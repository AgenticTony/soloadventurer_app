// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SecurityAlertImpl _$$SecurityAlertImplFromJson(Map<String, dynamic> json) =>
    _$SecurityAlertImpl(
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SecurityAlertImplToJson(_$SecurityAlertImpl instance) =>
    <String, dynamic>{
      'type': _$AlertTypeEnumMap[instance.type]!,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'userId': instance.userId,
      'metadata': instance.metadata,
    };

const _$AlertTypeEnumMap = {
  AlertType.failedTokenRefresh: 'failedTokenRefresh',
  AlertType.suspiciousActivity: 'suspiciousActivity',
  AlertType.concurrentDeviceUsage: 'concurrentDeviceUsage',
  AlertType.rateLimitViolation: 'rateLimitViolation',
  AlertType.tokenRevocation: 'tokenRevocation',
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 'low',
  AlertSeverity.medium: 'medium',
  AlertSeverity.high: 'high',
  AlertSeverity.critical: 'critical',
};
