import 'dart:async';
import 'dart:developer' as developer;
import 'package:soloadventurer/features/core/infrastructure/monitoring/monitoring_service.dart';

/// A utility class for measuring and logging performance metrics in the app.
class PerformanceMetrics {
  static final Map<String, Stopwatch> _activeTimers = {};
  static final Map<String, List<Duration>> _metricHistory = {};
  static MonitoringService? _monitoringService;

  /// Initialize the PerformanceMetrics with a monitoring service
  static void initialize(MonitoringService monitoringService) {
    _monitoringService = monitoringService;
    developer.log('PerformanceMetrics initialized with monitoring service');
  }

  /// Start measuring a performance metric with the given name.
  static void startMeasurement(String metricName) {
    if (_activeTimers.containsKey(metricName)) {
      developer
          .log('Warning: Timer for $metricName already running. Restarting.');
      _activeTimers[metricName]?.reset();
    } else {
      _activeTimers[metricName] = Stopwatch()..start();
    }

    developer.log('Started measuring: $metricName');
  }

  /// Stop measuring a performance metric and record the result.
  static Duration stopMeasurement(String metricName,
      {MetricCategory? category}) {
    final stopwatch = _activeTimers[metricName];
    if (stopwatch == null) {
      developer.log('Error: No timer found for $metricName');
      return Duration.zero;
    }

    stopwatch.stop();
    final duration = stopwatch.elapsed;

    // Store the measurement in history
    if (!_metricHistory.containsKey(metricName)) {
      _metricHistory[metricName] = [];
    }
    _metricHistory[metricName]?.add(duration);

    developer
        .log('Finished measuring: $metricName - ${duration.inMilliseconds}ms');

    // Report to monitoring service if available
    _monitoringService?.trackOperation(metricName, duration,
        category: category);

    _activeTimers.remove(metricName);

    return duration;
  }

  /// Get the average duration for a specific metric.
  static Duration getAverageDuration(String metricName) {
    final measurements = _metricHistory[metricName];
    if (measurements == null || measurements.isEmpty) {
      return Duration.zero;
    }

    final totalMs = measurements.fold<int>(
        0, (sum, duration) => sum + duration.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ measurements.length);
  }

  /// Print a summary of all recorded metrics.
  static void printSummary() {
    developer.log('===== Performance Metrics Summary =====');

    if (_metricHistory.isEmpty) {
      developer.log('No metrics recorded.');
      return;
    }

    _metricHistory.forEach((metricName, durations) {
      final count = durations.length;
      final avgMs = getAverageDuration(metricName).inMilliseconds;
      final minMs = durations
          .map((d) => d.inMilliseconds)
          .reduce((a, b) => a < b ? a : b);
      final maxMs = durations
          .map((d) => d.inMilliseconds)
          .reduce((a, b) => a > b ? a : b);

      developer.log('$metricName:');
      developer.log('  Count: $count');
      developer.log('  Average: ${avgMs}ms');
      developer.log('  Min: ${minMs}ms');
      developer.log('  Max: ${maxMs}ms');
    });

    developer.log('=====================================');
  }

  /// Clear all recorded metrics.
  static void clearMetrics() {
    _metricHistory.clear();
    developer.log('All metrics cleared.');
  }

  /// Measure the execution time of a function and report to monitoring service.
  static Future<T> measureFunction<T>(
      String metricName, Future<T> Function() function,
      {MetricCategory? category}) async {
    startMeasurement(metricName);
    try {
      final result = await function();
      stopMeasurement(metricName, category: category);
      return result;
    } catch (e, stackTrace) {
      stopMeasurement(metricName, category: category);
      // Report error to monitoring service if available
      _monitoringService?.reportError('PerformanceError', e, stackTrace,
          context: {
            'metricName': metricName,
            'category': category?.toString()
          });
      rethrow;
    }
  }

  /// Measure the execution time of a synchronous function and report to monitoring service.
  static T measureSyncFunction<T>(String metricName, T Function() function,
      {MetricCategory? category}) {
    startMeasurement(metricName);
    try {
      final result = function();
      stopMeasurement(metricName, category: category);
      return result;
    } catch (e, stackTrace) {
      stopMeasurement(metricName, category: category);
      // Report error to monitoring service if available
      _monitoringService?.reportError('PerformanceError', e, stackTrace,
          context: {
            'metricName': metricName,
            'category': category?.toString()
          });
      rethrow;
    }
  }

  /// Track a threshold breach for a specific metric
  static void trackThresholdBreach(
      String metricName, Duration threshold, Duration actual) {
    final message = 'Performance threshold breached for $metricName: '
        'Expected < ${threshold.inMilliseconds}ms, '
        'Actual: ${actual.inMilliseconds}ms';

    developer.log(message, level: 900); // Using a high level for visibility

    // Report to monitoring service if available
    _monitoringService?.trackEvent('performance_threshold_breach', parameters: {
      'metricName': metricName,
      'thresholdMs': threshold.inMilliseconds,
      'actualMs': actual.inMilliseconds,
      'percentOver':
          ((actual.inMilliseconds / threshold.inMilliseconds) * 100 - 100)
              .toStringAsFixed(1)
    });
  }
}
