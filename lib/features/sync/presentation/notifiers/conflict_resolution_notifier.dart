import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_resolution.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_service.dart';
import 'package:soloadventurer/features/sync/domain/entities/sync_entity_type.dart';
import 'package:soloadventurer/features/sync/presentation/state/conflict_resolution_state.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';
import '../providers/conflict_resolution_providers.dart';

part 'conflict_resolution_notifier.g.dart';

/// Notifier for managing conflict resolution state and user interactions
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - build() method returns ConflictResolutionState directly (not wrapped in AsyncValue)
/// - AsyncValue wrapping is handled automatically by the framework
/// - mounted checks removed (handled automatically by Riverpod 3.0)
/// - Dependencies injected via ref.watch() in build() method
///
/// Handles the complete flow of conflict resolution:
/// 1. Receives conflict detection events
/// 2. Shows resolution UI to user
/// 3. Processes user's resolution choice
/// 4. Applies resolution to local data store
/// 5. Queues sync operations for remote update
/// 6. Updates UI state
@riverpod
class ConflictResolutionNotifier extends _$ConflictResolutionNotifier {
  /// Initialize the notifier with dependencies
  ///
  /// Riverpod 3.0: build() returns the initial state directly (not wrapped in AsyncValue)
  @override
  ConflictResolutionState build() {
    // Get dependencies via ref.watch()
    final conflictResolver = ref.watch(conflictResolverProvider);
    final syncService = ref.watch(syncServiceProvider);
    final logger = ref.watch(loggingServiceProvider);

    // Set up cleanup using ref.onDispose()
    ref.onDispose(() {
      // logger: ConflictResolutionNotifier disposed
    });

    // Return initial state directly (AsyncValue wrapping is automatic)
    return ConflictResolutionState.initial();
  }

  /// Updates state with proper logging
  ///
  /// Riverpod 3.0: AsyncValue wrapping is automatic, just set state directly
  void _updateState(ConflictResolutionState newState) {
    final previousState = state;
    state = newState;

    final logger = ref.read(loggingServiceProvider);
    logger.logStateTransition(
      feature: 'ConflictResolution',
      fromState: previousState.toString(),
      toState: newState.toString(),
      metadata: {
        'has_conflicts': newState.hasConflicts,
        'is_resolved': newState.isResolved,
      },
      stackTrace: StackTrace.current,
    );
  }

  /// Set conflicts that need to be resolved
  ///
  /// Called when sync detects conflicts and needs user intervention.
  void setConflicts(List<ConflictInfo> conflicts) {
    // logger: SetConflicts started

    state = ConflictResolutionState.withPendingConflicts(conflicts);
    _updateState(state);
  }

  /// Start resolving a specific conflict
  ///
  /// Sets the active conflict and marks state as resolving.
  /// Should be called before showing the resolution UI.
  void startResolution(ConflictInfo conflict) {
    final logger = ref.read(loggingServiceProvider);
    // logging commented

    state = ConflictResolutionState.resolving(conflict);
    _updateState(state);
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
    final conflict = state.activeConflict;

    if (conflict == null) {
      final logger = ref.read(loggingServiceProvider);
      logger.logError(
        feature: 'ConflictResolution',
        error: 'No active conflict to resolve',
        code: 'NO_ACTIVE_CONFLICT',
        stackTrace: StackTrace.current,
      );
      return;
    }

    final logger = ref.read(loggingServiceProvider);
    // logging commented

    // Set loading state
    state = state.copyWith(isResolving: true);
    _updateState(state);

    try {
      // Get dependencies
      final conflictResolver = ref.read(conflictResolverProvider);
      final syncService = ref.read(syncServiceProvider);

      // Step 1: Resolve conflict using resolver service
      final resolution = await conflictResolver.resolveManually(
        conflict: conflict,
        userChoice: choice,
        customData: customData,
      );

      // logging commented

      // Step 2: Apply resolution to local data store
      await _applyResolutionToLocal(resolution);

      // Step 3: Queue sync operation for remote update
      await _queueResolutionOperation(resolution);

      // Step 4: Update state to resolved
      state = ConflictResolutionState.resolved(
        conflict: conflict,
        resolution: resolution,
      );
      _updateState(state);

      // Step 5: Trigger sync to push resolution to server
      await syncService.processQueue();
    } on ConflictResolutionException catch (e, stack) {
      final logger = ref.read(loggingServiceProvider);
      final conflict = state.activeConflict;

      logger.logError(
        feature: 'ConflictResolution',
        error: e.message,
        code: e.code,
        metadata: {
          'entity_id': conflict?.entityId,
          'choice': choice.name,
        },
        stackTrace: stack,
      );

      if (conflict != null) {
        state = ConflictResolutionState.failed(
          conflict: conflict,
          errorMessage: e.message,
        );
      }
    } catch (e, stack) {
      final logger = ref.read(loggingServiceProvider);
      final conflict = state.activeConflict;
      final message = 'Failed to apply resolution: ${e.toString()}';

      logger.logError(
        feature: 'ConflictResolution',
        error: message,
        code: 'RESOLUTION_FAILED',
        metadata: {
          'entity_id': conflict?.entityId,
          'choice': choice.name,
        },
        stackTrace: stack,
      );

      if (conflict != null) {
        state = ConflictResolutionState.failed(
          conflict: conflict,
          errorMessage: message,
        );
      }
    }
  }

  /// Cancel the current resolution
  ///
  /// Called when user dismisses the conflict resolution UI without making a choice.
  void cancelResolution() {
    final conflict = state.activeConflict;

    if (conflict == null) {
      final logger = ref.read(loggingServiceProvider);
      // logging commented
      return;
    }

    final logger = ref.read(loggingServiceProvider);
    // logging commented

    state = ConflictResolutionState.cancelled(conflict);
    _updateState(state);
  }

  /// Reset the state to initial
  ///
  /// Called after resolution is complete and UI needs to be reset.
  void reset() {
    final logger = ref.read(loggingServiceProvider);
    // logging commented

    state = ConflictResolutionState.initial();
    _updateState(state);
  }

  /// Apply resolution to local data store
  ///
  /// This is a placeholder for the actual data store integration.
  /// In a real implementation, this would call repository methods to update
  /// the local database/storage with the resolved data.
  Future<void> _applyResolutionToLocal(
    ConflictResolution resolution,
  ) async {
    final logger = ref.read(loggingServiceProvider);
    // logging commented

    // TODO: Integrate with actual data store
    // This would call repository methods like:
    // await _tripRepository.updateTrip(resolution.entityId, resolution.resolvedData);
    // or
    // await _noteRepository.updateNote(resolution.entityId, resolution.resolvedData);

    // For now, we just log that this needs to be implemented
    // logging commented

    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Queue sync operation for remote update
  ///
  /// Creates a sync operation to update the remote server with the resolved data.
  Future<void> _queueResolutionOperation(
    ConflictResolution resolution,
  ) async {
    final logger = ref.read(loggingServiceProvider);
    final syncService = ref.read(syncServiceProvider);

    // logging commented

    // Create sync operation to update remote
    // Convert entityType string to SyncEntityType enum
    SyncEntityType? entityType;
    try {
      entityType = SyncEntityType.values.firstWhere(
        (e) => e.name == resolution.entityType,
      );
    } catch (_) {
      // Fallback if no match found
      entityType = SyncEntityType.travelNote; // Default
    }

    final operation = SyncOperation.update(
      id: resolution.conflictId,
      entityType: entityType,
      entityId: resolution.entityId,
      data: resolution.resolvedData,
      version: resolution.resolvedVersion.version,
    );

    // Add to sync queue
    final added = await syncService.enqueueOperation(operation);

    if (!added) {
      throw ConflictResolutionException(
        message: 'Failed to queue sync operation',
        code: 'QUEUE_FAILED',
      );
    }

    // logging commented
  }

  /// Resolve multiple conflicts in batch
  ///
  /// Uses the conflict resolver's batch resolution capability.
  /// Useful for resolving multiple similar conflicts at once.
  Future<void> resolveMultipleConflicts(List<ConflictInfo> conflicts) async {
    if (conflicts.isEmpty) return;

    final logger = ref.read(loggingServiceProvider);
    // logging commented

    final conflictResolver = ref.read(conflictResolverProvider);
    final syncService = ref.read(syncServiceProvider);

    try {
      final result = await conflictResolver.resolveMultipleConflicts(
        conflicts: conflicts,
      );

      if (!result.isComplete) {
        logger.logError(
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

      // logging commented

      // Update state with results
      state = ConflictResolutionState.withPendingConflicts(
        result.failedConflicts,
      );
      _updateState(state);

      // Trigger sync if we had any successful resolutions
      if (result.resolutions.isNotEmpty) {
        await syncService.processQueue();
      }
    } catch (e, stack) {
      final logger = ref.read(loggingServiceProvider);
      logger.logError(
        feature: 'ConflictResolution',
        error: 'Batch resolution failed: ${e.toString()}',
        code: 'BATCH_RESOLUTION_FAILED',
        stackTrace: stack,
      );

      // Set error state - Riverpod 3.0 will wrap this in AsyncValue automatically
      state = ConflictResolutionState.initial().copyWith(
        errorMessage: 'Batch resolution failed: ${e.toString()}',
      );
    }
  }

  /// Auto-resolve conflicts that can be automatically merged
  ///
  /// Filters conflicts that can be auto-merged and resolves them without user intervention.
  Future<void> autoResolveConflicts(List<ConflictInfo> conflicts) async {
    final conflictResolver = ref.read(conflictResolverProvider);

    final autoResolvable = conflicts.where((conflict) {
      return conflictResolver.canMergeAutomatically(conflict: conflict);
    }).toList();

    if (autoResolvable.isEmpty) {
      final logger = ref.read(loggingServiceProvider);
      // logging commented
      return;
    }

    final logger = ref.read(loggingServiceProvider);
    // logging commented

    await resolveMultipleConflicts(autoResolvable);
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
