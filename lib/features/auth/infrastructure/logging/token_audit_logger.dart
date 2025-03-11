import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../features/core/domain/services/logging_service.dart';
import '../../../../features/core/infrastructure/monitoring/aws_cloudwatch_monitoring.dart';
import '../../domain/models/auth_session.dart';

part 'token_audit_logger.g.dart';

/// Provides comprehensive audit logging for token operations
@riverpod
LoggingService tokenAuditLogger(TokenAuditLoggerRef ref) {
  final monitoring = ref.watch(awsCloudWatchMonitoringProvider);
  return _TokenAuditLoggerImpl(monitoring);
}

class _TokenAuditLoggerImpl implements LoggingService {
  final AwsCloudWatchMonitoring _monitoring;
  static const String _logPrefix = '[TokenAudit]';

  _TokenAuditLoggerImpl(this._monitoring);

  /// Log token lifecycle events with detailed metadata
  @override
  void logTokenEvent({
    required String event,
    required String status,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logData = {
      'timestamp': timestamp,
      'type': 'TokenEvent',
      'event': event,
      'status': status,
      if (metadata != null) ...metadata,
      if (stackTrace != null) 'stack_trace': stackTrace.toString(),
    };

    // Log to CloudWatch
    _monitoring.recordEvent(
      'TokenOperation',
      attributes: logData,
    );

    // Debug logging
    debugPrint('$_logPrefix Token Event: $logData');
  }

  /// Log token rotation events
  void logTokenRotation({
    required AuthSession oldSession,
    required AuthSession newSession,
    String? reason,
  }) {
    final metadata = {
      'operation': 'token_rotation',
      'old_token_expiry': oldSession.expiresAt.toIso8601String(),
      'new_token_expiry': newSession.expiresAt.toIso8601String(),
      if (reason != null) 'reason': reason,
    };

    logTokenEvent(
      event: 'token_rotation',
      status: 'success',
      metadata: metadata,
    );
  }

  /// Log token blacklist events
  void logTokenBlacklist({
    required String token,
    required String reason,
    DateTime? expiryTime,
  }) {
    final metadata = {
      'operation': 'token_blacklist',
      'reason': reason,
      if (expiryTime != null) 'expiry_time': expiryTime.toIso8601String(),
    };

    logTokenEvent(
      event: 'token_blacklist',
      status: 'success',
      metadata: metadata,
    );
  }

  /// Log token validation events
  void logTokenValidation({
    required bool isValid,
    required String reason,
    Map<String, dynamic>? additionalInfo,
  }) {
    final metadata = {
      'operation': 'token_validation',
      'is_valid': isValid,
      'reason': reason,
      if (additionalInfo != null) ...additionalInfo,
    };

    logTokenEvent(
      event: 'token_validation',
      status: isValid ? 'success' : 'failure',
      metadata: metadata,
    );
  }

  /// Log token refresh attempts
  void logTokenRefresh({
    required bool success,
    String? error,
    int attemptNumber = 1,
    Map<String, dynamic>? additionalInfo,
  }) {
    final metadata = {
      'operation': 'token_refresh',
      'attempt_number': attemptNumber,
      if (error != null) 'error': error,
      if (additionalInfo != null) ...additionalInfo,
    };

    logTokenEvent(
      event: 'token_refresh',
      status: success ? 'success' : 'failure',
      metadata: metadata,
    );
  }

  /// Log security-related token events
  void logTokenSecurity({
    required String event,
    required String severity,
    String? threat,
    Map<String, dynamic>? securityContext,
  }) {
    final metadata = {
      'operation': 'token_security',
      'security_event': event,
      'severity': severity,
      if (threat != null) 'threat': threat,
      if (securityContext != null) ...securityContext,
    };

    logTokenEvent(
      event: 'security_event',
      status: 'alert',
      metadata: metadata,
    );

    // For high-severity security events, also record a metric
    if (severity == 'high') {
      _monitoring.recordMetric(
        'SecurityEvent',
        1.0,
        dimensions: {
          'EventType': event,
          'Severity': severity,
        },
      );
    }
  }

  @override
  void logStateTransition({
    required String feature,
    required String fromState,
    required String toState,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    final logData = {
      'feature': feature,
      'from_state': fromState,
      'to_state': toState,
      if (metadata != null) ...metadata,
    };

    logTokenEvent(
      event: 'state_transition',
      status: 'info',
      metadata: logData,
      stackTrace: stackTrace,
    );
  }

  @override
  void logError({
    required String feature,
    required String error,
    String? code,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    final logData = {
      'feature': feature,
      'error': error,
      if (code != null) 'code': code,
      if (metadata != null) ...metadata,
    };

    logTokenEvent(
      event: 'error',
      status: 'error',
      metadata: logData,
      stackTrace: stackTrace,
    );

    // Also record error metric
    _monitoring.recordMetric(
      'TokenError',
      1.0,
      dimensions: {
        'Feature': feature,
        'ErrorCode': code ?? 'unknown',
      },
    );
  }

  @override
  void logAuthEvent({
    required String event,
    required String status,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    final logData = {
      'auth_event': event,
      if (metadata != null) ...metadata,
    };

    logTokenEvent(
      event: 'auth_event',
      status: status,
      metadata: logData,
      stackTrace: stackTrace,
    );
  }
}
