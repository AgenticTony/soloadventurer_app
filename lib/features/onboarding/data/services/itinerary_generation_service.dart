import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';

part 'itinerary_generation_service.g.dart';

/// Service interface for generating travel itineraries
///
/// Takes onboarding data and generates a complete personalized itinerary
/// with daily activities, accommodations, and logistics. This service
/// coordinates with weather and recommendation services to create
/// weather-appropriate and interest-matching itineraries.
abstract class ItineraryGenerationService {
  /// Generates a complete itinerary from onboarding data
  ///
  /// [data] The user's onboarding preferences
  ///
  /// Returns a complete itinerary with daily plans
  ///
  /// Throws [ValidationException] if onboarding data is invalid
  /// Throws [ServerException] if generation fails
  /// Throws [NetworkException] if APIs are unavailable
  /// Throws [CacheException] if unable to save the itinerary
  Future<Itinerary> generateFromOnboarding(OnboardingData data);

  /// Generates a day plan for a specific date
  ///
  /// [date] The date to generate a plan for
  /// [destination] The travel destination
  /// [interests] User's travel interests
  /// [weather] Optional weather forecast for the day
  /// [isFirstDay] Whether this is the arrival day
  /// [isLastDay] Whether this is the departure day
  ///
  /// Returns a list of itinerary items for the day
  ///
  /// Throws [ServerException] if generation fails
  /// Throws [NetworkException] if APIs are unavailable
  Future<List<Map<String, dynamic>>> generateDayPlan({
    required DateTime date,
    required Map<String, dynamic> destination,
    required Set<String> interests,
    List<Map<String, dynamic>>? weather,
    bool isFirstDay = false,
    bool isLastDay = false,
  });

  /// Checks if itinerary generation is possible
  ///
  /// [data] The onboarding data to validate
  ///
  /// Returns true if all required services and data are available
  Future<bool> canGenerateItinerary(OnboardingData data);
}

/// Provider for the itinerary generation service implementation
@riverpod
ItineraryGenerationService itineraryGenerationService(
  Ref ref,
) {
  throw UnimplementedError(
    'ItineraryGenerationService implementation not provided. '
    'Use itineraryGenerationServiceProvider from itinerary_generation_service_impl.dart',
  );
}
