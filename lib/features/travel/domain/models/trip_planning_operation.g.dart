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
      priority: (json['priority'] as num?)?.toInt() ?? 2,
      plannedStartDate: json['plannedStartDate'] == null
          ? null
          : DateTime.parse(json['plannedStartDate'] as String),
      plannedEndDate: json['plannedEndDate'] == null
          ? null
          : DateTime.parse(json['plannedEndDate'] as String),
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
    };

const _$TripPlanningTypeEnumMap = {
  TripPlanningType.create: 'create',
  TripPlanningType.update: 'update',
  TripPlanningType.delete: 'delete',
  TripPlanningType.addDestination: 'addDestination',
  TripPlanningType.removeDestination: 'removeDestination',
  TripPlanningType.updateDates: 'updateDates',
};
