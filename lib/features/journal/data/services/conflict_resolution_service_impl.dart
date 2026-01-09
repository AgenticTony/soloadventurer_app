import 'dart:async';
import 'package:soloadventurer/core/error/exceptions.dart';
import 'package:soloadventurer/core/errors/app_exception.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/tag_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/tag_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/journal_entry_model.dart';
import 'package:soloadventurer/features/journal/data/models/media_item_model.dart';
import 'package:soloadventurer/features/journal/data/models/trip_model.dart';
import 'package:soloadventurer/features/journal/data/models/tag_model.dart';
import 'package:soloadventurer/features/journal/domain/services/conflict_resolution_service.dart';
import 'package:uuid/uuid.dart';

/// Implementation of [ConflictResolutionService] with local storage
class ConflictResolutionServiceImpl implements ConflictResolutionService {
  final JournalLocalDataSource _journalLocalDataSource;
  final JournalRemoteDataSource _journalRemoteDataSource;
  final TripLocalDataSource _tripLocalDataSource;
  final TripRemoteDataSource _tripRemoteDataSource;
  final TagLocalDataSource _tagLocalDataSource;
  final TagRemoteDataSource _tagRemoteDataSource;

  final _conflictController = StreamController<SyncConflict>.broadcast();
  final _resolutionController = StreamController<ConflictResolutionResult>.broadcast();

  final List<SyncConflict> _conflicts = [];
  final List<ConflictResolutionResult> _resolutionHistory = [];

  final List<ConflictDetectedCallback> _conflictCallbacks = [];
  final List<ConflictResolvedCallback> _resolutionCallbacks = [];

  final Uuid _uuid = const Uuid();

  ConflictResolutionServiceImpl({
    required JournalLocalDataSource journalLocalDataSource,
    required JournalRemoteDataSource journalRemoteDataSource,
    required TripLocalDataSource tripLocalDataSource,
    required TripRemoteDataSource tripRemoteDataSource,
    required TagLocalDataSource tagLocalDataSource,
    required TagRemoteDataSource tagRemoteDataSource,
  })  : _journalLocalDataSource = journalLocalDataSource,
        _journalRemoteDataSource = journalRemoteDataSource,
        _tripLocalDataSource = tripLocalDataSource,
        _tripRemoteDataSource = tripRemoteDataSource,
        _tagLocalDataSource = tagLocalDataSource,
        _tagRemoteDataSource = tagRemoteDataSource;

  @override
  Stream<SyncConflict> get conflictStream => _conflictController.stream;

  @override
  Stream<ConflictResolutionResult> get resolutionStream =>
      _resolutionController.stream;

  @override
  Future<bool> get hasPendingConflicts async {
    return _conflicts.any((c) => !c.isResolved);
  }

  @override
  Future<List<SyncConflict>> getPendingConflicts() async {
    return _conflicts.where((c) => !c.isResolved).toList();
  }

  @override
  Future<List<SyncConflict>> getAllConflicts() async {
    return List.from(_conflicts);
  }

  @override
  Future<List<SyncConflict>> getConflictsByType(String entityType) async {
    return _conflicts.where((c) => c.entityType == entityType).toList();
  }

  @override
  Future<List<SyncConflict>> getConflictsBySeverity(
    ConflictSeverity severity,
  ) async {
    return _conflicts.where((c) => c.severity == severity).toList();
  }

  @override
  Future<SyncConflict?> getConflict(String conflictId) async {
    try {
      return _conflicts.firstWhere((c) => c.conflictId == conflictId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<SyncConflict?> detectConflict({
    required String entityType,
    required Map<String, dynamic> localVersion,
    required Map<String, dynamic> remoteVersion,
  }) async {
    final localUpdatedAt = DateTime.parse(localVersion['updated_at'] as String);
    final remoteUpdatedAt = DateTime.parse(remoteVersion['updated_at'] as String);

    // Check if both versions were modified around the same time (potential conflict)
    final timeDifference = localUpdatedAt.difference(remoteUpdatedAt).abs();

    // If time difference is small (less than 1 minute), it's likely a conflict
    final isConcurrent = timeDifference.inSeconds < 60;

    if (!isConcurrent) {
      return null; // No conflict
    }

    // Determine conflict type
    final conflictType = _determineConflictType(
      localVersion,
      remoteVersion,
    );

    // Determine severity
    final severity = _determineSeverity(conflictType, entityType);

    // Detect field conflicts
    final fieldsToCheck = _getFieldsToCheck(entityType);
    final fieldConflicts = detectFieldConflicts(
      localVersion: localVersion,
      remoteVersion: remoteVersion,
      fields: fieldsToCheck,
    );

    // Create conflict
    final conflict = SyncConflict(
      conflictId: _uuid.v4(),
      entityType: entityType,
      entityId: localVersion['id'] as String,
      conflictType: conflictType,
      severity: severity,
      localVersion: localVersion,
      remoteVersion: remoteVersion,
      localUpdatedAt: localUpdatedAt,
      remoteUpdatedAt: remoteUpdatedAt,
      reason: _generateReason(conflictType, entityType),
      fieldConflicts: fieldConflicts,
      status: ConflictResolutionStatus.pending,
      detectedAt: DateTime.now(),
    );

    // Store conflict
    _conflicts.add(conflict);

    // Notify listeners
    _conflictController.add(conflict);
    for (final callback in _conflictCallbacks) {
      callback(conflict);
    }

    return conflict;
  }

  @override
  List<FieldConflict> detectFieldConflicts({
    required Map<String, dynamic> localVersion,
    required Map<String, dynamic> remoteVersion,
    required List<String> fields,
  }) {
    final conflicts = <FieldConflict>[];

    for (final field in fields) {
      final localValue = localVersion[field];
      final remoteValue = remoteVersion[field];

      if (localValue != remoteValue) {
        conflicts.add(FieldConflict(
          fieldName: field,
          localValue: localValue,
          remoteValue: remoteValue,
          canMerge: _canMergeField(field),
        ));
      }
    }

    return conflicts;
  }

  @override
  Future<ConflictResolutionResult> resolveConflict(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy, {
    Map<String, dynamic>? resolvedVersion,
  }) async {
    try {
      // Update conflict status to in progress
      final updatedConflict = conflict.copyWith(
        status: ConflictResolutionStatus.inProgress,
        retryCount: conflict.retryCount + 1,
      );
      _updateConflict(updatedConflict);

      Map<String, dynamic>? finalVersion;

      switch (strategy) {
        case ConflictResolutionStrategy.mostRecent:
          finalVersion = await _resolveMostRecent(conflict);
          break;

        case ConflictResolutionStrategy.localWins:
          finalVersion = await _resolveLocalWins(conflict);
          break;

        case ConflictResolutionStrategy.remoteWins:
          finalVersion = await _resolveRemoteWins(conflict);
          break;

        case ConflictResolutionStrategy.manual:
          if (resolvedVersion == null) {
            throw const ValidationException(
              message: 'resolvedVersion is required for manual resolution',
              errors: {},
            );
          }
          finalVersion = await _resolveManual(conflict, resolvedVersion);
          break;

        case ConflictResolutionStrategy.merge:
          finalVersion = await _resolveMerge(conflict);
          break;

        case ConflictResolutionStrategy.keepBoth:
          finalVersion = await _resolveKeepBoth(conflict);
          break;
      }

      // Apply the resolved version
      await _applyResolution(conflict, finalVersion!);

      // Update conflict status to resolved
      final resolvedConflict = conflict.copyWith(
        status: ConflictResolutionStatus.resolved,
        resolvedAt: DateTime.now(),
        resolutionStrategy: strategy,
      );
      _updateConflict(resolvedConflict);

      final result = ConflictResolutionResult.success(
        conflict: resolvedConflict,
        strategy: strategy,
        resolvedVersion: finalVersion,
      );

      // Notify listeners
      _resolutionController.add(result);
      for (final callback in _resolutionCallbacks) {
        callback(resolvedConflict, result);
      }

      return result;
    } catch (e) {
      // Update conflict status to failed
      final failedConflict = conflict.copyWith(
        status: ConflictResolutionStatus.failed,
        resolutionError: e.toString(),
      );
      _updateConflict(failedConflict);

      final result = ConflictResolutionResult.failure(
        conflict: failedConflict,
        strategy: strategy,
        error: e.toString(),
      );

      _resolutionController.add(result);

      return result;
    }
  }

  @override
  Future<List<ConflictResolutionResult>> resolveMultipleConflicts(
    List<SyncConflict> conflicts,
    ConflictResolutionStrategy strategy,
  ) async {
    final results = <ConflictResolutionResult>[];

    for (final conflict in conflicts) {
      final result = await resolveConflict(conflict, strategy);
      results.add(result);
    }

    return results;
  }

  @override
  Future<List<ConflictResolutionResult>> resolveAllPending(
    ConflictResolutionStrategy strategy, {
    ConflictSeverity? maxSeverity,
  }) async {
    final pendingConflicts = await getPendingConflicts();

    final filteredConflicts = maxSeverity != null
        ? pendingConflicts
            .where((c) => c.severity.index <= maxSeverity.index)
            .toList()
        : pendingConflicts;

    return resolveMultipleConflicts(filteredConflicts, strategy);
  }

  @override
  Future<void> ignoreConflict(String conflictId) async {
    final conflict = await getConflict(conflictId);
    if (conflict == null) {
      throw NotFoundException(
        message: 'Conflict not found: $conflictId',
      );
    }

    final ignoredConflict = conflict.copyWith(
      status: ConflictResolutionStatus.ignored,
      resolvedAt: DateTime.now(),
    );
    _updateConflict(ignoredConflict);
  }

  @override
  Future<ConflictResolutionResult?> retryConflict(String conflictId) async {
    final conflict = await getConflict(conflictId);
    if (conflict == null) {
      throw NotFoundException(
        message: 'Conflict not found: $conflictId',
      );
    }

    if (!conflict.failed) {
      throw const ValidationException(
        message: 'Can only retry failed conflicts',
        errors: {},
      );
    }

    final strategy = conflict.resolutionStrategy;
    if (strategy == null) {
      throw const ValidationException(
        message: 'No resolution strategy to retry',
        errors: {},
      );
    }

    return resolveConflict(conflict, strategy);
  }

  @override
  Future<ConflictResolutionStatistics> getStatistics() async {
    final total = _conflicts.length;
    final resolved = _conflicts.where((c) => c.status == ConflictResolutionStatus.resolved).length;
    final failed = _conflicts.where((c) => c.status == ConflictResolutionStatus.failed).length;
    final ignored = _conflicts.where((c) => c.status == ConflictResolutionStatus.ignored).length;
    final pending = _conflicts.where((c) => !c.isResolved).length;

    // Calculate most common conflict type
    final typeCounts = <ConflictType, int>{};
    for (final conflict in _conflicts) {
      typeCounts[conflict.conflictType] =
          (typeCounts[conflict.conflictType] ?? 0) + 1;
    }
    final mostCommonType = typeCounts.entries.isEmpty
        ? null
        : typeCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

    // Calculate average resolution time
    final resolvedConflicts =
        _conflicts.where((c) => c.resolvedAt != null).toList();
    final avgTime = resolvedConflicts.isEmpty
        ? Duration.zero
        : Duration(
            microseconds: resolvedConflicts
                    .map((c) => c.resolvedAt!.difference(c.detectedAt).inMicroseconds)
                    .reduce((a, b) => a + b) ~/
                resolvedConflicts.length,
          );

    return ConflictResolutionStatistics(
      totalConflicts: total,
      resolvedConflicts: resolved,
      failedConflicts: failed,
      ignoredConflicts: ignored,
      pendingConflicts: pending,
      mostCommonType: mostCommonType,
      averageResolutionTime: avgTime,
    );
  }

  @override
  Future<List<SyncConflict>> getResolutionHistory(String entityId) async {
    return _conflicts.where((c) => c.entityId == entityId).toList();
  }

  @override
  Future<void> clearResolvedConflicts() async {
    _conflicts.removeWhere((c) => c.isResolved);
  }

  @override
  Future<void> clearAllConflicts() async {
    _conflicts.clear();
    _resolutionHistory.clear();
  }

  @override
  void onConflictDetected(ConflictDetectedCallback callback) {
    _conflictCallbacks.add(callback);
  }

  @override
  void onConflictResolved(ConflictResolvedCallback callback) {
    _resolutionCallbacks.add(callback);
  }

  @override
  void removeConflictDetectedCallback(ConflictDetectedCallback callback) {
    _conflictCallbacks.remove(callback);
  }

  @override
  void removeConflictResolvedCallback(ConflictResolvedCallback callback) {
    _resolutionCallbacks.remove(callback);
  }

  @override
  Future<void> initialize() async {
    // Initialize conflict resolution service
    // Could load conflicts from persistent storage here
  }

  @override
  Future<void> dispose() async {
    await _conflictController.close();
    await _resolutionController.close();
  }

  // Private helper methods

  void _updateConflict(SyncConflict conflict) {
    final index = _conflicts.indexWhere((c) => c.conflictId == conflict.conflictId);
    if (index != -1) {
      _conflicts[index] = conflict;
    }
  }

  ConflictType _determineConflictType(
    Map<String, dynamic> localVersion,
    Map<String, dynamic> remoteVersion,
  ) {
    final localDeleted = localVersion['deleted_at'] != null;
    final remoteDeleted = remoteVersion['deleted_at'] != null;

    if (localDeleted && remoteDeleted) {
      return ConflictType.deletedModified;
    } else if (localDeleted) {
      return ConflictType.modifiedDeleted;
    } else if (remoteDeleted) {
      return ConflictType.deletedModified;
    } else {
      return ConflictType.fieldConflict;
    }
  }

  ConflictSeverity _determineSeverity(ConflictType type, String entityType) {
    switch (type) {
      case ConflictType.deletedModified:
      case ConflictType.modifiedDeleted:
        return ConflictSeverity.high;

      case ConflictType.relationshipConflict:
        return ConflictSeverity.critical;

      case ConflictType.mediaConflict:
        return ConflictSeverity.high;

      case ConflictType.concurrentModification:
        return ConflictSeverity.medium;

      case ConflictType.fieldConflict:
        return ConflictSeverity.low;

      default:
        return ConflictSeverity.medium;
    }
  }

  String _generateReason(ConflictType type, String entityType) {
    switch (type) {
      case ConflictType.fieldConflict:
        return '$entityType has conflicting field values';
      case ConflictType.deletedModified:
        return '$entityType was deleted locally but modified remotely';
      case ConflictType.modifiedDeleted:
        return '$entityType was modified locally but deleted remotely';
      case ConflictType.relationshipConflict:
        return '$entityType has conflicting parent/child relationships';
      case ConflictType.mediaConflict:
        return 'Media file conflict detected';
      case ConflictType.concurrentModification:
        return '$entityType was modified concurrently on multiple devices';
      default:
        return 'Unknown conflict detected for $entityType';
    }
  }

  List<String> _getFieldsToCheck(String entityType) {
    switch (entityType) {
      case 'journal_entry':
        return ['title', 'content', 'mood', 'location_name'];
      case 'trip':
        return ['name', 'description', 'start_date', 'end_date'];
      case 'tag':
        return ['name', 'color'];
      case 'media_item':
        return ['caption', 'media_type'];
      default:
        return [];
    }
  }

  bool _canMergeField(String field) {
    // Some fields can be intelligently merged
    return false; // For now, no auto-merge
  }

  Future<Map<String, dynamic>> _resolveMostRecent(
    SyncConflict conflict,
  ) async {
    if (conflict.remoteUpdatedAt.isAfter(conflict.localUpdatedAt)) {
      return conflict.remoteVersion;
    } else {
      return conflict.localVersion;
    }
  }

  Future<Map<String, dynamic>> _resolveLocalWins(
    SyncConflict conflict,
  ) async {
    return conflict.localVersion;
  }

  Future<Map<String, dynamic>> _resolveRemoteWins(
    SyncConflict conflict,
  ) async {
    return conflict.remoteVersion;
  }

  Future<Map<String, dynamic>> _resolveManual(
    SyncConflict conflict,
    Map<String, dynamic> resolvedVersion,
  ) async {
    return resolvedVersion;
  }

  Future<Map<String, dynamic>> _resolveMerge(
    SyncConflict conflict,
  ) async {
    // For now, merge defaults to most recent
    // In a more sophisticated implementation, this could merge field by field
    return _resolveMostRecent(conflict);
  }

  Future<Map<String, dynamic>> _resolveKeepBoth(
    SyncConflict conflict,
  ) async {
    // Create a copy with a new ID
    final copy = Map<String, dynamic>.from(conflict.localVersion);
    copy['id'] = _uuid.v4();
    copy['title'] = '${copy['title']} (Copy)';
    copy['created_at'] = DateTime.now().toIso8601String();
    copy['updated_at'] = DateTime.now().toIso8601String();

    return copy;
  }

  Future<void> _applyResolution(
    SyncConflict conflict,
    Map<String, dynamic> resolvedVersion,
  ) async {
    final entity = conflict.entityType;

    switch (entity) {
      case 'journal_entry':
        final entry = JournalEntryModel.fromJson(resolvedVersion);
        await _journalLocalDataSource.updateEntry(entry);
        await _journalRemoteDataSource.updateEntry(entry);
        await _journalLocalDataSource.updateSyncStatus(entry.id, 'synced');
        break;

      case 'trip':
        final trip = TripModel.fromJson(resolvedVersion);
        await _tripLocalDataSource.updateTrip(trip);
        await _tripRemoteDataSource.updateTrip(trip);
        await _tripLocalDataSource.updateSyncStatus(trip.id, 'synced');
        break;

      case 'tag':
        final tag = TagModel.fromJson(resolvedVersion);
        await _tagLocalDataSource.updateTag(tag);
        await _tagRemoteDataSource.updateTag(tag);
        await _tagLocalDataSource.updateSyncStatus(tag.id, 'synced');
        break;

      case 'media_item':
        final media = MediaItemModel.fromJson(resolvedVersion);
        await _journalLocalDataSource.updateMedia(media);
        await _journalRemoteDataSource.updateMedia(media);
        await _journalLocalDataSource.updateMediaSyncStatus(media.id, 'synced');
        break;

      default:
        throw ValidationException(
          message: 'Unknown entity type: $entity',
          errors: {'entity_type': ['Unknown type']},
        );
    }
  }
}
