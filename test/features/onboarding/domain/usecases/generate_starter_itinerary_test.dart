import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/budget_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/onboarding/domain/repositories/itinerary_generation_repository.dart';
import 'package:soloadventurer/features/onboarding/domain/usecases/generate_starter_itinerary.dart';

class MockItineraryGenerationRepository extends Mock
    implements ItineraryGenerationRepository {}

void main() {
  group('GenerateStarterItinerary', () {
    late MockItineraryGenerationRepository mockRepository;
    late GenerateStarterItinerary useCase;

    setUp(() {
      mockRepository = MockItineraryGenerationRepository();
      useCase = GenerateStarterItinerary(mockRepository);
    });

    // Test data factory
    OnboardingData createValidOnboardingData({
      String name = 'John Doe',
      Set<TravelInterest>? interests,
      BudgetRange? budget,
    }) {
      return OnboardingData(
        name: name,
        destination: const Destination(
          placeId: 'paris-id',
          name: 'Paris, France',
          latitude: 48.8566,
          longitude: 2.3522,
        ),
        dateRange: DateRange(
          start: DateTime(2026, 5, 11),
          end: DateTime(2026, 5, 18),
        ),
        interests: interests ?? {TravelInterest.food, TravelInterest.culture},
        budget: budget ?? BudgetRange.moderate,
      );
    }

    Map<String, dynamic> createMockItineraryResponse() {
      return {
        'id': 'itinerary-123',
        'name': "John's Paris Adventure",
        'destination': {
          'placeId': 'paris-id',
          'name': 'Paris, France',
          'latitude': 48.8566,
          'longitude': 2.3522,
          'airportCode': 'CDG',
        },
        'dateRange': {
          'start': '2026-05-11T00:00:00.000Z',
          'end': '2026-05-18T00:00:00.000Z',
          'numberOfDays': 7,
        },
        'numberOfDays': 7,
        'isStarter': true,
        'items': [
          {
            'id': 'item-1',
            'type': 'flight_arrival',
            'time': '2026-05-11T10:00:00.000Z',
            'isCompleted': false,
            'dayNumber': 1,
            'sortOrder': 0,
          },
          {
            'id': 'item-2',
            'type': 'lunch',
            'name': 'Cafe de Paris',
            'time': '2026-05-11T12:30:00.000Z',
            'isCompleted': false,
            'dayNumber': 1,
            'sortOrder': 1,
          },
        ],
        'itemsCount': 2,
        'completedItemsCount': 0,
        'completionPercentage': 0,
        'createdAt': '2026-01-05T10:00:00.000Z',
      };
    }

    group('execute', () {
      test('should return itinerary when repository generates successfully',
          () async {
        final data = createValidOnboardingData();
        final mockResponse = createMockItineraryResponse();

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenAnswer((_) async => mockResponse);

        final result = await useCase(data);

        expect(result, equals(mockResponse));
        verify(() => mockRepository.canGenerateItinerary(data.toJson()))
            .called(1);
        verify(() => mockRepository.generateStarterItinerary(data.toJson()))
            .called(1);
      });

      test('should throw ValidationException when onboarding data is invalid',
          () async {
        final invalidData = OnboardingData(
          name: '', // Empty name is invalid
          destination: const Destination(
            placeId: '',
            name: '',
            latitude: 0,
            longitude: 0,
          ),
          dateRange: DateRange(
            start: DateTime(2026, 5, 18),
            end: DateTime(2026, 5, 11),
          ),
          interests: {}, // Empty interests is invalid
        );

        expect(
          () => useCase(invalidData),
          throwsA(isA<ValidationException>()),
        );

        verifyNever(() => mockRepository.canGenerateItinerary(any()));
        verifyNever(() => mockRepository.generateStarterItinerary(any()));
      });

      test('should include all validation errors in exception', () async {
        final invalidData = OnboardingData(
          name: '',
          destination: const Destination(
            placeId: '',
            name: '',
            latitude: 0,
            longitude: 0,
          ),
          dateRange: DateRange(
            start: DateTime(2026, 5, 18),
            end: DateTime(2026, 5, 11),
          ),
          interests: {},
        );

        expect(
          () => useCase(invalidData),
          throwsA(
            predicate(
              (ValidationException e) =>
                  e.message.contains('name') &&
                  e.message.contains('destination') &&
                  e.message.contains('interest'),
            ),
          ),
        );
      });

      test('should throw ServerException when repository cannot generate',
          () async {
        final data = createValidOnboardingData();

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => false);

        expect(
          () => useCase(data),
          throwsA(
            predicate(
              (ServerException e) =>
                  e.message.contains('Unable to generate itinerary'),
            ),
          ),
        );

        verify(() => mockRepository.canGenerateItinerary(data.toJson()))
            .called(1);
        verifyNever(() => mockRepository.generateStarterItinerary(any()));
      });

      test('should propagate network exceptions from repository', () async {
        final data = createValidOnboardingData();

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenThrow(const NetworkConnectivityException(
          message: 'No internet connection',
        ));

        expect(
          () => useCase(data),
          throwsA(isA<NetworkConnectivityException>()),
        );
      });

      test('should propagate cache exceptions from repository', () async {
        final data = createValidOnboardingData();

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenThrow(const CacheException(
          message: 'Failed to cache itinerary',
        ));

        expect(
          () => useCase(data),
          throwsA(isA<CacheException>()),
        );
      });

      test('should propagate server exceptions from repository', () async {
        final data = createValidOnboardingData();

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenThrow(const ServerException(
          message: 'Server error',
        ));

        expect(
          () => useCase(data),
          throwsA(isA<ServerException>()),
        );
      });

      test('should pass JSON representation of data to repository', () async {
        final data = createValidOnboardingData(
          interests: {
            TravelInterest.food,
            TravelInterest.art,
            TravelInterest.nature
          },
        );
        final mockResponse = createMockItineraryResponse();

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenAnswer((_) async => mockResponse);

        await useCase(data);

        final captured = verify(
          () => mockRepository.generateStarterItinerary(captureAny()),
        ).captured.single as Map<String, dynamic>;

        expect(captured['name'], data.name);
        expect(captured['interests'], isNotNull);
      });
    });

    group('Constructor', () {
      test('should store repository reference', () {
        final repo = MockItineraryGenerationRepository();
        final useCase = GenerateStarterItinerary(repo);

        expect(useCase, isA<GenerateStarterItinerary>());
      });
    });

    group('Business logic validation', () {
      test('should accept data with exactly 5 interests (maximum allowed)',
          () async {
        final data = createValidOnboardingData(
          interests: {
            TravelInterest.food,
            TravelInterest.culture,
            TravelInterest.nature,
            TravelInterest.art,
            TravelInterest.shopping,
          },
        );
        final mockResponse = createMockItineraryResponse();

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenAnswer((_) async => mockResponse);

        expect(() => useCase(data), returnsNormally);
      });

      test('should accept all budget range values', () async {
        final mockResponse = createMockItineraryResponse();

        for (final budget in BudgetRange.values) {
          final data = createValidOnboardingData(budget: budget);

          when(() => mockRepository.canGenerateItinerary(any()))
              .thenAnswer((_) async => true);
          when(() => mockRepository.generateStarterItinerary(any()))
              .thenAnswer((_) async => mockResponse);

          expect(() => useCase(data), returnsNormally);
        }
      });
    });

    group('Repository interaction', () {
      test('should call canGenerateItinerary before generateStarterItinerary',
          () async {
        final data = createValidOnboardingData();
        final mockResponse = createMockItineraryResponse();

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenAnswer((_) async => mockResponse);

        await useCase(data);

        verifyInOrder([
          () => mockRepository.canGenerateItinerary(any()),
          () => mockRepository.generateStarterItinerary(any()),
        ]);
      });

      test(
          'should not call generateStarterItinerary when canGenerateItinerary is false',
          () async {
        final data = createValidOnboardingData();

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => false);

        try {
          await useCase(data);
        } catch (_) {
          // Expected ServerException
        }

        verify(() => mockRepository.canGenerateItinerary(any())).called(1);
        verifyNever(() => mockRepository.generateStarterItinerary(any()));
      });

      test('should pass data JSON to both repository methods', () async {
        final data = createValidOnboardingData();
        final mockResponse = createMockItineraryResponse();

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenAnswer((_) async => mockResponse);

        await useCase(data);

        final canGenerateCaptured = verify(
          () => mockRepository.canGenerateItinerary(captureAny()),
        ).captured.single;

        final generateCaptured = verify(
          () => mockRepository.generateStarterItinerary(captureAny()),
        ).captured.single;

        expect(canGenerateCaptured, equals(generateCaptured));
      });
    });
  });
}
