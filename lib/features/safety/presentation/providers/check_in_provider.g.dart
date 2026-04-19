// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier for managing check-in state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields

@ProviderFor(CheckInNotifier)
const checkInProvider = CheckInNotifierProvider._();

/// AsyncNotifier for managing check-in state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields
final class CheckInNotifierProvider
    extends $AsyncNotifierProvider<CheckInNotifier, CheckInState> {
  /// AsyncNotifier for managing check-in state.
  ///
  /// Riverpod 3.0 Compliant:
  /// - Uses @riverpod annotation with code generation
  /// - AsyncNotifier with AsyncValue handles loading/error
  /// - State no longer has isLoading/error fields
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
}

String _$checkInNotifierHash() => r'49533cea7a60c7d7948028da729a1c1c8c96bd1d';

/// AsyncNotifier for managing check-in state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields

abstract class _$CheckInNotifier extends $AsyncNotifier<CheckInState> {
  FutureOr<CheckInState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<CheckInState>, CheckInState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<CheckInState>, CheckInState>,
        AsyncValue<CheckInState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
