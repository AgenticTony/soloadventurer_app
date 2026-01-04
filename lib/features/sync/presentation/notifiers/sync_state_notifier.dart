import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/services/sync_service.dart';
import '../state/sync_state.dart';
import '../../../core/domain/services/logging_service.dart';

/// Notifier for managing comprehensive sync state
///
/// Listens to all sync service status changes and queue updates,
/// providing reactive state for UI components to consume.
/// Ensures all status indicators update immediately when sync state changes.
class SyncStateNotifier extends StateNotifier<SyncState> {
  /// Sync service for status and queue monitoring
  final SyncService _syncService;

  /// Logging service for debug/info logging
  final LoggingService _logger;

  /// Subscription to sync status changes
  StreamSubscription<SyncStatus>? _statusSubscription;

  /// Subscription to queue changes
  StreamSubscription<List<dynamic>>? _queueSubscription;

  /// Creates a new [SyncStateNotifier]
  SyncStateNotifier({
    required SyncService syncService,
    required LoggingService logger,
  })  : _syncService = syncService,
        _logger = logger,
        super(SyncState.initial()) {
    _initialize();
  }

  /// Initialize the notifier by subscribing to sync service streams
  void _initialize() {
    // Subscribe to status changes
    _statusSubscription = _syncService.statusStream.listen(
      _onStatusChanged,
      onError: (error, stack) {
        _logger.error(
          'SyncStateNotifier: Error in status stream',
          error: error,
          stackTrace: stack,
        );
      },
    );

    // Subscribe to queue changes
    _queueSubscription = _syncService.queueStream.listen(
      _onQueueChanged,
      onError: (error, stack) {
        _logger.error(
          'SyncStateNotifier: Error in queue stream',
          error: error,
          stackTrace: stack,
        );
      },
    );

    // Initialize with current state
    _updateStateFromService();

    _logger.info('SyncStateNotifier: Initialized');
  }

  /// Handle sync status changes from the sync service
  void _onStatusChanged(SyncStatus newStatus) {
    _logger.debug('SyncStateNotifier: Status changed to $newStatus');

    // Update state with new status
    state = state.copyWith(
      status: newStatus,
      lastStatusChangeAt: DateTime.now(),
    );

    // Track successful/failed sync results
    if (newStatus == SyncStatus.success) {
      // Get queue size for success count (operations processed)
      state = state.copyWith(
        lastSuccessfulSyncAt: DateTime.now(),
        lastSuccessCount: _syncService.queueSize,
        clearLastError: true,
      );
    } else if (newStatus == SyncStatus.failed) {
      state = state.copyWith(
        lastError: 'Sync failed',
        lastFailureCount: state.queueSize,
      );
    }

    // Update processing state
    state = state.copyWith(
      isProcessing: newStatus == SyncStatus.syncing,
    );
  }

  /// Handle queue changes from the sync service
  void _onQueueChanged(List<dynamic> queue) {
    _logger.debug('SyncStateNotifier: Queue changed, size: ${queue.length}');

    state = state.copyWith(
      queueSize: queue.length,
      hasPendingOperations: queue.length > 0,
    );

    // Update status based on queue state
    if (queue.length > 0 && state.status == SyncStatus.idle) {
      state = state.copyWith(
        status: SyncStatus.pending,
        lastStatusChangeAt: DateTime.now(),
      );
    } else if (queue.length == 0 && state.status == SyncStatus.pending) {
      state = state.copyWith(
        status: SyncStatus.idle,
        lastStatusChangeAt: DateTime.now(),
      );
    }
  }

  /// Update state from current sync service state
  ///
  /// Called during initialization to ensure state reflects current conditions.
  void _updateStateFromService() {
    state = SyncState(
      status: _syncService.status,
      queueSize: _syncService.queueSize,
      isProcessing: _syncService.isProcessing,
      lastStatusChangeAt: DateTime.now(),
      hasPendingOperations: _syncService.queueSize > 0,
    );

    _logger.debug('SyncStateNotifier: Initial state - ${state.toString()}');
  }

  /// Refresh state from sync service
  ///
  /// Can be called to manually refresh state if needed.
  void refresh() {
    _logger.debug('SyncStateNotifier: Manual refresh requested');
    _updateStateFromService();
  }

  /// Reset state to initial
  ///
  /// Clears all sync state information.
  void reset() {
    _logger.info('SyncStateNotifier: Resetting state');
    state = SyncState.initial();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _queueSubscription?.cancel();
    _logger.debug('SyncStateNotifier: Disposed');
    super.dispose();
  }
}
