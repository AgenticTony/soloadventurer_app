// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing check-in state
/// Handles creating, completing, scheduling, and cancelling check-ins

@ProviderFor(CheckInNotifier)
final checkInProvider = CheckInNotifierProvider._();

/// Notifier for managing check-in state
/// Handles creating, completing, scheduling, and cancelling check-ins
final class CheckInNotifierProvider
    extends $NotifierProvider<CheckInNotifier, AsyncValue<CheckInData>> {
  /// Notifier for managing check-in state
  /// Handles creating, completing, scheduling, and cancelling check-ins
  CheckInNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'checkInProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$checkInNotifierHash();

  @$internal
  @override
  CheckInNotifier create() => CheckInNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CheckInData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CheckInData>>(value),
    );
  }
}

String _$checkInNotifierHash() => r'5323c26a3bac10bff258e58fc293758b59f2e87c';

/// Notifier for managing check-in state
/// Handles creating, completing, scheduling, and cancelling check-ins

abstract class _$CheckInNotifier extends $Notifier<AsyncValue<CheckInData>> {
  AsyncValue<CheckInData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CheckInData>, AsyncValue<CheckInData>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<CheckInData>, AsyncValue<CheckInData>>,
        AsyncValue<CheckInData>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
