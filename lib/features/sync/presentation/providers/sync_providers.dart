import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/sync_service.dart';
import '../../domain/models/sync_status.dart';
import '../notifiers/manual_sync_notifier.dart';
import '../notifiers/sync_state_notifier.dart';
import '../state/manual_sync_state.dart';
import '../state/sync_state.dart';
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

// ============================================================================
// COMPREHENSIVE SYNC STATE PROVIDERS
// ============================================================================
// These providers track ALL sync state changes (not just manual sync)
// and ensure all UI components receive immediate updates when sync state changes.

/// Provider for the comprehensive sync state notifier
///
/// Manages global sync state by listening to all sync service changes.
/// Provides real-time updates for all sync status indicators.
final syncStateNotifierProvider =
    StateNotifierProvider<SyncStateNotifier, SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final logger = ref.watch(loggingServiceProvider);

  final notifier = SyncStateNotifier(
    syncService: syncService,
    logger: logger,
  );

  // Dispose notifier when provider is disposed
  ref.onDispose(() {
    notifier.dispose();
  });

  return notifier;
});

/// Provider for current comprehensive sync state
///
/// Provides direct access to the current sync state.
/// This state includes status, queue size, processing state, and last sync results.
final syncStateProvider = Provider<SyncState>((ref) {
  return ref.watch(syncStateNotifierProvider);
});

/// Provider for global sync status
///
/// Provides the current sync status for all sync operations (not just manual).
/// Updates immediately when any sync operation changes status.
final globalSyncStatusProvider = Provider<SyncStatus>((ref) {
  final state = ref.watch(syncStateNotifierProvider);
  return state.status;
});

/// Provider for global syncing state
///
/// Provides a boolean indicating if ANY sync operation is currently running.
/// Updates immediately when sync starts or stops.
final isGloballySyncingProvider = Provider<bool>((ref) {
  final state = ref.watch(syncStateNotifierProvider);
  return state.isSyncing;
});

/// Provider for global queue size
///
/// Provides the current number of operations in the sync queue.
/// Updates immediately when operations are added or removed from the queue.
final globalQueueSizeProvider = Provider<int>((ref) {
  final state = ref.watch(syncStateNotifierProvider);
  return state.queueSize;
});

/// Provider for global pending operations state
///
/// Provides a boolean indicating if there are any pending operations.
/// Updates immediately when queue state changes.
final hasGlobalPendingOperationsProvider = Provider<bool>((ref) {
  final state = ref.watch(syncStateNotifierProvider);
  return state.hasPendingOperations;
});

/// Provider for last successful sync time (global)
///
/// Provides the timestamp of the last successful sync (any type).
/// Useful for showing "Last synced: Xm ago" indicators.
final lastSuccessfulSyncTimeProvider = Provider<DateTime?>((ref) {
  final state = ref.watch(syncStateNotifierProvider);
  return state.lastSuccessfulSyncAt;
});

/// Provider for last sync success status (global)
///
/// Provides a boolean indicating if the last sync was successful.
/// Returns null if no sync has occurred yet.
final wasLastSyncSuccessfulProvider = Provider<bool?>((ref) {
  final state = ref.watch(syncStateNotifierProvider);
  if (state.lastSuccessfulSyncAt == null) return null;
  return state.wasLastSyncSuccessful;
});

/// Provider for sync status text (global)
///
/// Provides a user-friendly text representation of the current sync status.
/// Updates immediately when sync status changes.
final globalSyncStatusTextProvider = Provider<String>((ref) {
  final state = ref.watch(syncStateNotifierProvider);

  switch (state.status) {
    case SyncStatus.syncing:
      return 'Syncing...';
    case SyncStatus.success:
      return 'Synced successfully';
    case SyncStatus.failed:
      return 'Sync failed';
    case SyncStatus.pending:
      return 'Pending sync (${state.queueSize} ${_pluralize('item', state.queueSize)})';
    case SyncStatus.idle:
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
  final state = ref.watch(syncStateNotifierProvider);

  final buffer = StringBuffer();

  buffer.write('Status: ${state.status.displayName}');

  if (state.queueSize > 0) {
    buffer.write(' | Queue: ${state.queueSize}');
  }

  if (state.lastSuccessfulSyncAt != null) {
    final now = DateTime.now();
    final diff = now.difference(state.lastSuccessfulSyncAt!);
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
