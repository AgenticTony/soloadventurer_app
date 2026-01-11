import 'package:freezed_annotation/freezed_annotation.dart';

part 'destination_filter.freezed.dart';
part 'destination_filter.g.dart';

/// Budget level for travel destinations
enum FilterBudgetLevel {
  /// Budget-friendly options (<$50/day)
  @JsonValue('budget')
  budget,

  /// Economy options ($50-100/day)
  @JsonValue('economy')
  economy,

  /// Mid-range options ($100-200/day)
  @JsonValue('mid_range')
  midRange,

  /// Premium options ($200-400/day)
  @JsonValue('premium')
  premium,

  /// Luxury options ($400-800/day)
  @JsonValue('luxury')
  luxury,

  /// Ultra-luxury options (>$800/day)
  @JsonValue('ultra_luxury')
  ultraLuxury,
}

/// Activity level for travel destinations
enum FilterActivityLevel {
  /// Relaxed pace, minimal physical activity
  @JsonValue('relaxed')
  relaxed,

  /// Light physical activity, easy walks
  @JsonValue('light')
  light,

  /// Moderate activity, some walking/hiking
  @JsonValue('moderate')
  moderate,

  /// Active lifestyle, regular physical activities
  @JsonValue('active')
  active,

  /// Intense activities, challenging adventures
  @JsonValue('intense')
  intense,

  /// Extreme activities, expert-level adventures
  @JsonValue('extreme')
  extreme,
}

// Type aliases for backward compatibility
typedef BudgetLevel = FilterBudgetLevel;
typedef ActivityLevel = FilterActivityLevel;

/// Filter options for destination search
///
/// Used to query and filter destinations based on various criteria
/// including budget, safety, activity level, and solo-friendliness.
@freezed
sealed class DestinationFilter with _$DestinationFilter {
  factory DestinationFilter({
    /// Text search query to filter destinations by name or description
    String? searchQuery,

    /// Budget level filter
    /// When set, only returns destinations matching this budget level
    BudgetLevel? budgetLevel,

    /// Minimum safety score filter (1-10)
    /// When set, only returns destinations with safety score >= this value
    double? minSafetyScore,

    /// Minimum solo suitability score filter (1-10)
    /// When set, only returns destinations with solo suitability >= this value
    double? minSoloSuitabilityScore,

    /// Activity level filter
    /// When set, only returns destinations that support this activity level
    ActivityLevel? activityLevel,

    /// Country code filter (e.g., "JP", "US", "TH")
    /// When set, only returns destinations from this country
    String? countryCode,

    /// Region/state/province filter
    /// When set, only returns destinations from this region
    String? region,

    /// Tags/categories multi-select filter
    /// When set, only returns destinations that match ALL specified tags
    /// Example: ["beach", "urban"] will only return destinations tagged with both
    List<String>? tags,

    /// Whether to include only hidden gems
    /// When true, only returns destinations marked as hidden gems
    @Default(false) bool hiddenGemsOnly,

    /// Minimum popularity score filter (0-1)
    /// When set, only returns destinations with popularity >= this value
    double? minPopularityScore,

    /// Maximum daily cost filter (in USD)
    /// When set, only returns destinations with average daily cost <= this value
    int? maxDailyCost,

    /// Sort order for results
    /// Defaults to relevance when search query is provided, popularity otherwise
    @Default(DestinationSortOrder.popularity) DestinationSortOrder sortBy,

    /// Pagination offset for loading more results
    /// Used for pagination, defaults to 0
    @Default(0) int offset,

    /// Number of results to return
    /// Used for pagination, defaults to 20
    @Default(20) int limit,
  }) = _DestinationFilter;

  DestinationFilter._();

  factory DestinationFilter.fromJson(Map<String, dynamic> json) =>
      _$DestinationFilterFromJson(json);

  /// Creates a default filter with no filters applied
  factory DestinationFilter.defaultFilter() => DestinationFilter();

  /// Creates a copy of this filter with pagination reset
  /// Useful for restarting a search with the same filters
  DestinationFilter resetPagination() {
    return copyWith(
      offset: 0,
      limit: 20,
    );
  }

  /// Returns true if no active filters are set
  bool get isDefault {
    return searchQuery == null &&
        budgetLevel == null &&
        minSafetyScore == null &&
        minSoloSuitabilityScore == null &&
        activityLevel == null &&
        countryCode == null &&
        region == null &&
        (tags == null || tags!.isEmpty) &&
        !hiddenGemsOnly &&
        minPopularityScore == null &&
        maxDailyCost == null;
  }

  /// Returns true if any filter is active
  bool get hasActiveFilters => !isDefault;
}

/// Sort order options for destination search results
enum DestinationSortOrder {
  /// Sort by popularity score (high to low)
  @JsonValue('popularity')
  popularity,

  /// Sort by safety score (high to low)
  @JsonValue('safety')
  safety,

  /// Sort by solo suitability score (high to low)
  @JsonValue('solo_suitability')
  soloSuitability,

  /// Sort by budget level (budget to expensive)
  @JsonValue('budget_asc')
  budgetAsc,

  /// Sort by budget level (expensive to budget)
  @JsonValue('budget_desc')
  budgetDesc,

  /// Sort by newest first
  @JsonValue('newest')
  newest,

  /// Sort by relevance (requires search query)
  @JsonValue('relevance')
  relevance,
}
