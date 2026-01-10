// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceActivityImpl _$$PlaceActivityImplFromJson(Map<String, dynamic> json) =>
    _$PlaceActivityImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      isIndoor: json['isIndoor'] as bool? ?? false,
      estimatedDuration: (json['estimatedDuration'] as num?)?.toInt(),
      recommendedTime: json['recommendedTime'] as String?,
      cost: (json['cost'] as num?)?.toDouble(),
      bookingUrl: json['bookingUrl'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$$PlaceActivityImplToJson(_$PlaceActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'isIndoor': instance.isIndoor,
      'estimatedDuration': instance.estimatedDuration,
      'recommendedTime': instance.recommendedTime,
      'cost': instance.cost,
      'bookingUrl': instance.bookingUrl,
      'photoUrl': instance.photoUrl,
    };
