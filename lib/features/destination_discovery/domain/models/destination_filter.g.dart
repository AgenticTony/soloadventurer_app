// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DestinationFilter _$DestinationFilterFromJson(Map<String, dynamic> json) =>
    _DestinationFilter(
      searchQuery: json['searchQuery'] as String?,
      budgetLevel:
          $enumDecodeNullable(_$FilterBudgetLevelEnumMap, json['budgetLevel']),
      minSafetyScore: (json['minSafetyScore'] as num?)?.toDouble(),
      minSoloSuitabilityScore:
          (json['minSoloSuitabilityScore'] as num?)?.toDouble(),
      activityLevel: $enumDecodeNullable(
          _$FilterActivityLevelEnumMap, json['activityLevel']),
      countryCode: json['countryCode'] as String?,
      region: json['region'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      hiddenGemsOnly: json['hiddenGemsOnly'] as bool? ?? false,
      minPopularityScore: (json['minPopularityScore'] as num?)?.toDouble(),
      maxDailyCost: (json['maxDailyCost'] as num?)?.toInt(),
      sortBy:
          $enumDecodeNullable(_$DestinationSortOrderEnumMap, json['sortBy']) ??
              DestinationSortOrder.popularity,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$DestinationFilterToJson(_DestinationFilter instance) =>
    <String, dynamic>{
      'searchQuery': instance.searchQuery,
      'budgetLevel': _$FilterBudgetLevelEnumMap[instance.budgetLevel],
      'minSafetyScore': instance.minSafetyScore,
      'minSoloSuitabilityScore': instance.minSoloSuitabilityScore,
      'activityLevel': _$FilterActivityLevelEnumMap[instance.activityLevel],
      'countryCode': instance.countryCode,
      'region': instance.region,
      'tags': instance.tags,
      'hiddenGemsOnly': instance.hiddenGemsOnly,
      'minPopularityScore': instance.minPopularityScore,
      'maxDailyCost': instance.maxDailyCost,
      'sortBy': _$DestinationSortOrderEnumMap[instance.sortBy]!,
      'offset': instance.offset,
      'limit': instance.limit,
    };

const _$FilterBudgetLevelEnumMap = {
  FilterBudgetLevel.budget: 'budget',
  FilterBudgetLevel.economy: 'economy',
  FilterBudgetLevel.midRange: 'mid_range',
  FilterBudgetLevel.premium: 'premium',
  FilterBudgetLevel.luxury: 'luxury',
  FilterBudgetLevel.ultraLuxury: 'ultra_luxury',
};

const _$FilterActivityLevelEnumMap = {
  FilterActivityLevel.relaxed: 'relaxed',
  FilterActivityLevel.light: 'light',
  FilterActivityLevel.moderate: 'moderate',
  FilterActivityLevel.active: 'active',
  FilterActivityLevel.intense: 'intense',
  FilterActivityLevel.extreme: 'extreme',
};

const _$DestinationSortOrderEnumMap = {
  DestinationSortOrder.popularity: 'popularity',
  DestinationSortOrder.safety: 'safety',
  DestinationSortOrder.soloSuitability: 'solo_suitability',
  DestinationSortOrder.budgetAsc: 'budget_asc',
  DestinationSortOrder.budgetDesc: 'budget_desc',
  DestinationSortOrder.newest: 'newest',
  DestinationSortOrder.relevance: 'relevance',
};
