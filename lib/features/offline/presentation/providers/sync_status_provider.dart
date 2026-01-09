import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_manager.dart';

/// Provider for the SyncManager from DI
///
/// This provides access to the singleton SyncManager instance
/// managed by GetIt dependency injection.
final syncManagerProvider = Provider<SyncManager>((ref) {
  return getIt<SyncManager>();
});

/// Provider for sync status stream
///
/// This provides access to the raw sync status stream from SyncManager.
/// Use [syncStatusProvider] for a more convenient state-based API.
///
/// Example:
/// ```dart
/// final syncStream = ref.watch(syncStatusStreamProvider);
/// syncStream.listen((status) {
///   print('Sync state: ${status.state}');
/// });
/// ```
final syncStatusStreamProvider = StreamProvider<SyncStatus>((ref) {
  final syncManager = ref.watch(syncManagerProvider);

  // Return the sync status stream from SyncManager
  return syncManager.syncStatusStream;
});

/// Notifier for managing sync status state
///
/// This notifier subscribes to [SyncManager]'s status stream
/// and exposes the current sync status to UI components.
/// It automatically handles subscription lifecycle and disposal.
///
/// The notifier provides:
/// - Current sync state (idle, syncing, error, paused)
/// - Sync progress (0.0 to 1.0)
/// - Current sync phase (upload, download, conflict resolution, finalization)
/// - Pending operations count
/// - Error messages (if any)
/// - Last sync timestamp
/// - Current operation description
///
/// Example usage:
/// ```dart
/// final syncStatus = ref.watch(syncStatusProvider);
/// if (syncStatus.isSyncing) {
///   print('Syncing... ${(syncStatus.progress * 100).toInt()}%');
///   print('Phase: ${syncStatus.phase}');
/// } else if (syncStatus.hasError) {
///   print('Error: ${syncStatus.errorMessage}');
/// }
/// ```
class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  /// Reference to the SyncManager
  final SyncManager _syncManager;

  /// Subscription to sync status stream
  StreamSubscription<SyncStatus>? _subscription;

  /// Creates a new [SyncStatusNotifier]
  ///
  /// [_syncManager] - The sync manager to monitor
  SyncStatusNotifier(this._syncManager) : super(_syncManager.currentStatus) {
    // Start monitoring sync status
    _startMonitoring();
  }

  /// Start monitoring sync status changes
  void _startMonitoring() {
    // Subscribe to sync status updates
    _subscription = _syncManager.syncStatusStream.listen(
      (status) {
        // Update state when sync status changes
        state = status;
      },
      onError: (error) {
        // Handle errors by setting error state
        state = SyncStatus.error(
          'Sync stream error: $error',
          pendingOperations: state.pendingOperations,
          lastSyncTime: state.lastSyncTime,
        );
      },
    );
  }

  /// Trigger a manual sync cycle
  ///
  /// This initiates a sync operation regardless of whether there are
  /// pending operations. Use [force] to bypass certain checks.
  ///
  /// Returns the [SyncResult] when sync completes.
  Future<SyncResult> triggerSync({bool force = false}) async {
    try {
      return await _syncManager.startSync(force: force);
    } catch (e) {
      // State will be updated by the stream
      rethrow;
    }
  }

  /// Stop the current sync cycle
  ///
  /// Gracefully stops the current sync operation.
  /// Returns [true] if sync was stopped, [false] if no sync was in progress.
  Future<bool> stopSync() async {
    return await _syncManager.stopSync();
  }

  /// Pause automatic sync triggers
  ///
  /// When paused, the sync manager will not automatically trigger sync
  /// when connectivity changes. Manual sync can still be triggered.
  void pauseAutoSync() {
    _syncManager.pauseAutoSync();
  }

  /// Resume automatic sync triggers
  ///
  /// Re-enables automatic sync when connectivity changes.
  void resumeAutoSync() {
    _syncManager.resumeAutoSync();
  }

  /// Refresh sync status
  ///
  /// Gets the current sync status from the manager and updates state.
  /// This is useful for ensuring the state is up-to-date after returning
  /// to the screen.
  void refresh() {
    state = _syncManager.currentStatus;
  }

  @override
  void dispose() {
    // Cancel subscription when notifier is disposed
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}

/// Provider for sync status state
///
/// This provider exposes the current sync status to the app.
/// It auto-disposes when no longer being listened to, which helps
/// with resource management.
///
/// Example usage:
/// ```dart
/// final syncStatus = ref.watch(syncStatusProvider);
///
/// if (syncStatus.isSyncing) {
///   return CircularProgressIndicator(value: syncStatus.progress);
/// } else if (syncStatus.hasError) {
///   return Text('Sync error: ${syncStatus.errorMessage}');
/// } else if (syncStatus.pendingOperations > 0) {
///   return Text('${syncStatus.pendingOperations} pending');
/// } else {
///   return Text('All synced');
/// }
/// ```
///
/// To access individual properties:
/// ```dart
/// final isSyncing = ref.watch(syncStatusProvider.select(
///   (status) => status.isSyncing,
/// ));
///
/// final progress = ref.watch(syncStatusProvider.select(
///   (status) => status.progress,
/// ));
/// ```
final syncStatusProvider =
    StateNotifierProvider.autoDispose<SyncStatusNotifier, SyncStatus>(
  (ref) {
    // Get the SyncManager from DI
    final syncManager = ref.watch(syncManagerProvider);

    // Create and return the notifier
    final notifier = SyncStatusNotifier(syncManager);

    // Dispose the notifier when provider is disposed
    ref.onDispose(() {
      notifier.dispose();
    });

    return notifier;
  },
);

/// Selector provider for sync state enum
///
/// Provides easy access to the sync state enum value.
/// This is useful for widgets that need to know the exact state.
///
/// Example:
/// ```dart
/// final syncState = ref.watch(syncStateProvider);
/// switch (syncState) {
///   case SyncState.syncing:
///     // Show sync indicator
///     break;
///   case SyncState.error:
///     // Show error message
///     break;
///   case SyncState.idle:
///     // Show idle state
///     break;
///   case SyncState.paused:
///     // Show paused state
///     break;
/// }
/// ```
final syncStateProvider = Provider.autoDispose<SyncState>((ref) {
  return ref.watch(syncStatusProvider).state;
});

/// Selector provider for is syncing status
///
/// Returns true when sync is currently in progress.
/// This is useful for showing sync progress indicators.
///
/// Example:
/// ```dart
/// final isSyncing = ref.watch(isSyncingProvider);
/// if (isSyncing) {
///   // Show sync animation
/// }
/// ```
final isSyncingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(syncStatusProvider).isSyncing;
});

/// Selector provider for sync progress
///
/// Returns the current sync progress (0.0 to 1.0).
/// This is useful for progress bars.
///
/// Example:
/// ```dart
/// final progress = ref.watch(syncProgressProvider);
/// return LinearProgressIndicator(value: progress);
/// ```
final syncProgressProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(syncStatusProvider).progress;
});

/// Selector provider for sync phase
///
/// Returns the current sync phase.
/// This is useful for showing detailed sync status.
///
/// Example:
/// ```dart
/// final phase = ref.watch(syncPhaseProvider);
/// if (phase == SyncPhase.upload) {
///   return Text('Uploading changes...');
/// } else if (phase == SyncPhase.download) {
///   return Text('Downloading changes...');
/// }
/// ```
final syncPhaseProvider = Provider.autoDispose<SyncPhase>((ref) {
  return ref.watch(syncStatusProvider).phase;
});

/// Selector provider for pending operations count
///
/// Returns the number of operations pending sync.
/// This is useful for showing badges or counts.
///
/// Example:
/// ```dart
/// final pendingCount = ref.watch(pendingOperationsProvider);
/// if (pendingCount > 0) {
///   return Badge(count: pendingCount);
/// }
/// ```
final pendingOperationsProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(syncStatusProvider).pendingOperations;
});

/// Selector provider for has pending operations
///
/// Returns true when there are operations waiting to sync.
/// This is a convenience provider for more readable code.
///
/// Example:
/// ```dart
/// final hasPending = ref.watch(hasPendingOperationsProvider);
/// if (hasPending) {
///   // Show "Sync pending" indicator
/// }
/// ```
final hasPendingOperationsProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(syncStatusProvider).pendingOperations > 0;
});

/// Selector provider for sync error status
///
/// Returns true when sync has encountered an error.
/// This is useful for showing error banners.
///
/// Example:
/// ```dart
/// final hasError = ref.watch(hasSyncErrorProvider);
/// if (hasError) {
///   // Show error banner
/// }
/// ```
final hasSyncErrorProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(syncStatusProvider).hasError;
});

/// Selector provider for error message
///
/// Returns the current sync error message (if any).
/// Returns null if there's no error.
///
/// Example:
/// ```dart
/// final errorMessage = ref.watch(syncErrorMessageProvider);
/// if (errorMessage != null) {
///   return Text('Sync error: $errorMessage');
/// }
/// ```
final syncErrorMessageProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(syncStatusProvider).errorMessage;
});

/// Selector provider for last sync time
///
/// Returns the timestamp of the last successful sync.
/// Returns null if no sync has occurred.
///
/// Example:
/// ```dart
/// final lastSync = ref.watch(lastSyncTimeProvider);
/// if (lastSync != null) {
///   final timeAgo = DateTime.now().difference(lastSync);
///   return Text('Last synced: ${timeAgo.inMinutes}m ago');
/// }
/// ```
final lastSyncTimeProvider = Provider.autoDispose<DateTime?>((ref) {
  return ref.watch(syncStatusProvider).lastSyncTime;
});

/// Selector provider for current operation description
///
/// Returns a description of the current sync operation.
/// Returns null if no operation is in progress.
///
/// Example:
/// ```dart
/// final operation = ref.watch(currentSyncOperationProvider);
/// if (operation != null) {
///   return Text(operation);
/// }
/// ```
final currentSyncOperationProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(syncStatusProvider).currentOperation;
});

/// Selector provider for is idle status
///
/// Returns true when sync is idle (not syncing, no error).
/// This is useful for showing "all synced" status.
///
/// Example:
/// ```dart
/// final isIdle = ref.watch(isSyncIdleProvider);
/// if (isIdle) {
///   return Icon(Icons.check_circle, color: Colors.green);
/// }
/// ```
final isSyncIdleProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(syncStatusProvider).isIdle;
});
