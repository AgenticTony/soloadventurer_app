import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/sync/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_service.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_resolution.dart';
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

/// Provider for the current conflict resolution state (unwrapped from AsyncValue)
///
/// Provides direct access to the current state, or null if loading/error.
/// Use conflictResolutionProvider directly for full AsyncValue handling.
final currentConflictResolutionStateProvider =
    Provider<ConflictResolutionState?>((ref) {
      return ref.watch(conflictResolutionProvider).value;
    });

/// Provider for pending conflicts count
final pendingConflictsCountProvider = Provider<int>((ref) {
  return ref.watch(conflictResolutionProvider).value?.pendingConflicts.length ?? 0;
});

/// Provider for whether there are any conflicts
final hasConflictsProvider = Provider<bool>((ref) {
  return ref.watch(conflictResolutionProvider).value?.hasConflicts ?? false;
});

/// Provider for active conflict
final activeConflictProvider = Provider<ConflictInfo?>((ref) {
  return ref.watch(conflictResolutionProvider).value?.activeConflict;
});

/// Provider for resolution result
final resolutionResultProvider = Provider<ConflictResolution?>((ref) {
  return ref.watch(conflictResolutionProvider).value?.resolution;
});

/// Provider for conflict resolution status
enum ConflictResolutionStatus {
  idle,
  hasConflicts,
  resolving,
  resolved,
  failed,
  cancelled,
}

/// Provider for conflict resolution status
final conflictResolutionStatusProvider =
    Provider<ConflictResolutionStatus>((ref) {
      final asyncState = ref.watch(conflictResolutionProvider);

      // Loading means resolving
      if (asyncState.isLoading) {
        return ConflictResolutionStatus.resolving;
      }

      // Error means failed
      if (asyncState.hasError) {
        return ConflictResolutionStatus.failed;
      }

      final state = asyncState.value;
      if (state == null) return ConflictResolutionStatus.idle;

      if (state.wasCancelled) {
        return ConflictResolutionStatus.cancelled;
      }

      if (state.isResolved) {
        return ConflictResolutionStatus.resolved;
      }

      if (state.hasConflicts) {
        return ConflictResolutionStatus.hasConflicts;
      }

      return ConflictResolutionStatus.idle;
    });
