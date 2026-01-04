import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/sync_service.dart';
import '../notifiers/manual_sync_notifier.dart';
import '../state/manual_sync_state.dart';
import '../../../core/domain/services/logging_service.dart';

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

/// Provider for the manual sync notifier
///
/// Manages manual sync state and operations.
/// Uses AsyncValue pattern for loading, error, and data states.
final manualSyncNotifierProvider =
    StateNotifierProvider<ManualSyncNotifier, ManualSyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final logger = ref.watch(loggingServiceProvider);

  final notifier = ManualSyncNotifier(
    syncService: syncService,
    logger: logger,
  );

  // Dispose notifier when provider is disposed
  ref.onDispose(() {
    notifier.dispose();
  });

  return notifier;
});

/// Provider for current manual sync state
///
/// Provides direct access to the current manual sync state.
final manualSyncStateProvider = Provider<ManualSyncState>((ref) {
  return ref.watch(manualSyncNotifierProvider);
});

/// Provider for whether a manual sync is in progress
///
/// Provides a boolean indicating if sync is currently running.
/// Useful for showing loading indicators and disabling sync buttons.
final isSyncingProvider = Provider<bool>((ref) {
  final state = ref.watch(manualSyncNotifierProvider);
  return state.isSyncing;
});

/// Provider for last manual sync success status
///
/// Provides the success status of the last manual sync.
/// Returns null if no sync has been performed yet.
final lastSyncSuccessProvider = Provider<bool?>((ref) {
  final state = ref.watch(manualSyncNotifierProvider);
  return state.lastSyncSuccess;
});

/// Provider for sync status
///
/// Provides the current sync status from the manual sync state.
final syncStatusProvider = Provider<SyncStatus>((ref) {
  final state = ref.watch(manualSyncNotifierProvider);
  return state.status;
});

/// Provider for sync result summary
///
/// Provides a formatted string summary of the last sync result.
/// Useful for displaying sync results to users.
final syncResultSummaryProvider = Provider<String?>((ref) {
  final state = ref.watch(manualSyncNotifierProvider);

  if (!state.hasResults) {
    return null;
  }

  if (state.lastSyncSuccess == true) {
    if (state.failureCount == 0) {
      return 'Successfully synced ${state.successCount} ${_pluralize('item', state.successCount)}';
    } else {
      return 'Synced ${state.successCount} ${_pluralize('item', state.successCount)}, '
             '${state.failureCount} ${_pluralize('failure', state.failureCount)}';
    }
  } else if (state.lastSyncSuccess == false) {
    return 'Sync failed: ${state.errorMessage ?? "Unknown error"}';
  }

  return null;
});

/// Provider for pending operations count
///
/// Provides the number of operations currently in the sync queue.
final pendingOperationsCountProvider = Provider<int>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.queueSize;
});

/// Provider for whether there are pending operations
///
/// Provides a boolean indicating if there are operations waiting to sync.
/// Useful for showing/hiding pending sync indicators.
final hasPendingOperationsProvider = Provider<bool>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.queueSize > 0;
});

/// Provider for sync status text
///
/// Provides a user-friendly text representation of the sync status.
final syncStatusTextProvider = Provider<String>((ref) {
  final state = ref.watch(manualSyncNotifierProvider);

  if (state.isSyncing) {
    return 'Syncing...';
  }

  if (!state.hasResults) {
    return 'Ready to sync';
  }

  if (state.lastSyncSuccess == true) {
    return 'Synced successfully';
  }

  if (state.lastSyncSuccess == false) {
    return 'Sync failed';
  }

  return 'Ready to sync';
});

/// Provider for last sync time
///
/// Provides the timestamp of the last completed sync, if any.
final lastSyncTimeProvider = Provider<DateTime?>((ref) {
  final state = ref.watch(manualSyncNotifierProvider);
  return state.completedAt;
});

/// Helper function to pluralize words
String _pluralize(String word, int count) {
  return count == 1 ? word : '${word}s';
}
