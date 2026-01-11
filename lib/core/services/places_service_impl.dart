import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/travel/domain/models/place_activity.dart';
import 'places_service.dart';

part 'places_service_impl.g.dart';

/// Stub implementation of [PlacesService]
///
/// This is a placeholder implementation that returns empty results.
/// In production, this should be replaced with actual Google Places API integration.
class PlacesServiceImpl implements PlacesService {
  @override
  Future<List<PlaceActivity>> searchPlaces({
    required String query,
    required Destination destination,
    int radius = 5000,
  }) async {
    // TODO: Implement Google Places API search
    // For now, return empty list to allow app to compile
    return [];
  }

  @override
  Future<List<PlaceActivity>> findActivities({
    required Destination destination,
    required TravelInterest interest,
    required DateTime date,
    bool? isIndoor,
  }) async {
    // TODO: Implement activity search based on interests
    // For now, return empty list to allow app to compile
    return [];
  }

  @override
  Future<PeakHours> getPeakHours(
    String placeName,
    Destination destination,
  ) async {
    // TODO: Implement peak hours lookup
    // For now, return empty peak hours
    return const PeakHours(
      hours: [],
      dayOfWeek: 'daily',
    );
  }

  @override
  Future<List<PlaceActivity>> findIndoorAlternatives({
    required Destination destination,
    required List<TravelInterest> interests,
    required DateTime date,
  }) async {
    // TODO: Implement indoor alternatives search
    // For now, return empty list to allow app to compile
    return [];
  }

  @override
  Future<PlaceActivity?> getPlaceDetails(String placeId) async {
    // TODO: Implement place details lookup
    // For now, return null
    return null;
  }
}

/// Provider for PlacesServiceImpl
@riverpod
PlacesService placesServiceImpl(Ref ref) {
  return PlacesServiceImpl();
}

/// Provider override for PlacesService interface
@riverpod
PlacesService placesServiceOverride(Ref ref) {
  return ref.watch(placesServiceImplProvider);
}
