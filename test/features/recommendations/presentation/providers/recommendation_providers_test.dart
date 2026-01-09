import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:soloadventurer/features/recommendations/presentation/providers/recommendation_providers.dart';

/// Mock implementation of RecommendationRepository for testing
class MockRecommendationRepository implements RecommendationRepository {
  final Map<String, List<String>> _savedRecs = {};
  final Map<String, Set<String>> _dismissedRecs = {};
  bool shouldFail = false;

  @override
  Future saveRecommendation(String userId, recommendation) async {
    if (shouldFail) throw Exception('Save failed');
    _savedRecs.putIfAbsent(userId, () => []);
    _savedRecs[userId]!.add(recommendation.id);
    return recommendation;
  }

  @override
  Future getSavedRecommendations(String userId) async {
    if (shouldFail) throw Exception('Fetch failed');
    return _savedRecs[userId] ?? [];
  }

  @override
  Future dismissRecommendation(String userId, recommendationId) async {
    if (shouldFail) throw Exception('Dismiss failed');
    _dismissedRecs.putIfAbsent(userId, () => {});
    _dismissedRecs[userId]!.add(recommendationId);
    return Future.value();
  }

  @override
  Future recordFeedback(String recommendationId, feedback) async {
    if (shouldFail) throw Exception('Feedback failed');
    return Future.value();
  }

  @override
  Future getDismissedRecommendations(String userId) async {
    if (shouldFail) throw Exception('Get dismissed failed');
    return _dismissedRecs[userId] ?? {};
  }

  @override
  Future clearOldDismissals(
      {required String userId, required Duration olderThan}) async {
    if (shouldFail) throw Exception('Clear failed');
    final count = _dismissedRecs[userId]?.length ?? 0;
    _dismissedRecs[userId]?.clear();
    return count;
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
        await useCase('user-123', recommendation);

        // Assert - Verify it doesn't throw
        final saved = await mockRepository.getSavedRecommendations('user-123');
        expect(saved, isNotEmpty);

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
        expect(dismissed, contains('rec-1'));

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
