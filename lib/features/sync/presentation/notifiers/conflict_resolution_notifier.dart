import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_resolution.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/entities/sync_entity_type.dart';
import 'package:soloadventurer/features/sync/presentation/state/conflict_resolution_state.dart';
import '../../../core/domain/services/logging_service.dart';
import '../providers/conflict_resolution_providers.dart';

part 'conflict_resolution_notifier.g.dart';

/// Notifier for managing conflict resolution state and user interactions
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Uses AsyncNotifier pattern with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - isResolving/errorMessage removed from state (AsyncValue handles them)
/// - Async methods use AsyncValue.guard() for loading/error handling
/// - UI reads state via ref.watch(conflictResolutionProvider)
/// - UI calls methods via ref.read(conflictResolutionProvider.notifier)
@riverpod
class ConflictResolutionNotifier extends _$ConflictResolutionNotifier {
  late LoggingService _logger;

  /// Initialize the notifier with dependencies
  @override
  Future<ConflictResolutionState> build() async {
    // Get dependencies via ref.watch()
    _logger = ref.watch(loggingServiceProvider);

    // Set up cleanup using ref.onDispose()
    ref.onDispose(() {
      // ConflictResolutionNotifier disposed
    });

    // Return initial state directly (AsyncValue wrapping is automatic)
    return ConflictResolutionState.initial();
  }

  /// Set conflicts that need to be resolved
  ///
  /// Called when sync detects conflicts and needs user intervention.
  void setConflicts(List<ConflictInfo> conflicts) {
    final current = state.value ?? ConflictResolutionState.initial();
    state = AsyncData(ConflictResolutionState.withPendingConflicts(conflicts));

    _logger.logStateTransition(
      feature: 'ConflictResolution',
      fromState: current.toString(),
      toState: state.value.toString(),
      metadata: {
        'conflict_count': conflicts.length,
      },
      stackTrace: StackTrace.current,
    );
  }

  /// Start resolving a specific conflict
  ///
  /// Sets the active conflict for the resolution UI.
  void startResolution(ConflictInfo conflict) {
    final current = state.value ?? ConflictResolutionState.initial();
    state = AsyncData(ConflictResolutionState.resolving(conflict));

    _logger.logStateTransition(
      feature: 'ConflictResolution',
      fromState: current.toString(),
      toState: state.value.toString(),
      metadata: {
        'entity_id': conflict.entityId,
      },
      stackTrace: StackTrace.current,
    );
  }

  /// Process user's resolution choice
  ///
  /// Called when user makes a choice in the conflict resolution UI.
  /// Applies the resolution, updates local data, and queues sync operation.
  /// Uses AsyncValue.guard() for loading/error handling.
  Future<void> applyUserChoice({
    required ManualResolutionChoice choice,
    Map<String, dynamic>? customData,
  }) async {
    final current = state.value;
    final conflict = current?.activeConflict;

    if (conflict == null) {
      _logger.logError(
        feature: 'ConflictResolution',
        error: 'No active conflict to resolve',
        code: 'NO_ACTIVE_CONFLICT',
        stackTrace: StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // Get dependencies
      final conflictResolver = ref.read(conflictResolverProvider);
      final syncService = ref.read(syncServiceProvider);

      // Step 1: Resolve conflict using resolver service
      final resolution = await conflictResolver.resolveManually(
        conflict: conflict,
        userChoice: choice,
        customData: customData,
      );

      // Step 2: Apply resolution to local data store
      await _applyResolutionToLocal(resolution);

      // Step 3: Queue sync operation for remote update
      await _queueResolutionOperation(resolution);

      // Step 4: Trigger sync to push resolution to server
      await syncService.processQueue();

      // Return resolved state
      return ConflictResolutionState.resolved(
        conflict: conflict,
        resolution: resolution,
      );
    });

    // Log result
    if (state.hasError) {
      _logger.logError(
        feature: 'ConflictResolution',
        error: state.error.toString(),
        code: 'RESOLUTION_FAILED',
        metadata: {
          'entity_id': conflict.entityId,
          'choice': choice.name,
        },
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Cancel the current resolution
  ///
  /// Called when user dismisses the conflict resolution UI without making a choice.
  void cancelResolution() {
    final current = state.value;
    final conflict = current?.activeConflict;

    if (conflict == null) {
      return;
    }

    state = AsyncData(ConflictResolutionState.cancelled(conflict));

    _logger.logStateTransition(
      feature: 'ConflictResolution',
      fromState: current.toString(),
      toState: state.value.toString(),
      metadata: {
        'entity_id': conflict.entityId,
        'action': 'cancelled',
      },
      stackTrace: StackTrace.current,
    );
  }

  /// Reset the state to initial
  ///
  /// Called after resolution is complete and UI needs to be reset.
  void reset() {
    state = const AsyncData(ConflictResolutionState());
  }

  /// Apply resolution to local data store
  ///
  /// Placeholder for actual data store integration.
  Future<void> _applyResolutionToLocal(
    ConflictResolution resolution,
  ) async {
    // TODO: Integrate with actual data store
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Queue sync operation for remote update
  ///
  /// Creates a sync operation to update the remote server with the resolved data.
  Future<void> _queueResolutionOperation(
    ConflictResolution resolution,
  ) async {
    final syncService = ref.read(syncServiceProvider);

    // Convert entityType string to SyncEntityType enum
    SyncEntityType? entityType;
    try {
      entityType = SyncEntityType.values.firstWhere(
        (e) => e.name == resolution.entityType,
      );
    } catch (_) {
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
  }

  /// Resolve multiple conflicts in batch
  ///
  /// Uses AsyncValue.guard() for loading/error handling.
  Future<void> resolveMultipleConflicts(List<ConflictInfo> conflicts) async {
    if (conflicts.isEmpty) return;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final conflictResolver = ref.read(conflictResolverProvider);
      final syncService = ref.read(syncServiceProvider);

      final result = await conflictResolver.resolveMultipleConflicts(
        conflicts: conflicts,
      );

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

      // Trigger sync if we had any successful resolutions
      if (result.resolutions.isNotEmpty) {
        await syncService.processQueue();
      }

      // Return state with remaining failed conflicts
      return ConflictResolutionState.withPendingConflicts(
        result.failedConflicts,
      );
    });

    if (state.hasError) {
      _logger.logError(
        feature: 'ConflictResolution',
        error: 'Batch resolution failed: ${state.error}',
        code: 'BATCH_RESOLUTION_FAILED',
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Auto-resolve conflicts that can be automatically merged
  Future<void> autoResolveConflicts(List<ConflictInfo> conflicts) async {
    final conflictResolver = ref.read(conflictResolverProvider);

    final autoResolvable = conflicts.where((conflict) {
      return conflictResolver.canMergeAutomatically(conflict: conflict);
    }).toList();

    if (autoResolvable.isEmpty) {
      return;
    }

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
