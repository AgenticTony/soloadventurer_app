import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/recommendation_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/personalized_recommendation.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/repositories/destination_repository.dart';

// Mock classes
class MockDestinationRepository extends Mock implements DestinationRepository {}

void main() {
  late MockDestinationRepository mockRepository;
  late RecommendationNotifier notifier;
  const testUserId = 'user123';

  // Test data
  final testDestinations = [
    Destination(
      id: 'dest1',
      name: 'Tokyo',
      description: 'Amazing city',
      location: (lat: 35.6762, lng: 139.6503),
      safetyScore: 8.5,
      soloSuitabilityScore: 8.0,
      soloSuitabilityFactors: const SoloSuitabilityFactors(
        safety: 8.5,
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
      activityLevel: ActivityLevel.moderate,
      tags: ['urban', 'cultural'],
      images: ['https://example.com/tokyo.jpg'],
      popularActivities: [],
      bestTimeToVisit: 'Spring',
    ),
    Destination(
      id: 'dest2',
      name: 'Kyoto',
      description: 'Historic city',
      location: (lat: 35.0116, lng: 135.7681),
      safetyScore: 9.0,
      soloSuitabilityScore: 8.5,
      soloSuitabilityFactors: const SoloSuitabilityFactors(
        safety: 9.0,
        nightlife: 6.0,
        walkability: 8.5,
        accommodation: 8.5,
        soloDining: 8.0,
        communication: 6.0,
        overall: 7.7,
      ),
      countryCode: 'JP',
      region: 'Kansai',
      budgetLevel: BudgetLevel.moderate,
      activityLevel: ActivityLevel.relaxed,
      tags: ['cultural', 'historical'],
      images: ['https://example.com/kyoto.jpg'],
      popularActivities: [],
      bestTimeToVisit: 'Spring',
    ),
    Destination(
      id: 'dest3',
      name: 'Hidden Gem Village',
      description: 'Less known destination',
      location: (lat: 36.0, lng: 138.0),
      safetyScore: 7.5,
      soloSuitabilityScore: 7.0,
      soloSuitabilityFactors: const SoloSuitabilityFactors(
        safety: 7.5,
        nightlife: 5.0,
        walkability: 7.0,
        accommodation: 7.0,
        soloDining: 7.0,
        communication: 5.5,
        overall: 6.5,
      ),
      countryCode: 'JP',
      region: 'Chubu',
      budgetLevel: BudgetLevel.budget,
      activityLevel: ActivityLevel.relaxed,
      tags: ['nature', 'hidden'],
      images: ['https://example.com/hidden.jpg'],
      popularActivities: [],
      bestTimeToVisit: 'Summer',
    ),
  ];

  final testRecommendation = PersonalizedRecommendation(
    id: 'rec1',
    userId: testUserId,
    destinations: [
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
        isHiddenGem: true,
      ),
    ],
    source: RecommendationSource.userPreferences,
    summary: 'Based on your travel preferences',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    expiresAt: DateTime.now().add(const Duration(hours: 22)),
    totalCount: 10,
  );

  final expiredRecommendation = PersonalizedRecommendation(
    id: 'rec2',
    userId: testUserId,
    destinations: [
      RecommendedDestination(
        destination: testDestinations[0],
        matchScore: 0.85,
        reason: 'Test',
        matchingFactors: [],
      ),
    ],
    source: RecommendationSource.aiGenerated,
    summary: 'Expired recommendations',
    createdAt: DateTime.now().subtract(const Duration(hours: 25)),
    expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
    totalCount: 5,
  );

  setUp(() {
    mockRepository = MockDestinationRepository();
    // Setup mock to return test recommendation
    when(() => mockRepository.getPersonalizedRecommendations(any()))
        .thenAnswer((_) async => testRecommendation);
    notifier = RecommendationNotifier(mockRepository, testUserId);

    // Wait for auto-load
    Future.delayed(const Duration(milliseconds: 100));
  });

  group('RecommendationNotifier', () {
    group('initial state', () {
      test('should start with initial state', () {
        // Clear auto-loaded state
        notifier.clear();

        expect(notifier.state.value, isNotNull);
        expect(notifier.state.value!.recommendation, isNull);
      });

      test('should auto-load recommendations on creation', () async {
        // Create a new notifier to verify auto-load
        final newNotifier = RecommendationNotifier(mockRepository, testUserId);

        // Wait for auto-load
        await Future.delayed(const Duration(milliseconds: 100));

        verify(() => mockRepository.getPersonalizedRecommendations(testUserId))
            .called(1);
      });
    });

    group('loadRecommendations', () {
      test('should load recommendations successfully', () async {
        notifier.clear(); // Clear auto-loaded state

        await notifier.loadRecommendations();

        verify(() => mockRepository.getPersonalizedRecommendations(testUserId))
            .called(1);
        expect(notifier.state.value, isNotNull);
        expect(notifier.state.value!.recommendation?.userId, testUserId);
        expect(notifier.state.value!.destinations.length, 3);
      });

      test('should handle errors', () async {
        notifier.clear();
        when(() => mockRepository.getPersonalizedRecommendations(any()))
            .thenThrow(Exception('Network error'));

        await notifier.loadRecommendations();

        expect(notifier.state.hasValue, isFalse);
      });
    });

    group('refresh', () {
      test('should refresh recommendations', () async {
        // Wait for initial load
        await Future.delayed(const Duration(milliseconds: 100));

        // Reset mock
        reset(mockRepository);
        final newRecommendation = PersonalizedRecommendation(
          id: 'rec3',
          userId: testUserId,
          destinations: [
            RecommendedDestination(
              destination: testDestinations[1],
              matchScore: 0.90,
              reason: 'Updated recommendation',
              matchingFactors: [],
            ),
          ],
          source: RecommendationSource.aiGenerated,
          summary: 'Updated',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
          totalCount: 8,
        );
        when(() => mockRepository.getPersonalizedRecommendations(any()))
            .thenAnswer((_) async => newRecommendation);

        await notifier.refresh();

        expect(notifier.state.value!.destinations.length, 1);
        expect(notifier.state.value!.destinations[0].matchScore, 0.90);
      });

      test('should handle errors during refresh', () async {
        // Setup initial state
        when(() => mockRepository.getPersonalizedRecommendations(any()))
            .thenAnswer((_) async => testRecommendation);
        await notifier.loadRecommendations();

        // Mock error for refresh
        reset(mockRepository);
        when(() => mockRepository.getPersonalizedRecommendations(any()))
            .thenThrow(Exception('Network error'));

        await notifier.refresh();

        expect(notifier.state.hasValue, isFalse);
      });
    });

    group('refreshIfExpired', () {
      test('should refresh when recommendations are expired', () async {
        // Setup expired recommendation
        notifier.clear();
        when(() => mockRepository.getPersonalizedRecommendations(any()))
            .thenAnswer((_) async => expiredRecommendation);
        await notifier.loadRecommendations();

        // Reset mock for refresh
        reset(mockRepository);
        when(() => mockRepository.getPersonalizedRecommendations(any()))
            .thenAnswer((_) async => testRecommendation);

        final result = await notifier.refreshIfExpired();

        expect(result, isTrue);
        verify(() => mockRepository.getPersonalizedRecommendations(testUserId))
            .called(1);
      });

      test('should not refresh when recommendations are valid', () async {
        // Already loaded with valid testRecommendation

        final result = await notifier.refreshIfExpired();

        expect(result, isFalse);
        // Should not call repository again
        verify(() => mockRepository.getPersonalizedRecommendations(any()))
            .called(1); // Only initial call
      });

      test('should return false when state has no value', () async {
        notifier.clear();

        final result = await notifier.refreshIfExpired();

        expect(result, isFalse);
      });
    });

    group('clear', () {
      test('should reset state to initial', () async {
        await notifier.loadRecommendations();

        notifier.clear();

        expect(notifier.state.value!.recommendation, isNull);
      });
    });

    group('getters', () {
      test(
          'highMatchRecommendations should return destinations with score >= 0.7',
          () async {
        notifier.clear();
        await notifier.loadRecommendations();

        final highMatch = notifier.highMatchRecommendations;

        expect(highMatch.length, 2);
        expect(highMatch[0].destination.name, 'Tokyo');
        expect(highMatch[1].destination.name, 'Kyoto');
      });

      test('hiddenGemRecommendations should return hidden gems', () async {
        notifier.clear();
        await notifier.loadRecommendations();

        final hiddenGems = notifier.hiddenGemRecommendations;

        expect(hiddenGems.length, 1);
        expect(hiddenGems[0].destination.name, 'Hidden Gem Village');
        expect(hiddenGems[0].isHiddenGem, isTrue);
      });

      test('sortedRecommendations should sort by match score', () async {
        notifier.clear();
        await notifier.loadRecommendations();

        final sorted = notifier.sortedRecommendations;

        expect(sorted.length, 3);
        expect(sorted[0].matchScore, 0.85);
        expect(sorted[1].matchScore, 0.75);
        expect(sorted[2].matchScore, 0.60);
      });

      test('isExpired should return true for expired recommendations',
          () async {
        notifier.clear();
        when(() => mockRepository.getPersonalizedRecommendations(any()))
            .thenAnswer((_) async => expiredRecommendation);
        await notifier.loadRecommendations();

        expect(notifier.isExpired, isTrue);
      });

      test('isExpired should return false for valid recommendations', () async {
        expect(notifier.isExpired, isFalse);
      });

      test('isValid should return true for valid recommendations', () async {
        expect(notifier.isValid, isTrue);
      });

      test('isValid should return false for expired recommendations', () async {
        notifier.clear();
        when(() => mockRepository.getPersonalizedRecommendations(any()))
            .thenAnswer((_) async => expiredRecommendation);
        await notifier.loadRecommendations();

        expect(notifier.isValid, isFalse);
      });

      test('summary should return recommendation summary', () async {
        notifier.clear();
        await notifier.loadRecommendations();

        expect(notifier.summary, 'Based on your travel preferences');
      });

      test('source should return recommendation source', () async {
        notifier.clear();
        await notifier.loadRecommendations();

        expect(notifier.source, RecommendationSource.userPreferences);
      });

      test('totalCount should return total count', () async {
        notifier.clear();
        await notifier.loadRecommendations();

        expect(notifier.totalCount, 10);
      });

      test('getters should return empty/null when state has no value',
          () async {
        notifier.clear();

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

    group('state helpers', () {
      test('isExpired should correctly identify expired recommendations',
          () async {
        notifier.clear();
        when(() => mockRepository.getPersonalizedRecommendations(any()))
            .thenAnswer((_) async => expiredRecommendation);
        await notifier.loadRecommendations();

        expect(notifier.state.value!.isExpired, isTrue);
      });

      test('isValid should correctly identify valid recommendations', () async {
        expect(notifier.state.value!.isValid, isTrue);
      });

      test('highMatchRecommendations should filter correctly', () async {
        notifier.clear();
        await notifier.loadRecommendations();

        expect(notifier.state.value!.highMatchRecommendations.length, 2);
      });

      test('hiddenGemRecommendations should filter correctly', () async {
        notifier.clear();
        await notifier.loadRecommendations();

        expect(notifier.state.value!.hiddenGemRecommendations.length, 1);
      });

      test('sortedByMatchScore should sort correctly', () async {
        notifier.clear();
        await notifier.loadRecommendations();

        final sorted = notifier.state.value!.sortedByMatchScore;
        expect(sorted[0].matchScore >= sorted[1].matchScore, isTrue);
        expect(sorted[1].matchScore >= sorted[2].matchScore, isTrue);
      });
    });
  });
}
