import '../../domain/models/personalized_recommendation.dart';
import 'destination_dto.dart';

/// Data Transfer Object for PersonalizedRecommendation API responses
///
/// Provides explicit mapping between GraphQL API responses and the
/// [PersonalizedRecommendation] domain model. Handles nested destination
/// objects and complex recommendation data structures.
class PersonalizedRecommendationDto {
  /// Unique identifier
  final String id;

  /// User ID for whom recommendations are generated
  final String userId;

  /// List of recommended destinations with metadata
  final List<Map<String, dynamic>>? recommendations;

  /// Source of recommendations
  final String? source;

  /// Summary of recommendations
  final String? summary;

  /// Total count of recommendations
  final int? totalCount;

  /// When recommendations were generated
  final String? generatedAt;

  /// When recommendations expire
  final String? expiresAt;

  /// Snapshot of user preferences used for generation
  final Map<String, dynamic>? preferenceSnapshot;

  /// IDs of related recommendations
  final List<String>? relatedRecommendationIds;

  const PersonalizedRecommendationDto({
    required this.id,
    required this.userId,
    this.recommendations,
    this.source,
    this.summary,
    this.totalCount,
    this.generatedAt,
    this.expiresAt,
    this.preferenceSnapshot,
    this.relatedRecommendationIds,
  });

  /// Creates a [PersonalizedRecommendationDto] from JSON data (GraphQL response)
  factory PersonalizedRecommendationDto.fromJson(Map<String, dynamic> json) {
    return PersonalizedRecommendationDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      recommendations: (json['recommendations'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      source: json['source'] as String?,
      summary: json['summary'] as String?,
      totalCount: json['totalCount'] as int?,
      generatedAt: json['generatedAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      preferenceSnapshot: json['preferenceSnapshot'] as Map<String, dynamic>?,
      relatedRecommendationIds: (json['relatedRecommendationIds'] as List?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  /// Converts the DTO to a [PersonalizedRecommendation] domain model
  ///
  /// Handles null values by providing sensible defaults where appropriate.
  PersonalizedRecommendation toDomain() {
    return PersonalizedRecommendation(
      id: id,
      userId: userId,
      recommendations: _parseRecommendations(),
      source: source != null
          ? _parseRecommendationSource(source!)
          : RecommendationSource.aiGenerated,
      summary: summary ?? '',
      totalCount: totalCount ?? recommendations?.length ?? 0,
      generatedAt: generatedAt != null
          ? DateTime.parse(generatedAt!)
          : DateTime.now(),
      expiresAt: expiresAt != null
          ? DateTime.parse(expiresAt!)
          : null,
      preferenceSnapshot: preferenceSnapshot,
      relatedRecommendationIds: relatedRecommendationIds ?? [],
    );
  }

  /// Parses recommendations list to domain model
  List<RecommendedDestination> _parseRecommendations() {
    if (recommendations == null) return [];

    return recommendations!.map((recJson) {
      final destinationDto = DestinationDto.fromJson(
        recJson['destination'] as Map<String, dynamic>,
      );

      return RecommendedDestination(
        destination: destinationDto.toDomain(),
        matchScore: (recJson['matchScore'] as num?)?.toDouble() ?? 0.0,
        reason: recJson['reason'] as String? ?? '',
        matchingFactors: (recJson['matchingFactors'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        isHiddenGemMatch: recJson['isHiddenGemMatch'] as bool? ?? false,
      );
    }).toList();
  }

  /// Parses recommendation source string to enum
  RecommendationSource _parseRecommendationSource(String value) {
    // Normalize string to snake_case
    final normalizedValue = value.toLowerCase().replaceAll('-', '_');

    switch (normalizedValue) {
      case 'user_preferences':
        return RecommendationSource.userPreferences;
      case 'past_trips':
        return RecommendationSource.pastTrips;
      case 'similar_users':
        return RecommendationSource.similarUsers;
      case 'trending':
        return RecommendationSource.trending;
      case 'curated':
        return RecommendationSource.curated;
      case 'ai_generated':
        return RecommendationSource.aiGenerated;
      default:
        return RecommendationSource.aiGenerated;
    }
  }

  /// Converts a list of JSON objects to a list of [PersonalizedRecommendationDto]s
  static List<PersonalizedRecommendationDto> fromJsonList(
    List<dynamic> jsonList,
  ) {
    return jsonList
        .map((json) =>
            PersonalizedRecommendationDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Converts a list of [PersonalizedRecommendationDto]s to domain models
  static List<PersonalizedRecommendation> toDomainList(
    List<PersonalizedRecommendationDto> dtos,
  ) {
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
