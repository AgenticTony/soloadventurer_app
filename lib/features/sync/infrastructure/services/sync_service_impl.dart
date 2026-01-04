import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/sync_operation.dart';
import '../../domain/models/sync_status.dart';
import '../../domain/entities/sync_entity_type.dart';
import '../../domain/services/sync_service.dart';
import '../../domain/services/sync_queue_persistence.dart';
import '../../domain/services/network_connectivity.dart';

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

  /// Operation processing lock
  bool _processingLock = false;

  /// Whether persistence is enabled
  bool get _persistenceEnabled => _persistence != null;

  /// Whether network connectivity monitoring is enabled
  bool get _networkMonitoringEnabled => _networkConnectivity != null;

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
  SyncServiceImpl({
    SyncQueuePersistence? persistence,
    NetworkConnectivity? networkConnectivity,
  })  : _persistence = persistence,
        _networkConnectivity = networkConnectivity {
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

    int successCount = 0;
    int failureCount = 0;
    String? lastError;
    String? lastErrorCode;

    try {
      debugPrint('SyncService: Starting queue processing (${_queue.length} operations)');

      // Process operations in FIFO order (already sorted by priority)
      while (_queue.isNotEmpty && !_isPaused) {
        final operation = _queue.removeAt(0);

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
            if (operation.shouldRetry) {
              final retryOp = operation.copyWith(
                retryCount: operation.retryCount + 1,
              );
              _queue.add(retryOp);

              debugPrint('SyncService: Re-queueing operation ${operation.id} '
                  '(attempt ${retryOp.retryCount})');
            }
          }
        } catch (e, stackTrace) {
          failureCount++;
          lastError = e.toString();
          lastErrorCode = 'OPERATION_ERROR';

          debugPrint('SyncService: Error processing operation ${operation.id}: $e');
          debugPrint(stackTrace.toString());

          // Re-queue for retry if applicable
          if (operation.shouldRetry) {
            final retryOp = operation.copyWith(
              retryCount: operation.retryCount + 1,
            );
            _queue.add(retryOp);
          }
        }
      }

      // Determine final result
      if (failureCount > 0) {
        lastError ??= 'Some operations failed';
        lastErrorCode ??= 'PARTIAL_FAILURE';

        if (_queue.isNotEmpty) {
          _updateStatus(SyncStatus.pending);
        } else {
          _updateStatus(SyncStatus.failed);
        }

        return SyncResult.failure(
          lastError,
          code: lastErrorCode,
          successCount: successCount,
          failureCount: failureCount,
        );
      } else {
        _updateStatus(SyncStatus.success);
        return SyncResult.success(
          successCount: successCount,
          failureCount: failureCount,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('SyncService: Fatal error during queue processing: $e');
      debugPrint(stackTrace.toString());

      _updateStatus(SyncStatus.failed);

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
    final operationsToProcess =
        _queue.take(batchSize < _queue.length ? batchSize : _queue.length).toList();

    // Remove operations from queue
    _queue.removeRange(0, operationsToProcess.length);

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
            if (operation.shouldRetry) {
              final retryOp = operation.copyWith(
                retryCount: operation.retryCount + 1,
              );
              _queue.add(retryOp);
            }
          }
        } catch (e) {
          failureCount++;
          lastError = e.toString();
          lastErrorCode = 'OPERATION_ERROR';

          // Re-queue for retry if applicable
          if (operation.shouldRetry) {
            final retryOp = operation.copyWith(
              retryCount: operation.retryCount + 1,
            );
            _queue.add(retryOp);
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
}
