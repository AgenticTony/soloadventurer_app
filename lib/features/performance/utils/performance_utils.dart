import 'dart:async';
import 'package:flutter/material.dart';
import 'package:soloadventurer/core/monitoring/performance/performance_metrics.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';

/// Simplified performance metrics for benchmarking
class BenchmarkPerformanceMetrics {
  final int startupTimeMs;
  final int memoryUsageBytes;
  final int listRenderTimeMs;
  final double scrollFPS;
  final double jankyFramePercentage;
  final DateTime timestamp;

  const BenchmarkPerformanceMetrics({
    required this.startupTimeMs,
    required this.memoryUsageBytes,
    required this.listRenderTimeMs,
    required this.scrollFPS,
    required this.jankyFramePercentage,
    required this.timestamp,
  });

  /// Performance targets for benchmarking
  static const Map<String, double> targets = {
    'Startup Time (ms)': 2000,
    'Memory Usage (MB)': 200,
    'List Render Time (ms)': 3000,
    'Scroll FPS': 55,
    'Janky Frames (%)': 10,
  };

  /// Check if metrics meet performance targets
  bool meetsTargets() {
    return startupTimeMs < targets['Startup Time (ms)']! &&
        (memoryUsageBytes / 1024 / 1024) < targets['Memory Usage (MB)']! &&
        listRenderTimeMs < targets['List Render Time (ms)']! &&
        scrollFPS >= targets['Scroll FPS']! &&
        jankyFramePercentage < targets['Janky Frames (%)']!;
  }

  /// Get list of failed targets
  List<String> getFailedTargets() {
    final failures = <String>[];

    if (startupTimeMs >= targets['Startup Time (ms)']!) {
      failures.add('Startup Time: ${startupTimeMs}ms (target: <${targets['Startup Time (ms)']!.toInt()}ms)');
    }
    if ((memoryUsageBytes / 1024 / 1024) >= targets['Memory Usage (MB)']!) {
      failures.add('Memory Usage: ${(memoryUsageBytes / 1024 / 1024).toStringAsFixed(1)}MB (target: <${targets['Memory Usage (MB)']!.toInt()}MB)');
    }
    if (listRenderTimeMs >= targets['List Render Time (ms)']!) {
      failures.add('List Render Time: ${listRenderTimeMs}ms (target: <${targets['List Render Time (ms)']!.toInt()}ms)');
    }
    if (scrollFPS < targets['Scroll FPS']!) {
      failures.add('Scroll FPS: ${scrollFPS.toStringAsFixed(1)} (target: ≥${targets['Scroll FPS']!.toInt()})');
    }
    if (jankyFramePercentage >= targets['Janky Frames (%)']!) {
      failures.add('Janky Frames: ${jankyFramePercentage.toStringAsFixed(1)}% (target: <${targets['Janky Frames (%)']!.toInt()}%)');
    }

    return failures;
  }
}

/// Utility class for performance reporting and measurement
class PerformanceReporter {
  static BenchmarkPerformanceMetrics? _lastMetrics;

  /// Get the last captured metrics
  static BenchmarkPerformanceMetrics? get lastMetrics => _lastMetrics;

  /// Set the last captured metrics
  static void setLastMetrics(BenchmarkPerformanceMetrics metrics) {
    _lastMetrics = metrics;
  }

  /// Capture current memory usage
  ///
  /// Returns approximate memory usage in bytes
  static Future<int> captureMemoryUsage() async {
    // In a real implementation, this would use dart:developer or platform channels
    // For now, return a simulated value
    return 50 * 1024 * 1024; // 50 MB default
  }

  /// Create metrics from raw values
  static BenchmarkPerformanceMetrics createMetrics({
    required int startupTimeMs,
    required int memoryUsageBytes,
    required int listRenderTimeMs,
    required double scrollFPS,
    required double jankyFramePercentage,
  }) {
    final metrics = BenchmarkPerformanceMetrics(
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

  /// Compare two metrics and return comparison text
  static String compareMetrics(
    BenchmarkPerformanceMetrics baseline,
    BenchmarkPerformanceMetrics current,
  ) {
    final startupDiff = current.startupTimeMs - baseline.startupTimeMs;
    final memoryDiff = current.memoryUsageBytes - baseline.memoryUsageBytes;
    final renderDiff = current.listRenderTimeMs - baseline.listRenderTimeMs;
    final fpsDiff = current.scrollFPS - baseline.scrollFPS;
    final jankyDiff = current.jankyFramePercentage - baseline.jankyFramePercentage;

    final buffer = StringBuffer();
    buffer.writeln('Comparison vs Baseline:');

    if (startupDiff.abs() > 100) {
      buffer.writeln('  Startup: ${startupDiff > 0 ? '+' : ''}${startupDiff}ms ${startupDiff > 0 ? '↑' : '↓'}');
    }
    if ((memoryDiff / 1024 / 1024).abs() > 5) {
      buffer.writeln('  Memory: ${(memoryDiff / 1024 / 1024).toStringAsFixed(1)}MB ${memoryDiff > 0 ? '↑' : '↓'}');
    }
    if (renderDiff.abs() > 100) {
      buffer.writeln('  Render: ${renderDiff > 0 ? '+' : ''}${renderDiff}ms ${renderDiff > 0 ? '↑' : '↓'}');
    }
    if (fpsDiff.abs() > 1) {
      buffer.writeln('  FPS: ${fpsDiff > 0 ? '+' : ''}${fpsDiff.toStringAsFixed(1)} ${fpsDiff > 0 ? '↑' : '↓'}');
    }
    if (jankyDiff.abs() > 1) {
      buffer.writeln('  Janky: ${jankyDiff > 0 ? '+' : ''}${jankyDiff.toStringAsFixed(1)}% ${jankyDiff > 0 ? '↑' : '↓'}');
    }

    if (buffer.toString() == 'Comparison vs Baseline:\n') {
      return 'All metrics within acceptable range of baseline';
    }

    return buffer.toString().trimRight();
  }

  /// Measure execution time of a function
  static Future<Duration> measureTime(String label, Future<void> Function() fn) async {
    final stopwatch = Stopwatch()..start();
    await fn();
    stopwatch.stop();
    return stopwatch.elapsed;
  }
}

/// Utility class for generating test data for performance benchmarks
class PerformanceTestDataGenerator {
  /// Generate a list of trip objects for testing
  static List<Trip> generateLargeTripList({required int count}) {
    final trips = <Trip>[];
    final destinations = [
      'Tokyo, Japan',
      'Paris, France',
      'New York, USA',
      'London, UK',
      'Sydney, Australia',
      'Bangkok, Thailand',
      'Rome, Italy',
      'Barcelona, Spain',
    ];

    for (int i = 0; i < count; i++) {
      final destination = destinations[i % destinations.length];
      final budget = 1000 + (i % 10) * 500;

      trips.add(Trip(
        id: 'trip_$i',
        userId: 'test-user',
        title: 'Trip to $destination',
        destination: destination,
        startDate: DateTime.now().add(Duration(days: i * 7)),
        endDate: DateTime.now().add(Duration(days: i * 7 + 7)),
        budget: budget,
        status: i % 3 == 0 ? 'completed' : 'planned',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    return trips;
  }
}

/// Utility class for generating photo data for testing
class PhotoDataGenerator {
  /// Generate photo URLs for testing
  static List<String> generatePhotoUrls({required int count}) {
    final urls = <String>[];
    for (int i = 0; i < count; i++) {
      urls.add('https://example.com/photos/photo_$i.jpg');
    }
    return urls;
  }

  /// Generate photo metadata for testing
  static List<Map<String, dynamic>> generatePhotoMetadata({required int count}) {
    final photos = <Map<String, dynamic>>[];
    for (int i = 0; i < count; i++) {
      photos.add({
        'id': 'photo_$i',
        'url': 'https://example.com/photos/photo_$i.jpg',
        'caption': 'Photo $i',
        'timestamp': DateTime.now().toIso8601String(),
        'location': i % 2 == 0 ? 'Location A' : 'Location B',
        'sizeBytes': 1024 * 1024 * (2 + i % 5), // 2-6 MB
      });
    }
    return photos;
  }
}
