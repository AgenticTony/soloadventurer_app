import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';
import 'package:soloadventurer/core/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';

/// Result of an intercepted operation
///
/// Contains information about whether the operation was executed
/// immediately, queued for later, or failed.
class InterceptorResult {
  /// Whether the operation was executed immediately (online)
  final bool executedImmediately;

  /// Whether the operation was queued for later sync (offline)
  final bool queued;

  /// Whether the operation failed
  final bool failed;

  /// Error message if the operation failed
  final String? errorMessage;

  /// ID of the queued sync operation (if queued)
  final int? queuedOperationId;

  /// Creates a successful result for immediate execution
  const InterceptorResult.executed()
      : executedImmediately = true,
        queued = false,
        failed = false,
        errorMessage = null,
        queuedOperationId = null;

  /// Creates a result for queued operation
  const InterceptorResult.queued(this.queuedOperationId)
      : executedImmediately = false,
        queued = true,
        failed = false,
        errorMessage = null;

  /// Creates a failed result
  const InterceptorResult.failure(this.errorMessage)
      : executedImmediately = false,
        queued = false,
        failed = true,
        queuedOperationId = null;

  @override
  String toString() {
    if (failed) {
      return 'InterceptorResult.failure(errorMessage: $errorMessage)';
    } else if (queued) {
      return 'InterceptorResult.queued(operationId: $queuedOperationId)';
    } else {
      return 'InterceptorResult.executed()';
    }
  }
}

/// Configuration for offline interception behavior
class InterceptorConfig {
  /// Whether offline mode is enabled
  final bool enabled;

  /// Whether to queue operations when offline
  final bool queueWhenOffline;

  /// Whether to return optimistic responses when offline
  final bool optimisticResponses;

  /// Default priority for queued operations
  final SyncPriority defaultPriority;

  /// Maximum retry attempts for queued operations
  final int maxRetries;

  /// Creates a new [InterceptorConfig]
  const InterceptorConfig({
    this.enabled = true,
    this.queueWhenOffline = true,
    this.optimisticResponses = true,
    this.defaultPriority = SyncPriority.normal,
    this.maxRetries = 3,
  });

  /// Creates a disabled config (offline interception disabled)
  const InterceptorConfig.disabled()
      : enabled = false,
        queueWhenOffline = false,
        optimisticResponses = false,
        defaultPriority = SyncPriority.normal,
        maxRetries = 0;

  /// Default config instance
  static const defaultConfig = InterceptorConfig();
}

/// Callback function type for executing operations
///
/// This callback is invoked when the interceptor decides to execute
/// the operation immediately (when online). It should perform the actual
/// operation (e.g., API call) and return the result.
typedef OperationExecutor<T> = Future<T>;

/// Callback function type for updating local database
///
/// This callback is invoked immediately (whether online or offline) to
/// update the local database. This ensures the UI reflects changes immediately.
typedef LocalUpdateCallback = Future<void>;

/// Interceptor for offline-first operations
///
/// This interceptor captures write operations and decides whether to:
/// 1. Execute immediately if online
/// 2. Queue for later sync if offline
/// 3. Update local database immediately (optimistic UI)
///
/// The interceptor ensures:
/// - Operations are intercepted before execution
/// - Connectivity status is checked
/// - Operations are queued when offline
/// - Local database is updated immediately
/// - Optimistic responses are returned to UI
///
/// Example usage:
/// ```dart
/// final interceptor = OfflineInterceptor(
///   connectivityService: connectivityService,
///   syncQueueService: syncQueueService,
/// );
///
/// final result = await interceptor.interceptOperation(
///   entityType: 'trip',
///   entityId: '123',
///   operation: SyncOperationType.update,
///   data: {'title': 'New Trip'},
///   executor: () async {
///     // Execute the actual operation
///     return await tripRepository.updateTrip(data);
///   },
///   localUpdate: (localData) async {
///     // Update local database immediately
///     await tripDao.updateLocalTrip(localData);
///   },
/// );
/// ```
class OfflineInterceptor {
  /// Connectivity service for checking network status
  final ConnectivityService _connectivityService;

  /// Sync queue service for queueing operations
  final SyncQueueService _syncQueueService;

  /// Configuration for interception behavior
  final InterceptorConfig _config;

  /// Creates a new [OfflineInterceptor]
  ///
  /// [connectivityService] - Service for checking network connectivity
  /// [syncQueueService] - Service for queueing offline operations
  /// [config] - Configuration for interception behavior
  OfflineInterceptor({
    required ConnectivityService connectivityService,
    required SyncQueueService syncQueueService,
    InterceptorConfig config = InterceptorConfig.defaultConfig,
  })  : _connectivityService = connectivityService,
        _syncQueueService = syncQueueService,
        _config = config;

  // ==============================================================================
  // PUBLIC API - OPERATION INTERCEPTION
  // ==============================================================================

  /// Intercepts a write operation and handles it based on connectivity
  ///
  /// The [entityType] parameter is the type of entity (e.g., 'trip', 'journal').
  /// The [entityId] parameter is the ID of the entity.
  /// The [operation] parameter is the type of operation (create, update, delete).
  /// The [data] parameter is the operation payload.
  /// The [executor] callback is invoked to execute the operation when online.
  /// The [localUpdate] callback is invoked to update the local database immediately.
  /// The [priority] parameter is the operation priority (default: from config).
  /// The [maxRetries] parameter is the max retry attempts (default: from config).
  /// The [version] parameter is the entity version for conflict resolution.
  ///
  /// Returns an [InterceptorResult] indicating what happened.
  ///
  /// If offline and queueing is enabled, the operation is queued and
  /// localUpdate is called. The executor is NOT called.
  ///
  /// If online, the executor is called immediately. If it succeeds,
  /// localUpdate is also called to keep the local database in sync.
  Future<InterceptorResult> interceptOperation<T>({
    required String entityType,
    required String entityId,
    required SyncOperationType operation,
    required Map<String, dynamic> data,
    required OperationExecutor<T> executor,
    required LocalUpdateCallback localUpdate,
    SyncPriority? priority,
    int? maxRetries,
    int? version,
  }) async {
    // Check if interception is enabled
    if (!_config.enabled) {
      debugPrint('🔄 Offline interception disabled, executing immediately');
      return await _executeOperation(executor, localUpdate);
    }

    // Check connectivity status
    final connectivityStatus = await _connectivityService.checkConnectivity();
    final isConnected = connectivityStatus.isConnected;

    debugPrint('🔄 Intercepting $operation operation for $entityType:$entityId '
        '(connected: $isConnected)');

    if (isConnected) {
      // Online - execute immediately
      debugPrint('✅ Online - executing operation immediately');
      return await _executeOperation(executor, localUpdate);
    } else {
      // Offline - queue for later
      if (_config.queueWhenOffline) {
        debugPrint('📴 Offline - queueing operation for later sync');
        return await _queueOperation(
          entityType: entityType,
          entityId: entityId,
          operation: operation,
          data: data,
          localUpdate: localUpdate,
          priority: priority ?? _config.defaultPriority,
          maxRetries: maxRetries ?? _config.maxRetries,
          version: version,
        );
      } else {
        // Queueing disabled - fail the operation
        const error = 'Offline and queueing disabled';
        debugPrint('❌ $error');
        return const InterceptorResult.failure(error);
      }
    }
  }

  /// Intercepts multiple operations in a batch
  ///
  /// All operations are either executed (if online) or queued (if offline)
  /// as a batch. This is more efficient than intercepting operations one by one.
  ///
  /// The [operations] parameter is a list of operation specifications.
  /// Each operation is a map containing: entityType, entityId, operation, data,
  /// and optionally priority, maxRetries, and version.
  /// The [executor] callback is invoked for each operation when online.
  /// The [localUpdate] callback is invoked for each operation immediately.
  ///
  /// Returns a list of [InterceptorResult] for each operation.
  Future<List<InterceptorResult>> interceptBatch<T>({
    required List<Map<String, dynamic>> operations,
    required OperationExecutor<T> Function(Map<String, dynamic> op) executor,
    required LocalUpdateCallback Function(Map<String, dynamic> op) localUpdate,
  }) async {
    if (!_config.enabled) {
      debugPrint('🔄 Offline interception disabled, executing batch immediately');
      final results = <InterceptorResult>[];
      for (final op in operations) {
        final result = await _executeOperation(
          executor(op),
          localUpdate(op),
        );
        results.add(result);
      }
      return results;
    }

    // Check connectivity once for the entire batch
    final connectivityStatus = await _connectivityService.checkConnectivity();
    final isConnected = connectivityStatus.isConnected;

    debugPrint('🔄 Intercepting batch of ${operations.length} operations '
        '(connected: $isConnected)');

    final results = <InterceptorResult>[];

    if (isConnected) {
      // Online - execute all operations immediately
      debugPrint('✅ Online - executing batch immediately');
      for (final op in operations) {
        final result = await _executeOperation(
          executor(op),
          localUpdate(op),
        );
        results.add(result);
      }
    } else {
      // Offline - queue all operations
      if (_config.queueWhenOffline) {
        debugPrint('📴 Offline - queueing batch for later sync');
        for (final op in operations) {
          final result = await _queueOperation(
            entityType: op['entityType'] as String,
            entityId: op['entityId'] as String,
            operation: op['operation'] as SyncOperationType,
            data: op['data'] as Map<String, dynamic>,
            localUpdate: localUpdate(op),
            priority: op['priority'] as SyncPriority? ?? _config.defaultPriority,
            maxRetries: op['maxRetries'] as int? ?? _config.maxRetries,
            version: op['version'] as int?,
          );
          results.add(result);
        }
      } else {
        // Queueing disabled - fail all operations
        const error = 'Offline and queueing disabled';
        debugPrint('❌ $error');
        for (int i = 0; i < operations.length; i++) {
          results.add(const InterceptorResult.failure(error));
        }
      }
    }

    return results;
  }

  /// Updates the interceptor configuration
  ///
  /// Use this to change interception behavior at runtime.
  void updateConfig(InterceptorConfig config) {
    // In a real implementation, we might want to make _config mutable
    // or use a different approach. For now, this is a placeholder.
    debugPrint('⚙️ Updating interceptor config (not yet implemented)');
  }

  // ==============================================================================
  // PRIVATE METHODS
  // ==============================================================================

  /// Executes an operation immediately
  ///
  /// Calls the executor to perform the actual operation, then calls
  /// localUpdate to keep the local database in sync.
  Future<InterceptorResult> _executeOperation<T>(
    OperationExecutor<T> executor,
    LocalUpdateCallback localUpdate,
  ) async {
    try {
      // Execute the operation
      await executor();

      // Update local database to keep in sync
      try {
        await localUpdate();
        debugPrint('✅ Local database updated');
      } catch (e) {
        debugPrint('⚠️ Failed to update local database: $e');
        // Don't fail the operation if local update fails
      }

      return const InterceptorResult.executed();
    } catch (e) {
      debugPrint('❌ Operation execution failed: $e');
      return InterceptorResult.failure('Operation failed: $e');
    }
  }

  /// Queues an operation for later sync
  ///
  /// Updates the local database immediately (optimistic) and queues
  /// the operation for sync when connectivity is restored.
  Future<InterceptorResult> _queueOperation({
    required String entityType,
    required String entityId,
    required SyncOperationType operation,
    required Map<String, dynamic> data,
    required LocalUpdateCallback localUpdate,
    required SyncPriority priority,
    required int maxRetries,
    int? version,
  }) async {
    try {
      // Update local database immediately (optimistic)
      await localUpdate();
      debugPrint('✅ Local database updated (optimistic)');

      // Queue the operation for sync
      final result = await _syncQueueService.enqueueOperation(
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        data: data,
        priority: priority,
        maxRetries: maxRetries,
        version: version,
      );

      if (result.success) {
        debugPrint('✅ Operation queued successfully (id: ${result.operationId})');
        return InterceptorResult.queued(result.operationId);
      } else {
        debugPrint('❌ Failed to queue operation: ${result.errorMessage}');
        // Local database was updated, but queuing failed
        // This is a problematic state - the user sees the change but it won't sync
        return InterceptorResult.failure(
          'Local update succeeded but sync queue failed: ${result.errorMessage}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error queuing operation: $e');
      return InterceptorResult.failure('Failed to queue operation: $e');
    }
  }
}
