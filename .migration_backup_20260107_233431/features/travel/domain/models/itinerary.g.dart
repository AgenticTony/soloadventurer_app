// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Itinerary _$ItineraryFromJson(Map<String, dynamic> json) => _Itinerary(
      id: json['id'] as String,
      name: json['name'] as String,
      destination:
          Destination.fromJson(json['destination'] as Map<String, dynamic>),
      dateRange: DateRange.fromJson(json['dateRange'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((e) => ItineraryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      isStarter: json['isStarter'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
    );

Map<String, dynamic> _$ItineraryToJson(_Itinerary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'destination': instance.destination,
      'dateRange': instance.dateRange,
      'items': instance.items,
      'isStarter': instance.isStarter,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'userId': instance.userId,
      'coverImageUrl': instance.coverImageUrl,
    };
