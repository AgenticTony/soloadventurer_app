import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';
import 'package:soloadventurer/features/offline/domain/repositories/sync_queue_repository.dart';

/// Result of a sync queue operation
class SyncQueueResult {
  /// Whether the operation was successful
  final bool success;

  /// Error message if the operation failed
  final String? errorMessage;

  /// ID of the sync operation (if applicable)
  final int? operationId;

  /// Number of operations affected (if applicable)
  final int? operationsCount;

  /// Creates a successful result
  const SyncQueueResult.success({
    this.operationId,
    this.operationsCount,
  })  : success = true,
        errorMessage = null;

  /// Creates a failed result
  const SyncQueueResult.failure(this.errorMessage, {this.operationsCount})
      : success = false,
        operationId = null;

  @override
  String toString() {
    if (success) {
      return 'SyncQueueResult.success(operationId: $operationId, '
          'operationsCount: $operationsCount)';
    } else {
      return 'SyncQueueResult.failure(errorMessage: $errorMessage, '
          'operationsCount: $operationsCount)';
    }
  }
}

/// Service to manage sync queue lifecycle
///
/// This service provides high-level operations for managing the sync queue,
/// including enqueueing operations, retrying failed operations, and cleaning
/// up completed operations. It integrates with connectivity monitoring to
/// handle offline scenarios gracefully.
///
/// The service ensures:
/// - Operations are queued when offline
/// - Queue is persisted to database
/// - Queue is recovered on app restart
/// - Failed operations are retried with exponential backoff
/// - Batch operations are supported
///
/// Example usage:
/// ```dart
/// final syncQueueService = SyncQueueService(
///   repository: syncQueueRepository,
///   connectivityService: connectivityService,
/// );
///
/// // Enqueue a single operation
/// final result = await syncQueueService.enqueueOperation(
///   entityType: 'trip',
///   entityId: '123',
///   operation: SyncOperationType.create,
///   data: {'title': 'My Trip'},
/// );
///
/// // Process pending operations
/// await syncQueueService.processPendingOperations(
///   onProcess: (operation) async {
///     // Sync operation to server
///     return true; // Return true if successful
///   },
/// );
/// ```
class SyncQueueService {
  /// Repository for sync queue database operations
  final SyncQueueRepository _repository;

  /// Connectivity service for checking network status
  final ConnectivityService _connectivityService;

  /// Stream subscription for connectivity changes
  StreamSubscription? _connectivitySubscription;

  /// Controller for queue size updates
  final StreamController<int> _queueSizeController =
      StreamController<int>.broadcast();

  /// Current queue size (cached)
  int _currentQueueSize = 0;

  /// Timer for periodic cleanup of old operations
  Timer? _cleanupTimer;

  /// Interval for periodic cleanup (default: 1 hour)
  final Duration cleanupInterval;

  /// Maximum age for completed operations before cleanup
  final Duration completedOperationMaxAge;

  /// Maximum age for failed operations before cleanup
  final Duration failedOperationMaxAge;

  /// Creates a new [SyncQueueService] instance
  ///
  /// [repository] - Repository for sync queue database operations
  /// [connectivityService] - Connectivity service for checking network status
  /// [cleanupInterval] - Interval for periodic cleanup (default: 1 hour)
  /// [completedOperationMaxAge] - Max age for completed operations (default: 7 days)
  /// [failedOperationMaxAge] - Max age for failed operations (default: 30 days)
  SyncQueueService({
    required SyncQueueRepository repository,
    required ConnectivityService connectivityService,
    this.cleanupInterval = const Duration(hours: 1),
    this.completedOperationMaxAge = const Duration(days: 7),
    this.failedOperationMaxAge = const Duration(days: 30),
  })  : _repository = repository,
        _connectivityService = connectivityService;

  // ==============================================================================
  // PUBLIC API - QUEUE MANAGEMENT
  // ==============================================================================

  /// Stream of queue size updates
  ///
  /// Emits the current queue size whenever it changes.
  /// This is useful for UI components that need to display pending operation count.
  Stream<int> get queueSizeStream => _queueSizeController.stream;

  /// Gets the current queue size
  ///
  /// Returns the total count of all operations in the queue.
  /// This includes pending, processing, and failed operations.
  Future<int> getQueueSize() async {
    try {
      _currentQueueSize = await _repository.getQueueSize();
      return _currentQueueSize;
    } catch (e) {
      debugPrint('❌ Error getting queue size: $e');
      return 0;
    }
  }

  /// Gets the count of pending operations
  ///
  /// Returns the count of operations with pending status.
  Future<int> getPendingCount() async {
    try {
      return await _repository.countPendingOperations();
    } catch (e) {
      debugPrint('❌ Error getting pending count: $e');
      return 0;
    }
  }

  /// Gets the count of failed operations
  ///
  /// Returns the count of operations with failed status.
  Future<int> getFailedCount() async {
    try {
      return await _repository.countFailedOperations();
    } catch (e) {
      debugPrint('❌ Error getting failed count: $e');
      return 0;
    }
  }

  /// Gets queue statistics
  ///
  /// Returns a map with statistics about the sync queue including
  /// counts for each status (pending, processing, completed, failed).
  Future<Map<String, int>> getQueueStatistics() async {
    try {
      return await _repository.getQueueStatistics();
    } catch (e) {
      debugPrint('❌ Error getting queue statistics: $e');
      return {
        'pending': 0,
        'processing': 0,
        'completed': 0,
        'failed': 0,
      };
    }
  }

  // ==============================================================================
  // PUBLIC API - ENQUEUE OPERATIONS
  // ==============================================================================

  /// Enqueues a single sync operation
  ///
  /// The [entityType] parameter is the type of entity (e.g., 'trip', 'journal').
  /// The [entityId] parameter is the ID of the entity.
  /// The [operation] parameter is the type of operation to perform.
  /// The [data] parameter is the payload data for the operation.
  /// The [priority] parameter is the priority level (default: normal).
  /// The [maxRetries] parameter is the maximum retry attempts (default: 3).
  /// The [version] parameter is the entity version for conflict resolution.
  ///
  /// Returns a [SyncQueueResult] indicating success or failure.
  Future<SyncQueueResult> enqueueOperation({
    required String entityType,
    required String entityId,
    required SyncOperationType operation,
    required Map<String, dynamic> data,
    SyncPriority priority = SyncPriority.normal,
    int maxRetries = 3,
    int? version,
  }) async {
    try {
      final entity = SyncOperationEntity(
        id: 0, // ID will be assigned by database
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        data: data,
        priority: priority,
        maxRetries: maxRetries,
        status: SyncOperationStatus.pending,
        createdAt: DateTime.now(),
        version: version,
      );

      final result = await _repository.enqueueOperation(entity);

      debugPrint('✅ Enqueued sync operation: ${result.description} '
          '(id: ${result.id})');

      await _emitQueueSizeUpdate();

      return SyncQueueResult.success(operationId: result.id);
    } catch (e) {
      debugPrint('❌ Error enqueueing operation: $e');
      return SyncQueueResult.failure('Failed to enqueue operation: $e');
    }
  }

  /// Enqueues multiple sync operations in a batch
  ///
  /// The [operations] parameter is a list of operation specifications.
  /// Each operation is a map containing: entityType, entityId, operation, data,
  /// and optionally priority, maxRetries, and version.
  ///
  /// Returns a [SyncQueueResult] with the count of successfully enqueued operations.
  Future<SyncQueueResult> enqueueOperations(
    List<Map<String, dynamic>> operations,
  ) async {
    try {
      final entities = operations.map((op) {
        return SyncOperationEntity(
          id: 0,
          entityType: op['entityType'] as String,
          entityId: op['entityId'] as String,
          operation: op['operation'] as SyncOperationType,
          data: op['data'] as Map<String, dynamic>,
          priority: op['priority'] as SyncPriority? ?? SyncPriority.normal,
          maxRetries: op['maxRetries'] as int? ?? 3,
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
          version: op['version'] as int?,
        );
      }).toList();

      final count = await _repository.enqueueOperations(entities);

      debugPrint('✅ Enqueued $count sync operations in batch');

      await _emitQueueSizeUpdate();

      return SyncQueueResult.success(operationsCount: count);
    } catch (e) {
      debugPrint('❌ Error enqueuing operations: $e');
      return SyncQueueResult.failure(
        'Failed to enqueue operations: $e',
        operationsCount: 0,
      );
    }
  }

  // ==============================================================================
  // PUBLIC API - PROCESS OPERATIONS
  // ==============================================================================

  /// Processes pending sync operations
  ///
  /// The [limit] parameter is the maximum number of operations to process
  /// (default: 10). Operations are processed in priority order.
  /// The [onProcess] callback is invoked for each operation and should return
  /// true if the operation was successful, false otherwise.
  ///
  /// Returns a [SyncQueueResult] with the count of successfully processed operations.
  Future<SyncQueueResult> processPendingOperations({
    int limit = 10,
    required Future<bool> Function(SyncOperationEntity) onProcess,
  }) async {
    try {
      // Get pending operations prioritized by priority and age
      final operations = await _repository.getPendingOperations(limit: limit);

      if (operations.isEmpty) {
        debugPrint('📭 No pending operations to process');
        return const SyncQueueResult.success(operationsCount: 0);
      }

      debugPrint('🔄 Processing ${operations.length} pending operations...');

      int successCount = 0;
      int failureCount = 0;

      for (final operation in operations) {
        try {
          // Mark as processing
          await _repository.markAsProcessing(operation.id);

          // Process the operation
          final success = await onProcess(operation);

          if (success) {
            // Mark as completed
            await _repository.markAsCompleted(operation.id);
            successCount++;
            debugPrint('✅ Operation completed: ${operation.description}');
          } else {
            // Mark as failed
            await _repository.markAsFailed(
              operation.id,
              'Operation processing returned false',
            );
            failureCount++;
            debugPrint('❌ Operation failed: ${operation.description}');
          }
        } catch (e) {
          // Mark as failed with error
          await _repository.markAsFailed(operation.id, e.toString());
          failureCount++;
          debugPrint('❌ Operation error: ${operation.description} - $e');
        }
      }

      await _emitQueueSizeUpdate();

      debugPrint('📊 Processing complete: $successCount succeeded, '
          '$failureCount failed');

      return SyncQueueResult.success(operationsCount: successCount);
    } catch (e) {
      debugPrint('❌ Error processing operations: $e');
      return SyncQueueResult.failure('Failed to process operations: $e');
    }
  }

  /// Retries failed operations that are ready for retry
  ///
  /// Checks exponential backoff and only retries operations that have
  /// exceeded their backoff period. The [limit] parameter controls the
  /// maximum number of operations to retry (default: 10).
  ///
  /// Returns a [SyncQueueResult] with the count of retried operations.
  Future<SyncQueueResult> retryFailedOperations({int limit = 10}) async {
    try {
      final readyForRetry = await _repository.getOperationsReadyForRetry();

      if (readyForRetry.isEmpty) {
        debugPrint('📭 No failed operations ready for retry');
        return const SyncQueueResult.success(operationsCount: 0);
      }

      // Take only up to the limit
      final toRetry = readyForRetry.take(limit).toList();

      debugPrint('🔄 Retrying ${toRetry.length} failed operations...');

      // Reset operations to pending status
      final ids = toRetry.map((op) => op.id).toList();
      final count = await _repository.resetOperationsForRetry(ids);

      debugPrint('✅ Reset $count operations for retry');

      await _emitQueueSizeUpdate();

      return SyncQueueResult.success(operationsCount: count);
    } catch (e) {
      debugPrint('❌ Error retrying operations: $e');
      return SyncQueueResult.failure('Failed to retry operations: $e');
    }
  }

  // ==============================================================================
  // PUBLIC API - CLEANUP OPERATIONS
  // ==============================================================================

  /// Clears completed operations older than the configured max age
  ///
  /// This is called automatically by the periodic cleanup timer but can
  /// also be called manually.
  ///
  /// Returns a [SyncQueueResult] with the count of cleared operations.
  Future<SyncQueueResult> clearOldCompletedOperations() async {
    try {
      final cutoffDate =
          DateTime.now().subtract(completedOperationMaxAge);
      final count =
          await _repository.clearOldCompletedOperations(cutoffDate);

      if (count > 0) {
        debugPrint('🧹 Cleared $count old completed operations');
        await _emitQueueSizeUpdate();
      }

      return SyncQueueResult.success(operationsCount: count);
    } catch (e) {
      debugPrint('❌ Error clearing old completed operations: $e');
      return SyncQueueResult.failure(
        'Failed to clear old operations: $e',
        operationsCount: 0,
      );
    }
  }

  /// Clears failed operations older than the configured max age
  ///
  /// This is called automatically by the periodic cleanup timer but can
  /// also be called manually.
  ///
  /// Returns a [SyncQueueResult] with the count of cleared operations.
  Future<SyncQueueResult> clearOldFailedOperations() async {
    try {
      final cutoffDate = DateTime.now().subtract(failedOperationMaxAge);
      final count = await _repository.clearOldFailedOperations(cutoffDate);

      if (count > 0) {
        debugPrint('🧹 Cleared $count old failed operations');
        await _emitQueueSizeUpdate();
      }

      return SyncQueueResult.success(operationsCount: count);
    } catch (e) {
      debugPrint('❌ Error clearing old failed operations: $e');
      return SyncQueueResult.failure(
        'Failed to clear failed operations: $e',
        operationsCount: 0,
      );
    }
  }

  /// Clears all completed operations
  ///
  /// Returns a [SyncQueueResult] with the count of cleared operations.
  Future<SyncQueueResult> clearAllCompletedOperations() async {
    try {
      final count = await _repository.clearCompletedOperations();

      if (count > 0) {
        debugPrint('🧹 Cleared $count completed operations');
        await _emitQueueSizeUpdate();
      }

      return SyncQueueResult.success(operationsCount: count);
    } catch (e) {
      debugPrint('❌ Error clearing completed operations: $e');
      return SyncQueueResult.failure(
        'Failed to clear completed operations: $e',
        operationsCount: 0,
      );
    }
  }

  /// Clears all operations in the queue
  ///
  /// **WARNING**: This is a destructive operation. Use with caution.
  /// This will delete all operations regardless of their status.
  ///
  /// Returns a [SyncQueueResult] with the count of cleared operations.
  Future<SyncQueueResult> clearAllOperations() async {
    try {
      final count = await _repository.clearAllOperations();

      debugPrint('🧹 Cleared all $count operations from queue');

      await _emitQueueSizeUpdate();

      return SyncQueueResult.success(operationsCount: count);
    } catch (e) {
      debugPrint('❌ Error clearing all operations: $e');
      return SyncQueueResult.failure(
        'Failed to clear all operations: $e',
        operationsCount: 0,
      );
    }
  }

  // ==============================================================================
  // PUBLIC API - LIFECYCLE MANAGEMENT
  // ==============================================================================

  /// Initializes the sync queue service
  ///
  /// This method:
  /// 1. Starts periodic cleanup timer
  /// 2. Emits initial queue size
  /// 3. Recovers any stuck processing operations
  ///
  /// Returns [true] if initialization was successful.
  Future<bool> initialize() async {
    try {
      debugPrint('🔄 Initializing SyncQueueService...');

      // Recover any operations that were marked as processing
      // but the app crashed before completion
      await _recoverStuckOperations();

      // Emit initial queue size
      await _emitQueueSizeUpdate();

      // Start periodic cleanup timer
      _startCleanupTimer();

      debugPrint('✅ SyncQueueService initialized successfully');

      return true;
    } catch (e) {
      debugPrint('❌ Error initializing SyncQueueService: $e');
      return false;
    }
  }

  /// Disposes of resources
  ///
  /// Call this when the service is no longer needed to prevent memory leaks.
  void dispose() {
    debugPrint('🔄 Disposing SyncQueueService...');

    _cleanupTimer?.cancel();
    _cleanupTimer = null;

    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    _queueSizeController.close();
  }

  // ==============================================================================
  // PRIVATE METHODS
  // ==============================================================================

  /// Recovers operations that were stuck in processing state
  ///
  /// This can happen if the app crashes while an operation is being processed.
  /// We reset these operations to pending so they can be retried.
  Future<void> _recoverStuckOperations() async {
    try {
      final processingOps =
          await _repository.getOperationsByStatus(SyncOperationStatus.processing);

      if (processingOps.isNotEmpty) {
        debugPrint('🔄 Recovering ${processingOps.length} stuck operations...');

        final ids = processingOps.map((op) => op.id).toList();
        await _repository.resetOperationsForRetry(ids);

        debugPrint('✅ Recovered ${processingOps.length} stuck operations');
      }
    } catch (e) {
      debugPrint('❌ Error recovering stuck operations: $e');
    }
  }

  /// Emits a queue size update
  Future<void> _emitQueueSizeUpdate() async {
    try {
      final newSize = await getQueueSize();

      if (!_queueSizeController.isClosed) {
        _queueSizeController.add(newSize);
      }
    } catch (e) {
      debugPrint('❌ Error emitting queue size update: $e');
    }
  }

  /// Starts the periodic cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();

    _cleanupTimer = Timer.periodic(cleanupInterval, (_) {
      debugPrint('🧹 Running periodic cleanup...');
      clearOldCompletedOperations();
      clearOldFailedOperations();
    });

    debugPrint('⏰ Cleanup timer started (interval: ${cleanupInterval.inMinutes}min)');
  }
}
