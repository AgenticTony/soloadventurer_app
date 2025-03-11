import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:aws_cloudwatch_api/aws_cloudwatch_api.dart';
import 'package:aws_sns_api/aws_sns_api.dart';
import 'package:aws_common/aws_common.dart';
import '../logging/token_audit_logger.dart';
import './aws_cloudwatch_monitoring.dart';
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

/// AWS credentials provider
@riverpod
AWSCredentials awsCredentials(AwsCredentialsRef ref) {
  return AWSCredentials(
    accessKeyId: const String.fromEnvironment('AWS_ACCESS_KEY_ID'),
    secretAccessKey: const String.fromEnvironment('AWS_SECRET_ACCESS_KEY'),
    region:
        const String.fromEnvironment('AWS_REGION', defaultValue: 'us-east-1'),
  );
}

/// Provider for CloudWatch client
@riverpod
CloudWatchClient cloudWatchClient(CloudWatchClientRef ref) {
  final credentials = ref.watch(awsCredentialsProvider);
  return CloudWatchClient(credentials: credentials);
}

/// Provider for SNS client
@riverpod
SNSClient snsClient(SNSClientRef ref) {
  final credentials = ref.watch(awsCredentialsProvider);
  return SNSClient(credentials: credentials);
}

/// Manager responsible for handling security alerts and notifications
@riverpod
class AlertManager extends _$AlertManager implements AlertRepository {
  late final CloudWatchClient _cloudWatch;
  late final SNSClient _sns;
  String? _topicArn;
  bool _isInitialized = false;

  @override
  FutureOr<void> build() async {
    _cloudWatch = ref.watch(cloudWatchClientProvider);
    _sns = ref.watch(snsClientProvider);

    if (!_isInitialized) {
      await _initialize();
      _isInitialized = true;
    }
  }

  /// Initialize alert infrastructure
  Future<void> _initialize() async {
    try {
      await _setupCloudWatchAlarms();
      await _configureSnsNotifications();

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

  /// Set up CloudWatch alarms for security monitoring
  Future<void> _setupCloudWatchAlarms() async {
    final alarms = [
      _createAlarm(
        name: 'FailedTokenRefreshAlarm',
        metric: 'FailedTokenRefreshCount',
        threshold: AlertConfig.failedRefreshThreshold,
      ),
      _createAlarm(
        name: 'SuspiciousActivityAlarm',
        metric: 'SuspiciousActivityCount',
        threshold: AlertConfig.suspiciousActivityThreshold,
      ),
      _createAlarm(
        name: 'ConcurrentDeviceUsageAlarm',
        metric: 'ConcurrentDeviceCount',
        threshold: AlertConfig.concurrentDeviceThreshold,
      ),
      _createAlarm(
        name: 'RateLimitViolationAlarm',
        metric: 'RateLimitViolationCount',
        threshold: AlertConfig.rateLimitViolationThreshold,
      ),
      _createAlarm(
        name: 'TokenRevocationAlarm',
        metric: 'TokenRevocationCount',
        threshold: AlertConfig.revocationThreshold,
      ),
    ];

    await Future.wait(alarms);
  }

  /// Create a CloudWatch alarm with specified parameters
  Future<void> _createAlarm({
    required String name,
    required String metric,
    required int threshold,
  }) async {
    final alarm = PutMetricAlarmRequest(
      alarmName: name,
      metricName: metric,
      namespace: 'SoloAdventurer/TokenSecurity',
      period: AlertConfig.evaluationPeriod * 60,
      evaluationPeriods: 1,
      threshold: threshold.toDouble(),
      comparisonOperator: ComparisonOperator.greaterThanOrEqualToThreshold,
      statistic: Statistic.sum,
      actionsEnabled: true,
      alarmActions: [_topicArn!],
    );

    await _cloudWatch.putMetricAlarm(alarm);
  }

  /// Configure SNS notifications for alerts
  Future<void> _configureSnsNotifications() async {
    try {
      // Create SNS topic if it doesn't exist
      final response = await _sns.createTopic(
        CreateTopicRequest(
          name: 'SoloAdventurer-SecurityAlerts',
        ),
      );
      _topicArn = response.topicArn;

      // Configure topic policies and subscriptions
      await Future.wait([
        _sns.subscribe(
          SubscribeRequest(
            topicArn: _topicArn!,
            protocol: 'email',
            endpoint: const String.fromEnvironment('SECURITY_EMAIL'),
          ),
        ),
        if (const String.fromEnvironment('SECURITY_PHONE') != '')
          _sns.subscribe(
            SubscribeRequest(
              topicArn: _topicArn!,
              protocol: 'sms',
              endpoint: const String.fromEnvironment('SECURITY_PHONE'),
            ),
          ),
      ]);
    } catch (e, stack) {
      ref.read(tokenAuditLoggerProvider).logError(
            feature: 'alert_manager',
            error: e.toString(),
            code: 'sns_configuration_failed',
            stackTrace: stack,
          );
      rethrow;
    }
  }

  /// Send a security alert through configured channels
  @override
  Future<void> sendAlert(SecurityAlert alert) async {
    try {
      await _sns.publish(
        PublishRequest(
          topicArn: _topicArn!,
          message: alert.toString(),
          subject: 'Security Alert: ${alert.type}',
          messageAttributes: {
            'AlertType': MessageAttributeValue(
              dataType: 'String',
              stringValue: alert.type.toString(),
            ),
            'Severity': MessageAttributeValue(
              dataType: 'String',
              stringValue: alert.severity.toString(),
            ),
            'Timestamp': MessageAttributeValue(
              dataType: 'String',
              stringValue: DateTime.now().toIso8601String(),
            ),
          },
        ),
      );

      ref.read(tokenAuditLoggerProvider).logTokenEvent(
            event: 'security_alert_sent',
            status: 'warning',
            metadata: alert.toJson(),
          );

      // Record alert metric
      await _recordMetric(
        'SecurityAlerts',
        1.0,
        dimensions: {
          'Type': alert.type.toString(),
          'Severity': alert.severity.toString(),
        },
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

  /// Record a metric to CloudWatch
  Future<void> _recordMetric(
    String metricName,
    double value, {
    Map<String, String>? dimensions,
  }) async {
    try {
      final request = PutMetricDataRequest(
        namespace: 'SoloAdventurer/TokenSecurity',
        metricData: [
          MetricDatum(
            metricName: metricName,
            value: value,
            timestamp: DateTime.now(),
            dimensions: dimensions?.entries
                .map((e) => Dimension(
                      name: e.key,
                      value: e.value,
                    ))
                .toList(),
          ),
        ],
      );

      await _cloudWatch.putMetricData(request);
    } catch (e, stack) {
      ref.read(tokenAuditLoggerProvider).logError(
            feature: 'alert_manager',
            error: e.toString(),
            code: 'record_metric_failed',
            stackTrace: stack,
          );
    }
  }
}
