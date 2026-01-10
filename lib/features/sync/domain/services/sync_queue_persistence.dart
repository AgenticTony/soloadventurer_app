import '../models/sync_operation.dart';

/// Result of a queue persistence operation
class SyncQueuePersistenceResult {
  /// Whether the operation was successful
  final bool success;

  /// Number of operations persisted
  final int operationCount;

  /// Error message if operation failed
  final String? error;

  const SyncQueuePersistenceResult({
    required this.success,
    this.operationCount = 0,
    this.error,
  });

  /// Creates a successful result
  factory SyncQueuePersistenceResult.success({int operationCount = 0}) {
    return SyncQueuePersistenceResult(
      success: true,
      operationCount: operationCount,
    );
  }

  /// Creates a failed result
  factory SyncQueuePersistenceResult.failure(String error) {
    return SyncQueuePersistenceResult(
      success: false,
      error: error,
    );
  }

  @override
  String toString() => 'SyncQueuePersistenceResult(success: $success, '
      'operationCount: $operationCount, error: $error)';
}

/// Abstract interface for persisting sync queue operations
///
/// Implementations should handle:
/// - Saving operations to persistent storage
/// - Loading operations from persistent storage
/// - Clearing persisted operations
/// - Handling corrupted data gracefully
abstract class SyncQueuePersistence {
  /// Save the current queue to persistent storage
  ///
  /// Returns [SyncQueuePersistenceResult] with operation count or error
  Future<SyncQueuePersistenceResult> saveQueue(List<SyncOperation> queue);

  /// Load the queue from persistent storage
  ///
  /// Returns a list of operations, or empty list if none exist or on error
  Future<List<SyncOperation>> loadQueue();

  /// Clear all persisted queue data
  ///
  /// Returns [SyncQueuePersistenceResult] indicating success or failure
  Future<SyncQueuePersistenceResult> clearQueue();

  /// Remove a specific operation from persistent storage
  ///
  /// Returns [true] if operation was found and removed
  Future<bool> removeOperation(String operationId);

  /// Check if there are any persisted operations
  ///
  /// Returns [true] if operations exist in storage
  Future<bool> hasPersistedOperations();

  /// Get the count of persisted operations
  ///
  /// Returns the number of operations in storage, or 0 if none exist
  Future<int> getOperationCount();
}
