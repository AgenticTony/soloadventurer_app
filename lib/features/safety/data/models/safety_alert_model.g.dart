// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SafetyAlertModel _$SafetyAlertModelFromJson(Map<String, dynamic> json) =>
    _SafetyAlertModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$SafetyAlertTypeEnumMap, json['type']),
      status: $enumDecode(_$SafetyAlertStatusEnumMap, json['status']),
      message: json['message'] as String?,
      location: json['location'] == null
          ? null
          : SafetyAlertLocation.fromJson(
              json['location'] as Map<String, dynamic>),
      notifiedContactIds: (json['notifiedContactIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      acknowledgedByContactIds:
          (json['acknowledgedByContactIds'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      triggeredAt: DateTime.parse(json['triggeredAt'] as String),
      firstAcknowledgedAt: json['firstAcknowledgedAt'] == null
          ? null
          : DateTime.parse(json['firstAcknowledgedAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      batteryLevel: (json['batteryLevel'] as num?)?.toInt(),
      checkInId: json['checkInId'] as String?,
      tripId: json['tripId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SafetyAlertModelToJson(_SafetyAlertModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$SafetyAlertTypeEnumMap[instance.type]!,
      'status': _$SafetyAlertStatusEnumMap[instance.status]!,
      'message': instance.message,
      'location': instance.location,
      'notifiedContactIds': instance.notifiedContactIds,
      'acknowledgedByContactIds': instance.acknowledgedByContactIds,
      'triggeredAt': instance.triggeredAt.toIso8601String(),
      'firstAcknowledgedAt': instance.firstAcknowledgedAt?.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'batteryLevel': instance.batteryLevel,
      'checkInId': instance.checkInId,
      'tripId': instance.tripId,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$SafetyAlertTypeEnumMap = {
  SafetyAlertType.emergencySOS: 'emergencySOS',
  SafetyAlertType.needHelp: 'needHelp',
  SafetyAlertType.emergency: 'emergency',
  SafetyAlertType.missedCheckIn: 'missedCheckIn',
  SafetyAlertType.locationUpdate: 'locationUpdate',
  SafetyAlertType.safe: 'safe',
};

const _$SafetyAlertStatusEnumMap = {
  SafetyAlertStatus.sent: 'sent',
  SafetyAlertStatus.acknowledged: 'acknowledged',
  SafetyAlertStatus.resolved: 'resolved',
  SafetyAlertStatus.cancelled: 'cancelled',
};
