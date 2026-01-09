// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Destination _$DestinationFromJson(Map<String, dynamic> json) => _Destination(
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      airportCode: json['airportCode'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$DestinationToJson(_Destination instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'name': instance.name,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'airportCode': instance.airportCode,
      'country': instance.country,
      'city': instance.city,
      'imageUrl': instance.imageUrl,
    };
