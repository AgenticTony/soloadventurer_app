import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/onboarding/data/repositories/itinerary_generation_repository_impl.dart';
import 'package:soloadventurer/features/onboarding/data/services/itinerary_generation_service.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:soloadventurer/features/onboarding/domain/repositories/itinerary_generation_repository.dart';
import 'package:soloadventurer/features/onboarding/domain/usecases/generate_starter_itinerary.dart';
import 'package:soloadventurer/features/onboarding/presentation/notifiers/onboarding_notifier.dart';
import 'package:soloadventurer/features/onboarding/presentation/state/onboarding_state.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';

part 'onboarding_providers.g.dart';

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
@riverpod
ItineraryGenerationRepository itineraryGenerationRepository(
  Ref ref,
) {
  // Mock implementation for development/testing
  // The repository already contains mock behavior that returns
  // sample itinerary structures
  return ItineraryGenerationRepositoryImpl();
}

/// Mock service for development
///
/// This is a temporary placeholder until the actual itinerary
/// generation service is implemented. The repository uses this
/// but has its own mock logic built in.
class MockItineraryGenerationService implements ItineraryGenerationService {
  @override
  Future<Itinerary> generateFromOnboarding(OnboardingData data) {
    throw UnimplementedError(
      'Use generateStarterItinerary(Map) method on repository instead',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> generateDayPlan({
    required DateTime date,
    required Map<String, dynamic> destination,
    required Set<String> interests,
    List<Map<String, dynamic>>? weather,
    bool isFirstDay = false,
    bool isLastDay = false,
  }) {
    throw UnimplementedError('Not yet implemented');
  }

  @override
  Future<bool> canGenerateItinerary(OnboardingData data) async {
    return true;
  }
}

/// Provider for the generate starter itinerary use case
///
/// Provides the use case that orchestrates itinerary generation
/// from onboarding data.
@riverpod
GenerateStarterItinerary generateStarterItinerary(
  Ref ref,
) {
  final repository = ref.watch(itineraryGenerationRepositoryProvider);
  return GenerateStarterItinerary(repository);
}

// The onboardingProvider is auto-generated from the @riverpod
// annotation in onboarding_notifier.dart
// No need to define it manually here

/// Provider for accessing the current onboarding data
///
/// Convenience provider that extracts the current OnboardingData
/// from the OnboardingState.
@riverpod
OnboardingData? currentOnboardingData(Ref ref) {
  final state = ref.watch(onboardingProvider);
  return state.data;
}

/// Provider for checking if the form is valid
///
/// Convenience provider that extracts the validation status
/// from the OnboardingState.
@riverpod
bool isOnboardingFormValid(Ref ref) {
  final state = ref.watch(onboardingProvider);
  return switch (state) {
    OnboardingInProgress(isValid: final isValid) => isValid,
    OnboardingInitial() => false,
    OnboardingSubmitting() => false,
    OnboardingSuccess() => false,
    OnboardingError() => false,
  };
}

/// Provider for accessing validation errors
///
/// Convenience provider that extracts validation errors
/// from the OnboardingState.
@riverpod
List<String> onboardingValidationErrors(Ref ref) {
  final state = ref.watch(onboardingProvider);
  return switch (state) {
    OnboardingInProgress(validationErrors: final errors) => errors,
    OnboardingInitial() => [],
    OnboardingSubmitting() => [],
    OnboardingSuccess() => [],
    OnboardingError() => [],
  };
}

/// Provider for checking if the form is submitting
///
/// Convenience provider that extracts the submitting status
/// from the OnboardingState.
@riverpod
bool isOnboardingSubmitting(Ref ref) {
  final state = ref.watch(onboardingProvider);
  return state.isSubmitting;
}

/// Provider for accessing the generated itinerary
///
/// Convenience provider that extracts the itinerary from the
/// OnboardingState when available.
@riverpod
Map<String, dynamic>? generatedItinerary(Ref ref) {
  final state = ref.watch(onboardingProvider);
  return switch (state) {
    OnboardingSuccess(itinerary: final itinerary) => itinerary.toJson(),
    OnboardingInitial() => null,
    OnboardingInProgress() => null,
    OnboardingSubmitting() => null,
    OnboardingError() => null,
  };
}

/// Provider for accessing the error message
///
/// Convenience provider that extracts the error message
/// from the OnboardingState when available.
@riverpod
String? onboardingErrorMessage(Ref ref) {
  final state = ref.watch(onboardingProvider);
  return switch (state) {
    OnboardingError(message: final message) => message,
    OnboardingInitial() => null,
    OnboardingInProgress() => null,
    OnboardingSubmitting() => null,
    OnboardingSuccess() => null,
  };
}
