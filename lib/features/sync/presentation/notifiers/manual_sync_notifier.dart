import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/sync_status.dart';
import '../state/manual_sync_state.dart';
import '../providers/service_providers.dart';

part 'manual_sync_notifier.g.dart';

/// Notifier for managing manual sync operations
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Uses AsyncNotifier pattern with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - isSyncing/errorMessage removed from state (AsyncValue handles them)
/// - Methods use AsyncValue.guard() for async operations
/// - UI reads state via ref.watch(manualSyncProvider)
/// - UI calls methods via ref.read(manualSyncProvider.notifier)
@riverpod
class ManualSyncNotifier extends _$ManualSyncNotifier {
  /// Stream subscription for cleanup
  StreamSubscription<SyncOperationStatus>? _statusSubscription;

  /// Initialize the notifier and subscribe to sync status changes
  @override
  Future<ManualSyncState> build() async {
    // Get dependencies via ref.watch()
    final syncService = ref.watch(syncServiceProvider);

    // Set up cleanup using ref.onDispose()
    ref.onDispose(() {
      _statusSubscription?.cancel();
    });

    // Initialize state
    final initialState = ManualSyncState.initial();

    // Subscribe to status changes
    _statusSubscription = syncService.statusStream.listen(
      (status) => _onSyncOperationStatusChanged(status),
      onError: (error, stack) {
        // Silently handle errors
      },
    );

    return initialState;
  }

  /// Handle sync status changes from the sync service
  void _onSyncOperationStatusChanged(
    SyncOperationStatus status,
  ) {
    // Only update state if we're in a syncing state
    // This prevents automatic syncs from affecting manual sync state
    final current = state.value;
    if (current != null && current.isSyncing) {
      // Update status but keep other state intact
      state = AsyncData(current.copyWith(status: status));
    }
  }

  /// Trigger a manual sync operation
  ///
  /// Processes all pending operations in the sync queue.
  /// Uses AsyncValue.guard() for loading/error handling.
  Future<void> triggerSync() async {
    // Get dependencies
    final syncService = ref.read(syncServiceProvider);

    // Prevent multiple simultaneous syncs
    final current = state.value;
    if (current != null && current.isSyncing) {
      return;
    }

    final startedAt = DateTime.now();

    // Set loading state with startedAt info
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // Process the sync queue
      final result = await syncService.processQueue();

      final completedAt = DateTime.now();

      if (result.success) {
        // Sync succeeded
        return ManualSyncState.success(
          successCount: result.successCount,
          failureCount: result.failureCount,
          completedAt: completedAt,
          startedAt: startedAt,
          totalProcessed: result.successCount + result.failureCount,
          status: SyncOperationStatus.success,
        );
      } else {
        // Sync failed - throw to be caught by AsyncValue.guard
        throw ManualSyncException(
          result.error ?? 'Unknown sync error',
          successCount: result.successCount,
          failureCount: result.failureCount,
          completedAt: completedAt,
          startedAt: startedAt,
          totalProcessed: result.successCount + result.failureCount,
        );
      }
    });
  }

  /// Reset the state to initial
  ///
  /// Clears all sync result information.
  void reset() {
    state = const AsyncData(ManualSyncState(
      status: SyncOperationStatus.idle,
    ));
  }
}

/// Exception thrown when a manual sync fails.
///
/// Carries result data so the UI can still display partial results
/// when handling the error via AsyncValue.
class ManualSyncException implements Exception {
  final String message;
  final int successCount;
  final int failureCount;
  final DateTime completedAt;
  final DateTime startedAt;
  final int totalProcessed;

  ManualSyncException(
    this.message, {
    this.successCount = 0,
    this.failureCount = 0,
    required this.completedAt,
    required this.startedAt,
    this.totalProcessed = 0,
  });

  /// Build a ManualSyncState representing this failure
  ManualSyncState toState() => ManualSyncState.failure(
        completedAt: completedAt,
        startedAt: startedAt,
        successCount: successCount,
        failureCount: failureCount,
        totalProcessed: totalProcessed,
        status: SyncOperationStatus.failed,
      );

  @override
  String toString() => 'ManualSyncException: $message';
}
