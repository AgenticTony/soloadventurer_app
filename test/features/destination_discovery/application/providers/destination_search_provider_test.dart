import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/destination_search_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart' hide BudgetLevel, ActivityLevel;
import 'package:soloadventurer/features/destination_discovery/domain/repositories/destination_repository.dart';

// Mock classes
class MockDestinationRepository extends Mock implements DestinationRepository {}

void main() {
  late MockDestinationRepository mockRepository;
  late DestinationSearchNotifier notifier;

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
  ];

  setUp(() {
    mockRepository = MockDestinationRepository();
    notifier = DestinationSearchNotifier(mockRepository);
  });

  group('DestinationSearchNotifier', () {
    group('initial state', () {
      test('should start with initial state', () {
        expect(notifier.state.value, isNotNull);
        expect(notifier.state.value!.isInitial, isTrue);
        expect(notifier.state.value!.results.isEmpty, isTrue);
        expect(notifier.state.value!.hasMore, isTrue);
        expect(notifier.state.value!.currentOffset, 0);
      });
    });

    group('search', () {
      test('should load destinations successfully with reset=true', () async {
        const filter = DestinationFilter(searchQuery: 'Tokyo');
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);

        await notifier.search(filter, reset: true);

        verify(() => mockRepository.searchDestinations(any())).called(1);
        expect(notifier.state.value, isNotNull);
        expect(notifier.state.value!.results.length, 2);
        expect(notifier.state.value!.results[0].name, 'Tokyo');
        expect(notifier.state.value!.hasMore, isTrue);
        expect(notifier.state.value!.currentOffset, 2);
        expect(notifier.state.value!.totalCount, 2);
      });

      test('should load destinations successfully with reset=false', () async {
        const filter = DestinationFilter(
          searchQuery: 'Tokyo',
          offset: 20,
          limit: 20,
        );
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);

        await notifier.search(filter, reset: false);

        expect(notifier.state.value!.results.length, 2);
        expect(notifier.state.value!.currentOffset, 22); // 20 + 2
      });

      test('should set hasMore to false when results less than limit',
          () async {
        const filter = DestinationFilter(
          searchQuery: 'Tokyo',
          limit: 20,
        );
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => [testDestinations[0]]);

        await notifier.search(filter, reset: true);

        expect(notifier.state.value!.hasMore, isFalse);
      });

      test('should handle empty results', () async {
        const filter = DestinationFilter(searchQuery: 'Unknown');
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => []);

        await notifier.search(filter, reset: true);

        expect(notifier.state.value!.results.isEmpty, isTrue);
        expect(notifier.state.value!.totalCount, 0);
      });

      test('should handle errors', () async {
        const filter = DestinationFilter();
        when(() => mockRepository.searchDestinations(any()))
            .thenThrow(Exception('Network error'));

        await notifier.search(filter, reset: true);

        expect(notifier.state.hasValue, isFalse);
      });
    });

    group('loadMore', () {
      test('should load more destinations when hasMore is true', () async {
        // Setup initial state
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);
        await notifier.search(const DestinationFilter(), reset: true);

        // Load more
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => [testDestinations[0]]);

        final result = await notifier.loadMore();

        expect(result, isTrue);
        expect(notifier.state.value!.results.length, 3); // 2 initial + 1 more
        expect(notifier.state.value!.currentOffset, 21); // 0 + 20 + 1
      });

      test('should return false when hasMore is false', () async {
        // Setup state with hasMore = false
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => []);
        await notifier.search(const DestinationFilter(), reset: true);

        final result = await notifier.loadMore();

        expect(result, isFalse);
        verifyNever(() => mockRepository.searchDestinations(any()));
      });

      test('should return false when state has no value', () async {
        // Reset to initial state which has no value
        notifier = DestinationSearchNotifier(mockRepository);

        final result = await notifier.loadMore();

        expect(result, isFalse);
      });

      test('should return false when state is loading', () async {
        // Setup loading state
        notifier.state = const AsyncValue.loading();

        final result = await notifier.loadMore();

        expect(result, isFalse);
      });

      test('should revert to previous state on error', () async {
        // Setup initial state
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);
        await notifier.search(const DestinationFilter(), reset: true);

        // Mock error for loadMore
        when(() => mockRepository.searchDestinations(any()))
            .thenThrow(Exception('Network error'));

        expect(() async => await notifier.loadMore(), throwsException);
        expect(notifier.state.hasValue, isFalse);
      });
    });

    group('refresh', () {
      test('should refresh with current filter', () async {
        const filter = DestinationFilter(searchQuery: 'Tokyo');
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);

        await notifier.search(filter, reset: true);

        // Clear the mock to verify it's called again
        reset(mockRepository);
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => [testDestinations[0]]);

        await notifier.refresh();

        verify(() => mockRepository.searchDestinations(any())).called(1);
        expect(notifier.state.value!.results.length, 1);
      });

      test('should do nothing when state has no value', () async {
        notifier.clear();

        await notifier.refresh();

        verifyNever(() => mockRepository.searchDestinations(any()));
      });
    });

    group('clear', () {
      test('should reset state to initial', () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);
        await notifier.search(const DestinationFilter(), reset: true);

        notifier.clear();

        expect(notifier.state.value!.isInitial, isTrue);
        expect(notifier.state.value!.results.isEmpty, isTrue);
        expect(notifier.state.value!.hasMore, isTrue);
        expect(notifier.state.value!.currentOffset, 0);
      });
    });

    group('updateFilter', () {
      test('should update filter without performing search', () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);
        await notifier.search(const DestinationFilter(), reset: true);

        const newFilter = DestinationFilter(searchQuery: 'Kyoto');
        notifier.updateFilter(newFilter);

        expect(notifier.state.value!.filter.searchQuery, 'Kyoto');
        expect(notifier.state.value!.results.length, 2); // Results unchanged
        verifyNever(() => mockRepository.searchDestinations(any()));
      });

      test('should do nothing when state has no value', () async {
        notifier.clear();

        notifier.updateFilter(const DestinationFilter(searchQuery: 'Test'));

        // Should not throw
      });
    });

    group('resetFilter', () {
      test('should reset filter to default values', () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);
        await notifier.search(
          const DestinationFilter(searchQuery: 'Tokyo'),
          reset: true,
        );

        notifier.resetFilter();

        expect(notifier.state.value!.filter.searchQuery, isNull);
        expect(notifier.state.value!.results.length, 2); // Results unchanged
      });

      test('should do nothing when state has no value', () async {
        notifier.clear();

        notifier.resetFilter();

        // Should not throw
      });
    });

    group('searchQuery', () {
      test('should update search query and perform search', () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => [testDestinations[0]]);

        await notifier.searchQuery('Tokyo');

        verify(() => mockRepository.searchDestinations(any())).called(1);
        expect(notifier.state.value!.filter.searchQuery, 'Tokyo');
        expect(notifier.state.value!.results.length, 1);
      });

      test('should do nothing when state has no value', () async {
        notifier.clear();

        await notifier.searchQuery('Test');

        verifyNever(() => mockRepository.searchDestinations(any()));
      });
    });

    group('state getters', () {
      test('resultCount should return number of results', () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);
        await notifier.search(const DestinationFilter(), reset: true);

        expect(notifier.state.value!.resultCount, 2);
      });

      test('isEmpty should return true when no results and not initial',
          () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => []);
        await notifier.search(const DestinationFilter(), reset: true);

        expect(notifier.state.value!.isEmpty, isTrue);
      });

      test('hasResults should return true when results exist', () async {
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => testDestinations);
        await notifier.search(const DestinationFilter(), reset: true);

        expect(notifier.state.value!.hasResults, isTrue);
      });
    });
  });
}
