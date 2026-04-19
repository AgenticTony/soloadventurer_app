import 'dart:async';
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
  final StreamController<SyncOperationStatus> _statusController =
      StreamController<SyncOperationStatus>.broadcast();
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
  SyncOperationStatus _status = SyncOperationStatus.idle;

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
  final bool _isManualSync = false;

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
  SyncOperationStatus get status => _status;

  @override
  Stream<SyncOperationStatus> get statusStream => _statusController.stream;

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
        _updateStatus(SyncOperationStatus.pending);

        // Auto-process if enabled
        if (_config.autoProcess && !_isPaused) {
          _scheduleProcessing();
        }
      } else {
      }
    } catch (e) {
    // intentional silent catch
    }
  }

  /// Initialize network connectivity monitoring
  void _initializeNetworkMonitoring() {
    if (!_networkMonitoringEnabled) return;

    try {
      // Subscribe to online events to trigger sync when connection is restored
      _networkOnlineSubscription = _networkConnectivity!.onOnline.listen(
        (_) {
          // Trigger sync processing when coming back online
          if (_queue.isNotEmpty && !_isPaused && _config.autoProcess) {
            _scheduleProcessing();
          }
        },
        onError: (error, stackTrace) {
        },
      );

    } catch (e) {
    // intentional silent catch
    }
  }

  @override
  Future<bool> enqueueOperation(SyncOperation operation) async {
    // Validate queue size
    if (_queue.length >= _config.maxQueueSize) {
      return false;
    }

    // Check for duplicate operations
    if (_queue.any((op) => op.id == operation.id)) {
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
    if (_status == SyncOperationStatus.idle) {
      _updateStatus(SyncOperationStatus.pending);
    }

    // Auto-process if enabled
    if (_config.autoProcess && !_isPaused) {
      _scheduleProcessing();
    }

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
      return true;
    }

    return false;
  }

  @override
  Future<void> clearQueue() async {
    _queue.length;
    _queue.clear();

    // Clear persisted queue
    if (_persistenceEnabled) {
      try {
        await _persistence!.clearQueue();
      } catch (e) {
      // intentional silent catch
      }
    }

    _notifyQueueChanged();

    if (_status == SyncOperationStatus.pending) {
      _updateStatus(SyncOperationStatus.idle);
    }

  }

  @override
  Future<SyncResult> processQueue() async {
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
      _updateStatus(SyncOperationStatus.idle);
      return SyncResult.success();
    }

    _processingLock = true;
    _isProcessing = true;
    _updateStatus(SyncOperationStatus.syncing);

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
    }

    int successCount = 0;
    int failureCount = 0;
    String? lastError;
    String? lastErrorCode;

    try {

      // Process operations in FIFO order (already sorted by priority)
      while (_queue.isNotEmpty && !_isPaused) {
        final operation = _queue.removeAt(0);
        // Skip operations that aren't ready for retry yet
        if (!operation.isReadyForRetry) {
          // Put it back in the queue
          _queue.insert(0, operation);

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
              final nextRetryAt =
                  _backoff.calculateNextRetryTime(nextRetryCount);

              final retryOp = operation.copyWith(
                retryCount: nextRetryCount,
                nextRetryAt: nextRetryAt,
              );
              _queue.add(retryOp);

            } else {
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

          } else {
          }
        }
      }

      // Determine final result
      final totalCount = successCount + failureCount;
      if (failureCount > 0) {
        lastError ??= 'Some operations failed';
        lastErrorCode ??= 'PARTIAL_FAILURE';

        if (_queue.isNotEmpty) {
          _updateStatus(SyncOperationStatus.pending);
        } else {
          _updateStatus(SyncOperationStatus.failed);
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
        _updateStatus(SyncOperationStatus.success);

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
    } catch (e) {

      _updateStatus(SyncOperationStatus.failed);

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
      _updateStatus(SyncOperationStatus.idle);
      return SyncResult.success();
    }

    _processingLock = true;
    _isProcessing = true;
    _updateStatus(SyncOperationStatus.syncing);

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
              final nextRetryAt =
                  _backoff.calculateNextRetryTime(nextRetryCount);

              final retryOp = operation.copyWith(
                retryCount: nextRetryCount,
                nextRetryAt: nextRetryAt,
              );
              _queue.add(retryOp);

            } else {
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

          } else {
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

        _updateStatus(_queue.isEmpty
            ? SyncOperationStatus.failed
            : SyncOperationStatus.pending);

        return SyncResult.failure(
          lastError,
          code: lastErrorCode,
          successCount: successCount,
          failureCount: failureCount,
        );
      } else {
        _updateStatus(_queue.isEmpty
            ? SyncOperationStatus.success
            : SyncOperationStatus.pending);
        return SyncResult.success(
          successCount: successCount,
          failureCount: failureCount,
        );
      }
    } catch (e) {
      _updateStatus(SyncOperationStatus.failed);

      return SyncResult.failure(
        'Batch processing failed: ${e.toString()}',
        code: 'PROCESSING_ERROR',
        successCount: successCount,
        failureCount: failureCount,
      );
    } finally {
      _processingLock = false;
      _isProcessing = false;

    }
  }

  @override
  Future<int> retryFailedOperations() async {
    final failedOps = _queue
        .where((op) => op.retryCount > 0 && op.retryCount < _config.maxRetryAttempts)
        .toList();
    final retryCount = failedOps.length;

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
  }

  @override
  void resumeProcessing() {
    _isPaused = false;

    if (_queue.isNotEmpty && _config.autoProcess) {
      _scheduleProcessing();
    }
  }

  @override
  void updateConfig(SyncQueueConfig config) {
    _config = config;
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _networkOnlineSubscription?.cancel();
    _networkOnlineSubscription = null;
    _statusController.close();
    _queueController.close();
  }

  /// Persist the current queue state
  Future<void> _persistQueue() async {
    if (!_persistenceEnabled) return;

    try {
      final result = await _persistence!.saveQueue(_queue);
      if (!result.success) {
      }
    } catch (e) {
    // intentional silent catch
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

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Mock success (in real implementation, this would make API calls)
    return true;
  }

  /// Update sync status and notify listeners
  void _updateStatus(SyncOperationStatus newStatus) {
    if (_isDisposed) return;
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(_status);
    }
  }

  /// Notify listeners that queue has changed
  void _notifyQueueChanged() {
    if (_isDisposed) return;
    _queueController.add(List.unmodifiable(_queue));
  }

  /// Schedule processing with delay
  void _scheduleProcessing() {
    if (_isDisposed) return;
    Future.delayed(Duration(milliseconds: _config.retryDelayMs), () {
      if (!_isDisposed && !_isPaused && !_isProcessing && _queue.isNotEmpty) {
        processBatch();
      }
    });
  }

  /// Get current network connection type for history logging
  Future<String?> _getCurrentConnectionType() async {
    if (!_networkMonitoringEnabled) return null;

    try {
      return _networkConnectivity!.connectionType.name;
    } catch (e) {
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
          startedAt:
              DateTime.now(), // Will be updated when we add startedAt tracking
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
                suggestion: 'Please try again later',
                occurredAt: DateTime.now(),
              )
            : null;

        updatedEntry = SyncHistoryEntry.failure(
          id: _currentHistoryEntryId!,
          startedAt:
              DateTime.now(), // Will be updated when we add startedAt tracking
          successCount: successCount,
          failureCount: failureCount,
          totalCount: totalCount,
          error: syncError!,
          isManual: _isManualSync,
          connectionType: connectionType,
        );
      }

      await _historyService!.updateEntry(_currentHistoryEntryId!, updatedEntry);
    } catch (e) {
      // intentional silent catch - updateEntry failure is non-critical
    } finally {
      _currentHistoryEntryId = null;
    }
  }
}
