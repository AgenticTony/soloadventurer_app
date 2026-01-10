// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Photo _$PhotoFromJson(Map<String, dynamic> json) => _Photo(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      caption: json['caption'] as String?,
      tripId: json['tripId'] as String,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      takenAt: DateTime.parse(json['takenAt'] as String),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      sizeInBytes: (json['sizeInBytes'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PhotoToJson(_Photo instance) => <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'caption': instance.caption,
      'tripId': instance.tripId,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'takenAt': instance.takenAt.toIso8601String(),
      'width': instance.width,
      'height': instance.height,
      'sizeInBytes': instance.sizeInBytes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
