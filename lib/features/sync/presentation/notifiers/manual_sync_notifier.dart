import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/services/sync_service.dart';
import '../state/manual_sync_state.dart';
import '../../../core/domain/services/logging_service.dart';

/// Notifier for managing manual sync operations
///
/// Handles manual sync triggers, tracks sync progress,
/// and provides state updates for UI components.
class ManualSyncNotifier extends StateNotifier<ManualSyncState> {
  /// Sync service for triggering sync operations
  final SyncService _syncService;

  /// Logging service for debug/info logging
  final LoggingService _logger;

  /// Subscription to sync status changes
  StreamSubscription<SyncStatus>? _statusSubscription;

  /// Creates a new [ManualSyncNotifier]
  ManualSyncNotifier({
    required SyncService syncService,
    required LoggingService logger,
  })  : _syncService = syncService,
        _logger = logger,
        super(ManualSyncState.initial()) {
    _initialize();
  }

  /// Initialize the notifier by subscribing to sync status changes
  void _initialize() {
    _statusSubscription = _syncService.statusStream.listen(
      _onSyncStatusChanged,
      onError: (error, stack) {
        _logger.error(
          'ManualSyncNotifier: Error in status stream',
          error: error,
          stackTrace: stack,
        );
      },
    );

    _logger.info('ManualSyncNotifier: Initialized');
  }

  /// Handle sync status changes from the sync service
  void _onSyncStatusChanged(SyncStatus status) {
    // Only update state if we're in a syncing state
    // This prevents automatic syncs from affecting manual sync state
    if (state.isSyncing) {
      _logger.debug('ManualSyncNotifier: Status changed to $status');

      // Update status but keep other state intact
      state = state.copyWith(status: status);

      // Check if sync completed
      if (status == SyncStatus.success || status == SyncStatus.failed) {
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
    // Prevent multiple simultaneous syncs
    if (state.isSyncing) {
      _logger.warning('ManualSyncNotifier: Sync already in progress, ignoring trigger');
      return;
    }

    final startedAt = DateTime.now();
    _logger.info('ManualSyncNotifier: Manual sync triggered at $startedAt');

    // Update state to syncing
    state = ManualSyncState.syncing(
      startedAt: startedAt,
      status: _syncService.status,
    );

    try {
      // Process the sync queue
      final result = await _syncService.processQueue();

      final completedAt = DateTime.now();
      _logger.info(
        'ManualSyncNotifier: Sync completed at $completedAt - '
        'Success: ${result.success}, '
        'SuccessCount: ${result.successCount}, '
        'FailureCount: ${result.failureCount}',
      );

      if (result.success) {
        // Sync succeeded
        state = ManualSyncState.success(
          successCount: result.successCount,
          failureCount: result.failureCount,
          completedAt: completedAt,
          startedAt: startedAt,
          totalProcessed: result.successCount + result.failureCount,
          status: SyncStatus.success,
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
          status: SyncStatus.failed,
        );
      }
    } catch (e, stack) {
      final completedAt = DateTime.now();
      _logger.error(
        'ManualSyncNotifier: Sync failed with exception',
        error: e,
        stackTrace: stack,
      );

      state = ManualSyncState.failure(
        errorMessage: e.toString(),
        completedAt: completedAt,
        startedAt: startedAt,
        status: SyncStatus.failed,
      );
    }
  }

  /// Reset the state to initial
  ///
  /// Clears all sync result information.
  void reset() {
    _logger.info('ManualSyncNotifier: Resetting state');
    state = ManualSyncState.initial();
  }

  /// Clear error message if present
  ///
  /// Keeps sync results but removes error message.
  void clearError() {
    if (state.errorMessage != null) {
      _logger.debug('ManualSyncNotifier: Clearing error message');
      state = state.copyWith(errorMessage: null);
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _logger.debug('ManualSyncNotifier: Disposed');
    super.dispose();
  }
}
