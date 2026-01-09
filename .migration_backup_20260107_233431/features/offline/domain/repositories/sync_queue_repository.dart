import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';

/// Repository interface for managing sync queue operations
///
/// This repository provides methods for enqueueing, dequeueing, and managing
/// sync operations in the local database. It handles priority-based queueing,
/// retry logic, and cleanup of completed operations.
abstract class SyncQueueRepository {
  /// Enqueues a new sync operation
  ///
  /// The [operation] parameter is the sync operation to enqueue.
  /// Returns the enqueued operation with the database-generated ID.
  ///
  /// Throws [RepositoryException] if the operation cannot be enqueued.
  Future<SyncOperationEntity> enqueueOperation(SyncOperationEntity operation);

  /// Enqueues multiple sync operations in a single transaction
  ///
  /// The [operations] parameter is a list of sync operations to enqueue.
  /// Returns the count of operations successfully enqueued.
  ///
  /// This is more efficient than enqueueing operations one by one.
  Future<int> enqueueOperations(List<SyncOperationEntity> operations);

  /// Dequeues the next pending operation
  ///
  /// Returns the next pending operation ordered by priority, or null if queue is empty.
  ///
  /// Priority order: high > normal > low
  /// Within same priority: oldest operations first
  Future<SyncOperationEntity?> dequeueOperation();

  /// Gets multiple pending operations ordered by priority
  ///
  /// The [limit] parameter is the maximum number of operations to return (default: 50).
  /// Returns a list of pending operations prioritized for execution.
  ///
  /// Priority order: high > normal > low
  /// Within same priority: oldest operations first
  Future<List<SyncOperationEntity>> getPendingOperations({int limit = 50});

  /// Gets all operations for a specific entity
  ///
  /// The [entityType] parameter is the entity type (e.g., 'trip', 'journal').
  /// The [entityId] parameter is the entity ID.
  /// Returns a list of sync operations for the specified entity.
  Future<List<SyncOperationEntity>> getOperationsByEntity(
    String entityType,
    String entityId,
  );

  /// Gets all operations for a specific entity type
  ///
  /// The [entityType] parameter is the entity type (e.g., 'trip', 'journal').
  /// Returns a list of sync operations for the specified entity type.
  Future<List<SyncOperationEntity>> getOperationsByEntityType(
    String entityType,
  );

  /// Gets operations by status
  ///
  /// The [status] parameter is the operation status.
  /// Returns a list of operations with the specified status.
  Future<List<SyncOperationEntity>> getOperationsByStatus(
    SyncOperationStatus status,
  );

  /// Gets a sync operation by ID
  ///
  /// The [id] parameter is the operation ID to retrieve.
  /// Returns the sync operation if found, null otherwise.
  Future<SyncOperationEntity?> getOperationById(int id);

  /// Marks an operation as completed
  ///
  /// The [id] parameter is the operation ID to mark as completed.
  /// Returns the number of operations affected (should be 1).
  Future<int> markAsCompleted(int id);

  /// Marks an operation as failed with the given error message
  ///
  /// The [id] parameter is the operation ID to mark as failed.
  /// The [errorMessage] parameter is the error message to store.
  /// Returns the number of operations affected (should be 1).
  Future<int> markAsFailed(int id, String errorMessage);

  /// Marks an operation as processing
  ///
  /// The [id] parameter is the operation ID to mark as processing.
  /// Returns the number of operations affected (should be 1).
  Future<int> markAsProcessing(int id);

  /// Resets failed operations to pending for retry
  ///
  /// The [ids] parameter is a list of operation IDs to reset.
  /// Returns the count of operations reset.
  Future<int> resetOperationsForRetry(List<int> ids);

  /// Gets operations that are ready to be retried
  ///
  /// Returns a list of failed operations that can be retried based on
  /// exponential backoff logic.
  Future<List<SyncOperationEntity>> getOperationsReadyForRetry();

  /// Clears all completed operations
  ///
  /// Returns the count of operations deleted.
  ///
  /// This is a cleanup operation for operations that completed successfully.
  Future<int> clearCompletedOperations();

  /// Clears all operations (including pending, failed, etc.)
  ///
  /// Returns the count of operations deleted.
  ///
  /// **WARNING**: This is a destructive operation. Use with caution.
  Future<int> clearAllOperations();

  /// Clears old completed operations
  ///
  /// The [olderThan] parameter is the timestamp threshold.
  /// Operations completed before this time will be deleted.
  /// Returns the count of operations deleted.
  Future<int> clearOldCompletedOperations(DateTime olderThan);

  /// Clears operations for a specific entity
  ///
  /// The [entityType] parameter is the entity type.
  /// The [entityId] parameter is the entity ID.
  /// Returns the count of operations deleted.
  Future<int> clearOperationsForEntity(String entityType, String entityId);

  /// Clears old failed operations that exceeded max retries
  ///
  /// The [olderThan] parameter is the timestamp threshold.
  /// Operations that failed before this time will be deleted.
  /// Returns the count of operations deleted.
  Future<int> clearOldFailedOperations(DateTime olderThan);

  /// Counts all pending operations
  ///
  /// Returns the count of operations with pending status.
  Future<int> countPendingOperations();

  /// Counts all failed operations
  ///
  /// Returns the count of operations with failed status.
  Future<int> countFailedOperations();

  /// Gets queue statistics
  ///
  /// Returns a map with statistics about the sync queue:
  /// - 'pending': count of pending operations
  /// - 'processing': count of processing operations
  /// - 'completed': count of completed operations
  /// - 'failed': count of failed operations
  Future<Map<String, int>> getQueueStatistics();

  /// Gets the total size of the queue
  ///
  /// Returns the total count of all operations in the queue.
  Future<int> getQueueSize();

  /// Updates an existing sync operation
  ///
  /// The [operation] parameter is the updated sync operation.
  /// Returns the number of operations affected (should be 1).
  Future<int> updateOperation(SyncOperationEntity operation);

  /// Deletes a sync operation by ID
  ///
  /// The [id] parameter is the operation ID to delete.
  /// Returns the number of operations affected (should be 1).
  Future<int> deleteOperation(int id);

  /// Deletes multiple sync operations by IDs
  ///
  /// The [ids] parameter is a list of operation IDs to delete.
  /// Returns the count of operations deleted.
  Future<int> deleteOperations(List<int> ids);
}
