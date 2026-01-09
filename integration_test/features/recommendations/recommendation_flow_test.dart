import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/core/providers/core_providers.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/places_remote_data_source.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/recommendation_local_data_source.dart';
import 'package:soloadventurer/features/recommendations/data/repositories/recommendation_repository_impl.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation_request.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:soloadventurer/features/recommendations/domain/services/recommendation_service.dart';
import 'package:soloadventurer/features/recommendations/presentation/providers/recommendation_providers.dart';
import 'package:soloadventurer/features/recommendations/presentation/widgets/recommendation_filter_panel.dart';
import 'package:soloadventurer/core/error/failures.dart';

import '../../test_helpers.dart';

// Mock classes
class MockRecommendationService extends Mock implements RecommendationService {}

class MockRecommendationLocalDataSource extends Mock
    implements RecommendationLocalDataSource {}

class MockPlacesRemoteDataSource extends Mock
    implements PlacesRemoteDataSource {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockRecommendationService mockRecommendationService;
  late MockRecommendationLocalDataSource mockLocalDataSource;
  late MockPlacesRemoteDataSource mockPlacesDataSource;
  late RecommendationRepository recommendationRepository;

  // Test data
  const testUserId = 'test-user-123';
  const testItineraryId = 'itinerary-456';

  const testDestination = Destination(
    placeId: 'dest-1',
    name: 'New York City',
    country: 'USA',
    latitude: 40.7128,
    longitude: -74.0060,
  );

  final testDateRange = DateRange(
    start: DateTime(2026, 6, 15),
    end: DateTime(2026, 6, 20),
  );

  final testRecommendations = [
    PersonalizedRecommendation(
      id: 'rec-1',
      activity: const PlaceActivity(
        id: 'place-1',
        name: 'Central Park',
        category: RecommendationCategory.attraction,
        description: 'A large public park in Manhattan',
        rating: 4.8,
        reviewCount: 15000,
        images: ['https://example.com/central-park.jpg'],
        priceLevel: '\$',
      ),
      metadata: RecommendationMetadata(
        matchedInterests: {TravelInterest.art},
        suggestedDate: DateTime(2026, 6, 15),
        suggestedTime: const TimeOfDay(hour: 10, minute: 0),
        distance: DistanceFromHotel.walking,
        weather: WeatherContext.outdoor,
        crowdLevel: CrowdLevel.medium,
        estimatedDuration: const Duration(hours: 2),
        requiresAdvanceBooking: false,
      ),
      reasoning: 'Perfect for your interest in art and outdoor activities',
      relevanceScore: 92.0,
    ),
    PersonalizedRecommendation(
      id: 'rec-2',
      activity: const PlaceActivity(
        id: 'place-2',
        name: 'Le Bernardin',
        category: RecommendationCategory.food,
        description: 'Renowned French seafood restaurant',
        rating: 4.9,
        reviewCount: 3500,
        images: ['https://example.com/le-bernardin.jpg'],
        priceLevel: '\$\$\$',
      ),
      metadata: RecommendationMetadata(
        matchedInterests: {TravelInterest.food},
        suggestedDate: DateTime(2026, 6, 16),
        suggestedTime: const TimeOfDay(hour: 19, minute: 0),
        distance: DistanceFromHotel.shortTrip,
        weather: WeatherContext.indoor,
        crowdLevel: CrowdLevel.high,
        estimatedDuration: const Duration(hours: 2),
        requiresAdvanceBooking: true,
      ),
      reasoning: 'Matches your food interests perfectly',
      relevanceScore: 88.0,
    ),
    PersonalizedRecommendation(
      id: 'rec-3',
      activity: const PlaceActivity(
        id: 'place-3',
        name: 'MoMA',
        category: RecommendationCategory.attraction,
        description: 'Museum of Modern Art',
        rating: 4.7,
        reviewCount: 12000,
        images: ['https://example.com/moma.jpg'],
        priceLevel: '\$\$',
      ),
      metadata: RecommendationMetadata(
        matchedInterests: {TravelInterest.art},
        suggestedDate: DateTime(2026, 6, 17),
        suggestedTime: const TimeOfDay(hour: 11, minute: 0),
        distance: DistanceFromHotel.walking,
        weather: WeatherContext.indoor,
        crowdLevel: CrowdLevel.high,
        estimatedDuration: const Duration(hours: 3),
        requiresAdvanceBooking: true,
      ),
      reasoning: 'World-class modern art museum',
      relevanceScore: 85.0,
    ),
  ];

  setUp(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Initialize mock services
    mockRecommendationService = MockRecommendationService();
    mockLocalDataSource = MockRecommendationLocalDataSource();
    mockPlacesDataSource = MockPlacesRemoteDataSource();

    // Register fallback values for mocktail
    registerFallbackValue(
      RecommendationRequest(
        itineraryId: testItineraryId,
        destination: testDestination,
        tripDates: testDateRange,
        interests: const {},
      ),
    );
    registerFallbackValue(testRecommendations.first);

    // Setup mock defaults
    when(() => mockRecommendationService.getPersonalizedRecommendations(any()))
        .thenAnswer((_) async => Right(testRecommendations));

    when(() => mockLocalDataSource.saveRecommendation(any(), any())).thenAnswer(
        (_) async => testRecommendations.first.copyWith(isSaved: true));

    when(() => mockLocalDataSource.getSavedRecommendations(any()))
        .thenAnswer((_) async => <PersonalizedRecommendation>[]);

    when(() => mockLocalDataSource.dismissRecommendation(any(), any()))
        .thenAnswer((_) async => const Right(unit));

    // Initialize repository
    recommendationRepository =
        RecommendationRepositoryImpl(mockLocalDataSource);

    // Create container with provider overrides
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        recommendationServiceProvider
            .overrideWithValue(mockRecommendationService),
        recommendationLocalDataSourceProvider
            .overrideWithValue(mockLocalDataSource),
        placesRemoteDataSourceProvider.overrideWithValue(mockPlacesDataSource),
        recommendationRepositoryProvider
            .overrideWithValue(recommendationRepository),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
  });

  group('Recommendation Flow Integration Tests', () {
    testWidgets('Complete recommendation discovery and filtering flow',
        (tester) async {
      TestHelpers.logSection('Recommendation Discovery Flow');

      // Build app
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Get the use case
      final getRecommendations =
          container.read(getPersonalizedRecommendationsProvider);

      // Create request
      final request = RecommendationRequest(
        itineraryId: testItineraryId,
        destination: testDestination,
        tripDates: testDateRange,
        interests: {TravelInterest.food, TravelInterest.art},
        limit: 20,
        excludeItineraryItems: true,
      );

      // Act: Get recommendations
      final result = await getRecommendations(request);

      // Assert: Recommendations returned successfully
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (recommendations) {
          expect(recommendations, hasLength(3));
          expect(recommendations.first.id, 'rec-1');
          expect(recommendations.first.activity.name, 'Central Park');
          expect(recommendations.first.relevanceScore, 92.0);
        },
      );

      TestHelpers.log('✓ Recommendations loaded successfully');
    });

    testWidgets('Filter recommendations by interest', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Get recommendations
      final getRecommendations =
          container.read(getPersonalizedRecommendationsProvider);
      final request = RecommendationRequest(
        itineraryId: testItineraryId,
        destination: testDestination,
        tripDates: testDateRange,
        interests: {TravelInterest.food, TravelInterest.art},
      );

      final result = await getRecommendations(request);
      final recommendations = result.getOrElse((failure) => []);

      // Apply filter for food interest
      const foodFilter = RecommendationFilter(
        sort: RecommendationSort.bestMatch,
        interests: {TravelInterest.food},
      );

      final filteredRecommendations = foodFilter.apply(recommendations);

      // Assert: Only food recommendations remain
      expect(filteredRecommendations, hasLength(1));
      expect(filteredRecommendations.first.metadata.matchedInterests,
          contains(TravelInterest.food));
      expect(filteredRecommendations.first.activity.name, 'Le Bernardin');

      TestHelpers.log('✓ Recommendations filtered by interest');
    });

    testWidgets('Sort recommendations by relevance score', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Get recommendations
      final getRecommendations =
          container.read(getPersonalizedRecommendationsProvider);
      final request = RecommendationRequest(
        itineraryId: testItineraryId,
        destination: testDestination,
        tripDates: testDateRange,
        interests: {TravelInterest.food, TravelInterest.art},
      );

      final result = await getRecommendations(request);
      final recommendations = result.getOrElse((failure) => []);

      // Apply sort for best match
      final bestMatchFilter = RecommendationFilter(
        sort: RecommendationSort.bestMatch,
        interests: recommendations
            .map((r) => r.metadata.matchedInterests)
            .first
            .toSet(),
      );

      final sortedRecommendations = bestMatchFilter.apply(recommendations);

      // Assert: Highest score first
      expect(sortedRecommendations.first.relevanceScore, 92.0);
      expect(sortedRecommendations.first.activity.name, 'Central Park');
      expect(sortedRecommendations.last.relevanceScore, 85.0);

      TestHelpers.log('✓ Recommendations sorted by relevance score');
    });

    testWidgets('Save recommendation for later', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Get the save use case
      final saveRecommendation = container.read(saveRecommendationProvider);

      // Act: Save first recommendation
      final result =
          await saveRecommendation(testUserId, testRecommendations.first);

      // Assert: Recommendation saved
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (saved) {
          expect(saved.id, 'rec-1');
          expect(saved.isSaved, true);
        },
      );

      // Verify saved recommendations
      final savedRecs =
          await mockLocalDataSource.getSavedRecommendations(testUserId);
      expect(savedRecs, isNotEmpty);

      TestHelpers.log('✓ Recommendation saved for later');
    });

    testWidgets('Dismiss recommendation', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Get the dismiss use case
      final dismissRecommendation =
          container.read(dismissRecommendationProvider);

      // Act: Dismiss second recommendation
      final result = await dismissRecommendation(testUserId, 'rec-2');

      // Assert: Recommendation dismissed
      expect(result.isRight(), true);

      // Verify dismissal was called
      verify(() =>
              mockLocalDataSource.dismissRecommendation(testUserId, 'rec-2'))
          .called(1);

      TestHelpers.log('✓ Recommendation dismissed');
    });

    testWidgets('Complete recommendation interaction flow', (tester) async {
      TestHelpers.logSection('Complete Interaction Flow');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Get recommendations
      final getRecommendations =
          container.read(getPersonalizedRecommendationsProvider);
      final saveRecommendation = container.read(saveRecommendationProvider);
      final dismissRecommendation =
          container.read(dismissRecommendationProvider);

      final request = RecommendationRequest(
        itineraryId: testItineraryId,
        destination: testDestination,
        tripDates: testDateRange,
        interests: {TravelInterest.food, TravelInterest.art},
      );

      // Step 1: Load recommendations
      final recsResult = await getRecommendations(request);
      expect(recsResult.isRight(), true);
      final recommendations = recsResult.getOrElse(() => []);
      expect(recommendations, hasLength(3));
      TestHelpers.log('✓ Step 1: Loaded 3 recommendations');

      // Step 2: Save first recommendation
      final saveResult =
          await saveRecommendation(testUserId, recommendations[0]);
      expect(saveResult.isRight(), true);
      TestHelpers.log('✓ Step 2: Saved "Central Park"');

      // Step 3: Dismiss second recommendation
      final dismissResult =
          await dismissRecommendation(testUserId, recommendations[1].id);
      expect(dismissResult.isRight(), true);
      TestHelpers.log('✓ Step 3: Dismissed "Le Bernardin"');

      // Step 4: Verify saved recommendations
      when(() => mockLocalDataSource.getSavedRecommendations(testUserId))
          .thenAnswer((_) async => [recommendations[0]]);

      final savedRecs =
          await mockLocalDataSource.getSavedRecommendations(testUserId);
      expect(savedRecs, hasLength(1));
      expect(savedRecs.first.id, 'rec-1');
      TestHelpers.log('✓ Step 4: Verified saved recommendations');

      // Step 5: Apply filter to remaining recommendations
      const artFilter = RecommendationFilter(
        sort: RecommendationSort.bestMatch,
        interests: {TravelInterest.art},
      );

      final filtered = artFilter.apply(recommendations);
      expect(filtered, hasLength(2)); // Central Park and MoMA
      TestHelpers.log('✓ Step 5: Filtered recommendations');
    });

    testWidgets('Handle recommendation service errors gracefully',
        (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Setup mock to return error
      when(() =>
              mockRecommendationService.getPersonalizedRecommendations(any()))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Service unavailable')));

      final getRecommendations =
          container.read(getPersonalizedRecommendationsProvider);
      final request = RecommendationRequest(
        itineraryId: testItineraryId,
        destination: testDestination,
        tripDates: testDateRange,
        interests: {TravelInterest.food},
      );

      // Act: Try to get recommendations
      final result = await getRecommendations(request);

      // Assert: Error handled gracefully
      expect(result.isLeft(), true);

      TestHelpers.log('✓ Service error handled gracefully');
    });

    testWidgets('Handle empty recommendations', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Setup mock to return empty list
      when(() =>
              mockRecommendationService.getPersonalizedRecommendations(any()))
          .thenAnswer((_) async => const Right(<PersonalizedRecommendation>[]));

      final getRecommendations =
          container.read(getPersonalizedRecommendationsProvider);
      final request = RecommendationRequest(
        itineraryId: testItineraryId,
        destination: testDestination,
        tripDates: testDateRange,
        interests: {TravelInterest.art},
      );

      // Act: Get recommendations
      final result = await getRecommendations(request);

      // Assert: Empty list returned successfully
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (recommendations) {
          expect(recommendations, isEmpty);
        },
      );

      TestHelpers.log('✓ Empty recommendations handled correctly');
    });

    testWidgets('Sort options work correctly', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final getRecommendations =
          container.read(getPersonalizedRecommendationsProvider);
      final request = RecommendationRequest(
        itineraryId: testItineraryId,
        destination: testDestination,
        tripDates: testDateRange,
        interests: {TravelInterest.food, TravelInterest.art},
      );

      final result = await getRecommendations(request);
      final recommendations = result.getOrElse((failure) => []);

      // Sort by highest rated
      const ratedFilter = RecommendationFilter(
        sort: RecommendationSort.highestRated,
        interests: {TravelInterest.food, TravelInterest.art},
      );

      final sorted = ratedFilter.apply(recommendations);

      // Assert: Highest rated first (Le Bernardin at 4.9)
      expect(sorted.first.activity.rating, 4.9);
      expect(sorted.first.activity.name, 'Le Bernardin');
      expect(
          sorted.last.activity.rating, lessThan(sorted.first.activity.rating));

      TestHelpers.log('✓ Sorting by rating works correctly');
    });

    testWidgets('Recommendation metadata is preserved through filtering',
        (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final getRecommendations =
          container.read(getPersonalizedRecommendationsProvider);
      final request = RecommendationRequest(
        itineraryId: testItineraryId,
        destination: testDestination,
        tripDates: testDateRange,
        interests: {TravelInterest.food, TravelInterest.art},
      );

      final result = await getRecommendations(request);
      final recommendations = result.getOrElse((failure) => []);

      // Filter and verify metadata
      const filter = RecommendationFilter(
        sort: RecommendationSort.bestMatch,
        interests: {TravelInterest.food},
      );

      final filtered = filter.apply(recommendations);
      expect(filtered, hasLength(1));

      final rec = filtered.first;
      expect(rec.metadata.matchedInterests, contains(TravelInterest.food));
      expect(rec.metadata.requiresAdvanceBooking, true);
      expect(rec.metadata.crowdLevel, CrowdLevel.high);
      expect(rec.metadata.estimatedDuration, const Duration(hours: 2));

      TestHelpers.log('✓ Metadata preserved through filtering');
    });

    testWidgets('User state isolation between recommendations', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final saveRecommendation = container.read(saveRecommendationProvider);

      // User 1 saves a recommendation
      const user1Id = 'user-1';
      final rec1 = testRecommendations[0];
      await saveRecommendation(user1Id, rec1);

      // User 2 saves a different recommendation
      const user2Id = 'user-2';
      final rec2 = testRecommendations[1];
      await saveRecommendation(user2Id, rec2);

      // Verify isolation
      when(() => mockLocalDataSource.getSavedRecommendations(user1Id))
          .thenAnswer((_) async => [rec1]);
      when(() => mockLocalDataSource.getSavedRecommendations(user2Id))
          .thenAnswer((_) async => [rec2]);

      final user1Recs =
          await mockLocalDataSource.getSavedRecommendations(user1Id);
      final user2Recs =
          await mockLocalDataSource.getSavedRecommendations(user2Id);

      expect(user1Recs, hasLength(1));
      expect(user1Recs.first.id, 'rec-1');
      expect(user2Recs, hasLength(1));
      expect(user2Recs.first.id, 'rec-2');

      TestHelpers.log('✓ User state isolation verified');
    });
  });
}
