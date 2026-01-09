// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing onboarding form state
///
/// Handles the onboarding flow from form input through itinerary generation.
/// Uses a freezed state union type to represent the different states of
/// the onboarding process.

@ProviderFor(OnboardingNotifier)
final onboardingProvider = OnboardingNotifierProvider._();

/// Notifier for managing onboarding form state
///
/// Handles the onboarding flow from form input through itinerary generation.
/// Uses a freezed state union type to represent the different states of
/// the onboarding process.
final class OnboardingNotifierProvider
    extends $NotifierProvider<OnboardingNotifier, OnboardingState> {
  /// Notifier for managing onboarding form state
  ///
  /// Handles the onboarding flow from form input through itinerary generation.
  /// Uses a freezed state union type to represent the different states of
  /// the onboarding process.
  OnboardingNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'onboardingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$onboardingNotifierHash();

  @$internal
  @override
  OnboardingNotifier create() => OnboardingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingState>(value),
    );
  }
}

String _$onboardingNotifierHash() =>
    r'481660f3d90bfb5cbaa18b6df2731ac0ce2a54d1';

/// Notifier for managing onboarding form state
///
/// Handles the onboarding flow from form input through itinerary generation.
/// Uses a freezed state union type to represent the different states of
/// the onboarding process.

abstract class _$OnboardingNotifier extends $Notifier<OnboardingState> {
  OnboardingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OnboardingState, OnboardingState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<OnboardingState, OnboardingState>,
        OnboardingState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
