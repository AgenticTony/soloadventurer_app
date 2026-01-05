// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SafetyStatusImpl _$$SafetyStatusImplFromJson(Map<String, dynamic> json) =>
    _$SafetyStatusImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      status: $enumDecode(_$SafetyStatusTypeEnumMap, json['status']),
      message: json['message'] as String?,
      location: json['location'] == null
          ? null
          : SafetyStatusLocation.fromJson(
              json['location'] as Map<String, dynamic>),
      batteryLevel: (json['batteryLevel'] as num?)?.toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      safetyAlertId: json['safetyAlertId'] as String?,
      checkInId: json['checkInId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SafetyStatusImplToJson(_$SafetyStatusImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'status': _$SafetyStatusTypeEnumMap[instance.status]!,
      'message': instance.message,
      'location': instance.location,
      'batteryLevel': instance.batteryLevel,
      'timestamp': instance.timestamp.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'safetyAlertId': instance.safetyAlertId,
      'checkInId': instance.checkInId,
      'metadata': instance.metadata,
    };

const _$SafetyStatusTypeEnumMap = {
  SafetyStatusType.safe: 'safe',
  SafetyStatusType.needHelp: 'needHelp',
  SafetyStatusType.emergency: 'emergency',
  SafetyStatusType.unknown: 'unknown',
};

_$SafetyStatusLocationImpl _$$SafetyStatusLocationImplFromJson(
        Map<String, dynamic> json) =>
    _$SafetyStatusLocationImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      placeName: json['placeName'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$SafetyStatusLocationImplToJson(
        _$SafetyStatusLocationImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'altitude': instance.altitude,
      'address': instance.address,
      'placeName': instance.placeName,
      'timestamp': instance.timestamp.toIso8601String(),
    };
