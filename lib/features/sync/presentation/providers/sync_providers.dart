import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/sync_status.dart';
import '../notifiers/manual_sync_notifier.dart' show manualSyncProvider;
import '../notifiers/sync_state_notifier.dart' show syncStateProvider;
import '../state/manual_sync_state.dart';
import '../state/sync_state.dart';
import 'service_providers.dart' show syncServiceProvider;

// ============================================================================
// MANUAL SYNC PROVIDERS
// ============================================================================
// The ManualSyncNotifier has been migrated to Riverpod 3.0 AsyncNotifier.
// Use the auto-generated `manualSyncProvider` from manual_sync_notifier.dart.
// The provider now exposes AsyncValue<ManualSyncState>.
// Use ref.watch(manualSyncProvider) to get AsyncValue<ManualSyncState>.
// Use .value or .when() to access the state.

/// Provider for current manual sync state (unwrapped from AsyncValue)
///
/// Provides direct access to the current manual sync state, or null
/// if loading/error. Use manualSyncProvider directly for full AsyncValue
/// handling with loading/error states.
final manualSyncStateProvider = Provider<ManualSyncState?>((ref) {
  return ref.watch(manualSyncProvider).value;
});

/// Provider for whether a manual sync is in progress
///
/// True when AsyncValue is in loading state.
/// Useful for showing loading indicators and disabling sync buttons.
final isSyncingProvider = Provider<bool>((ref) {
  final asyncState = ref.watch(manualSyncProvider);
  // Loading state means syncing
  if (asyncState.isLoading) return true;
  // Also check if the status says syncing
  return asyncState.value?.isSyncing ?? false;
});

/// Provider for last manual sync success status
///
/// Provides the success status of the last manual sync.
/// Returns null if no sync has been performed yet or state is loading.
final lastSyncSuccessProvider = Provider<bool?>((ref) {
  return ref.watch(manualSyncProvider).value?.lastSyncSuccess;
});

/// Provider for sync status
///
/// Provides the current sync status from the manual sync state.
final syncStatusProvider = Provider<SyncOperationStatus?>((ref) {
  return ref.watch(manualSyncProvider).value?.status;
});

/// Provider for sync result summary
///
/// Provides a formatted string summary of the last sync result.
/// Useful for displaying sync results to users.
final syncResultSummaryProvider = Provider<String?>((ref) {
  final state = ref.watch(manualSyncProvider).value;

  if (state == null || !state.hasResults) {
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
    // Error message is now in AsyncValue.error, not in state
    return 'Sync failed';
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
  final asyncState = ref.watch(manualSyncProvider);
  final state = asyncState.value;

  if (asyncState.isLoading || state?.isSyncing == true) {
    return 'Syncing...';
  }

  if (state == null || !state.hasResults) {
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
  return ref.watch(manualSyncProvider).value?.completedAt;
});

/// Helper function to pluralize words
String _pluralize(String word, int count) {
  return count == 1 ? word : '${word}s';
}

// ============================================================================
// COMPREHENSIVE SYNC STATE PROVIDERS
// ============================================================================
// The SyncStateNotifier has been migrated to Riverpod 3.0 AsyncNotifier.
// Use the auto-generated `syncStateProvider` from sync_state_notifier.dart.
// The provider now exposes AsyncValue<SyncState>.

/// Provider for current comprehensive sync state (unwrapped from AsyncValue)
///
/// Note: Use the auto-generated `syncStateProvider` from sync_state_notifier.dart
/// which directly provides AsyncValue<SyncState>. This provider is kept for
/// backward compatibility and unwraps the AsyncValue.
@Deprecated('Use syncStateProvider directly and handle AsyncValue')
final syncStateProviderOldDeprecated = Provider<SyncState?>((ref) {
  return ref.watch(syncStateProvider).value;
});

/// Provider for global sync status
///
/// Provides the current sync status for all sync operations (not just manual).
/// Updates immediately when any sync operation changes status.
final globalSyncOperationStatusProvider = Provider<SyncOperationStatus>((ref) {
  final state = ref.watch(syncStateProvider).value;
  return state?.status ?? SyncOperationStatus.idle;
});

/// Provider for global syncing state
///
/// Provides a boolean indicating if ANY sync operation is currently running.
/// Updates immediately when sync starts or stops.
final isGloballySyncingProvider = Provider<bool>((ref) {
  final asyncState = ref.watch(syncStateProvider);
  if (asyncState.isLoading) return true;
  return asyncState.value?.isSyncing ?? false;
});

/// Provider for global queue size
///
/// Provides the current number of operations in the sync queue.
/// Updates immediately when operations are added or removed from the queue.
final globalQueueSizeProvider = Provider<int>((ref) {
  return ref.watch(syncStateProvider).value?.queueSize ?? 0;
});

/// Provider for global pending operations state
///
/// Provides a boolean indicating if there are any pending operations.
/// Updates immediately when queue state changes.
final hasGlobalPendingOperationsProvider = Provider<bool>((ref) {
  return ref.watch(syncStateProvider).value?.hasPendingOperations ?? false;
});

/// Provider for last successful sync time (global)
///
/// Provides the timestamp of the last successful sync (any type).
/// Useful for showing "Last synced: Xm ago" indicators.
final lastSuccessfulSyncTimeProvider = Provider<DateTime?>((ref) {
  return ref.watch(syncStateProvider).value?.lastSuccessfulSyncAt;
});

/// Provider for last sync success status (global)
///
/// Provides a boolean indicating if the last sync was successful.
/// Returns null if no sync has occurred yet.
final wasLastSyncSuccessfulProvider = Provider<bool?>((ref) {
  final state = ref.watch(syncStateProvider).value;
  if (state?.lastSuccessfulSyncAt == null) return null;
  return state!.wasLastSyncSuccessful;
});

/// Provider for sync status text (global)
///
/// Provides a user-friendly text representation of the current sync status.
/// Updates immediately when sync status changes.
final globalSyncOperationStatusTextProvider = Provider<String>((ref) {
  final state = ref.watch(syncStateProvider).value;

  if (state == null) return 'Loading...';

  switch (state.status) {
    case SyncOperationStatus.syncing:
      return 'Syncing...';
    case SyncOperationStatus.success:
      return 'Synced successfully';
    case SyncOperationStatus.failed:
      return 'Sync failed';
    case SyncOperationStatus.pending:
      return 'Pending sync (${state.queueSize} ${_pluralize('item', state.queueSize)})';
    case SyncOperationStatus.idle:
      if (state.hasQueue) {
        return 'Ready to sync (${state.queueSize} ${_pluralize('item', state.queueSize)})';
      }
      return 'Ready to sync';
  }
});

/// Provider for sync status details (global)
///
/// Provides detailed status information including counts and timing.
/// Useful for comprehensive status displays.
final syncStatusDetailsProvider = Provider<String>((ref) {
  final state = ref.watch(syncStateProvider).value;

  if (state == null) return 'Loading...';

  final buffer = StringBuffer();

  buffer.write('Status: ${state.status.displayName}');

  if (state.queueSize > 0) {
    buffer.write(' | Queue: ${state.queueSize}');
  }

  final lastSyncTime = state.lastSuccessfulSyncAt;
  if (lastSyncTime != null) {
    final now = DateTime.now();
    final diff = now.difference(lastSyncTime);
    buffer.write(' | Last sync: ');
    if (diff.inMinutes < 1) {
      buffer.write('Just now');
    } else if (diff.inMinutes < 60) {
      buffer.write('${diff.inMinutes}m ago');
    } else if (diff.inHours < 24) {
      buffer.write('${diff.inHours}h ago');
    } else {
      buffer.write('${diff.inDays}d ago');
    }
  }

  if (state.lastTotalOperations > 0) {
    final rate = state.lastSuccessRate;
    if (rate != null) {
      buffer.write(' | Success: ${(rate * 100).toInt()}%');
    }
  }

  return buffer.toString();
});
