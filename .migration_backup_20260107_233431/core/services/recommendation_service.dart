import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/travel/domain/models/weather_forecast.dart';

part 'recommendation_service.g.dart';

/// Types of recommendations
enum RecommendationType {
  /// Tourist attractions and points of interest
  attraction,

  /// Restaurants and dining options
  restaurant,

  /// Hotels and accommodations
  accommodation,

  /// Activities and experiences
  activity,

  /// Cultural experiences (museums, galleries, etc.)
  culture,

  /// Outdoor activities and adventures
  outdoor,

  /// Shopping destinations
  shopping,

  /// Entertainment and nightlife
  entertainment,
}

/// A single recommendation with details
class Recommendation {
  /// Unique identifier for this recommendation
  final String id;

  /// Type of recommendation
  final RecommendationType type;

  /// Name of the place
  final String name;

  /// Detailed description
  final String? description;

  /// Location/address
  final String? location;

  /// Latitude coordinate
  final double? latitude;

  /// Longitude coordinate
  final double? longitude;

  /// Rating from 0 to 5
  final double? rating;

  /// Price level ($, $$, $$$, $$$$)
  final String? priceLevel;

  /// Estimated cost in local currency
  final double? estimatedCost;

  /// How well this matches user interests (0-1)
  final double? relevanceScore;

  /// Recommended duration in hours
  final int? durationHours;

  /// URL for more information or booking
  final String? url;

  /// Opening hours
  final String? openingHours;

  /// Why this was recommended
  final String? reason;

  const Recommendation({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.rating,
    this.priceLevel,
    this.estimatedCost,
    this.relevanceScore,
    this.durationHours,
    this.url,
    this.openingHours,
    this.reason,
  });
}

/// Service for generating travel recommendations
///
/// Provides activity and restaurant recommendations based on user interests,
/// destination, and weather conditions. Used during itinerary generation
/// to populate daily plans with relevant activities.
abstract class RecommendationService {
  /// Gets activity recommendations for a destination
  ///
  /// [destination] The destination to get recommendations for
  /// [interests] User's travel interests to match against
  /// [weather] Optional weather forecast for filtering outdoor activities
  /// [limit] Maximum number of recommendations to return
  ///
  /// Returns a list of recommended activities sorted by relevance
  ///
  /// Throws [ServerException] if the recommendation API is unavailable
  /// Throws [NetworkException] if there's a connectivity issue
  Future<List<Recommendation>> getActivityRecommendations(
    Destination destination,
    Set<TravelInterest> interests,
    List<WeatherForecast>? weather, {
    int limit = 10,
  });

  /// Gets restaurant recommendations for a destination
  ///
  /// [destination] The destination to get recommendations for
  /// [interests] User's travel interests (e.g., food) to match against
  /// [budget] Optional budget preference for filtering
  /// [limit] Maximum number of recommendations to return
  ///
  /// Returns a list of recommended restaurants sorted by relevance
  ///
  /// Throws [ServerException] if the recommendation API is unavailable
  /// Throws [NetworkException] if there's a connectivity issue
  Future<List<Recommendation>> getRestaurantRecommendations(
    Destination destination,
    Set<TravelInterest> interests, {
    String? budget,
    int limit = 5,
  });

  /// Gets accommodation recommendations for a destination
  ///
  /// [destination] The destination to get recommendations for
  /// [budget] Optional budget preference for filtering
  /// [limit] Maximum number of recommendations to return
  ///
  /// Returns a list of recommended accommodations sorted by relevance
  ///
  /// Throws [ServerException] if the recommendation API is unavailable
  /// Throws [NetworkException] if there's a connectivity issue
  Future<List<Recommendation>> getAccommodationRecommendations(
    Destination destination, {
    String? budget,
    int limit = 5,
  });

  /// Checks if recommendations are available for a destination
  ///
  /// [destination] The destination to check
  ///
  /// Returns true if recommendations can be generated for this destination
  Future<bool> areRecommendationsAvailable(Destination destination);
}

/// Provider for the recommendation service implementation
@Riverpod(keepAlive: true)
RecommendationService recommendationService(Ref ref) {
  throw UnimplementedError(
    'RecommendationService implementation not provided. '
    'Use recommendationServiceProvider from recommendation_service_impl.dart',
  );
}
