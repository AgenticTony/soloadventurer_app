// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing check-in state
/// Handles check-in creation, completion, scheduling, and cancellation
///
/// Riverpod 2 Compliant:
/// - Uses AutoDisposeNotifier (auto-disposes when unused)
/// - NO getters in state - all derived values are fields
/// - UI reads STATE only via ref.watch()
/// - UI calls methods via ref.read(provider.notifier)

@ProviderFor(CheckInNotifier)
const checkInProvider = CheckInNotifierProvider._();

/// Notifier for managing check-in state
/// Handles check-in creation, completion, scheduling, and cancellation
///
/// Riverpod 2 Compliant:
/// - Uses AutoDisposeNotifier (auto-disposes when unused)
/// - NO getters in state - all derived values are fields
/// - UI reads STATE only via ref.watch()
/// - UI calls methods via ref.read(provider.notifier)
final class CheckInNotifierProvider
    extends $NotifierProvider<CheckInNotifier, CheckInState> {
  /// Notifier for managing check-in state
  /// Handles check-in creation, completion, scheduling, and cancellation
  ///
  /// Riverpod 2 Compliant:
  /// - Uses AutoDisposeNotifier (auto-disposes when unused)
  /// - NO getters in state - all derived values are fields
  /// - UI reads STATE only via ref.watch()
  /// - UI calls methods via ref.read(provider.notifier)
  const CheckInNotifierProvider._()
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
  Override overrideWithValue(CheckInState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckInState>(value),
    );
  }
}

String _$checkInNotifierHash() => r'5f03485d2f8003002814898dac134ba82296eacf';

/// Notifier for managing check-in state
/// Handles check-in creation, completion, scheduling, and cancellation
///
/// Riverpod 2 Compliant:
/// - Uses AutoDisposeNotifier (auto-disposes when unused)
/// - NO getters in state - all derived values are fields
/// - UI reads STATE only via ref.watch()
/// - UI calls methods via ref.read(provider.notifier)

abstract class _$CheckInNotifier extends $Notifier<CheckInState> {
  CheckInState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CheckInState, CheckInState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<CheckInState, CheckInState>,
        CheckInState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
