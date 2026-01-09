import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/destination.dart';
import '../../domain/models/destination_filter.dart';

/// Provider for destination filter state management
///
/// This provider manages the state of destination search filters including:
/// - Budget level
/// - Safety score
/// - Activity level
/// - Solo suitability score
/// - Location/region
/// - Tags/categories
/// - Search query
/// - Sort order
///
/// This provider is separate from [destinationSearchProvider] to allow UI
/// components to manage filter state without triggering searches immediately.
///
/// Usage:
/// ```dart
/// final filterState = ref.watch(filterProvider);
/// final filterNotifier = ref.read(filterProvider.notifier);
///
/// // Update individual filter fields
/// filterNotifier.updateBudgetLevel(BudgetLevel.moderate);
/// filterNotifier.updateMinSafetyScore(7.0);
/// filterNotifier.updateSearchQuery('Tokyo');
///
/// // Update multiple fields at once
/// filterNotifier.updateFilter(
///   const DestinationFilter(
///     budgetLevel: BudgetLevel.budget,
///     minSafetyScore: 8.0,
///   ),
/// );
///
/// // Reset all filters
/// filterNotifier.reset();
///
/// // Check if filters are active
/// if (filterState.hasActiveFilters) {
///   // Show active filters indicator
/// }
/// ```
final filterProvider =
    StateNotifierProvider<FilterNotifier, DestinationFilter>((ref) {
  return FilterNotifier();
});

/// Notifier for managing destination filter state
///
/// This notifier handles all filter update operations:
/// - Updating individual filter fields
/// - Updating the entire filter at once
/// - Resetting filters to default values
/// - Providing helper methods to check filter status
class FilterNotifier extends StateNotifier<DestinationFilter> {
  /// Creates a new [FilterNotifier]
  ///
  /// The filter starts with default values (no filters applied).
  FilterNotifier() : super(const DestinationFilter());

  /// Update the entire filter at once
  ///
  /// The [filter] parameter completely replaces the current filter state.
  /// Use this method when you need to update multiple fields at once.
  ///
  /// This is useful for applying a complete filter preset or when loading
  /// saved filter preferences.
  void updateFilter(DestinationFilter filter) {
    state = filter;
  }

  /// Update the search query
  ///
  /// The [query] parameter is the text to search for. Set to null to clear.
  void updateSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Update the budget level filter
  ///
  /// The [budgetLevel] parameter specifies the desired budget level.
  /// Set to null to remove this filter.
  void updateBudgetLevel(BudgetLevel? budgetLevel) {
    state = state.copyWith(budgetLevel: budgetLevel);
  }

  /// Update the minimum safety score filter
  ///
  /// The [score] parameter is the minimum safety score (1-10).
  /// Set to null to remove this filter.
  void updateMinSafetyScore(double? score) {
    state = state.copyWith(minSafetyScore: score);
  }

  /// Update the minimum solo suitability score filter
  ///
  /// The [score] parameter is the minimum solo suitability score (1-10).
  /// Set to null to remove this filter.
  void updateMinSoloSuitabilityScore(double? score) {
    state = state.copyWith(minSoloSuitabilityScore: score);
  }

  /// Update the activity level filter
  ///
  /// The [activityLevel] parameter specifies the desired activity level.
  /// Set to null to remove this filter.
  void updateActivityLevel(ActivityLevel? activityLevel) {
    state = state.copyWith(activityLevel: activityLevel);
  }

  /// Update the location/region filters
  ///
  /// The [countryCode] parameter is the ISO country code (e.g., "JP", "US").
  /// The [region] parameter is the region/state/province.
  /// Set either to null to remove that filter.
  void updateLocation({String? countryCode, String? region}) {
    state = state.copyWith(
      countryCode: countryCode,
      region: region,
    );
  }

  /// Update the country code filter
  ///
  /// The [countryCode] parameter is the ISO country code (e.g., "JP", "US").
  /// Set to null to remove this filter.
  void updateCountryCode(String? countryCode) {
    state = state.copyWith(countryCode: countryCode);
  }

  /// Update the region filter
  ///
  /// The [region] parameter is the region/state/province.
  /// Set to null to remove this filter.
  void updateRegion(String? region) {
    state = state.copyWith(region: region);
  }

  /// Update the tags filter
  ///
  /// The [tags] parameter is a list of tags to filter by.
  /// Destinations must match ALL specified tags.
  /// Set to null or empty to remove this filter.
  void updateTags(List<String>? tags) {
    state = state.copyWith(tags: tags);
  }

  /// Add a single tag to the tags filter
  ///
  /// The [tag] parameter will be added to the existing tags list.
  /// If the tag is already present, the state remains unchanged.
  void addTag(String tag) {
    final currentTags = state.tags ?? [];
    if (currentTags.contains(tag)) {
      return; // Tag already exists
    }
    state = state.copyWith(tags: [...currentTags, tag]);
  }

  /// Remove a single tag from the tags filter
  ///
  /// The [tag] parameter will be removed from the existing tags list.
  /// If the tag is not present, the state remains unchanged.
  void removeTag(String tag) {
    final currentTags = state.tags;
    if (currentTags == null || !currentTags.contains(tag)) {
      return; // Tag doesn't exist
    }

    final updatedTags = currentTags.where((t) => t != tag).toList();
    state = state.copyWith(
      tags: updatedTags.isEmpty ? null : updatedTags,
    );
  }

  /// Toggle a tag in the tags filter
  ///
  /// The [tag] parameter will be added if not present, or removed if present.
  void toggleTag(String tag) {
    final currentTags = state.tags ?? [];
    if (currentTags.contains(tag)) {
      removeTag(tag);
    } else {
      addTag(tag);
    }
  }

  /// Update the hidden gems only filter
  ///
  /// The [hiddenGemsOnly] parameter, when true, filters to show only hidden gems.
  void updateHiddenGemsOnly(bool hiddenGemsOnly) {
    state = state.copyWith(hiddenGemsOnly: hiddenGemsOnly);
  }

  /// Toggle the hidden gems only filter
  void toggleHiddenGemsOnly() {
    state = state.copyWith(hiddenGemsOnly: !state.hiddenGemsOnly);
  }

  /// Update the minimum popularity score filter
  ///
  /// The [score] parameter is the minimum popularity score (0-1).
  /// Set to null to remove this filter.
  void updateMinPopularityScore(double? score) {
    state = state.copyWith(minPopularityScore: score);
  }

  /// Update the maximum daily cost filter
  ///
  /// The [cost] parameter is the maximum average daily cost in USD.
  /// Set to null to remove this filter.
  void updateMaxDailyCost(int? cost) {
    state = state.copyWith(maxDailyCost: cost);
  }

  /// Update the sort order
  ///
  /// The [sortOrder] parameter determines how results are sorted.
  void updateSortOrder(DestinationSortOrder sortOrder) {
    state = state.copyWith(sortBy: sortOrder);
  }

  /// Reset all filters to default values
  ///
  /// This method clears all active filters and resets to the initial state.
  /// The search query, budget, safety scores, location, tags, and other
  /// filters will all be reset to their default (null/empty) values.
  void reset() {
    state = const DestinationFilter();
  }

  /// Reset only the soft filters (keeps location and budget)
  ///
  /// This method clears search query, tags, and toggles while preserving
  /// location and budget settings. Useful for refining an existing search.
  void resetSoftFilters() {
    state = state.copyWith(
      searchQuery: null,
      tags: null,
      hiddenGemsOnly: false,
      minPopularityScore: null,
    );
  }

  /// Reset pagination-related fields
  ///
  /// This method resets offset and limit to their default values.
  /// This is useful when starting a new search.
  void resetPagination() {
    state = state.resetPagination();
  }

  // ===== Helper Getters =====

  /// Check if any filters are currently active
  ///
  /// Returns true if any filter field has a non-default value.
  bool get hasActiveFilters => state.hasActiveFilters;

  /// Check if only soft filters are active
  ///
  /// Returns true if only search query, tags, or toggles are set,
  /// but location, budget, and score filters are not.
  bool get hasOnlySoftFilters {
    return state.searchQuery != null ||
        (state.tags != null && state.tags!.isNotEmpty) ||
        state.hiddenGemsOnly ||
        state.minPopularityScore != null;
  }

  /// Get the current search query
  String? get searchQuery => state.searchQuery;

  /// Get the current budget level filter
  BudgetLevel? get budgetLevel => state.budgetLevel;

  /// Get the current minimum safety score filter
  double? get minSafetyScore => state.minSafetyScore;

  /// Get the current minimum solo suitability score filter
  double? get minSoloSuitabilityScore => state.minSoloSuitabilityScore;

  /// Get the current activity level filter
  ActivityLevel? get activityLevel => state.activityLevel;

  /// Get the current country code filter
  String? get countryCode => state.countryCode;

  /// Get the current region filter
  String? get region => state.region;

  /// Get the current tags filter
  List<String>? get tags => state.tags;

  /// Get the current hidden gems only filter
  bool get hiddenGemsOnly => state.hiddenGemsOnly;

  /// Get the current minimum popularity score filter
  double? get minPopularityScore => state.minPopularityScore;

  /// Get the current maximum daily cost filter
  int? get maxDailyCost => state.maxDailyCost;

  /// Get the current sort order
  DestinationSortOrder get sortOrder => state.sortBy;

  /// Get the count of active filters
  ///
  /// Returns the number of filter fields that have non-default values.
  int get activeFilterCount {
    int count = 0;
    if (state.searchQuery != null) count++;
    if (state.budgetLevel != null) count++;
    if (state.minSafetyScore != null) count++;
    if (state.minSoloSuitabilityScore != null) count++;
    if (state.activityLevel != null) count++;
    if (state.countryCode != null) count++;
    if (state.region != null) count++;
    if (state.tags != null && state.tags!.isNotEmpty) count++;
    if (state.hiddenGemsOnly) count++;
    if (state.minPopularityScore != null) count++;
    if (state.maxDailyCost != null) count++;
    return count;
  }
}
