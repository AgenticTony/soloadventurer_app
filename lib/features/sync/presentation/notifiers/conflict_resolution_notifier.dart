import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_resolution.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_service.dart';
import 'package:soloadventurer/features/sync/presentation/state/conflict_resolution_state.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

/// Notifier for managing conflict resolution state and user interactions
///
/// Handles the complete flow of conflict resolution:
/// 1. Receives conflict detection events
/// 2. Shows resolution UI to user
/// 3. Processes user's resolution choice
/// 4. Applies resolution to local data store
/// 5. Queues sync operations for remote update
/// 6. Updates UI state
class ConflictResolutionNotifier
    extends StateNotifier<AsyncValue<ConflictResolutionState>> {
  final ConflictResolver _conflictResolver;
  final SyncService _syncService;
  final LoggingService _logger;

  /// Creates a new [ConflictResolutionNotifier]
  ConflictResolutionNotifier({
    required ConflictResolver conflictResolver,
    required SyncService syncService,
    required LoggingService logger,
  })  : _conflictResolver = conflictResolver,
        _syncService = syncService,
        _logger = logger,
        super(const AsyncValue.data(ConflictResolutionState.initial()));

  /// Updates state with proper logging
  void _updateState(AsyncValue<ConflictResolutionState> newState) {
    final previousState = state.valueOrNull;
    state = newState;

    _logger.logStateTransition(
      feature: 'ConflictResolution',
      fromState: previousState.toString(),
      toState: newState.valueOrNull.toString(),
      metadata: {
        'is_loading': newState.isLoading,
        'has_error': newState.hasError,
        'has_conflicts': newState.valueOrNull?.hasConflicts ?? false,
        'is_resolved': newState.valueOrNull?.isResolved ?? false,
      },
      stackTrace: StackTrace.current,
    );
  }

  /// Set conflicts that need to be resolved
  ///
  /// Called when sync detects conflicts and needs user intervention.
  void setConflicts(List<ConflictInfo> conflicts) {
    if (!mounted) return;

    _logger.logSyncEvent(
      event: 'SetConflicts',
      status: 'Started',
      metadata: {
        'conflict_count': conflicts.length,
        'entity_ids': conflicts.map((c) => c.entityId).toList(),
      },
    );

    final newState = AsyncValue.data(
      ConflictResolutionState.withPendingConflicts(conflicts),
    );
    _updateState(newState);
  }

  /// Start resolving a specific conflict
  ///
  /// Sets the active conflict and marks state as resolving.
  /// Should be called before showing the resolution UI.
  void startResolution(ConflictInfo conflict) {
    if (!mounted) return;

    _logger.logSyncEvent(
      event: 'StartResolution',
      status: 'InProgress',
      metadata: {
        'entity_id': conflict.entityId,
        'entity_type': conflict.entityType,
        'conflict_type': conflict.conflictType.name,
      },
    );

    final newState = AsyncValue.data(
      ConflictResolutionState.resolving(conflict),
    );
    _updateState(newState);
  }

  /// Process user's resolution choice
  ///
  /// Called when user makes a choice in the conflict resolution UI.
  /// Applies the resolution, updates local data, and queues sync operation.
  ///
  /// Parameters:
  /// - [choice]: User's resolution choice (keepLocal, keepRemote, customMerge)
  /// - [customData]: Optional custom merged data for customMerge choice
  Future<void> applyUserChoice({
    required ManualResolutionChoice choice,
    Map<String, dynamic>? customData,
  }) async {
    final currentState = state.valueOrNull;
    final conflict = currentState?.activeConflict;

    if (conflict == null) {
      _logger.logError(
        feature: 'ConflictResolution',
        error: 'No active conflict to resolve',
        code: 'NO_ACTIVE_CONFLICT',
        stackTrace: StackTrace.current,
      );
      return;
    }

    if (!mounted) return;

    _logger.logSyncEvent(
      event: 'ApplyUserChoice',
      status: 'InProgress',
      metadata: {
        'entity_id': conflict.entityId,
        'choice': choice.name,
        'has_custom_data': customData != null,
      },
    );

    // Set loading state
    _updateState(AsyncValue.data(currentState.copyWith(isResolving: true)));

    try {
      // Step 1: Resolve conflict using resolver service
      final resolution = await _conflictResolver.resolveManually(
        conflict: conflict,
        userChoice: choice,
        customData: customData,
      );

      if (!mounted) return;

      _logger.logSyncEvent(
        event: 'ApplyUserChoice',
        status: 'Success',
        metadata: {
          'entity_id': conflict.entityId,
          'strategy': resolution.strategy.name,
          'chose_local': resolution.choseLocal,
          'chose_remote': resolution.choseRemote,
          'is_merged': resolution.isMerged,
        },
      );

      // Step 2: Apply resolution to local data store
      await _applyResolutionToLocal(resolution);

      if (!mounted) return;

      // Step 3: Queue sync operation for remote update
      await _queueResolutionOperation(resolution);

      if (!mounted) return;

      // Step 4: Update state to resolved
      final resolvedState = ConflictResolutionState.resolved(
        conflict: conflict,
        resolution: resolution,
      );

      _updateState(AsyncValue.data(resolvedState));

      // Step 5: Trigger sync to push resolution to server
      await _syncService.processQueue();
    } on ConflictResolutionException catch (e, stack) {
      if (!mounted) return;

      _logger.logError(
        feature: 'ConflictResolution',
        error: e.message,
        code: e.code,
        metadata: {
          'entity_id': conflict.entityId,
          'choice': choice.name,
        },
        stackTrace: stack,
      );

      final failedState = ConflictResolutionState.failed(
        conflict: conflict,
        errorMessage: e.message,
      );
      _updateState(AsyncValue.error(e.message, stack));
    } catch (e, stack) {
      if (!mounted) return;

      final message = 'Failed to apply resolution: ${e.toString()}';
      _logger.logError(
        feature: 'ConflictResolution',
        error: message,
        code: 'RESOLUTION_FAILED',
        metadata: {
          'entity_id': conflict.entityId,
          'choice': choice.name,
        },
        stackTrace: stack,
      );

      final failedState = ConflictResolutionState.failed(
        conflict: conflict,
        errorMessage: message,
      );
      _updateState(AsyncValue.error(message, stack));
    }
  }

  /// Cancel the current resolution
  ///
  /// Called when user dismisses the conflict resolution UI without making a choice.
  void cancelResolution() {
    final currentState = state.valueOrNull;
    final conflict = currentState?.activeConflict;

    if (conflict == null) {
      _logger.logSyncEvent(
        event: 'CancelResolution',
        status: 'Skipped',
        metadata: {'reason': 'No active conflict'},
      );
      return;
    }

    if (!mounted) return;

    _logger.logSyncEvent(
      event: 'CancelResolution',
      status: 'Success',
      metadata: {'entity_id': conflict.entityId},
    );

    final cancelledState = ConflictResolutionState.cancelled(conflict);
    _updateState(AsyncValue.data(cancelledState));
  }

  /// Reset the state to initial
  ///
  /// Called after resolution is complete and UI needs to be reset.
  void reset() {
    if (!mounted) return;

    _logger.logSyncEvent(
      event: 'Reset',
      status: 'Success',
    );

    _updateState(const AsyncValue.data(ConflictResolutionState.initial()));
  }

  /// Apply resolution to local data store
  ///
  /// This is a placeholder for the actual data store integration.
  /// In a real implementation, this would call repository methods to update
  /// the local database/storage with the resolved data.
  Future<void> _applyResolutionToLocal(
    ConflictResolution resolution,
  ) async {
    _logger.logSyncEvent(
      event: 'ApplyResolutionToLocal',
      status: 'InProgress',
      metadata: {
        'entity_id': resolution.entityId,
        'entity_type': resolution.entityType,
        'strategy': resolution.strategy.name,
      },
    );

    // TODO: Integrate with actual data store
    // This would call repository methods like:
    // await _tripRepository.updateTrip(resolution.entityId, resolution.resolvedData);
    // or
    // await _noteRepository.updateNote(resolution.entityId, resolution.resolvedData);

    // For now, we just log that this needs to be implemented
    _logger.logSyncEvent(
      event: 'ApplyResolutionToLocal',
      status: 'PendingImplementation',
      metadata: {
        'note': 'Data store integration needed',
        'resolved_data': resolution.resolvedData,
      },
    );

    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Queue sync operation for remote update
  ///
  /// Creates a sync operation to update the remote server with the resolved data.
  Future<void> _queueResolutionOperation(
    ConflictResolution resolution,
  ) async {
    _logger.logSyncEvent(
      event: 'QueueResolutionOperation',
      status: 'InProgress',
      metadata: {
        'entity_id': resolution.entityId,
        'entity_type': resolution.entityType,
      },
    );

    // Create sync operation to update remote
    final operation = SyncOperation.update(
      entityType: resolution.entityType,
      entityId: resolution.entityId,
      data: resolution.resolvedData,
      version: resolution.resolvedVersion.version,
    );

    // Add to sync queue
    final added = await _syncService.enqueueOperation(operation);

    if (!added) {
      throw ConflictResolutionException(
        message: 'Failed to queue sync operation',
        code: 'QUEUE_FAILED',
      );
    }

    _logger.logSyncEvent(
      event: 'QueueResolutionOperation',
      status: 'Success',
      metadata: {
        'operation_id': operation.id,
        'entity_id': resolution.entityId,
      },
    );
  }

  /// Resolve multiple conflicts in batch
  ///
  /// Uses the conflict resolver's batch resolution capability.
  /// Useful for resolving multiple similar conflicts at once.
  Future<void> resolveMultipleConflicts(List<ConflictInfo> conflicts) async {
    if (!mounted) return;
    if (conflicts.isEmpty) return;

    _logger.logSyncEvent(
      event: 'ResolveMultipleConflicts',
      status: 'InProgress',
      metadata: {'conflict_count': conflicts.length},
    );

    _updateState(const AsyncValue.loading());

    try {
      final result = await _conflictResolver.resolveMultipleConflicts(
        conflicts: conflicts,
      );

      if (!mounted) return;

      if (!result.isComplete) {
        _logger.logError(
          feature: 'ConflictResolution',
          error: 'Some conflicts failed to resolve',
          code: 'BATCH_PARTIAL_FAILURE',
          metadata: {
            'total': result.totalConflicts,
            'resolved': result.resolvedCount,
            'failed': result.failedCount,
          },
          stackTrace: StackTrace.current,
        );
      }

      // Apply all successful resolutions
      for (final resolution in result.resolutions) {
        await _applyResolutionToLocal(resolution);
        await _queueResolutionOperation(resolution);
      }

      if (!mounted) return;

      _logger.logSyncEvent(
        event: 'ResolveMultipleConflicts',
        status: 'Success',
        metadata: {
          'total': result.totalConflicts,
          'resolved': result.resolvedCount,
          'failed': result.failedCount,
        },
      );

      // Update state with results
      final newState = ConflictResolutionState.withPendingConflicts(
        result.failedConflicts,
      );
      _updateState(AsyncValue.data(newState));

      // Trigger sync if we had any successful resolutions
      if (result.resolutions.isNotEmpty) {
        await _syncService.processQueue();
      }
    } catch (e, stack) {
      if (!mounted) return;

      _logger.logError(
        feature: 'ConflictResolution',
        error: 'Batch resolution failed: ${e.toString()}',
        code: 'BATCH_RESOLUTION_FAILED',
        stackTrace: stack,
      );

      _updateState(AsyncValue.error(e.toString(), stack));
    }
  }

  /// Auto-resolve conflicts that can be automatically merged
  ///
  /// Filters conflicts that can be auto-merged and resolves them without user intervention.
  Future<void> autoResolveConflicts(List<ConflictInfo> conflicts) async {
    if (!mounted) return;

    final autoResolvable = conflicts.where((conflict) {
      return _conflictResolver.canMergeAutomatically(conflict: conflict);
    }).toList();

    if (autoResolvable.isEmpty) {
      _logger.logSyncEvent(
        event: 'AutoResolveConflicts',
        status: 'Skipped',
        metadata: {'reason': 'No auto-resolvable conflicts'},
      );
      return;
    }

    _logger.logSyncEvent(
      event: 'AutoResolveConflicts',
      status: 'InProgress',
      metadata: {
        'total_conflicts': conflicts.length,
        'auto_resolvable': autoResolvable.length,
      },
    );

    await resolveMultipleConflicts(autoResolvable);
  }

  @override
  void dispose() {
    _logger.logSyncEvent(
      event: 'Dispose',
      status: 'Success',
    );
    super.dispose();
  }
}

/// Exception thrown during conflict resolution
class ConflictResolutionException implements Exception {
  final String message;
  final String code;

  ConflictResolutionException({
    required this.message,
    required this.code,
  });

  @override
  String toString() => 'ConflictResolutionException: $message ($code)';
}
