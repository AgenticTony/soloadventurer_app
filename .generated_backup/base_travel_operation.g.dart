// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_travel_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BaseTravelOperationImpl _$$BaseTravelOperationImplFromJson(
        Map<String, dynamic> json) =>
    _$BaseTravelOperationImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      priority: (json['priority'] as num?)?.toInt() ?? 1,
      requiresNetwork: json['requiresNetwork'] as bool? ?? true,
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$BaseTravelOperationImplToJson(
        _$BaseTravelOperationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'timestamp': instance.timestamp.toIso8601String(),
      'priority': instance.priority,
      'requiresNetwork': instance.requiresNetwork,
      'data': instance.data,
    };
