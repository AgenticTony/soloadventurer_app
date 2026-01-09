// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_travel_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BaseTravelOperation _$BaseTravelOperationFromJson(Map<String, dynamic> json) =>
    _BaseTravelOperation(
      id: json['id'] as String,
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      priority: json['priority'] == null
          ? OperationPriority.low
          : const OperationPriorityConverter()
              .fromJson((json['priority'] as num).toInt()),
      requiresNetwork: json['requiresNetwork'] as bool? ?? true,
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$BaseTravelOperationToJson(
        _BaseTravelOperation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'timestamp': instance.timestamp.toIso8601String(),
      'priority': const OperationPriorityConverter().toJson(instance.priority),
      'requiresNetwork': instance.requiresNetwork,
      'data': instance.data,
    };
