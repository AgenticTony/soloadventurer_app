import 'package:freezed_annotation/freezed_annotation.dart';

part 'destination.freezed.dart';
part 'destination.g.dart';

/// Represents solo suitability factors with individual scores
@freezed
class SoloSuitabilityFactors with _$SoloSuitabilityFactors {
  const factory SoloSuitabilityFactors({
    /// Safety score for solo travelers (1-10)
    required double safety,

    /// Nightlife and social scene score (1-10)
    required double nightlife,

    /// Walkability and public transport (1-10)
    required double walkability,

    /// Hostel and accommodation options (1-10)
    required double accommodation,

    /// Solo dining and activities (1-10)
    required double soloDining,

    /// English proficiency and communication (1-10)
    required double communication,

    /// Overall solo suitability score (1-10)
    required double overall,
  }) = _SoloSuitabilityFactors;

  factory SoloSuitabilityFactors.fromJson(Map<String, dynamic> json) =>
      _$SoloSuitabilityFactorsFromJson(json);
}

/// Represents a safety insight for a destination
@freezed
class SafetyInsight with _$SafetyInsight {
  const factory SafetyInsight({
    /// Category of the safety insight (e.g., "theft", "transportation", "nightlife")
    required String category,

    /// Detailed description of the safety insight
    required String description,

    /// Severity level (low, medium, high)
    required String severity,

    /// Tips for staying safe in this category
    required List<String> tips,
  }) = _SafetyInsight;

  factory SafetyInsight.fromJson(Map<String, dynamic> json) =>
      _$SafetyInsightFromJson(json);
}

/// Represents a popular activity at a destination
@freezed
class Activity with _$Activity {
  const factory Activity({
    /// Activity ID
    required String id,

    /// Activity name
    required String name,

    /// Activity description
    String? description,

    /// Category of activity (e.g., "outdoor", "cultural", "food")
    required String category,

    /// Whether activity is suitable for solo travelers
    required bool soloFriendly,

    /// Estimated cost level
    String? costLevel,

    /// Image URL for the activity
    String? imageUrl,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
}

/// Budget level enum
enum BudgetLevel {
  @JsonValue('budget')
  budget,

  @JsonValue('moderate')
  moderate,

  @JsonValue('expensive')
  expensive,
}

/// Activity level enum
enum ActivityLevel {
  @JsonValue('relaxed')
  relaxed,

  @JsonValue('moderate')
  moderate,

  @JsonValue('adventurous')
  adventurous,
}

/// Represents a destination with solo-travel-specific information
@freezed
class Destination with _$Destination {
  const factory Destination({
    /// Unique identifier
    required String id,

    /// Destination name
    required String name,

    /// Detailed description
    required String description,

    /// Location latitude
    required double latitude,

    /// Location longitude
    required double longitude,

    /// Country code (e.g., "JP", "US")
    required String countryCode,

    /// Region/state/province
    String? region,

    /// Overall safety score (1-10)
    required double safetyScore,

    /// Detailed safety insights
    required List<SafetyInsight> safetyInsights,

    /// Solo suitability score (1-10)
    required double soloSuitabilityScore,

    /// Individual solo suitability factors
    required SoloSuitabilityFactors soloSuitabilityFactors,

    /// Budget level
    required BudgetLevel budgetLevel,

    /// Activity level options available
    required List<ActivityLevel> activityLevels,

    /// Tags/categories (e.g., ["beach", "mountain", "urban"])
    required List<String> tags,

    /// Image URLs for the destination
    required List<String> images,

    /// Cover/featured image
    String? coverImageUrl,

    /// Popular activities at the destination
    required List<Activity> popularActivities,

    /// Best time to visit (e.g., "March to May", "Year-round")
    String? bestTimeToVisit,

    /// Average daily cost estimate (in USD)
    int? averageDailyCost,

    /// Currency code
    String? currencyCode,

    /// Language spoken
    String? language,

    /// Timezone
    String? timezone,

    /// Whether this is a curated "hidden gem"
    @Default(false) bool isHiddenGem,

    /// Popularity score (0-1)
    @Default(0.5) double popularityScore,

    /// Created timestamp
    required DateTime createdAt,

    /// Updated timestamp
    required DateTime updatedAt,
  }) = _Destination;

  factory Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);
}
