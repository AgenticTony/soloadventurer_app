import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/sync_service.dart';
import '../../domain/models/sync_status.dart';
import '../state/manual_sync_state.dart';
import '../../../core/domain/services/logging_service.dart';
import '../providers/sync_providers.dart';

part 'manual_sync_notifier.g.dart';

/// Notifier for managing manual sync operations
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Uses ref.onDispose() for cleanup instead of dispose() method
/// - Initialization logic moved from constructor to build() method
///
/// Handles manual sync triggers, tracks sync progress,
/// and provides state updates for UI components.
@riverpod
class ManualSyncNotifier extends _$ManualSyncNotifier {
  /// Initialize the notifier and subscribe to sync status changes
  ///
  /// Riverpod 3.0: build() replaces constructor for initialization
  @override
  ManualSyncState build() {
    // Get dependencies via ref.watch()
    final syncService = ref.watch(syncServiceProvider);
    final logger = ref.watch(loggingServiceProvider);

    // Set up cleanup using ref.onDispose()
    ref.onDispose(() {
      _statusSubscription?.cancel();
      // logging
    });

    // Initialize state
    final initialState = ManualSyncState.initial();

    // Subscribe to status changes
    _statusSubscription = syncService.statusStream.listen(
      (status) => _onSyncOperationStatusChanged(status, logger),
      onError: (error, stack) {
        // logging
      },
    );

    // logging
    return initialState;
  }

  /// Stream subscription for cleanup
  StreamSubscription<SyncOperationStatus>? _statusSubscription;

  /// Handle sync status changes from the sync service
  void _onSyncOperationStatusChanged(
    SyncOperationStatus status,
    LoggingService logger,
  ) {
    // Only update state if we're in a syncing state
    // This prevents automatic syncs from affecting manual sync state
    if (state.isSyncing) {
      // logging

      // Update status but keep other state intact
      state = state.copyWith(status: status);

      // Check if sync completed
      if (status == SyncOperationStatus.success ||
          status == SyncOperationStatus.failed) {
        // The actual result will be set by triggerSync method
        // This is just a status update
      }
    }
  }

  /// Trigger a manual sync operation
  ///
  /// Processes all pending operations in the sync queue.
  /// Updates state with progress and results.
  Future<void> triggerSync() async {
    // Get dependencies
    final syncService = ref.read(syncServiceProvider);
    final logger = ref.read(loggingServiceProvider);

    // Prevent multiple simultaneous syncs
    if (state.isSyncing) {
      // logging
      return;
    }

    final startedAt = DateTime.now();
    // logging

    // Update state to syncing
    state = ManualSyncState.syncing(
      startedAt: startedAt,
      status: syncService.status,
    );

    try {
      // Process the sync queue
      final result = await syncService.processQueue();

      final completedAt = DateTime.now();
      // logging

      if (result.success) {
        // Sync succeeded
        state = ManualSyncState.success(
          successCount: result.successCount,
          failureCount: result.failureCount,
          completedAt: completedAt,
          startedAt: startedAt,
          totalProcessed: result.successCount + result.failureCount,
          status: SyncOperationStatus.success,
        );
      } else {
        // Sync failed
        state = ManualSyncState.failure(
          errorMessage: result.error ?? 'Unknown sync error',
          completedAt: completedAt,
          startedAt: startedAt,
          successCount: result.successCount,
          failureCount: result.failureCount,
          totalProcessed: result.successCount + result.failureCount,
          status: SyncOperationStatus.failed,
        );
      }
    } catch (e, stack) {
      final logger = ref.read(loggingServiceProvider);
      final completedAt = DateTime.now();
      // logging

      state = ManualSyncState.failure(
        errorMessage: e.toString(),
        completedAt: completedAt,
        startedAt: startedAt,
        status: SyncOperationStatus.failed,
      );
    }
  }

  /// Reset the state to initial
  ///
  /// Clears all sync result information.
  void reset() {
    final logger = ref.read(loggingServiceProvider);
    // logging
    state = ManualSyncState.initial();
  }

  /// Clear error message if present
  ///
  /// Keeps sync results but removes error message.
  void clearError() {
    if (state.errorMessage != null) {
      final logger = ref.read(loggingServiceProvider);
      // logging
      state = state.copyWith(errorMessage: null);
    }
  }
}
