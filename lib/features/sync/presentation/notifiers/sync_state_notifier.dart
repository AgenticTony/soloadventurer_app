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
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Uses AsyncNotifier pattern with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - isProcessing/lastError removed from state (AsyncValue handles them)
/// - Stream subscriptions update state via AsyncData
/// - UI reads state via ref.watch(syncStateProvider)
/// - UI calls methods via ref.read(syncStateProvider.notifier)
@riverpod
class SyncStateNotifier extends _$SyncStateNotifier {
  /// Stream subscriptions for cleanup
  StreamSubscription<SyncOperationStatus>? _statusSubscription;
  StreamSubscription<List<dynamic>>? _queueSubscription;

  /// Initialize the notifier and subscribe to sync service streams
  @override
  Future<SyncState> build() async {
    // Get dependencies via ref.watch()
    final syncService = ref.watch(syncServiceProvider);
    final logger = ref.watch(loggingServiceProvider);

    // Set up cleanup using ref.onDispose()
    ref.onDispose(() {
      _statusSubscription?.cancel();
      _queueSubscription?.cancel();
    });

    // Initialize state from current service state
    final initialState = _buildStateFromService(syncService);

    // Subscribe to status changes
    _statusSubscription = syncService.statusStream.listen(
      (status) => _onStatusChanged(status, logger),
      onError: (error, stack) {
        // Handle stream errors
      },
    );

    // Subscribe to queue changes
    _queueSubscription = syncService.queueStream.listen(
      (queue) => _onQueueChanged(queue, logger),
      onError: (error, stack) {
        // Handle stream errors
      },
    );

    return initialState;
  }

  /// Build initial state from current sync service state
  SyncState _buildStateFromService(SyncService syncService) {
    return SyncState(
      status: syncService.status,
      queueSize: syncService.queueSize,
      lastStatusChangeAt: DateTime.now(),
      hasPendingOperations: syncService.queueSize > 0,
    );
  }

  /// Handle sync status changes from the sync service
  void _onStatusChanged(
    SyncOperationStatus newStatus,
    LoggingService logger,
  ) {
    final current = state.value;
    if (current == null) return;

    var newState = current.copyWith(
      status: newStatus,
      lastStatusChangeAt: DateTime.now(),
    );

    // Track successful/failed sync results
    if (newStatus == SyncOperationStatus.success) {
      newState = newState.copyWith(
        lastSuccessfulSyncAt: DateTime.now(),
        lastSuccessCount: 0,
      );
    } else if (newStatus == SyncOperationStatus.failed) {
      newState = newState.copyWith(
        lastFailureCount: current.queueSize,
      );
    }

    state = AsyncData(newState);
  }

  /// Handle queue changes from the sync service
  void _onQueueChanged(
    List<dynamic> queue,
    LoggingService logger,
  ) {
    final current = state.value;
    if (current == null) return;

    var newState = current.copyWith(
      queueSize: queue.length,
      hasPendingOperations: queue.isNotEmpty,
    );

    // Update status based on queue state
    if (queue.isNotEmpty && current.status == SyncOperationStatus.idle) {
      newState = newState.copyWith(
        status: SyncOperationStatus.pending,
        lastStatusChangeAt: DateTime.now(),
      );
    } else if (queue.isEmpty &&
        current.status == SyncOperationStatus.pending) {
      newState = newState.copyWith(
        status: SyncOperationStatus.idle,
        lastStatusChangeAt: DateTime.now(),
      );
    }

    state = AsyncData(newState);
  }

  /// Refresh state from sync service
  void refresh() {
    final syncService = ref.read(syncServiceProvider);
    state = AsyncData(_buildStateFromService(syncService));
  }

  /// Reset state to initial
  Future<void> reset() async {
    state = const AsyncData(SyncState(
      status: SyncOperationStatus.idle,
      queueSize: 0,
    ));
  }
}
