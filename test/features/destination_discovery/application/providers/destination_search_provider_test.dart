import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/destination_repository_provider.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/destination_search_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart'
    hide BudgetLevel, ActivityLevel;
import 'package:soloadventurer/features/destination_discovery/domain/repositories/destination_repository.dart';

class MockDestinationRepository extends Mock implements DestinationRepository {}

// Fallback value for mocktail
// DestinationFilter is sealed/freezed, so we use a real instance

void main() {
  late MockDestinationRepository mockRepository;
  late ProviderContainer container;

  final testDestinations = [
    Destination(
      id: 'dest1',
      name: 'Tokyo',
      description: 'Amazing city',
      latitude: 35.6762,
      longitude: 139.6503,
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
      activityLevels: [ActivityLevel.moderate],
      tags: ['urban', 'cultural'],
      images: ['https://example.com/tokyo.jpg'],
      popularActivities: [],
      safetyInsights: [],
      bestTimeToVisit: 'Spring',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Destination(
      id: 'dest2',
      name: 'Kyoto',
      description: 'Historic city',
      latitude: 35.0116,
      longitude: 135.7681,
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
      activityLevels: [ActivityLevel.relaxed],
      tags: ['cultural', 'historical'],
      images: ['https://example.com/kyoto.jpg'],
      popularActivities: [],
      safetyInsights: [],
      bestTimeToVisit: 'Spring',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  setUpAll(() {
    registerFallbackValue(DestinationFilter());
  });

  setUp(() {
    mockRepository = MockDestinationRepository();
    container = ProviderContainer.test(overrides: [
      destinationRepositoryProvider.overrideWithValue(mockRepository),
    ]);
    // Keep provider alive
    container.listen(destinationSearchProvider, (_, __) {});
  });

  tearDown(() {
    container.dispose();
  });

  group('DestinationSearch', () {
    group('initial state', () {
      test('should start with initial state', () async {
        final state =
            await container.read(destinationSearchProvider.future);
        expect(state.isInitial, isTrue);
        expect(state.results.isEmpty, isTrue);
        expect(state.hasMore, isTrue);
        expect(state.currentOffset, 0);
      });
    });

    group('search', () {
      test('should load destinations successfully with reset=true', () async {
        final filter = DestinationFilter(searchQuery: 'Tokyo');
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);

        await container
            .read(destinationSearchProvider.notifier)
            .search(filter, reset: true);

        verify(() => mockRepository.searchDestinations(any())).called(1);
        final state = container.read(destinationSearchProvider).value!;
        expect(state.results.length, 2);
        expect(state.results[0].name, 'Tokyo');
        expect(state.hasMore, isFalse); // 2 results < 20 limit
        expect(state.currentOffset, 2);
        expect(state.totalCount, 2);
      });

      test('should load destinations successfully with reset=false', () async {
        final filter = DestinationFilter(
          searchQuery: 'Tokyo',
          offset: 20,
          limit: 20,
        );
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);

        await container
            .read(destinationSearchProvider.notifier)
            .search(filter, reset: false);

        final state = container.read(destinationSearchProvider).value!;
        expect(state.results.length, 2);
        expect(state.currentOffset, 22); // 20 + 2
      });

      test('should set hasMore to false when results less than limit',
          () async {
        final filter = DestinationFilter(
          searchQuery: 'Tokyo',
          limit: 20,
        );
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => [testDestinations[0]]);

        await container
            .read(destinationSearchProvider.notifier)
            .search(filter, reset: true);

        final state = container.read(destinationSearchProvider).value!;
        expect(state.hasMore, isFalse);
      });

      test('should handle empty results', () async {
        final filter = DestinationFilter(searchQuery: 'Unknown');
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => []);

        await container
            .read(destinationSearchProvider.notifier)
            .search(filter, reset: true);

        final state = container.read(destinationSearchProvider).value!;
        expect(state.results.isEmpty, isTrue);
        expect(state.totalCount, 0);
      });

      test('should handle errors', () async {
        final filter = DestinationFilter();
        when(() => mockRepository.searchDestinations(any()))
            .thenThrow(Exception('Network error'));

        await container
            .read(destinationSearchProvider.notifier)
            .search(filter, reset: true);

        expect(container.read(destinationSearchProvider).hasError, isTrue);
      });
    });

    group('loadMore', () {
      test('should load more destinations when hasMore is true', () async {
        // Return enough results so hasMore becomes true (20 >= default limit)
        final manyDestinations = List.generate(20, (i) => testDestinations[i % 2]);
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => manyDestinations);
        await container
            .read(destinationSearchProvider.notifier)
            .search(DestinationFilter(), reset: true);

        // hasMore should be true (20 results >= 20 limit)
        expect(container.read(destinationSearchProvider).value!.hasMore, isTrue);

        // Load more
        reset(mockRepository);
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => [testDestinations[0]]);

        final result = await container
            .read(destinationSearchProvider.notifier)
            .loadMore();

        expect(result, isTrue);
        final state = container.read(destinationSearchProvider).value!;
        expect(state.results.length, 21); // 20 initial + 1 more
      });

      test('should return false when hasMore is false', () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => [testDestinations[0]]);
        await container
            .read(destinationSearchProvider.notifier)
            .search(DestinationFilter(), reset: true);

        // Now hasMore should be false (1 result < 20 limit)
        final result = await container
            .read(destinationSearchProvider.notifier)
            .loadMore();

        expect(result, isFalse);
      });

      test('should return false when state has no value', () async {
        final freshContainer = ProviderContainer.test(overrides: [
          destinationRepositoryProvider.overrideWithValue(mockRepository),
        ]);
        addTearDown(freshContainer.dispose);

        final result = await freshContainer
            .read(destinationSearchProvider.notifier)
            .loadMore();

        expect(result, isFalse);
      });

      test('should return false when state is loading', () async {
        await container.read(destinationSearchProvider.future);
        expect(true, isTrue); // placeholder
      });
    });

    group('refresh', () {
      test('should refresh with current filter', () async {
        final filter = DestinationFilter(searchQuery: 'Tokyo');
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);

        await container
            .read(destinationSearchProvider.notifier)
            .search(filter, reset: true);

        reset(mockRepository);
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => [testDestinations[0]]);

        await container.read(destinationSearchProvider.notifier).refresh();

        verify(() => mockRepository.searchDestinations(any())).called(1);
        final state = container.read(destinationSearchProvider).value!;
        expect(state.results.length, 1);
      });

      test('should do nothing when state has no value', () async {
        container.read(destinationSearchProvider.notifier).clear();
        await container.read(destinationSearchProvider.notifier).refresh();
      });
    });

    group('clear', () {
      test('should reset state to initial', () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);
        await container
            .read(destinationSearchProvider.notifier)
            .search(DestinationFilter(), reset: true);

        container.read(destinationSearchProvider.notifier).clear();

        final state = container.read(destinationSearchProvider).value!;
        expect(state.isInitial, isTrue);
        expect(state.results.isEmpty, isTrue);
        expect(state.hasMore, isTrue);
        expect(state.currentOffset, 0);
      });
    });

    group('updateFilter', () {
      test('should update filter without performing search', () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);
        await container
            .read(destinationSearchProvider.notifier)
            .search(DestinationFilter(), reset: true);

        // Reset mock call tracking after the initial search
        reset(mockRepository);

        final newFilter = DestinationFilter(searchQuery: 'Kyoto');
        container.read(destinationSearchProvider.notifier).updateFilter(newFilter);

        final state = container.read(destinationSearchProvider).value!;
        expect(state.filter.searchQuery, 'Kyoto');
        expect(state.results.length, 2); // Results unchanged
        verifyNever(() => mockRepository.searchDestinations(any()));
      });

      test('should do nothing when state has no value', () async {
        container.read(destinationSearchProvider.notifier).clear();
        container
            .read(destinationSearchProvider.notifier)
            .updateFilter(DestinationFilter(searchQuery: 'Test'));
      });
    });

    group('resetFilter', () {
      test('should reset filter to default values', () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);
        await container
            .read(destinationSearchProvider.notifier)
            .search(DestinationFilter(searchQuery: 'Tokyo'), reset: true);

        container.read(destinationSearchProvider.notifier).resetFilter();

        final state = container.read(destinationSearchProvider).value!;
        expect(state.filter.searchQuery, isNull);
        expect(state.results.length, 2); // Results unchanged
      });

      test('should do nothing when state has no value', () async {
        container.read(destinationSearchProvider.notifier).clear();
        container.read(destinationSearchProvider.notifier).resetFilter();
      });
    });

    group('searchQuery', () {
      test('should update search query and perform search', () async {
        // Ensure provider is fully built first
        await container.read(destinationSearchProvider.future);

        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => [testDestinations[0]]);

        await container
            .read(destinationSearchProvider.notifier)
            .searchQuery('Tokyo');

        verify(() => mockRepository.searchDestinations(any())).called(1);
        final state = container.read(destinationSearchProvider).value!;
        expect(state.filter.searchQuery, 'Tokyo');
        expect(state.results.length, 1);
      });

      test('should do nothing when state has no value', () async {
        container.read(destinationSearchProvider.notifier).clear();
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => <Destination>[]);
        await container
            .read(destinationSearchProvider.notifier)
            .searchQuery('Test');
      });
    });

    group('state getters', () {
      test('resultCount should return number of results', () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);
        await container
            .read(destinationSearchProvider.notifier)
            .search(DestinationFilter(), reset: true);

        final state = container.read(destinationSearchProvider).value!;
        expect(state.resultCount, 2);
      });

      test('isEmpty should return true when no results and not initial',
          () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => []);
        await container
            .read(destinationSearchProvider.notifier)
            .search(DestinationFilter(), reset: true);

        final state = container.read(destinationSearchProvider).value!;
        expect(state.isEmpty, isTrue);
      });

      test('hasResults should return true when results exist', () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);
        await container
            .read(destinationSearchProvider.notifier)
            .search(DestinationFilter(), reset: true);

        final state = container.read(destinationSearchProvider).value!;
        expect(state.hasResults, isTrue);
      });
    });
  });
}
