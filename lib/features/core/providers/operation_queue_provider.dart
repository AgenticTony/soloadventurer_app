import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/operation_queue.dart' show QueueableOperation;
import '../services/operation_queue.dart' as services;

part 'operation_queue_provider.freezed.dart';
part 'operation_queue_provider.g.dart';

/// State of the operation queue
@freezed
sealed class OperationQueueState with _$OperationQueueState {
  const factory OperationQueueState({
    /// List of pending operations waiting to be processed
    @Default([]) List<QueueableOperation> pendingOperations,

    /// List of failed operations that exceeded max retries
    @Default([]) List<QueueableOperation> failedOperations,

    /// Whether the queue is currently processing operations
    @Default(false) bool isProcessing,

    /// Count of pending operations
    @Default(0) int pendingCount,

    /// Count of failed operations
    @Default(0) int failedCount,
  }) = _OperationQueueState;
}

/// Provider that exposes the operation queue state to the UI
///
/// This provider provides a reactive state object that UI components can
/// consume to display queue status, pending/failed operations, and processing state.
///
/// Note: Call refreshState() to update the state after operations are added
/// or processed. The state does not auto-update to avoid excessive rebuilds.
@riverpod
class OperationQueueNotifier extends _$OperationQueueNotifier {
  @override
  OperationQueueState build() {
    // Don't auto-watch to avoid excessive rebuilds.
    // The queue will be accessed synchronously when needed.
    // Provide initial empty state.
    return const OperationQueueState(
      pendingOperations: [],
      failedOperations: [],
      isProcessing: false,
      pendingCount: 0,
      failedCount: 0,
    );
  }

  /// Refresh the queue state from the OperationQueue
  ///
  /// Call this method after performing actions that modify the queue
  /// to ensure the UI reflects the latest state.
  void refreshState() {
    final queue = ref.read(services.operationQueueProvider.notifier);
    final pendingOps = queue.getPendingOperations();
    final failedOps = queue.getFailedOperations();

    state = OperationQueueState(
      pendingOperations: pendingOps,
      failedOperations: failedOps,
      isProcessing: queue.isProcessing,
      pendingCount: pendingOps.length,
      failedCount: failedOps.length,
    );
  }

  /// Retry a specific failed operation by ID
  Future<void> retryOperation(String id) async {
    final queue = ref.read(services.operationQueueProvider.notifier);
    await queue.retryOperation(id);
    refreshState();
  }

  /// Retry all failed operations
  Future<void> retryAllFailed() async {
    final queue = ref.read(services.operationQueueProvider.notifier);
    await queue.retryAllFailed();
    refreshState();
  }

  /// Clear all failed operations
  Future<void> clearFailedOperations() async {
    final queue = ref.read(services.operationQueueProvider.notifier);
    await queue.clearFailedOperations();
    refreshState();
  }

  /// Remove a specific failed operation by ID
  Future<void> removeFailedOperation(String id) async {
    final queue = ref.read(services.operationQueueProvider.notifier);
    await queue.removeFailedOperation(id);
    refreshState();
  }

  /// Process the queue manually
  Future<void> processQueue() async {
    final queue = ref.read(services.operationQueueProvider.notifier);
    await queue.processQueue();
    refreshState();
  }
}
