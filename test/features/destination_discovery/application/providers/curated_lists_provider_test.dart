import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/curated_lists_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/curated_list.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/repositories/destination_repository.dart';

// Mock classes
class MockDestinationRepository extends Mock implements DestinationRepository {}

void main() {
  late MockDestinationRepository mockRepository;
  late CuratedListsNotifier notifier;

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

  final testCuratedLists = [
    CuratedList(
      id: 'list1',
      name: 'Popular Solo Destinations',
      description: 'Top destinations for solo travelers',
      type: CuratedListType.popularSolo,
      destinations: testDestinations,
      coverImageUrl: 'https://example.com/cover.jpg',
      curator: Curator(name: 'Solo Traveler Co.', avatarUrl: null),
      metadata: CuratedListMetadata(
        viewCount: 10000,
        saveCount: 5000,
        isFeatured: true,
      ),
      averageSafetyScore: 8.75,
      averageSoloSuitabilityScore: 8.25,
      tags: ['urban', 'cultural', 'popular'],
    ),
    CuratedList(
      id: 'list2',
      name: 'Hidden Gems of Japan',
      description: 'Off the beaten path destinations',
      type: CuratedListType.hiddenGems,
      destinations: [testDestinations[0]],
      coverImageUrl: 'https://example.com/hidden.jpg',
      curator: Curator(name: 'Local Experts', avatarUrl: null),
      metadata: CuratedListMetadata(
        viewCount: 5000,
        saveCount: 2500,
        isFeatured: true,
      ),
      averageSafetyScore: 8.5,
      averageSoloSuitabilityScore: 8.0,
      tags: ['hidden', 'nature'],
    ),
    CuratedList(
      id: 'list3',
      name: 'Budget-Friendly Adventures',
      description: 'Travel on a budget',
      type: CuratedListType.budgetFriendly,
      destinations: testDestinations,
      coverImageUrl: 'https://example.com/budget.jpg',
      curator: Curator(name: 'Budget Traveler', avatarUrl: null),
      metadata: CuratedListMetadata(
        viewCount: 3000,
        saveCount: 1500,
        isFeatured: false,
      ),
      averageSafetyScore: 8.75,
      averageSoloSuitabilityScore: 8.25,
      tags: ['budget', 'adventure'],
    ),
  ];

  setUp(() {
    mockRepository = MockDestinationRepository();
    // Setup mock to return test curated lists
    when(() => mockRepository.getCuratedLists())
        .thenAnswer((_) async => testCuratedLists);
    notifier = CuratedListsNotifier(mockRepository);

    // Wait for auto-load
    Future.delayed(const Duration(milliseconds: 100));
  });

  group('CuratedListsNotifier', () {
    group('initial state', () {
      test('should start with initial state', () {
        notifier.clear();

        expect(notifier.state.value, isNotNull);
        expect(notifier.state.value!.curatedLists.isEmpty, isTrue);
        expect(notifier.state.value!.selectedList, isNull);
      });

      test('should auto-load curated lists on creation', () async {
        // Create a new notifier to verify auto-load
        final newNotifier = CuratedListsNotifier(mockRepository);

        // Wait for auto-load
        await Future.delayed(const Duration(milliseconds: 100));

        verify(() => mockRepository.getCuratedLists()).called(1);
      });
    });

    group('loadCuratedLists', () {
      test('should load all curated lists successfully', () async {
        notifier.clear(); // Clear auto-loaded state

        await notifier.loadCuratedLists();

        verify(() => mockRepository.getCuratedLists()).called(1);
        expect(notifier.state.value, isNotNull);
        expect(notifier.state.value!.curatedListCount, 3);
      });

      test('should handle errors', () async {
        notifier.clear();
        when(() => mockRepository.getCuratedLists())
            .thenThrow(Exception('Network error'));

        await notifier.loadCuratedLists();

        expect(notifier.state.hasValue, isFalse);
      });
    });

    group('loadCuratedList', () {
      test('should load a specific curated list', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        final specificList = CuratedList(
          id: 'list4',
          name: 'Updated List',
          description: 'Updated description',
          type: CuratedListType.cultural,
          destinations: testDestinations,
          curator: Curator(name: 'Editor', avatarUrl: null),
        );

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => specificList);

        await notifier.loadCuratedList('list1');

        expect(notifier.state.value!.selectedList?.id, 'list4');
        expect(notifier.state.value!.selectedList?.name, 'Updated List');
      });

      test('should update list in curated lists array if it exists', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        final updatedList = testCuratedLists[0].copyWith(
          name: 'Updated Popular Solo Destinations',
        );

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => updatedList);

        await notifier.loadCuratedList('list1');

        // Should be updated in the array
        final listInArray = notifier.state.value!.curatedLists
            .firstWhere((list) => list.id == 'list1');
        expect(listInArray.name, 'Updated Popular Solo Destinations');
      });

      test('should add list to array if it does not exist', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        final newList = CuratedList(
          id: 'list99',
          name: 'New List',
          description: 'New',
          type: CuratedListType.custom,
          destinations: [],
          curator: Curator(name: 'User', avatarUrl: null),
        );

        when(() => mockRepository.getCuratedListById('list99'))
            .thenAnswer((_) async => newList);

        await notifier.loadCuratedList('list99');

        expect(notifier.state.value!.curatedLists.any((l) => l.id == 'list99'),
            isTrue);
        expect(notifier.state.value!.selectedList?.id, 'list99');
      });

      test('should handle errors', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        when(() => mockRepository.getCuratedListById(any()))
            .thenThrow(Exception('Not found'));

        expect(() async => await notifier.loadCuratedList('list1'),
            throwsException);
      });
    });

    group('refresh', () {
      test('should refresh all curated lists', () async {
        // Wait for initial load
        await Future.delayed(const Duration(milliseconds: 100));

        // Reset mock
        reset(mockRepository);
        final refreshedLists = [testCuratedLists[0], testCuratedLists[1]];
        when(() => mockRepository.getCuratedLists())
            .thenAnswer((_) async => refreshedLists);

        await notifier.refresh();

        expect(notifier.state.value!.curatedListCount, 2);
      });

      test('should preserve selected list during refresh', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await notifier.loadCuratedList('list1');

        // Refresh
        reset(mockRepository);
        final refreshedLists = [testCuratedLists[1]];
        when(() => mockRepository.getCuratedLists())
            .thenAnswer((_) async => refreshedLists);

        await notifier.refresh();

        expect(notifier.state.value!.selectedList?.id, 'list1');
      });

      test('should handle errors during refresh', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        reset(mockRepository);
        when(() => mockRepository.getCuratedLists())
            .thenThrow(Exception('Network error'));

        await notifier.refresh();

        expect(notifier.state.hasValue, isFalse);
      });
    });

    group('refreshSelectedList', () {
      test('should refresh selected list', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await notifier.loadCuratedList('list1');

        final updatedList = testCuratedLists[0].copyWith(
          name: 'Refreshed List Name',
        );

        reset(mockRepository);
        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => updatedList);

        final result = await notifier.refreshSelectedList();

        expect(result, isTrue);
        expect(notifier.state.value!.selectedList?.name, 'Refreshed List Name');
      });

      test('should update list in curated lists array', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await notifier.loadCuratedList('list1');

        final updatedList = testCuratedLists[0].copyWith(
          viewCount: 15000,
        );

        reset(mockRepository);
        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => updatedList);

        await notifier.refreshSelectedList();

        final listInArray = notifier.state.value!.curatedLists
            .firstWhere((list) => list.id == 'list1');
        expect(listInArray.viewCount, 15000);
      });

      test('should return false when no list is selected', () async {
        notifier.clear();

        final result = await notifier.refreshSelectedList();

        expect(result, isFalse);
        verifyNever(() => mockRepository.getCuratedListById(any()));
      });

      test('should handle errors', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await notifier.loadCuratedList('list1');

        reset(mockRepository);
        when(() => mockRepository.getCuratedListById('list1'))
            .thenThrow(Exception('Network error'));

        expect(
            () async => await notifier.refreshSelectedList(), throwsException);
      });
    });

    group('clear', () {
      test('should reset state to initial', () async {
        await notifier.loadCuratedLists();

        notifier.clear();

        expect(notifier.state.value!.curatedLists.isEmpty, isTrue);
        expect(notifier.state.value!.selectedList, isNull);
      });
    });

    group('clearSelectedList', () {
      test('should clear selected list while keeping curated lists', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await notifier.loadCuratedList('list1');

        notifier.clearSelectedList();

        expect(notifier.state.value!.selectedList, isNull);
        expect(notifier.state.value!.curatedListCount, 3);
      });

      test('should do nothing when state has no value', () async {
        notifier.clear();

        notifier.clearSelectedList();

        // Should not throw
      });
    });

    group('getters', () {
      test('featuredLists should return featured lists', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        final featured = notifier.featuredLists;

        expect(featured.length, 2); // list1 and list2 are featured
        expect(featured.every((list) => list.isFeatured), isTrue);
      });

      test('popularLists should return popular lists', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        final popular = notifier.popularLists;

        expect(popular.length, 2); // list1 and list2 have high save counts
      });

      test('getListsByType should filter by type', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        final hiddenGems = notifier.getListsByType(CuratedListType.hiddenGems);

        expect(hiddenGems.length, 1);
        expect(hiddenGems[0].type, CuratedListType.hiddenGems);
      });

      test('hiddenGemsLists should return hidden gems lists', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        final hiddenGems = notifier.hiddenGemsLists;

        expect(hiddenGems.length, 1);
        expect(hiddenGems[0].isHiddenGemsList, isTrue);
      });

      test('budgetFriendlyLists should return budget-friendly lists', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        final budget = notifier.budgetFriendlyLists;

        expect(budget.length, 1);
        expect(budget[0].isBudgetFriendly, isTrue);
      });

      test('popularSoloLists should return popular solo lists', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        final popularSolo = notifier.popularSoloLists;

        expect(popularSolo.length, 1);
        expect(popularSolo[0].isPopular, isTrue);
      });

      test('totalCount should return list count', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        expect(notifier.totalCount, 3);
      });

      test('hasCuratedLists should return true when lists exist', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        expect(notifier.hasCuratedLists, isTrue);
      });

      test('hasCuratedLists should return false when no lists', () async {
        notifier.clear();

        expect(notifier.hasCuratedLists, isFalse);
      });

      test('hasSelectedList should return true when list is selected',
          () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await notifier.loadCuratedList('list1');

        expect(notifier.hasSelectedList, isTrue);
      });

      test('hasSelectedList should return false when no list selected',
          () async {
        notifier.clear();

        expect(notifier.hasSelectedList, isFalse);
      });

      test('selectedList should return selected list', () async {
        notifier.clear();
        await notifier.loadCuratedLists();

        when(() => mockRepository.getCuratedListById('list1'))
            .thenAnswer((_) async => testCuratedLists[0]);
        await notifier.loadCuratedList('list1');

        expect(notifier.selectedList?.id, 'list1');
      });

      test('getters should return empty/null when state has no value',
          () async {
        notifier.clear();

        expect(notifier.featuredLists.isEmpty, isTrue);
        expect(notifier.popularLists.isEmpty, isTrue);
        expect(notifier.getListsByType(CuratedListType.hiddenGems).isEmpty,
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
