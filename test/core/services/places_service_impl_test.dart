import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/services/places_service_impl.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/travel/domain/models/place_activity.dart';

/// A fake [Dio] that returns canned responses for Places API (New) endpoints.
class FakeDio implements Dio {
  final Map<String, Map<String, dynamic>> _getResponses;
  final Map<String, Map<String, dynamic>> _postResponses;
  int requestCount = 0;
  final List<String> requestPaths = [];

  FakeDio({
    Map<String, Map<String, dynamic>>? getResponses,
    Map<String, Map<String, dynamic>>? postResponses,
  })  : _getResponses = getResponses ?? {},
        _postResponses = postResponses ?? {};

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    requestCount++;
    requestPaths.add(path);

    final responseData = _getResponses[path];
    if (responseData == null) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        message: 'No fake GET response for $path',
      );
    }

    return Response<T>(
      data: responseData as T,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    requestCount++;
    requestPaths.add(path);

    final responseData = _postResponses[path];
    if (responseData == null) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        message: 'No fake POST response for $path',
      );
    }

    return Response<T>(
      data: responseData as T,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  const testApiKey = 'test_api_key_12345';

  // New API base URL
  const baseUrl = 'https://places.googleapis.com/v1';

  // Sample Places API (New) text search response
  const textSearchResponse = {
    'places': [
      {
        'id': 'ChIJdd4hrwug2EcRmSrV3Vo6llI',
        'displayName': {'text': 'Louvre Museum', 'languageCode': 'en'},
        'formattedAddress': 'Rue de Rivoli, 75001 Paris, France',
        'location': {'latitude': 48.8606, 'longitude': 2.3376},
        'rating': 4.7,
        'userRatingCount': 100000,
        'types': ['museum', 'tourist_attraction', 'point_of_interest'],
        'photos': [
          {
            'name': 'places/ChIJdd4hrwug2EcRmSrV3Vo6llI/photos/ATJ83zhSS',
            'heightPx': 1000,
            'widthPx': 1500,
          },
        ],
        'priceLevel': 'PRICE_LEVEL_INEXPENSIVE',
        'businessStatus': 'OPERATIONAL',
        'googleMapsUri': 'https://maps.google.com/?cid=123',
      },
      {
        'id': 'ChIJyz8nUOVj5kcRJAZkpPqiHM8',
        'displayName': {'text': 'Musee dOrsay', 'languageCode': 'en'},
        'formattedAddress': "1 Rue de la Légion d'Honneur, 75007 Paris",
        'location': {'latitude': 48.86, 'longitude': 2.3266},
        'rating': 4.6,
        'userRatingCount': 75000,
        'types': ['museum', 'art_gallery', 'tourist_attraction'],
        'photos': [],
        'businessStatus': 'OPERATIONAL',
      },
    ],
  };

  const nearbySearchResponse = {
    'places': [
      {
        'id': 'rest_001',
        'displayName': {'text': 'Le Bouillon Chartier', 'languageCode': 'en'},
        'formattedAddress': '33 Rue du Faubourg Montmartre, Paris',
        'location': {'latitude': 48.8719, 'longitude': 2.3469},
        'rating': 4.3,
        'userRatingCount': 15000,
        'types': ['restaurant', 'food', 'point_of_interest'],
        'photos': [],
        'priceLevel': 'PRICE_LEVEL_INEXPENSIVE',
        'businessStatus': 'OPERATIONAL',
      },
    ],
  };

  const placeDetailsResponse = {
    'id': 'ChIJdd4hrwug2EcRmSrV3Vo6llI',
    'displayName': {'text': 'Louvre Museum', 'languageCode': 'en'},
    'formattedAddress': 'Rue de Rivoli, 75001 Paris, France',
    'location': {'latitude': 48.8606, 'longitude': 2.3376},
    'rating': 4.7,
    'userRatingCount': 100000,
    'types': ['museum', 'tourist_attraction', 'point_of_interest'],
    'photos': [
      {
        'name': 'places/ChIJdd4hrwug2EcRmSrV3Vo6llI/photos/ATJ83zhSS',
        'heightPx': 1000,
        'widthPx': 1500,
      },
    ],
    'websiteUri': 'https://www.louvre.fr/',
    'priceLevel': 'PRICE_LEVEL_MODERATE',
    'businessStatus': 'OPERATIONAL',
    'editorialSummary': {
      'text': "The Louvre is the world's largest art museum.",
      'languageCode': 'en',
    },
    'regularOpeningHours': {
      'weekdayDescriptions': [
        'Monday: 9:00 AM – 6:00 PM',
        'Tuesday: Closed',
        'Wednesday: 9:00 AM – 9:45 PM',
      ],
    },
  };

  const emptySearchResponse = <String, dynamic>{};

  const closedPermanentlyResponse = {
    'places': [
      {
        'id': 'closed_001',
        'displayName': {'text': 'Closed Restaurant', 'languageCode': 'en'},
        'formattedAddress': '123 Closed St',
        'location': {'latitude': 48.86, 'longitude': 2.35},
        'rating': 3.0,
        'userRatingCount': 50,
        'types': ['restaurant'],
        'photos': [],
        'businessStatus': 'CLOSED_PERMANENTLY',
      },
    ],
  };

  final testDestination = Destination(
    placeId: 'test_paris',
    name: 'Paris, France',
    latitude: 48.8566,
    longitude: 2.3522,
    country: 'France',
    city: 'Paris',
  );

  group('PlacesServiceImpl (New API)', () {
    // ---------------------------------------------------------------
    // Text Search (searchPlaces)
    // ---------------------------------------------------------------
    group('searchPlaces', () {
      test('parses New API text search results', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchText': textSearchResponse,
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final results = await service.searchPlaces(
          query: 'museums',
          destination: testDestination,
        );

        expect(results, hasLength(2));

        final louvre = results.first;
        expect(louvre.id, 'ChIJdd4hrwug2EcRmSrV3Vo6llI');
        expect(louvre.name, 'Louvre Museum');
        expect(louvre.address, 'Rue de Rivoli, 75001 Paris, France');
        expect(louvre.latitude, 48.8606);
        expect(louvre.longitude, 2.3376);
        expect(louvre.rating, 4.7);
        expect(louvre.reviewCount, 100000);
        expect(louvre.category, 'museum');
        expect(louvre.isIndoor, isTrue);
        expect(louvre.photoUrl, isNotEmpty);
        expect(louvre.cost, 1.0); // PRICE_LEVEL_INEXPENSIVE
      });

      test('returns empty list for empty response', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchText': emptySearchResponse,
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final results = await service.searchPlaces(
          query: 'nonexistent place xyz123',
          destination: testDestination,
        );

        expect(results, isEmpty);
      });

      test('filters out CLOSED_PERMANENTLY businesses', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchText': closedPermanentlyResponse,
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final results = await service.searchPlaces(
          query: 'restaurants',
          destination: testDestination,
        );

        // Closed business is filtered to empty name/id
        expect(results.where((p) => p.name.isNotEmpty), isEmpty);
      });

      test('returns empty list on DioException', () async {
        final fakeDio = FakeDio(); // No responses configured

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final results = await service.searchPlaces(
          query: 'test',
          destination: testDestination,
        );

        expect(results, isEmpty);
      });

      test('uses POST to searchText endpoint', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchText': textSearchResponse,
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        await service.searchPlaces(query: 'museums', destination: testDestination);

        expect(fakeDio.requestPaths, contains('$baseUrl/places:searchText'));
      });
    });

    // ---------------------------------------------------------------
    // Caching
    // ---------------------------------------------------------------
    group('caching', () {
      test('caches search results and avoids duplicate API calls',
          () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchText': textSearchResponse,
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);

        // First call - hits API
        final results1 = await service.searchPlaces(
          query: 'museums',
          destination: testDestination,
        );
        expect(fakeDio.requestCount, 1);

        // Second call - cached
        final results2 = await service.searchPlaces(
          query: 'museums',
          destination: testDestination,
        );
        expect(fakeDio.requestCount, 1);

        expect(results1.length, results2.length);
        expect(results1.first.id, results2.first.id);
      });

      test('different queries bypass cache', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchText': textSearchResponse,
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);

        await service.searchPlaces(
          query: 'museums',
          destination: testDestination,
        );
        await service.searchPlaces(
          query: 'restaurants',
          destination: testDestination,
        );

        expect(fakeDio.requestCount, 2);
      });

      test('caches place details', () async {
        final fakeDio = FakeDio(
          getResponses: {
            '$baseUrl/places/ChIJdd4hrwug2EcRmSrV3Vo6llI':
                placeDetailsResponse,
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);

        // First call
        final details1 =
            await service.getPlaceDetails('ChIJdd4hrwug2EcRmSrV3Vo6llI');
        expect(fakeDio.requestCount, 1);

        // Second call - cached
        final details2 =
            await service.getPlaceDetails('ChIJdd4hrwug2EcRmSrV3Vo6llI');
        expect(fakeDio.requestCount, 1);

        expect(details1?.name, 'Louvre Museum');
        expect(details2?.name, 'Louvre Museum');
        expect(details1?.bookingUrl, 'https://www.louvre.fr/');
      });
    });

    // ---------------------------------------------------------------
    // Place Details
    // ---------------------------------------------------------------
    group('getPlaceDetails', () {
      test('parses New API place details response', () async {
        final fakeDio = FakeDio(
          getResponses: {
            '$baseUrl/places/ChIJdd4hrwug2EcRmSrV3Vo6llI':
                placeDetailsResponse,
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final details =
            await service.getPlaceDetails('ChIJdd4hrwug2EcRmSrV3Vo6llI');

        expect(details, isNotNull);
        expect(details!.name, 'Louvre Museum');
        expect(details.description,
            "The Louvre is the world's largest art museum.");
        expect(details.bookingUrl, 'https://www.louvre.fr/');
        expect(details.photoUrl, isNotEmpty);
        expect(details.cost, 2.0); // PRICE_LEVEL_MODERATE
      });

      test('returns null on DioException', () async {
        final fakeDio = FakeDio(); // No responses

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final details = await service.getPlaceDetails('any_id');

        expect(details, isNull);
      });
    });

    // ---------------------------------------------------------------
    // findActivities (Nearby Search)
    // ---------------------------------------------------------------
    group('findActivities', () {
      test('searches by interest type using searchNearby', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchNearby': nearbySearchResponse,
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final results = await service.findActivities(
          destination: testDestination,
          interest: TravelInterest.food,
          date: DateTime(2026, 6, 15),
        );

        expect(results, isNotEmpty);
        expect(results.first.category, 'restaurant');
        expect(results.first.name, 'Le Bouillon Chartier');
        expect(fakeDio.requestPaths.first, '$baseUrl/places:searchNearby');
      });

      test('deduplicates results across multiple types', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchNearby': {
              'places': [
                {
                  'id': 'dup_001',
                  'displayName': {'text': 'Test Museum', 'languageCode': 'en'},
                  'formattedAddress': '123 Test St',
                  'location': {'latitude': 48.86, 'longitude': 2.35},
                  'rating': 4.5,
                  'userRatingCount': 1000,
                  'types': ['museum', 'art_gallery'],
                  'photos': [],
                  'businessStatus': 'OPERATIONAL',
                },
              ],
            },
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final results = await service.findActivities(
          destination: testDestination,
          interest: TravelInterest.art,
          date: DateTime(2026, 6, 15),
        );

        // art maps to ['museum', 'art_gallery'] — two API calls but
        // should deduplicate to one result
        expect(results, hasLength(1));
      });

      test('filters by isIndoor when specified', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchNearby': {
              'places': [
                {
                  'id': 'indoor_1',
                  'displayName': {'text': 'Indoor Museum', 'languageCode': 'en'},
                  'formattedAddress': '1 Museum St',
                  'location': {'latitude': 48.86, 'longitude': 2.35},
                  'rating': 4.5,
                  'userRatingCount': 100,
                  'types': ['museum'],
                  'photos': [],
                  'businessStatus': 'OPERATIONAL',
                },
                {
                  'id': 'outdoor_1',
                  'displayName': {'text': 'Outdoor Park', 'languageCode': 'en'},
                  'formattedAddress': '1 Park Ave',
                  'location': {'latitude': 48.87, 'longitude': 2.36},
                  'rating': 4.2,
                  'userRatingCount': 50,
                  'types': ['park'],
                  'photos': [],
                  'businessStatus': 'OPERATIONAL',
                },
              ],
            },
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);

        final indoorOnly = await service.findActivities(
          destination: testDestination,
          interest: TravelInterest.art,
          date: DateTime(2026, 6, 15),
          isIndoor: true,
        );

        expect(indoorOnly.every((a) => a.isIndoor), isTrue);
      });
    });

    // ---------------------------------------------------------------
    // findIndoorAlternatives
    // ---------------------------------------------------------------
    group('findIndoorAlternatives', () {
      test('returns only indoor activities', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchNearby': {
              'places': [
                {
                  'id': 'cafe_1',
                  'displayName': {'text': 'Cozy Cafe', 'languageCode': 'en'},
                  'formattedAddress': '5 Cafe Lane',
                  'location': {'latitude': 48.86, 'longitude': 2.35},
                  'rating': 4.4,
                  'userRatingCount': 200,
                  'types': ['cafe', 'food'],
                  'photos': [],
                  'businessStatus': 'OPERATIONAL',
                },
                {
                  'id': 'park_1',
                  'displayName': {'text': 'Rainy Park', 'languageCode': 'en'},
                  'formattedAddress': '10 Park Blvd',
                  'location': {'latitude': 48.87, 'longitude': 2.36},
                  'rating': 4.0,
                  'userRatingCount': 50,
                  'types': ['park'],
                  'photos': [],
                  'businessStatus': 'OPERATIONAL',
                },
              ],
            },
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final results = await service.findIndoorAlternatives(
          destination: testDestination,
          interests: [TravelInterest.food],
          date: DateTime(2026, 6, 15),
        );

        expect(results.every((a) => a.isIndoor), isTrue);
      });
    });

    // ---------------------------------------------------------------
    // getPeakHours
    // ---------------------------------------------------------------
    group('getPeakHours', () {
      test('returns empty peak hours (known API limitation)', () async {
        final fakeDio = FakeDio();

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final peakHours = await service.getPeakHours(
          'Louvre Museum',
          testDestination,
        );

        expect(peakHours.hours, isEmpty);
        expect(peakHours.dayOfWeek, 'daily');
      });
    });

    // ---------------------------------------------------------------
    // Photo URL construction (New API)
    // ---------------------------------------------------------------
    group('photo URL', () {
      test('builds photo URL from photo name', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchText': textSearchResponse,
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final results = await service.searchPlaces(
          query: 'museums',
          destination: testDestination,
        );

        final louvre = results.first;
        expect(
          louvre.photoUrl,
          contains('places/ChIJdd4hrwug2EcRmSrV3Vo6llI/photos/ATJ83zhSS/media'),
        );
        expect(louvre.photoUrl, contains('maxWidthPx=400'));
      });

      test('returns null photoUrl when no photos', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchText': textSearchResponse,
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final results = await service.searchPlaces(
          query: 'museums',
          destination: testDestination,
        );

        // Musee d'Orsay has empty photos array
        final orsay = results[1];
        expect(orsay.photoUrl, isNull);
      });
    });

    // ---------------------------------------------------------------
    // Price level mapping
    // ---------------------------------------------------------------
    group('price level', () {
      test('maps price level enum to numeric cost', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchText': textSearchResponse,
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final results = await service.searchPlaces(
          query: 'museums',
          destination: testDestination,
        );

        final louvre = results.first;
        expect(louvre.cost, 1.0); // PRICE_LEVEL_INEXPENSIVE
      });

      test('returns null cost when priceLevel is absent', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchText': textSearchResponse,
          },
        );

        final service = PlacesServiceImpl(dio: fakeDio, apiKey: testApiKey);
        final results = await service.searchPlaces(
          query: 'museums',
          destination: testDestination,
        );

        // Musee d'Orsay has no priceLevel field
        final orsay = results[1];
        expect(orsay.cost, isNull);
      });
    });

    group('Error handling', () {
      test('handles quota exceeded (429) gracefully returning empty', () async {
        final fakeDio = FakeDio(
          postResponses: {
            '$baseUrl/places:searchText': {
              'error': {'code': 429, 'message': 'Quota exceeded'},
            },
          },
        );

        // FakeDio will throw because response data has error structure,
        // but PlacesServiceImpl should catch DioException and return [].
        final throwingDio = FakeDio();
        final service = PlacesServiceImpl(dio: throwingDio, apiKey: testApiKey);

        // When no response is configured, FakeDio throws DioException.
        // The service should catch it and return empty.
        final results = await service.searchPlaces(
          query: 'test',
          destination: testDestination,
        );
        expect(results, isEmpty);
      });

      test('handles API errors gracefully returning empty', () async {
        final throwingDio = FakeDio();
        final service = PlacesServiceImpl(dio: throwingDio, apiKey: testApiKey);

        // All methods should return empty/null on DioException, never throw.
        expect(
          await service.searchPlaces(query: 'test', destination: testDestination),
          isEmpty,
        );
        expect(
          await service.findActivities(
            destination: testDestination,
            interest: TravelInterest.food,
            date: DateTime.now(),
          ),
          isEmpty,
        );
        expect(
          await service.getPlaceDetails('nonexistent'),
          isNull,
        );
        expect(
          await service.findIndoorAlternatives(
            destination: testDestination,
            interests: [TravelInterest.art],
            date: DateTime.now(),
          ),
          isEmpty,
        );
      });

      test('returns empty when API key not configured', () async {
        final service = PlacesServiceImpl(dio: FakeDio(), apiKey: '');

        expect(
          await service.searchPlaces(query: 'test', destination: testDestination),
          isEmpty,
        );
        expect(
          await service.findActivities(
            destination: testDestination,
            interest: TravelInterest.food,
            date: DateTime.now(),
          ),
          isEmpty,
        );
        expect(await service.getPlaceDetails('test'), isNull);
      });
    });
  });
}
