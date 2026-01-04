import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';

/// State before an optimistic update for rollback purposes
///
/// When an optimistic update is made (e.g., updating a trip title while offline),
/// we store the previous state so we can rollback if the sync fails.
class OptimisticUpdateState {
  /// Entity type (e.g., 'trip', 'journal', 'userProfile')
  final String entityType;

  /// Entity ID
  final String entityId;

  /// Type of operation performed
  final SyncOperationType operation;

  /// Previous state before the optimistic update (for update operations)
  ///
  /// For create operations, this is null (nothing to rollback to)
  /// For update operations, this contains the full previous entity data
  /// For delete operations, this contains the deleted entity data
  final Map<String, dynamic>? previousState;

  /// Sync operation ID in the queue
  final int syncOperationId;

  /// When this optimistic update was created
  final DateTime createdAt;

  /// Creates a new [OptimisticUpdateState]
  const OptimisticUpdateState({
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.previousState,
    required this.syncOperationId,
    required this.createdAt,
  });

  /// Copy with method for immutable updates
  OptimisticUpdateState copyWith({
    String? entityType,
    String? entityId,
    SyncOperationType? operation,
    Map<String, dynamic>? previousState,
    int? syncOperationId,
    DateTime? createdAt,
  }) {
    return OptimisticUpdateState(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      previousState: previousState ?? this.previousState,
      syncOperationId: syncOperationId ?? this.syncOperationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'OptimisticUpdateState(entityType: $entityType, entityId: $entityId, '
        'operation: $operation, syncOperationId: $syncOperationId)';
  }
}

/// Result of a rollback operation
class RollbackResult {
  /// Whether the rollback was successful
  final bool success;

  /// Error message if rollback failed
  final String? errorMessage;

  /// Entity ID that was rolled back
  final String entityId;

  /// Entity type that was rolled back
  final String entityType;

  /// Creates a successful rollback result
  const RollbackResult.success({
    required this.entityId,
    required this.entityType,
  })  : success = true,
        errorMessage = null;

  /// Creates a failed rollback result
  const RollbackResult.failure({
    required this.entityId,
    required this.entityType,
    required this.errorMessage,
  }) : success = false;

  @override
  String toString() {
    if (success) {
      return 'RollbackResult.success(entityType: $entityType, entityId: $entityId)';
    } else {
      return 'RollbackResult.failure(entityType: $entityType, entityId: $entityId, '
          'error: $errorMessage)';
    }
  }
}

/// Configuration for optimistic update handler behavior
class OptimisticUpdateConfig {
  /// Whether to enable automatic rollback on sync failure
  final bool autoRollbackOnFailure;

  /// Maximum age of optimistic updates before auto-cleanup (milliseconds)
  final int maxAgeMs;

  /// Whether to track optimistic updates for debugging
  final bool enableTracking;

  /// Default configuration
  static const defaultConfig = OptimisticUpdateConfig();

  const OptimisticUpdateConfig({
    this.autoRollbackOnFailure = true,
    this.maxAgeMs = 7 * 24 * 60 * 60 * 1000, // 7 days
    this.enableTracking = true,
  });
}

/// Callback function type for performing rollback operations
///
/// This callback is invoked when a rollback needs to be performed.
/// It should restore the entity to its previous state.
typedef RollbackCallback = Future<RollbackResult> Function(
  String entityType,
  String entityId,
  SyncOperationType operation,
  Map<String, dynamic>? previousState,
);

/// Service for managing optimistic UI updates with rollback capability
///
/// This service tracks optimistic updates made while offline and provides
/// rollback functionality when sync operations fail. It integrates with
/// repositories to enable immediate UI feedback with safety nets.
///
/// ## Features
/// - Track pending optimistic updates
/// - Store rollback state for each operation
/// - Perform rollbacks when sync fails
/// - Clean up successfully synced operations
/// - Stream of pending operations for UI monitoring
///
/// ## Usage
/// ```dart
/// // Register an optimistic update
/// await handler.registerOptimisticUpdate(
///   entityType: 'trip',
///   entityId: 'trip_123',
///   operation: SyncOperationType.update,
///   previousState: tripJson, // State before update
///   syncOperationId: 42,
/// );
///
/// // When sync succeeds, clear the optimistic update
/// await handler.clearOptimisticUpdate(syncOperationId: 42);
///
/// // When sync fails, rollback the update
/// final result = await handler.rollbackOperation(
///   syncOperationId: 42,
///   rollbackCallback: myRollbackCallback,
/// );
/// ```
class OptimisticUpdateHandler {
  /// Configuration for handler behavior
  final OptimisticUpdateConfig config;

  /// In-memory storage of pending optimistic updates
  /// Key: syncOperationId, Value: OptimisticUpdateState
  final Map<int, OptimisticUpdateState> _pendingUpdates = {};

  /// Stream controller for emitting updates to pending operations
  final StreamController<Map<int, OptimisticUpdateState>> _pendingUpdatesController =
      StreamController<Map<int, OptimisticUpdateState>>.broadcast();

  /// Creates a new [OptimisticUpdateHandler]
  OptimisticUpdateHandler({
    this.config = OptimisticUpdateConfig.defaultConfig,
  });

  // ==============================================================================
  // PUBLIC API - Register and manage optimistic updates
  // ==============================================================================

  /// Register an optimistic update for tracking
  ///
  /// [entityType] - Type of entity (e.g., 'trip', 'journal')
  /// [entityId] - ID of the entity
  /// [operation] - Type of operation performed
  /// [previousState] - State before the optimistic update (for rollback)
  /// [syncOperationId] - ID of the sync operation in the queue
  ///
  /// Returns the registered [OptimisticUpdateState].
  Future<OptimisticUpdateState> registerOptimisticUpdate({
    required String entityType,
    required String entityId,
    required SyncOperationType operation,
    required Map<String, dynamic>? previousState,
    required int syncOperationId,
  }) async {
    final state = OptimisticUpdateState(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      previousState: previousState,
      syncOperationId: syncOperationId,
      createdAt: DateTime.now(),
    );

    _pendingUpdates[syncOperationId] = state;
    _emitPendingUpdates();

    if (config.enableTracking) {
      debugPrint('✅ Registered optimistic update: $state');
    }

    return state;
  }

  /// Get an optimistic update state by sync operation ID
  ///
  /// Returns null if the operation is not being tracked.
  OptimisticUpdateState? getOptimisticUpdate(int syncOperationId) {
    return _pendingUpdates[syncOperationId];
  }

  /// Get all pending optimistic updates
  Map<int, OptimisticUpdateState> getPendingUpdates() {
    return Map.unmodifiable(_pendingUpdates);
  }

  /// Stream of pending optimistic updates
  ///
  /// Emits the current map of pending updates whenever it changes.
  /// Useful for UI components that need to show pending operation indicators.
  Stream<Map<int, OptimisticUpdateState>> get pendingUpdatesStream =>
      _pendingUpdatesController.stream;

  /// Get count of pending optimistic updates
  int get pendingCount => _pendingUpdates.length;

  /// Check if an entity has a pending optimistic update
  bool hasPendingUpdate(String entityType, String entityId) {
    return _pendingUpdates.values.any(
      (state) => state.entityType == entityType && state.entityId == entityId,
    );
  }

  /// Get all pending updates for a specific entity
  List<OptimisticUpdateState> getPendingUpdatesForEntity(
    String entityType,
    String entityId,
  ) {
    return _pendingUpdates.values
        .where((state) =>
            state.entityType == entityType && state.entityId == entityId)
        .toList();
  }

  // ==============================================================================
  // ROLLBACK OPERATIONS
  // ==============================================================================

  /// Rollback a failed optimistic update
  ///
  /// [syncOperationId] - ID of the sync operation that failed
  /// [rollbackCallback] - Callback function to perform the actual rollback
  ///
  /// Returns [RollbackResult] indicating success or failure.
  ///
  /// The callback should restore the entity to its previous state.
  /// For example, for a trip update, it would write the previous trip data
  /// back to the local database.
  Future<RollbackResult> rollbackOperation({
    required int syncOperationId,
    required RollbackCallback rollbackCallback,
  }) async {
    final state = _pendingUpdates[syncOperationId];
    if (state == null) {
      debugPrint('⚠️ No optimistic update found for operation #$syncOperationId');
      return RollbackResult.failure(
        entityId: '',
        entityType: '',
        errorMessage: 'Optimistic update not found',
      );
    }

    try {
      if (config.enableTracking) {
        debugPrint('🔄 Rolling back optimistic update: $state');
      }

      // Perform the rollback via callback
      final result = await rollbackCallback(
        state.entityType,
        state.entityId,
        state.operation,
        state.previousState,
      );

      // Remove from tracking if rollback succeeded
      if (result.success) {
        _pendingUpdates.remove(syncOperationId);
        _emitPendingUpdates();
        debugPrint('✅ Rollback successful for ${state.entityType}:${state.entityId}');
      } else {
        debugPrint('❌ Rollback failed for ${state.entityType}:${state.entityId}: '
            '${result.errorMessage}');
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error during rollback: ${e.toString()}');
      return RollbackResult.failure(
        entityId: state.entityId,
        entityType: state.entityType,
        errorMessage: e.toString(),
      );
    }
  }

  /// Rollback all failed operations
  ///
  /// [rollbackCallback] - Callback function to perform the actual rollbacks
  ///
  /// Returns a list of rollback results for each operation.
  Future<List<RollbackResult>> rollbackAllOperations({
    required RollbackCallback rollbackCallback,
  }) async {
    final results = <RollbackResult>[];
    final operationIds = _pendingUpdates.keys.toList();

    debugPrint('🔄 Rolling back ${operationIds.length} optimistic updates');

    for (final syncOperationId in operationIds) {
      final result = await rollbackOperation(
        syncOperationId: syncOperationId,
        rollbackCallback: rollbackCallback,
      );
      results.add(result);
    }

    final successCount = results.where((r) => r.success).length;
    debugPrint('✅ Rollback complete: $successCount/${results.length} successful');

    return results;
  }

  /// Rollback all operations for a specific entity
  ///
  /// Useful when an entity fails to sync completely and all its
  /// optimistic updates need to be reverted.
  Future<List<RollbackResult>> rollbackOperationsForEntity({
    required String entityType,
    required String entityId,
    required RollbackCallback rollbackCallback,
  }) async {
    final states = getPendingUpdatesForEntity(entityType, entityId);
    final results = <RollbackResult>[];

    debugPrint('🔄 Rolling back ${states.length} updates for '
        '$entityType:$entityId');

    for (final state in states) {
      final result = await rollbackOperation(
        syncOperationId: state.syncOperationId,
        rollbackCallback: rollbackCallback,
      );
      results.add(result);
    }

    return results;
  }

  // ==============================================================================
  // CLEANUP OPERATIONS
  // ==============================================================================

  /// Clear a successful optimistic update from tracking
  ///
  /// Call this when a sync operation completes successfully.
  void clearOptimisticUpdate({required int syncOperationId}) {
    final removed = _pendingUpdates.remove(syncOperationId);
    if (removed != null && config.enableTracking) {
      debugPrint('🧹 Cleared optimistic update: $removed');
    }
    _emitPendingUpdates();
  }

  /// Clear all optimistic updates for a specific entity
  ///
  /// Useful when an entity syncs successfully and all its
  /// pending optimistic updates can be cleared.
  void clearOptimisticUpdatesForEntity({
    required String entityType,
    required String entityId,
  }) {
    final keysToRemove = _pendingUpdates.entries
        .where((entry) =>
            entry.value.entityType == entityType &&
            entry.value.entityId == entityId)
        .map((entry) => entry.key)
        .toList();

    for (final key in keysToRemove) {
      _pendingUpdates.remove(key);
    }

    if (keysToRemove.isNotEmpty && config.enableTracking) {
      debugPrint('🧹 Cleared $keysToRemove optimistic updates for '
          '$entityType:$entityId');
    }
    _emitPendingUpdates();
  }

  /// Clear all optimistic updates
  ///
  /// Useful for cleanup during app shutdown or when resetting sync state.
  void clearAllOptimisticUpdates() {
    final count = _pendingUpdates.length;
    _pendingUpdates.clear();
    if (count > 0 && config.enableTracking) {
      debugPrint('🧹 Cleared all $count optimistic updates');
    }
    _emitPendingUpdates();
  }

  /// Clean up old optimistic updates
  ///
  /// Removes optimistic updates older than [maxAgeMs].
  /// Useful for periodic cleanup to prevent memory leaks.
  ///
  /// Returns the number of updates cleaned up.
  Future<int> cleanupOldUpdates({int? maxAgeMs}) async {
    final maxAge = maxAgeMs ?? config.maxAgeMs;
    final cutoffTime = DateTime.now().subtract(Duration(milliseconds: maxAge));
    final keysToRemove = <int>[];

    for (final entry in _pendingUpdates.entries) {
      if (entry.value.createdAt.isBefore(cutoffTime)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _pendingUpdates.remove(key);
    }

    if (keysToRemove.isNotEmpty && config.enableTracking) {
      debugPrint('🧹 Cleaned up ${keysToRemove.length} old optimistic updates '
          '(older than ${maxAge}ms)');
    }
    _emitPendingUpdates();

    return keysToRemove.length;
  }

  // ==============================================================================
  // STREAM MANAGEMENT
  // ==============================================================================

  /// Emit current pending updates to stream
  void _emitPendingUpdates() {
    if (!_pendingUpdatesController.isClosed) {
      _pendingUpdatesController.add(Map.unmodifiable(_pendingUpdates));
    }
  }

  // ==============================================================================
  // LIFECYCLE
  // ==============================================================================

  /// Dispose resources
  ///
  /// Call this when the handler is no longer needed to prevent memory leaks.
  void dispose() {
    _pendingUpdatesController.close();
    _pendingUpdates.clear();
    if (config.enableTracking) {
      debugPrint('🗑️ OptimisticUpdateHandler disposed');
    }
  }
}
