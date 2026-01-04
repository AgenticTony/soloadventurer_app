// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_planning_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripPlanningOperationImpl _$$TripPlanningOperationImplFromJson(
        Map<String, dynamic> json) =>
    _$TripPlanningOperationImpl(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      planningType:
          $enumDecode(_$TripPlanningTypeEnumMap, json['planningType']),
      changes: json['changes'] as Map<String, dynamic>,
      priority: (json['priority'] as num?)?.toInt() ?? OperationPriority.normal,
      plannedStartDate: json['plannedStartDate'] == null
          ? null
          : DateTime.parse(json['plannedStartDate'] as String),
      plannedEndDate: json['plannedEndDate'] == null
          ? null
          : DateTime.parse(json['plannedEndDate'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastAttempt: json['lastAttempt'] == null
          ? null
          : DateTime.parse(json['lastAttempt'] as String),
      attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
      lastError: json['lastError'] as String?,
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
    );

Map<String, dynamic> _$$TripPlanningOperationImplToJson(
        _$TripPlanningOperationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'planningType': _$TripPlanningTypeEnumMap[instance.planningType]!,
      'changes': instance.changes,
      'priority': instance.priority,
      'plannedStartDate': instance.plannedStartDate?.toIso8601String(),
      'plannedEndDate': instance.plannedEndDate?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastAttempt': instance.lastAttempt?.toIso8601String(),
      'attemptCount': instance.attemptCount,
      'lastError': instance.lastError,
      'maxRetries': instance.maxRetries,
    };

const _$TripPlanningTypeEnumMap = {
  TripPlanningType.create: 'create',
  TripPlanningType.update: 'update',
  TripPlanningType.delete: 'delete',
  TripPlanningType.addDestination: 'addDestination',
  TripPlanningType.removeDestination: 'removeDestination',
  TripPlanningType.updateDates: 'updateDates',
};
