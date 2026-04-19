import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart';

void main() {
  group('DestinationFilter', () {
    group('construction', () {
      test('should create with default values', () {
        final filter = DestinationFilter();

        expect(filter.searchQuery, isNull);
        expect(filter.budgetLevel, isNull);
        expect(filter.minSafetyScore, isNull);
        expect(filter.minSoloSuitabilityScore, isNull);
        expect(filter.activityLevel, isNull);
        expect(filter.countryCode, isNull);
        expect(filter.region, isNull);
        expect(filter.tags, isNull);
        expect(filter.hiddenGemsOnly, isFalse);
        expect(filter.minPopularityScore, isNull);
        expect(filter.maxDailyCost, isNull);
        expect(filter.sortBy, DestinationSortOrder.popularity);
        expect(filter.offset, 0);
        expect(filter.limit, 20);
      });

      test('should create with custom values', () {
        final filter = DestinationFilter(
          searchQuery: 'Tokyo',
          budgetLevel: FilterBudgetLevel.midRange,
          minSafetyScore: 7.0,
          minSoloSuitabilityScore: 8.0,
          activityLevel: FilterActivityLevel.moderate,
          countryCode: 'JP',
          region: 'Kanto',
          tags: ['urban', 'cultural'],
          hiddenGemsOnly: true,
          minPopularityScore: 0.5,
          maxDailyCost: 100,
          sortBy: DestinationSortOrder.safety,
          offset: 20,
          limit: 10,
        );

        expect(filter.searchQuery, 'Tokyo');
        expect(filter.budgetLevel, FilterBudgetLevel.midRange);
        expect(filter.minSafetyScore, 7.0);
        expect(filter.minSoloSuitabilityScore, 8.0);
        expect(filter.activityLevel, FilterActivityLevel.moderate);
        expect(filter.countryCode, 'JP');
        expect(filter.region, 'Kanto');
        expect(filter.tags, ['urban', 'cultural']);
        expect(filter.hiddenGemsOnly, isTrue);
        expect(filter.minPopularityScore, 0.5);
        expect(filter.maxDailyCost, 100);
        expect(filter.sortBy, DestinationSortOrder.safety);
        expect(filter.offset, 20);
        expect(filter.limit, 10);
      });

      test('defaultFilter factory should create default filter', () {
        final filter = DestinationFilter.defaultFilter();

        expect(filter.isDefault, isTrue);
        expect(filter.searchQuery, isNull);
        expect(filter.budgetLevel, isNull);
      });
    });

    group('isDefault', () {
      test('should return true when no filters are set', () {
        final filter = DestinationFilter();
        expect(filter.isDefault, isTrue);
      });

      test('should return false when searchQuery is set', () {
        final filter = DestinationFilter(searchQuery: 'Tokyo');
        expect(filter.isDefault, isFalse);
      });

      test('should return false when budgetLevel is set', () {
        final filter = DestinationFilter(budgetLevel: FilterBudgetLevel.budget);
        expect(filter.isDefault, isFalse);
      });

      test('should return false when minSafetyScore is set', () {
        final filter = DestinationFilter(minSafetyScore: 7.0);
        expect(filter.isDefault, isFalse);
      });

      test('should return false when minSoloSuitabilityScore is set', () {
        final filter = DestinationFilter(minSoloSuitabilityScore: 8.0);
        expect(filter.isDefault, isFalse);
      });

      test('should return false when activityLevel is set', () {
        final filter = DestinationFilter(activityLevel: FilterActivityLevel.active);
        expect(filter.isDefault, isFalse);
      });

      test('should return false when countryCode is set', () {
        final filter = DestinationFilter(countryCode: 'JP');
        expect(filter.isDefault, isFalse);
      });

      test('should return false when region is set', () {
        final filter = DestinationFilter(region: 'Kanto');
        expect(filter.isDefault, isFalse);
      });

      test('should return false when tags are set', () {
        final filter = DestinationFilter(tags: ['urban']);
        expect(filter.isDefault, isFalse);
      });

      test('should return true when tags is empty list', () {
        final filter = DestinationFilter(tags: []);
        expect(filter.isDefault, isTrue);
      });

      test('should return false when hiddenGemsOnly is true', () {
        final filter = DestinationFilter(hiddenGemsOnly: true);
        expect(filter.isDefault, isFalse);
      });

      test('should return false when minPopularityScore is set', () {
        final filter = DestinationFilter(minPopularityScore: 0.5);
        expect(filter.isDefault, isFalse);
      });

      test('should return false when maxDailyCost is set', () {
        final filter = DestinationFilter(maxDailyCost: 100);
        expect(filter.isDefault, isFalse);
      });
    });

    group('hasActiveFilters', () {
      test('should return false when no filters are set', () {
        final filter = DestinationFilter();
        expect(filter.hasActiveFilters, isFalse);
      });

      test('should return true when any filter is set', () {
        final filter = DestinationFilter(searchQuery: 'test');
        expect(filter.hasActiveFilters, isTrue);
      });
    });

    group('copyWith', () {
      test('should copy with new searchQuery', () {
        final original = DestinationFilter(searchQuery: 'Tokyo');
        final modified = original.copyWith(searchQuery: 'Kyoto');

        expect(modified.searchQuery, 'Kyoto');
        expect(original.searchQuery, 'Tokyo');
      });

      test('should copy with new budgetLevel', () {
        final original = DestinationFilter(budgetLevel: FilterBudgetLevel.budget);
        final modified =
            original.copyWith(budgetLevel: FilterBudgetLevel.luxury);

        expect(modified.budgetLevel, FilterBudgetLevel.luxury);
        expect(original.budgetLevel, FilterBudgetLevel.budget);
      });

      test('should preserve unspecified fields', () {
        final original = DestinationFilter(
          searchQuery: 'Tokyo',
          countryCode: 'JP',
          minSafetyScore: 7.0,
        );
        final modified = original.copyWith(searchQuery: 'Kyoto');

        expect(modified.searchQuery, 'Kyoto');
        expect(modified.countryCode, 'JP');
        expect(modified.minSafetyScore, 7.0);
      });
    });

    group('resetPagination', () {
      test('should reset offset and limit', () {
        final filter = DestinationFilter(offset: 40, limit: 10);
        final reset = filter.resetPagination();

        expect(reset.offset, 0);
        expect(reset.limit, 20);
        expect(reset.searchQuery, filter.searchQuery);
      });
    });

    group('fromJson', () {
      test('should deserialize from JSON', () {
        final json = {
          'searchQuery': 'Tokyo',
          'budgetLevel': 'budget',
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
          'offset': 20,
          'limit': 10,
        };

        final filter = DestinationFilter.fromJson(json);

        expect(filter.searchQuery, 'Tokyo');
        expect(filter.budgetLevel, FilterBudgetLevel.budget);
        expect(filter.minSafetyScore, 7.0);
        expect(filter.countryCode, 'JP');
        expect(filter.tags, ['urban', 'cultural']);
        expect(filter.hiddenGemsOnly, isTrue);
        expect(filter.offset, 20);
      });
    });

    group('toJson', () {
      test('should serialize to JSON', () {
        final filter = DestinationFilter(
          searchQuery: 'Tokyo',
          countryCode: 'JP',
        );
        final json = filter.toJson();

        expect(json['searchQuery'], 'Tokyo');
        expect(json['countryCode'], 'JP');
      });
    });
  });

  group('FilterBudgetLevel', () {
    test('should have all expected values', () {
      expect(FilterBudgetLevel.values.length, 6);
      expect(FilterBudgetLevel.values, contains(FilterBudgetLevel.budget));
      expect(FilterBudgetLevel.values, contains(FilterBudgetLevel.economy));
      expect(FilterBudgetLevel.values, contains(FilterBudgetLevel.midRange));
      expect(FilterBudgetLevel.values, contains(FilterBudgetLevel.premium));
      expect(FilterBudgetLevel.values, contains(FilterBudgetLevel.luxury));
      expect(FilterBudgetLevel.values, contains(FilterBudgetLevel.ultraLuxury));
    });
  });

  group('FilterActivityLevel', () {
    test('should have all expected values', () {
      expect(FilterActivityLevel.values.length, 6);
      expect(FilterActivityLevel.values, contains(FilterActivityLevel.relaxed));
      expect(FilterActivityLevel.values, contains(FilterActivityLevel.light));
      expect(FilterActivityLevel.values, contains(FilterActivityLevel.moderate));
      expect(FilterActivityLevel.values, contains(FilterActivityLevel.active));
      expect(FilterActivityLevel.values, contains(FilterActivityLevel.intense));
      expect(FilterActivityLevel.values, contains(FilterActivityLevel.extreme));
    });
  });

  group('DestinationSortOrder', () {
    test('should have all expected values', () {
      expect(DestinationSortOrder.values.length, 7);
      expect(DestinationSortOrder.values,
          contains(DestinationSortOrder.popularity));
      expect(
          DestinationSortOrder.values, contains(DestinationSortOrder.safety));
      expect(DestinationSortOrder.values,
          contains(DestinationSortOrder.soloSuitability));
      expect(DestinationSortOrder.values,
          contains(DestinationSortOrder.budgetAsc));
      expect(DestinationSortOrder.values,
          contains(DestinationSortOrder.budgetDesc));
      expect(
          DestinationSortOrder.values, contains(DestinationSortOrder.newest));
      expect(DestinationSortOrder.values,
          contains(DestinationSortOrder.relevance));
    });
  });

  group('Type aliases', () {
    test('BudgetLevel should be alias for FilterBudgetLevel', () {
      // BudgetLevel is a typedef for FilterBudgetLevel
      const level = BudgetLevel.midRange;
      expect(level, FilterBudgetLevel.midRange);
    });

    test('ActivityLevel should be alias for FilterActivityLevel', () {
      // ActivityLevel is a typedef for FilterActivityLevel
      const level = ActivityLevel.moderate;
      expect(level, FilterActivityLevel.moderate);
    });
  });
}
