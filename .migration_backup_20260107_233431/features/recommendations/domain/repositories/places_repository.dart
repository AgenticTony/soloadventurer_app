import 'package:dartz/dartz.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';

/// Repository for finding places and activities
///
/// Provides search and discovery capabilities for attractions,
/// restaurants, and activities at destinations.
abstract class PlacesRepository {
  /// Finds places by interest at a destination
  ///
  /// [destination] Where to search
  /// [interest] The interest category to match
  /// [categories] Optional category filter
  /// [limit] Maximum results to return
  ///
  /// Returns [Right] with list of matching places
  /// Returns [Left] with failure if search fails
  Future<Either<Failure, List<PlaceActivity>>> findPlacesByInterest({
    required Destination destination,
    required TravelInterest interest,
    Set<RecommendationCategory>? categories,
    int limit = 20,
  });

  /// Searches for places by name or keyword
  ///
  /// [destination] Where to search
  /// [query] Search query
  /// [limit] Maximum results to return
  ///
  /// Returns [Right] with list of matching places
  /// Returns [Left] with failure if search fails
  Future<Either<Failure, List<PlaceActivity>>> searchPlaces({
    required Destination destination,
    required String query,
    int limit = 20,
  });

  /// Gets details for a specific place
  ///
  /// [placeId] The place's unique identifier
  ///
  /// Returns [Right] with detailed place information
  /// Returns [Left] with failure if not found
  Future<Either<Failure, PlaceActivity>> getPlaceDetails(
    String placeId,
  );

  /// Gets places near a location
  ///
  /// [latitude] Center latitude
  /// [longitude] Center longitude
  /// [radiusKm] Search radius in kilometers
  /// [categories] Optional category filter
  /// [limit] Maximum results to return
  ///
  /// Returns [Right] with list of nearby places
  /// Returns [Left] with failure if search fails
  Future<Either<Failure, List<PlaceActivity>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    @Default(5.0) double radiusKm,
    Set<RecommendationCategory>? categories,
    int limit = 20,
  });

  /// Gets popular places at a destination
  ///
  /// [destination] Where to search
  /// [limit] Maximum results to return
  ///
  /// Returns [Right] with list of popular places sorted by rating/visits
  /// Returns [Left] with failure if retrieval fails
  Future<Either<Failure, List<PlaceActivity>>> getPopularPlaces({
    required Destination destination,
    int limit = 20,
  });
}
