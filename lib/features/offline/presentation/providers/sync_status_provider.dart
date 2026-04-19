import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_manager.dart'
    show SyncManager, SyncStatus, SyncResult, SyncState, SyncPhase;
import 'package:soloadventurer/features/offline/presentation/providers/sync_manager_provider.dart'
    show syncManagerProvider;

part 'sync_status_provider.g.dart';

/// Riverpod 3.0 Migration Notes:
/// - Converted from `StateNotifier<SyncStatus>` to `Notifier<SyncStatus>`
/// - Dependencies injected via ref.watch() in build() method
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns SyncStatus not AsyncValue
/// - StreamSubscription management via ref.onDispose()
/// - Constructor auto-load and stream subscription moved to build() method

// syncManager is provided by sync_manager_provider.dart

@riverpod
Stream<SyncStatus> syncStatusStream(Ref ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.syncStatusStream;
}

@riverpod
class SyncStatusNotifier extends _$SyncStatusNotifier {
  StreamSubscription<SyncStatus>? _subscription;

  @override
  SyncStatus build() {
    final syncManager = ref.watch(syncManagerProvider);
    _startMonitoring(syncManager);
    return syncManager.currentStatus;
  }

  void _startMonitoring(SyncManager syncManager) {
    _subscription = syncManager.syncStatusStream.listen(
      (status) {
        state = status;
      },
      onError: (error) {
        state = SyncStatus.error(
          'Sync stream error: $error',
          pendingOperations: state.pendingOperations,
          lastSyncTime: state.lastSyncTime,
        );
      },
    );

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });
  }

  Future<SyncResult> triggerSync({bool force = false}) async {
    final syncManager = ref.read(syncManagerProvider);
    try {
      return await syncManager.startSync(force: force);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> stopSync() async {
    final syncManager = ref.read(syncManagerProvider);
    return await syncManager.stopSync();
  }

  void pauseAutoSync() {
    final syncManager = ref.read(syncManagerProvider);
    syncManager.pauseAutoSync();
  }

  void resumeAutoSync() {
    final syncManager = ref.read(syncManagerProvider);
    syncManager.resumeAutoSync();
  }

  void refresh() {
    final syncManager = ref.read(syncManagerProvider);
    state = syncManager.currentStatus;
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
