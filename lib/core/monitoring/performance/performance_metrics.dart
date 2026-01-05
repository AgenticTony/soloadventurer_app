import 'package:flutter/foundation.dart';

/// App-wide performance metrics collected over time
///
/// This class aggregates performance data from various sources including
/// startup time, memory usage, frame rate, and network latency to provide
/// a comprehensive view of app performance.
class PerformanceMetrics {
  /// Time taken for app to start in milliseconds
  final int startupTimeMs;

  /// Current memory usage in bytes
  final int currentMemoryUsageBytes;

  /// Average memory usage in bytes over monitoring period
  final int averageMemoryUsageBytes;

  /// Peak memory usage in bytes
  final int peakMemoryUsageBytes;

  /// Current frame rate (FPS)
  final double currentFPS;

  /// Average frame rate (FPS) over monitoring period
  final double averageFPS;

  /// Percentage of janky frames (>16ms frame time)
  final double jankyFramePercentage;

  /// Total frames rendered since monitoring started
  final int totalFrames;

  /// Number of janky frames
  final int jankyFrames;

  /// Average network latency in milliseconds
  final double averageNetworkLatencyMs;

  /// Total network requests made
  final int totalNetworkRequests;

  /// Number of failed network requests
  final int failedNetworkRequests;

  /// Network error rate (0.0 to 1.0)
  double get errorRate => totalNetworkRequests > 0
      ? failedNetworkRequests / totalNetworkRequests
      : 0.0;

  /// Timestamp when metrics were captured
  final DateTime timestamp;

  /// Duration since monitoring started
  final Duration monitoringDuration;

  const PerformanceMetrics({
    required this.startupTimeMs,
    required this.currentMemoryUsageBytes,
    required this.averageMemoryUsageBytes,
    required this.peakMemoryUsageBytes,
    required this.currentFPS,
    required this.averageFPS,
    required this.jankyFramePercentage,
    required this.totalFrames,
    required this.jankyFrames,
    required this.averageNetworkLatencyMs,
    required this.totalNetworkRequests,
    required this.failedNetworkRequests,
    required this.timestamp,
    required this.monitoringDuration,
  });

  /// Current memory usage in MB
  double get currentMemoryUsageMB =>
      currentMemoryUsageBytes / (1024 * 1024);

  /// Average memory usage in MB
  double get averageMemoryUsageMB =>
      averageMemoryUsageBytes / (1024 * 1024);

  /// Peak memory usage in MB
  double get peakMemoryUsageMB =>
      peakMemoryUsageBytes / (1024 * 1024);

  /// Convert metrics to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'startupTimeMs': startupTimeMs,
      'currentMemoryUsageBytes': currentMemoryUsageBytes,
      'currentMemoryUsageMB': currentMemoryUsageMB,
      'averageMemoryUsageBytes': averageMemoryUsageBytes,
      'averageMemoryUsageMB': averageMemoryUsageMB,
      'peakMemoryUsageBytes': peakMemoryUsageBytes,
      'peakMemoryUsageMB': peakMemoryUsageMB,
      'currentFPS': currentFPS,
      'averageFPS': averageFPS,
      'jankyFramePercentage': jankyFramePercentage,
      'totalFrames': totalFrames,
      'jankyFrames': jankyFrames,
      'averageNetworkLatencyMs': averageNetworkLatencyMs,
      'totalNetworkRequests': totalNetworkRequests,
      'failedNetworkRequests': failedNetworkRequests,
      'errorRate': errorRate,
      'timestamp': timestamp.toIso8601String(),
      'monitoringDurationMs': monitoringDuration.inMilliseconds,
    };
  }

  /// Create a formatted string representation
  String format() {
    return '''
App Performance Metrics:
- Startup Time: ${startupTimeMs}ms
- Memory: ${currentMemoryUsageMB.toStringAsFixed(2)} MB (avg: ${averageMemoryUsageMB.toStringAsFixed(2)} MB, peak: ${peakMemoryUsageMB.toStringAsFixed(2)} MB)
- FPS: ${currentFPS.toStringAsFixed(1)} (avg: ${averageFPS.toStringAsFixed(1)})
- Janky Frames: ${jankyFramePercentage.toStringAsFixed(1)}%
- Network: ${averageNetworkLatencyMs.toStringAsFixed(1)}ms avg latency
- Requests: $totalNetworkRequests total, ${failedNetworkRequests} failed
- Monitoring Duration: ${monitoringDuration.inMinutes} minutes
''';
  }

  /// Check if metrics meet performance targets
  ///
  /// Targets:
  /// - Startup time < 2000ms
  /// - Memory usage < 200 MB
  /// - Average FPS >= 55
  /// - Janky frames < 10%
  /// - Network error rate < 5%
  bool meetsTargets() {
    return startupTimeMs < 2000 &&
        currentMemoryUsageBytes < 200 * 1024 * 1024 &&
        averageFPS >= 55 &&
        jankyFramePercentage < 10 &&
        errorRate < 0.05;
  }

  /// Check if metrics meet acceptable thresholds (less strict than targets)
  bool isAcceptable() {
    return startupTimeMs < 3000 &&
        currentMemoryUsageBytes < 250 * 1024 * 1024 &&
        averageFPS >= 50 &&
        jankyFramePercentage < 20 &&
        errorRate < 0.10;
  }

  @override
  String toString() => format();

  /// Create a copy with modified values
  PerformanceMetrics copyWith({
    int? startupTimeMs,
    int? currentMemoryUsageBytes,
    int? averageMemoryUsageBytes,
    int? peakMemoryUsageBytes,
    double? currentFPS,
    double? averageFPS,
    double? jankyFramePercentage,
    int? totalFrames,
    int? jankyFrames,
    double? averageNetworkLatencyMs,
    int? totalNetworkRequests,
    int? failedNetworkRequests,
    DateTime? timestamp,
    Duration? monitoringDuration,
  }) {
    return PerformanceMetrics(
      startupTimeMs: startupTimeMs ?? this.startupTimeMs,
      currentMemoryUsageBytes: currentMemoryUsageBytes ?? this.currentMemoryUsageBytes,
      averageMemoryUsageBytes: averageMemoryUsageBytes ?? this.averageMemoryUsageBytes,
      peakMemoryUsageBytes: peakMemoryUsageBytes ?? this.peakMemoryUsageBytes,
      currentFPS: currentFPS ?? this.currentFPS,
      averageFPS: averageFPS ?? this.averageFPS,
      jankyFramePercentage: jankyFramePercentage ?? this.jankyFramePercentage,
      totalFrames: totalFrames ?? this.totalFrames,
      jankyFrames: jankyFrames ?? this.jankyFrames,
      averageNetworkLatencyMs: averageNetworkLatencyMs ?? this.averageNetworkLatencyMs,
      totalNetworkRequests: totalNetworkRequests ?? this.totalNetworkRequests,
      failedNetworkRequests: failedNetworkRequests ?? this.failedNetworkRequests,
      timestamp: timestamp ?? this.timestamp,
      monitoringDuration: monitoringDuration ?? this.monitoringDuration,
    );
  }
}

/// Performance alert level
enum PerformanceAlertLevel {
  /// Performance is good
  good,

  /// Performance is degraded but acceptable
  warning,

  /// Performance is critically poor
  critical,
}

/// Performance alert event
class PerformanceAlert {
  /// Alert level
  final PerformanceAlertLevel level;

  /// Metrics that triggered the alert
  final PerformanceMetrics metrics;

  /// Alert message describing the issue
  final String message;

  /// Specific issues detected
  final List<String> issues;

  /// Timestamp when alert was triggered
  final DateTime timestamp;

  const PerformanceAlert({
    required this.level,
    required this.metrics,
    required this.message,
    required this.issues,
    required this.timestamp,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'metrics': metrics.toJson(),
      'message': message,
      'issues': issues,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PerformanceAlert(${level.name}: $message\nIssues: ${issues.join(', ')}')';
  }
}
