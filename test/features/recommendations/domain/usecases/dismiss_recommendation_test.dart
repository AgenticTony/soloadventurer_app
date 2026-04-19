import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:soloadventurer/features/recommendations/domain/usecases/dismiss_recommendation.dart';

@GenerateNiceMocks([
  MockSpec<RecommendationRepository>(),
])
import 'dismiss_recommendation_test.mocks.dart';

void main() {
  late DismissRecommendation useCase;
  late MockRecommendationRepository mockRepository;

  setUp(() {
    mockRepository = MockRecommendationRepository();
    useCase = DismissRecommendation(mockRepository);
    provideDummy<Either<Failure, Unit>>(const Right(unit));
  });

  group('DismissRecommendation', () {
    test('returns unit on successful dismissal', () async {
      // Arrange
      const userId = 'user-123';
      const recommendationId = 'rec-456';

      when(mockRepository.dismissRecommendation(any, any))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(userId, recommendationId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (unitValue) {
          expect(unitValue, unit);
        },
      );

      verify(mockRepository.dismissRecommendation(userId, recommendationId))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('passes correct userId and recommendationId to repository', () async {
      // Arrange
      const userId = 'user-789';
      const recommendationId = 'rec-999';

      when(mockRepository.dismissRecommendation(any, any))
          .thenAnswer((_) async => const Right(unit));

      // Act
      await useCase(userId, recommendationId);

      // Assert
      final captured = verify(mockRepository.dismissRecommendation(
        captureAny,
        captureAny,
      )).captured;

      expect(captured[0], userId);
      expect(captured[1], recommendationId);
    });

    test('returns CacheFailure when repository fails with cache error',
        () async {
      // Arrange
      const userId = 'user-123';
      const recommendationId = 'rec-456';

      when(mockRepository.dismissRecommendation(any, any))
          .thenAnswer((_) async => const Left(CacheFailure(
                message: 'Failed to dismiss recommendation',
              )));

      // Act
      final result = await useCase(userId, recommendationId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Failed to dismiss recommendation');
        },
        (_) => fail('Should return Left'),
      );

      verify(mockRepository.dismissRecommendation(userId, recommendationId))
          .called(1);
    });

    test('returns NetworkFailure when repository fails with network error',
        () async {
      // Arrange
      const userId = 'user-123';
      const recommendationId = 'rec-456';

      when(mockRepository.dismissRecommendation(any, any))
          .thenAnswer((_) async => const Left(NetworkFailure(
                message: 'No internet connection',
              )));

      // Act
      final result = await useCase(userId, recommendationId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, 'No internet connection');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('returns ServerFailure when repository fails with server error',
        () async {
      // Arrange
      const userId = 'user-123';
      const recommendationId = 'rec-456';

      when(mockRepository.dismissRecommendation(any, any))
          .thenAnswer((_) async => const Left(ServerFailure(
                message: 'Server error',
                statusCode: 500,
              )));

      // Act
      final result = await useCase(userId, recommendationId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Server error');
          expect((failure as ServerFailure).statusCode, 500);
        },
        (_) => fail('Should return Left'),
      );
    });

    test('handles empty userId', () async {
      // Arrange
      const userId = '';
      const recommendationId = 'rec-456';

      when(mockRepository.dismissRecommendation(any, any))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(userId, recommendationId);

      // Assert
      expect(result.isRight(), true);

      verify(mockRepository.dismissRecommendation(userId, recommendationId))
          .called(1);
    });

    test('handles empty recommendationId', () async {
      // Arrange
      const userId = 'user-123';
      const recommendationId = '';

      when(mockRepository.dismissRecommendation(any, any))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(userId, recommendationId);

      // Assert
      expect(result.isRight(), true);

      verify(mockRepository.dismissRecommendation(userId, recommendationId))
          .called(1);
    });

    test('returns unknown failure for unexpected errors', () async {
      // Arrange
      const userId = 'user-123';
      const recommendationId = 'rec-456';

      when(mockRepository.dismissRecommendation(any, any))
          .thenAnswer((_) async => const Left(UnknownFailure(
                message: 'Unexpected error occurred',
              )));

      // Act
      final result = await useCase(userId, recommendationId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<UnknownFailure>());
          expect(failure.message, 'Unexpected error occurred');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('handles user data isolation', () async {
      // Arrange - Two users with the same recommendation
      const user1Id = 'user-123';
      const user2Id = 'user-456';
      const recommendationId = 'rec-1';

      when(mockRepository.dismissRecommendation(user1Id, recommendationId))
          .thenAnswer((_) async => const Right(unit));

      // Act - User 1 dismisses
      final result1 = await useCase(user1Id, recommendationId);

      // Assert - Only User 1's dismissal should be called
      verify(mockRepository.dismissRecommendation(user1Id, recommendationId))
          .called(1);
      verifyNever(
          mockRepository.dismissRecommendation(user2Id, recommendationId));

      expect(result1.isRight(), true);
    });

    test('is idempotent - can dismiss already-dismissed recommendation',
        () async {
      // Arrange
      const userId = 'user-123';
      const recommendationId = 'rec-1';

      when(mockRepository.dismissRecommendation(userId, recommendationId))
          .thenAnswer((_) async => const Right(unit));

      // Act - Dismiss twice
      final result1 = await useCase(userId, recommendationId);
      final result2 = await useCase(userId, recommendationId);

      // Assert - Both should succeed
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);
      verify(mockRepository.dismissRecommendation(userId, recommendationId))
          .called(2);
    });
  });
}
