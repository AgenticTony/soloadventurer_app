import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/services/sync_service.dart';
import '../../domain/models/sync_status.dart';
import '../state/sync_state.dart';
import '../../../core/domain/services/logging_service.dart';
import '../providers/service_providers.dart';

part 'sync_state_notifier.g.dart';

/// Notifier for managing comprehensive sync state
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Uses ref.onDispose() for cleanup instead of dispose() method
/// - Initialization logic moved from constructor to build() method
///
/// Listens to all sync service status changes and queue updates,
/// providing reactive state for UI components to consume.
/// Ensures all status indicators update immediately when sync state changes.
/// Optionally persists state across app restarts.
@riverpod
class SyncStateNotifier extends _$SyncStateNotifier {
  /// Initialize the notifier and subscribe to sync service streams
  ///
  /// Riverpod 3.0: build() replaces constructor for initialization
  @override
  SyncState build() {
    // Get dependencies via ref.watch()
    final syncService = ref.watch(syncServiceProvider);
    final logger = ref.watch(loggingServiceProvider);

    // Set up cleanup using ref.onDispose()
    ref.onDispose(() {
      _statusSubscription?.cancel();
      _queueSubscription?.cancel();
      // logging
    });

    // Initialize state
    final initialState = SyncState.initial();

    // Subscribe to status changes
    _statusSubscription = syncService.statusStream.listen(
      (status) => _onStatusChanged(status, logger),
      onError: (error, stack) {
        // logging
      },
    );

    // Subscribe to queue changes
    _queueSubscription = syncService.queueStream.listen(
      (queue) => _onQueueChanged(queue, logger),
      onError: (error, stack) {
        // logging
      },
    );

    // Initialize with current state
    _updateStateFromService(syncService, logger);

    // logging
    return initialState;
  }

  /// Stream subscriptions for cleanup
  StreamSubscription<SyncOperationStatus>? _statusSubscription;
  StreamSubscription<List<dynamic>>? _queueSubscription;

  /// Load persisted state from storage
  /// NOTE: State persistence disabled due to type mismatch between domain/presentation SyncState
  Future<void> _loadPersistedState(
    LoggingService logger,
    SyncState initialState,
  ) async {
    // State persistence disabled
  }

  /// Save current state to persistent storage
  /// NOTE: State persistence disabled due to type mismatch between domain/presentation SyncState
  Future<void> _saveState(
    LoggingService logger,
  ) async {
    // State persistence disabled
  }

  /// Handle sync status changes from the sync service
  void _onStatusChanged(
    SyncOperationStatus newStatus,
    LoggingService logger,
  ) {
    // logging

    // Update state with new status
    state = state.copyWith(
      status: newStatus,
      lastStatusChangeAt: DateTime.now(),
    );

    // Track successful/failed sync results
    if (newStatus == SyncOperationStatus.success) {
      // Get queue size for success count (operations processed)
      state = state.copyWith(
        lastSuccessfulSyncAt: DateTime.now(),
        lastSuccessCount: 0,
        clearLastError: true,
      );
    } else if (newStatus == SyncOperationStatus.failed) {
      state = state.copyWith(
        lastError: 'Sync failed',
        lastFailureCount: state.queueSize,
      );
    }

    // Update processing state
    state = state.copyWith(
      isProcessing: newStatus == SyncOperationStatus.syncing,
    );

    // Persist state after status change
  }

  /// Handle queue changes from the sync service
  void _onQueueChanged(
    List<dynamic> queue,
    LoggingService logger,
  ) {
    // logging

    state = state.copyWith(
      queueSize: queue.length,
      hasPendingOperations: queue.isNotEmpty,
    );

    // Update status based on queue state
    if (queue.isNotEmpty && state.status == SyncOperationStatus.idle) {
      state = state.copyWith(
        status: SyncOperationStatus.pending,
        lastStatusChangeAt: DateTime.now(),
      );
    } else if (queue.isEmpty && state.status == SyncOperationStatus.pending) {
      state = state.copyWith(
        status: SyncOperationStatus.idle,
        lastStatusChangeAt: DateTime.now(),
      );
    }

    // Persist state after queue change
  }

  /// Update state from current sync service state
  ///
  /// Called during initialization to ensure state reflects current conditions.
  void _updateStateFromService(
    SyncService syncService,
    LoggingService logger,
  ) {
    state = SyncState(
      status: syncService.status,
      queueSize: syncService.queueSize,
      isProcessing: syncService.isProcessing,
      lastStatusChangeAt: DateTime.now(),
      hasPendingOperations: syncService.queueSize > 0,
    );

    // logger.debug('SyncState: Initial state - ${state.toString()}');
  }

  /// Refresh state from sync service
  ///
  /// Can be called to manually refresh state if needed.
  void refresh() {
    final syncService = ref.read(syncServiceProvider);
    final logger = ref.read(loggingServiceProvider);
    // logging
    _updateStateFromService(syncService, logger);
  }

  /// Reset state to initial
  ///
  /// Clears all sync state information.
  Future<void> reset() async {
    state = SyncState.initial();
  }
}
