import 'package:freezed_annotation/freezed_annotation.dart';

import 'destination.dart';

part 'personalized_recommendation.freezed.dart';
part 'personalized_recommendation.g.dart';

/// Source of the recommendation
enum RecommendationSource {
  /// Based on user's explicit preferences and profile
  @JsonValue('user_preferences')
  userPreferences,

  /// Based on user's past trip history
  @JsonValue('past_trips')
  pastTrips,

  /// Based on similar users' preferences (collaborative filtering)
  @JsonValue('similar_users')
  similarUsers,

  /// Trending destinations among solo travelers
  @JsonValue('trending')
  trending,

  /// From curated collections by travel experts
  @JsonValue('curated')
  curated,

  /// Hybrid approach using multiple factors
  @JsonValue('ai_generated')
  aiGenerated,
}

/// Represents a single destination recommendation with its relevance score
@freezed
sealed class RecommendedDestination with _$RecommendedDestination {
  const RecommendedDestination._();

  const factory RecommendedDestination({
    /// The destination being recommended
    required Destination destination,

    /// Match score/relevance (0.0 to 1.0)
    /// Higher values indicate better match to user preferences
    required double matchScore,

    /// Human-readable reason for this recommendation
    /// Example: "Perfect for your love of cultural experiences and solo dining"
    required String reason,

    /// Key factors that contributed to this recommendation
    /// Example: ["high solo suitability", "cultural activities", "moderate budget"]
    required List<String> matchingFactors,

    /// Indicates if this destination is a hidden gem match
    @Default(false) bool isHiddenGemMatch,
  }) = _RecommendedDestination;

  factory RecommendedDestination.fromJson(Map<String, dynamic> json) =>
      _$RecommendedDestinationFromJson(json);
}

/// Represents AI-generated personalized recommendations for a user
///
/// This model contains a list of destinations tailored to a specific user's
/// preferences, travel history, and behavior. Recommendations are generated
/// using AI/ML algorithms that analyze multiple factors.
@freezed
sealed class PersonalizedRecommendation with _$PersonalizedRecommendation {
  // Private constructor for freezed with custom members
  const PersonalizedRecommendation._();

  factory PersonalizedRecommendation({
    /// Unique identifier for this recommendation set
    required String id,

    /// User ID these recommendations are for
    required String userId,

    /// List of recommended destinations with match scores and reasons
    required List<RecommendedDestination> recommendations,

    /// Source/method used to generate these recommendations
    required RecommendationSource source,

    /// Human-readable summary of recommendations
    /// Example: "Based on your love for cultural immersion and solo dining"
    String? summary,

    /// Total count of recommendations available
    /// May be greater than recommendations.length for pagination
    @Default(0) int totalCount,

    /// Timestamp when recommendations were generated
    required DateTime generatedAt,

    /// Timestamp when these recommendations expire
    /// After this time, fresh recommendations should be fetched
    required DateTime expiresAt,

    /// User preferences used for generating recommendations (snapshot)
    /// Useful for explaining why certain destinations were recommended
    Map<String, dynamic>? preferenceSnapshot,

    /// Related recommendation set IDs
    /// Example: ["rec_123", "rec_456"] for different categories
    List<String>? relatedRecommendationIds,
  }) = _PersonalizedRecommendation;

  factory PersonalizedRecommendation.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedRecommendationFromJson(json);

  /// Checks if recommendations have expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Checks if recommendations are still valid
  bool get isValid => !isExpired;

  /// Returns only high-match recommendations (score >= 0.7)
  List<RecommendedDestination> get highMatchRecommendations =>
      recommendations.where((r) => r.matchScore >= 0.7).toList();

  /// Returns only hidden gem recommendations
  List<RecommendedDestination> get hiddenGemRecommendations =>
      recommendations.where((r) => r.isHiddenGemMatch).toList();

  /// Returns recommendations sorted by match score (highest first)
  List<RecommendedDestination> get sortedByMatchScore {
    final sorted = List<RecommendedDestination>.from(recommendations);
    sorted.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return sorted;
  }
}
