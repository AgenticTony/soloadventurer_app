// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing overall safety state
/// Handles safety status, emergency SOS, and safety alerts
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - Uses Notifier base class instead of StateNotifier
/// - Dependencies accessed via ref.watch() in methods

@ProviderFor(Safety)
const safetyProvider = SafetyProvider._();

/// Notifier for managing overall safety state
/// Handles safety status, emergency SOS, and safety alerts
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - Uses Notifier base class instead of StateNotifier
/// - Dependencies accessed via ref.watch() in methods
final class SafetyProvider extends $NotifierProvider<Safety, SafetyState> {
  /// Notifier for managing overall safety state
  /// Handles safety status, emergency SOS, and safety alerts
  ///
  /// Riverpod 3.0 Compliant:
  /// - Uses @riverpod annotation with code generation
  /// - Uses Notifier base class instead of StateNotifier
  /// - Dependencies accessed via ref.watch() in methods
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyState>(value),
    );
  }
}

String _$safetyHash() => r'9f1144cbd88801ffdad78f522fbc099beec139e6';

/// Notifier for managing overall safety state
/// Handles safety status, emergency SOS, and safety alerts
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - Uses Notifier base class instead of StateNotifier
/// - Dependencies accessed via ref.watch() in methods

abstract class _$Safety extends $Notifier<SafetyState> {
  SafetyState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SafetyState, SafetyState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SafetyState, SafetyState>, SafetyState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
