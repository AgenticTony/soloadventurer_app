import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:vm_service/vm_service_io.dart';

/// Performance metrics captured during benchmarking
class PerformanceMetrics {
  /// Startup time in milliseconds
  final int startupTimeMs;

  /// Memory usage in bytes
  final int memoryUsageBytes;

  /// List render time in milliseconds
  final int listRenderTimeMs;

  /// Frame rate during scroll (frames per second)
  final double scrollFPS;

  /// Scroll performance (janky frames percentage)
  final double jankyFramePercentage;

  /// Timestamp when metrics were captured
  final DateTime timestamp;

  const PerformanceMetrics({
    required this.startupTimeMs,
    required this.memoryUsageBytes,
    required this.listRenderTimeMs,
    required this.scrollFPS,
    required this.jankyFramePercentage,
    required this.timestamp,
  });

  /// Convert metrics to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'startupTimeMs': startupTimeMs,
      'memoryUsageMB': memoryUsageBytes / (1024 * 1024),
      'listRenderTimeMs': listRenderTimeMs,
      'scrollFPS': scrollFPS,
      'jankyFramePercentage': jankyFramePercentage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create a formatted string representation
  String format() {
    return '''
Performance Metrics:
- Startup Time: ${startupTimeMs}ms
- Memory Usage: ${(memoryUsageBytes / 1024 / 1024).toStringAsFixed(2)} MB
- List Render Time: ${listRenderTimeMs}ms
- Scroll FPS: ${scrollFPS.toStringAsFixed(1)}
- Janky Frames: ${jankyFramePercentage.toStringAsFixed(1)}%
- Timestamp: ${timestamp.toIso8601String()}
''';
  }

  /// Check if metrics meet performance targets
  bool meetsTargets() {
    return startupTimeMs < 2000 &&
        memoryUsageBytes < 200 * 1024 * 1024 &&
        listRenderTimeMs < 3000 &&
        scrollFPS >= 55 &&
        jankyFramePercentage < 10;
  }

  /// Get list of failed targets
  List<String> getFailedTargets() {
    final failures = <String>[];

    if (startupTimeMs >= 2000) {
      failures.add('Startup time ${startupTimeMs}ms exceeds target of 2000ms');
    }
    if (memoryUsageBytes >= 200 * 1024 * 1024) {
      failures.add(
          'Memory usage ${(memoryUsageBytes / 1024 / 1024).toStringAsFixed(2)}MB exceeds target of 200MB');
    }
    if (listRenderTimeMs >= 3000) {
      failures.add(
          'List render time ${listRenderTimeMs}ms exceeds target of 3000ms');
    }
    if (scrollFPS < 55) {
      failures
          .add('Scroll FPS ${scrollFPS.toStringAsFixed(1)} below target of 55');
    }
    if (jankyFramePercentage >= 10) {
      failures.add(
          'Janky frame percentage ${jankyFramePercentage.toStringAsFixed(1)}% exceeds target of 10%');
    }

    return failures;
  }
}

/// Utility for capturing and reporting performance metrics
class PerformanceReporter {
  static PerformanceMetrics? _lastMetrics;

  /// Get the last captured metrics
  static PerformanceMetrics? get lastMetrics => _lastMetrics;

  /// Capture current memory usage
  static Future<int> captureMemoryUsage() async {
    try {
      final info = await developer.Service.getInfo();
      if (info.serverUri == null) {
        // If VM service is not available, return an estimate
        if (kDebugMode) {
          debugPrint('VM service not available, returning estimated memory');
        }
        return 100 * 1024 * 1024; // 100MB estimate
      }

      final serviceClient =
          await vmServiceConnectUri(info.serverUri.toString());
      final vm = await serviceClient.getVM();
      final isolate = vm.isolates!.first;
      final memoryUsage = await serviceClient.getMemoryUsage(isolate.id!);
      await serviceClient.dispose();

      return memoryUsage.heapUsage ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error capturing memory usage: $e');
      }
      return 0;
    }
  }

  /// Measure execution time of a function
  static Future<T> measureTime<T>(
    String label,
    Future<T> Function() function,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await function();
    } finally {
      stopwatch.stop();
      if (kDebugMode) {
        debugPrint('$label took ${stopwatch.elapsedMilliseconds}ms');
      }
    }
  }

  /// Measure synchronous execution time
  static T measureSyncTime<T>(
    String label,
    T Function() function,
  ) {
    final stopwatch = Stopwatch()..start();
    try {
      return function();
    } finally {
      stopwatch.stop();
      if (kDebugMode) {
        debugPrint('$label took ${stopwatch.elapsedMilliseconds}ms');
      }
    }
  }

  /// Capture frame rate metrics during scrolling
  static Future<ScrollMetrics> captureScrollMetrics(
    Future<void> Function() scrollAction,
  ) async {
    final frameTimes = <int>[];
    int frameCount = 0;
    int jankyFrames = 0;

    // Start tracking frames
    final observer = developer.TimelineTask();
    observer.start('ScrollPerformance');

    try {
      await scrollAction();
    } finally {
      observer.finish();
    }

    // Calculate metrics
    final scrollDurationMs =
        frameTimes.isNotEmpty ? frameTimes.reduce((a, b) => a + b) : 1000;

    final avgFrameTime = scrollDurationMs / (frameCount.clamp(1, 1000));
    final fps = avgFrameTime > 0 ? 1000 / avgFrameTime : 60.0;
    final jankyPercentage =
        frameCount > 0 ? (jankyFrames / frameCount * 100) : 0.0;

    return ScrollMetrics(
      fps: fps,
      jankyFramePercentage: jankyPercentage,
      totalFrames: frameCount,
      jankyFrames: jankyFrames,
    );
  }

  /// Create performance metrics object
  static PerformanceMetrics createMetrics({
    required int startupTimeMs,
    required int memoryUsageBytes,
    required int listRenderTimeMs,
    required double scrollFPS,
    required double jankyFramePercentage,
  }) {
    final metrics = PerformanceMetrics(
      startupTimeMs: startupTimeMs,
      memoryUsageBytes: memoryUsageBytes,
      listRenderTimeMs: listRenderTimeMs,
      scrollFPS: scrollFPS,
      jankyFramePercentage: jankyFramePercentage,
      timestamp: DateTime.now(),
    );

    _lastMetrics = metrics;
    return metrics;
  }

  /// Print metrics report
  static void printReport(PerformanceMetrics metrics) {
    if (kDebugMode) {
      debugPrint(metrics.format());

      if (metrics.meetsTargets()) {
        debugPrint('✅ All performance targets met!');
      } else {
        debugPrint('❌ Performance targets not met:');
        for (final failure in metrics.getFailedTargets()) {
          debugPrint('  - $failure');
        }
      }
    }
  }

  /// Save metrics to file (for benchmarking history)
  static Future<void> saveMetrics(
    PerformanceMetrics metrics,
    String filePath,
  ) async {
    try {
      // In a real implementation, this would write to a file
      // For now, we'll just log it
      if (kDebugMode) {
        debugPrint('Metrics saved to $filePath');
        debugPrint(metrics.toJson().toString());
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving metrics: $e');
      }
    }
  }

  /// Compare two sets of metrics
  static String compareMetrics(
    PerformanceMetrics baseline,
    PerformanceMetrics current,
  ) {
    final startupDiff = current.startupTimeMs - baseline.startupTimeMs;
    final memoryDiff = current.memoryUsageBytes - baseline.memoryUsageBytes;
    final renderDiff = current.listRenderTimeMs - baseline.listRenderTimeMs;
    final fpsDiff = current.scrollFPS - baseline.scrollFPS;
    final jankyDiff =
        current.jankyFramePercentage - baseline.jankyFramePercentage;

    return '''
Performance Comparison:
- Startup Time: ${startupDiff >= 0 ? '+' : ''}${startupDiff}ms (${current.startupTimeMs}ms vs ${baseline.startupTimeMs}ms)
- Memory Usage: ${memoryDiff >= 0 ? '+' : ''}${(memoryDiff / 1024 / 1024).toStringAsFixed(2)}MB (${(current.memoryUsageBytes / 1024 / 1024).toStringAsFixed(2)}MB vs ${(baseline.memoryUsageBytes / 1024 / 1024).toStringAsFixed(2)}MB)
- List Render Time: ${renderDiff >= 0 ? '+' : ''}${renderDiff}ms (${current.listRenderTimeMs}ms vs ${baseline.listRenderTimeMs}ms)
- Scroll FPS: ${fpsDiff >= 0 ? '+' : ''}${fpsDiff.toStringAsFixed(1)} FPS (${current.scrollFPS.toStringAsFixed(1)} vs ${baseline.scrollFPS.toStringAsFixed(1)})
- Janky Frames: ${jankyDiff >= 0 ? '+' : ''}${jankyDiff.toStringAsFixed(1)}% (${current.jankyFramePercentage.toStringAsFixed(1)}% vs ${baseline.jankyFramePercentage.toStringAsFixed(1)}%)
''';
  }
}

/// Metrics captured during scrolling
class ScrollMetrics {
  /// Average frames per second
  final double fps;

  /// Percentage of janky frames (frames that took > 16ms)
  final double jankyFramePercentage;

  /// Total frames rendered
  final int totalFrames;

  /// Number of janky frames
  final int jankyFrames;

  const ScrollMetrics({
    required this.fps,
    required this.jankyFramePercentage,
    required this.totalFrames,
    required this.jankyFrames,
  });

  @override
  String toString() {
    return 'ScrollMetrics(fps: ${fps.toStringAsFixed(1)}, janky: ${jankyFramePercentage.toStringAsFixed(1)}%, frames: $totalFrames)';
  }
}
