import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';

/// Remote data source for places and activities
///
/// In production, this would connect to APIs like:
/// - Google Places API
/// - Yelp API
/// - TripAdvisor API
/// - Custom recommendation engine
abstract class PlacesRemoteDataSource {
  /// Finds places by interest at a destination
  Future<List<PlaceActivity>> findPlacesByInterest({
    required Destination destination,
    required TravelInterest interest,
    Set<RecommendationCategory>? categories,
    int limit = 20,
  });

  /// Searches for places by name or keyword
  Future<List<PlaceActivity>> searchPlaces({
    required Destination destination,
    required String query,
    int limit = 20,
  });

  /// Gets details for a specific place
  Future<PlaceActivity> getPlaceDetails(String placeId);

  /// Gets places near a location
  Future<List<PlaceActivity>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    required double radiusKm,
    Set<RecommendationCategory>? categories,
    int limit = 20,
  });

  /// Gets popular places at a destination
  Future<List<PlaceActivity>> getPopularPlaces({
    required Destination destination,
    int limit = 20,
  });
}

/// Mock implementation for development/testing
///
/// Returns predefined place data without making API calls.
/// In production, replace with actual API integration.
class MockPlacesRemoteDataSource implements PlacesRemoteDataSource {
  // Mock data for common destinations
  static final _mockPlaces = {
    'paris': _generateParisPlaces(),
    'london': _generateLondonPlaces(),
    'tokyo': _generateTokyoPlaces(),
    'new york': _generateNewYorkPlaces(),
  };

  @override
  Future<List<PlaceActivity>> findPlacesByInterest({
    required Destination destination,
    required TravelInterest interest,
    Set<RecommendationCategory>? categories,
    int limit = 20,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    final cityKey = _getCityKey(destination);
    final allPlaces =
        _mockPlaces[cityKey] ?? _generateGenericPlaces(destination);

    // Filter by interest
    final filtered = allPlaces.where((place) {
      final matchesInterest = _matchesInterest(place, interest);
      final matchesCategory =
          categories == null || categories.contains(place.category);
      return matchesInterest && matchesCategory;
    }).toList();

    return filtered.take(limit).toList();
  }

  @override
  Future<List<PlaceActivity>> searchPlaces({
    required Destination destination,
    required String query,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final cityKey = _getCityKey(destination);
    final allPlaces =
        _mockPlaces[cityKey] ?? _generateGenericPlaces(destination);

    final results = allPlaces
        .where((place) =>
            place.name.toLowerCase().contains(query.toLowerCase()) ||
            (place.description?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();

    return results.take(limit).toList();
  }

  @override
  Future<PlaceActivity> getPlaceDetails(String placeId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Search all mock places
    for (final places in _mockPlaces.values) {
      final place = places.cast<PlaceActivity?>().firstWhere(
            (p) => p?.id == placeId,
            orElse: () => null,
          );
      if (place != null) return place;
    }

    throw const ServerException(
      message: 'Place not found: $placeId',
      statusCode: 404,
    );
  }

  @override
  Future<List<PlaceActivity>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    required double radiusKm,
    Set<RecommendationCategory>? categories,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // For mock, just return generic places
    // In production, would use actual location-based search
    final results = _generateGenericPlaces(
      const Destination(
          name: 'Unknown', country: 'Unknown', latitude: 0, longitude: 0),
    );

    return results.take(limit).toList();
  }

  @override
  Future<List<PlaceActivity>> getPopularPlaces({
    required Destination destination,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final cityKey = _getCityKey(destination);
    final allPlaces =
        _mockPlaces[cityKey] ?? _generateGenericPlaces(destination);

    // Sort by rating and review count
    final sorted = List<PlaceActivity>.from(allPlaces)
      ..sort((a, b) {
        final ratingCompare = b.rating.compareTo(a.rating);
        if (ratingCompare != 0) return ratingCompare;
        return b.reviewCount.compareTo(a.reviewCount);
      });

    return sorted.take(limit).toList();
  }

  String _getCityKey(Destination destination) {
    final name = destination.name.toLowerCase();
    if (name.contains('paris')) return 'paris';
    if (name.contains('london')) return 'london';
    if (name.contains('tokyo')) return 'tokyo';
    if (name.contains('new york') || name.contains('nyc')) return 'new york';
    return name;
  }

  bool _matchesInterest(PlaceActivity place, TravelInterest interest) {
    switch (interest) {
      case TravelInterest.food:
        return place.category == RecommendationCategory.food;
      case TravelInterest.culture:
      case TravelInterest.art:
        return place.category == RecommendationCategory.culture;
      case TravelInterest.adventure:
      case TravelInterest.nature:
        return place.category == RecommendationCategory.adventure;
      case TravelInterest.wellness:
        return place.category == RecommendationCategory.wellness;
      case TravelInterest.shopping:
        return place.category == RecommendationCategory.shopping;
      default:
        return true;
    }
  }

  static List<PlaceActivity> _generateParisPlaces() {
    return [
      const PlaceActivity(
        id: 'paris-1',
        name: 'Musée d\'Orsay',
        category: RecommendationCategory.culture,
        description: 'World-renowned museum housing Impressionist masterpieces',
        location: '1 Rue de la Légion d\'Honneur, 75007 Paris',
        latitude: 48.8600,
        longitude: 2.3265,
        rating: 4.8,
        reviewCount: 12340,
        priceLevel: '€€',
        cost: 16.0,
        estimatedDuration: Duration(hours: 3),
        images: ['https://example.com/orsay.jpg'],
        tags: ['indoor', 'solo_friendly', 'art', 'museum'],
        localTips: [
          'Go early morning (9:30 AM) to avoid crowds',
          'Don\'t miss the clock room on the 5th floor',
        ],
        bookingUrl: 'https://www.musee-orsay.fr/en',
        requiresBooking: false,
        openingHours: '9:30 AM - 6:00 PM',
      ),
      const PlaceActivity(
        id: 'paris-2',
        name: 'Café de Flore',
        category: RecommendationCategory.food,
        description: 'Historic literary café dating to 1887',
        location: '172 Bd Saint-Germain, 75006 Paris',
        latitude: 48.8540,
        longitude: 2.3325,
        rating: 4.2,
        reviewCount: 4520,
        priceLevel: '€€€',
        cost: 25.0,
        estimatedDuration: Duration(hours: 1),
        images: ['https://example.com/flore.jpg'],
        tags: ['indoor', 'solo_friendly', 'historic', 'coffee'],
        localTips: [
          'Perfect for people-watching',
          'Try their famous hot chocolate',
        ],
        openingHours: '7:30 AM - 1:00 AM',
      ),
      const PlaceActivity(
        id: 'paris-3',
        name: 'Duc des Lombards',
        category: RecommendationCategory.entertainment,
        description: 'Legendary jazz club with live performances',
        location: '42 Rue des Lombards, 75001 Paris',
        latitude: 48.8610,
        longitude: 2.3490,
        rating: 4.6,
        reviewCount: 2340,
        priceLevel: '€€€',
        cost: 35.0,
        estimatedDuration: Duration(hours: 2),
        images: ['https://example.com/jazz.jpg'],
        tags: ['indoor', 'nightlife', 'music', 'solo_friendly'],
        localTips: [
          'Book tickets in advance for popular shows',
          'Arrive early for good seats',
        ],
        bookingUrl: 'https://www.ducdeslombards.fr',
        requiresBooking: true,
        openingHours: '7:00 PM - 2:00 AM',
      ),
      const PlaceActivity(
        id: 'paris-4',
        name: 'Seine River Cruise',
        category: RecommendationCategory.activity,
        description: 'Scenic boat tour along the Seine',
        location: 'Port de la Bourdonnais, 75007 Paris',
        latitude: 48.8620,
        longitude: 2.2950,
        rating: 4.5,
        reviewCount: 8900,
        priceLevel: '€€',
        cost: 15.0,
        estimatedDuration: Duration(hours: 1),
        images: ['https://example.com/seine.jpg'],
        tags: ['outdoor', 'solo_friendly', 'scenic', 'photography'],
        localTips: [
          'Best at sunset for the lights',
          'Bring a jacket even in summer',
        ],
        bookingUrl: 'https://www.vedettesdupontneuf.com',
        requiresBooking: false,
        openingHours: '10:00 AM - 10:00 PM',
      ),
    ];
  }

  static List<PlaceActivity> _generateLondonPlaces() {
    return [
      const PlaceActivity(
        id: 'london-1',
        name: 'British Museum',
        category: RecommendationCategory.culture,
        description: 'World-famous museum with vast collections',
        location: 'Great Russell St, Bloomsbury, London WC1B 3DG',
        latitude: 51.5194,
        longitude: -0.1270,
        rating: 4.7,
        reviewCount: 25600,
        priceLevel: 'Free',
        cost: 0.0,
        estimatedDuration: Duration(hours: 3),
        images: ['https://example.com/british-museum.jpg'],
        tags: ['indoor', 'solo_friendly', 'free', 'history'],
        localTips: [
          'Free admission, special exhibitions cost extra',
          'Don\'t miss the Rosetta Stone',
        ],
        openingHours: '10:00 AM - 5:00 PM',
      ),
    ];
  }

  static List<PlaceActivity> _generateTokyoPlaces() {
    return [
      const PlaceActivity(
        id: 'tokyo-1',
        name: 'Senso-ji Temple',
        category: RecommendationCategory.culture,
        description: 'Ancient Buddhist temple in Asakusa',
        location: '2-3-1 Asakusa, Taito City, Tokyo',
        latitude: 35.7148,
        longitude: 139.7967,
        rating: 4.6,
        reviewCount: 18200,
        priceLevel: 'Free',
        cost: 0.0,
        estimatedDuration: Duration(hours: 1),
        images: ['https://example.com/sensoji.jpg'],
        tags: ['outdoor', 'solo_friendly', 'free', 'historic'],
        localTips: [
          'Visit early morning for fewer crowds',
          'Explore Nakamise shopping street',
        ],
        openingHours: '6:00 AM - 5:00 PM',
      ),
    ];
  }

  static List<PlaceActivity> _generateNewYorkPlaces() {
    return [
      const PlaceActivity(
        id: 'nyc-1',
        name: 'Central Park',
        category: RecommendationCategory.attraction,
        description: 'Iconic urban park in Manhattan',
        location: 'New York, NY',
        latitude: 40.7829,
        longitude: -73.9654,
        rating: 4.8,
        reviewCount: 45000,
        priceLevel: 'Free',
        cost: 0.0,
        estimatedDuration: Duration(hours: 2),
        images: ['https://example.com/central-park.jpg'],
        tags: ['outdoor', 'solo_friendly', 'free', 'nature'],
        localTips: [
          'Great for morning runs',
          'Visit Bethesda Terrace and Fountain',
        ],
        openingHours: '6:00 AM - 1:00 AM',
      ),
    ];
  }

  static List<PlaceActivity> _generateGenericPlaces(Destination destination) {
    return [
      const PlaceActivity(
        id: 'generic-1',
        name: 'Local Museum',
        category: RecommendationCategory.culture,
        description: 'Explore local history and art',
        location: 'Downtown',
        rating: 4.2,
        reviewCount: 500,
        priceLevel: '€€',
        cost: 10.0,
        estimatedDuration: Duration(hours: 2),
        tags: ['indoor', 'solo_friendly'],
        openingHours: '9:00 AM - 5:00 PM',
      ),
      const PlaceActivity(
        id: 'generic-2',
        name: 'City Walking Tour',
        category: RecommendationCategory.activity,
        description: 'Guided tour of historic sites',
        location: 'City Center',
        rating: 4.5,
        reviewCount: 1200,
        priceLevel: '€€',
        cost: 20.0,
        estimatedDuration: Duration(hours: 2),
        tags: ['outdoor', 'solo_friendly', 'guided'],
        openingHours: '10:00 AM - 4:00 PM',
      ),
      const PlaceActivity(
        id: 'generic-3',
        name: 'Local Restaurant',
        category: RecommendationCategory.food,
        description: 'Authentic local cuisine',
        location: 'Food District',
        rating: 4.3,
        reviewCount: 800,
        priceLevel: '€€€',
        cost: 30.0,
        estimatedDuration: Duration(hours: 1),
        tags: ['indoor', 'solo_friendly', 'food'],
        openingHours: '11:00 AM - 10:00 PM',
      ),
    ];
  }
}
