// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_queue.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A persistent priority queue for managing offline-capable operations.
///
/// The queue handles execution, retry logic, deduplication, and persistence of
/// operations across app restarts. Operations are processed based on priority,
/// network connectivity, and authentication status.
///
/// ## Features
/// - **Priority-based processing**: Critical operations execute first
/// - **Exponential backoff retry**: Failed operations retry with increasing delays
/// - **Deduplication**: Prevents redundant operations from accumulating
/// - **Persistence**: Survives app restarts and device reboots
/// - **Aging mechanism**: Low-priority operations get priority boost over time
/// - **Round-robin**: Ensures fair processing across priority levels
///
/// ## Thread Safety
/// All public methods are thread-safe. The queue processes operations
/// sequentially on a 30-second timer, preventing concurrent execution.
///
/// ## Usage Example
/// ```dart
/// final queue = ref.read(operationQueueProvider.notifier);
///
/// // Add an operation to the queue
/// await queue.addOperation(myOperation);
///
/// // Get pending operations
/// final pending = queue.getPendingOperations();
///
/// // Retry a failed operation
/// await queue.retryOperation(operationId);
///
/// // Clear all failed operations
/// await queue.clearFailedOperations();
/// ```
///
/// See [QueueableOperation] for creating custom operations.

@ProviderFor(OperationQueue)
final operationQueueProvider = OperationQueueProvider._();

/// A persistent priority queue for managing offline-capable operations.
///
/// The queue handles execution, retry logic, deduplication, and persistence of
/// operations across app restarts. Operations are processed based on priority,
/// network connectivity, and authentication status.
///
/// ## Features
/// - **Priority-based processing**: Critical operations execute first
/// - **Exponential backoff retry**: Failed operations retry with increasing delays
/// - **Deduplication**: Prevents redundant operations from accumulating
/// - **Persistence**: Survives app restarts and device reboots
/// - **Aging mechanism**: Low-priority operations get priority boost over time
/// - **Round-robin**: Ensures fair processing across priority levels
///
/// ## Thread Safety
/// All public methods are thread-safe. The queue processes operations
/// sequentially on a 30-second timer, preventing concurrent execution.
///
/// ## Usage Example
/// ```dart
/// final queue = ref.read(operationQueueProvider.notifier);
///
/// // Add an operation to the queue
/// await queue.addOperation(myOperation);
///
/// // Get pending operations
/// final pending = queue.getPendingOperations();
///
/// // Retry a failed operation
/// await queue.retryOperation(operationId);
///
/// // Clear all failed operations
/// await queue.clearFailedOperations();
/// ```
///
/// See [QueueableOperation] for creating custom operations.
final class OperationQueueProvider
    extends $AsyncNotifierProvider<OperationQueue, void> {
  /// A persistent priority queue for managing offline-capable operations.
  ///
  /// The queue handles execution, retry logic, deduplication, and persistence of
  /// operations across app restarts. Operations are processed based on priority,
  /// network connectivity, and authentication status.
  ///
  /// ## Features
  /// - **Priority-based processing**: Critical operations execute first
  /// - **Exponential backoff retry**: Failed operations retry with increasing delays
  /// - **Deduplication**: Prevents redundant operations from accumulating
  /// - **Persistence**: Survives app restarts and device reboots
  /// - **Aging mechanism**: Low-priority operations get priority boost over time
  /// - **Round-robin**: Ensures fair processing across priority levels
  ///
  /// ## Thread Safety
  /// All public methods are thread-safe. The queue processes operations
  /// sequentially on a 30-second timer, preventing concurrent execution.
  ///
  /// ## Usage Example
  /// ```dart
  /// final queue = ref.read(operationQueueProvider.notifier);
  ///
  /// // Add an operation to the queue
  /// await queue.addOperation(myOperation);
  ///
  /// // Get pending operations
  /// final pending = queue.getPendingOperations();
  ///
  /// // Retry a failed operation
  /// await queue.retryOperation(operationId);
  ///
  /// // Clear all failed operations
  /// await queue.clearFailedOperations();
  /// ```
  ///
  /// See [QueueableOperation] for creating custom operations.
  OperationQueueProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'operationQueueProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$operationQueueHash();

  @$internal
  @override
  OperationQueue create() => OperationQueue();
}

String _$operationQueueHash() => r'78ae38ad1e528696c5595c63d91fdd9f83e02590';

/// A persistent priority queue for managing offline-capable operations.
///
/// The queue handles execution, retry logic, deduplication, and persistence of
/// operations across app restarts. Operations are processed based on priority,
/// network connectivity, and authentication status.
///
/// ## Features
/// - **Priority-based processing**: Critical operations execute first
/// - **Exponential backoff retry**: Failed operations retry with increasing delays
/// - **Deduplication**: Prevents redundant operations from accumulating
/// - **Persistence**: Survives app restarts and device reboots
/// - **Aging mechanism**: Low-priority operations get priority boost over time
/// - **Round-robin**: Ensures fair processing across priority levels
///
/// ## Thread Safety
/// All public methods are thread-safe. The queue processes operations
/// sequentially on a 30-second timer, preventing concurrent execution.
///
/// ## Usage Example
/// ```dart
/// final queue = ref.read(operationQueueProvider.notifier);
///
/// // Add an operation to the queue
/// await queue.addOperation(myOperation);
///
/// // Get pending operations
/// final pending = queue.getPendingOperations();
///
/// // Retry a failed operation
/// await queue.retryOperation(operationId);
///
/// // Clear all failed operations
/// await queue.clearFailedOperations();
/// ```
///
/// See [QueueableOperation] for creating custom operations.

abstract class _$OperationQueue extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
