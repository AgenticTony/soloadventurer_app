import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/offline/data/models/sync_operation_model.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';
import 'package:soloadventurer/features/offline/domain/repositories/sync_queue_repository.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/sync_queue_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/schema.dart';

/// Implementation of [SyncQueueRepository] that manages sync queue in local database
///
/// This repository handles persistence of sync operations using SQLite through Drift ORM.
/// It provides methods for enqueueing, dequeueing, and managing sync operations with
/// priority-based queueing and retry logic.
class SyncQueueRepositoryImpl implements SyncQueueRepository {
  final SyncQueueDao _syncQueueDao;

  /// Creates a new [SyncQueueRepositoryImpl]
  ///
  /// The [syncQueueDao] parameter is the DAO for sync queue database operations.
  const SyncQueueRepositoryImpl({
    required SyncQueueDao syncQueueDao,
  }) : _syncQueueDao = syncQueueDao;

  // ==============================================================================
  // ENQUEUE OPERATIONS
  // ==============================================================================

  @override
  Future<SyncOperationEntity> enqueueOperation(
      SyncOperationEntity operation) async {
    try {
      final item = await _syncQueueDao.enqueueOperation(
        _entityToCompanion(operation),
      );
      return SyncOperationModel.fromDatabase(item).toDomainEntity();
    } catch (e) {
      throw RepositoryException('Failed to enqueue operation: ${e.toString()}');
    }
  }

  @override
  Future<int> enqueueOperations(
      List<SyncOperationEntity> operations) async {
    try {
      final companions = operations.map(_entityToCompanion).toList();
      return await _syncQueueDao.enqueueOperations(companions);
    } catch (e) {
      throw RepositoryException(
          'Failed to enqueue operations: ${e.toString()}');
    }
  }

  // ==============================================================================
  // DEQUEUE OPERATIONS
  // ==============================================================================

  @override
  Future<SyncOperationEntity?> dequeueOperation() async {
    try {
      final items = await _syncQueueDao.getPendingOperationsByPriority(limit: 1);
      if (items.isEmpty) return null;

      // Mark as processing
      final item = items.first;
      await _syncQueueDao.markAsProcessing(item.id);

      // Get the updated item
      final updatedItem = await _syncQueueDao.getOperationById(item.id);
      if (updatedItem == null) return null;

      return SyncOperationModel.fromDatabase(updatedItem).toDomainEntity();
    } catch (e) {
      throw RepositoryException('Failed to dequeue operation: ${e.toString()}');
    }
  }

  @override
  Future<List<SyncOperationEntity>> getPendingOperations(
      {int limit = 50}) async {
    try {
      final items =
          await _syncQueueDao.getPendingOperationsByPriority(limit: limit);
      return items
          .map((item) => SyncOperationModel.fromDatabase(item).toDomainEntity())
          .toList();
    } catch (e) {
      throw RepositoryException(
          'Failed to get pending operations: ${e.toString()}');
    }
  }

  // ==============================================================================
  // QUERY OPERATIONS
  // ==============================================================================

  @override
  Future<List<SyncOperationEntity>> getOperationsByEntity(
    String entityType,
    String entityId,
  ) async {
    try {
      final items =
          await _syncQueueDao.getOperationsByEntity(entityType, entityId);
      return items
          .map((item) => SyncOperationModel.fromDatabase(item).toDomainEntity())
          .toList();
    } catch (e) {
      throw RepositoryException(
          'Failed to get operations by entity: ${e.toString()}');
    }
  }

  @override
  Future<List<SyncOperationEntity>> getOperationsByEntityType(
    String entityType,
  ) async {
    try {
      final items = await _syncQueueDao.getOperationsByEntityType(entityType);
      return items
          .map((item) => SyncOperationModel.fromDatabase(item).toDomainEntity())
          .toList();
    } catch (e) {
      throw RepositoryException(
          'Failed to get operations by entity type: ${e.toString()}');
    }
  }

  @override
  Future<List<SyncOperationEntity>> getOperationsByStatus(
    SyncOperationStatus status,
  ) async {
    try {
      final items = await _syncQueueDao.getOperationsByStatus(status.value);
      return items
          .map((item) => SyncOperationModel.fromDatabase(item).toDomainEntity())
          .toList();
    } catch (e) {
      throw RepositoryException(
          'Failed to get operations by status: ${e.toString()}');
    }
  }

  @override
  Future<SyncOperationEntity?> getOperationById(int id) async {
    try {
      final item = await _syncQueueDao.getOperationById(id);
      if (item == null) return null;

      return SyncOperationModel.fromDatabase(item).toDomainEntity();
    } catch (e) {
      throw RepositoryException(
          'Failed to get operation by ID: ${e.toString()}');
    }
  }

  // ==============================================================================
  // STATUS UPDATE OPERATIONS
  // ==============================================================================

  @override
  Future<int> markAsCompleted(int id) async {
    try {
      return await _syncQueueDao.markAsCompleted(id);
    } catch (e) {
      throw RepositoryException(
          'Failed to mark operation as completed: ${e.toString()}');
    }
  }

  @override
  Future<int> markAsFailed(int id, String errorMessage) async {
    try {
      return await _syncQueueDao.markAsFailedWithRetry(id, errorMessage);
    } catch (e) {
      throw RepositoryException(
          'Failed to mark operation as failed: ${e.toString()}');
    }
  }

  @override
  Future<int> markAsProcessing(int id) async {
    try {
      return await _syncQueueDao.markAsProcessing(id);
    } catch (e) {
      throw RepositoryException(
          'Failed to mark operation as processing: ${e.toString()}');
    }
  }

  @override
  Future<int> resetOperationsForRetry(List<int> ids) async {
    try {
      return await _syncQueueDao.resetOperationsForRetry(ids);
    } catch (e) {
      throw RepositoryException(
          'Failed to reset operations for retry: ${e.toString()}');
    }
  }

  @override
  Future<List<SyncOperationEntity>> getOperationsReadyForRetry() async {
    try {
      final items = await _syncQueueDao.getOperationsReadyForRetry();
      return items
          .map((item) => SyncOperationModel.fromDatabase(item).toDomainEntity())
          .toList();
    } catch (e) {
      throw RepositoryException(
          'Failed to get operations ready for retry: ${e.toString()}');
    }
  }

  // ==============================================================================
  // CLEANUP OPERATIONS
  // ==============================================================================

  @override
  Future<int> clearCompletedOperations() async {
    try {
      return await _syncQueueDao.clearCompletedOperations();
    } catch (e) {
      throw RepositoryException(
          'Failed to clear completed operations: ${e.toString()}');
    }
  }

  @override
  Future<int> clearAllOperations() async {
    try {
      return await _syncQueueDao.clearAllOperations();
    } catch (e) {
      throw RepositoryException(
          'Failed to clear all operations: ${e.toString()}');
    }
  }

  @override
  Future<int> clearOldCompletedOperations(DateTime olderThan) async {
    try {
      return await _syncQueueDao.clearOldCompletedOperations(olderThan);
    } catch (e) {
      throw RepositoryException(
          'Failed to clear old completed operations: ${e.toString()}');
    }
  }

  @override
  Future<int> clearOperationsForEntity(
    String entityType,
    String entityId,
  ) async {
    try {
      return await _syncQueueDao.clearOperationsForEntity(
          entityType, entityId);
    } catch (e) {
      throw RepositoryException(
          'Failed to clear operations for entity: ${e.toString()}');
    }
  }

  @override
  Future<int> clearOldFailedOperations(DateTime olderThan) async {
    try {
      return await _syncQueueDao.clearOldFailedOperations(olderThan);
    } catch (e) {
      throw RepositoryException(
          'Failed to clear old failed operations: ${e.toString()}');
    }
  }

  // ==============================================================================
  // STATISTICS OPERATIONS
  // ==============================================================================

  @override
  Future<int> countPendingOperations() async {
    try {
      return await _syncQueueDao.countPendingOperations();
    } catch (e) {
      throw RepositoryException(
          'Failed to count pending operations: ${e.toString()}');
    }
  }

  @override
  Future<int> countFailedOperations() async {
    try {
      return await _syncQueueDao.countFailedOperations();
    } catch (e) {
      throw RepositoryException(
          'Failed to count failed operations: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, int>> getQueueStatistics() async {
    try {
      return await _syncQueueDao.getQueueStatistics();
    } catch (e) {
      throw RepositoryException(
          'Failed to get queue statistics: ${e.toString()}');
    }
  }

  @override
  Future<int> getQueueSize() async {
    try {
      final stats = await _syncQueueDao.getQueueStatistics();
      return stats.values.fold(0, (sum, count) => sum + count);
    } catch (e) {
      throw RepositoryException('Failed to get queue size: ${e.toString()}');
    }
  }

  // ==============================================================================
  // UPDATE & DELETE OPERATIONS
  // ==============================================================================

  @override
  Future<int> updateOperation(SyncOperationEntity operation) async {
    try {
      final item = await _syncQueueDao.getOperationById(operation.id);
      if (item == null) {
        throw RepositoryException('Operation not found: ${operation.id}');
      }

      final updatedItem = _entityFromModel(
        SyncOperationModel.fromDatabase(item).copyWith(
          operation: operation.operation,
          data: operation.data,
          priority: operation.priority,
          retryCount: operation.retryCount,
          maxRetries: operation.maxRetries,
          status: operation.status,
          errorMessage: operation.errorMessage,
          version: operation.version,
        ),
      );

      return await _syncQueueDao.updateOperation(updatedItem);
    } catch (e) {
      throw RepositoryException(
          'Failed to update operation: ${e.toString()}');
    }
  }

  @override
  Future<int> deleteOperation(int id) async {
    try {
      return await _syncQueueDao.deleteOperationById(id);
    } catch (e) {
      throw RepositoryException('Failed to delete operation: ${e.toString()}');
    }
  }

  @override
  Future<int> deleteOperations(List<int> ids) async {
    try {
      return await _syncQueueDao.deleteOperationsByIds(ids);
    } catch (e) {
      throw RepositoryException('Failed to delete operations: ${e.toString()}');
    }
  }

  // ==============================================================================
  // PRIVATE HELPER METHODS
  // ==============================================================================

  /// Converts a [SyncOperationEntity] to a [SyncQueueCompanion] for database operations
  SyncQueueCompanion _entityToCompanion(SyncOperationEntity entity) {
    return SyncQueueCompanion(
      entityType: Value(entity.entityType),
      entityId: Value(entity.entityId),
      operation: Value(entity.operation.value),
      data: Value(_encodeData(entity.data)),
      priority: Value(entity.priority.value),
      retryCount: Value(entity.retryCount),
      maxRetries: Value(entity.maxRetries),
      status: Value(entity.status.value),
      errorMessage: Value(entity.errorMessage),
      createdAt: Value(entity.createdAt),
      lastAttemptedAt: Value(entity.lastAttemptedAt),
      completedAt: Value(entity.completedAt),
      version: Value(entity.version),
    );
  }

  /// Converts a [SyncOperationModel] to a [SyncQueueItem] for database operations
  SyncQueueItem _entityFromModel(SyncOperationModel model) {
    return SyncQueueItem(
      id: model.id,
      entityType: model.entityType,
      entityId: model.entityId,
      operation: model.operation.value,
      data: model.dataAsJson,
      priority: model.priority.value,
      retryCount: model.retryCount,
      maxRetries: model.maxRetries,
      status: model.status.value,
      errorMessage: model.errorMessage,
      createdAt: model.createdAt,
      lastAttemptedAt: model.lastAttemptedAt,
      completedAt: model.completedAt,
      version: model.version,
    );
  }

  /// Encodes data map to JSON string for database storage
  String _encodeData(Map<String, dynamic> data) {
    try {
      return SyncOperationModel(data: data).dataAsJson;
    } catch (e) {
      throw RepositoryException('Failed to encode operation data: ${e.toString()}');
    }
  }
}
