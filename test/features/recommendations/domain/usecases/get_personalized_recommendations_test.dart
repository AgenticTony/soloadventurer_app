import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation_request.dart';
import 'package:soloadventurer/features/recommendations/domain/services/recommendation_service.dart';
import 'package:soloadventurer/features/recommendations/domain/usecases/get_personalized_recommendations.dart';

@GenerateNiceMocks([
  MockSpec<RecommendationService>(),
])
import 'get_personalized_recommendations_test.mocks.dart';

void main() {
  late GetPersonalizedRecommendations useCase;
  late MockRecommendationService mockService;

  setUp(() {
    mockService = MockRecommendationService();
    useCase = GetPersonalizedRecommendations(mockService);
    provideDummy<Either<Failure, List<PersonalizedRecommendation>>>(
      const Left(ServerFailure(message: 'dummy', statusCode: 0)),
    );
  });

  group('GetPersonalizedRecommendations', () {
    const destination = Destination(
      placeId: 'paris-france',
      name: 'Paris',
      latitude: 48.8566,
      longitude: 2.3522,
    );

    final dateRange = DateRange(
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 6, 7),
    );

    final interests = <TravelInterest>{
      TravelInterest.food,
      TravelInterest.art,
    };

    final validRequest = RecommendationRequest(
      itineraryId: 'itinerary-123',
      destination: destination,
      tripDates: dateRange,
      interests: interests,
    );

    test('returns recommendations when request is valid and service succeeds',
        () async {
      // Arrange
      final recommendations = [
        PersonalizedRecommendation(
          id: 'rec-1',
          activity: const PlaceActivity(
            id: 'place-1',
            name: 'Louvre Museum',
            category: RecommendationCategory.attraction,
            rating: 4.8,
          ),
          metadata: RecommendationMetadata(
            matchedInterests: interests,
            suggestedDate: DateTime(2026, 6, 2),
            suggestedTime: const TimeOfDay(hour: 10),
            distance: DistanceFromHotel.walking,
            weather: WeatherContext.anyWeather,
            crowdLevel: CrowdLevel.high,
          ),
          reasoning: 'Perfect match for your museum interest',
          relevanceScore: 92.0,
        ),
      ];

      when(mockService.getPersonalizedRecommendations(any))
          .thenAnswer((_) async => Right(recommendations));

      // Act
      final result = await useCase(validRequest);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (recs) {
          expect(recs, hasLength(1));
          expect(recs.first.id, 'rec-1');
          expect(recs.first.activity.name, 'Louvre Museum');
        },
      );

      verify(mockService.getPersonalizedRecommendations(validRequest))
          .called(1);
      verifyNoMoreInteractions(mockService);
    });

    test('returns ValidationFailure when request itineraryId is empty',
        () async {
      // Arrange
      final invalidRequest = RecommendationRequest(
        itineraryId: '',
        destination: destination,
        tripDates: dateRange,
        interests: interests,
      );

      // Act
      final result = await useCase(invalidRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Invalid recommendation request'));
        },
        (_) => fail('Should return Left with ValidationFailure'),
      );

      verifyZeroInteractions(mockService);
    });

    test('returns ValidationFailure when request destination is invalid',
        () async {
      // Arrange
      const invalidDestination = Destination(
        placeId: '',
        name: '',
        latitude: 0,
        longitude: 0,
      );

      final invalidRequest = RecommendationRequest(
        itineraryId: 'itinerary-123',
        destination: invalidDestination,
        tripDates: dateRange,
        interests: interests,
      );

      // Act
      final result = await useCase(invalidRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (_) => fail('Should return Left'),
      );

      verifyZeroInteractions(mockService);
    });

    test('returns ValidationFailure when request tripDates is invalid',
        () async {
      // Arrange
      final invalidDateRange = DateRange(
        start: DateTime(2020, 6, 7),
        end: DateTime(2020, 6, 1), // End before start
      );

      final invalidRequest = RecommendationRequest(
        itineraryId: 'itinerary-123',
        destination: destination,
        tripDates: invalidDateRange,
        interests: interests,
      );

      // Act
      final result = await useCase(invalidRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (_) => fail('Should return Left'),
      );

      verifyZeroInteractions(mockService);
    });

    test('returns ValidationFailure when request interests are empty',
        () async {
      // Arrange
      final invalidRequest = RecommendationRequest(
        itineraryId: 'itinerary-123',
        destination: destination,
        tripDates: dateRange,
        interests: <TravelInterest>{}, // Empty interests
      );

      // Act
      final result = await useCase(invalidRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (_) => fail('Should return Left'),
      );

      verifyZeroInteractions(mockService);
    });

    test('returns Failure when service call fails', () async {
      // Arrange
      when(mockService.getPersonalizedRecommendations(any))
          .thenAnswer((_) async => const Left(ServerFailure(
                message: 'Failed to fetch recommendations',
                statusCode: 500,
              )));

      // Act
      final result = await useCase(validRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Failed to fetch recommendations');
        },
        (_) => fail('Should return Left'),
      );

      verify(mockService.getPersonalizedRecommendations(validRequest))
          .called(1);
    });

    test('returns empty list when service returns no recommendations',
        () async {
      // Arrange
      when(mockService.getPersonalizedRecommendations(any))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(validRequest);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (recs) {
          expect(recs, isEmpty);
        },
      );
    });

    test('returns multiple recommendations in service order', () async {
      // Arrange
      final recommendations = [
        PersonalizedRecommendation(
          id: 'rec-2',
          activity: const PlaceActivity(
            id: 'place-2',
            name: 'Eiffel Tower',
            category: RecommendationCategory.attraction,
          ),
          metadata: RecommendationMetadata(
            matchedInterests: interests,
            suggestedDate: DateTime(2026, 6, 1),
            suggestedTime: const TimeOfDay(hour: 9),
            distance: DistanceFromHotel.walking,
            weather: WeatherContext.outdoor,
            crowdLevel: CrowdLevel.peak,
          ),
          reasoning: 'Iconic landmark',
          relevanceScore: 88.0,
        ),
        PersonalizedRecommendation(
          id: 'rec-1',
          activity: const PlaceActivity(
            id: 'place-1',
            name: 'Louvre Museum',
            category: RecommendationCategory.attraction,
          ),
          metadata: RecommendationMetadata(
            matchedInterests: interests,
            suggestedDate: DateTime(2026, 6, 2),
            suggestedTime: const TimeOfDay(hour: 10),
            distance: DistanceFromHotel.walking,
            weather: WeatherContext.anyWeather,
            crowdLevel: CrowdLevel.high,
          ),
          reasoning: 'Perfect match for your museum interest',
          relevanceScore: 95.0,
        ),
      ];

      when(mockService.getPersonalizedRecommendations(any))
          .thenAnswer((_) async => Right(recommendations));

      // Act
      final result = await useCase(validRequest);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (recs) {
          expect(recs, hasLength(2));
          expect(recs.first.id, 'rec-2');
          expect(recs.first.relevanceScore, 88.0);
          expect(recs.last.id, 'rec-1');
          expect(recs.last.relevanceScore, 95.0);
        },
      );
    });
  });
}
