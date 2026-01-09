import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:soloadventurer/features/onboarding/domain/repositories/itinerary_generation_repository.dart';

/// Use case for generating a starter itinerary from onboarding data
///
/// This use case encapsulates the business logic for creating a personalized
/// travel itinerary based on user preferences collected during onboarding.
/// It follows Clean Architecture principles by depending on an abstract
/// repository interface rather than concrete implementations.
class GenerateStarterItinerary {
  /// Repository for itinerary generation logic
  final ItineraryGenerationRepository _repository;

  /// Creates a new GenerateStarterItinerary use case
  ///
  /// [repository] The repository implementation for itinerary generation
  const GenerateStarterItinerary(this._repository);

  /// Executes the use case to generate a starter itinerary
  ///
  /// Takes [OnboardingData] containing the user's travel preferences
  /// and returns a successfully generated itinerary map.
  ///
  /// [data] The onboarding data with destination, dates, and interests
  ///
  /// Returns an itinerary map containing:
  /// - id: Unique identifier
  /// - name: Itinerary name
  /// - destination: Destination details
  /// - dateRange: Travel dates
  /// - items: List of daily activities
  /// - isStarter: true for onboarding-generated itineraries
  /// - createdAt: Generation timestamp
  ///
  /// Throws [ValidationException] if onboarding data is invalid
  /// Throws [ServerException] if backend generation fails
  /// Throws [NetworkException] if connectivity issues occur
  /// Throws [CacheException] if unable to cache the result
  Future<Map<String, dynamic>> call(
    OnboardingData data,
  ) async {
    // Validate input data first
    if (!data.isValid) {
      throw ValidationException(
        message: data.validationErrors.join(', '),
        errors: {
          'onboarding': data.validationErrors,
        },
      );
    }

    // Check if generation is possible
    final canGenerate = await _repository.canGenerateItinerary(
      data.toJson(),
    );

    if (!canGenerate) {
      throw const ServerException(
        message:
            'Unable to generate itinerary at this time. Please try again later.',
      );
    }

    // Generate the itinerary
    return await _repository.generateStarterItinerary(
      data.toJson(),
    );
  }
}
