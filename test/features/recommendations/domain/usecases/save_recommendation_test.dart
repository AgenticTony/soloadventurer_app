import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:soloadventurer/features/recommendations/domain/usecases/save_recommendation.dart';

@GenerateNiceMocks([
  MockSpec<RecommendationRepository>(),
])
import 'save_recommendation_test.mocks.dart';

void main() {
  late SaveRecommendation useCase;
  late MockRecommendationRepository mockRepository;

  setUp(() {
    mockRepository = MockRecommendationRepository();
    useCase = SaveRecommendation(mockRepository);
  });

  group('SaveRecommendation', () {
    final recommendation = PersonalizedRecommendation(
      id: 'rec-123',
      activity: const PlaceActivity(
        id: 'place-1',
        name: 'Test Restaurant',
        category: RecommendationCategory.food,
        rating: 4.5,
      ),
      metadata: RecommendationMetadata(
        matchedInterests: {TravelInterest.foodTours},
        suggestedDate: DateTime(2026, 6, 15),
        suggestedTime: const TimeOfDay(hour: 12),
        distance: DistanceFromHotel.walking,
        weather: WeatherContext.anyWeather,
        crowdLevel: CrowdLevel.medium,
      ),
      reasoning: 'Great match for your interests',
      relevanceScore: 85.0,
      isSaved: false,
    );

    test('returns saved recommendation marked as saved', () async {
      // Arrange
      final savedRecommendation = recommendation.copyWith(isSaved: true);

      when(mockRepository.saveRecommendation(any, any))
          .thenAnswer((_) async => Right(savedRecommendation));

      // Act
      final result = await useCase('user-123', recommendation);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (saved) {
          expect(saved.id, 'rec-123');
          expect(saved.isSaved, true);
          expect(saved.activity.name, 'Test Restaurant');
        },
      );

      verify(mockRepository.saveRecommendation('user-123', savedRecommendation))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('passes recommendation with isSaved=true to repository', () async {
      // Arrange
      final savedRecommendation = recommendation.copyWith(isSaved: true);

      when(mockRepository.saveRecommendation(any, any))
          .thenAnswer((_) async => Right(savedRecommendation));

      // Act
      await useCase('user-456', recommendation);

      // Assert
      final captured = verify(mockRepository.saveRecommendation(
        captureAny,
        captureAny,
      )).captured;

      expect(captured[0], 'user-456');
      expect(captured[1], isA<PersonalizedRecommendation>());
      expect((captured[1] as PersonalizedRecommendation).isSaved, true);
    });

    test('returns Failure when repository save fails', () async {
      // Arrange
      when(mockRepository.saveRecommendation(any, any))
          .thenAnswer((_) async => const Left(CacheFailure(
                message: 'Failed to save recommendation',
              )));

      // Act
      final result = await useCase('user-123', recommendation);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Failed to save recommendation');
        },
        (_) => fail('Should return Left'),
      );

      verify(mockRepository.saveRecommendation('user-123', any)).called(1);
    });

    test('returns NetworkFailure when repository has network error', () async {
      // Arrange
      when(mockRepository.saveRecommendation(any, any))
          .thenAnswer((_) async => const Left(NetworkFailure(
                message: 'No internet connection',
              )));

      // Act
      final result = await useCase('user-123', recommendation);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
        },
        (_) => fail('Should return Left'),
      );
    });

    test('preserves all original recommendation properties', () async {
      // Arrange
      final savedRecommendation = recommendation.copyWith(isSaved: true);

      when(mockRepository.saveRecommendation(any, any))
          .thenAnswer((_) async => Right(savedRecommendation));

      // Act
      final result = await useCase('user-789', recommendation);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (saved) {
          expect(saved.id, recommendation.id);
          expect(saved.activity, recommendation.activity);
          expect(saved.metadata, recommendation.metadata);
          expect(saved.reasoning, recommendation.reasoning);
          expect(saved.relevanceScore, recommendation.relevanceScore);
          expect(saved.source, recommendation.source);
          expect(saved.isAddedToItinerary, recommendation.isAddedToItinerary);
          expect(saved.isSaved, true); // Only this should change
        },
      );
    });

    test('handles already saved recommendation', () async {
      // Arrange
      final alreadySaved = recommendation.copyWith(isSaved: true);

      when(mockRepository.saveRecommendation(any, any))
          .thenAnswer((_) async => Right(alreadySaved));

      // Act
      final result = await useCase('user-123', alreadySaved);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (saved) {
          expect(saved.isSaved, true);
        },
      );
    });

    test('handles recommendation with isAddedToItinerary=true', () async {
      // Arrange
      final addedToItinerary = recommendation.copyWith(
        isSaved: true,
        isAddedToItinerary: true,
      );

      when(mockRepository.saveRecommendation(any, any))
          .thenAnswer((_) async => Right(addedToItinerary));

      // Act
      final result = await useCase('user-123', recommendation);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (saved) {
          expect(saved.isSaved, true);
          expect(saved.isAddedToItinerary, true);
        },
      );
    });

    test('passes correct userId to repository', () async {
      // Arrange
      const userId = 'custom-user-id';
      final savedRecommendation = recommendation.copyWith(isSaved: true);

      when(mockRepository.saveRecommendation(any, any))
          .thenAnswer((_) async => Right(savedRecommendation));

      // Act
      await useCase(userId, recommendation);

      // Assert
      verify(mockRepository.saveRecommendation(userId, any)).called(1);
    });
  });
}
