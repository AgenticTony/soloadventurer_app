// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the itinerary generation repository
///
/// Provides the repository implementation that connects to the
/// itinerary generation service. This can be overridden with mocks
/// for testing.
///
/// Note: This uses a mock implementation that returns dummy itineraries.
/// In production, this should be replaced with GetIt injection of the
/// actual service implementation when the itinerary generation service
/// is complete.

@ProviderFor(itineraryGenerationRepository)
final itineraryGenerationRepositoryProvider =
    ItineraryGenerationRepositoryProvider._();

/// Provider for the itinerary generation repository
///
/// Provides the repository implementation that connects to the
/// itinerary generation service. This can be overridden with mocks
/// for testing.
///
/// Note: This uses a mock implementation that returns dummy itineraries.
/// In production, this should be replaced with GetIt injection of the
/// actual service implementation when the itinerary generation service
/// is complete.

final class ItineraryGenerationRepositoryProvider extends $FunctionalProvider<
        ItineraryGenerationRepository,
        ItineraryGenerationRepository,
        ItineraryGenerationRepository>
    with $Provider<ItineraryGenerationRepository> {
  /// Provider for the itinerary generation repository
  ///
  /// Provides the repository implementation that connects to the
  /// itinerary generation service. This can be overridden with mocks
  /// for testing.
  ///
  /// Note: This uses a mock implementation that returns dummy itineraries.
  /// In production, this should be replaced with GetIt injection of the
  /// actual service implementation when the itinerary generation service
  /// is complete.
  ItineraryGenerationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'itineraryGenerationRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itineraryGenerationRepositoryHash();

  @$internal
  @override
  $ProviderElement<ItineraryGenerationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItineraryGenerationRepository create(Ref ref) {
    return itineraryGenerationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItineraryGenerationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<ItineraryGenerationRepository>(value),
    );
  }
}

String _$itineraryGenerationRepositoryHash() =>
    r'7ed1a51ae012b2b139f065daca256244331bbbcb';

/// Provider for the generate starter itinerary use case
///
/// Provides the use case that orchestrates itinerary generation
/// from onboarding data.

@ProviderFor(generateStarterItinerary)
final generateStarterItineraryProvider = GenerateStarterItineraryProvider._();

/// Provider for the generate starter itinerary use case
///
/// Provides the use case that orchestrates itinerary generation
/// from onboarding data.

final class GenerateStarterItineraryProvider extends $FunctionalProvider<
    GenerateStarterItinerary,
    GenerateStarterItinerary,
    GenerateStarterItinerary> with $Provider<GenerateStarterItinerary> {
  /// Provider for the generate starter itinerary use case
  ///
  /// Provides the use case that orchestrates itinerary generation
  /// from onboarding data.
  GenerateStarterItineraryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'generateStarterItineraryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$generateStarterItineraryHash();

  @$internal
  @override
  $ProviderElement<GenerateStarterItinerary> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GenerateStarterItinerary create(Ref ref) {
    return generateStarterItinerary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GenerateStarterItinerary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GenerateStarterItinerary>(value),
    );
  }
}

String _$generateStarterItineraryHash() =>
    r'a2c07ae6fa68958e686bbf27b1700b928664fe74';

/// Provider for accessing the current onboarding data
///
/// Convenience provider that extracts the current OnboardingData
/// from the OnboardingState.

@ProviderFor(currentOnboardingData)
final currentOnboardingDataProvider = CurrentOnboardingDataProvider._();

/// Provider for accessing the current onboarding data
///
/// Convenience provider that extracts the current OnboardingData
/// from the OnboardingState.

final class CurrentOnboardingDataProvider extends $FunctionalProvider<
    OnboardingData?,
    OnboardingData?,
    OnboardingData?> with $Provider<OnboardingData?> {
  /// Provider for accessing the current onboarding data
  ///
  /// Convenience provider that extracts the current OnboardingData
  /// from the OnboardingState.
  CurrentOnboardingDataProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentOnboardingDataProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentOnboardingDataHash();

  @$internal
  @override
  $ProviderElement<OnboardingData?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OnboardingData? create(Ref ref) {
    return currentOnboardingData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingData? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingData?>(value),
    );
  }
}

String _$currentOnboardingDataHash() =>
    r'a69ef526c34f66061f973682c18ff68d86b936f3';

/// Provider for checking if the form is valid
///
/// Convenience provider that extracts the validation status
/// from the OnboardingState.

@ProviderFor(isOnboardingFormValid)
final isOnboardingFormValidProvider = IsOnboardingFormValidProvider._();

/// Provider for checking if the form is valid
///
/// Convenience provider that extracts the validation status
/// from the OnboardingState.

final class IsOnboardingFormValidProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Provider for checking if the form is valid
  ///
  /// Convenience provider that extracts the validation status
  /// from the OnboardingState.
  IsOnboardingFormValidProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isOnboardingFormValidProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isOnboardingFormValidHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOnboardingFormValid(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isOnboardingFormValidHash() =>
    r'c66e325a33cea9426231fbed2a08511907d272e4';

/// Provider for accessing validation errors
///
/// Convenience provider that extracts validation errors
/// from the OnboardingState.

@ProviderFor(onboardingValidationErrors)
final onboardingValidationErrorsProvider =
    OnboardingValidationErrorsProvider._();

/// Provider for accessing validation errors
///
/// Convenience provider that extracts validation errors
/// from the OnboardingState.

final class OnboardingValidationErrorsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// Provider for accessing validation errors
  ///
  /// Convenience provider that extracts validation errors
  /// from the OnboardingState.
  OnboardingValidationErrorsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'onboardingValidationErrorsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$onboardingValidationErrorsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return onboardingValidationErrors(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$onboardingValidationErrorsHash() =>
    r'ca675593e036a3c296b8c3a65c5de75bb2d8119e';

/// Provider for checking if the form is submitting
///
/// Convenience provider that extracts the submitting status
/// from the OnboardingState.

@ProviderFor(isOnboardingSubmitting)
final isOnboardingSubmittingProvider = IsOnboardingSubmittingProvider._();

/// Provider for checking if the form is submitting
///
/// Convenience provider that extracts the submitting status
/// from the OnboardingState.

final class IsOnboardingSubmittingProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Provider for checking if the form is submitting
  ///
  /// Convenience provider that extracts the submitting status
  /// from the OnboardingState.
  IsOnboardingSubmittingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isOnboardingSubmittingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isOnboardingSubmittingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOnboardingSubmitting(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isOnboardingSubmittingHash() =>
    r'6d0293904b9c34c471a9d359752cb3ae19764011';

/// Provider for accessing the generated itinerary
///
/// Convenience provider that extracts the itinerary from the
/// OnboardingState when available.

@ProviderFor(generatedItinerary)
final generatedItineraryProvider = GeneratedItineraryProvider._();

/// Provider for accessing the generated itinerary
///
/// Convenience provider that extracts the itinerary from the
/// OnboardingState when available.

final class GeneratedItineraryProvider extends $FunctionalProvider<
    Map<String, dynamic>?,
    Map<String, dynamic>?,
    Map<String, dynamic>?> with $Provider<Map<String, dynamic>?> {
  /// Provider for accessing the generated itinerary
  ///
  /// Convenience provider that extracts the itinerary from the
  /// OnboardingState when available.
  GeneratedItineraryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'generatedItineraryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$generatedItineraryHash();

  @$internal
  @override
  $ProviderElement<Map<String, dynamic>?> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, dynamic>? create(Ref ref) {
    return generatedItinerary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, dynamic>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, dynamic>?>(value),
    );
  }
}

String _$generatedItineraryHash() =>
    r'dec9eac788f509b9b5abbd231f1eaf414765845e';

/// Provider for accessing the error message
///
/// Convenience provider that extracts the error message
/// from the OnboardingState when available.

@ProviderFor(onboardingErrorMessage)
final onboardingErrorMessageProvider = OnboardingErrorMessageProvider._();

/// Provider for accessing the error message
///
/// Convenience provider that extracts the error message
/// from the OnboardingState when available.

final class OnboardingErrorMessageProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Provider for accessing the error message
  ///
  /// Convenience provider that extracts the error message
  /// from the OnboardingState when available.
  OnboardingErrorMessageProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'onboardingErrorMessageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$onboardingErrorMessageHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return onboardingErrorMessage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$onboardingErrorMessageHash() =>
    r'6b3f6b8708efa8463c9fed9c35d9f6467c4a6552';
