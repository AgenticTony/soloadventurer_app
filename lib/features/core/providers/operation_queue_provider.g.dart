// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_queue_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$operationQueueNotifierHash() =>
    r'3ce94f895390e0387a91fb64f0d1ec3e391de1cc';

/// Provider that exposes the operation queue state to the UI
///
/// This provider provides a reactive state object that UI components can
/// consume to display queue status, pending/failed operations, and processing state.
///
/// Note: Call refreshState() to update the state after operations are added
/// or processed. The state does not auto-update to avoid excessive rebuilds.
///
/// Copied from [OperationQueueNotifier].
@ProviderFor(OperationQueueNotifier)
final operationQueueNotifierProvider = AutoDisposeNotifierProvider<
    OperationQueueNotifier, OperationQueueState>.internal(
  OperationQueueNotifier.new,
  name: r'operationQueueNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$operationQueueNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OperationQueueNotifier = AutoDisposeNotifier<OperationQueueState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
