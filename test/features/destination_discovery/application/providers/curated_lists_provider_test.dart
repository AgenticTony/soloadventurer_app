import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/curated_lists_provider.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/destination_repository_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/curated_list.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/repositories/destination_repository.dart';

class MockDestinationRepository extends Mock implements DestinationRepository {}

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

  final testCuratedLists = [
    CuratedList(
      id: 'list1',
      name: 'Popular Solo Destinations',
      description: 'Top destinations for solo travelers',
      type: CuratedListType.popularSolo,
      destinations: testDestinations,
      coverImageUrl: 'https://example.com/cover.jpg',
      curatorName: 'Solo Traveler Co.',
      isFeatured: true,
      viewCount: 10000,
      saveCount: 5000,
      averageSafetyScore: 8.75,
      averageSoloSuitabilityScore: 8.25,
      tags: ['urban', 'cultural', 'popular'],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    CuratedList(
      id: 'list2',
      name: 'Hidden Gems of Japan',
      description: 'Off the beaten path destinations',
      type: CuratedListType.hiddenGems,
      destinations: [testDestinations[0]],
      coverImageUrl: 'https://example.com/hidden.jpg',
      curatorName: 'Local Experts',
      isFeatured: true,
      viewCount: 5000,
      saveCount: 2500,
      averageSafetyScore: 8.5,
      averageSoloSuitabilityScore: 8.0,
      tags: ['hidden', 'nature'],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    CuratedList(
      id: 'list3',
      name: 'Budget-Friendly Adventures',
      description: 'Travel on a budget',
      type: CuratedListType.budgetFriendly,
      destinations: testDestinations,
      coverImageUrl: 'https://example.com/budget.jpg',
      curatorName: 'Budget Traveler',
      isFeatured: false,
      viewCount: 3000,
      saveCount: 1500,
      averageSafetyScore: 8.75,
      averageSoloSuitabilityScore: 8.25,
      tags: ['budget', 'adventure'],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  setUp(() {
    mockRepository = MockDestinationRepository();
    when(() => mockRepository.getCuratedLists())
        .thenAnswer((_) async => testCuratedLists);
    container = ProviderContainer.test(overrides: [
      destinationRepositoryProvider.overrideWithValue(mockRepository),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  group('CuratedLists', () {
    group('initial state', () {
      test('should auto-load curated lists on build', () async {
        // Watch the provider to trigger build
        container.listen(curatedListsProvider, (_, __) {});

        // Wait for async build to complete
        await container.read(curatedListsProvider.future);

        verify(() => mockRepository.getCuratedLists()).called(1);
        final state = container.read(curatedListsProvider).value!;
        expect(state.curatedLists.length, 3);
      });
    });

    group('loadCuratedList', () {
      test('should load a specific curated list', () async {
        await container.read(curatedListsProvider.future);

        final specificList = CuratedList(
          id: 'list4',
          name: 'Updated List',
          description: 'Updated description',
          type: CuratedListType.cultural,
          destinations: testDestinations,
          curatorName: 'Editor',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => specificList);

        await container
            .read(curatedListsProvider.notifier)
            .loadCuratedList('list1');

        final state = container.read(curatedListsProvider).value!;
        expect(state.selectedList?.id, 'list4');
        expect(state.selectedList?.name, 'Updated List');
      });

      test('should update list in curated lists array if it exists', () async {
        await container.read(curatedListsProvider.future);

        final updatedList = testCuratedLists[0].copyWith(
          name: 'Updated Popular Solo Destinations',
        );

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => updatedList);

        await container
            .read(curatedListsProvider.notifier)
            .loadCuratedList('list1');

        final state = container.read(curatedListsProvider).value!;
        final listInArray =
            state.curatedLists.firstWhere((list) => list.id == 'list1');
        expect(listInArray.name, 'Updated Popular Solo Destinations');
      });

      test('should add list to array if it does not exist', () async {
        await container.read(curatedListsProvider.future);

        final newList = CuratedList(
          id: 'list99',
          name: 'New List',
          description: 'New',
          type: CuratedListType.custom,
          destinations: [],
          curatorName: 'User',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        when(() => mockRepository.getCuratedListById('list99'))
            .thenAnswer((_) async => newList);

        await container
            .read(curatedListsProvider.notifier)
            .loadCuratedList('list99');

        final state = container.read(curatedListsProvider).value!;
        expect(state.curatedLists.any((l) => l.id == 'list99'), isTrue);
        expect(state.selectedList?.id, 'list99');
      });

      test('should handle errors', () async {
        await container.read(curatedListsProvider.future);

        when(() => mockRepository.getCuratedListById(any()))
            .thenThrow(Exception('Not found'));

        await container
            .read(curatedListsProvider.notifier)
            .loadCuratedList('list1');

        expect(container.read(curatedListsProvider).hasError, isTrue);
      });
    });

    group('refresh', () {
      test('should refresh all curated lists', () async {
        await container.read(curatedListsProvider.future);

        reset(mockRepository);
        final refreshedLists = [testCuratedLists[0], testCuratedLists[1]];
        when(() => mockRepository.getCuratedLists())
            .thenAnswer((_) async => refreshedLists);

        await container.read(curatedListsProvider.notifier).refresh();

        final state = container.read(curatedListsProvider).value!;
        expect(state.curatedListCount, 2);
      });

      test('should preserve selected list during refresh', () async {
        await container.read(curatedListsProvider.future);

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await container
            .read(curatedListsProvider.notifier)
            .loadCuratedList('list1');

        reset(mockRepository);
        when(() => mockRepository.getCuratedLists())
            .thenAnswer((_) async => [testCuratedLists[1]]);

        await container.read(curatedListsProvider.notifier).refresh();

        final state = container.read(curatedListsProvider).value!;
        expect(state.selectedList?.id, 'list1');
      });

      test('should handle errors during refresh', () async {
        await container.read(curatedListsProvider.future);

        reset(mockRepository);
        when(() => mockRepository.getCuratedLists())
            .thenThrow(Exception('Network error'));

        await container.read(curatedListsProvider.notifier).refresh();

        expect(container.read(curatedListsProvider).hasError, isTrue);
      });
    });

    group('refreshSelectedList', () {
      test('should refresh selected list', () async {
        await container.read(curatedListsProvider.future);

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await container
            .read(curatedListsProvider.notifier)
            .loadCuratedList('list1');

        final updatedList = testCuratedLists[0].copyWith(
          name: 'Refreshed List Name',
        );

        reset(mockRepository);
        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => updatedList);

        final result = await container
            .read(curatedListsProvider.notifier)
            .refreshSelectedList();

        expect(result, isTrue);
        final state = container.read(curatedListsProvider).value!;
        expect(state.selectedList?.name, 'Refreshed List Name');
      });

      test('should update list in curated lists array', () async {
        await container.read(curatedListsProvider.future);

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await container
            .read(curatedListsProvider.notifier)
            .loadCuratedList('list1');

        final updatedList = testCuratedLists[0].copyWith(viewCount: 15000);

        reset(mockRepository);
        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => updatedList);

        await container
            .read(curatedListsProvider.notifier)
            .refreshSelectedList();

        final state = container.read(curatedListsProvider).value!;
        final listInArray =
            state.curatedLists.firstWhere((list) => list.id == 'list1');
        expect(listInArray.viewCount, 15000);
      });

      test('should return false when no list is selected', () async {
        // Create fresh container without loading any list
        final freshContainer = ProviderContainer.test(overrides: [
          destinationRepositoryProvider.overrideWithValue(mockRepository),
        ]);
        addTearDown(freshContainer.dispose);

        // Clear to get to initial state where no list is selected
        when(() => mockRepository.getCuratedLists())
            .thenAnswer((_) async => <CuratedList>[]);
        await freshContainer.read(curatedListsProvider.future);

        final result = await freshContainer
            .read(curatedListsProvider.notifier)
            .refreshSelectedList();

        expect(result, isFalse);
        verifyNever(() => mockRepository.getCuratedListById(any()));
      });

      test('should handle errors', () async {
        await container.read(curatedListsProvider.future);

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await container
            .read(curatedListsProvider.notifier)
            .loadCuratedList('list1');

        reset(mockRepository);
        when(() => mockRepository.getCuratedListById('list1'))
            .thenThrow(Exception('Network error'));

        final result = await container
            .read(curatedListsProvider.notifier)
            .refreshSelectedList();

        // refreshSelectedList catches errors via AsyncValue.guard
        expect(result, isTrue);
        expect(container.read(curatedListsProvider).hasError, isTrue);
      });
    });

    group('clear', () {
      test('should reset state to initial', () async {
        await container.read(curatedListsProvider.future);

        container.read(curatedListsProvider.notifier).clear();

        final state = container.read(curatedListsProvider).value!;
        expect(state.curatedLists.isEmpty, isTrue);
        expect(state.selectedList, isNull);
      });
    });

    group('clearSelectedList', () {
      test('should clear selected list while keeping curated lists', () async {
        await container.read(curatedListsProvider.future);

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await container
            .read(curatedListsProvider.notifier)
            .loadCuratedList('list1');

        container.read(curatedListsProvider.notifier).clearSelectedList();

        final state = container.read(curatedListsProvider).value!;
        expect(state.selectedList, isNull);
        expect(state.curatedListCount, 3);
      });
    });

    group('getters', () {
      test('featuredLists should return featured lists', () async {
        await container.read(curatedListsProvider.future);

        final featured =
            container.read(curatedListsProvider.notifier).featuredLists;

        expect(featured.length, 2); // list1 and list2 are featured
        expect(featured.every((list) => list.isFeatured), isTrue);
      });

      test('popularLists should return popular lists', () async {
        await container.read(curatedListsProvider.future);

        final popular =
            container.read(curatedListsProvider.notifier).popularLists;

        expect(popular.length, 3); // All lists are popular (featured or high counts)
      });

      test('getListsByType should filter by type', () async {
        await container.read(curatedListsProvider.future);

        final hiddenGems = container
            .read(curatedListsProvider.notifier)
            .getListsByType(CuratedListType.hiddenGems);

        expect(hiddenGems.length, 1);
        expect(hiddenGems[0].type, CuratedListType.hiddenGems);
      });

      test('hiddenGemsLists should return hidden gems lists', () async {
        await container.read(curatedListsProvider.future);

        final hiddenGems =
            container.read(curatedListsProvider.notifier).hiddenGemsLists;

        expect(hiddenGems.length, 1);
        expect(hiddenGems[0].isHiddenGemsList, isTrue);
      });

      test('budgetFriendlyLists should return budget-friendly lists', () async {
        await container.read(curatedListsProvider.future);

        final budget =
            container.read(curatedListsProvider.notifier).budgetFriendlyLists;

        expect(budget.length, 1);
        expect(budget[0].isBudgetFriendly, isTrue);
      });

      test('popularSoloLists should return popular solo lists', () async {
        await container.read(curatedListsProvider.future);

        final popularSolo =
            container.read(curatedListsProvider.notifier).popularSoloLists;

        expect(popularSolo.length, 1);
        expect(popularSolo[0].isPopular, isTrue);
      });

      test('totalCount should return list count', () async {
        await container.read(curatedListsProvider.future);

        expect(container.read(curatedListsProvider.notifier).totalCount, 3);
      });

      test('hasCuratedLists should return true when lists exist', () async {
        await container.read(curatedListsProvider.future);

        expect(
            container.read(curatedListsProvider.notifier).hasCuratedLists,
            isTrue);
      });

      test('hasCuratedLists should return false when no lists', () {
        // Clear to initial state
        container.read(curatedListsProvider.notifier).clear();

        expect(
            container.read(curatedListsProvider.notifier).hasCuratedLists,
            isFalse);
      });

      test('hasSelectedList should return true when list is selected',
          () async {
        await container.read(curatedListsProvider.future);

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await container
            .read(curatedListsProvider.notifier)
            .loadCuratedList('list1');

        expect(container.read(curatedListsProvider.notifier).hasSelectedList,
            isTrue);
      });

      test('hasSelectedList should return false when no list selected', () {
        container.read(curatedListsProvider.notifier).clear();

        expect(container.read(curatedListsProvider.notifier).hasSelectedList,
            isFalse);
      });

      test('selectedList should return selected list', () async {
        await container.read(curatedListsProvider.future);

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await container
            .read(curatedListsProvider.notifier)
            .loadCuratedList('list1');

        expect(
            container.read(curatedListsProvider.notifier).selectedList?.id,
            'list1');
      });

      test('getters should return empty/null when state has no value',
          () async {
        container.read(curatedListsProvider.notifier).clear();

        final notifier = container.read(curatedListsProvider.notifier);
        expect(notifier.featuredLists.isEmpty, isTrue);
        expect(notifier.popularLists.isEmpty, isTrue);
        expect(
            notifier.getListsByType(CuratedListType.hiddenGems).isEmpty,
            isTrue);
        expect(notifier.hiddenGemsLists.isEmpty, isTrue);
        expect(notifier.budgetFriendlyLists.isEmpty, isTrue);
        expect(notifier.popularSoloLists.isEmpty, isTrue);
        expect(notifier.totalCount, 0);
        expect(notifier.hasCuratedLists, isFalse);
        expect(notifier.hasSelectedList, isFalse);
        expect(notifier.selectedList, isNull);
      });
    });
  });
}
