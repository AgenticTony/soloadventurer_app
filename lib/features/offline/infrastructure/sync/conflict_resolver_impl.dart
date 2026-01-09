import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/trip_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/journal_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/user_dao.dart';
import 'package:soloadventurer/features/offline/domain/services/conflict_resolver.dart';

/// In-memory conflict log for tracking conflicts
///
/// In a production app, this would be persisted to the database.
/// For now, we store conflicts in memory with the ability to
/// persist critical conflicts to the database if needed.
class ConflictLog {
  /// All recorded conflicts
  final List<Conflict> _conflicts = [];

  /// Adds a conflict to the log
  void add(Conflict conflict) {
    _conflicts.add(conflict);
    debugPrint(
        '⚔️ Conflict recorded: ${conflict.entityType}/${conflict.entityId} '
        '(${conflict.type})');
  }

  /// Gets all unresolved conflicts
  List<Conflict> getUnresolved() {
    return _conflicts.where((c) => !c.isResolved).toList();
  }

  /// Gets conflicts by entity type
  List<Conflict> getByType(EntityType type) {
    return _conflicts.where((c) => c.entityType == type).toList();
  }

  /// Gets conflict history
  List<Conflict> getHistory({DateTime? startDate, DateTime? endDate}) {
    var conflicts = _conflicts.toList();

    if (startDate != null) {
      conflicts =
          conflicts.where((c) => c.detectedAt.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      conflicts =
          conflicts.where((c) => c.detectedAt.isBefore(endDate)).toList();
    }

    return conflicts;
  }

  /// Clears old resolved conflicts
  void clearOld(DateTime beforeDate) {
    _conflicts.removeWhere((c) =>
        c.isResolved &&
        c.resolvedAt != null &&
        c.resolvedAt!.isBefore(beforeDate));

    debugPrint('🗑️ Cleared old conflicts from before $beforeDate');
  }

  /// Gets total count
  int get length => _conflicts.length;

  /// Clears all conflicts
  void clear() {
    _conflicts.clear();
  }

  /// Gets all conflicts (for testing purposes)
  List<Conflict> get all => List.unmodifiable(_conflicts);
}

/// Implementation of [ConflictResolver]
///
/// This resolver provides multiple strategies for handling conflicts
/// that occur when the same entity is modified on both client and server.
///
/// Resolution strategies:
/// - **lastWriteWins**: Uses the most recently modified version
/// - **serverWins**: Always prefers the server version
/// - **clientWins**: Always prefers the client version
/// - **manual**: Requires user intervention
///
/// The resolver maintains a log of all conflicts for auditing purposes
/// and can automatically resolve conflicts based on entity type and severity.
class ConflictResolverImpl implements ConflictResolver {
  /// AppDatabase instance for data operations
  final AppDatabase _database;

  /// Conflict log for tracking all conflicts
  final ConflictLog _conflictLog;

  /// Uuid generator for conflict IDs
  final Uuid _uuid = const Uuid();

  /// Default resolution strategy for each entity type
  final Map<EntityType, ConflictResolutionStrategy> _defaultStrategies;

  /// Data Access Objects
  late final TripDao _tripDao = TripDao(_database);
  late final JournalDao _journalDao = JournalDao(_database);
  late final UserDao _userDao = UserDao(_database);

  /// Creates a new [ConflictResolverImpl] instance
  ///
  /// [database] - AppDatabase instance for data operations
  /// [defaultStrategies] - Optional custom default strategies per entity type
  ConflictResolverImpl({
    required AppDatabase database,
    Map<EntityType, ConflictResolutionStrategy>? defaultStrategies,
  })  : _database = database,
        _conflictLog = ConflictLog(),
        _defaultStrategies = defaultStrategies ??
            const {
              // For trips, prefer server version (more authoritative)
              EntityType.trip: ConflictResolutionStrategy.serverWins,

              // For journals, prefer client version (personal data)
              EntityType.journal: ConflictResolutionStrategy.clientWins,

              // For user profile, prefer last write
              EntityType.userProfile: ConflictResolutionStrategy.lastWriteWins,

              // For preferences, always prefer client
              EntityType.travelPreference:
                  ConflictResolutionStrategy.clientWins,
            };

  // ==============================================================================
  // PUBLIC API - CONFLICT RETRIEVAL
  // ==============================================================================

  @override
  Future<List<Conflict>> getUnresolvedConflicts() async {
    final conflicts = _conflictLog.getUnresolved();
    debugPrint('📊 Found ${conflicts.length} unresolved conflicts');
    return conflicts;
  }

  @override
  Future<List<Conflict>> getConflictsByType(EntityType entityType) async {
    final conflicts = _conflictLog.getByType(entityType);
    debugPrint('📊 Found ${conflicts.length} conflicts for $entityType');
    return conflicts;
  }

  @override
  Future<List<Conflict>> getConflictHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final conflicts = _conflictLog.getHistory(
      startDate: startDate,
      endDate: endDate,
    );
    debugPrint('📊 Found ${conflicts.length} conflicts in history');
    return conflicts;
  }

  // ==============================================================================
  // PUBLIC API - CONFLICT RESOLUTION
  // ==============================================================================

  @override
  Future<bool> resolveConflict(
    String conflictId,
    ConflictResolutionStrategy strategy,
  ) async {
    try {
      debugPrint('⚔️ Resolving conflict $conflictId with $strategy');

      // Find the conflict
      final conflicts = await getUnresolvedConflicts();
      final conflict = conflicts.where((c) => c.id == conflictId).firstOrNull;

      if (conflict == null) {
        debugPrint('❌ Conflict not found: $conflictId');
        return false;
      }

      // Apply the resolution strategy
      bool success;
      switch (strategy) {
        case ConflictResolutionStrategy.lastWriteWins:
          success = await _resolveWithLastWriteWins(conflict);
          break;
        case ConflictResolutionStrategy.serverWins:
          success = await _resolveWithServerWins(conflict);
          break;
        case ConflictResolutionStrategy.clientWins:
          success = await _resolveWithClientWins(conflict);
          break;
        case ConflictResolutionStrategy.manual:
          debugPrint('⚠️ Manual resolution required for $conflictId');
          // For manual resolution, we don't auto-resolve
          // The user will need to handle this through UI
          return true;
      }

      if (success) {
        // Mark conflict as resolved in the log
        final resolvedConflict = conflict.markAsResolved(strategy);
        _updateConflictInLog(resolvedConflict);
        debugPrint('✅ Conflict $conflictId resolved successfully');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error resolving conflict $conflictId: $e');
      return false;
    }
  }

  @override
  Future<ConflictResolutionResult> resolveAllConflicts() async {
    debugPrint('⚔️ Starting automatic conflict resolution...');

    final conflicts = await getUnresolvedConflicts();

    int resolvedCount = 0;
    int manualCount = 0;
    int failedCount = 0;
    final pendingConflicts = <Conflict>[];

    for (final conflict in conflicts) {
      // Get the default strategy for this entity type
      final strategy = _defaultStrategies[conflict.entityType] ??
          ConflictResolutionStrategy.lastWriteWins;

      // Skip manual resolution
      if (strategy == ConflictResolutionStrategy.manual) {
        manualCount++;
        pendingConflicts.add(conflict);
        continue;
      }

      // Try to resolve the conflict
      final success = await resolveConflict(conflict.id, strategy);

      if (success) {
        resolvedCount++;
      } else {
        failedCount++;
        pendingConflicts.add(conflict);
      }
    }

    debugPrint('⚔️ Conflict resolution complete: '
        '$resolvedCount resolved, $manualCount manual, $failedCount failed');

    return ConflictResolutionResult(
      resolvedCount: resolvedCount,
      manualResolutionRequired: manualCount,
      failedCount: failedCount,
      pendingConflicts: pendingConflicts,
    );
  }

  // ==============================================================================
  // PUBLIC API - CONFLICT RECORDING
  // ==============================================================================

  @override
  Future<void> recordConflict(Conflict conflict) async {
    _conflictLog.add(conflict);
  }

  @override
  Future<void> clearOldConflicts(DateTime beforeDate) async {
    _conflictLog.clearOld(beforeDate);
  }

  // ==============================================================================
  // PRIVATE METHODS - RESOLUTION STRATEGIES
  // ==============================================================================

  /// Resolves conflict by choosing the most recently modified version
  ///
  /// This strategy compares the updatedAt timestamps of the client
  /// and server versions, and chooses the most recent one.
  Future<bool> _resolveWithLastWriteWins(Conflict conflict) async {
    try {
      final clientIsNewer =
          conflict.clientUpdatedAt.isAfter(conflict.serverUpdatedAt);

      if (clientIsNewer) {
        debugPrint('📝 Client version is newer for ${conflict.entityId}');
        return await _applyClientVersion(conflict);
      } else {
        debugPrint('📝 Server version is newer for ${conflict.entityId}');
        return await _applyServerVersion(conflict);
      }
    } catch (e) {
      debugPrint('❌ Error in last-write-wins resolution: $e');
      return false;
    }
  }

  /// Resolves conflict by always choosing the server version
  ///
  /// This strategy is appropriate for authoritative data where
  /// the server is considered the source of truth.
  Future<bool> _resolveWithServerWins(Conflict conflict) async {
    try {
      debugPrint('🔒 Applying server version for ${conflict.entityId}');
      return await _applyServerVersion(conflict);
    } catch (e) {
      debugPrint('❌ Error in server-wins resolution: $e');
      return false;
    }
  }

  /// Resolves conflict by always choosing the client version
  ///
  /// This strategy is appropriate for user-specific data where
  /// the client's changes should take precedence.
  Future<bool> _resolveWithClientWins(Conflict conflict) async {
    try {
      debugPrint('👤 Applying client version for ${conflict.entityId}');
      return await _applyClientVersion(conflict);
    } catch (e) {
      debugPrint('❌ Error in client-wins resolution: $e');
      return false;
    }
  }

  /// Applies the client version of the conflicted entity
  ///
  /// Updates the local database with the client version and
  /// queues a sync operation to upload it to the server.
  Future<bool> _applyClientVersion(Conflict conflict) async {
    try {
      switch (conflict.entityType) {
        case EntityType.trip:
          return await _applyClientTripVersion(conflict);
        case EntityType.journal:
          return await _applyClientJournalVersion(conflict);
        case EntityType.userProfile:
          return await _applyClientUserVersion(conflict);
        case EntityType.travelPreference:
          // For now, skip preferences as they're not fully implemented
          debugPrint(
              '⚠️ Preferences not yet supported for conflict resolution');
          return true;
        case EntityType.other:
          debugPrint('⚠️ Unknown entity type, cannot resolve');
          return false;
      }
    } catch (e) {
      debugPrint('❌ Error applying client version: $e');
      return false;
    }
  }

  /// Applies the server version of the conflicted entity
  ///
  /// Updates the local database with the server version.
  Future<bool> _applyServerVersion(Conflict conflict) async {
    try {
      switch (conflict.entityType) {
        case EntityType.trip:
          return await _applyServerTripVersion(conflict);
        case EntityType.journal:
          return await _applyServerJournalVersion(conflict);
        case EntityType.userProfile:
          return await _applyServerUserVersion(conflict);
        case EntityType.travelPreference:
          // For now, skip preferences
          debugPrint(
              '⚠️ Preferences not yet supported for conflict resolution');
          return true;
        case EntityType.other:
          debugPrint('⚠️ Unknown entity type, cannot resolve');
          return false;
      }
    } catch (e) {
      debugPrint('❌ Error applying server version: $e');
      return false;
    }
  }

  // ==============================================================================
  // PRIVATE METHODS - ENTITY-SPECIFIC RESOLUTION
  // ==============================================================================

  /// Applies client version for a trip conflict
  Future<bool> _applyClientTripVersion(Conflict conflict) async {
    try {
      // Update the trip with client data using database write method
      await (_database.update(_database.trips)
            ..where((t) => t.id.equals(conflict.entityId)))
          .write(TripsCompanion(
        hasPendingChanges: const Value(true),
        version: Value(conflict.clientData['version'] as int? ?? 0),
        updatedAt: Value(conflict.clientUpdatedAt),
      ));

      debugPrint('✅ Applied client version for trip ${conflict.entityId}');
      return true;
    } catch (e) {
      debugPrint('❌ Error applying client trip version: $e');
      return false;
    }
  }

  /// Applies server version for a trip conflict
  Future<bool> _applyServerTripVersion(Conflict conflict) async {
    try {
      // Update the trip with server data using database write method
      await (_database.update(_database.trips)
            ..where((t) => t.id.equals(conflict.entityId)))
          .write(TripsCompanion(
        hasPendingChanges: const Value(false),
        isSynced: const Value(true),
        version: Value(conflict.serverData['version'] as int? ?? 0),
        updatedAt: Value(conflict.serverUpdatedAt),
        lastSyncedAt: Value(DateTime.now()),
      ));

      debugPrint('✅ Applied server version for trip ${conflict.entityId}');
      return true;
    } catch (e) {
      debugPrint('❌ Error applying server trip version: $e');
      return false;
    }
  }

  /// Applies client version for a journal conflict
  Future<bool> _applyClientJournalVersion(Conflict conflict) async {
    try {
      // Update the journal with client data using database write method
      await (_database.update(_database.journals)
            ..where((j) => j.id.equals(conflict.entityId)))
          .write(JournalsCompanion(
        hasPendingChanges: const Value(true),
        version: Value(conflict.clientData['version'] as int? ?? 0),
        updatedAt: Value(conflict.clientUpdatedAt),
      ));

      debugPrint('✅ Applied client version for journal ${conflict.entityId}');
      return true;
    } catch (e) {
      debugPrint('❌ Error applying client journal version: $e');
      return false;
    }
  }

  /// Applies server version for a journal conflict
  Future<bool> _applyServerJournalVersion(Conflict conflict) async {
    try {
      // Update the journal with server data using database write method
      await (_database.update(_database.journals)
            ..where((j) => j.id.equals(conflict.entityId)))
          .write(JournalsCompanion(
        hasPendingChanges: const Value(false),
        isSynced: const Value(true),
        version: Value(conflict.serverData['version'] as int? ?? 0),
        updatedAt: Value(conflict.serverUpdatedAt),
        lastSyncedAt: Value(DateTime.now()),
      ));

      debugPrint('✅ Applied server version for journal ${conflict.entityId}');
      return true;
    } catch (e) {
      debugPrint('❌ Error applying server journal version: $e');
      return false;
    }
  }

  /// Applies client version for a user profile conflict
  Future<bool> _applyClientUserVersion(Conflict conflict) async {
    try {
      // Update the user with client data using database write method
      await (_database.update(_database.users)
            ..where((u) => u.id.equals(conflict.entityId)))
          .write(UsersCompanion(
        hasPendingChanges: const Value(true),
        version: Value(conflict.clientData['version'] as int? ?? 0),
        updatedAt: Value(conflict.clientUpdatedAt),
      ));

      debugPrint('✅ Applied client version for user ${conflict.entityId}');
      return true;
    } catch (e) {
      debugPrint('❌ Error applying client user version: $e');
      return false;
    }
  }

  /// Applies server version for a user profile conflict
  Future<bool> _applyServerUserVersion(Conflict conflict) async {
    try {
      // Update the user with server data using database write method
      await (_database.update(_database.users)
            ..where((u) => u.id.equals(conflict.entityId)))
          .write(UsersCompanion(
        hasPendingChanges: const Value(false),
        isSynced: const Value(true),
        version: Value(conflict.serverData['version'] as int? ?? 0),
        updatedAt: Value(conflict.serverUpdatedAt),
        lastSyncedAt: Value(DateTime.now()),
      ));

      debugPrint('✅ Applied server version for user ${conflict.entityId}');
      return true;
    } catch (e) {
      debugPrint('❌ Error applying server user version: $e');
      return false;
    }
  }

  // ==============================================================================
  // PRIVATE METHODS - LOGGING
  // ==============================================================================

  /// Updates a conflict in the log
  void _updateConflictInLog(Conflict updatedConflict) {
    // Find and replace the conflict in the log
    final index = _conflictLog._conflicts.indexWhere(
      (c) => c.id == updatedConflict.id,
    );

    if (index != -1) {
      _conflictLog._conflicts[index] = updatedConflict;
    }
  }

  // ==============================================================================
  // UTILITY METHODS
  // ==============================================================================

  /// Creates a new conflict ID
  String _createConflictId() {
    return 'conflict_${_uuid.v4()}';
  }

  /// Determines the severity of a conflict
  ConflictSeverity _determineSeverity(
      ConflictType type, EntityType entityType) {
    switch (type) {
      case ConflictType.deleteModify:
        return ConflictSeverity.high;
      case ConflictType.concurrentUpdate:
        return entityType == EntityType.trip
            ? ConflictSeverity.medium
            : ConflictSeverity.low;
      case ConflictType.duplicateCreate:
        return ConflictSeverity.high;
      case ConflictType.versionMismatch:
        return ConflictSeverity.low;
    }
  }
}
