import '../models/sync_operation.dart';
import '../models/sync_status.dart';
import '../entities/sync_entity_type.dart';

/// Result of a sync operation
class SyncResult {
  /// Whether the sync was successful
  final bool success;

  /// Number of operations successfully synced
  final int successCount;

  /// Number of operations that failed
  final int failureCount;

  /// Error message if sync failed
  final String? error;

  /// Error code for specific error handling
  final String? errorCode;

  const SyncResult({
    required this.success,
    this.successCount = 0,
    this.failureCount = 0,
    this.error,
    this.errorCode,
  });

  /// Creates a successful sync result
  factory SyncResult.success({
    int successCount = 0,
    int failureCount = 0,
  }) =>
      SyncResult(
        success: true,
        successCount: successCount,
        failureCount: failureCount,
      );

  /// Creates a failed sync result
  factory SyncResult.failure(
    String error, {
    String? code,
    int successCount = 0,
    int failureCount = 0,
  }) =>
      SyncResult(
        success: false,
        error: error,
        errorCode: code,
        successCount: successCount,
        failureCount: failureCount,
      );

  @override
  String toString() =>
      'SyncResult(success: $success, successCount: $successCount, '
      'failureCount: $failureCount, error: $error, errorCode: $errorCode)';
}

/// Configuration for sync queue processing
class SyncQueueConfig {
  /// Maximum number of operations to process in a single batch
  final int maxBatchSize;

  /// Maximum number of retry attempts for failed operations
  final int maxRetryAttempts;

  /// Delay between retry attempts in milliseconds
  final int retryDelayMs;

  /// Whether to automatically process queue when operations are added
  final bool autoProcess;

  /// Maximum queue size before operations are rejected
  final int maxQueueSize;

  const SyncQueueConfig({
    this.maxBatchSize = 50,
    this.maxRetryAttempts = 5,
    this.retryDelayMs = 1000,
    this.autoProcess = true,
    this.maxQueueSize = 1000,
  });

  /// Default configuration
  static const defaultConfig = SyncQueueConfig();
}

/// Abstract interface for sync service operations
abstract class SyncService {
  /// Current queue of pending operations (FIFO order)
  List<SyncOperation> get queue;

  /// Number of operations currently in queue
  int get queueSize;

  /// Whether the queue is currently being processed
  bool get isProcessing;

  /// Current sync status
  SyncOperationStatus get status;

  /// Stream of sync status changes
  Stream<SyncOperationStatus> get statusStream;

  /// Stream of queue changes
  Stream<List<SyncOperation>> get queueStream;

  /// Add a single operation to the queue
  ///
  /// Returns [true] if operation was added successfully
  /// Returns [false] if queue is full or operation is invalid
  Future<bool> enqueueOperation(SyncOperation operation);

  /// Add multiple operations to the queue
  ///
  /// Returns the number of operations successfully added
  Future<int> enqueueOperations(List<SyncOperation> operations);

  /// Remove an operation from the queue by ID
  ///
  /// Returns [true] if operation was found and removed
  Future<bool> removeOperation(String operationId);

  /// Clear all operations from the queue
  Future<void> clearQueue();

  /// Process the queue (FIFO order)
  ///
  /// Processes operations in order of priority, then by creation time.
  /// Stops processing if a critical error occurs.
  ///
  /// Returns [SyncResult] with operation counts and error information
  Future<SyncResult> processQueue();

  /// Process a single batch of operations
  ///
  /// Processes up to [maxBatchSize] operations from the queue.
  ///
  /// Returns [SyncResult] with operation counts and error information
  Future<SyncResult> processBatch({int? maxBatchSize});

  /// Retry failed operations
  ///
  /// Re-queues operations that failed due to transient errors.
  /// Operations that have exceeded max retry attempts are removed.
  ///
  /// Returns the number of operations re-queued
  Future<int> retryFailedOperations();

  /// Get operations by entity type
  List<SyncOperation> getOperationsByType(SyncEntityType entityType);

  /// Get operations by operation type (create, update, delete)
  List<SyncOperation> getOperationsByOperationType(
      SyncOperationType operationType);

  /// Get operations pending for a specific entity
  List<SyncOperation> getOperationsForEntity(String entityId);

  /// Pause queue processing
  void pauseProcessing();

  /// Resume queue processing
  void resumeProcessing();

  /// Update queue configuration
  void updateConfig(SyncQueueConfig config);

  /// Get current configuration
  SyncQueueConfig get config;

  /// Dispose of resources
  void dispose();
}

/// Provider signature for dependency injection
typedef SyncServiceProvider = SyncService Function();
