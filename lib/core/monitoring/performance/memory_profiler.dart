import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:vm_service/vm_service_io.dart' show vmServiceConnectUri;
import 'package:vm_service/vm_service.dart' show VmService;

/// Memory usage snapshot at a point in time
class MemorySnapshot {
  /// Heap memory usage in bytes
  final int heapUsageBytes;

  /// Resident set size (RSS) in bytes
  final int rssBytes;

  /// Timestamp when snapshot was captured
  final DateTime timestamp;

  /// Heap usage in MB
  double get heapUsageMB => heapUsageBytes / (1024 * 1024);

  /// RSS in MB
  double get rssMB => rssBytes / (1024 * 1024);

  const MemorySnapshot({
    required this.heapUsageBytes,
    required this.rssBytes,
    required this.timestamp,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'heapUsageBytes': heapUsageBytes,
      'heapUsageMB': heapUsageMB,
      'rssBytes': rssBytes,
      'rssMB': rssMB,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MemorySnapshot(heap: ${heapUsageMB.toStringAsFixed(2)} MB, rss: ${rssMB.toStringAsFixed(2)} MB)';
  }

  /// Create a formatted string for display
  String format() {
    return '''
Memory Snapshot:
- Heap Usage: ${heapUsageMB.toStringAsFixed(2)} MB
- RSS: ${rssMB.toStringAsFixed(2)} MB
- Timestamp: ${timestamp.toIso8601String()}
''';
  }
}

/// Memory usage statistics
class MemoryStatistics {
  /// Current heap usage in bytes
  final int currentHeapUsageBytes;

  /// Average heap usage in bytes
  final int averageHeapUsageBytes;

  /// Peak heap usage in bytes
  final int peakHeapUsageBytes;

  /// Current RSS in bytes
  final int currentRSSBytes;

  /// Average RSS in bytes
  final int averageRSSBytes;

  /// Peak RSS in bytes
  final int peakRSSBytes;

  /// Number of snapshots collected
  final int snapshotCount;

  /// Monitoring start time
  final DateTime startTime;

  /// Monitoring end time
  final DateTime endTime;

  /// Memory trend (increasing, decreasing, stable)
  final MemoryTrend trend;

  /// Trend percentage
  final double trendPercentage;

  const MemoryStatistics({
    required this.currentHeapUsageBytes,
    required this.averageHeapUsageBytes,
    required this.peakHeapUsageBytes,
    required this.currentRSSBytes,
    required this.averageRSSBytes,
    required this.peakRSSBytes,
    required this.snapshotCount,
    required this.startTime,
    required this.endTime,
    required this.trend,
    required this.trendPercentage,
  });

  /// Current heap usage in MB
  double get currentHeapUsageMB => currentHeapUsageBytes / (1024 * 1024);

  /// Average heap usage in MB
  double get averageHeapUsageMB => averageHeapUsageBytes / (1024 * 1024);

  /// Peak heap usage in MB
  double get peakHeapUsageMB => peakHeapUsageBytes / (1024 * 1024);

  /// Current RSS in MB
  double get currentRSSMB => currentRSSBytes / (1024 * 1024);

  /// Average RSS in MB
  double get averageRSSMB => averageRSSBytes / (1024 * 1024);

  /// Peak RSS in MB
  double get peakRSSMB => peakRSSBytes / (1024 * 1024);

  /// Monitoring duration
  Duration get monitoringDuration => endTime.difference(startTime);

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'currentHeapUsageBytes': currentHeapUsageBytes,
      'currentHeapUsageMB': currentHeapUsageMB,
      'averageHeapUsageBytes': averageHeapUsageBytes,
      'averageHeapUsageMB': averageHeapUsageMB,
      'peakHeapUsageBytes': peakHeapUsageBytes,
      'peakHeapUsageMB': peakHeapUsageMB,
      'currentRSSBytes': currentRSSBytes,
      'currentRSSMB': currentRSSMB,
      'averageRSSBytes': averageRSSBytes,
      'averageRSSMB': averageRSSMB,
      'peakRSSBytes': peakRSSBytes,
      'peakRSSMB': peakRSSMB,
      'snapshotCount': snapshotCount,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'monitoringDurationMs': monitoringDuration.inMilliseconds,
      'trend': trend.name,
      'trendPercentage': trendPercentage,
    };
  }

  @override
  String toString() {
    return '''
Memory Statistics:
- Heap Usage: ${currentHeapUsageMB.toStringAsFixed(2)} MB (avg: ${averageHeapUsageMB.toStringAsFixed(2)} MB, peak: ${peakHeapUsageMB.toStringAsFixed(2)} MB)
- RSS: ${currentRSSMB.toStringAsFixed(2)} MB (avg: ${averageRSSMB.toStringAsFixed(2)} MB, peak: ${peakRSSMB.toStringAsFixed(2)} MB)
- Snapshots: $snapshotCount
- Trend: ${trend.name} (${trendPercentage.toStringAsFixed(1)}%)
- Duration: ${monitoringDuration.inMinutes} minutes
''';
  }

  /// Create a formatted string for display
  String format() => toString();
}

/// Memory trend over time
enum MemoryTrend {
  /// Memory usage is increasing
  increasing,

  /// Memory usage is decreasing
  decreasing,

  /// Memory usage is stable
  stable,
}

/// Utility class for memory profiling
///
/// This class provides convenient methods for capturing and analyzing
/// memory usage snapshots. It's designed to be used with the MemoryMonitor
/// service or standalone for ad-hoc profiling.
///
/// ## Usage
///
/// ```dart
/// // Capture a single snapshot
/// final snapshot = await MemoryProfiler.captureSnapshot();
/// debugPrint(snapshot.toString());
///
/// // Start a profiling session
/// await MemoryProfiler.startProfiling();
/// // ... perform operations ...
/// final stats = await MemoryProfiler.stopProfiling();
/// debugPrint(stats.toString());
///
/// // Get current memory usage (quick estimate)
/// final usage = await MemoryProfiler.getCurrentUsage();
/// debugPrint('Current heap: ${usage.heapUsageMB.toStringAsFixed(2)} MB');
/// ```
class MemoryProfiler {
  /// VM service client (cached)
  static VmService? _vmService;

  /// List of snapshots for current profiling session
  static final List<MemorySnapshot> _snapshots = [];

  /// Start time for current profiling session
  static DateTime? _profilingStartTime;

  /// Whether profiling is currently active
  static bool _isProfiling = false;

  /// Capture a memory snapshot
  ///
  /// Returns current memory usage including heap and RSS.
  /// If VM service is not available, returns estimated values.
  static Future<MemorySnapshot> captureSnapshot() async {
    try {
      final info = await developer.Service.getInfo();

      int heapUsage = 100 * 1024 * 1024; // 100MB default
      int rss = 120 * 1024 * 1024; // 120MB default

      if (info.serverUri != null) {
        try {
          // Connect to VM service
          _vmService ??= await vmServiceConnectUri(info.serverUri.toString());

          final vm = await _vmService!.getVM();
          if (vm.isolates != null && vm.isolates!.isNotEmpty) {
            final isolate = vm.isolates!.first;
            final memoryUsage = await _vmService!.getMemoryUsage(isolate.id!);

            heapUsage = memoryUsage.heapUsage ?? heapUsage;
            // RSS is not directly available from getMemoryUsage
            // Use heapUsage + 20MB as a rough estimate for RSS
            rss = heapUsage + (20 * 1024 * 1024);
          }
        } catch (e) {
          if (kDebugMode) {
          }
        }
      }

      final snapshot = MemorySnapshot(
        heapUsageBytes: heapUsage,
        rssBytes: rss,
        timestamp: DateTime.now(),
      );

      // Store snapshot if profiling is active
      if (_isProfiling) {
        _snapshots.add(snapshot);
      }

      return snapshot;
    } catch (e) {
      if (kDebugMode) {
      }
      // Return estimated values on error
      return MemorySnapshot(
        heapUsageBytes: 100 * 1024 * 1024,
        rssBytes: 120 * 1024 * 1024,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Get current memory usage (simplified)
  ///
  /// Returns just the heap usage in bytes as an integer.
  /// This is a convenience method for quick checks.
  static Future<int> getCurrentUsage() async {
    final snapshot = await captureSnapshot();
    return snapshot.heapUsageBytes;
  }

  /// Get current memory usage in MB
  static Future<double> getCurrentUsageMB() async {
    final usage = await getCurrentUsage();
    return usage / (1024 * 1024);
  }

  /// Start a profiling session
  ///
  /// Begins collecting memory snapshots. Snapshots will be stored
  /// until [stopProfiling] is called.
  static Future<void> startProfiling() async {
    if (_isProfiling) {
      if (kDebugMode) {
      }
      return;
    }

    _isProfiling = true;
    _profilingStartTime = DateTime.now();
    _snapshots.clear();

    // Capture initial snapshot
    await captureSnapshot();

    if (kDebugMode) {
    }
  }

  /// Stop profiling and get statistics
  ///
  /// Stops the profiling session and returns statistics based on
  /// all collected snapshots.
  static Future<MemoryStatistics?> stopProfiling() async {
    if (!_isProfiling) {
      if (kDebugMode) {
      }
      return null;
    }

    _isProfiling = false;

    // Capture final snapshot
    await captureSnapshot();

    if (_snapshots.isEmpty) {
      if (kDebugMode) {
      }
      return null;
    }

    final now = DateTime.now();
    final startTime = _profilingStartTime ?? now;

    // Calculate statistics
    final currentHeap = _snapshots.last.heapUsageBytes;
    final totalHeap =
        _snapshots.fold<int>(0, (sum, s) => sum + s.heapUsageBytes);
    final avgHeap = totalHeap ~/ _snapshots.length;
    final peakHeap =
        _snapshots.map((s) => s.heapUsageBytes).reduce((a, b) => a > b ? a : b);

    final currentRSS = _snapshots.last.rssBytes;
    final totalRSS = _snapshots.fold<int>(0, (sum, s) => sum + s.rssBytes);
    final avgRSS = totalRSS ~/ _snapshots.length;
    final peakRSS =
        _snapshots.map((s) => s.rssBytes).reduce((a, b) => a > b ? a : b);

    // Calculate trend
    MemoryTrend trend = MemoryTrend.stable;
    double trendPercentage = 0.0;

    if (_snapshots.length >= 2) {
      final midPoint = _snapshots.length ~/ 2;
      final firstHalf = _snapshots.sublist(0, midPoint);
      final secondHalf = _snapshots.sublist(midPoint);

      final firstHalfAvg =
          firstHalf.map((s) => s.heapUsageBytes).reduce((a, b) => a + b) /
              firstHalf.length;
      final secondHalfAvg =
          secondHalf.map((s) => s.heapUsageBytes).reduce((a, b) => a + b) /
              secondHalf.length;

      final change = (secondHalfAvg - firstHalfAvg) / firstHalfAvg;

      if (change > 0.1) {
        // > 10% increase
        trend = MemoryTrend.increasing;
        trendPercentage = change * 100;
      } else if (change < -0.1) {
        // > 10% decrease
        trend = MemoryTrend.decreasing;
        trendPercentage = -change * 100;
      } else {
        trend = MemoryTrend.stable;
        trendPercentage = change * 100;
      }
    }

    final stats = MemoryStatistics(
      currentHeapUsageBytes: currentHeap,
      averageHeapUsageBytes: avgHeap,
      peakHeapUsageBytes: peakHeap,
      currentRSSBytes: currentRSS,
      averageRSSBytes: avgRSS,
      peakRSSBytes: peakRSS,
      snapshotCount: _snapshots.length,
      startTime: startTime,
      endTime: now,
      trend: trend,
      trendPercentage: trendPercentage,
    );

    // Clear snapshots
    _snapshots.clear();
    _profilingStartTime = null;

    if (kDebugMode) {
    }

    return stats;
  }

  /// Get collected snapshots without stopping profiling
  static List<MemorySnapshot> getSnapshots() {
    return List.unmodifiable(_snapshots);
  }

  /// Clear all snapshots
  static void clearSnapshots() {
    _snapshots.clear();
    if (kDebugMode) {
    }
  }

  /// Check if profiling is currently active
  static bool get isProfiling => _isProfiling;

  /// Dispose of resources
  static Future<void> dispose() async {
    await _vmService?.dispose();
    _vmService = null;
    _snapshots.clear();
    _isProfiling = false;
    _profilingStartTime = null;

    if (kDebugMode) {
    }
  }

  /// Log a memory snapshot with a custom message
  static Future<void> logSnapshot(String message) async {
    await captureSnapshot();
    if (kDebugMode) {
    }
  }

  /// Compare two memory snapshots and log the difference
  static void compareSnapshots(MemorySnapshot before, MemorySnapshot after,
      {String? label}) {
    final heapDiff = after.heapUsageBytes - before.heapUsageBytes;
    final rssDiff = after.rssBytes - before.rssBytes;
    final duration = after.timestamp.difference(before.timestamp);

    final buffer = StringBuffer();
    if (label != null) {
      buffer.writeln(label);
    }
    buffer.writeln('Memory Comparison:');
    buffer.writeln('  Duration: ${duration.inMilliseconds}ms');
    buffer.writeln(
        '  Heap: ${(heapDiff / (1024 * 1024)).toStringAsFixed(2)} MB '
        '(${heapDiff >= 0 ? '+' : ''}${(heapDiff / (1024 * 1024)).toStringAsFixed(2)})');
    buffer.writeln('  RSS: ${(rssDiff / (1024 * 1024)).toStringAsFixed(2)} MB '
        '(${rssDiff >= 0 ? '+' : ''}${(rssDiff / (1024 * 1024)).toStringAsFixed(2)})');

    if (kDebugMode) {
    }
  }
}
