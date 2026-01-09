// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_queue.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$operationQueueHash() => r'025b05f9d17043aca094b7a380d252f8028977a8';

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
///
/// Copied from [OperationQueue].
@ProviderFor(OperationQueue)
final operationQueueProvider =
    AutoDisposeAsyncNotifierProvider<OperationQueue, void>.internal(
  OperationQueue.new,
  name: r'operationQueueProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$operationQueueHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OperationQueue = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
