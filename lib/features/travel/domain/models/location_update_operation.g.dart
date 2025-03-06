// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_update_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationUpdateOperationImpl _$$LocationUpdateOperationImplFromJson(
        Map<String, dynamic> json) =>
    _$LocationUpdateOperationImpl(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      priority: (json['priority'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$LocationUpdateOperationImplToJson(
        _$LocationUpdateOperationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timestamp': instance.timestamp.toIso8601String(),
      'priority': instance.priority,
    };
