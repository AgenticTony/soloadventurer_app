// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SoloSuitabilityFactors _$SoloSuitabilityFactorsFromJson(
        Map<String, dynamic> json) =>
    _SoloSuitabilityFactors(
      safety: (json['safety'] as num).toDouble(),
      nightlife: (json['nightlife'] as num).toDouble(),
      walkability: (json['walkability'] as num).toDouble(),
      accommodation: (json['accommodation'] as num).toDouble(),
      soloDining: (json['soloDining'] as num).toDouble(),
      communication: (json['communication'] as num).toDouble(),
      overall: (json['overall'] as num).toDouble(),
    );

Map<String, dynamic> _$SoloSuitabilityFactorsToJson(
        _SoloSuitabilityFactors instance) =>
    <String, dynamic>{
      'safety': instance.safety,
      'nightlife': instance.nightlife,
      'walkability': instance.walkability,
      'accommodation': instance.accommodation,
      'soloDining': instance.soloDining,
      'communication': instance.communication,
      'overall': instance.overall,
    };

_SafetyInsight _$SafetyInsightFromJson(Map<String, dynamic> json) =>
    _SafetyInsight(
      category: json['category'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      tips: (json['tips'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SafetyInsightToJson(_SafetyInsight instance) =>
    <String, dynamic>{
      'category': instance.category,
      'description': instance.description,
      'severity': instance.severity,
      'tips': instance.tips,
    };

_Activity _$ActivityFromJson(Map<String, dynamic> json) => _Activity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      soloFriendly: json['soloFriendly'] as bool,
      costLevel: json['costLevel'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ActivityToJson(_Activity instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'soloFriendly': instance.soloFriendly,
      'costLevel': instance.costLevel,
      'imageUrl': instance.imageUrl,
    };

_Destination _$DestinationFromJson(Map<String, dynamic> json) => _Destination(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      countryCode: json['countryCode'] as String,
      region: json['region'] as String?,
      safetyScore: (json['safetyScore'] as num).toDouble(),
      safetyInsights: (json['safetyInsights'] as List<dynamic>)
          .map((e) => SafetyInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      soloSuitabilityScore: (json['soloSuitabilityScore'] as num).toDouble(),
      soloSuitabilityFactors: SoloSuitabilityFactors.fromJson(
          json['soloSuitabilityFactors'] as Map<String, dynamic>),
      budgetLevel: $enumDecode(_$BudgetLevelEnumMap, json['budgetLevel']),
      activityLevels: (json['activityLevels'] as List<dynamic>)
          .map((e) => $enumDecode(_$ActivityLevelEnumMap, e))
          .toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      coverImageUrl: json['coverImageUrl'] as String?,
      popularActivities: (json['popularActivities'] as List<dynamic>)
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList(),
      bestTimeToVisit: json['bestTimeToVisit'] as String?,
      averageDailyCost: (json['averageDailyCost'] as num?)?.toInt(),
      currencyCode: json['currencyCode'] as String?,
      language: json['language'] as String?,
      timezone: json['timezone'] as String?,
      isHiddenGem: json['isHiddenGem'] as bool? ?? false,
      popularityScore: (json['popularityScore'] as num?)?.toDouble() ?? 0.5,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DestinationToJson(_Destination instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'countryCode': instance.countryCode,
      'region': instance.region,
      'safetyScore': instance.safetyScore,
      'safetyInsights': instance.safetyInsights,
      'soloSuitabilityScore': instance.soloSuitabilityScore,
      'soloSuitabilityFactors': instance.soloSuitabilityFactors,
      'budgetLevel': _$BudgetLevelEnumMap[instance.budgetLevel]!,
      'activityLevels': instance.activityLevels
          .map((e) => _$ActivityLevelEnumMap[e]!)
          .toList(),
      'tags': instance.tags,
      'images': instance.images,
      'coverImageUrl': instance.coverImageUrl,
      'popularActivities': instance.popularActivities,
      'bestTimeToVisit': instance.bestTimeToVisit,
      'averageDailyCost': instance.averageDailyCost,
      'currencyCode': instance.currencyCode,
      'language': instance.language,
      'timezone': instance.timezone,
      'isHiddenGem': instance.isHiddenGem,
      'popularityScore': instance.popularityScore,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$BudgetLevelEnumMap = {
  BudgetLevel.budget: 'budget',
  BudgetLevel.moderate: 'moderate',
  BudgetLevel.expensive: 'expensive',
};

const _$ActivityLevelEnumMap = {
  ActivityLevel.relaxed: 'relaxed',
  ActivityLevel.moderate: 'moderate',
  ActivityLevel.adventurous: 'adventurous',
};
