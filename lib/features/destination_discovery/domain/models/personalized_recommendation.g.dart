// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personalized_recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecommendedDestination _$RecommendedDestinationFromJson(
        Map<String, dynamic> json) =>
    _RecommendedDestination(
      destination:
          Destination.fromJson(json['destination'] as Map<String, dynamic>),
      matchScore: (json['matchScore'] as num).toDouble(),
      reason: json['reason'] as String,
      matchingFactors: (json['matchingFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isHiddenGemMatch: json['isHiddenGemMatch'] as bool? ?? false,
    );

Map<String, dynamic> _$RecommendedDestinationToJson(
        _RecommendedDestination instance) =>
    <String, dynamic>{
      'destination': instance.destination,
      'matchScore': instance.matchScore,
      'reason': instance.reason,
      'matchingFactors': instance.matchingFactors,
      'isHiddenGemMatch': instance.isHiddenGemMatch,
    };

_PersonalizedRecommendation _$PersonalizedRecommendationFromJson(
        Map<String, dynamic> json) =>
    _PersonalizedRecommendation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map(
              (e) => RecommendedDestination.fromJson(e as Map<String, dynamic>))
          .toList(),
      source: $enumDecode(_$RecommendationSourceEnumMap, json['source']),
      summary: json['summary'] as String?,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      preferenceSnapshot: json['preferenceSnapshot'] as Map<String, dynamic>?,
      relatedRecommendationIds:
          (json['relatedRecommendationIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$PersonalizedRecommendationToJson(
        _PersonalizedRecommendation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'recommendations': instance.recommendations,
      'source': _$RecommendationSourceEnumMap[instance.source]!,
      'summary': instance.summary,
      'totalCount': instance.totalCount,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'preferenceSnapshot': instance.preferenceSnapshot,
      'relatedRecommendationIds': instance.relatedRecommendationIds,
    };

const _$RecommendationSourceEnumMap = {
  RecommendationSource.userPreferences: 'user_preferences',
  RecommendationSource.pastTrips: 'past_trips',
  RecommendationSource.similarUsers: 'similar_users',
  RecommendationSource.trending: 'trending',
  RecommendationSource.curated: 'curated',
  RecommendationSource.aiGenerated: 'ai_generated',
};
