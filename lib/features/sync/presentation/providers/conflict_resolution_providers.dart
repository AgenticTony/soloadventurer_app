import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/sync/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_service.dart';
import 'package:soloadventurer/features/sync/presentation/notifiers/conflict_resolution_notifier.dart';
import 'package:soloadventurer/features/sync/presentation/state/conflict_resolution_state.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

/// Provider for the conflict resolver service
///
/// This must be overridden in the main app with the actual implementation.
final conflictResolverProvider = Provider<ConflictResolver>((ref) {
  throw UnimplementedError(
    'conflictResolverProvider must be overridden with the actual implementation',
  );
});

/// Provider for the sync service
///
/// This must be overridden in the main app with the actual implementation.
final syncServiceProvider = Provider<SyncService>((ref) {
  throw UnimplementedError(
    'syncServiceProvider must be overridden with the actual implementation',
  );
});

/// Provider for the logging service
///
/// This must be overridden in the main app with the actual implementation.
final loggingServiceProvider = Provider<LoggingService>((ref) {
  throw UnimplementedError(
    'loggingServiceProvider must be overridden with the actual implementation',
  );
});

/// Provider for the conflict resolution notifier
///
/// Manages conflict resolution state and user interactions.
/// Uses AsyncValue pattern for loading, error, and data states.
final conflictResolutionNotifierProvider =
    StateNotifierProvider<ConflictResolutionNotifier,
        AsyncValue<ConflictResolutionState>>((ref) {
  final resolver = ref.watch(conflictResolverProvider);
  final syncService = ref.watch(syncServiceProvider);
  final logger = ref.watch(loggingServiceProvider);

  final notifier = ConflictResolutionNotifier(
    conflictResolver: resolver,
    syncService: syncService,
    logger: logger,
  );

  // Dispose notifier when provider is disposed
  ref.onDispose(() {
    notifier.dispose();
  });

  return notifier;
});

/// Stream provider for conflict resolution state changes
///
/// Provides a stream of state updates for reactive UI.
/// This is useful for widgets that need to react to state changes.
final conflictResolutionStateProvider = StreamProvider<
    AsyncValue<ConflictResolutionState>>((ref) {
  final notifier = ref.watch(conflictResolutionNotifierProvider);
  return notifier.stream;
});

/// Provider for the current conflict resolution state
///
/// Provides direct access to the current state value.
/// Returns null if state is loading or error.
final currentConflictResolutionStateProvider =
    Provider<ConflictResolutionState?>((ref) {
      final asyncState = ref.watch(conflictResolutionNotifierProvider);
      return asyncState.valueOrNull;
    });

/// Provider for pending conflicts count
///
/// Provides the number of conflicts waiting to be resolved.
/// Useful for showing badge counts in UI.
final pendingConflictsCountProvider = Provider<int>((ref) {
  final state = ref.watch(conflictResolutionNotifierProvider).valueOrNull;
  return state?.pendingCount ?? 0;
});

/// Provider for whether there are any conflicts
///
/// Provides a boolean indicating if there are pending or active conflicts.
/// Useful for showing/hiding conflict indicators.
final hasConflictsProvider = Provider<bool>((ref) {
  final state = ref.watch(conflictResolutionNotifierProvider).valueOrNull;
  return state?.hasConflicts ?? false;
});

/// Provider for active conflict
///
/// Provides the conflict currently being resolved, if any.
final activeConflictProvider = Provider<ConflictInfo?>((ref) {
  final state = ref.watch(conflictResolutionNotifierProvider).valueOrNull;
  return state?.activeConflict;
});

/// Provider for resolution result
///
/// Provides the result of the last successful resolution, if any.
final resolutionResultProvider = Provider<ConflictResolution?>((ref) {
  final state = ref.watch(conflictResolutionNotifierProvider).valueOrNull;
  return state?.resolution;
});

/// Provider for conflict resolution status
///
/// Provides a high-level status of conflict resolution:
/// - idle: No conflicts
/// - hasConflicts: Conflicts waiting to be resolved
/// - resolving: Currently resolving a conflict
/// - resolved: Conflict was successfully resolved
/// - failed: Resolution failed
/// - cancelled: User cancelled resolution
enum ConflictResolutionStatus {
  idle,
  hasConflicts,
  resolving,
  resolved,
  failed,
  cancelled,
}

/// Provider for conflict resolution status
///
/// Provides a high-level status enum for easier UI state management.
final conflictResolutionStatusProvider =
    Provider<ConflictResolutionStatus>((ref) {
  final state = ref.watch(conflictResolutionNotifierProvider);
  final value = state.valueOrNull;

  if (value == null) {
    return ConflictResolutionStatus.idle;
  }

  if (state.isLoading) {
    return ConflictResolutionStatus.resolving;
  }

  if (state.hasError) {
    return ConflictResolutionStatus.failed;
  }

  if (value.wasCancelled) {
    return ConflictResolutionStatus.cancelled;
  }

  if (value.isResolved) {
    return ConflictResolutionStatus.resolved;
  }

  if (value.isResolving) {
    return ConflictResolutionStatus.resolving;
  }

  if (value.hasConflicts) {
    return ConflictResolutionStatus.hasConflicts;
  }

  return ConflictResolutionStatus.idle;
});
