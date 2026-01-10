// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SafetyStatusModelImpl _$$SafetyStatusModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SafetyStatusModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      statusType: $enumDecode(_$SafetyStatusTypeEnumMap, json['statusType']),
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

Map<String, dynamic> _$$SafetyStatusModelImplToJson(
        _$SafetyStatusModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'statusType': _$SafetyStatusTypeEnumMap[instance.statusType]!,
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
