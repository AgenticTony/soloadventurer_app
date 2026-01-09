import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/sync_operation.dart';
import '../../domain/models/sync_status.dart';
import '../../domain/models/sync_error.dart';
import '../../domain/entities/sync_entity_type.dart';
import '../../domain/services/sync_service.dart';
import '../../domain/services/sync_queue_persistence.dart';
import '../../domain/services/network_connectivity.dart';
import '../../domain/services/exponential_backoff.dart';
import '../../domain/services/sync_history_service.dart';
import '../../domain/models/sync_history_entry.dart';

/// Implementation of [SyncService] with queue management and persistence
class SyncServiceImpl implements SyncService {
  /// Internal queue storage (FIFO)
  final List<SyncOperation> _queue = [];

  /// Stream controllers for state updates
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  final StreamController<List<SyncOperation>> _queueController =
      StreamController<List<SyncOperation>>.broadcast();

  /// Queue persistence service
  final SyncQueuePersistence? _persistence;

  /// Network connectivity monitoring service
  final NetworkConnectivity? _networkConnectivity;

  /// Sync history service for logging operations
  final SyncHistoryService? _historyService;

  /// Subscription to network online events
  StreamSubscription<bool>? _networkOnlineSubscription;

  /// Current sync status
  SyncStatus _status = SyncStatus.idle;

  /// Whether processing is currently paused
  bool _isPaused = false;

  /// Whether queue is currently being processed
  bool _isProcessing = false;

  /// Queue configuration
  SyncQueueConfig _config = SyncQueueConfig.defaultConfig;

  /// Exponential backoff calculator for retry delays
  final ExponentialBackoff _backoff;

  /// Operation processing lock
  bool _processingLock = false;

  /// Current history entry ID for the active sync operation
  String? _currentHistoryEntryId;

  /// Whether this is a manual sync operation
  bool _isManualSync = false;

  /// Whether persistence is enabled
  bool get _persistenceEnabled => _persistence != null;

  /// Whether network connectivity monitoring is enabled
  bool get _networkMonitoringEnabled => _networkConnectivity != null;

  /// Whether history logging is enabled
  bool get _historyEnabled => _historyService != null;

  @override
  List<SyncOperation> get queue => List.unmodifiable(_queue);

  @override
  int get queueSize => _queue.length;

  @override
  bool get isProcessing => _isProcessing;

  @override
  SyncStatus get status => _status;

  @override
  Stream<SyncStatus> get statusStream => _statusController.stream;

  @override
  Stream<List<SyncOperation>> get queueStream => _queueController.stream;

  @override
  SyncQueueConfig get config => _config;

  /// Creates a new [SyncServiceImpl] instance
  ///
  /// If [persistence] is provided, the queue will be persisted across app restarts
  /// If [networkConnectivity] is provided, sync will automatically trigger when
  /// connection is restored
  /// If [backoff] is provided, it will be used for retry delay calculation
  /// If [historyService] is provided, sync operations will be logged to history
  SyncServiceImpl({
    SyncQueuePersistence? persistence,
    NetworkConnectivity? networkConnectivity,
    ExponentialBackoff? backoff,
    SyncHistoryService? historyService,
  })  : _persistence = persistence,
        _networkConnectivity = networkConnectivity,
        _historyService = historyService,
        _backoff = backoff ?? ExponentialBackoff.standard {
    _initializeFromPersistence();
    _initializeNetworkMonitoring();
  }

  /// Initialize the service by loading persisted queue
  Future<void> _initializeFromPersistence() async {
    if (!_persistenceEnabled) return;

    try {
      debugPrint('SyncService: Loading queue from persistence...');
      final persistedQueue = await _persistence!.loadQueue();

      if (persistedQueue.isNotEmpty) {
        _queue.addAll(persistedQueue);

        // Sort queue by priority (descending) then by creation time (ascending)
        _queue.sort((a, b) {
          final priorityDiff = b.priority.compareTo(a.priority);
          if (priorityDiff != 0) return priorityDiff;
          return a.createdAt.compareTo(b.createdAt);
        });

        _notifyQueueChanged();
        _updateStatus(SyncStatus.pending);

        debugPrint('SyncService: Loaded ${_queue.length} operations from persistence');

        // Auto-process if enabled
        if (_config.autoProcess && !_isPaused) {
          _scheduleProcessing();
        }
      } else {
        debugPrint('SyncService: No persisted operations found');
      }
    } catch (e, stackTrace) {
      debugPrint('SyncService: Error loading from persistence: $e');
      debugPrint(stackTrace.toString());
    }
  }

  /// Initialize network connectivity monitoring
  void _initializeNetworkMonitoring() {
    if (!_networkMonitoringEnabled) return;

    try {
      // Subscribe to online events to trigger sync when connection is restored
      _networkOnlineSubscription = _networkConnectivity!.onOnline.listen(
        (_) {
          debugPrint('SyncService: Network connection restored');
          // Trigger sync processing when coming back online
          if (_queue.isNotEmpty && !_isPaused && _config.autoProcess) {
            debugPrint('SyncService: Auto-triggering sync due to connection restoration');
            _scheduleProcessing();
          }
        },
        onError: (error, stackTrace) {
          debugPrint('SyncService: Error in network monitoring stream: $error');
          debugPrint(stackTrace.toString());
        },
      );

      debugPrint('SyncService: Network connectivity monitoring initialized');
    } catch (e, stackTrace) {
      debugPrint('SyncService: Error initializing network monitoring: $e');
      debugPrint(stackTrace.toString());
    }
  }

  @override
  Future<bool> enqueueOperation(SyncOperation operation) async {
    // Validate queue size
    if (_queue.length >= _config.maxQueueSize) {
      debugPrint('SyncService: Queue is full, rejecting operation');
      return false;
    }

    // Check for duplicate operations
    if (_queue.any((op) => op.id == operation.id)) {
      debugPrint('SyncService: Operation ${operation.id} already in queue');
      return false;
    }

    // Add to queue
    _queue.add(operation);

    // Sort queue by priority (descending) then by creation time (ascending)
    _queue.sort((a, b) {
      final priorityDiff = b.priority.compareTo(a.priority);
      if (priorityDiff != 0) return priorityDiff;
      return a.createdAt.compareTo(b.createdAt);
    });

    // Persist the updated queue
    await _persistQueue();

    // Notify listeners
    _notifyQueueChanged();

    // Update status to pending if queue was empty
    if (_status == SyncStatus.idle) {
      _updateStatus(SyncStatus.pending);
    }

    // Auto-process if enabled
    if (_config.autoProcess && !_isPaused) {
      _scheduleProcessing();
    }

    debugPrint('SyncService: Enqueued operation ${operation.id} '
        '(type: ${operation.entityType}, queue size: ${_queue.length})');

    return true;
  }

  @override
  Future<int> enqueueOperations(List<SyncOperation> operations) async {
    if (operations.isEmpty) return 0;

    int added = 0;

    for (final operation in operations) {
      if (await enqueueOperation(operation)) {
        added++;
      }
    }

    debugPrint('SyncService: Enqueued $added/${operations.length} operations');

    return added;
  }

  @override
  Future<bool> removeOperation(String operationId) async {
    final initialLength = _queue.length;
    _queue.removeWhere((op) => op.id == operationId);

    if (_queue.length < initialLength) {
      // Persist the updated queue
      await _persistQueue();

      _notifyQueueChanged();
      debugPrint('SyncService: Removed operation $operationId');
      return true;
    }

    return false;
  }

  @override
  Future<void> clearQueue() async {
    final count = _queue.length;
    _queue.clear();

    // Clear persisted queue
    if (_persistenceEnabled) {
      try {
        await _persistence!.clearQueue();
      } catch (e) {
        debugPrint('SyncService: Error clearing persisted queue: $e');
      }
    }

    _notifyQueueChanged();

    if (_status == SyncStatus.pending) {
      _updateStatus(SyncStatus.idle);
    }

    debugPrint('SyncService: Cleared $count operations from queue');
  }

  @override
  Future<SyncResult> processQueue() async {
    if (_isPaused) {
      debugPrint('SyncService: Processing is paused');
      return SyncResult.failure(
        'Processing is paused',
        code: 'PAUSED',
      );
    }

    if (_processingLock) {
      debugPrint('SyncService: Already processing queue');
      return SyncResult.failure(
        'Queue processing already in progress',
        code: 'ALREADY_PROCESSING',
      );
    }

    if (_queue.isEmpty) {
      debugPrint('SyncService: Queue is empty');
      _updateStatus(SyncStatus.idle);
      return SyncResult.success();
    }

    _processingLock = true;
    _isProcessing = true;
    _updateStatus(SyncStatus.syncing);

    // Create history entry for this sync operation
    final entryId = 'sync_${DateTime.now().millisecondsSinceEpoch}';
    _currentHistoryEntryId = entryId;

    if (_historyEnabled) {
      final connectionType = await _getCurrentConnectionType();
      final entry = SyncHistoryEntry.start(
        id: entryId,
        isManual: _isManualSync,
        connectionType: connectionType,
      );
      await _historyService!.addEntry(entry);
      debugPrint('SyncService: Created history entry $entryId');
    }

    int successCount = 0;
    int failureCount = 0;
    String? lastError;
    String? lastErrorCode;

    try {
      debugPrint('SyncService: Starting queue processing (${_queue.length} operations)');

      // Process operations in FIFO order (already sorted by priority)
      while (_queue.isNotEmpty && !_isPaused) {
        final operation = _queue.removeAt(0);
        // Skip operations that aren't ready for retry yet
        if (!operation.isReadyForRetry) {
          // Put it back in the queue
          _queue.insert(0, operation);

          debugPrint('SyncService: Operation ${operation.id} not ready for retry yet, '
              'will retry at ${operation.nextRetryAt?.toIso8601String()}');

          // Calculate delay until next retry and schedule processing
          final delayUntilRetry = operation.timeUntilRetry;
          if (delayUntilRetry != null) {
            Future.delayed(delayUntilRetry, () {
              if (!_isPaused && _queue.isNotEmpty) {
                _scheduleProcessing();
              }
            });
          }

          // Break out of the loop for now
          break;
        }

        // Persist the updated queue after removal
        await _persistQueue();

        _notifyQueueChanged();

        try {
          final result = await _processSingleOperation(operation);

          if (result) {
            successCount++;
          } else {
            failureCount++;

            // Re-queue for retry if applicable
            if (operation.shouldRetry(_config.maxRetryAttempts)) {
              final nextRetryCount = operation.retryCount + 1;
              final nextRetryAt = _backoff.calculateNextRetryTime(nextRetryCount);

              final retryOp = operation.copyWith(
                retryCount: nextRetryCount,
                nextRetryAt: nextRetryAt,
              );
              _queue.add(retryOp);

              debugPrint('SyncService: Re-queueing operation ${operation.id} '
                  '(attempt $nextRetryCount, next retry at ${nextRetryAt.toIso8601String()})');
            } else {
              debugPrint('SyncService: Operation ${operation.id} exceeded max retry attempts '
                  '(${operation.retryCount}/${_config.maxRetryAttempts})');
            }
          }
        } catch (e, stackTrace) {
          failureCount++;
          lastError = e.toString();
          lastErrorCode = 'OPERATION_ERROR';

          debugPrint('SyncService: Error processing operation ${operation.id}: $e');
          debugPrint(stackTrace.toString());

          // Re-queue for retry if applicable
          if (operation.shouldRetry(_config.maxRetryAttempts)) {
            final nextRetryCount = operation.retryCount + 1;
            final nextRetryAt = _backoff.calculateNextRetryTime(nextRetryCount);

            final retryOp = operation.copyWith(
              retryCount: nextRetryCount,
              nextRetryAt: nextRetryAt,
            );
            _queue.add(retryOp);

            debugPrint('SyncService: Re-queueing operation ${operation.id} '
                '(attempt $nextRetryCount, next retry at ${nextRetryAt.toIso8601String()})');
          } else {
            debugPrint('SyncService: Operation ${operation.id} exceeded max retry attempts '
                '(${operation.retryCount}/${_config.maxRetryAttempts})');
          }
        }
      }

      // Determine final result
      final totalCount = successCount + failureCount;
      if (failureCount > 0) {
        lastError ??= 'Some operations failed';
        lastErrorCode ??= 'PARTIAL_FAILURE';

        if (_queue.isNotEmpty) {
          _updateStatus(SyncStatus.pending);
        } else {
          _updateStatus(SyncStatus.failed);
        }

        // Complete history entry
        await _completeHistoryEntry(
          isSuccess: false,
          successCount: successCount,
          failureCount: failureCount,
          totalCount: totalCount,
          error: lastError,
        );

        return SyncResult.failure(
          lastError,
          code: lastErrorCode,
          successCount: successCount,
          failureCount: failureCount,
        );
      } else {
        _updateStatus(SyncStatus.success);

        // Complete history entry
        await _completeHistoryEntry(
          isSuccess: true,
          successCount: successCount,
          failureCount: failureCount,
          totalCount: totalCount,
        );

        return SyncResult.success(
          successCount: successCount,
          failureCount: failureCount,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('SyncService: Fatal error during queue processing: $e');
      debugPrint(stackTrace.toString());

      _updateStatus(SyncStatus.failed);

      final totalCount = successCount + failureCount;

      // Complete history entry
      await _completeHistoryEntry(
        isSuccess: false,
        successCount: successCount,
        failureCount: failureCount,
        totalCount: totalCount,
        error: 'Queue processing failed: ${e.toString()}',
      );

      return SyncResult.failure(
        'Queue processing failed: ${e.toString()}',
        code: 'PROCESSING_ERROR',
        successCount: successCount,
        failureCount: failureCount,
      );
    } finally {
      _processingLock = false;
      _isProcessing = false;

      debugPrint('SyncService: Queue processing completed '
          '(success: $successCount, failed: $failureCount, remaining: ${_queue.length})');
    }
  }

  @override
  Future<SyncResult> processBatch({int? maxBatchSize}) async {
    if (_isPaused) {
      return SyncResult.failure(
        'Processing is paused',
        code: 'PAUSED',
      );
    }

    if (_processingLock) {
      return SyncResult.failure(
        'Queue processing already in progress',
        code: 'ALREADY_PROCESSING',
      );
    }

    if (_queue.isEmpty) {
      _updateStatus(SyncStatus.idle);
      return SyncResult.success();
    }

    _processingLock = true;
    _isProcessing = true;
    _updateStatus(SyncStatus.syncing);

    final batchSize = maxBatchSize ?? _config.maxBatchSize;

    // Filter and collect operations ready for processing
    final operationsToProcess = <SyncOperation>[];
    final operationsNotReady = <SyncOperation>[];
    var collected = 0;

    for (final operation in _queue) {
      if (collected >= batchSize) break;

      if (operation.isReadyForRetry) {
        operationsToProcess.add(operation);
        collected++;
      } else {
        operationsNotReady.add(operation);
      }
    }

    // Remove processed operations from queue
    _queue.removeWhere((op) => operationsToProcess.contains(op));

    // Put back operations that aren't ready
    _queue.insertAll(0, operationsNotReady);

    // Persist the updated queue
    await _persistQueue();

    _notifyQueueChanged();

    int successCount = 0;
    int failureCount = 0;
    String? lastError;
    String? lastErrorCode;

    try {
      debugPrint('SyncService: Processing batch of ${operationsToProcess.length} operations');

      for (final operation in operationsToProcess) {
        try {
          final result = await _processSingleOperation(operation);

          if (result) {
            successCount++;
          } else {
            failureCount++;

            // Re-queue for retry if applicable
            if (operation.shouldRetry(_config.maxRetryAttempts)) {
              final nextRetryCount = operation.retryCount + 1;
              final nextRetryAt = _backoff.calculateNextRetryTime(nextRetryCount);

              final retryOp = operation.copyWith(
                retryCount: nextRetryCount,
                nextRetryAt: nextRetryAt,
              );
              _queue.add(retryOp);

              debugPrint('SyncService: Re-queueing operation ${operation.id} '
                  '(attempt $nextRetryCount, next retry at ${nextRetryAt.toIso8601String()})');
            } else {
              debugPrint('SyncService: Operation ${operation.id} exceeded max retry attempts '
                  '(${operation.retryCount}/${_config.maxRetryAttempts})');
            }
          }
        } catch (e) {
          failureCount++;
          lastError = e.toString();
          lastErrorCode = 'OPERATION_ERROR';

          // Re-queue for retry if applicable
          if (operation.shouldRetry(_config.maxRetryAttempts)) {
            final nextRetryCount = operation.retryCount + 1;
            final nextRetryAt = _backoff.calculateNextRetryTime(nextRetryCount);

            final retryOp = operation.copyWith(
              retryCount: nextRetryCount,
              nextRetryAt: nextRetryAt,
            );
            _queue.add(retryOp);

            debugPrint('SyncService: Re-queueing operation ${operation.id} '
                '(attempt $nextRetryCount, next retry at ${nextRetryAt.toIso8601String()})');
          } else {
            debugPrint('SyncService: Operation ${operation.id} exceeded max retry attempts '
                '(${operation.retryCount}/${_config.maxRetryAttempts})');
          }
        }
      }

      // Re-sort queue after re-queueing retries
      _queue.sort((a, b) {
        final priorityDiff = b.priority.compareTo(a.priority);
        if (priorityDiff != 0) return priorityDiff;
        return a.createdAt.compareTo(b.createdAt);
      });

      // Persist the updated queue with re-queued operations
      await _persistQueue();

      _notifyQueueChanged();

      // Determine final result
      if (failureCount > 0) {
        lastError ??= 'Some operations failed';
        lastErrorCode ??= 'PARTIAL_FAILURE';

        _updateStatus(_queue.isEmpty ? SyncStatus.failed : SyncStatus.pending);

        return SyncResult.failure(
          lastError,
          code: lastErrorCode,
          successCount: successCount,
          failureCount: failureCount,
        );
      } else {
        _updateStatus(_queue.isEmpty ? SyncStatus.success : SyncStatus.pending);
        return SyncResult.success(
          successCount: successCount,
          failureCount: failureCount,
        );
      }
    } catch (e) {
      _updateStatus(SyncStatus.failed);

      return SyncResult.failure(
        'Batch processing failed: ${e.toString()}',
        code: 'PROCESSING_ERROR',
        successCount: successCount,
        failureCount: failureCount,
      );
    } finally {
      _processingLock = false;
      _isProcessing = false;

      debugPrint('SyncService: Batch processing completed '
          '(success: $successCount, failed: $failureCount)');
    }
  }

  @override
  Future<int> retryFailedOperations() async {
    final failedOps = _queue.where((op) => op.retryCount > 0).toList();
    final retryCount = failedOps.length;

    debugPrint('SyncService: Re-queueing $retryCount failed operations');

    // Reset retry count to allow retry
    for (final op in failedOps) {
      final index = _queue.indexWhere((o) => o.id == op.id);
      if (index != -1) {
        _queue[index] = op.copyWith(retryCount: 0);
      }
    }

    // Persist the updated queue
    await _persistQueue();

    // Trigger processing if not paused
    if (!_isPaused && _config.autoProcess) {
      _scheduleProcessing();
    }

    return retryCount;
  }

  @override
  List<SyncOperation> getOperationsByType(SyncEntityType entityType) {
    return _queue.where((op) => op.entityType == entityType).toList();
  }

  @override
  List<SyncOperation> getOperationsByOperationType(
      SyncOperationType operationType) {
    return _queue.where((op) => op.operationType == operationType).toList();
  }

  @override
  List<SyncOperation> getOperationsForEntity(String entityId) {
    return _queue.where((op) => op.entityId == entityId).toList();
  }

  @override
  void pauseProcessing() {
    _isPaused = true;
    debugPrint('SyncService: Processing paused');
  }

  @override
  void resumeProcessing() {
    _isPaused = false;
    debugPrint('SyncService: Processing resumed');

    if (_queue.isNotEmpty && _config.autoProcess) {
      _scheduleProcessing();
    }
  }

  @override
  void updateConfig(SyncQueueConfig config) {
    _config = config;
    debugPrint('SyncService: Configuration updated');
  }

  @override
  void dispose() {
    _networkOnlineSubscription?.cancel();
    _networkOnlineSubscription = null;
    _statusController.close();
    _queueController.close();
    debugPrint('SyncService: Disposed');
  }

  /// Persist the current queue state
  Future<void> _persistQueue() async {
    if (!_persistenceEnabled) return;

    try {
      final result = await _persistence!.saveQueue(_queue);
      if (!result.success) {
        debugPrint('SyncService: Failed to persist queue: ${result.error}');
      }
    } catch (e) {
      debugPrint('SyncService: Error persisting queue: $e');
    }
  }

  /// Process a single operation (mock implementation)
  ///
  /// In a real implementation, this would:
  /// 1. Validate the operation data
  /// 2. Make API calls to sync with backend
  /// 3. Handle conflicts if detected
  /// 4. Update local storage on success
  Future<bool> _processSingleOperation(SyncOperation operation) async {
    debugPrint('SyncService: Processing operation ${operation.id} '
        '(${operation.operationType.name} ${operation.entityType.name})');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Mock success (in real implementation, this would make API calls)
    // Simulate occasional failures for testing
    final shouldFail = operation.retryCount == 0 && false; // Set to true to test failures

    if (shouldFail) {
      debugPrint('SyncService: Operation ${operation.id} failed (simulated)');
      return false;
    }

    debugPrint('SyncService: Operation ${operation.id} succeeded');
    return true;
  }

  /// Update sync status and notify listeners
  void _updateStatus(SyncStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(_status);
      debugPrint('SyncService: Status changed to ${_status.name}');
    }
  }

  /// Notify listeners that queue has changed
  void _notifyQueueChanged() {
    _queueController.add(List.unmodifiable(_queue));
  }

  /// Schedule processing with delay
  void _scheduleProcessing() {
    Future.delayed(Duration(milliseconds: _config.retryDelayMs), () {
      if (!_isPaused && !_isProcessing && _queue.isNotEmpty) {
        processBatch();
      }
    });
  }

  /// Get current network connection type for history logging
  Future<String?> _getCurrentConnectionType() async {
    if (!_networkMonitoringEnabled) return null;

    try {
      final connection = await _networkConnectivity!.currentConnection;
      return connection?.type.name;
    } catch (e) {
      debugPrint('SyncService: Error getting connection type: $e');
      return null;
    }
  }

  /// Complete history entry when sync finishes
  Future<void> _completeHistoryEntry({
    required bool isSuccess,
    required int successCount,
    required int failureCount,
    required int totalCount,
    String? error,
  }) async {
    if (!_historyEnabled || _currentHistoryEntryId == null) return;

    try {
      final connectionType = await _getCurrentConnectionType();
      SyncHistoryEntry updatedEntry;

      if (isSuccess) {
        updatedEntry = SyncHistoryEntry.success(
          id: _currentHistoryEntryId!,
          startedAt: DateTime.now(), // Will be updated when we add startedAt tracking
          successCount: successCount,
          failureCount: failureCount,
          totalCount: totalCount,
          isManual: _isManualSync,
          connectionType: connectionType,
        );
      } else {
        // Import SyncError here to avoid circular dependency
        // For now, create a basic error
        final syncError = error != null
            ? SyncError(
                errorId: 'error_${DateTime.now().millisecondsSinceEpoch}',
                type: SyncErrorType.unknown,
                severity: SyncErrorSeverity.medium,
                technicalMessage: error,
                userMessage: error,
                occurredAt: DateTime.now(),
              )
            : null;

        updatedEntry = SyncHistoryEntry.failure(
          id: _currentHistoryEntryId!,
          startedAt: DateTime.now(), // Will be updated when we add startedAt tracking
          successCount: successCount,
          failureCount: failureCount,
          totalCount: totalCount,
          error: syncError!,
          isManual: _isManualSync,
          connectionType: connectionType,
        );
      }

      await _historyService!.updateEntry(_currentHistoryEntryId!, updatedEntry);
      debugPrint('SyncService: Updated history entry $_currentHistoryEntryId');
    } catch (e) {
      debugPrint('SyncService: Error updating history entry: $e');
    } finally {
      _currentHistoryEntryId = null;
    }
  }
}
