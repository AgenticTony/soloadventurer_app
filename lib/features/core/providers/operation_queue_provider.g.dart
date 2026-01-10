// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_queue_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that exposes the operation queue state to the UI
///
/// This provider provides a reactive state object that UI components can
/// consume to display queue status, pending/failed operations, and processing state.
///
/// Note: Call refreshState() to update the state after operations are added
/// or processed. The state does not auto-update to avoid excessive rebuilds.

@ProviderFor(OperationQueueNotifier)
final operationQueueProvider = OperationQueueNotifierProvider._();

/// Provider that exposes the operation queue state to the UI
///
/// This provider provides a reactive state object that UI components can
/// consume to display queue status, pending/failed operations, and processing state.
///
/// Note: Call refreshState() to update the state after operations are added
/// or processed. The state does not auto-update to avoid excessive rebuilds.
final class OperationQueueNotifierProvider
    extends $NotifierProvider<OperationQueueNotifier, OperationQueueState> {
  /// Provider that exposes the operation queue state to the UI
  ///
  /// This provider provides a reactive state object that UI components can
  /// consume to display queue status, pending/failed operations, and processing state.
  ///
  /// Note: Call refreshState() to update the state after operations are added
  /// or processed. The state does not auto-update to avoid excessive rebuilds.
  OperationQueueNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'operationQueueProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$operationQueueNotifierHash();

  @$internal
  @override
  OperationQueueNotifier create() => OperationQueueNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OperationQueueState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OperationQueueState>(value),
    );
  }
}

String _$operationQueueNotifierHash() =>
    r'3ce94f895390e0387a91fb64f0d1ec3e391de1cc';

/// Provider that exposes the operation queue state to the UI
///
/// This provider provides a reactive state object that UI components can
/// consume to display queue status, pending/failed operations, and processing state.
///
/// Note: Call refreshState() to update the state after operations are added
/// or processed. The state does not auto-update to avoid excessive rebuilds.

abstract class _$OperationQueueNotifier extends $Notifier<OperationQueueState> {
  OperationQueueState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OperationQueueState, OperationQueueState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<OperationQueueState, OperationQueueState>,
        OperationQueueState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
