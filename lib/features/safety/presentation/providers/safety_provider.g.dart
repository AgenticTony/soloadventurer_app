// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier for managing overall safety state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields

@ProviderFor(Safety)
const safetyProvider = SafetyProvider._();

/// AsyncNotifier for managing overall safety state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields
final class SafetyProvider extends $AsyncNotifierProvider<Safety, SafetyState> {
  /// AsyncNotifier for managing overall safety state.
  ///
  /// Riverpod 3.0 Compliant:
  /// - Uses @riverpod annotation with code generation
  /// - AsyncNotifier with AsyncValue handles loading/error
  /// - State no longer has isLoading/error fields
  const SafetyProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'safetyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$safetyHash();

  @$internal
  @override
  Safety create() => Safety();
}

String _$safetyHash() => r'5b322a94416f5bc44e0d85b9027d2ab5b81756f5';

/// AsyncNotifier for managing overall safety state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields

abstract class _$Safety extends $AsyncNotifier<SafetyState> {
  FutureOr<SafetyState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<SafetyState>, SafetyState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<SafetyState>, SafetyState>,
        AsyncValue<SafetyState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
