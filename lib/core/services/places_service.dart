import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/travel/domain/models/place_activity.dart';

// Import for the implementation provider
import 'places_service_impl.dart' show placesServiceOverrideProvider;

part 'places_service.g.dart';

/// Service for finding and searching places/activities
///
/// Provides access to place data from Google Places API or similar.
/// Used by smart services to suggest activities for itineraries.
abstract class PlacesService {
  /// Searches for places/activities near a destination
  ///
  /// The [query] parameter is the search query (e.g., 'museums', 'restaurants').
  /// The [destination] parameter is the location to search near.
  /// The [radius] parameter is the search radius in meters (default: 5000).
  ///
  /// Returns a list of places matching the search criteria.
  Future<List<PlaceActivity>> searchPlaces({
    required String query,
    required Destination destination,
    int radius = 5000,
  });

  /// Finds activities based on user interests
  ///
  /// The [destination] parameter is the location to search.
  /// The [interest] parameter is the travel interest category.
  /// The [date] parameter is the date of the activity (for availability).
  /// The [isIndoor] parameter filters to indoor/outdoor activities.
  ///
  /// Returns a list of activities matching the interest.
  Future<List<PlaceActivity>> findActivities({
    required Destination destination,
    required TravelInterest interest,
    required DateTime date,
    bool? isIndoor,
  });

  /// Gets peak hours information for a place
  ///
  /// The [placeName] parameter is the name of the place.
  /// The [destination] parameter is the location (for disambiguation).
  ///
  /// Returns peak hours data if available.
  Future<PeakHours> getPeakHours(
    String placeName,
    Destination destination,
  );

  /// Finds indoor alternatives for a given location
  ///
  /// The [destination] parameter is the location to search.
  /// The [interests] parameter filters by user interests.
  /// The [date] parameter is the date of the activity.
  ///
  /// Returns indoor activities suitable for bad weather.
  Future<List<PlaceActivity>> findIndoorAlternatives({
    required Destination destination,
    required List<TravelInterest> interests,
    required DateTime date,
  });

  /// Gets detailed information about a place
  ///
  /// The [placeId] parameter is the Google Place ID or similar identifier.
  ///
  /// Returns detailed place information.
  Future<PlaceActivity?> getPlaceDetails(String placeId);
}

/// Provider for the places service implementation
///
/// This provider returns the actual implementation from places_service_impl.dart.
/// The placesServiceOverrideProvider handles the proper instantiation.
@Riverpod(keepAlive: true)
PlacesService placesService(Ref ref) {
  return ref.watch(placesServiceOverrideProvider);
}
