import 'dart:async';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/core/domain/services/connectivity_service.dart';
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
import 'package:soloadventurer/features/journal/domain/services/sync_service.dart';

/// Implementation of [SyncService] using local SQLite and remote Supabase
class SyncServiceImpl implements SyncService {
  final JournalLocalDataSource _journalLocalDataSource;
  final JournalRemoteDataSource _journalRemoteDataSource;
  final TripLocalDataSource _tripLocalDataSource;
  final TripRemoteDataSource _tripRemoteDataSource;
  final TagLocalDataSource _tagLocalDataSource;
  final TagRemoteDataSource _tagRemoteDataSource;
  final ConnectivityService _connectivityService;

  final _progressController = StreamController<SyncProgress>.broadcast();
  final _conflictController = StreamController<SyncConflict>.broadcast();

  SyncProgress _currentProgress = const SyncProgress(totalItems: 0);
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  bool _isCancelled = false;

  final List<SyncProgressCallback> _progressCallbacks = [];
  final List<SyncConflictCallback> _conflictCallbacks = [];

  SyncStatistics _statistics = const SyncStatistics(
    totalSyncs: 0,
    successfulSyncs: 0,
    failedSyncs: 0,
  );

  SyncServiceImpl({
    required JournalLocalDataSource journalLocalDataSource,
    required JournalRemoteDataSource journalRemoteDataSource,
    required TripLocalDataSource tripLocalDataSource,
    required TripRemoteDataSource tripRemoteDataSource,
    required TagLocalDataSource tagLocalDataSource,
    required TagRemoteDataSource tagRemoteDataSource,
    required ConnectivityService connectivityService,
  })  : _journalLocalDataSource = journalLocalDataSource,
        _journalRemoteDataSource = journalRemoteDataSource,
        _tripLocalDataSource = tripLocalDataSource,
        _tripRemoteDataSource = tripRemoteDataSource,
        _tagLocalDataSource = tagLocalDataSource,
        _tagRemoteDataSource = tagRemoteDataSource,
        _connectivityService = connectivityService;

  @override
  SyncProgress get currentProgress => _currentProgress;

  @override
  Stream<SyncProgress> get progressStream => _progressController.stream;

  @override
  Stream<SyncConflict> get conflictStream => _conflictController.stream;

  @override
  bool get isSyncing => _isSyncing;

  @override
  DateTime? get lastSyncTime => _lastSyncTime;

  @override
  Future<SyncResult> syncAll([SyncConfig? config]) async {
    final effectiveConfig = config ?? SyncConfig.defaultConfig;
    final startedAt = DateTime.now();

    try {
      _isSyncing = true;
      _isCancelled = false;

      // Check connectivity first
      final hasConnection = await _connectivityService.hasConnectivity;
      if (!hasConnection) {
        throw const ServerException(
          message: 'No network connection available',
          statusCode: 503,
        );
      }

      int totalUploaded = 0;
      int totalDownloaded = 0;
      int totalConflicts = 0;
      final allErrors = <String>[];

      // Sync entries first
      _updateProgress(
        const SyncProgress(
          totalItems: 100,
          currentOperation: SyncOperationType.entries,
        ),
      );

      final entriesResult = await syncEntries(
        SyncDirection.bidirectional,
        effectiveConfig,
      );

      totalUploaded += entriesResult.uploadedCount;
      totalDownloaded += entriesResult.downloadedCount;
      totalConflicts += entriesResult.conflictCount;
      allErrors.addAll(entriesResult.errors);

      // Sync trips
      _updateProgress(
        const SyncProgress(
          totalItems: 100,
          syncedItems: 25,
          currentOperation: SyncOperationType.trips,
        ),
      );

      final tripsResult = await syncTrips(
        SyncDirection.bidirectional,
        effectiveConfig,
      );

      totalUploaded += tripsResult.uploadedCount;
      totalDownloaded += tripsResult.downloadedCount;
      totalConflicts += tripsResult.conflictCount;
      allErrors.addAll(tripsResult.errors);

      // Sync tags
      _updateProgress(
        const SyncProgress(
          totalItems: 100,
          syncedItems: 50,
          currentOperation: SyncOperationType.tags,
        ),
      );

      final tagsResult = await syncTags(
        SyncDirection.bidirectional,
        effectiveConfig,
      );

      totalUploaded += tagsResult.uploadedCount;
      totalDownloaded += tagsResult.downloadedCount;
      totalConflicts += tagsResult.conflictCount;
      allErrors.addAll(tagsResult.errors);

      // Sync media last (can be large)
      if (effectiveConfig.syncMedia) {
        _updateProgress(
          const SyncProgress(
            totalItems: 100,
            syncedItems: 75,
            currentOperation: SyncOperationType.media,
          ),
        );

        final mediaResult = await syncMedia(
          SyncDirection.bidirectional,
          effectiveConfig,
        );

        totalUploaded += mediaResult.uploadedCount;
        totalDownloaded += mediaResult.downloadedCount;
        totalConflicts += mediaResult.conflictCount;
        allErrors.addAll(mediaResult.errors);
      }

      // Mark all synced items
      _updateProgress(
        const SyncProgress(
          totalItems: 100,
          syncedItems: 100,
          currentOperation: SyncOperationType.full,
        ),
      );

      _isSyncing = false;
      _lastSyncTime = DateTime.now();

      final result = SyncResult.success(
        operationType: SyncOperationType.full,
        direction: SyncDirection.bidirectional,
        uploadedCount: totalUploaded,
        downloadedCount: totalDownloaded,
        conflictCount: totalConflicts,
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    } catch (e) {
      _isSyncing = false;

      final result = SyncResult.failure(
        operationType: SyncOperationType.full,
        direction: SyncDirection.bidirectional,
        errors: [e.toString()],
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    }
  }

  @override
  Future<SyncResult> syncEntries([
    SyncDirection direction = SyncDirection.bidirectional,
    SyncConfig? config,
  ]) async {
    final effectiveConfig = config ?? SyncConfig.defaultConfig;
    final startedAt = DateTime.now();

    try {
      int uploadedCount = 0;
      int downloadedCount = 0;
      int conflictCount = 0;

      if (direction == SyncDirection.upload ||
          direction == SyncDirection.bidirectional) {
        // Upload pending entries
        final pendingEntries =
            await _journalLocalDataSource.getEntriesBySyncStatus('pending');

        for (final entry in pendingEntries) {
          if (_isCancelled) break;

          try {
            final remoteEntry =
                await _journalRemoteDataSource.getEntry(entry.id);
            // Conflict: entry exists remotely
            conflictCount++;
            final conflict = SyncConflict(
              entityType: 'journal_entry',
              entityId: entry.id,
              localVersion: entry.toJson(),
              remoteVersion: remoteEntry.toJson(),
              localUpdatedAt: entry.updatedAt,
              remoteUpdatedAt: remoteEntry.updatedAt,
              reason: 'Entry modified both locally and remotely',
            );

            if (effectiveConfig.autoResolveConflicts) {
              await _autoResolveConflict(conflict, effectiveConfig);
            } else {
              _notifyConflict(conflict);
            }
          } on ServerException catch (e) {
            if (e.statusCode == 404) {
              // Entry doesn't exist remotely, upload it
              await _journalRemoteDataSource.createEntry(entry);
              await _journalLocalDataSource.updateSyncStatus(
                entry.id,
                'synced',
              );
              uploadedCount++;
            } else {
              rethrow;
            }
          }
        }
      }

      if (direction == SyncDirection.download ||
          direction == SyncDirection.bidirectional) {
        // Download remote entries
        final remoteEntries = await _journalRemoteDataSource.getEntries();

        for (final remoteEntry in remoteEntries) {
          if (_isCancelled) break;

          try {
            final localEntry =
                await _journalLocalDataSource.getEntry(remoteEntry.id);

            // Check if remote is newer
            if (remoteEntry.updatedAt.isAfter(localEntry!.updatedAt)) {
              await _journalLocalDataSource.updateEntry(remoteEntry);
              downloadedCount++;
            }
          } on AppException catch (e) {
            if (e is NotFoundException) {
              // Entry doesn't exist locally, create it
              await _journalLocalDataSource.createEntry(remoteEntry);
              downloadedCount++;
            }
          }
        }
      }

      final result = SyncResult.success(
        operationType: SyncOperationType.entries,
        direction: direction,
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        conflictCount: conflictCount,
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    } catch (e) {
      final result = SyncResult.failure(
        operationType: SyncOperationType.entries,
        direction: direction,
        errors: [e.toString()],
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    }
  }

  @override
  Future<SyncResult> syncMedia([
    SyncDirection direction = SyncDirection.bidirectional,
    SyncConfig? config,
  ]) async {
    final effectiveConfig = config ?? SyncConfig.defaultConfig;
    final startedAt = DateTime.now();

    try {
      int uploadedCount = 0;
      int downloadedCount = 0;
      int conflictCount = 0;

      if (direction == SyncDirection.upload ||
          direction == SyncDirection.bidirectional) {
        // Upload pending media
        final pendingMedia =
            await _journalLocalDataSource.getMediaBySyncStatus('pending');

        for (final media in pendingMedia) {
          if (_isCancelled) break;

          try {
            final remoteMedia = await _journalRemoteDataSource
                .getMediaForEntry(media.journalEntryId);
            final exists = remoteMedia.any((m) => m.id == media.id);

            if (exists) {
              conflictCount++;
            } else {
              await _journalRemoteDataSource.addMedia(media);
              await _journalLocalDataSource.updateMediaSyncStatus(
                media.id,
                'synced',
              );
              uploadedCount++;
            }
          } catch (e) {
            // Error uploading media, mark as failed
            await _journalLocalDataSource.updateMediaSyncStatus(
              media.id,
              'pending',
            );
          }
        }
      }

      if (direction == SyncDirection.download ||
          direction == SyncDirection.bidirectional) {
        // Note: Full media download is complex and may need pagination
        // For now, we'll sync media associated with synced entries
        final syncedEntries =
            await _journalLocalDataSource.getEntriesBySyncStatus('synced');

        for (final entry in syncedEntries) {
          if (_isCancelled) break;

          try {
            final remoteMedia =
                await _journalRemoteDataSource.getMediaForEntry(entry.id);
            final localMedia =
                await _journalLocalDataSource.getMediaForEntry(entry.id);

            for (final remote in remoteMedia) {
              final exists = localMedia.any((m) => m.id == remote.id);
              if (!exists) {
                await _journalLocalDataSource.addMedia(remote);
                downloadedCount++;
              }
            }
          } catch (e) {
            // Continue with next entry
          }
        }
      }

      final result = SyncResult.success(
        operationType: SyncOperationType.media,
        direction: direction,
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        conflictCount: conflictCount,
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    } catch (e) {
      final result = SyncResult.failure(
        operationType: SyncOperationType.media,
        direction: direction,
        errors: [e.toString()],
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    }
  }

  @override
  Future<SyncResult> syncTrips([
    SyncDirection direction = SyncDirection.bidirectional,
    SyncConfig? config,
  ]) async {
    final effectiveConfig = config ?? SyncConfig.defaultConfig;
    final startedAt = DateTime.now();

    try {
      int uploadedCount = 0;
      int downloadedCount = 0;
      int conflictCount = 0;

      if (direction == SyncDirection.upload ||
          direction == SyncDirection.bidirectional) {
        // Upload pending trips
        final pendingTrips =
            await _tripLocalDataSource.getTripsBySyncStatus('pending');

        for (final trip in pendingTrips) {
          if (_isCancelled) break;

          try {
            final remoteTrip = await _tripRemoteDataSource.getTrip(trip.id);
            // Conflict: trip exists remotely
            conflictCount++;
            final conflict = SyncConflict(
              entityType: 'trip',
              entityId: trip.id,
              localVersion: trip.toJson(),
              remoteVersion: remoteTrip.toJson(),
              localUpdatedAt: trip.updatedAt,
              remoteUpdatedAt: remoteTrip.updatedAt,
              reason: 'Trip modified both locally and remotely',
            );

            if (effectiveConfig.autoResolveConflicts) {
              await _autoResolveConflict(conflict, effectiveConfig);
            } else {
              _notifyConflict(conflict);
            }
          } on AppException catch (e) {
            if (e is NotFoundException) {
              // Trip doesn't exist remotely, upload it
              await _tripRemoteDataSource.createTrip(trip);
              await _tripLocalDataSource.updateSyncStatus(
                trip.id,
                'synced',
              );
              uploadedCount++;
            } else {
              rethrow;
            }
          }
        }
      }

      if (direction == SyncDirection.download ||
          direction == SyncDirection.bidirectional) {
        // Download remote trips
        final remoteTrips = await _tripRemoteDataSource.getTrips();

        for (final remoteTrip in remoteTrips) {
          if (_isCancelled) break;

          try {
            final localTrip = await _tripLocalDataSource.getTrip(remoteTrip.id);

            // Check if remote is newer
            if (remoteTrip.updatedAt.isAfter(localTrip!.updatedAt)) {
              await _tripLocalDataSource.updateTrip(remoteTrip);
              downloadedCount++;
            }
          } on AppException catch (e) {
            if (e is NotFoundException) {
              // Trip doesn't exist locally, create it
              await _tripLocalDataSource.createTrip(remoteTrip);
              downloadedCount++;
            }
          }
        }
      }

      final result = SyncResult.success(
        operationType: SyncOperationType.trips,
        direction: direction,
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        conflictCount: conflictCount,
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    } catch (e) {
      final result = SyncResult.failure(
        operationType: SyncOperationType.trips,
        direction: direction,
        errors: [e.toString()],
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    }
  }

  @override
  Future<SyncResult> syncTags([
    SyncDirection direction = SyncDirection.bidirectional,
    SyncConfig? config,
  ]) async {
    final effectiveConfig = config ?? SyncConfig.defaultConfig;
    final startedAt = DateTime.now();

    try {
      int uploadedCount = 0;
      int downloadedCount = 0;
      int conflictCount = 0;

      if (direction == SyncDirection.upload ||
          direction == SyncDirection.bidirectional) {
        // Upload pending tags
        final pendingTags =
            await _tagLocalDataSource.getTagsBySyncStatus('pending');

        for (final tag in pendingTags) {
          if (_isCancelled) break;

          try {
            final remoteTag = await _tagRemoteDataSource.getTag(tag.id);
            // Conflict: tag exists remotely
            conflictCount++;
            final conflict = SyncConflict(
              entityType: 'tag',
              entityId: tag.id,
              localVersion: tag.toJson(),
              remoteVersion: remoteTag.toJson(),
              localUpdatedAt: tag.createdAt,
              remoteUpdatedAt: remoteTag.createdAt,
              reason: 'Tag modified both locally and remotely',
            );

            if (effectiveConfig.autoResolveConflicts) {
              await _autoResolveConflict(conflict, effectiveConfig);
            } else {
              _notifyConflict(conflict);
            }
          } on AppException catch (e) {
            if (e is NotFoundException) {
              // Tag doesn't exist remotely, upload it
              await _tagRemoteDataSource.createTag(tag);
              await _tagLocalDataSource.updateSyncStatus(
                tag.id,
                'synced',
              );
              uploadedCount++;
            } else {
              rethrow;
            }
          }
        }
      }

      if (direction == SyncDirection.download ||
          direction == SyncDirection.bidirectional) {
        // Download remote tags
        final remoteTags = await _tagRemoteDataSource.getTags();

        for (final remoteTag in remoteTags) {
          if (_isCancelled) break;

          try {
            final localTag = await _tagLocalDataSource.getTag(remoteTag.id);

            // Check if remote is newer
            if (remoteTag.createdAt.isAfter(localTag!.createdAt)) {
              await _tagLocalDataSource.updateTag(remoteTag);
              downloadedCount++;
            }
          } on AppException catch (e) {
            if (e is NotFoundException) {
              // Tag doesn't exist locally, create it
              await _tagLocalDataSource.createTag(remoteTag);
              downloadedCount++;
            }
          }
        }
      }

      final result = SyncResult.success(
        operationType: SyncOperationType.tags,
        direction: direction,
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        conflictCount: conflictCount,
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    } catch (e) {
      final result = SyncResult.failure(
        operationType: SyncOperationType.tags,
        direction: direction,
        errors: [e.toString()],
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    }
  }

  @override
  Future<SyncResult> syncPending() async {
    const config = SyncConfig.quickConfig;
    return await syncAll(config);
  }

  @override
  Future<SyncResult> uploadChanges() async {
    const config = SyncConfig.defaultConfig;
    final startedAt = DateTime.now();

    try {
      int totalUploaded = 0;
      final allErrors = <String>[];

      final entriesResult = await syncEntries(SyncDirection.upload, config);
      totalUploaded += entriesResult.uploadedCount;
      allErrors.addAll(entriesResult.errors);

      final tripsResult = await syncTrips(SyncDirection.upload, config);
      totalUploaded += tripsResult.uploadedCount;
      allErrors.addAll(tripsResult.errors);

      final tagsResult = await syncTags(SyncDirection.upload, config);
      totalUploaded += tagsResult.uploadedCount;
      allErrors.addAll(tagsResult.errors);

      final mediaResult = await syncMedia(SyncDirection.upload, config);
      totalUploaded += mediaResult.uploadedCount;
      allErrors.addAll(mediaResult.errors);

      final result = SyncResult.success(
        operationType: SyncOperationType.full,
        direction: SyncDirection.upload,
        uploadedCount: totalUploaded,
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    } catch (e) {
      final result = SyncResult.failure(
        operationType: SyncOperationType.full,
        direction: SyncDirection.upload,
        errors: [e.toString()],
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    }
  }

  @override
  Future<SyncResult> downloadChanges() async {
    const config = SyncConfig.defaultConfig;
    final startedAt = DateTime.now();

    try {
      int totalDownloaded = 0;
      final allErrors = <String>[];

      final entriesResult = await syncEntries(SyncDirection.download, config);
      totalDownloaded += entriesResult.downloadedCount;
      allErrors.addAll(entriesResult.errors);

      final tripsResult = await syncTrips(SyncDirection.download, config);
      totalDownloaded += tripsResult.downloadedCount;
      allErrors.addAll(tripsResult.errors);

      final tagsResult = await syncTags(SyncDirection.download, config);
      totalDownloaded += tagsResult.downloadedCount;
      allErrors.addAll(tagsResult.errors);

      final mediaResult = await syncMedia(SyncDirection.download, config);
      totalDownloaded += mediaResult.downloadedCount;
      allErrors.addAll(mediaResult.errors);

      final result = SyncResult.success(
        operationType: SyncOperationType.full,
        direction: SyncDirection.download,
        downloadedCount: totalDownloaded,
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    } catch (e) {
      final result = SyncResult.failure(
        operationType: SyncOperationType.full,
        direction: SyncDirection.download,
        errors: [e.toString()],
        startedAt: startedAt,
      );

      _updateStatistics(result);

      return result;
    }
  }

  @override
  Future<void> resolveConflict(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy, {
    Map<String, dynamic>? resolvedVersion,
  }) async {
    final entity = conflict.entityType;
    final entityId = conflict.entityId;

    switch (strategy) {
      case ConflictResolutionStrategy.mostRecent:
        if (conflict.remoteUpdatedAt.isAfter(conflict.localUpdatedAt)) {
          await _applyRemoteResolution(
              entity, entityId, conflict.remoteVersion);
        } else {
          await _keepLocalVersion(entity, entityId);
        }
        break;

      case ConflictResolutionStrategy.localWins:
        await _keepLocalVersion(entity, entityId);
        break;

      case ConflictResolutionStrategy.remoteWins:
        await _applyRemoteResolution(entity, entityId, conflict.remoteVersion);
        break;

      case ConflictResolutionStrategy.manual:
        if (resolvedVersion != null) {
          await _applyManualResolution(entity, entityId, resolvedVersion);
        }
        break;
    }
  }

  @override
  Future<List<SyncConflict>> getPendingConflicts() async {
    // This would need to track conflicts in a separate table
    // For now, return empty list
    return [];
  }

  @override
  Future<void> cancelSync() async {
    _isCancelled = true;
    _isSyncing = false;
  }

  @override
  void onProgressUpdate(SyncProgressCallback callback) {
    _progressCallbacks.add(callback);
  }

  @override
  void onConflictDetected(SyncConflictCallback callback) {
    _conflictCallbacks.add(callback);
  }

  @override
  void removeProgressCallback(SyncProgressCallback callback) {
    _progressCallbacks.remove(callback);
  }

  @override
  void removeConflictCallback(SyncConflictCallback callback) {
    _conflictCallbacks.remove(callback);
  }

  @override
  SyncStatistics getStatistics() {
    return _statistics;
  }

  @override
  Future<void> clearSyncState() async {
    _statistics = const SyncStatistics(
      totalSyncs: 0,
      successfulSyncs: 0,
      failedSyncs: 0,
    );
    _lastSyncTime = null;
  }

  @override
  Future<void> initialize() async {
    // Initialize sync service
    // Could load last sync time from preferences
  }

  @override
  Future<void> dispose() async {
    await _progressController.close();
    await _conflictController.close();
  }

  // Private helper methods

  void _updateProgress(SyncProgress progress) {
    _currentProgress = progress;
    _progressController.add(progress);
    for (final callback in _progressCallbacks) {
      callback(progress);
    }
  }

  void _notifyConflict(SyncConflict conflict) {
    _conflictController.add(conflict);
    for (final callback in _conflictCallbacks) {
      callback(conflict);
    }
  }

  Future<void> _autoResolveConflict(
    SyncConflict conflict,
    SyncConfig config,
  ) async {
    await resolveConflict(
      conflict,
      config.conflictStrategy,
    );
  }

  Future<void> _applyRemoteResolution(
    String entity,
    String id,
    Map<String, dynamic> remoteVersion,
  ) async {
    switch (entity) {
      case 'journal_entry':
        final entry = JournalEntryModel.fromJson(remoteVersion);
        await _journalLocalDataSource.updateEntry(entry);
        await _journalLocalDataSource.updateSyncStatus(id, 'synced');
        break;

      case 'trip':
        final trip = TripModel.fromJson(remoteVersion);
        await _tripLocalDataSource.updateTrip(trip);
        await _tripLocalDataSource.updateSyncStatus(id, 'synced');
        break;

      case 'tag':
        final tag = TagModel.fromJson(remoteVersion);
        await _tagLocalDataSource.updateTag(tag);
        await _tagLocalDataSource.updateSyncStatus(id, 'synced');
        break;

      case 'media_item':
        final media = MediaItemModel.fromJson(remoteVersion);
        await _journalLocalDataSource.updateMedia(media);
        await _journalLocalDataSource.updateMediaSyncStatus(id, 'synced');
        break;
    }
  }

  Future<void> _keepLocalVersion(String entity, String id) async {
    switch (entity) {
      case 'journal_entry':
        final entry = await _journalLocalDataSource.getEntry(id);
        if (entry != null) {
          await _journalRemoteDataSource.updateEntry(entry);
          await _journalLocalDataSource.updateSyncStatus(id, 'synced');
        }
        break;

      case 'trip':
        final trip = await _tripLocalDataSource.getTrip(id);
        if (trip != null) {
          await _tripRemoteDataSource.updateTrip(trip);
          await _tripLocalDataSource.updateSyncStatus(id, 'synced');
        }
        break;

      case 'tag':
        final tag = await _tagLocalDataSource.getTag(id);
        if (tag != null) {
          await _tagRemoteDataSource.updateTag(tag);
          await _tagLocalDataSource.updateSyncStatus(id, 'synced');
        }
        break;

      case 'media_item':
        // Media upload logic is handled separately
        break;
    }
  }

  Future<void> _applyManualResolution(
    String entity,
    String id,
    Map<String, dynamic> resolvedVersion,
  ) async {
    await _applyRemoteResolution(entity, id, resolvedVersion);
  }

  void _updateStatistics(SyncResult result) {
    final duration = result.duration;

    _statistics = SyncStatistics(
      totalSyncs: _statistics.totalSyncs + 1,
      successfulSyncs: result.success
          ? _statistics.successfulSyncs + 1
          : _statistics.successfulSyncs,
      failedSyncs: result.success
          ? _statistics.failedSyncs
          : _statistics.failedSyncs + 1,
      totalUploaded: _statistics.totalUploaded + result.uploadedCount,
      totalDownloaded: _statistics.totalDownloaded + result.downloadedCount,
      totalConflictsResolved:
          _statistics.totalConflictsResolved + result.conflictCount,
      averageDuration: Duration(
        milliseconds: ((_statistics.averageDuration.inMilliseconds *
                    _statistics.totalSyncs) +
                duration.inMilliseconds) ~/
            (_statistics.totalSyncs + 1).clamp(1, double.infinity).toInt(),
      ),
      lastSyncTime: DateTime.now(),
      totalDataTransferred: _statistics.totalDataTransferred,
    );
  }
}
