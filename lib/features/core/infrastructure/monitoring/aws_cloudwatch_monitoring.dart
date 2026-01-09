import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// TODO: Fix aws_cloudwatch_api package corruption
// import 'package:aws_cloudwatch_api/cloudwatch-2010-08-01.dart' as aws;
// import 'package:shared_aws_api/shared.dart';
import './monitoring_service.dart';

part 'aws_cloudwatch_monitoring.g.dart';

/// Data class for metric data
class MetricDatum {
  final String metricName;
  final double value;
  final List<Dimension>? dimensions;
  final DateTime? timestamp;

  MetricDatum({
    required this.metricName,
    required this.value,
    this.dimensions,
    this.timestamp,
  });
}

/// Data class for dimensions
class Dimension {
  final String name;
  final String value;

  Dimension({required this.name, required this.value});
}

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

/// CloudWatch wrapper class (stub implementation)
class CloudWatch {
  final String region;
  final String accessKeyId;
  final String secretAccessKey;

  CloudWatch({
    required this.region,
    required this.accessKeyId,
    required this.secretAccessKey,
  }) {
    debugPrint('CloudWatch: Stub implementation - AWS monitoring disabled');
  }

  Future<void> putMetricData({
    required String namespace,
    required List<MetricDatum> metricData,
  }) async {
    // Stub implementation - AWS CloudWatch API package is corrupted
    debugPrint(
        'CloudWatch: Stub putMetricData called for $namespace with ${metricData.length} metrics');
  }
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
            dimensions: [
              Dimension(name: 'Message', value: message),
            ],
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
            dimensions: [
              Dimension(name: 'Message', value: message),
            ],
            timestamp: DateTime.now(),
          ),
        ],
      );

      debugPrint('Info logged to CloudWatch: $message');
    } catch (e) {
      debugPrint('Failed to log info to CloudWatch: $e');
    }
  }

  Future<void> logMetric(
    String name,
    double value, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final dimensions = metadata?.entries
          .map((e) => Dimension(name: e.key, value: e.value.toString()))
          .toList();

      await _cloudWatch.putMetricData(
        namespace: _namespace,
        metricData: [
          MetricDatum(
            metricName: name,
            value: value,
            dimensions: dimensions,
            timestamp: DateTime.now(),
          ),
        ],
      );

      debugPrint('Metric logged to CloudWatch: $name = $value');
    } catch (e) {
      debugPrint('Failed to log metric to CloudWatch: $e');
    }
  }

  @override
  void startTimer(String name) {
    _timers[name] = DateTime.now();
    debugPrint('Timer started: $name');
  }

  @override
  Future<double?> stopTimer(String name) async {
    final startTime = _timers[name];
    if (startTime == null) {
      debugPrint('Timer not found: $name');
      return null;
    }

    final duration = DateTime.now().difference(startTime);
    final durationMs = duration.inMilliseconds.toDouble();

    await logMetric(
      '${name}_duration',
      durationMs,
      metadata: {'unit': 'milliseconds'},
    );

    _timers.remove(name);
    debugPrint('Timer stopped: $name (${durationMs}ms)');
    return durationMs;
  }

  @override
  Future<void> logDebug(
    String message, {
    Map<String, dynamic>? context,
  }) async {
    try {
      await _cloudWatch.putMetricData(
        namespace: _namespace,
        metricData: [
          MetricDatum(
            metricName: 'Debug',
            value: 1.0,
            dimensions: [
              Dimension(name: 'Message', value: message),
            ],
            timestamp: DateTime.now(),
          ),
        ],
      );

      debugPrint('Debug logged to CloudWatch: $message');
    } catch (e) {
      debugPrint('Failed to log debug to CloudWatch: $e');
    }
  }

  @override
  Future<void> recordMetric(
    String metricName,
    double value, {
    Map<String, String>? dimensions,
  }) async {
    try {
      final metricDimensions = dimensions?.entries
          .map((e) => Dimension(name: e.key, value: e.value))
          .toList();

      await _cloudWatch.putMetricData(
        namespace: _namespace,
        metricData: [
          MetricDatum(
            metricName: metricName,
            value: value,
            dimensions: metricDimensions,
            timestamp: DateTime.now(),
          ),
        ],
      );

      debugPrint('Metric logged to CloudWatch: $metricName = $value');
    } catch (e) {
      debugPrint('Failed to log metric to CloudWatch: $e');
    }
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
            metricName: 'Event',
            value: 1.0,
            dimensions: [
              Dimension(name: 'Name', value: eventName),
              if (attributes != null)
                ...attributes.entries.map(
                    (e) => Dimension(name: e.key, value: e.value.toString())),
            ],
            timestamp: DateTime.now(),
          ),
        ],
      );

      debugPrint('Event logged to CloudWatch: $eventName');
    } catch (e) {
      debugPrint('Failed to log event to CloudWatch: $e');
    }
  }
}
