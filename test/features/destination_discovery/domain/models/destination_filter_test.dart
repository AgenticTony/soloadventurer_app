import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart'
    hide BudgetLevel, ActivityLevel;
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';

void main() {
  group('DestinationSortOrder enum', () {
    test('should have all correct values', () {
      expect(DestinationSortOrder.values.length, 7);

      expect(DestinationSortOrder.popularity, isA<DestinationSortOrder>());
      expect(DestinationSortOrder.safety, isA<DestinationSortOrder>());
      expect(DestinationSortOrder.soloSuitability, isA<DestinationSortOrder>());
      expect(DestinationSortOrder.budgetAsc, isA<DestinationSortOrder>());
      expect(DestinationSortOrder.budgetDesc, isA<DestinationSortOrder>());
      expect(DestinationSortOrder.newest, isA<DestinationSortOrder>());
      expect(DestinationSortOrder.relevance, isA<DestinationSortOrder>());
    });

    test('should serialize correctly', () {
      expect(DestinationSortOrder.popularity.toJson(), 'popularity');
      expect(DestinationSortOrder.safety.toJson(), 'safety');
      expect(DestinationSortOrder.soloSuitability.toJson(), 'solo_suitability');
      expect(DestinationSortOrder.budgetAsc.toJson(), 'budget_asc');
      expect(DestinationSortOrder.budgetDesc.toJson(), 'budget_desc');
      expect(DestinationSortOrder.newest.toJson(), 'newest');
      expect(DestinationSortOrder.relevance.toJson(), 'relevance');
    });

    test('should deserialize correctly', () {
      expect(DestinationSortOrder.fromJson('popularity'),
          DestinationSortOrder.popularity);
      expect(
          DestinationSortOrder.fromJson('safety'), DestinationSortOrder.safety);
      expect(DestinationSortOrder.fromJson('solo_suitability'),
          DestinationSortOrder.soloSuitability);
      expect(DestinationSortOrder.fromJson('budget_asc'),
          DestinationSortOrder.budgetAsc);
      expect(DestinationSortOrder.fromJson('budget_desc'),
          DestinationSortOrder.budgetDesc);
      expect(
          DestinationSortOrder.fromJson('newest'), DestinationSortOrder.newest);
      expect(DestinationSortOrder.fromJson('relevance'),
          DestinationSortOrder.relevance);
    });
  });

  group('DestinationFilter', () {
    test('should create with default values', () {
      const filter = DestinationFilter();

      expect(filter.searchQuery, isNull);
      expect(filter.budgetLevel, isNull);
      expect(filter.minSafetyScore, isNull);
      expect(filter.minSoloSuitabilityScore, isNull);
      expect(filter.activityLevel, isNull);
      expect(filter.countryCode, isNull);
      expect(filter.region, isNull);
      expect(filter.tags, isNull);
      expect(filter.hiddenGemsOnly, false);
      expect(filter.minPopularityScore, isNull);
      expect(filter.maxDailyCost, isNull);
      expect(filter.sortBy, DestinationSortOrder.popularity);
      expect(filter.offset, 0);
      expect(filter.limit, 20);
    });

    test('should create with all fields', () {
      const filter = DestinationFilter(
        searchQuery: 'Tokyo',
        budgetLevel: BudgetLevel.moderate,
        minSafetyScore: 7.0,
        minSoloSuitabilityScore: 8.0,
        activityLevel: ActivityLevel.moderate,
        countryCode: 'JP',
        region: 'Kanto',
        tags: ['urban', 'cultural'],
        hiddenGemsOnly: true,
        minPopularityScore: 0.5,
        maxDailyCost: 100,
        sortBy: DestinationSortOrder.safety,
        offset: 10,
        limit: 30,
      );

      expect(filter.searchQuery, 'Tokyo');
      expect(filter.budgetLevel, BudgetLevel.moderate);
      expect(filter.minSafetyScore, 7.0);
      expect(filter.minSoloSuitabilityScore, 8.0);
      expect(filter.activityLevel, ActivityLevel.moderate);
      expect(filter.countryCode, 'JP');
      expect(filter.region, 'Kanto');
      expect(filter.tags, ['urban', 'cultural']);
      expect(filter.hiddenGemsOnly, true);
      expect(filter.minPopularityScore, 0.5);
      expect(filter.maxDailyCost, 100);
      expect(filter.sortBy, DestinationSortOrder.safety);
      expect(filter.offset, 10);
      expect(filter.limit, 30);
    });

    test('should serialize to JSON correctly', () {
      const filter = DestinationFilter(
        searchQuery: 'Tokyo',
        budgetLevel: BudgetLevel.moderate,
        minSafetyScore: 7.0,
        minSoloSuitabilityScore: 8.0,
        activityLevel: ActivityLevel.moderate,
        countryCode: 'JP',
        region: 'Kanto',
        tags: ['urban', 'cultural'],
        hiddenGemsOnly: true,
        sortBy: DestinationSortOrder.safety,
      );

      final json = filter.toJson();

      expect(json['searchQuery'], 'Tokyo');
      expect(json['budgetLevel'], 'moderate');
      expect(json['minSafetyScore'], 7.0);
      expect(json['minSoloSuitabilityScore'], 8.0);
      expect(json['activityLevel'], 'moderate');
      expect(json['countryCode'], 'JP');
      expect(json['region'], 'Kanto');
      expect(json['tags'], ['urban', 'cultural']);
      expect(json['hiddenGemsOnly'], true);
      expect(json['sortBy'], 'safety');
      expect(json['offset'], 0); // default value
      expect(json['limit'], 20); // default value
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'searchQuery': 'Tokyo',
        'budgetLevel': 'moderate',
        'minSafetyScore': 7.0,
        'minSoloSuitabilityScore': 8.0,
        'activityLevel': 'moderate',
        'countryCode': 'JP',
        'region': 'Kanto',
        'tags': ['urban', 'cultural'],
        'hiddenGemsOnly': true,
        'minPopularityScore': 0.5,
        'maxDailyCost': 100,
        'sortBy': 'safety',
        'offset': 10,
        'limit': 30,
      };

      final filter = DestinationFilter.fromJson(json);

      expect(filter.searchQuery, 'Tokyo');
      expect(filter.budgetLevel, BudgetLevel.moderate);
      expect(filter.minSafetyScore, 7.0);
      expect(filter.minSoloSuitabilityScore, 8.0);
      expect(filter.activityLevel, ActivityLevel.moderate);
      expect(filter.countryCode, 'JP');
      expect(filter.region, 'Kanto');
      expect(filter.tags, ['urban', 'cultural']);
      expect(filter.hiddenGemsOnly, true);
      expect(filter.minPopularityScore, 0.5);
      expect(filter.maxDailyCost, 100);
      expect(filter.sortBy, DestinationSortOrder.safety);
      expect(filter.offset, 10);
      expect(filter.limit, 30);
    });

    test('should implement equality correctly', () {
      const filter1 = DestinationFilter(
        searchQuery: 'Tokyo',
        budgetLevel: BudgetLevel.moderate,
      );

      const filter2 = DestinationFilter(
        searchQuery: 'Tokyo',
        budgetLevel: BudgetLevel.moderate,
      );

      const filter3 = DestinationFilter(
        searchQuery: 'Kyoto',
        budgetLevel: BudgetLevel.moderate,
      );

      expect(filter1, equals(filter2));
      expect(filter1, isNot(equals(filter3)));
      expect(filter1.hashCode, equals(filter2.hashCode));
    });

    test('should support copyWith', () {
      const filter = DestinationFilter(
        searchQuery: 'Tokyo',
        budgetLevel: BudgetLevel.moderate,
        offset: 10,
      );

      final updated = filter.copyWith(
        searchQuery: 'Kyoto',
        offset: 0,
      );

      expect(updated.searchQuery, 'Kyoto');
      expect(updated.budgetLevel, BudgetLevel.moderate);
      expect(updated.offset, 0);
    });

    test('defaultFilter should create a filter with default values', () {
      final filter = DestinationFilter.defaultFilter();

      expect(filter.isDefault, true);
      expect(filter.offset, 0);
      expect(filter.limit, 20);
    });

    test('isDefault should return true when no filters are set', () {
      const filter = DestinationFilter();
      expect(filter.isDefault, true);
    });

    test('isDefault should return false when filters are set', () {
      const filter1 = DestinationFilter(searchQuery: 'Tokyo');
      expect(filter1.isDefault, false);

      const filter2 = DestinationFilter(budgetLevel: BudgetLevel.budget);
      expect(filter2.isDefault, false);

      const filter3 = DestinationFilter(hiddenGemsOnly: true);
      expect(filter3.isDefault, false);
    });

    test('resetPagination should reset offset and limit', () {
      const filter = DestinationFilter(
        searchQuery: 'Tokyo',
        offset: 40,
        limit: 50,
      );

      final reset = filter.resetPagination();

      expect(reset.searchQuery, 'Tokyo');
      expect(reset.offset, 0);
      expect(reset.limit, 20);
    });

    test('hasActiveFilters should return true when any filter is set', () {
      const filter1 = DestinationFilter(searchQuery: 'Tokyo');
      expect(filter1.hasActiveFilters, true);

      const filter2 = DestinationFilter(budgetLevel: BudgetLevel.moderate);
      expect(filter2.hasActiveFilters, true);

      const filter3 = DestinationFilter();
      expect(filter3.hasActiveFilters, false);
    });

    test('should handle null tags correctly', () {
      const filter1 = DestinationFilter();
      expect(filter1.tags, isNull);
      expect(filter1.isDefault, true);

      const filter2 = DestinationFilter(tags: []);
      expect(filter2.tags, isEmpty);
      expect(filter2.isDefault, true); // empty tags is treated as no filter

      const filter3 = DestinationFilter(tags: ['urban']);
      expect(filter3.isDefault, false);
    });
  });
}
