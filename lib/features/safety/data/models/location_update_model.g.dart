// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationUpdateModel _$LocationUpdateModelFromJson(Map<String, dynamic> json) =>
    _LocationUpdateModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      placeName: json['placeName'] as String?,
      batteryLevel: (json['batteryLevel'] as num?)?.toInt(),
      sharingStatus:
          $enumDecode(_$LocationSharingStatusEnumMap, json['sharingStatus']),
      sharedWithContactIds: (json['sharedWithContactIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      emergency: json['emergency'] as bool? ?? false,
      checkInId: json['checkInId'] as String?,
      alertId: json['alertId'] as String?,
      tripId: json['tripId'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LocationUpdateModelToJson(
        _LocationUpdateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'altitude': instance.altitude,
      'address': instance.address,
      'placeName': instance.placeName,
      'batteryLevel': instance.batteryLevel,
      'sharingStatus': _$LocationSharingStatusEnumMap[instance.sharingStatus]!,
      'sharedWithContactIds': instance.sharedWithContactIds,
      'emergency': instance.emergency,
      'checkInId': instance.checkInId,
      'alertId': instance.alertId,
      'tripId': instance.tripId,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$LocationSharingStatusEnumMap = {
  LocationSharingStatus.active: 'active',
  LocationSharingStatus.paused: 'paused',
  LocationSharingStatus.ended: 'ended',
};
