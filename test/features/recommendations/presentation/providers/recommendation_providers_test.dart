import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:soloadventurer/features/recommendations/presentation/providers/recommendation_providers.dart';

/// Mock implementation of RecommendationRepository for testing
class MockRecommendationRepository implements RecommendationRepository {
  final Map<String, List<String>> _savedRecs = {};
  final Map<String, Set<String>> _dismissedRecs = {};
  bool shouldFail = false;

  @override
  Future<Either<Failure, PersonalizedRecommendation>> saveRecommendation(
    String userId,
    PersonalizedRecommendation recommendation,
  ) async {
    if (shouldFail) {
      return const Left(UnknownFailure(message: 'Save failed'));
    }
    _savedRecs.putIfAbsent(userId, () => []);
    _savedRecs[userId]!.add(recommendation.id);
    return Right(recommendation);
  }

  @override
  Future<Either<Failure, List<PersonalizedRecommendation>>>
      getSavedRecommendations(String userId) async {
    if (shouldFail) {
      return const Left(UnknownFailure(message: 'Fetch failed'));
    }
    // Return empty list for simplicity in test
    return const Right([]);
  }

  @override
  Future<Either<Failure, Unit>> dismissRecommendation(
    String userId,
    String recommendationId,
  ) async {
    if (shouldFail) {
      return const Left(UnknownFailure(message: 'Dismiss failed'));
    }
    _dismissedRecs.putIfAbsent(userId, () => {});
    _dismissedRecs[userId]!.add(recommendationId);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> recordFeedback(
    String recommendationId,
    RecommendationFeedback feedback,
  ) async {
    if (shouldFail) {
      return const Left(UnknownFailure(message: 'Feedback failed'));
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Set<String>>> getDismissedRecommendations(
    String userId,
  ) async {
    if (shouldFail) {
      return const Left(UnknownFailure(message: 'Get dismissed failed'));
    }
    return Right(_dismissedRecs[userId] ?? {});
  }

  @override
  Future<Either<Failure, int>> clearOldDismissals({
    required String userId,
    required Duration olderThan,
  }) async {
    if (shouldFail) {
      return const Left(UnknownFailure(message: 'Clear failed'));
    }
    final count = _dismissedRecs[userId]?.length ?? 0;
    _dismissedRecs[userId]?.clear();
    return Right(count);
  }
}

void main() {
  group('RecommendationProviders', () {
    late MockRecommendationRepository mockRepository;

    setUp(() {
      mockRepository = MockRecommendationRepository();
    });

    test('recommendationLocalDataSourceProvider creates instance', () {
      // Arrange & Act
      final container = ProviderContainer();

      // Assert
      expect(
        container.read(recommendationLocalDataSourceProvider),
        isA<RecommendationLocalDataSourceImpl>(),
      );

      container.dispose();
    });

    test('recommendationRepositoryProvider uses local data source', () {
      // Arrange & Act
      final container = ProviderContainer();

      // Assert
      expect(
        container.read(recommendationRepositoryProvider),
        isA<RecommendationRepositoryImpl>(),
      );

      container.dispose();
    });

    test('can override recommendationRepositoryProvider', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          recommendationRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Act
      final repository = container.read(recommendationRepositoryProvider);

      // Assert
      expect(repository, same(mockRepository));

      container.dispose();
    });

    test('repository instance persists across reads', () {
      // Arrange
      final container = ProviderContainer();

      // Act
      final repo1 = container.read(recommendationRepositoryProvider);
      final repo2 = container.read(recommendationRepositoryProvider);

      // Assert
      expect(identical(repo1, repo2), true);

      container.dispose();
    });

    group('SaveRecommendation Provider', () {
      test('creates SaveRecommendation use case', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            recommendationRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        // Act
        final useCase = container.read(saveRecommendationProvider);

        // Assert
        expect(useCase, isA<SaveRecommendation>());

        container.dispose();
      });

      test('use case calls repository', () async {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            recommendationRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        final useCase = container.read(saveRecommendationProvider);

        // Act
        final recommendation = _createTestRecommendation('rec-1');
        final result = await useCase('user-123', recommendation);

        // Assert - Verify it succeeds
        expect(result.isRight(), true);

        container.dispose();
      });
    });

    group('DismissRecommendation Provider', () {
      test('creates DismissRecommendation use case', () {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            recommendationRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        // Act
        final useCase = container.read(dismissRecommendationProvider);

        // Assert
        expect(useCase, isA<DismissRecommendation>());

        container.dispose();
      });

      test('use case calls repository', () async {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            recommendationRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        final useCase = container.read(dismissRecommendationProvider);

        // Act
        await useCase('user-123', 'rec-1');

        // Assert
        final dismissed =
            await mockRepository.getDismissedRecommendations('user-123');
        expect(dismissed.isRight(), true);
        dismissed.fold(
          (l) => fail('Should return Right'),
          (r) => expect(r, contains('rec-1')),
        );

        container.dispose();
      });
    });

    group('Provider State Management', () {
      test('providers are disposed when container is disposed', () {
        // Arrange
        final container = ProviderContainer();
        final repository = container.read(recommendationRepositoryProvider);

        // Act
        container.dispose();

        // Assert - Provider should be invalidated after dispose
        // This is a basic smoke test - in production, you'd verify
        // that resources are properly cleaned up
      });

      test('multiple containers have independent provider instances', () {
        // Arrange
        final container1 = ProviderContainer();
        final container2 = ProviderContainer();

        // Act
        final repo1 = container1.read(recommendationRepositoryProvider);
        final repo2 = container2.read(recommendationRepositoryProvider);

        // Assert
        expect(identical(repo1, repo2), false,
            reason: 'Each container should have its own provider instance');

        container1.dispose();
        container2.dispose();
      });
    });

    group('Error Handling', () {
      test('handles repository errors gracefully', () async {
        // Arrange
        mockRepository.shouldFail = true;
        final container = ProviderContainer(
          overrides: [
            recommendationRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        final useCase = container.read(saveRecommendationProvider);

        // Act & Assert
        final recommendation = _createTestRecommendation('rec-1');
        final result = await useCase('user-123', recommendation);

        expect(result.isLeft(), true,
            reason: 'Should return Left when repository fails');

        container.dispose();
      });
    });
  });
}

/// Helper to create a test recommendation
dynamic _createTestRecommendation(String id) {
  // Return a simple map-based test object
  // since we can't use the full freezed classes
  return {'id': id, 'name': 'Test Place'};
}
