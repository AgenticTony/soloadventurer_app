// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing overall safety state
/// Handles safety status, emergency SOS, and safety alerts

@ProviderFor(SafetyNotifier)
final safetyProvider = SafetyNotifierProvider._();

/// Notifier for managing overall safety state
/// Handles safety status, emergency SOS, and safety alerts
final class SafetyNotifierProvider
    extends $NotifierProvider<SafetyNotifier, AsyncValue<SafetyData>> {
  /// Notifier for managing overall safety state
  /// Handles safety status, emergency SOS, and safety alerts
  SafetyNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$safetyNotifierHash();

  @$internal
  @override
  SafetyNotifier create() => SafetyNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<SafetyData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<SafetyData>>(value),
    );
  }
}

String _$safetyNotifierHash() => r'f86e3bef0880bbbfe32aeec77440987650b35f75';

/// Notifier for managing overall safety state
/// Handles safety status, emergency SOS, and safety alerts

abstract class _$SafetyNotifier extends $Notifier<AsyncValue<SafetyData>> {
  AsyncValue<SafetyData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SafetyData>, AsyncValue<SafetyData>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<SafetyData>, AsyncValue<SafetyData>>,
        AsyncValue<SafetyData>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
