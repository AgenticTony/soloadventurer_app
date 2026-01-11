import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_manager.dart';
import 'package:soloadventurer/features/offline/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';
import 'package:soloadventurer/features/offline/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/upload_sync.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/download_sync.dart';

/// Implementation of [SyncManager]
///
/// This implementation coordinates the synchronization process between
/// local database and remote server. It ensures only one sync cycle runs
/// at a time and automatically triggers sync when connectivity is restored.
///
/// The sync manager follows a phased approach:
/// 1. **Upload Phase**: Sync queued local changes to server
/// 2. **Download Phase**: Pull server changes to local database
/// 3. **Conflict Resolution**: Resolve any conflicts
/// 4. **Finalization**: Complete sync and update metadata
///
/// Note: Upload and download phases will be fully implemented in
/// subsequent subtasks (5.2 and 5.3). This implementation provides
/// the coordination framework and auto-sync triggers.
class SyncManagerImpl implements SyncManager {
  /// Connectivity service for network monitoring
  final ConnectivityService _connectivityService;

  /// Sync queue service for managing pending operations
  final SyncQueueService _syncQueueService;

  /// Upload sync service for syncing operations to server
  final UploadSync _uploadSync;

  /// Download sync service for syncing server data to local database
  final DownloadSync _downloadSync;

  /// Conflict resolver for handling sync conflicts
  final ConflictResolver _conflictResolver;

  /// Function to get the current user ID
  final String Function() _getCurrentUserId;

  /// Stream controller for sync status updates
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  /// Current sync status
  SyncStatus _currentStatus = SyncStatus.idle();

  /// Whether a sync cycle is currently in progress
  bool _isSyncing = false;

  /// Whether auto-sync is currently paused
  bool _autoSyncPaused = false;

  /// Subscription to connectivity changes
  StreamSubscription? _connectivitySubscription;

  /// Subscription to queue size changes
  StreamSubscription? _queueSizeSubscription;

  /// Last sync timestamp
  DateTime? _lastSyncTime;

  /// Minimum interval between auto-syncs (default: 30 seconds)
  final Duration autoSyncMinInterval;

  /// Whether to only sync on WiFi (default: false)
  final bool syncOnlyOnWifi;

  /// Creates a new [SyncManagerImpl] instance
  ///
  /// [connectivityService] - Connectivity service for network monitoring
  /// [syncQueueService] - Sync queue service for managing operations
  /// [uploadSync] - Upload sync service for syncing to server
  /// [downloadSync] - Download sync service for syncing from server
  /// [conflictResolver] - Conflict resolver for handling sync conflicts
  /// [getCurrentUserId] - Function to get the current user ID
  /// [autoSyncMinInterval] - Minimum interval between auto-syncs (default: 30s)
  /// [syncOnlyOnWifi] - Only sync when on WiFi (default: false)
  SyncManagerImpl({
    required ConnectivityService connectivityService,
    required SyncQueueService syncQueueService,
    required UploadSync uploadSync,
    required DownloadSync downloadSync,
    required ConflictResolver conflictResolver,
    required String Function() getCurrentUserId,
    this.autoSyncMinInterval = const Duration(seconds: 30),
    this.syncOnlyOnWifi = false,
  })  : _connectivityService = connectivityService,
        _syncQueueService = syncQueueService,
        _uploadSync = uploadSync,
        _downloadSync = downloadSync,
        _conflictResolver = conflictResolver,
        _getCurrentUserId = getCurrentUserId;

  // ==============================================================================
  // SYNC STATUS STREAM
  // ==============================================================================

  @override
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

  @override
  SyncStatus get currentStatus => _currentStatus;

  // ==============================================================================
  // LIFECYCLE MANAGEMENT
  // ==============================================================================

  @override
  Future<bool> initialize() async {
    try {
      debugPrint('🔄 Initializing SyncManager...');

      // Get initial queue size
      final pendingCount = await _syncQueueService.getPendingCount();

      // Emit initial status
      _updateStatus(SyncStatus.idle(pendingOperations: pendingCount));

      // Listen to connectivity changes
      _connectivitySubscription =
          _connectivityService.connectivityStream.listen(
        (status) {
          _handleConnectivityChange(status);
        },
        onError: (error) {
          debugPrint('❌ Connectivity stream error: $error');
          _updateStatus(SyncStatus.error(
            'Connectivity monitoring error',
            pendingOperations: _currentStatus.pendingOperations,
            lastSyncTime: _lastSyncTime,
          ));
        },
      );

      // Listen to queue size changes
      _queueSizeSubscription = _syncQueueService.queueSizeStream.listen(
        (size) {
          // Update pending operations count in current status
          if (!_isSyncing) {
            _updateStatus(_currentStatus.copyWith(
              pendingOperations: size,
            ));
          }
        },
        onError: (error) {
          debugPrint('❌ Queue size stream error: $error');
        },
      );

      debugPrint('✅ SyncManager initialized successfully');

      return true;
    } catch (e) {
      debugPrint('❌ Error initializing SyncManager: $e');
      return false;
    }
  }

  @override
  void dispose() {
    debugPrint('🔄 Disposing SyncManager...');

    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    _queueSizeSubscription?.cancel();
    _queueSizeSubscription = null;

    _statusController.close();
  }

  // ==============================================================================
  // SYNC CONTROL
  // ==============================================================================

  @override
  Future<SyncResult> startSync({bool force = false}) async {
    // Prevent concurrent sync cycles
    if (_isSyncing) {
      debugPrint('⚠️ Sync already in progress, ignoring request');
      return const SyncResult.failure(
        'Sync already in progress',
        duration: Duration.zero,
      );
    }

    // Check if we should sync (unless forced)
    if (!force) {
      final pendingCount = await _syncQueueService.getPendingCount();
      if (pendingCount == 0) {
        debugPrint('📭 No pending operations, skipping sync');
        return const SyncResult.success(duration: Duration.zero);
      }

      // Check if enough time has passed since last sync
      if (_lastSyncTime != null) {
        final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
        if (timeSinceLastSync < autoSyncMinInterval) {
          final remainingTime = autoSyncMinInterval - timeSinceLastSync;
          debugPrint('⏱️ Auto-sync too soon, waiting '
              '${remainingTime.inSeconds}s');
          return const SyncResult.failure(
            'Sync cooldown active',
            duration: Duration.zero,
          );
        }
      }
    }

    final startTime = DateTime.now();
    _isSyncing = true;

    try {
      debugPrint('🚀 Starting sync cycle...');

      // Get current user ID for sync operations
      final userId = _getCurrentUserId();
      if (userId.isEmpty) {
        debugPrint('⚠️ No user authenticated, skipping sync');
        _isSyncing = false;
        return const SyncResult.failure(
          'No authenticated user',
          duration: Duration.zero,
        );
      }

      // Update status to syncing
      _updateStatus(SyncStatus.syncing(
        phase: SyncPhase.upload,
        progress: 0.0,
        currentOperation: 'Starting sync...',
        pendingOperations: _currentStatus.pendingOperations,
      ));

      // ========================================================================
      // PHASE 1: UPLOAD - Sync local changes to server
      // ========================================================================
      debugPrint('📤 Phase 1: Upload - Syncing local changes to server...');

      _updateStatus(SyncStatus.syncing(
        phase: SyncPhase.upload,
        progress: 0.1,
        currentOperation: 'Uploading local changes...',
        pendingOperations: _currentStatus.pendingOperations,
      ));

      int uploadedCount = 0;
      int conflictsResolved = 0;

      // Process pending operations through UploadSync
      final uploadResult = await _processPendingOperations();
      uploadedCount = uploadResult;

      if (uploadResult < 0) {
        // Error during upload
        throw Exception('Upload phase failed');
      }

      debugPrint('✅ Upload phase complete: $uploadedCount operations');

      _updateStatus(SyncStatus.syncing(
        phase: SyncPhase.upload,
        progress: 0.5,
        currentOperation: 'Upload complete',
        pendingOperations: _currentStatus.pendingOperations,
      ));

      // ========================================================================
      // PHASE 2: DOWNLOAD - Pull server changes to local
      // ========================================================================
      debugPrint('📥 Phase 2: Download - Pulling server changes...');

      _updateStatus(SyncStatus.syncing(
        phase: SyncPhase.download,
        progress: 0.6,
        currentOperation: 'Downloading server changes...',
        pendingOperations: _currentStatus.pendingOperations,
      ));

      int downloadedCount = 0;
      int insertedCount = 0;
      int updatedCount = 0;

      // Download server changes using DownloadSync service
      final downloadResult = await _downloadSync.syncServerChanges(
        userId: userId,
        onProgress: (current, total) {
          // Update progress in sync status
          final progress = 0.5 + (current / total * 0.3); // 50% to 80%
          _updateStatus(SyncStatus.syncing(
            phase: SyncPhase.download,
            progress: progress,
            currentOperation: 'Downloading entity type $current of $total...',
            pendingOperations: _currentStatus.pendingOperations,
          ));
        },
      );

      downloadedCount = downloadResult.downloadCount;
      insertedCount = downloadResult.insertCount;
      updatedCount = downloadResult.updateCount;

      debugPrint('✅ Download phase complete: '
          '$downloadedCount changes '
          '($insertedCount inserted, $updatedCount updated)');

      _updateStatus(SyncStatus.syncing(
        phase: SyncPhase.download,
        progress: 0.8,
        currentOperation: 'Download complete',
        pendingOperations: _currentStatus.pendingOperations,
      ));

      // ========================================================================
      // PHASE 3: CONFLICT RESOLUTION - Resolve conflicts
      // ========================================================================
      debugPrint('⚔️ Phase 3: Conflict Resolution...');

      _updateStatus(SyncStatus.syncing(
        phase: SyncPhase.conflictResolution,
        progress: 0.9,
        currentOperation: 'Resolving conflicts...',
        pendingOperations: _currentStatus.pendingOperations,
      ));

      // Resolve all conflicts automatically using default strategies
      final resolutionResult = await _conflictResolver.resolveAllConflicts();
      conflictsResolved = resolutionResult.resolvedCount;

      debugPrint('✅ Conflict resolution complete: '
          '$conflictsResolved resolved, '
          '${resolutionResult.manualResolutionRequired} require manual action');

      // Emit a warning if manual resolution is required
      if (resolutionResult.manualResolutionRequired > 0) {
        debugPrint('⚠️ Warning: ${resolutionResult.manualResolutionRequired} '
            'conflicts require manual resolution');
      }

      // ========================================================================
      // PHASE 4: FINALIZATION - Complete sync
      // ========================================================================
      debugPrint('🏁 Phase 4: Finalization...');

      _updateStatus(SyncStatus.syncing(
        phase: SyncPhase.finalization,
        progress: 0.95,
        currentOperation: 'Finalizing sync...',
        pendingOperations: _currentStatus.pendingOperations,
      ));

      // Update last sync time
      _lastSyncTime = DateTime.now();

      // Get updated pending count
      final pendingCount = await _syncQueueService.getPendingCount();

      final duration = DateTime.now().difference(startTime);

      debugPrint('✅ Sync cycle complete in ${duration.inSeconds}s');
      debugPrint('📊 Summary: '
          'uploaded: $uploadedCount, '
          'downloaded: $downloadedCount '
          '($insertedCount inserted, $updatedCount updated), '
          'conflicts: $conflictsResolved');

      // Update status to idle
      _updateStatus(SyncStatus.idle(
        pendingOperations: pendingCount,
      ));

      return SyncResult.success(
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        conflictsResolved: conflictsResolved,
        duration: duration,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Sync failed: $e');
      debugPrint('Stack trace: $stackTrace');

      final duration = DateTime.now().difference(startTime);

      // Update status to error
      _updateStatus(SyncStatus.error(
        'Sync failed: $e',
        pendingOperations: _currentStatus.pendingOperations,
        lastSyncTime: _lastSyncTime,
      ));

      return SyncResult.failure(
        e.toString(),
        duration: duration,
      );
    } finally {
      _isSyncing = false;
    }
  }

  @override
  Future<bool> stopSync() async {
    if (!_isSyncing) {
      debugPrint('⚠️ No sync in progress to stop');
      return false;
    }

    debugPrint('🛑 Stopping sync cycle...');

    // Note: We can't immediately stop in-progress operations
    // but we can set a flag to prevent new operations from starting
    // For now, we'll just mark that sync should stop
    // In a full implementation, we'd have a cancellation token

    _isSyncing = false;

    _updateStatus(SyncStatus.idle(
      pendingOperations: _currentStatus.pendingOperations,
    ));

    debugPrint('✅ Sync stopped');

    return true;
  }

  @override
  void pauseAutoSync() {
    debugPrint('⏸️ Pausing auto-sync');
    _autoSyncPaused = true;
  }

  @override
  void resumeAutoSync() {
    debugPrint('▶️ Resuming auto-sync');
    _autoSyncPaused = false;

    // Trigger sync if we have pending operations
    _syncQueueService.getPendingCount().then((count) {
      if (count > 0) {
        _connectivityService.checkConnectivity().then((status) {
          if (status.isConnected) {
            debugPrint('🔄 Triggering sync after resume');
            startSync();
          }
        });
      }
    });
  }

  // ==============================================================================
  // PRIVATE METHODS - HANDLERS
  // ==============================================================================

  /// Handles connectivity changes
  void _handleConnectivityChange(ConnectivityStatus status) {
    debugPrint('🌐 Connectivity changed: ${status.connectionType} '
        '(connected: ${status.isConnected})');

    // Trigger sync when connection is restored
    if (status.isConnected && !_autoSyncPaused && !_isSyncing) {
      // Check WiFi-only preference
      if (syncOnlyOnWifi && status.connectionType != ConnectionType.wifi) {
        debugPrint('⚠️ WiFi-only mode, skipping sync on cellular');
        _updateStatus(SyncStatus.paused(
          pendingOperations: _currentStatus.pendingOperations,
        ));
        return;
      }

      // Check if we have pending operations
      _syncQueueService.getPendingCount().then((count) {
        if (count > 0) {
          // Check cooldown
          if (_lastSyncTime != null) {
            final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
            if (timeSinceLastSync < autoSyncMinInterval) {
              debugPrint('⏱️ Auto-sync cooldown active');
              return;
            }
          }

          debugPrint('🔄 Connection restored, triggering auto-sync...');
          startSync();
        } else {
          debugPrint('📭 No pending operations to sync');
        }
      });
    } else if (!status.isConnected && _isSyncing) {
      // Handle connection loss during sync
      debugPrint('⚠️ Connection lost during sync');
      _updateStatus(SyncStatus.paused(
        pendingOperations: _currentStatus.pendingOperations,
      ));
    }
  }

  // ==============================================================================
  // PRIVATE METHODS - SYNC PHASES
  // ==============================================================================

  /// Processes pending operations in the sync queue
  ///
  /// Uses the UploadSync service to sync queued operations to the server.
  ///
  /// Returns the number of successfully processed operations,
  /// or -1 if an error occurred.
  Future<int> _processPendingOperations() async {
    try {
      debugPrint('📤 Processing pending operations with UploadSync...');

      final result = await _uploadSync.processPendingOperations(
        limit: 10,
        onProgress: (current, total) {
          // Update progress in sync status
          final progress = 0.1 + (current / total * 0.4); // 10% to 50%
          _updateStatus(SyncStatus.syncing(
            phase: SyncPhase.upload,
            progress: progress,
            currentOperation: 'Uploading $current of $total operations...',
            pendingOperations: _currentStatus.pendingOperations,
          ));
        },
      );

      if (result.isSuccessful) {
        debugPrint('✅ Upload complete: ${result.successCount} operations');
        return result.successCount;
      } else {
        debugPrint('⚠️ Upload partial: ${result.successCount} succeeded, '
            '${result.failureCount} failed');
        // Return success count even if some failed
        // Failed operations will be retried later
        return result.successCount;
      }
    } catch (e) {
      debugPrint('❌ Error processing operations: $e');
      return -1;
    }
  }

  // ==============================================================================
  // PRIVATE METHODS - UTILITIES
  // ==============================================================================

  /// Updates the current sync status and emits it
  void _updateStatus(SyncStatus newStatus) {
    _currentStatus = newStatus;

    if (!_statusController.isClosed) {
      _statusController.add(newStatus);
    }

    debugPrint('📊 Sync status: $newStatus');
  }
}
