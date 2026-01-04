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
      priority: (json['priority'] as num?)?.toInt() ?? OperationPriority.low,
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

Map<String, dynamic> _$$LocationUpdateOperationImplToJson(
        _$LocationUpdateOperationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timestamp': instance.timestamp.toIso8601String(),
      'priority': instance.priority,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastAttempt': instance.lastAttempt?.toIso8601String(),
      'attemptCount': instance.attemptCount,
      'lastError': instance.lastError,
      'maxRetries': instance.maxRetries,
    };
