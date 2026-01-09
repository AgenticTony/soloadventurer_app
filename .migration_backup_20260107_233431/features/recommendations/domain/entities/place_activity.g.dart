// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaceActivity _$PlaceActivityFromJson(Map<String, dynamic> json) =>
    _PlaceActivity(
      id: json['id'] as String,
      name: json['name'] as String,
      category: $enumDecode(_$RecommendationCategoryEnumMap, json['category']),
      description: json['description'] as String?,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      priceLevel: json['priceLevel'] as String?,
      cost: (json['cost'] as num?)?.toDouble(),
      estimatedDuration: json['estimatedDuration'] == null
          ? null
          : Duration(microseconds: (json['estimatedDuration'] as num).toInt()),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      localTips: (json['localTips'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      bookingUrl: json['bookingUrl'] as String?,
      requiresBooking: json['requiresBooking'] as bool? ?? false,
      openingHours: json['openingHours'] as String?,
    );

Map<String, dynamic> _$PlaceActivityToJson(_PlaceActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': _$RecommendationCategoryEnumMap[instance.category]!,
      'description': instance.description,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'priceLevel': instance.priceLevel,
      'cost': instance.cost,
      'estimatedDuration': instance.estimatedDuration?.inMicroseconds,
      'images': instance.images,
      'tags': instance.tags,
      'localTips': instance.localTips,
      'bookingUrl': instance.bookingUrl,
      'requiresBooking': instance.requiresBooking,
      'openingHours': instance.openingHours,
    };

const _$RecommendationCategoryEnumMap = {
  RecommendationCategory.food: 'food',
  RecommendationCategory.attraction: 'attraction',
  RecommendationCategory.activity: 'activity',
  RecommendationCategory.entertainment: 'entertainment',
  RecommendationCategory.shopping: 'shopping',
  RecommendationCategory.wellness: 'wellness',
  RecommendationCategory.culture: 'culture',
  RecommendationCategory.adventure: 'adventure',
};
