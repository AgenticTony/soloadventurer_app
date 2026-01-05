// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationUpdateImpl _$$LocationUpdateImplFromJson(Map<String, dynamic> json) =>
    _$LocationUpdateImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      address: json['address'] as String?,
      placeName: json['placeName'] as String?,
      sharingStatus:
          $enumDecode(_$LocationSharingStatusEnumMap, json['sharingStatus']),
      sharedWithContactIds: (json['sharedWithContactIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      batteryLevel: (json['batteryLevel'] as num?)?.toInt(),
      isEmergency: json['isEmergency'] as bool? ?? false,
      emergencyAlertId: json['emergencyAlertId'] as String?,
      checkInId: json['checkInId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LocationUpdateImplToJson(
        _$LocationUpdateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'altitude': instance.altitude,
      'speed': instance.speed,
      'heading': instance.heading,
      'address': instance.address,
      'placeName': instance.placeName,
      'sharingStatus': _$LocationSharingStatusEnumMap[instance.sharingStatus]!,
      'sharedWithContactIds': instance.sharedWithContactIds,
      'batteryLevel': instance.batteryLevel,
      'isEmergency': instance.isEmergency,
      'emergencyAlertId': instance.emergencyAlertId,
      'checkInId': instance.checkInId,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$LocationSharingStatusEnumMap = {
  LocationSharingStatus.active: 'active',
  LocationSharingStatus.paused: 'paused',
  LocationSharingStatus.ended: 'ended',
};
