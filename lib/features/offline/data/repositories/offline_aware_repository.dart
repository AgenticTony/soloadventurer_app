import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/offline/data/models/sync_operation_model.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';
import 'package:soloadventurer/features/offline/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';

/// Result of an offline-aware repository operation
///
/// Contains the result data along with sync status information.
class RepositoryOperationResult<T> {
  /// The result data from the operation
  final T data;

  /// Whether the operation was executed immediately or queued for sync
  final bool executedImmediately;

  /// Whether the operation is queued for sync (only meaningful if executedImmediately is false)
  final bool isQueuedForSync;

  /// ID of the sync operation if queued (null if executed immediately)
  final int? syncOperationId;

  /// Creates a result for an immediately executed operation
  const RepositoryOperationResult.immediate(this.data)
      : executedImmediately = true,
        isQueuedForSync = false,
        syncOperationId = null;

  /// Creates a result for a queued operation
  const RepositoryOperationResult.queued(
    this.data, {
    this.syncOperationId,
  })  : executedImmediately = false,
        isQueuedForSync = true;

  @override
  String toString() {
    if (executedImmediately) {
      return 'RepositoryOperationResult.immediate(data: $data)';
    } else {
      return 'RepositoryOperationResult.queued(data: $data, '
          'syncOperationId: $syncOperationId)';
    }
  }
}

/// Configuration for offline-aware repository behavior
class OfflineRepositoryConfig {
  /// Whether to enable offline mode (if false, operations will fail when offline)
  final bool enableOfflineMode;

  /// Whether to queue mutations for sync when offline
  final bool queueWhenOffline;

  /// Whether to return optimistic responses when queuing operations
  final bool returnOptimisticResponse;

  /// Default sync priority for queued operations
  final SyncPriority defaultSyncPriority;

  /// Maximum number of retries for failed sync operations
  final int maxSyncRetries;

  /// Whether to automatically trigger sync when connection is restored
  final bool autoSyncOnConnectionRestored;

  const OfflineRepositoryConfig({
    this.enableOfflineMode = true,
    this.queueWhenOffline = true,
    this.returnOptimisticResponse = true,
    this.defaultSyncPriority = SyncPriority.normal,
    this.maxSyncRetries = 3,
    this.autoSyncOnConnectionRestored = true,
  });

  /// Default configuration
  static const defaultConfig = OfflineRepositoryConfig();
}

/// Abstract base repository with offline-first logic
///
/// This class provides common offline-first functionality for all repositories,
/// including:
/// - Reading from local database first
/// - Writing to local database immediately
/// - Queueing mutations for sync when offline
/// - Fallback to API when local data is unavailable
///
/// Subclasses should implement the abstract methods to provide entity-specific
/// behavior while inheriting the offline-first orchestration logic.
///
/// Type parameters:
/// - [Entity]: The domain entity type (e.g., Trip, Journal, Profile)
/// - [Model]: The local data model type (e.g., LocalTripModel, LocalJournalModel)
/// - [CreateModel]: The model type for create operations (optional, defaults to Model)
/// - [UpdateModel]: The model type for update operations (optional, defaults to Model)
abstract class OfflineAwareRepository<Entity, Model,
    CreateModel extends Model, UpdateModel extends Model> {
  /// Connectivity service for checking network status
  final ConnectivityService _connectivityService;

  /// Sync queue service for queuing offline operations
  final SyncQueueService _syncQueueService;

  /// Configuration for repository behavior
  final OfflineRepositoryConfig config;

  /// Creates a new [OfflineAwareRepository]
  ///
  /// Subclasses should receive their dependencies via constructor injection
  /// and pass them to this constructor using super(params).
  OfflineAwareRepository({
    required ConnectivityService connectivityService,
    required SyncQueueService syncQueueService,
    this.config = OfflineRepositoryConfig.defaultConfig,
  })  : _connectivityService = connectivityService,
        _syncQueueService = syncQueueService;

  // ==============================================================================
  // ABSTRACT METHODS - Must be implemented by subclasses
  // ==============================================================================

  /// Get the entity type name for sync operations (e.g., 'trip', 'journal', 'userProfile')
  String get entityType;

  /// Convert a domain entity to a local model for database storage
  Model entityToModel(Entity entity);

  /// Convert a local model to a domain entity
  Entity modelToEntity(Model model);

  /// Get entity ID from a domain entity
  String getEntityId(Entity entity);

  /// Get entity ID from a local model
  String getModelId(Model model);

  /// Read entity from local database by ID
  Future<Model?> readFromLocal(String id);

  /// Write entity to local database
  Future<Model> writeToLocal(Model model);

  /// Delete entity from local database by ID
  Future<void> deleteFromLocal(String id);

  /// Read all entities from local database (with optional user filter)
  Future<List<Model>> readAllFromLocal({String? userId});

  /// Execute create operation on remote API
  Future<Entity> executeRemoteCreate(CreateModel model);

  /// Execute update operation on remote API
  Future<Entity> executeRemoteUpdate(String id, UpdateModel model);

  /// Execute delete operation on remote API
  Future<void> executeRemoteDelete(String id);

  /// Execute fetch operation on remote API (get single entity)
  Future<Entity> executeRemoteFetch(String id);

  /// Execute fetch all operation on remote API (get list of entities)
  Future<List<Entity>> executeRemoteFetchAll({String? userId});

  // ==============================================================================
  // READ OPERATIONS - Read from local first, fallback to remote
  // ==============================================================================

  /// Get a single entity by ID
  ///
  /// Strategy:
  /// 1. Try to read from local database
  /// 2. If local data exists and is synced, return it
  /// 3. If online, try to fetch from remote and update local cache
  /// 4. If offline and local data is unavailable, throw exception
  Future<Entity> getById(String id) async {
    try {
      // Step 1: Try local database first
      final localModel = await readFromLocal(id);
      if (localModel != null) {
        final entity = modelToEntity(localModel);
        debugPrint('📦 $entityType: Retrieved from local cache: $id');

        // If local data is synced, we can trust it
        // If it has pending changes, we still return it (optimistic)
        return entity;
      }

      // Step 2: Local data not available, check connectivity
      final isConnected = await _connectivityService.checkConnectivity();

      if (!isConnected.isConnected) {
        if (config.enableOfflineMode) {
          throw CacheException(
            message: '$entityType not available offline and not in local cache',
          );
        } else {
          throw NetworkConnectivityException(
            message: 'No network connection and offline mode disabled',
          );
        }
      }

      // Step 3: Fetch from remote API
      debugPrint('🌐 $entityType: Fetching from remote API: $id');
      final remoteEntity = await executeRemoteFetch(id);

      // Step 4: Cache the fetched entity locally
      final model = entityToModel(remoteEntity);
      await writeToLocal(model);

      return remoteEntity;
    } on AppException catch (e) {
      debugPrint('❌ $entityType: Error in getById: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ $entityType: Unexpected error in getById: ${e.toString()}');
      throw UnknownException(message: e.toString());
    }
  }

  /// Get all entities (optionally filtered by user ID)
  ///
  /// Strategy:
  /// 1. Try to read all from local database
  /// 2. If local data exists, return it
  /// 3. If online, try to fetch from remote and update local cache
  /// 4. If offline and local data is unavailable, throw exception
  Future<List<Entity>> getAll({String? userId}) async {
    try {
      // Step 1: Try local database first
      final localModels = await readAllFromLocal(userId: userId);

      if (localModels.isNotEmpty) {
        final entities = localModels.map(modelToEntity).toList();
        debugPrint(
            '📦 $entityType: Retrieved ${entities.length} from local cache');
        return entities;
      }

      // Step 2: Local data not available, check connectivity
      final isConnected = await _connectivityService.checkConnectivity();

      if (!isConnected.isConnected) {
        if (config.enableOfflineMode) {
          throw CacheException(
            message: '$entityType data not available offline',
          );
        } else {
          throw NetworkConnectivityException(
            message: 'No network connection and offline mode disabled',
          );
        }
      }

      // Step 3: Fetch from remote API
      debugPrint('🌐 $entityType: Fetching all from remote API');
      final remoteEntities = await executeRemoteFetchAll(userId: userId);

      // Step 4: Cache the fetched entities locally
      for (final entity in remoteEntities) {
        final model = entityToModel(entity);
        try {
          await writeToLocal(model);
        } catch (e) {
          debugPrint('⚠️ $entityType: Failed to cache entity: $e');
        }
      }

      return remoteEntities;
    } on AppException catch (e) {
      debugPrint('❌ $entityType: Error in getAll: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ $entityType: Unexpected error in getAll: ${e.toString()}');
      throw UnknownException(message: e.toString());
    }
  }

  // ==============================================================================
  // WRITE OPERATIONS - Write locally first, queue for sync if offline
  // ==============================================================================

  /// Create a new entity
  ///
  /// Strategy:
  /// 1. Write to local database immediately (with temporary ID if needed)
  /// 2. If online, execute remote operation immediately
  /// 3. If offline, queue for sync and return optimistic response
  Future<RepositoryOperationResult<Entity>> create(CreateModel model) async {
    try {
      // Step 1: Generate temporary ID if needed (for optimistic updates)
      final tempId = _generateTemporaryId();

      // Step 2: Write to local database immediately
      debugPrint('📝 $entityType: Writing to local database: $tempId');
      final localModel = await _writeModelWithId(model, tempId);

      // Step 3: Check connectivity
      final isConnected = await _connectivityService.checkConnectivity();

      if (isConnected.isConnected) {
        // Online: Execute remote operation immediately
        debugPrint('🌐 $entityType: Online, creating on remote API');
        try {
          final remoteEntity = await executeRemoteCreate(localModel as CreateModel);

          // Update local database with server-assigned ID and data
          final updatedModel = entityToModel(remoteEntity);
          await writeToLocal(updatedModel);

          return RepositoryOperationResult.immediate(remoteEntity);
        } on AppException catch (e) {
          // Remote operation failed, but we have local data
          debugPrint('⚠️ $entityType: Remote create failed: ${e.message}');
          if (config.queueWhenOffline) {
            await _queueOperation(
              entityType: entityType,
              entityId: tempId,
              operation: SyncOperationType.create,
              data: _modelToJson(localModel),
            );
          }
          // Return optimistic response
          final entity = modelToEntity(localModel);
          return RepositoryOperationResult.queued(entity);
        }
      } else {
        // Offline: Queue for sync
        debugPrint('📴 $entityType: Offline, queuing for sync');
        if (config.queueWhenOffline) {
          await _queueOperation(
            entityType: entityType,
            entityId: tempId,
            operation: SyncOperationType.create,
            data: _modelToJson(localModel),
          );
        }

        // Return optimistic response
        final entity = modelToEntity(localModel);
        return RepositoryOperationResult.queued(entity);
      }
    } on AppException catch (e) {
      debugPrint('❌ $entityType: Error in create: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ $entityType: Unexpected error in create: ${e.toString()}');
      throw UnknownException(message: e.toString());
    }
  }

  /// Update an existing entity
  ///
  /// Strategy:
  /// 1. Write to local database immediately
  /// 2. If online, execute remote operation immediately
  /// 3. If offline, queue for sync and return optimistic response
  Future<RepositoryOperationResult<Entity>> update(
    String id,
    UpdateModel model,
  ) async {
    try {
      // Step 1: Write to local database immediately
      debugPrint('📝 $entityType: Writing update to local database: $id');
      final localModel = await _writeModelWithId(model, id);

      // Step 2: Check connectivity
      final isConnected = await _connectivityService.checkConnectivity();

      if (isConnected.isConnected) {
        // Online: Execute remote operation immediately
        debugPrint('🌐 $entityType: Online, updating on remote API: $id');
        try {
          final remoteEntity = await executeRemoteUpdate(id, localModel as UpdateModel);

          // Update local database with server response
          final updatedModel = entityToModel(remoteEntity);
          await writeToLocal(updatedModel);

          return RepositoryOperationResult.immediate(remoteEntity);
        } on AppException catch (e) {
          // Remote operation failed, but we have local data
          debugPrint('⚠️ $entityType: Remote update failed: ${e.message}');
          if (config.queueWhenOffline) {
            await _queueOperation(
              entityType: entityType,
              entityId: id,
              operation: SyncOperationType.update,
              data: _modelToJson(localModel),
            );
          }
          // Return optimistic response
          final entity = modelToEntity(localModel);
          return RepositoryOperationResult.queued(entity);
        }
      } else {
        // Offline: Queue for sync
        debugPrint('📴 $entityType: Offline, queuing update for sync: $id');
        if (config.queueWhenOffline) {
          await _queueOperation(
            entityType: entityType,
            entityId: id,
            operation: SyncOperationType.update,
            data: _modelToJson(localModel),
          );
        }

        // Return optimistic response
        final entity = modelToEntity(localModel);
        return RepositoryOperationResult.queued(entity);
      }
    } on AppException catch (e) {
      debugPrint('❌ $entityType: Error in update: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ $entityType: Unexpected error in update: ${e.toString()}');
      throw UnknownException(message: e.toString());
    }
  }

  /// Delete an entity
  ///
  /// Strategy:
  /// 1. Mark as deleted in local database (soft delete)
  /// 2. If online, execute remote operation immediately
  /// 3. If offline, queue for sync
  Future<RepositoryOperationResult<void>> delete(String id) async {
    try {
      // Step 1: Soft delete in local database immediately
      debugPrint('📝 $entityType: Soft deleting in local database: $id');
      await deleteFromLocal(id);

      // Step 2: Check connectivity
      final isConnected = await _connectivityService.checkConnectivity();

      if (isConnected.isConnected) {
        // Online: Execute remote operation immediately
        debugPrint('🌐 $entityType: Online, deleting on remote API: $id');
        try {
          await executeRemoteDelete(id);
          return RepositoryOperationResult.immediate(null);
        } on AppException catch (e) {
          // Remote operation failed, but we have local deletion
          debugPrint('⚠️ $entityType: Remote delete failed: ${e.message}');
          if (config.queueWhenOffline) {
            await _queueOperation(
              entityType: entityType,
              entityId: id,
              operation: SyncOperationType.delete,
              data: {'id': id},
            );
          }
          // Return queued result
          return RepositoryOperationResult.queued(null);
        }
      } else {
        // Offline: Queue for sync
        debugPrint('📴 $entityType: Offline, queuing deletion for sync: $id');
        if (config.queueWhenOffline) {
          await _queueOperation(
            entityType: entityType,
            entityId: id,
            operation: SyncOperationType.delete,
            data: {'id': id},
          );
        }

        // Return queued result
        return RepositoryOperationResult.queued(null);
      }
    } on AppException catch (e) {
      debugPrint('❌ $entityType: Error in delete: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ $entityType: Unexpected error in delete: ${e.toString()}');
      throw UnknownException(message: e.toString());
    }
  }

  // ==============================================================================
  // HELPER METHODS - Internal utilities
  // ==============================================================================

  /// Generate a temporary ID for new entities
  String _generateTemporaryId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'temp_$timestamp_$random';
  }

  /// Write model to local database with specified ID
  ///
  /// This is a helper that subclasses can override if they need custom ID handling
  Future<Model> _writeModelWithId(Model model, String id) async {
    // Default implementation just calls writeToLocal
    // Subclasses can override if they need to inject the ID
    return writeToLocal(model);
  }

  /// Convert model to JSON for sync queue storage
  Map<String, dynamic> _modelToJson(Model model) {
    // Default implementation uses toString
    // Subclasses should override this to provide proper serialization
    if (model is Map<String, dynamic>) {
      return model as Map<String, dynamic>;
    }
    throw UnimplementedError(
      '_modelToJson must be implemented by $entityType repository',
    );
  }

  /// Queue an operation for sync
  Future<void> _queueOperation({
    required String entityType,
    required String entityId,
    required SyncOperationType operation,
    required Map<String, dynamic> data,
  }) async {
    final syncOperation = SyncOperationEntity(
      id: 0, // Will be assigned by database
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      data: data,
      priority: config.defaultSyncPriority,
      retryCount: 0,
      maxRetries: config.maxSyncRetries,
      status: SyncOperationStatus.pending,
      errorMessage: null,
      createdAt: DateTime.now(),
      lastAttemptedAt: null,
      completedAt: null,
      version: 1,
    );

    final result = await _syncQueueService.enqueueOperation(syncOperation);
    debugPrint('📋 $entityType: Queued operation #$result.operationId '
        'for $operation on $entityId');
  }

  /// Check if currently online
  Future<bool> get isOnline async {
    final status = await _connectivityService.checkConnectivity();
    return status.isConnected;
  }

  /// Check if currently offline
  Future<bool> get isOffline async {
    return !(await isOnline);
  }
}
