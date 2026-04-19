import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/recommendation_provider.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/destination_repository_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/personalized_recommendation.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/repositories/destination_repository.dart';

// Mock classes
class MockDestinationRepository extends Mock implements DestinationRepository {}

void main() {
  late MockDestinationRepository mockRepository;
  late ProviderContainer container;
  const testUserId = 'user123';

  // Helper to create test destinations
  Destination createTestDestination({
    String id = 'dest1',
    String name = 'Tokyo',
    double lat = 35.6762,
    double lng = 139.6503,
    double safetyScore = 8.5,
    double soloScore = 8.0,
  }) {
    return Destination(
      id: id,
      name: name,
      description: 'Amazing city',
      latitude: lat,
      longitude: lng,
      safetyScore: safetyScore,
      safetyInsights: [],
      soloSuitabilityScore: soloScore,
      soloSuitabilityFactors: SoloSuitabilityFactors(
        safety: safetyScore,
        nightlife: 7.0,
        walkability: 9.0,
        accommodation: 8.0,
        soloDining: 7.5,
        communication: 6.5,
        overall: 7.8,
      ),
      countryCode: 'JP',
      region: 'Kanto',
      budgetLevel: BudgetLevel.moderate,
      activityLevels: [ActivityLevel.moderate],
      tags: ['urban', 'cultural'],
      images: ['https://example.com/$name.jpg'],
      popularActivities: [],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
  }

  final testDestinations = [
    createTestDestination(id: 'dest1', name: 'Tokyo'),
    createTestDestination(id: 'dest2', name: 'Kyoto', lat: 35.0116, lng: 135.7681),
    createTestDestination(id: 'dest3', name: 'Hidden Gem Village', lat: 36.0, lng: 138.0, safetyScore: 7.5, soloScore: 7.0),
  ];

  PersonalizedRecommendation createTestRecommendation({
    String id = 'rec1',
    bool expired = false,
  }) {
    final now = DateTime.now();
    return PersonalizedRecommendation(
      id: id,
      userId: testUserId,
      recommendations: [
        RecommendedDestination(
          destination: testDestinations[0],
          matchScore: 0.85,
          reason: 'High solo suitability',
          matchingFactors: ['high solo suitability', 'cultural activities'],
        ),
        RecommendedDestination(
          destination: testDestinations[1],
          matchScore: 0.75,
          reason: 'Matches your budget preferences',
          matchingFactors: ['moderate budget', 'historical sites'],
        ),
        RecommendedDestination(
          destination: testDestinations[2],
          matchScore: 0.60,
          reason: 'Off the beaten path',
          matchingFactors: ['hidden gem', 'nature'],
          isHiddenGemMatch: true,
        ),
      ],
      source: RecommendationSource.userPreferences,
      summary: 'Based on your travel preferences',
      generatedAt: now.subtract(Duration(hours: expired ? 25 : 2)),
      expiresAt: now.subtract(Duration(hours: expired ? 1 : -22)),
      totalCount: 10,
    );
  }

  setUp(() {
    mockRepository = MockDestinationRepository();
    when(() => mockRepository.getPersonalizedRecommendations(any()))
        .thenAnswer((_) async => createTestRecommendation());

    container = ProviderContainer.test(
      overrides: [
        destinationRepositoryProvider.overrideWith((ref) => mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('recommendationProvider', () {
    group('initial state', () {
      test('should auto-load recommendations on build', () async {
        // Access the provider to trigger build
        final recommendation = await container.read(
          recommendationProvider(testUserId).future,
        );

        verify(() => mockRepository.getPersonalizedRecommendations(testUserId))
            .called(1);
        expect(recommendation.recommendation, isNotNull);
        expect(recommendation.recommendation?.userId, testUserId);
      });
    });

    group('loadRecommendations via refresh', () {
      test('should load recommendations successfully', () async {
        // Wait for auto-load
        await container.read(recommendationProvider(testUserId).future);

        verify(() => mockRepository.getPersonalizedRecommendations(testUserId))
            .called(1);
      });

      test('should handle errors', () async {
        when(() => mockRepository.getPersonalizedRecommendations(any()))
            .thenThrow(Exception('Network error'));

        // Create a new container with failing mock
        final errorContainer = ProviderContainer(
          overrides: [
            destinationRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        // Trigger provider build and collect errors
        bool gotError = false;
        final sub = errorContainer.listen(
          recommendationProvider(testUserId),
          (_, next) {
            if (next.hasError) gotError = true;
          },
          fireImmediately: true,
          onError: (error, stackTrace) {
            gotError = true;
          },
        );

        // Give microtasks a chance to run
        await Future.delayed(const Duration(milliseconds: 100));

        expect(gotError, isTrue);

        sub.close();
        errorContainer.dispose();
      });
    });

    group('refresh', () {
      test('should refresh recommendations', () async {
        // Wait for initial load
        await container.read(recommendationProvider(testUserId).future);

        // Reset mock for refresh
        reset(mockRepository);
        final newRecommendation = PersonalizedRecommendation(
          id: 'rec3',
          userId: testUserId,
          recommendations: [
            RecommendedDestination(
              destination: testDestinations[1],
              matchScore: 0.90,
              reason: 'Updated recommendation',
              matchingFactors: [],
            ),
          ],
          source: RecommendationSource.aiGenerated,
          summary: 'Updated',
          generatedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
          totalCount: 8,
        );
        when(() => mockRepository.getPersonalizedRecommendations(any()))
            .thenAnswer((_) async => newRecommendation);

        await container
            .read(recommendationProvider(testUserId).notifier)
            .refresh();

        final state = container.read(recommendationProvider(testUserId));
        expect(state.value, isNotNull);
        expect(state.value!.recommendation?.recommendations.length, 1);
      });
    });

    group('refreshIfExpired', () {
      test('should refresh when recommendations are expired', () async {
        // Setup expired recommendation
        reset(mockRepository);
        when(() => mockRepository.getPersonalizedRecommendations(any()))
            .thenAnswer((_) async => createTestRecommendation(expired: true));

        // Create new container with expired data
        final expiredContainer = ProviderContainer.test(
          overrides: [
            destinationRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );
        await expiredContainer.read(recommendationProvider(testUserId).future);

        // Reset for refresh
        reset(mockRepository);
        when(() => mockRepository.getPersonalizedRecommendations(any()))
            .thenAnswer((_) async => createTestRecommendation());

        final result = await expiredContainer
            .read(recommendationProvider(testUserId).notifier)
            .refreshIfExpired();

        expect(result, isTrue);
        verify(() => mockRepository.getPersonalizedRecommendations(testUserId))
            .called(1);

        expiredContainer.dispose();
      });

      test('should not refresh when recommendations are valid', () async {
        // Already loaded with valid testRecommendation (expires in 22h)
        await container.read(recommendationProvider(testUserId).future);

        final result = await container
            .read(recommendationProvider(testUserId).notifier)
            .refreshIfExpired();

        expect(result, isFalse);
      });

      test('should return false when state has no value', () async {
        // Provider hasn't been accessed yet in a fresh container
        // Actually, accessing the provider triggers auto-load
        // Test with clear instead
        final notifier =
            container.read(recommendationProvider(testUserId).notifier);
        // Wait for auto-load first
        await container.read(recommendationProvider(testUserId).future);
        notifier.clear();

        final result = await notifier.refreshIfExpired();
        expect(result, isFalse);
      });
    });

    group('clear', () {
      test('should reset state to initial', () async {
        await container.read(recommendationProvider(testUserId).future);

        container
            .read(recommendationProvider(testUserId).notifier)
            .clear();

        final state = container.read(recommendationProvider(testUserId));
        expect(state.value, isNotNull);
        expect(state.value!.recommendation, isNull);
      });
    });

    group('getters', () {
      test(
          'highMatchRecommendations should return destinations with score >= 0.7',
          () async {
        await container.read(recommendationProvider(testUserId).future);

        final notifier =
            container.read(recommendationProvider(testUserId).notifier);
        final highMatch = notifier.highMatchRecommendations;

        expect(highMatch.length, 2);
        expect(highMatch[0].destination.name, 'Tokyo');
        expect(highMatch[1].destination.name, 'Kyoto');
      });

      test('hiddenGemRecommendations should return hidden gems', () async {
        await container.read(recommendationProvider(testUserId).future);

        final notifier =
            container.read(recommendationProvider(testUserId).notifier);
        final hiddenGems = notifier.hiddenGemRecommendations;

        expect(hiddenGems.length, 1);
        expect(hiddenGems[0].destination.name, 'Hidden Gem Village');
        expect(hiddenGems[0].isHiddenGemMatch, isTrue);
      });

      test('sortedRecommendations should sort by match score', () async {
        await container.read(recommendationProvider(testUserId).future);

        final notifier =
            container.read(recommendationProvider(testUserId).notifier);
        final sorted = notifier.sortedRecommendations;

        expect(sorted.length, 3);
        expect(sorted[0].matchScore, 0.85);
        expect(sorted[1].matchScore, 0.75);
        expect(sorted[2].matchScore, 0.60);
      });

      test('isExpired should return false for valid recommendations', () async {
        await container.read(recommendationProvider(testUserId).future);

        final notifier =
            container.read(recommendationProvider(testUserId).notifier);
        expect(notifier.isExpired, isFalse);
      });

      test('isValid should return true for valid recommendations', () async {
        await container.read(recommendationProvider(testUserId).future);

        final notifier =
            container.read(recommendationProvider(testUserId).notifier);
        expect(notifier.isValid, isTrue);
      });

      test('summary should return recommendation summary', () async {
        await container.read(recommendationProvider(testUserId).future);

        final notifier =
            container.read(recommendationProvider(testUserId).notifier);
        expect(notifier.summary, 'Based on your travel preferences');
      });

      test('source should return recommendation source', () async {
        await container.read(recommendationProvider(testUserId).future);

        final notifier =
            container.read(recommendationProvider(testUserId).notifier);
        expect(notifier.source, RecommendationSource.userPreferences);
      });

      test('totalCount should return total count', () async {
        await container.read(recommendationProvider(testUserId).future);

        final notifier =
            container.read(recommendationProvider(testUserId).notifier);
        expect(notifier.totalCount, 10);
      });

      test('getters should return empty/null when state has no value',
          () async {
        // Wait for auto-load then clear
        await container.read(recommendationProvider(testUserId).future);
        container
            .read(recommendationProvider(testUserId).notifier)
            .clear();

        final notifier =
            container.read(recommendationProvider(testUserId).notifier);

        expect(notifier.highMatchRecommendations.isEmpty, isTrue);
        expect(notifier.hiddenGemRecommendations.isEmpty, isTrue);
        expect(notifier.sortedRecommendations.isEmpty, isTrue);
        expect(notifier.isExpired, isFalse);
        expect(notifier.isValid, isFalse);
        expect(notifier.summary, isNull);
        expect(notifier.source, isNull);
        expect(notifier.totalCount, 0);
      });
    });
  });
}
