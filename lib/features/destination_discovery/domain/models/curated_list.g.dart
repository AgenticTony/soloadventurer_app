// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curated_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CuratedList _$CuratedListFromJson(Map<String, dynamic> json) => _CuratedList(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$CuratedListTypeEnumMap, json['type']),
      destinations: (json['destinations'] as List<dynamic>)
          .map((e) => Destination.fromJson(e as Map<String, dynamic>))
          .toList(),
      coverImageUrl: json['coverImageUrl'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      curatorName: json['curatorName'] as String?,
      curatorImageUrl: json['curatorImageUrl'] as String?,
      destinationCount: (json['destinationCount'] as num?)?.toInt() ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      averageSafetyScore: (json['averageSafetyScore'] as num?)?.toDouble(),
      averageSoloSuitabilityScore:
          (json['averageSoloSuitabilityScore'] as num?)?.toDouble(),
      budgetRange: json['budgetRange'] as String?,
      bestTimeToVisit: json['bestTimeToVisit'] as String?,
      recommendedDuration: json['recommendedDuration'] as String?,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      saveCount: (json['saveCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      isPublished: json['isPublished'] as bool? ?? true,
    );

Map<String, dynamic> _$CuratedListToJson(_CuratedList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$CuratedListTypeEnumMap[instance.type]!,
      'destinations': instance.destinations,
      'coverImageUrl': instance.coverImageUrl,
      'images': instance.images,
      'curatorName': instance.curatorName,
      'curatorImageUrl': instance.curatorImageUrl,
      'destinationCount': instance.destinationCount,
      'isFeatured': instance.isFeatured,
      'displayOrder': instance.displayOrder,
      'tags': instance.tags,
      'averageSafetyScore': instance.averageSafetyScore,
      'averageSoloSuitabilityScore': instance.averageSoloSuitabilityScore,
      'budgetRange': instance.budgetRange,
      'bestTimeToVisit': instance.bestTimeToVisit,
      'recommendedDuration': instance.recommendedDuration,
      'viewCount': instance.viewCount,
      'saveCount': instance.saveCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'isPublished': instance.isPublished,
    };

const _$CuratedListTypeEnumMap = {
  CuratedListType.popularSolo: 'popular_solo',
  CuratedListType.hiddenGems: 'hidden_gems',
  CuratedListType.budgetFriendly: 'budget_friendly',
  CuratedListType.adventure: 'adventure',
  CuratedListType.cultural: 'cultural',
  CuratedListType.beach: 'beach',
  CuratedListType.urban: 'urban',
  CuratedListType.nature: 'nature',
  CuratedListType.food: 'food',
  CuratedListType.wellness: 'wellness',
  CuratedListType.seasonal: 'seasonal',
  CuratedListType.custom: 'custom',
};
