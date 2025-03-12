import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aws_cloudwatch_api/cloudwatch-2010-08-01.dart' as aws;
import 'package:shared_aws_api/shared.dart';
import './monitoring_service.dart';

part 'aws_cloudwatch_monitoring.g.dart';

/// Provider for AWS CloudWatch monitoring service
@riverpod
AwsCloudWatchMonitoring awsCloudWatchMonitoring(
    AwsCloudWatchMonitoringRef ref) {
  final cloudWatch = CloudWatch(
    region: dotenv.env['AWS_REGION'] ?? 'us-east-1',
    accessKeyId: dotenv.env['AWS_ACCESS_KEY_ID'] ?? '',
    secretAccessKey: dotenv.env['AWS_SECRET_ACCESS_KEY'] ?? '',
  );

  return AwsCloudWatchMonitoring(
    cloudWatch: cloudWatch,
    namespace: 'SoloAdventurer/TokenSecurity',
  );
}

/// CloudWatch wrapper class
class CloudWatch {
  final String region;
  final String accessKeyId;
  final String secretAccessKey;
  late final aws.CloudWatch _client;

  CloudWatch({
    required this.region,
    required this.accessKeyId,
    required this.secretAccessKey,
  }) {
    _client = aws.CloudWatch(
      region: region,
      credentials: AwsClientCredentials(
        accessKey: accessKeyId,
        secretKey: secretAccessKey,
      ),
    );
  }

  Future<void> putMetricData({
    required String namespace,
    required List<MetricDatum> metricData,
  }) async {
    try {
      final request = aws.PutMetricDataInput(
        namespace: namespace,
        metricData: metricData
            .map((datum) => aws.MetricDatum(
                  metricName: datum.metricName,
                  value: datum.value,
                  dimensions: datum.dimensions
                      ?.map((d) => aws.Dimension(
                            name: d.name,
                            value: d.value,
                          ))
                      .toList(),
                  timestamp: datum.timestamp,
                ))
            .toList(),
      );

      await _client.putMetricData(request);
    } catch (e) {
      debugPrint('Failed to put metric data to CloudWatch: $e');
      rethrow;
    }
  }
}

class MetricDatum {
  final String metricName;
  final double value;
  final List<Dimension>? dimensions;
  final DateTime timestamp;

  MetricDatum({
    required this.metricName,
    required this.value,
    this.dimensions,
    required this.timestamp,
  });
}

class Dimension {
  final String name;
  final String value;

  Dimension({
    required this.name,
    required this.value,
  });
}

/// Implementation of [MonitoringService] using AWS CloudWatch
class AwsCloudWatchMonitoring implements MonitoringService {
  final CloudWatch _cloudWatch;
  final String _namespace;
  final Map<String, DateTime> _timers = {};

  AwsCloudWatchMonitoring({
    required CloudWatch cloudWatch,
    required String namespace,
  })  : _cloudWatch = cloudWatch,
        _namespace = namespace;

  @override
  Future<void> logError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    try {
      await _cloudWatch.putMetricData(
        namespace: _namespace,
        metricData: [
          MetricDatum(
            metricName: 'Error',
            value: 1.0,
            dimensions: [
              Dimension(
                name: 'ErrorType',
                value: error.runtimeType.toString(),
              ),
            ],
            timestamp: DateTime.now(),
          ),
        ],
      );

      debugPrint('Error logged to CloudWatch: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    } catch (e) {
      debugPrint('Failed to log error to CloudWatch: $e');
    }
  }

  @override
  Future<void> logWarning(
    String message, {
    Map<String, dynamic>? context,
  }) async {
    try {
      await _cloudWatch.putMetricData(
        namespace: _namespace,
        metricData: [
          MetricDatum(
            metricName: 'Warning',
            value: 1.0,
            dimensions: _contextToDimensions(context),
            timestamp: DateTime.now(),
          ),
        ],
      );

      debugPrint('Warning logged to CloudWatch: $message');
    } catch (e) {
      debugPrint('Failed to log warning to CloudWatch: $e');
    }
  }

  @override
  Future<void> logInfo(
    String message, {
    Map<String, dynamic>? context,
  }) async {
    try {
      await _cloudWatch.putMetricData(
        namespace: _namespace,
        metricData: [
          MetricDatum(
            metricName: 'Info',
            value: 1.0,
            dimensions: _contextToDimensions(context),
            timestamp: DateTime.now(),
          ),
        ],
      );

      debugPrint('Info logged to CloudWatch: $message');
    } catch (e) {
      debugPrint('Failed to log info to CloudWatch: $e');
    }
  }

  @override
  Future<void> logDebug(
    String message, {
    Map<String, dynamic>? context,
  }) async {
    // Only log debug messages in debug mode
    if (kDebugMode) {
      try {
        await _cloudWatch.putMetricData(
          namespace: _namespace,
          metricData: [
            MetricDatum(
              metricName: 'Debug',
              value: 1.0,
              dimensions: _contextToDimensions(context),
              timestamp: DateTime.now(),
            ),
          ],
        );

        debugPrint('Debug logged to CloudWatch: $message');
      } catch (e) {
        debugPrint('Failed to log debug to CloudWatch: $e');
      }
    }
  }

  @override
  Future<void> recordMetric(
    String metricName,
    double value, {
    Map<String, String>? dimensions,
  }) async {
    try {
      await _cloudWatch.putMetricData(
        namespace: _namespace,
        metricData: [
          MetricDatum(
            metricName: metricName,
            value: value,
            dimensions: dimensions?.entries
                .map((e) => Dimension(name: e.key, value: e.value))
                .toList(),
            timestamp: DateTime.now(),
          ),
        ],
      );

      debugPrint('Metric recorded to CloudWatch: $metricName = $value');
    } catch (e) {
      debugPrint('Failed to record metric to CloudWatch: $e');
    }
  }

  @override
  void startTimer(String operationName) {
    _timers[operationName] = DateTime.now();
  }

  @override
  Future<void> stopTimer(String operationName) async {
    final startTime = _timers.remove(operationName);
    if (startTime == null) {
      debugPrint('No timer found for operation: $operationName');
      return;
    }

    final duration = DateTime.now().difference(startTime);
    await recordMetric(
      '${operationName}Duration',
      duration.inMilliseconds.toDouble(),
      dimensions: {'Operation': operationName},
    );
  }

  @override
  Future<void> recordEvent(
    String eventName, {
    Map<String, dynamic>? attributes,
  }) async {
    try {
      await _cloudWatch.putMetricData(
        namespace: _namespace,
        metricData: [
          MetricDatum(
            metricName: eventName,
            value: 1.0,
            dimensions: _contextToDimensions(attributes),
            timestamp: DateTime.now(),
          ),
        ],
      );

      debugPrint('Event recorded to CloudWatch: $eventName');
    } catch (e) {
      debugPrint('Failed to record event to CloudWatch: $e');
    }
  }

  List<Dimension>? _contextToDimensions(Map<String, dynamic>? context) {
    if (context == null) return null;
    return context.entries
        .map((e) => Dimension(name: e.key, value: e.value.toString()))
        .toList();
  }
}
