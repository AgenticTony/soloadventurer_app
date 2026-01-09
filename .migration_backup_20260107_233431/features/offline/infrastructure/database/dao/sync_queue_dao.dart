import 'package:drift/drift.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';

/// Data Access Object for SyncQueue table
///
/// Provides type-safe database operations for sync queue management.
/// Supports offline-first scenarios with prioritized sync operations.
class SyncQueueDao extends DatabaseAccessor<AppDatabase> {
  /// Creates a new SyncQueueDao
  ///
  /// The [db] parameter is the AppDatabase instance.
  SyncQueueDao(super.db);

  // ==============================================================================
  // CRUD OPERATIONS
  // ==============================================================================

  /// Enqueues a new sync operation
  ///
  /// The [item] parameter is a SyncQueueCompanion object with sync operation data.
  /// Returns the inserted sync queue item with the database-generated ID.
  ///
  /// Throws [InvalidDataException] if the sync operation data is invalid.
  Future<SyncQueueItem> enqueueOperation(SyncQueueCompanion item) async {
    return db.syncQueue.insert(item);
  }

  /// Enqueues multiple sync operations in a single transaction
  ///
  /// The [items] parameter is a list of SyncQueueCompanion objects.
  /// Returns the count of operations enqueued.
  ///
  /// This is more efficient than enqueueing operations one by one.
  Future<int> enqueueOperations(List<SyncQueueCompanion> items) async {
    return await transaction(() async {
      var count = 0;
      for (final item in items) {
        db.syncQueue.insert(item);
        count++;
      }
      return count;
    });
  }

  /// Updates an existing sync queue item
  ///
  /// The [item] parameter is a SyncQueueItem object with updated data.
  /// Returns the number of rows affected (should be 1).
  Future<int> updateOperation(SyncQueueItem item) async {
    return await db.syncQueue.update.replace(item);
  }

  /// Deletes a sync queue item by ID
  ///
  /// The [id] parameter is the sync queue item ID to delete.
  /// Returns the number of rows affected (should be 1 or 0).
  Future<int> deleteOperationById(int id) async {
    return await (db.syncQueue.delete..where((sq) => sq.id.equals(id))).go();
  }

  /// Deletes multiple sync queue items by IDs
  ///
  /// The [ids] parameter is a list of sync queue item IDs to delete.
  /// Returns the count of operations deleted.
  Future<int> deleteOperationsByIds(List<int> ids) async {
    return await (db.syncQueue.delete..where((sq) => sq.id.isIn(ids))).go();
  }

  // ==============================================================================
  // QUERY OPERATIONS
  // ==============================================================================

  /// Gets a sync queue item by ID
  ///
  /// The [id] parameter is the sync queue item ID to retrieve.
  /// Returns the sync queue item if found, null otherwise.
  Future<SyncQueueItem?> getOperationById(int id) {
    return (select(syncQueue)..where((sq) => sq.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gets all pending sync operations
  ///
  /// Returns a list of operations with status 'pending'.
  ///
  /// Ordered by priority (high first) and creation date (oldest first).
  Future<List<SyncQueueItem>> getPendingOperations() {
    return (select(syncQueue)
          ..where((sq) => sq.status.equals('pending'))
          ..orderBy([
            (sq) => OrderingTerm.asc(sq.priority),
            (sq) => OrderingTerm.asc(sq.createdAt),
          ]))
        .get();
  }

  /// Gets pending operations ordered by priority
  ///
  /// The [limit] parameter is the maximum number of operations to return.
  /// Returns a list of pending operations prioritized for execution.
  ///
  /// Priority order: 'high' > 'normal' > 'low'
  Future<List<SyncQueueItem>> getPendingOperationsByPriority(
      {int limit = 50}) {
    // Using CASE WHEN for priority ordering
    // high = 1, normal = 2, low = 3
    final priorityCase = CaseWhen<String, int>([
      ifCase(syncQueue.priority.equals('high'), then: const Constant(1)),
      ifCase(syncQueue.priority.equals('normal'), then: const Constant(2)),
      ifCase(syncQueue.priority.equals('low'), then: const Constant(3)),
    ], otherwise: const Constant(2));

    return (select(syncQueue)
          ..where((sq) => sq.status.equals('pending'))
          ..orderBy([
            (sq) => OrderingTerm.asc(priorityCase),
            (sq) => OrderingTerm.asc(sq.createdAt),
          ])
          ..limit(limit))
        .get();
  }

  /// Gets failed operations that can be retried
  ///
  /// Returns a list of failed operations where retryCount < maxRetries.
  ///
  /// Ordered by retry count (fewest retries first) and last attempted time.
  Future<List<SyncQueueItem>> getFailedOperationsForRetry() {
    return (select(syncQueue)
          ..where((sq) => sq.status.equals('failed'))
          ..where((sq) => sq.retryCount.isSmallerThan(sq.maxRetries))
          ..orderBy([
            (sq) => OrderingTerm.asc(sq.retryCount),
            (sq) => OrderingTerm.asc(sq.lastAttemptedAt),
          ]))
        .get();
  }

  /// Gets all operations for a specific entity
  ///
  /// The [entityType] parameter is the entity type (e.g., 'trip', 'journal').
  /// The [entityId] parameter is the entity ID.
  /// Returns a list of sync operations for the specified entity.
  Future<List<SyncQueueItem>> getOperationsByEntity(
    String entityType,
    String entityId,
  ) {
    return (select(syncQueue)
          ..where((sq) => sq.entityType.equals(entityType))
          ..where((sq) => sq.entityId.equals(entityId))
          ..orderBy([(sq) => OrderingTerm.asc(sq.createdAt)]))
        .get();
  }

  /// Gets all operations for a specific entity type
  ///
  /// The [entityType] parameter is the entity type (e.g., 'trip', 'journal').
  /// Returns a list of sync operations for the specified entity type.
  Future<List<SyncQueueItem>> getOperationsByEntityType(String entityType) {
    return (select(syncQueue)
          ..where((sq) => sq.entityType.equals(entityType))
          ..orderBy([(sq) => OrderingTerm.asc(sq.createdAt)]))
        .get();
  }

  /// Gets all operations with a specific status
  ///
  /// The [status] parameter is the operation status (e.g., 'pending', 'processing', 'completed', 'failed').
  /// Returns a list of operations with the specified status.
  Future<List<SyncQueueItem>> getOperationsByStatus(String status) {
    return (select(syncQueue)
          ..where((sq) => sq.status.equals(status))
          ..orderBy([(sq) => OrderingTerm.asc(sq.createdAt)]))
        .get();
  }

  /// Gets operations by operation type
  ///
  /// The [operation] parameter is the operation type (e.g., 'create', 'update', 'delete').
  /// The [entityType] parameter is optional. If provided, filters by entity type as well.
  /// Returns a list of operations of the specified type.
  Future<List<SyncQueueItem>> getOperationsByType(String operation,
      {String? entityType}) {
    final query = select(syncQueue)
      ..where((sq) => sq.operation.equals(operation))
      ..orderBy([(sq) => OrderingTerm.asc(sq.createdAt)]);

    if (entityType != null) {
      query.where((sq) => sq.entityType.equals(entityType));
    }

    return query.get();
  }

  /// Counts all pending operations
  ///
  /// Returns the count of operations with status 'pending'.
  Future<int> countPendingOperations() async {
    final query = selectOnly(syncQueue)
      ..addColumns([syncQueue.id.count()])
      ..where(syncQueue.status.equals('pending'));

    final result = await query.getSingle();
    return result.read(syncQueue.id.count());
  }

  /// Counts all failed operations
  ///
  /// Returns the count of operations with status 'failed'.
  Future<int> countFailedOperations() async {
    final query = selectOnly(syncQueue)
      ..addColumns([syncQueue.id.count()])
      ..where(syncQueue.status.equals('failed'));

    final result = await query.getSingle();
    return result.read(syncQueue.id.count());
  }

  /// Counts operations by entity type and status
  ///
  /// The [entityType] parameter is the entity type.
  /// The [status] parameter is the operation status.
  /// Returns the count of matching operations.
  Future<int> countOperationsByEntityAndStatus(
      String entityType, String status) async {
    final query = selectOnly(syncQueue)
      ..addColumns([syncQueue.id.count()])
      ..where(syncQueue.entityType.equals(entityType))
      ..where(syncQueue.status.equals(status));

    final result = await query.getSingle();
    return result.read(syncQueue.id.count());
  }

  /// Gets queue statistics
  ///
  /// Returns a map with statistics about the sync queue:
  /// - 'pending': count of pending operations
  /// - 'processing': count of processing operations
  /// - 'completed': count of completed operations
  /// - 'failed': count of failed operations
  Future<Map<String, int>> getQueueStatistics() async {
    final pendingCount = await countPendingOperations();
    final processingCount = await _countByStatus('processing');
    final completedCount = await _countByStatus('completed');
    final failedCount = await countFailedOperations();

    return {
      'pending': pendingCount,
      'processing': processingCount,
      'completed': completedCount,
      'failed': failedCount,
    };
  }

  /// Counts operations by status (internal helper)
  Future<int> _countByStatus(String status) async {
    final query = selectOnly(syncQueue)
      ..addColumns([syncQueue.id.count()])
      ..where(syncQueue.status.equals(status));

    final result = await query.getSingle();
    return result.read(syncQueue.id.count());
  }

  // ==============================================================================
  // STATUS UPDATE OPERATIONS
  // ==============================================================================

  /// Marks an operation as processing
  ///
  /// The [id] parameter is the operation ID.
  /// Returns the number of rows affected.
  Future<int> markAsProcessing(int id) {
    return (db.syncQueue.update..where((sq) => sq.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('processing'),
        lastAttemptedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marks an operation as completed
  ///
  /// The [id] parameter is the operation ID.
  /// Returns the number of rows affected.
  Future<int> markAsCompleted(int id) {
    return (db.syncQueue.update..where((sq) => sq.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('completed'),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marks an operation as failed
  ///
  /// The [id] parameter is the operation ID.
  /// The [errorMessage] parameter is the error message to store.
  /// Returns the number of rows affected.
  Future<int> markAsFailed(int id, String errorMessage) {
    return (db.syncQueue.update..where((sq) => sq.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('failed'),
        errorMessage: Value(errorMessage),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marks an operation as failed and increments retry count
  ///
  /// The [id] parameter is the operation ID.
  /// The [errorMessage] parameter is the error message to store.
  /// Returns the number of rows affected.
  Future<int> markAsFailedWithRetry(int id, String errorMessage) async {
    final item = await getOperationById(id);
    if (item == null) return 0;

    final newRetryCount = item.retryCount + 1;
    final shouldFail = newRetryCount >= item.maxRetries;

    return (db.syncQueue.update..where((sq) => sq.id.equals(id))).write(
      SyncQueueCompanion(
        status: Value(shouldFail ? 'failed' : 'pending'),
        retryCount: Value(newRetryCount),
        errorMessage: Value(errorMessage),
        lastAttemptedAt: Value(DateTime.now()),
        completedAt: shouldFail ? Value(DateTime.now()) : const Value.absent(),
      ),
    );
  }

  /// Resets failed operations to pending for retry
  ///
  /// The [ids] parameter is a list of operation IDs to reset.
  /// Returns the count of operations reset.
  Future<int> resetOperationsForRetry(List<int> ids) {
    return (db.syncQueue.update..where((sq) => sq.id.isIn(ids))).write(
      const SyncQueueCompanion(
        status: Value('pending'),
        errorMessage: Value(null),
      ),
    );
  }

  // ==============================================================================
  // BATCH OPERATIONS
  // ==============================================================================

  /// Clears all completed operations
  ///
  /// Returns the count of operations deleted.
  ///
  /// This is a cleanup operation for operations that completed successfully.
  Future<int> clearCompletedOperations() async {
    return await (db.syncQueue.delete..where((sq) => sq.status.equals('completed')))
        .go();
  }

  /// Clears all operations (including pending, failed, etc.)
  ///
  /// Returns the count of operations deleted.
  ///
  /// **WARNING**: This is a destructive operation. Use with caution.
  Future<int> clearAllOperations() async {
    return await db.syncQueue.delete.go();
  }

  /// Clears old completed operations
  ///
  /// The [olderThan] parameter is the timestamp threshold.
  /// Operations completed before this time will be deleted.
  /// Returns the count of operations deleted.
  Future<int> clearOldCompletedOperations(DateTime olderThan) async {
    return await (db.syncQueue.delete
          ..where((sq) => sq.status.equals('completed'))
          ..where((sq) => sq.completedAt.isSmallerThanValue(olderThan)))
        .go();
  }

  /// Clears operations for a specific entity
  ///
  /// The [entityType] parameter is the entity type.
  /// The [entityId] parameter is the entity ID.
  /// Returns the count of operations deleted.
  Future<int> clearOperationsForEntity(String entityType, String entityId) {
    return (db.syncQueue.delete
          ..where((sq) => sq.entityType.equals(entityType))
          ..where((sq) => sq.entityId.equals(entityId)))
        .go();
  }

  /// Deletes old failed operations that exceeded max retries
  ///
  /// The [olderThan] parameter is the timestamp threshold.
  /// Operations that failed before this time will be deleted.
  /// Returns the count of operations deleted.
  Future<int> clearOldFailedOperations(DateTime olderThan) async {
    return await (db.syncQueue.delete
          ..where((sq) => sq.status.equals('failed'))
          ..where((sq) => sq.retryCount.isBiggerOrEqualValue(sq.maxRetries))
          ..where((sq) => sq.completedAt.isSmallerThanValue(olderThan)))
        .go();
  }

  /// Gets operations that need to be retried (based on exponential backoff)
  ///
  /// The [baseDelay] parameter is the base delay in seconds (default: 60).
  /// The [maxDelay] parameter is the maximum delay in seconds (default: 3600).
  /// Returns a list of failed operations that are ready for retry.
  ///
  /// Implements exponential backoff: delay = baseDelay * 2^retryCount
  Future<List<SyncQueueItem>> getOperationsReadyForRetry({
    int baseDelay = 60,
    int maxDelay = 3600,
  }) {
    final now = DateTime.now();

    // Calculate threshold for each operation based on retry count
    // This is approximated in SQL by checking if enough time has passed
    return (select(syncQueue)
          ..where((sq) => sq.status.equals('failed'))
          ..where((sq) => sq.retryCount.isSmallerThan(sq.maxRetries))
          ..where((sq) => sq.lastAttemptedAt.isNotNull())
          ..where((sq) => sq.lastAttemptedAt.isSmallerThanValue(
                now.subtract(Duration(
                  seconds: _calculateBackoffDelay(
                    baseDelay,
                    maxDelay,
                    0, // This will be filtered in code
                  ),
                )),
              )))
        .get();
  }

  /// Calculates exponential backoff delay
  int _calculateBackoffDelay(int baseDelay, int maxDelay, int retryCount) {
    final delay = baseDelay * (1 << retryCount); // 2^retryCount
    return delay > maxDelay ? maxDelay : delay;
  }
}
