import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soloadventurer/core/error/exceptions.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/recommendation_local_data_source.dart';
import 'package:soloadventurer/features/recommendations/data/repositories/recommendation_repository_impl.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation_request.dart';

@GenerateNiceMocks([
  MockSpec<RecommendationLocalDataSource>(),
])
import 'recommendation_repository_impl_test.mocks.dart';

void main() {
  late RecommendationRepositoryImpl repository;
  late MockRecommendationLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockRecommendationLocalDataSource();
    repository = RecommendationRepositoryImpl(mockDataSource);
  });

  group('RecommendationRepositoryImpl', () {
    final recommendation = PersonalizedRecommendation(
      id: 'rec-123',
      activity: const PlaceActivity(
        id: 'place-1',
        name: 'Test Restaurant',
        category: RecommendationCategory.food,
        rating: 4.5,
      ),
      metadata: RecommendationMetadata(
        matchedInterests: {TravelInterest.food},
        suggestedDate: DateTime(2026, 6, 15),
        suggestedTime: const TimeOfDay(hour: 12),
        distance: DistanceFromHotel.walking,
        weather: WeatherContext.anyWeather,
        crowdLevel: CrowdLevel.medium,
      ),
      reasoning: 'Great match',
      relevanceScore: 85.0,
    );

    group('saveRecommendation', () {
      test('returns saved recommendation on success', () async {
        // Arrange
        const userId = 'user-123';
        when(mockDataSource.saveRecommendation(any, any))
            .thenAnswer((_) async => recommendation);

        // Act
        final result =
            await repository.saveRecommendation(userId, recommendation);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should return Right'),
          (saved) {
            expect(saved.id, 'rec-123');
          },
        );

        verify(mockDataSource.saveRecommendation(userId, recommendation))
            .called(1);
      });

      test('returns cache failure on RepositoryException', () async {
        // Arrange
        const userId = 'user-123';
        when(mockDataSource.saveRecommendation(any, any))
            .thenThrow(RepositoryException('Save failed'));

        // Act
        final result =
            await repository.saveRecommendation(userId, recommendation);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, 'Save failed');
          },
          (_) => fail('Should return Left'),
        );
      });

      test('returns unknown failure on unexpected exception', () async {
        // Arrange
        const userId = 'user-123';
        when(mockDataSource.saveRecommendation(any, any))
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result =
            await repository.saveRecommendation(userId, recommendation);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<UnknownFailure>());
          },
          (_) => fail('Should return Left'),
        );
      });
    });

    group('getSavedRecommendations', () {
      test('returns list of saved recommendations on success', () async {
        // Arrange
        const userId = 'user-123';
        final recommendations = [recommendation];
        when(mockDataSource.getSavedRecommendations(any))
            .thenAnswer((_) async => recommendations);

        // Act
        final result = await repository.getSavedRecommendations(userId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should return Right'),
          (saved) {
            expect(saved, hasLength(1));
            expect(saved.first.id, 'rec-123');
          },
        );

        verify(mockDataSource.getSavedRecommendations(userId)).called(1);
      });

      test('returns empty list when no recommendations saved', () async {
        // Arrange
        const userId = 'user-123';
        when(mockDataSource.getSavedRecommendations(any))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getSavedRecommendations(userId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should return Right'),
          (saved) {
            expect(saved, isEmpty);
          },
        );
      });

      test('returns cache failure on RepositoryException', () async {
        // Arrange
        const userId = 'user-123';
        when(mockDataSource.getSavedRecommendations(any))
            .thenThrow(RepositoryException('Fetch failed'));

        // Act
        final result = await repository.getSavedRecommendations(userId);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
          },
          (_) => fail('Should return Left'),
        );
      });
    });

    group('dismissRecommendation', () {
      test('returns unit on successful dismissal', () async {
        // Arrange
        const userId = 'user-123';
        const recommendationId = 'rec-456';
        when(mockDataSource.dismissRecommendation(any, any))
            .thenAnswer((_) async {
          return;
        });

        // Act
        final result =
            await repository.dismissRecommendation(userId, recommendationId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should return Right'),
          (unitValue) {
            expect(unitValue, unit);
          },
        );

        verify(mockDataSource.dismissRecommendation(userId, recommendationId))
            .called(1);
      });

      test('returns cache failure on RepositoryException', () async {
        // Arrange
        const userId = 'user-123';
        const recommendationId = 'rec-456';
        when(mockDataSource.dismissRecommendation(any, any))
            .thenThrow(RepositoryException('Dismiss failed'));

        // Act
        final result =
            await repository.dismissRecommendation(userId, recommendationId);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
          },
          (_) => fail('Should return Left'),
        );
      });
    });

    group('recordFeedback', () {
      test('returns unit on successful feedback recording', () async {
        // Arrange
        const recommendationId = 'rec-123';
        const feedback = RecommendationFeedback.helpful;
        when(mockDataSource.recordFeedback(any, any)).thenAnswer((_) async {
          return;
        });

        // Act
        final result =
            await repository.recordFeedback(recommendationId, feedback);

        // Assert
        expect(result.isRight(), true);

        verify(mockDataSource.recordFeedback(recommendationId, feedback))
            .called(1);
      });

      test('returns cache failure on RepositoryException', () async {
        // Arrange
        const recommendationId = 'rec-123';
        const feedback = RecommendationFeedback.notHelpful;
        when(mockDataSource.recordFeedback(any, any))
            .thenThrow(RepositoryException('Feedback failed'));

        // Act
        final result =
            await repository.recordFeedback(recommendationId, feedback);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
          },
          (_) => fail('Should return Left'),
        );
      });
    });

    group('getDismissedRecommendations', () {
      test('returns set of dismissed recommendation IDs on success', () async {
        // Arrange
        const userId = 'user-123';
        final dismissedIds = {'rec-1', 'rec-2', 'rec-3'};
        when(mockDataSource.getDismissedRecommendations(any))
            .thenAnswer((_) async => dismissedIds);

        // Act
        final result = await repository.getDismissedRecommendations(userId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should return Right'),
          (ids) {
            expect(ids, hasLength(3));
            expect(ids, contains('rec-1'));
            expect(ids, contains('rec-2'));
            expect(ids, contains('rec-3'));
          },
        );

        verify(mockDataSource.getDismissedRecommendations(userId)).called(1);
      });

      test('returns empty set when no dismissals', () async {
        // Arrange
        const userId = 'user-123';
        when(mockDataSource.getDismissedRecommendations(any))
            .thenAnswer((_) async => <String>{});

        // Act
        final result = await repository.getDismissedRecommendations(userId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should return Right'),
          (ids) {
            expect(ids, isEmpty);
          },
        );
      });
    });

    group('clearOldDismissals', () {
      test('returns count of cleared dismissals on success', () async {
        // Arrange
        const userId = 'user-123';
        const olderThan = Duration(days: 30);
        const count = 5;
        when(mockDataSource.clearOldDismissals(
          userId: anyNamed('userId'),
          olderThan: anyNamed('olderThan'),
        )).thenAnswer((_) async => count);

        // Act
        final result = await repository.clearOldDismissals(
          userId: userId,
          olderThan: olderThan,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should return Right'),
          (clearedCount) {
            expect(clearedCount, 5);
          },
        );

        verify(mockDataSource.clearOldDismissals(
          userId: userId,
          olderThan: olderThan,
        )).called(1);
      });

      test('returns zero count when nothing to clear', () async {
        // Arrange
        const userId = 'user-123';
        const olderThan = Duration(days: 30);
        when(mockDataSource.clearOldDismissals(
          userId: anyNamed('userId'),
          olderThan: anyNamed('olderThan'),
        )).thenAnswer((_) async => 0);

        // Act
        final result = await repository.clearOldDismissals(
          userId: userId,
          olderThan: olderThan,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should return Right'),
          (clearedCount) {
            expect(clearedCount, 0);
          },
        );
      });

      test('returns cache failure on RepositoryException', () async {
        // Arrange
        const userId = 'user-123';
        const olderThan = Duration(days: 30);
        when(mockDataSource.clearOldDismissals(
          userId: anyNamed('userId'),
          olderThan: anyNamed('olderThan'),
        )).thenThrow(RepositoryException('Clear failed'));

        // Act
        final result = await repository.clearOldDismissals(
          userId: userId,
          olderThan: olderThan,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
          },
          (_) => fail('Should return Left'),
        );
      });
    });

    group('User Data Isolation', () {
      test('separates data by userId', () async {
        // Arrange
        const user1Id = 'user-123';
        const user2Id = 'user-456';
        const recommendationId = 'rec-1';

        when(mockDataSource.dismissRecommendation(user1Id, recommendationId))
            .thenAnswer((_) async {
          return;
        });

        // Act - User 1 dismisses
        await repository.dismissRecommendation(user1Id, recommendationId);

        // Assert - Only User 1's dismissal called
        verify(mockDataSource.dismissRecommendation(user1Id, recommendationId))
            .called(1);
        verifyNever(
            mockDataSource.dismissRecommendation(user2Id, recommendationId));
      });
    });
  });
}
