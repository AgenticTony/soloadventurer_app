import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_manager.dart';
import 'package:soloadventurer/app/providers/offline_service_providers.dart';

part 'sync_status_provider.g.dart';

/// Re-export of syncManagerProvider from app/providers/offline_service_providers.dart
/// The syncManagerProvider is now defined in app/providers/offline_service_providers.dart

/// Provider for sync status stream
@riverpod
Stream<SyncStatus> syncStatusStream(Ref ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.syncStatusStream;
}

/// Notifier for managing sync status state
@riverpod
class SyncStatusNotifier extends _$SyncStatusNotifier {
  /// Subscription to sync status stream
  StreamSubscription<SyncStatus>? _subscription;

  @override
  SyncStatus build() {
    final syncManager = ref.watch(syncManagerProvider);
    _syncManager = syncManager;
    _startMonitoring();
    return _syncManager.currentStatus;
  }

  late final SyncManager _syncManager;

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
  Future<SyncResult> triggerSync({bool force = false}) async {
    try {
      return await _syncManager.startSync(force: force);
    } catch (e) {
      // State will be updated by the stream
      rethrow;
    }
  }

  /// Stop the current sync cycle
  Future<bool> stopSync() async {
    return await _syncManager.stopSync();
  }

  /// Pause automatic sync triggers
  void pauseAutoSync() {
    _syncManager.pauseAutoSync();
  }

  /// Resume automatic sync triggers
  void resumeAutoSync() {
    _syncManager.resumeAutoSync();
  }

  /// Refresh sync status
  void refresh() {
    state = _syncManager.currentStatus;
  }
}

/// Selector provider for sync state enum
@riverpod
SyncState syncState(Ref ref) {
  return ref.watch(syncStatusProvider).state;
}

/// Selector provider for is syncing status
@riverpod
bool isSyncing(Ref ref) {
  return ref.watch(syncStatusProvider).isSyncing;
}

/// Selector provider for sync progress
@riverpod
double syncProgress(Ref ref) {
  return ref.watch(syncStatusProvider).progress;
}

/// Selector provider for sync phase
@riverpod
SyncPhase syncPhase(Ref ref) {
  return ref.watch(syncStatusProvider).phase;
}

/// Selector provider for pending operations count
@riverpod
int pendingOperations(Ref ref) {
  return ref.watch(syncStatusProvider).pendingOperations;
}

/// Selector provider for has pending operations
@riverpod
bool hasPendingOperations(Ref ref) {
  return ref.watch(syncStatusProvider).pendingOperations > 0;
}

/// Selector provider for sync error status
@riverpod
bool hasSyncError(Ref ref) {
  return ref.watch(syncStatusProvider).hasError;
}

/// Selector provider for error message
@riverpod
String? syncErrorMessage(Ref ref) {
  return ref.watch(syncStatusProvider).errorMessage;
}

/// Selector provider for last sync time
@riverpod
DateTime? lastSyncTime(Ref ref) {
  return ref.watch(syncStatusProvider).lastSyncTime;
}

/// Selector provider for current operation description
@riverpod
String? currentSyncOperation(Ref ref) {
  return ref.watch(syncStatusProvider).currentOperation;
}

/// Selector provider for is idle status
@riverpod
bool isSyncIdle(Ref ref) {
  return ref.watch(syncStatusProvider).isIdle;
}
