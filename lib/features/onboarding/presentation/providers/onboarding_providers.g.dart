// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itineraryGenerationRepositoryHash() =>
    r'7ed1a51ae012b2b139f065daca256244331bbbcb';

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
///
/// Copied from [itineraryGenerationRepository].
@ProviderFor(itineraryGenerationRepository)
final itineraryGenerationRepositoryProvider =
    AutoDisposeProvider<ItineraryGenerationRepository>.internal(
  itineraryGenerationRepository,
  name: r'itineraryGenerationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itineraryGenerationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ItineraryGenerationRepositoryRef
    = AutoDisposeProviderRef<ItineraryGenerationRepository>;
String _$generateStarterItineraryHash() =>
    r'a2c07ae6fa68958e686bbf27b1700b928664fe74';

/// Provider for the generate starter itinerary use case
///
/// Provides the use case that orchestrates itinerary generation
/// from onboarding data.
///
/// Copied from [generateStarterItinerary].
@ProviderFor(generateStarterItinerary)
final generateStarterItineraryProvider =
    AutoDisposeProvider<GenerateStarterItinerary>.internal(
  generateStarterItinerary,
  name: r'generateStarterItineraryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$generateStarterItineraryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GenerateStarterItineraryRef
    = AutoDisposeProviderRef<GenerateStarterItinerary>;
String _$currentOnboardingDataHash() =>
    r'af0fca7afb96ebbb8b483bc88dc8d8bb19710a40';

/// Provider for accessing the current onboarding data
///
/// Convenience provider that extracts the current OnboardingData
/// from the OnboardingState.
///
/// Copied from [currentOnboardingData].
@ProviderFor(currentOnboardingData)
final currentOnboardingDataProvider =
    AutoDisposeProvider<OnboardingData?>.internal(
  currentOnboardingData,
  name: r'currentOnboardingDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentOnboardingDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentOnboardingDataRef = AutoDisposeProviderRef<OnboardingData?>;
String _$isOnboardingFormValidHash() =>
    r'ca61be0d40894ec7366ed6aed3eb3af38b6d4063';

/// Provider for checking if the form is valid
///
/// Convenience provider that extracts the validation status
/// from the OnboardingState.
///
/// Copied from [isOnboardingFormValid].
@ProviderFor(isOnboardingFormValid)
final isOnboardingFormValidProvider = AutoDisposeProvider<bool>.internal(
  isOnboardingFormValid,
  name: r'isOnboardingFormValidProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isOnboardingFormValidHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsOnboardingFormValidRef = AutoDisposeProviderRef<bool>;
String _$onboardingValidationErrorsHash() =>
    r'70df35f149943252bb026d86f7f8770d225edbe9';

/// Provider for accessing validation errors
///
/// Convenience provider that extracts validation errors
/// from the OnboardingState.
///
/// Copied from [onboardingValidationErrors].
@ProviderFor(onboardingValidationErrors)
final onboardingValidationErrorsProvider =
    AutoDisposeProvider<List<String>>.internal(
  onboardingValidationErrors,
  name: r'onboardingValidationErrorsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingValidationErrorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnboardingValidationErrorsRef = AutoDisposeProviderRef<List<String>>;
String _$isOnboardingSubmittingHash() =>
    r'07314e8cfa63c5d06fe010ce887c91e362564f1f';

/// Provider for checking if the form is submitting
///
/// Convenience provider that extracts the submitting status
/// from the OnboardingState.
///
/// Copied from [isOnboardingSubmitting].
@ProviderFor(isOnboardingSubmitting)
final isOnboardingSubmittingProvider = AutoDisposeProvider<bool>.internal(
  isOnboardingSubmitting,
  name: r'isOnboardingSubmittingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isOnboardingSubmittingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsOnboardingSubmittingRef = AutoDisposeProviderRef<bool>;
String _$generatedItineraryHash() =>
    r'950cba847cdea72feef66253db09c69e6e260e14';

/// Provider for accessing the generated itinerary
///
/// Convenience provider that extracts the itinerary from the
/// OnboardingState when available.
///
/// Copied from [generatedItinerary].
@ProviderFor(generatedItinerary)
final generatedItineraryProvider =
    AutoDisposeProvider<Map<String, dynamic>?>.internal(
  generatedItinerary,
  name: r'generatedItineraryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$generatedItineraryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GeneratedItineraryRef = AutoDisposeProviderRef<Map<String, dynamic>?>;
String _$onboardingErrorMessageHash() =>
    r'c6a9c99278347d32a4b7de50b7500bc525a53aaf';

/// Provider for accessing the error message
///
/// Convenience provider that extracts the error message
/// from the OnboardingState when available.
///
/// Copied from [onboardingErrorMessage].
@ProviderFor(onboardingErrorMessage)
final onboardingErrorMessageProvider = AutoDisposeProvider<String?>.internal(
  onboardingErrorMessage,
  name: r'onboardingErrorMessageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingErrorMessageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnboardingErrorMessageRef = AutoDisposeProviderRef<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
