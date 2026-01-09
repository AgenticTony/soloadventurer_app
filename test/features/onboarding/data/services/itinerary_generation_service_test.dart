import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/onboarding/data/repositories/itinerary_generation_repository_impl.dart';
import 'package:soloadventurer/features/onboarding/data/services/itinerary_generation_service.dart';

class MockItineraryGenerationService extends Mock
    implements ItineraryGenerationService {}

void main() {
  group('ItineraryGenerationRepositoryImpl', () {
    late MockItineraryGenerationService mockService;
    late ItineraryGenerationRepositoryImpl repository;

    setUp(() {
      mockService = MockItineraryGenerationService();
      repository = ItineraryGenerationRepositoryImpl(mockService);
    });

    // Helper to create valid test data
    Map<String, dynamic> createValidTestData({
      Map<String, dynamic>? destination,
      Map<String, dynamic>? dateRange,
    }) {
      return {
        'name': 'John Doe',
        'destination': destination ??
            {
              'placeId': 'paris-id',
              'name': 'Paris, France',
              'latitude': 48.8566,
              'longitude': 2.3522,
            },
        'dateRange': dateRange ??
            {
              'start': '2026-05-11T00:00:00.000Z',
              'end': '2026-05-18T00:00:00.000Z',
              'numberOfDays': 7,
            },
        'interests': ['food', 'culture'],
        'budget': 'moderate',
      };
    }

    group('canGenerateItinerary', () {
      test('should return true when all required fields are present and valid',
          () async {
        final data = createValidTestData();

        final result = await repository.canGenerateItinerary(data);

        expect(result, isTrue);
      });

      test('should return false when destination is missing', () async {
        final data = createValidTestData()..remove('destination');

        final result = await repository.canGenerateItinerary(data);

        expect(result, isFalse);
      });

      test('should return false when destination is null', () async {
        final data = createValidTestData()..['destination'] = null;

        final result = await repository.canGenerateItinerary(data);

        expect(result, isFalse);
      });

      test('should return false when destination is not a map', () async {
        final data = createValidTestData()..['destination'] = 'invalid';

        final result = await repository.canGenerateItinerary(data);

        expect(result, isFalse);
      });

      test('should return false when destination missing placeId', () async {
        final data = createValidTestData();
        (data['destination'] as Map).remove('placeId');

        final result = await repository.canGenerateItinerary(data);

        expect(result, isFalse);
      });

      test('should return false when destination missing name', () async {
        final data = createValidTestData();
        (data['destination'] as Map).remove('name');

        final result = await repository.canGenerateItinerary(data);

        expect(result, isFalse);
      });

      test('should return false when destination missing latitude', () async {
        final data = createValidTestData();
        (data['destination'] as Map).remove('latitude');

        final result = await repository.canGenerateItinerary(data);

        expect(result, isFalse);
      });

      test('should return false when destination missing longitude', () async {
        final data = createValidTestData();
        (data['destination'] as Map).remove('longitude');

        final result = await repository.canGenerateItinerary(data);

        expect(result, isFalse);
      });

      test('should return false when dateRange is missing', () async {
        final data = createValidTestData()..remove('dateRange');

        final result = await repository.canGenerateItinerary(data);

        expect(result, isFalse);
      });

      test('should return false when dateRange is null', () async {
        final data = createValidTestData()..['dateRange'] = null;

        final result = await repository.canGenerateItinerary(data);

        expect(result, isFalse);
      });

      test('should return false when dateRange is not a map', () async {
        final data = createValidTestData()..['dateRange'] = 'invalid';

        final result = await repository.canGenerateItinerary(data);

        expect(result, isFalse);
      });

      test('should return false when dateRange missing start', () async {
        final data = createValidTestData();
        (data['dateRange'] as Map).remove('start');

        final result = await repository.canGenerateItinerary(data);

        expect(result, isFalse);
      });

      test('should return false when dateRange missing end', () async {
        final data = createValidTestData();
        (data['dateRange'] as Map).remove('end');

        final result = await repository.canGenerateItinerary(data);

        expect(result, isFalse);
      });

      test('should return true when destination has airport code', () async {
        final data = createValidTestData(
          destination: {
            'placeId': 'paris-id',
            'name': 'Paris, France',
            'latitude': 48.8566,
            'longitude': 2.3522,
            'airportCode': 'CDG',
          },
        );

        final result = await repository.canGenerateItinerary(data);

        expect(result, isTrue);
      });

      test('should handle exception gracefully', () async {
        final data = <String, dynamic>{'invalid': 'data'};

        final result = await repository.canGenerateItinerary(data);

        expect(result, isFalse);
      });
    });

    group('generateStarterItinerary', () {
      test('should return itinerary map with required fields', () async {
        final data = createValidTestData(
          destination: {
            'placeId': 'rome-id',
            'name': 'Rome, Italy',
            'latitude': 41.9028,
            'longitude': 12.4964,
          },
        );

        final result = await repository.generateStarterItinerary(data);

        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('id'), isTrue);
        expect(result.containsKey('name'), isTrue);
        expect(result.containsKey('destination'), isTrue);
        expect(result.containsKey('dateRange'), isTrue);
        expect(result.containsKey('items'), isTrue);
        expect(result['isStarter'], isTrue);
        expect(result.containsKey('createdAt'), isTrue);
      });

      test('should generate unique IDs for each itinerary', () async {
        final data = createValidTestData();

        final result1 = await repository.generateStarterItinerary(data);
        final result2 = await repository.generateStarterItinerary(data);

        expect(result1['id'], isNot(equals(result2['id'])));
      });

      test('should include destination from input data', () async {
        final expectedDestination = {
          'placeId': 'tokyo-id',
          'name': 'Tokyo, Japan',
          'latitude': 35.6762,
          'longitude': 139.6503,
        };
        final data = createValidTestData(destination: expectedDestination);

        final result = await repository.generateStarterItinerary(data);

        expect(result['destination'], equals(expectedDestination));
      });

      test('should include dateRange from input data', () async {
        final expectedDateRange = {
          'start': '2026-06-01T00:00:00.000Z',
          'end': '2026-06-10T00:00:00.000Z',
          'numberOfDays': 9,
        };
        final data = createValidTestData(dateRange: expectedDateRange);

        final result = await repository.generateStarterItinerary(data);

        expect(result['dateRange'], equals(expectedDateRange));
      });

      test('should include userId from input data if present', () async {
        final data = createValidTestData()..['userId'] = 'user-123';

        final result = await repository.generateStarterItinerary(data);

        expect(result['userId'], 'user-123');
      });

      test('should not include userId if not in input data', () async {
        final data = createValidTestData();

        final result = await repository.generateStarterItinerary(data);

        expect(result.containsKey('userId'), isFalse);
      });

      test('should create itinerary name based on destination', () async {
        final data = createValidTestData(
          destination: {
            'placeId': 'paris-id',
            'name': 'Paris, France',
            'latitude': 48.8566,
            'longitude': 2.3522,
          },
        );

        final result = await repository.generateStarterItinerary(data);

        expect(result['name'], contains('Paris'));
        expect(result['name'], contains('Trip'));
      });

      test('should have valid ISO8601 createdAt timestamp', () async {
        final data = createValidTestData();

        final result = await repository.generateStarterItinerary(data);
        final createdAt = result['createdAt'] as String;

        expect(() => DateTime.parse(createdAt), returnsNormally);
      });

      test('should mark isStarter as true', () async {
        final data = createValidTestData();

        final result = await repository.generateStarterItinerary(data);

        expect(result['isStarter'], isTrue);
      });

      test('should initialize with empty items list', () async {
        final data = createValidTestData();

        final result = await repository.generateStarterItinerary(data);
        final items = result['items'] as List;

        expect(items, isEmpty);
      });

      test('should rethrow ServerException from service', () async {
        final data = createValidTestData();
        when(() => mockService.generateFromOnboarding(any()))
            .thenThrow(const ServerException(message: 'Service error'));

        expect(
          () => repository.generateStarterItinerary(data),
          throwsA(isA<ServerException>()),
        );
      });

      test('should rethrow NetworkConnectivityException from service',
          () async {
        final data = createValidTestData();
        when(() => mockService.generateFromOnboarding(any())).thenThrow(
            const NetworkConnectivityException(message: 'No internet'));

        expect(
          () => repository.generateStarterItinerary(data),
          throwsA(isA<NetworkConnectivityException>()),
        );
      });

      test('should rethrow CacheException from service', () async {
        final data = createValidTestData();
        when(() => mockService.generateFromOnboarding(any()))
            .thenThrow(const CacheException(message: 'Cache error'));

        expect(
          () => repository.generateStarterItinerary(data),
          throwsA(isA<CacheException>()),
        );
      });

      test('should wrap generic exceptions in ServerException', () async {
        final data = createValidTestData();
        when(() => mockService.generateFromOnboarding(any()))
            .thenThrow(Exception('Generic error'));

        expect(
          () => repository.generateStarterItinerary(data),
          throwsA(
            predicate(
              (ServerException e) => e.message.contains('Failed to generate'),
            ),
          ),
        );
      });

      test('should use default destination name when missing', () async {
        final data = createValidTestData();
        (data['destination'] as Map).remove('name');

        final result = await repository.generateStarterItinerary(data);

        expect(result['name'], contains('Destination'));
      });
    });

    group('Constructor', () {
      test('should store service reference', () {
        final service = MockItineraryGenerationService();
        final repo = ItineraryGenerationRepositoryImpl(service);

        expect(repo, isA<ItineraryGenerationRepositoryImpl>());
      });
    });
  });
}
