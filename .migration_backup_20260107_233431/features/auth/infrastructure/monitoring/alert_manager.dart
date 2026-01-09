import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:aws_cloudwatch/aws_cloudwatch.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../logging/token_audit_logger.dart';
import '../../domain/entities/security_alert.dart';
import '../../domain/repositories/alert_repository.dart';

part 'alert_manager.g.dart';

/// Configuration for security alerts
class AlertConfig {
  /// Threshold for failed token refresh attempts
  static const int failedRefreshThreshold = 3;

  /// Time window for evaluating failed attempts (minutes)
  static const int evaluationPeriod = 5;

  /// Threshold for suspicious activity alerts
  static const int suspiciousActivityThreshold = 2;

  /// Threshold for concurrent device usage
  static const int concurrentDeviceThreshold = 3;

  /// Rate limit violation threshold
  static const int rateLimitViolationThreshold = 5;

  /// Token revocation alert threshold
  static const int revocationThreshold = 1;
}

/// Provider for CloudWatch client
@riverpod
CloudWatch cloudWatchClient(Ref ref) {
  return CloudWatch(
    awsAccessKey: dotenv.env['AWS_ACCESS_KEY_ID'] ?? '',
    awsSecretKey: dotenv.env['AWS_SECRET_ACCESS_KEY'] ?? '',
    region: dotenv.env['AWS_REGION'] ?? 'us-east-1',
    groupName: 'SoloAdventurer/TokenSecurity',
    streamName: 'SecurityAlerts',
  );
}

/// Manager responsible for handling security alerts and notifications
@riverpod
class AlertManager extends _$AlertManager implements AlertRepository {
  late final CloudWatch _cloudWatch;
  bool _isInitialized = false;

  @override
  FutureOr<void> build() async {
    _cloudWatch = ref.watch(cloudWatchClientProvider);

    if (!_isInitialized) {
      await _initialize();
      _isInitialized = true;
    }
  }

  /// Initialize alert infrastructure
  Future<void> _initialize() async {
    try {
      ref.read(tokenAuditLoggerProvider).logTokenEvent(
        event: 'alert_manager_initialized',
        status: 'info',
        metadata: {
          'failed_refresh_threshold': AlertConfig.failedRefreshThreshold,
          'evaluation_period': AlertConfig.evaluationPeriod,
          'suspicious_activity_threshold':
              AlertConfig.suspiciousActivityThreshold,
        },
      );
    } catch (e, stack) {
      ref.read(tokenAuditLoggerProvider).logError(
            feature: 'alert_manager',
            error: e.toString(),
            code: 'initialization_failed',
            stackTrace: stack,
          );
      rethrow;
    }
  }

  /// Send a security alert through CloudWatch
  @override
  Future<void> sendAlert(SecurityAlert alert) async {
    try {
      final logMessage = {
        'type': alert.type.toString(),
        'severity': alert.severity.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'details': alert.toJson(),
      };

      await _cloudWatch.log(logMessage.toString());

      ref.read(tokenAuditLoggerProvider).logTokenEvent(
            event: 'security_alert_sent',
            status: 'warning',
            metadata: alert.toJson(),
          );
    } catch (e, stack) {
      ref.read(tokenAuditLoggerProvider).logError(
            feature: 'alert_manager',
            error: e.toString(),
            code: 'send_alert_failed',
            stackTrace: stack,
          );
      rethrow;
    }
  }

  /// Test CloudWatch logging
  Future<void> testCloudWatchLogging() async {
    try {
      final testMessage = {
        'type': 'TEST_ALERT',
        'severity': 'INFO',
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'This is a test alert from the Flutter app',
      };

      await _cloudWatch.log(testMessage.toString());

      ref.read(tokenAuditLoggerProvider).logTokenEvent(
        event: 'test_alert_sent',
        status: 'info',
        metadata: {'message': 'Test alert sent successfully'},
      );
    } catch (e, stack) {
      ref.read(tokenAuditLoggerProvider).logError(
            feature: 'alert_manager',
            error: e.toString(),
            code: 'test_alert_failed',
            stackTrace: stack,
          );
      rethrow;
    }
  }
}
