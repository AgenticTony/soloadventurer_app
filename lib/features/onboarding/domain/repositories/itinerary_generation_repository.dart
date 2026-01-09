/// Repository interface for generating travel itineraries
///
/// This abstract repository defines the contract for generating
/// personalized travel itineraries based on onboarding data.
/// Implementations can use various sources (AI, templates, APIs).
abstract class ItineraryGenerationRepository {
  /// Generates a personalized starter itinerary from onboarding data
  ///
  /// Takes the user's onboarding preferences and creates a complete
  /// itinerary with daily activities, accommodations, and recommendations.
  ///
  /// [data] The onboarding data containing destination, dates, and interests
  ///
  /// Returns a JSON-serializable itinerary map containing:
  /// ```dart
  /// {
  ///   'id': String,
  ///   'name': String,
  ///   'destination': Map<String, dynamic>,
  ///   'dateRange': Map<String, dynamic>,
  ///   'items': List<Map<String, dynamic>>,
  ///   'isStarter': bool,
  ///   'createdAt': DateTime,
  /// }
  /// ```
  ///
  /// Throws [ValidationException] if onboarding data is invalid
  /// Throws [ServerException] if backend generation fails
  /// Throws [NetworkException] if connectivity issues occur
  /// Throws [CacheException] if unable to cache the result
  Future<Map<String, dynamic>> generateStarterItinerary(
    Map<String, dynamic> data,
  );

  /// Validates that itinerary generation is possible
  ///
  /// Checks if all required services and data are available
  /// for generating an itinerary (e.g., destination details available,
  /// weather service accessible, etc.).
  ///
  /// Returns true if generation is possible, false otherwise
  Future<bool> canGenerateItinerary(Map<String, dynamic> data);
}
