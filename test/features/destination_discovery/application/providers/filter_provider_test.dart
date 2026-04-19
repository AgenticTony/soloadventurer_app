import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/filter_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart';

void main() {
  late ProviderContainer container;
  late Filter notifier;

  setUp(() {
    container = ProviderContainer.test();
    addTearDown(container.dispose);
    notifier = container.read(filterProvider.notifier);
  });

  group('Filter', () {
    group('initial state', () {
      test('should start with default filter', () {
        expect(notifier.state, equals(DestinationFilter()));
        expect(notifier.hasActiveFilters, isFalse);
        expect(notifier.activeFilterCount, 0);
      });
    });

    group('updateFilter', () {
      test('should replace entire filter', () {
        final newFilter = DestinationFilter(
          searchQuery: 'Tokyo',
          budgetLevel: BudgetLevel.midRange,
        );

        notifier.updateFilter(newFilter);

        expect(notifier.state.searchQuery, 'Tokyo');
        expect(notifier.state.budgetLevel, BudgetLevel.midRange);
      });
    });

    group('updateSearchQuery', () {
      test('should update search query', () {
        notifier.updateSearchQuery('Kyoto');

        expect(notifier.searchQuery, 'Kyoto');
        expect(notifier.state.searchQuery, 'Kyoto');
      });

      test('should clear search query with null', () {
        notifier.updateSearchQuery('Test');
        notifier.updateSearchQuery(null);

        expect(notifier.searchQuery, isNull);
      });
    });

    group('updateBudgetLevel', () {
      test('should update budget level', () {
        notifier.updateBudgetLevel(BudgetLevel.luxury);

        expect(notifier.budgetLevel, BudgetLevel.luxury);
      });

      test('should clear budget level with null', () {
        notifier.updateBudgetLevel(BudgetLevel.budget);
        notifier.updateBudgetLevel(null);

        expect(notifier.budgetLevel, isNull);
      });
    });

    group('updateMinSafetyScore', () {
      test('should update minimum safety score', () {
        notifier.updateMinSafetyScore(7.5);

        expect(notifier.minSafetyScore, 7.5);
      });

      test('should clear safety score with null', () {
        notifier.updateMinSafetyScore(8.0);
        notifier.updateMinSafetyScore(null);

        expect(notifier.minSafetyScore, isNull);
      });
    });

    group('updateMinSoloSuitabilityScore', () {
      test('should update minimum solo suitability score', () {
        notifier.updateMinSoloSuitabilityScore(7.0);

        expect(notifier.minSoloSuitabilityScore, 7.0);
      });

      test('should clear solo suitability score with null', () {
        notifier.updateMinSoloSuitabilityScore(8.0);
        notifier.updateMinSoloSuitabilityScore(null);

        expect(notifier.minSoloSuitabilityScore, isNull);
      });
    });

    group('updateActivityLevel', () {
      test('should update activity level', () {
        notifier.updateActivityLevel(ActivityLevel.extreme);

        expect(notifier.activityLevel, ActivityLevel.extreme);
      });

      test('should clear activity level with null', () {
        notifier.updateActivityLevel(ActivityLevel.relaxed);
        notifier.updateActivityLevel(null);

        expect(notifier.activityLevel, isNull);
      });
    });

    group('updateLocation', () {
      test('should update country and region', () {
        notifier.updateLocation(countryCode: 'JP', region: 'Kanto');

        expect(notifier.countryCode, 'JP');
        expect(notifier.region, 'Kanto');
      });

      test('should update only country code', () {
        notifier.updateLocation(countryCode: 'US');

        expect(notifier.countryCode, 'US');
        expect(notifier.region, isNull);
      });

      test('should update only region', () {
        notifier.updateLocation(region: 'California');

        expect(notifier.region, 'California');
      });
    });

    group('updateCountryCode', () {
      test('should update country code', () {
        notifier.updateCountryCode('FR');

        expect(notifier.countryCode, 'FR');
      });

      test('should clear country code with null', () {
        notifier.updateCountryCode('JP');
        notifier.updateCountryCode(null);

        expect(notifier.countryCode, isNull);
      });
    });

    group('updateRegion', () {
      test('should update region', () {
        notifier.updateRegion('Kansai');

        expect(notifier.region, 'Kansai');
      });

      test('should clear region with null', () {
        notifier.updateRegion('Kanto');
        notifier.updateRegion(null);

        expect(notifier.region, isNull);
      });
    });

    group('updateTags', () {
      test('should update tags', () {
        final tags = ['urban', 'cultural', 'food'];
        notifier.updateTags(tags);

        expect(notifier.tags?.length, 3);
        expect(notifier.tags?.contains('urban'), isTrue);
      });

      test('should clear tags with null or empty', () {
        notifier.updateTags(['urban', 'cultural']);
        notifier.updateTags(null);

        expect(notifier.tags, isNull);
      });
    });

    group('addTag', () {
      test('should add tag to existing tags', () {
        notifier.updateTags(['urban']);
        notifier.addTag('cultural');

        expect(notifier.tags?.length, 2);
        expect(notifier.tags?.contains('cultural'), isTrue);
      });

      test('should add first tag when tags is null', () {
        notifier.addTag('urban');

        expect(notifier.tags?.length, 1);
        expect(notifier.tags?.first, 'urban');
      });

      test('should not add duplicate tag', () {
        notifier.addTag('urban');
        notifier.addTag('urban');

        expect(notifier.tags?.length, 1);
      });
    });

    group('removeTag', () {
      test('should remove tag from tags', () {
        notifier.updateTags(['urban', 'cultural', 'food']);
        notifier.removeTag('cultural');

        expect(notifier.tags?.length, 2);
        expect(notifier.tags?.contains('cultural'), isFalse);
      });

      test('should set tags to null when removing last tag', () {
        notifier.updateTags(['urban']);
        notifier.removeTag('urban');

        expect(notifier.tags, isNull);
      });

      test('should do nothing when tag does not exist', () async {
        notifier.updateTags(['urban']);
        notifier.removeTag('cultural');

        expect(notifier.tags?.length, 1);
      });

      test('should do nothing when tags is null', () async {
        notifier.removeTag('urban');

        expect(notifier.tags, isNull);
      });
    });

    group('toggleTag', () {
      test('should add tag when not present', () {
        notifier.updateTags(['urban']);
        notifier.toggleTag('cultural');

        expect(notifier.tags?.length, 2);
        expect(notifier.tags?.contains('cultural'), isTrue);
      });

      test('should remove tag when present', () {
        notifier.updateTags(['urban', 'cultural']);
        notifier.toggleTag('cultural');

        expect(notifier.tags?.length, 1);
        expect(notifier.tags?.contains('cultural'), isFalse);
      });
    });

    group('updateHiddenGemsOnly', () {
      test('should update hidden gems only filter', () {
        notifier.updateHiddenGemsOnly(true);

        expect(notifier.hiddenGemsOnly, isTrue);
      });
    });

    group('toggleHiddenGemsOnly', () {
      test('should toggle hidden gems filter', () {
        expect(notifier.hiddenGemsOnly, isFalse);

        notifier.toggleHiddenGemsOnly();

        expect(notifier.hiddenGemsOnly, isTrue);

        notifier.toggleHiddenGemsOnly();

        expect(notifier.hiddenGemsOnly, isFalse);
      });
    });

    group('updateMinPopularityScore', () {
      test('should update minimum popularity score', () {
        notifier.updateMinPopularityScore(0.7);

        expect(notifier.minPopularityScore, 0.7);
      });

      test('should clear popularity score with null', () {
        notifier.updateMinPopularityScore(0.8);
        notifier.updateMinPopularityScore(null);

        expect(notifier.minPopularityScore, isNull);
      });
    });

    group('updateMaxDailyCost', () {
      test('should update maximum daily cost', () {
        notifier.updateMaxDailyCost(200);

        expect(notifier.maxDailyCost, 200);
      });

      test('should clear max daily cost with null', () {
        notifier.updateMaxDailyCost(150);
        notifier.updateMaxDailyCost(null);

        expect(notifier.maxDailyCost, isNull);
      });
    });

    group('updateSortOrder', () {
      test('should update sort order', () {
        notifier.updateSortOrder(DestinationSortOrder.safety);

        expect(notifier.sortOrder, DestinationSortOrder.safety);
      });
    });

    group('reset', () {
      test('should reset all filters to default', () {
        notifier.updateSearchQuery('Tokyo');
        notifier.updateBudgetLevel(BudgetLevel.midRange);
        notifier.updateMinSafetyScore(8.0);
        notifier.updateTags(['urban']);
        notifier.updateHiddenGemsOnly(true);

        notifier.reset();

        expect(notifier.searchQuery, isNull);
        expect(notifier.budgetLevel, isNull);
        expect(notifier.minSafetyScore, isNull);
        expect(notifier.tags, isNull);
        expect(notifier.hiddenGemsOnly, isFalse);
        expect(notifier.activeFilterCount, 0);
      });
    });

    group('resetSoftFilters', () {
      test('should reset only soft filters', () {
        notifier.updateSearchQuery('Tokyo');
        notifier.updateBudgetLevel(BudgetLevel.midRange);
        notifier.updateCountryCode('JP');
        notifier.updateTags(['urban']);
        notifier.updateHiddenGemsOnly(true);

        notifier.resetSoftFilters();

        expect(notifier.searchQuery, isNull);
        expect(notifier.tags, isNull);
        expect(notifier.hiddenGemsOnly, isFalse);
        expect(notifier.budgetLevel, BudgetLevel.midRange); // Preserved
        expect(notifier.countryCode, 'JP'); // Preserved
      });
    });

    group('resetPagination', () {
      test('should reset pagination fields', () {
        notifier.state = notifier.state.copyWith(
          offset: 40,
          limit: 20,
        );

        notifier.resetPagination();

        expect(notifier.state.offset, 0);
        expect(notifier.state.limit, 20);
      });
    });

    group('hasActiveFilters', () {
      test('should return false when no filters are active', () {
        expect(notifier.hasActiveFilters, isFalse);
      });

      test('should return true when filters are active', () {
        notifier.updateSearchQuery('Tokyo');

        expect(notifier.hasActiveFilters, isTrue);
      });
    });

    group('hasOnlySoftFilters', () {
      test('should return true when only soft filters are active', () {
        notifier.updateSearchQuery('Tokyo');

        expect(notifier.hasOnlySoftFilters, isTrue);
      });

      test('should return false when hard filters are active', () {
        notifier.updateBudgetLevel(BudgetLevel.midRange);

        expect(notifier.hasOnlySoftFilters, isFalse);
      });

      test('should return false when both types are active', () {
        notifier.updateSearchQuery('Tokyo');
        notifier.updateBudgetLevel(BudgetLevel.midRange);

        expect(notifier.hasOnlySoftFilters, isFalse);
      });
    });

    group('activeFilterCount', () {
      test('should count active filters correctly', () {
        expect(notifier.activeFilterCount, 0);

        notifier.updateSearchQuery('Tokyo');
        expect(notifier.activeFilterCount, 1);

        notifier.updateBudgetLevel(BudgetLevel.midRange);
        expect(notifier.activeFilterCount, 2);

        notifier.updateMinSafetyScore(8.0);
        expect(notifier.activeFilterCount, 3);

        notifier.updateTags(['urban', 'cultural']);
        expect(notifier.activeFilterCount, 4); // Tags counts as 1

        notifier.updateHiddenGemsOnly(true);
        expect(notifier.activeFilterCount, 5);

        notifier.updateCountryCode('JP');
        expect(notifier.activeFilterCount, 6);

        notifier.updateRegion('Kanto');
        expect(notifier.activeFilterCount, 7);
      });
    });

    group('complex scenarios', () {
      test('should handle multiple filter updates', () {
        notifier
          ..updateSearchQuery('Japan')
          ..updateBudgetLevel(BudgetLevel.midRange)
          ..updateMinSafetyScore(7.5)
          ..updateActivityLevel(ActivityLevel.moderate)
          ..updateCountryCode('JP')
          ..addTag('urban')
          ..addTag('cultural');

        expect(notifier.activeFilterCount, 6);
        expect(notifier.searchQuery, 'Japan');
        expect(notifier.budgetLevel, BudgetLevel.midRange);
        expect(notifier.tags?.length, 2);
      });

      test('should handle filter reset and re-apply', () {
        notifier
          ..updateSearchQuery('Tokyo')
          ..updateBudgetLevel(BudgetLevel.luxury);

        notifier.reset();

        expect(notifier.hasActiveFilters, isFalse);

        notifier
          ..updateSearchQuery('Kyoto')
          ..updateMinSafetyScore(8.0);

        expect(notifier.activeFilterCount, 2);
        expect(notifier.searchQuery, 'Kyoto');
      });

      test('should handle tag operations correctly', () {
        notifier
          ..addTag('urban')
          ..addTag('cultural')
          ..addTag('food');

        expect(notifier.tags?.length, 3);

        notifier.toggleTag('cultural');

        expect(notifier.tags?.length, 2);
        expect(notifier.tags?.contains('cultural'), isFalse);

        notifier.removeTag('urban');

        expect(notifier.tags?.length, 1);
        expect(notifier.tags?.first, 'food');
      });
    });
  });
}
