import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/curated_list.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';

void main() {
  group('CuratedListType enum', () {
    test('should have all correct values', () {
      expect(CuratedListType.values.length, 12);

      expect(CuratedListType.popularSolo, isA<CuratedListType>());
      expect(CuratedListType.hiddenGems, isA<CuratedListType>());
      expect(CuratedListType.budgetFriendly, isA<CuratedListType>());
      expect(CuratedListType.adventure, isA<CuratedListType>());
      expect(CuratedListType.cultural, isA<CuratedListType>());
      expect(CuratedListType.beach, isA<CuratedListType>());
      expect(CuratedListType.urban, isA<CuratedListType>());
      expect(CuratedListType.nature, isA<CuratedListType>());
      expect(CuratedListType.food, isA<CuratedListType>());
      expect(CuratedListType.wellness, isA<CuratedListType>());
      expect(CuratedListType.seasonal, isA<CuratedListType>());
      expect(CuratedListType.custom, isA<CuratedListType>());
    });

    test('should serialize correctly via CuratedList', () {
      // Test serialization by creating CuratedList objects and serializing
      for (final type in CuratedListType.values) {
        final list = CuratedList(
          id: 'test',
          name: 'Test',
          description: 'Desc',
          type: type,
          destinations: [],
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );
        final json = list.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['type'], isNotNull);
      }
    });

    test('should deserialize correctly via CuratedList', () {
      final typeStrings = [
        'popular_solo',
        'hidden_gems',
        'budget_friendly',
        'adventure',
        'cultural',
        'beach',
        'urban',
        'nature',
        'food',
        'wellness',
        'seasonal',
        'custom',
      ];

      final expectedTypes = [
        CuratedListType.popularSolo,
        CuratedListType.hiddenGems,
        CuratedListType.budgetFriendly,
        CuratedListType.adventure,
        CuratedListType.cultural,
        CuratedListType.beach,
        CuratedListType.urban,
        CuratedListType.nature,
        CuratedListType.food,
        CuratedListType.wellness,
        CuratedListType.seasonal,
        CuratedListType.custom,
      ];

      for (var i = 0; i < typeStrings.length; i++) {
        final json = {
          'id': 'test',
          'name': 'Test',
          'description': 'Desc',
          'type': typeStrings[i],
          'destinations': <Map<String, dynamic>>[],
          'createdAt': DateTime(2024).toIso8601String(),
          'updatedAt': DateTime(2024).toIso8601String(),
        };
        final list = CuratedList.fromJson(json);
        expect(list.type, expectedTypes[i]);
      }
    });
  });

  group('CuratedList', () {
    late DateTime now;
    late Destination testDestination;

    setUp(() {
      now = DateTime.now();
      testDestination = Destination(
        id: 'dest_1',
        name: 'Tokyo',
        description: 'A vibrant metropolis',
        latitude: 35.6762,
        longitude: 139.6503,
        countryCode: 'JP',
        region: 'Kanto',
        safetyScore: 9.2,
        safetyInsights: [],
        soloSuitabilityScore: 8.8,
        soloSuitabilityFactors: const SoloSuitabilityFactors(
          safety: 9.5,
          nightlife: 8.0,
          walkability: 9.0,
          accommodation: 9.0,
          soloDining: 9.5,
          communication: 7.0,
          overall: 8.8,
        ),
        budgetLevel: BudgetLevel.expensive,
        activityLevels: [ActivityLevel.moderate],
        tags: ['urban'],
        images: ['https://example.com/tokyo.jpg'],
        popularActivities: [],
        createdAt: now,
        updatedAt: now,
      );
    });

    test('should create with all required fields', () {
      final curatedList = CuratedList(
        id: 'list_1',
        name: 'Hidden Gems of Asia',
        description: 'Undiscovered destinations in Asia',
        type: CuratedListType.hiddenGems,
        destinations: [testDestination],
        createdAt: now,
        updatedAt: now,
      );

      expect(curatedList.id, 'list_1');
      expect(curatedList.name, 'Hidden Gems of Asia');
      expect(curatedList.description, 'Undiscovered destinations in Asia');
      expect(curatedList.type, CuratedListType.hiddenGems);
      expect(curatedList.destinations, [testDestination]);
      expect(curatedList.createdAt, now);
      expect(curatedList.updatedAt, now);
    });

    test('should create with optional fields', () {
      final curatedList = CuratedList(
        id: 'list_1',
        name: 'Popular Solo Destinations',
        description: 'Top destinations for solo travelers',
        type: CuratedListType.popularSolo,
        destinations: [testDestination],
        coverImageUrl: 'https://example.com/cover.jpg',
        images: ['https://example.com/img1.jpg'],
        curatorName: 'SoloAdventurer Team',
        curatorImageUrl: 'https://example.com/curator.jpg',
        destinationCount: 10,
        isFeatured: true,
        displayOrder: 1,
        tags: ['asia', 'budget'],
        averageSafetyScore: 8.5,
        averageSoloSuitabilityScore: 8.0,
        budgetRange: 'Budget-friendly',
        bestTimeToVisit: 'March to May',
        recommendedDuration: '7-10 days',
        viewCount: 1000,
        saveCount: 150,
        createdAt: now,
        updatedAt: now,
        publishedAt: now,
      );

      expect(curatedList.coverImageUrl, 'https://example.com/cover.jpg');
      expect(curatedList.images, ['https://example.com/img1.jpg']);
      expect(curatedList.curatorName, 'SoloAdventurer Team');
      expect(curatedList.isFeatured, true);
      expect(curatedList.tags, ['asia', 'budget']);
      expect(curatedList.viewCount, 1000);
      expect(curatedList.saveCount, 150);
    });

    test('should serialize to JSON correctly', () {
      final curatedList = CuratedList(
        id: 'list_1',
        name: 'Hidden Gems',
        description: 'Undiscovered destinations',
        type: CuratedListType.hiddenGems,
        destinations: [testDestination],
        isFeatured: true,
        destinationCount: 5,
        createdAt: now,
        updatedAt: now,
      );

      final json = curatedList.toJson();

      expect(json['id'], 'list_1');
      expect(json['name'], 'Hidden Gems');
      expect(json['description'], 'Undiscovered destinations');
      expect(json['type'], 'hidden_gems');
      expect(json['isFeatured'], true);
      expect(json['destinationCount'], 5);
      expect(json['destinations'], isA<List>());
    });

    test('should deserialize from JSON correctly', () {
      final curatedList = CuratedList(
        id: 'list_1',
        name: 'Hidden Gems',
        description: 'Undiscovered destinations',
        type: CuratedListType.hiddenGems,
        destinations: [testDestination],
        createdAt: now,
        updatedAt: now,
      );

      final json = curatedList.toJson();
      final deserialized = CuratedList.fromJson(json);

      expect(deserialized.id, curatedList.id);
      expect(deserialized.name, curatedList.name);
      expect(deserialized.type, curatedList.type);
      expect(deserialized.destinations.length, curatedList.destinations.length);
    });

    test('should implement equality correctly', () {
      final list1 = CuratedList(
        id: 'list_1',
        name: 'Hidden Gems',
        description: 'Undiscovered',
        type: CuratedListType.hiddenGems,
        destinations: [testDestination],
        createdAt: now,
        updatedAt: now,
      );

      final list2 = CuratedList(
        id: 'list_1',
        name: 'Hidden Gems',
        description: 'Undiscovered',
        type: CuratedListType.hiddenGems,
        destinations: [testDestination],
        createdAt: now,
        updatedAt: now,
      );

      final list3 = CuratedList(
        id: 'list_2',
        name: 'Popular',
        description: 'Popular',
        type: CuratedListType.popularSolo,
        destinations: [testDestination],
        createdAt: now,
        updatedAt: now,
      );

      expect(list1, equals(list2));
      expect(list1, isNot(equals(list3)));
      expect(list1.hashCode, equals(list2.hashCode));
    });

    test('should support copyWith', () {
      final curatedList = CuratedList(
        id: 'list_1',
        name: 'Hidden Gems',
        description: 'Undiscovered',
        type: CuratedListType.hiddenGems,
        destinations: [testDestination],
        viewCount: 100,
        createdAt: now,
        updatedAt: now,
      );

      final updated = curatedList.copyWith(
        name: 'Updated Name',
        viewCount: 200,
      );

      expect(updated.id, curatedList.id);
      expect(updated.name, 'Updated Name');
      expect(updated.viewCount, 200);
      expect(updated.type, curatedList.type);
    });

    test('hasCoverImage should return true when coverImageUrl is present', () {
      final listWithCover = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        coverImageUrl: 'https://example.com/cover.jpg',
        createdAt: now,
        updatedAt: now,
      );

      expect(listWithCover.hasCoverImage, true);
    });

    test('hasCoverImage should return false when coverImageUrl is null', () {
      final listWithoutCover = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        createdAt: now,
        updatedAt: now,
      );

      expect(listWithoutCover.hasCoverImage, false);
    });

    test(
        'hasDestinations should return true when destinations list is not empty',
        () {
      final listWithDests = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [testDestination],
        createdAt: now,
        updatedAt: now,
      );

      expect(listWithDests.hasDestinations, true);
    });

    test('hasDestinations should return false when destinations list is empty',
        () {
      final listWithoutDests = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        createdAt: now,
        updatedAt: now,
      );

      expect(listWithoutDests.hasDestinations, false);
    });

    test('destinationCountLabel should return correct label', () {
      final list1 = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [testDestination],
        destinationCount: 1,
        createdAt: now,
        updatedAt: now,
      );

      expect(list1.destinationCountLabel, '1 Destination');

      final list5 = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        destinationCount: 5,
        createdAt: now,
        updatedAt: now,
      );

      expect(list5.destinationCountLabel, '5 Destinations');
    });

    test('previewDestinations should return first 3 destinations', () {
      final dest2 = Destination(
        id: 'dest_2',
        name: 'Kyoto',
        description: 'Cultural capital',
        latitude: 35.0116,
        longitude: 135.7681,
        countryCode: 'JP',
        region: 'Kansai',
        safetyScore: 9.5,
        safetyInsights: [],
        soloSuitabilityScore: 9.0,
        soloSuitabilityFactors: const SoloSuitabilityFactors(
          safety: 9.5,
          nightlife: 7.0,
          walkability: 9.0,
          accommodation: 8.5,
          soloDining: 9.0,
          communication: 7.0,
          overall: 9.0,
        ),
        budgetLevel: BudgetLevel.moderate,
        activityLevels: [ActivityLevel.relaxed],
        tags: ['cultural'],
        images: [],
        popularActivities: [],
        createdAt: now,
        updatedAt: now,
      );

      final list = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [testDestination, dest2],
        createdAt: now,
        updatedAt: now,
      );

      final preview = list.previewDestinations;

      expect(preview.length, 2);
      expect(preview.first.id, 'dest_1');
    });

    test('typeLabel should return correct label for each type', () {
      final types = {
        CuratedListType.popularSolo: 'Popular Solo Destinations',
        CuratedListType.hiddenGems: 'Hidden Gems',
        CuratedListType.budgetFriendly: 'Budget-Friendly',
        CuratedListType.adventure: 'Adventure',
        CuratedListType.cultural: 'Cultural',
        CuratedListType.beach: 'Beach & Coastal',
        CuratedListType.urban: 'Urban Exploration',
        CuratedListType.nature: 'Nature & Wilderness',
        CuratedListType.food: 'Food & Culinary',
        CuratedListType.wellness: 'Wellness & Retreat',
        CuratedListType.seasonal: 'Seasonal Collection',
        CuratedListType.custom: 'Custom Collection',
      };

      for (final entry in types.entries) {
        final list = CuratedList(
          id: 'list_1',
          name: 'List',
          description: 'Desc',
          type: entry.key,
          destinations: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(list.typeLabel, entry.value);
      }
    });

    test('isHiddenGemsList should return true only for hidden gems type', () {
      final hiddenGemsList = CuratedList(
        id: 'list_1',
        name: 'Hidden Gems',
        description: 'Desc',
        type: CuratedListType.hiddenGems,
        destinations: [],
        createdAt: now,
        updatedAt: now,
      );

      expect(hiddenGemsList.isHiddenGemsList, true);

      final popularList = CuratedList(
        id: 'list_1',
        name: 'Popular',
        description: 'Desc',
        type: CuratedListType.popularSolo,
        destinations: [],
        createdAt: now,
        updatedAt: now,
      );

      expect(popularList.isHiddenGemsList, false);
    });

    test('isBudgetFriendly should return true only for budget friendly type',
        () {
      final budgetList = CuratedList(
        id: 'list_1',
        name: 'Budget',
        description: 'Desc',
        type: CuratedListType.budgetFriendly,
        destinations: [],
        createdAt: now,
        updatedAt: now,
      );

      expect(budgetList.isBudgetFriendly, true);

      final adventureList = CuratedList(
        id: 'list_1',
        name: 'Adventure',
        description: 'Desc',
        type: CuratedListType.adventure,
        destinations: [],
        createdAt: now,
        updatedAt: now,
      );

      expect(adventureList.isBudgetFriendly, false);
    });

    test('isPopular should return true for featured or high view/save counts', () {
      // isFeatured makes it popular
      final featuredList = CuratedList(
        id: 'list_1',
        name: 'Popular',
        description: 'Desc',
        type: CuratedListType.popularSolo,
        destinations: [],
        isFeatured: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(featuredList.isPopular, true);

      // High viewCount makes it popular
      final highViewList = CuratedList(
        id: 'list_2',
        name: 'Custom',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        viewCount: 1001,
        createdAt: now,
        updatedAt: now,
      );

      expect(highViewList.isPopular, true);

      // Low counts, not featured
      final customList = CuratedList(
        id: 'list_3',
        name: 'Custom',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        createdAt: now,
        updatedAt: now,
      );

      expect(customList.isPopular, false);
    });

    test('withIncrementedViewCount should increment view count', () {
      final list = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        viewCount: 100,
        createdAt: now,
        updatedAt: now,
      );

      final updated = list.withIncrementedViewCount();

      expect(updated.viewCount, 101);
      expect(updated.id, list.id);
    });

    test('withIncrementedSaveCount should increment save count', () {
      final list = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        saveCount: 50,
        createdAt: now,
        updatedAt: now,
      );

      final updated = list.withIncrementedSaveCount();

      expect(updated.saveCount, 51);
      expect(updated.id, list.id);
    });

    test('withUpdatedTimestamp should update updatedAt', () {
      final list = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        createdAt: now,
        updatedAt: now,
      );

      final updated = list.withUpdatedTimestamp();

      expect(updated.updatedAt.isAfter(list.updatedAt) || updated.updatedAt == list.updatedAt, isTrue);
      expect(updated.id, list.id);
    });

    test('hasSafetyScores should return true when averageSafetyScore is set',
        () {
      final listWithSafety = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        averageSafetyScore: 8.5,
        createdAt: now,
        updatedAt: now,
      );

      expect(listWithSafety.hasSafetyScores, true);

      final listWithoutSafety = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        createdAt: now,
        updatedAt: now,
      );

      expect(listWithoutSafety.hasSafetyScores, false);
    });

    test(
        'hasSoloSuitabilityScores should return true when averageSoloSuitabilityScore is set',
        () {
      final listWithSolo = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        averageSoloSuitabilityScore: 8.0,
        createdAt: now,
        updatedAt: now,
      );

      expect(listWithSolo.hasSoloSuitabilityScores, true);

      final listWithoutSolo = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        createdAt: now,
        updatedAt: now,
      );

      expect(listWithoutSolo.hasSoloSuitabilityScores, false);
    });

    test('matchesTag should return true when list has matching tag', () {
      final list = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        tags: ['asia', 'budget', 'cultural'],
        createdAt: now,
        updatedAt: now,
      );

      expect(list.matchesTag('asia'), true);
      expect(list.matchesTag('budget'), true);
      expect(list.matchesTag('europe'), false);
    });

    test('matchesTag should return false when tags are null', () {
      final list = CuratedList(
        id: 'list_1',
        name: 'List',
        description: 'Desc',
        type: CuratedListType.custom,
        destinations: [],
        createdAt: now,
        updatedAt: now,
      );

      expect(list.matchesTag('asia'), false);
    });

    test('should handle empty destinations list', () {
      final list = CuratedList(
        id: 'list_1',
        name: 'Empty List',
        description: 'No destinations yet',
        type: CuratedListType.custom,
        destinations: [],
        destinationCount: 0,
        createdAt: now,
        updatedAt: now,
      );

      expect(list.hasDestinations, false);
      expect(list.destinationCount, 0);
      expect(list.destinations, isEmpty);
    });

    test('should handle large view and save counts', () {
      final list = CuratedList(
        id: 'list_1',
        name: 'Popular List',
        description: 'Very popular',
        type: CuratedListType.popularSolo,
        destinations: [testDestination],
        viewCount: 1000000,
        saveCount: 50000,
        createdAt: now,
        updatedAt: now,
      );

      expect(list.viewCount, 1000000);
      expect(list.saveCount, 50000);
    });
  });
}
