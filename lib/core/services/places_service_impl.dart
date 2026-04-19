import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/core/cache/memory_cache.dart';
import 'package:soloadventurer/core/config/google_places_config.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/travel/domain/models/place_activity.dart';
import 'places_service.dart';

part 'places_service_impl.g.dart';

/// Maps TravelInterest categories to Google Places (New) place types.
const _interestTypeMap = <TravelInterest, List<String>>{
  TravelInterest.art: ['museum', 'art_gallery'],
  TravelInterest.food: ['restaurant', 'cafe', 'bakery', 'meal_takeaway'],
  TravelInterest.history: ['museum'],
  TravelInterest.nature: ['park', 'campground'],
  TravelInterest.adventure: ['tourist_attraction'],
  TravelInterest.relaxation: ['spa'],
  TravelInterest.shopping: ['shopping_mall', 'store', 'clothing_store'],
  TravelInterest.nightlife: ['bar', 'night_club'],
  TravelInterest.music: ['night_club'],
  TravelInterest.architecture: ['tourist_attraction'],
};

/// Place types that are typically indoor.
const _indoorTypes = {
  'museum',
  'art_gallery',
  'restaurant',
  'cafe',
  'bakery',
  'shopping_mall',
  'store',
  'night_club',
  'bar',
  'spa',
  'library',
  'movie_theater',
  'bowling_alley',
  'beauty_salon',
};

/// Field mask for search results (limits billing).
const _searchFieldMask =
    'places.id,places.displayName,places.formattedAddress,places.location,'
    'places.rating,places.userRatingCount,places.types,places.photos,'
    'places.priceLevel,places.businessStatus,places.googleMapsUri';

/// Field mask for place details.
const _detailsFieldMask =
    'id,displayName,formattedAddress,location,rating,userRatingCount,types,'
    'photos,priceLevel,businessStatus,websiteUri,regularOpeningHours,'
    'places.editorialSummary';

/// Real implementation of [PlacesService] using Google Places API (New).
///
/// Uses the v1 endpoints (POST for search, GET for details) with
/// X-Goog-Api-Key and X-Goog-FieldMask headers.
/// Responses are cached in memory to stay within the free tier.
class PlacesServiceImpl implements PlacesService {
  final Dio _dio;

  /// Cache for search results.
  final MemoryCache<String, List<PlaceActivity>> _searchCache;

  /// Cache for place details.
  final MemoryCache<String, PlaceActivity> _detailsCache;

  static const _baseUrl = 'https://places.googleapis.com/v1';

  /// Creates a [PlacesServiceImpl].
  ///
  /// Optionally accepts a [dio] instance and [apiKey] for testing.
  /// When [apiKey] is not provided, reads from [GooglePlacesConfig].
  PlacesServiceImpl({Dio? dio, String? apiKey})
      : _apiKey = apiKey ?? GooglePlacesConfig.apiKey,
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            )),
        _searchCache = MemoryCache<String, List<PlaceActivity>>(
          config: const MemoryCacheConfig(
            maxSize: 100,
            defaultTtl: Duration(hours: 1),
          ),
        ),
        _detailsCache = MemoryCache<String, PlaceActivity>(
          config: const MemoryCacheConfig(
            maxSize: 200,
            defaultTtl: Duration(hours: 24),
          ),
        );

  final String _apiKey;

  /// Common headers for Google Places API (New).
  Map<String, String> get _headers => {
        'X-Goog-Api-Key': _apiKey,
        'Content-Type': 'application/json',
      };

  @override
  Future<List<PlaceActivity>> searchPlaces({
    required String query,
    required Destination destination,
    int radius = 5000,
  }) async {
    if (_apiKey.isEmpty) {
      return [];
    }

    final cacheKey =
        'search:$query:${destination.latitude},${destination.longitude}:$radius';
    final cached = _searchCache.get(cacheKey);
    if (cached != null) return cached;

    final results = await _textSearch(
      query: query,
      lat: destination.latitude,
      lng: destination.longitude,
      radius: radius,
    );

    await _searchCache.put(cacheKey, results);
    return results;
  }

  @override
  Future<List<PlaceActivity>> findActivities({
    required Destination destination,
    required TravelInterest interest,
    required DateTime date,
    bool? isIndoor,
  }) async {
    if (_apiKey.isEmpty) return [];

    final types = _interestTypeMap[interest] ?? ['tourist_attraction'];
    final cacheKey =
        'activities:${interest.name}:${destination.latitude},${destination.longitude}:5000';

    final cached = _searchCache.get(cacheKey);
    if (cached != null) return _filterByIndoor(cached, isIndoor);

    final allResults = <PlaceActivity>[];
    for (final type in types) {
      final results = await _nearbySearch(
        lat: destination.latitude,
        lng: destination.longitude,
        radius: 5000,
        type: type,
      );
      allResults.addAll(results);
    }

    // Deduplicate by place ID
    final seen = <String>{};
    final deduped = allResults.where((p) => seen.add(p.id)).toList();

    await _searchCache.put(cacheKey, deduped);
    return _filterByIndoor(deduped, isIndoor);
  }

  @override
  Future<PeakHours> getPeakHours(
    String placeName,
    Destination destination,
  ) async {
    // Google Places API (New) does not expose popular times data.
    // Peak hours would require Google Maps Internal API access.
    return const PeakHours(hours: [], dayOfWeek: 'daily');
  }

  @override
  Future<List<PlaceActivity>> findIndoorAlternatives({
    required Destination destination,
    required List<TravelInterest> interests,
    required DateTime date,
  }) async {
    if (_apiKey.isEmpty) return [];

    final indoorTypes = <String>{};
    for (final interest in interests) {
      final types = _interestTypeMap[interest] ?? [];
      for (final type in types) {
        if (_indoorTypes.contains(type)) {
          indoorTypes.add(type);
        }
      }
    }

    if (indoorTypes.isEmpty) {
      indoorTypes.addAll(['museum', 'cafe', 'shopping_mall', 'library']);
    }

    final allResults = <PlaceActivity>[];
    for (final type in indoorTypes) {
      final results = await _nearbySearch(
        lat: destination.latitude,
        lng: destination.longitude,
        radius: 5000,
        type: type,
      );
      allResults.addAll(results);
    }

    final seen = <String>{};
    return allResults
        .where((p) => seen.add(p.id) && p.isIndoor)
        .toList();
  }

  @override
  Future<PlaceActivity?> getPlaceDetails(String placeId) async {
    if (_apiKey.isEmpty) return null;

    final cacheKey = 'details:$placeId';
    final cached = _detailsCache.get(cacheKey);
    if (cached != null) return cached;

    final result = await _fetchPlaceDetails(placeId);
    if (result != null) {
      await _detailsCache.put(cacheKey, result);
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // HTTP helpers — Google Places API (New)
  // ---------------------------------------------------------------------------

  /// Text Search (New): POST /v1/places:searchText
  Future<List<PlaceActivity>> _textSearch({
    required String query,
    required double lat,
    required double lng,
    required int radius,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/places:searchText',
        data: {
          'textQuery': query,
          'locationBias': {
            'circle': {
              'center': {'latitude': lat, 'longitude': lng},
              'radius': radius.toDouble(),
            },
          },
          'pageSize': 20,
        },
        options: Options(
          headers: {
            ..._headers,
            'X-Goog-FieldMask': _searchFieldMask,
          },
        ),
      );

      return _parseSearchResponse(response.data);
    } on DioException catch (_) {
      return [];
    }
  }

  /// Nearby Search (New): POST /v1/places:searchNearby
  Future<List<PlaceActivity>> _nearbySearch({
    required double lat,
    required double lng,
    required int radius,
    required String type,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/places:searchNearby',
        data: {
          'locationRestriction': {
            'circle': {
              'center': {'latitude': lat, 'longitude': lng},
              'radius': radius.toDouble(),
            },
          },
          'includedTypes': [type],
          'pageSize': 20,
        },
        options: Options(
          headers: {
            ..._headers,
            'X-Goog-FieldMask': _searchFieldMask,
          },
        ),
      );

      return _parseSearchResponse(response.data);
    } on DioException catch (_) {
      return [];
    }
  }

  /// Place Details (New): GET /v1/places/{placeId}
  Future<PlaceActivity?> _fetchPlaceDetails(String placeId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/places/$placeId',
        options: Options(
          headers: {
            ..._headers,
            'X-Goog-FieldMask': _detailsFieldMask,
          },
        ),
      );

      final data = response.data;
      if (data == null) return null;

      return _parsePlace(data);
    } on DioException catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Response parsing — Places API (New) format
  // ---------------------------------------------------------------------------

  /// Parses a search response (New API).
  ///
  /// New API returns `{"places": [...]}` instead of `{"results": [...]}`.
  List<PlaceActivity> _parseSearchResponse(Map<String, dynamic>? data) {
    if (data == null) return [];

    final places = data['places'] as List<dynamic>?;
    if (places == null) return [];

    return places
        .cast<Map<String, dynamic>>()
        .map(_parsePlace)
        .where((p) => p.name.isNotEmpty)
        .toList();
  }

  /// Parses a single place from the New API response format.
  ///
  /// New API uses:
  /// - `id` instead of `place_id`
  /// - `displayName.text` instead of `name`
  /// - `location` directly (not inside `geometry`)
  /// - `userRatingCount` instead of `user_ratings_total`
  /// - `photos[].name` for photo reference (e.g., "places/ChIJ.../photos/ATJ...")
  /// - `priceLevel` as enum string (PRICE_LEVEL_FREE, _INEXPENSIVE, etc.)
  /// - `businessStatus` as enum string (OPERATIONAL, CLOSED_TEMPORARILY, etc.)
  PlaceActivity _parsePlace(Map<String, dynamic> json) {
    // Filter out permanently closed businesses
    final businessStatus = json['businessStatus'] as String?;
    if (businessStatus == 'CLOSED_PERMANENTLY') {
      return const PlaceActivity(
        id: '',
        name: '',
        description: '',
        category: '',
      );
    }

    final types = (json['types'] as List<dynamic>?)
            ?.cast<String>()
            .toList() ??
        [];

    final category = _inferCategory(types);
    final isIndoor = types.any(_indoorTypes.contains);

    // Photo: New API uses photos[].name for the media URL
    final photos = json['photos'] as List<dynamic>?;
    final photoName = photos != null && photos.isNotEmpty
        ? photos[0]['name'] as String? ?? ''
        : '';
    final photoUrl =
        photoName.isNotEmpty ? '$_baseUrl/$photoName/media?maxWidthPx=400&key=$_apiKey' : null;

    // Location: New API uses location.latitude / location.longitude directly
    final location = json['location'] as Map<String, dynamic>?;

    // Display name: New API uses displayName.text
    final displayName = json['displayName'] as Map<String, dynamic>?;
    final name = displayName?['text'] as String? ?? '';

    // Description: editorialSummary.text
    final editorialSummary = json['editorialSummary'] as Map<String, dynamic>?;
    final description = editorialSummary?['text'] as String? ?? _buildDescription(types);

    // Price level: New API returns enum strings
    final priceLevelStr = json['priceLevel'] as String?;
    final cost = _mapPriceLevel(priceLevelStr);

    return PlaceActivity(
      id: json['id'] as String? ?? '',
      name: name,
      description: description,
      category: category,
      address: json['formattedAddress'] as String?,
      latitude: location?['latitude'] as double?,
      longitude: location?['longitude'] as double?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['userRatingCount'] as int? ?? 0,
      isIndoor: isIndoor,
      cost: cost,
      photoUrl: photoUrl,
      bookingUrl: json['websiteUri'] as String?,
    );
  }

  /// Maps Google Places (New) price level enum to a numeric value.
  ///
  /// Returns null if not available, 0.0 for free, 1.0-4.0 for price tiers.
  double? _mapPriceLevel(String? priceLevel) {
    if (priceLevel == null) return null;
    return switch (priceLevel) {
      'PRICE_LEVEL_FREE' => 0.0,
      'PRICE_LEVEL_INEXPENSIVE' => 1.0,
      'PRICE_LEVEL_MODERATE' => 2.0,
      'PRICE_LEVEL_EXPENSIVE' => 3.0,
      'PRICE_LEVEL_VERY_EXPENSIVE' => 4.0,
      _ => null,
    };
  }

  /// Infers a human-readable category from Google Places types.
  String _inferCategory(List<String> types) {
    if (types.contains('restaurant') || types.contains('meal_takeaway')) {
      return 'restaurant';
    }
    if (types.contains('cafe')) return 'cafe';
    if (types.contains('bar')) return 'bar';
    if (types.contains('night_club')) return 'nightlife';
    if (types.contains('museum')) return 'museum';
    if (types.contains('art_gallery')) return 'art_gallery';
    if (types.contains('park')) return 'park';
    if (types.contains('shopping_mall') || types.contains('store')) {
      return 'shopping';
    }
    if (types.contains('spa')) return 'spa';
    if (types.contains('tourist_attraction')) return 'attraction';
    if (types.contains('library')) return 'library';
    return 'poi';
  }

  /// Builds a brief description from place types when editorial summary
  /// is not available.
  String _buildDescription(List<String> types) {
    final labels = <String>[];
    for (final type in types) {
      if (_categoryLabels.containsKey(type)) {
        labels.add(_categoryLabels[type]!);
      }
    }
    if (labels.isEmpty) return 'Point of interest';
    return labels.join(' \u00b7 ');
  }

  /// Filters activities by indoor/outdoor preference.
  List<PlaceActivity> _filterByIndoor(
    List<PlaceActivity> activities,
    bool? isIndoor,
  ) {
    if (isIndoor == null) return activities;
    return activities.where((a) => a.isIndoor == isIndoor).toList();
  }
}

/// Human-readable labels for Google Places types.
const _categoryLabels = <String, String>{
  'restaurant': 'Restaurant',
  'cafe': 'Cafe',
  'bar': 'Bar',
  'bakery': 'Bakery',
  'meal_takeaway': 'Takeout',
  'museum': 'Museum',
  'art_gallery': 'Art Gallery',
  'park': 'Park',
  'shopping_mall': 'Shopping Mall',
  'store': 'Store',
  'night_club': 'Nightclub',
  'spa': 'Spa',
  'tourist_attraction': 'Tourist Attraction',
  'library': 'Library',
  'campground': 'Campground',
};

/// Provider for PlacesServiceImpl.
@riverpod
PlacesService placesServiceImpl(Ref ref) {
  return PlacesServiceImpl();
}

/// Provider override for PlacesService interface.
@riverpod
PlacesService placesServiceOverride(Ref ref) {
  return ref.watch(placesServiceImplProvider);
}
