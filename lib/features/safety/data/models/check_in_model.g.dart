// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckInModelImpl _$$CheckInModelImplFromJson(Map<String, dynamic> json) =>
    _$CheckInModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      triggerType:
          $enumDecode(_$CheckInTriggerTypeEnumMap, json['triggerType']),
      status: $enumDecode(_$CheckInStatusEnumMap, json['status']),
      scheduledTime: json['scheduledTime'] == null
          ? null
          : DateTime.parse(json['scheduledTime'] as String),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      location: json['location'] == null
          ? null
          : CheckInLocation.fromJson(json['location'] as Map<String, dynamic>),
      statusMessage: json['statusMessage'] as String?,
      tripId: json['tripId'] as String?,
      notifyContactIds: (json['notifyContactIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      alertSent: json['alertSent'] as bool? ?? false,
      alertSentAt: json['alertSentAt'] == null
          ? null
          : DateTime.parse(json['alertSentAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CheckInModelImplToJson(_$CheckInModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'triggerType': _$CheckInTriggerTypeEnumMap[instance.triggerType]!,
      'status': _$CheckInStatusEnumMap[instance.status]!,
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
      'deadline': instance.deadline?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'location': instance.location,
      'statusMessage': instance.statusMessage,
      'tripId': instance.tripId,
      'notifyContactIds': instance.notifyContactIds,
      'alertSent': instance.alertSent,
      'alertSentAt': instance.alertSentAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$CheckInTriggerTypeEnumMap = {
  CheckInTriggerType.manual: 'manual',
  CheckInTriggerType.scheduledTime: 'scheduledTime',
  CheckInTriggerType.locationArrival: 'locationArrival',
  CheckInTriggerType.locationDeparture: 'locationDeparture',
};

const _$CheckInStatusEnumMap = {
  CheckInStatus.scheduled: 'scheduled',
  CheckInStatus.active: 'active',
  CheckInStatus.completed: 'completed',
  CheckInStatus.missed: 'missed',
  CheckInStatus.cancelled: 'cancelled',
};
