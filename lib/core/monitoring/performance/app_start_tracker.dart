import 'package:flutter/foundation.dart';
import 'package:solo_adventurer/core/monitoring/performance/performance_monitor.dart';
import 'package:solo_adventurer/core/monitoring/performance/memory_profiler.dart';

/// Utility class for tracking app startup performance
///
/// This class tracks the app startup time and integrates with the
/// PerformanceMonitor for comprehensive startup metrics.
///
/// ## Usage
///
/// ```dart
/// // In main(), before runApp()
/// void main() {
///   AppStartTracker.trackAppStart();
///   runApp(MyApp());
/// }
///
/// // In first frame callback or after initial render
/// AppStartTracker.completeStartup();
///
/// // Get startup duration
/// final duration = AppStartTracker.getStartupDuration();
/// debugPrint('Startup took: ${duration.inMilliseconds}ms');
/// ```
class AppStartTracker {
  static DateTime? _startTime;
  static DateTime? _endTime;
  static bool _isCompleted = false;

  /// Start tracking app startup time
  ///
  /// Should be called as early as possible in main() before runApp().
  /// This also integrates with PerformanceMonitor if it's initialized.
  static void trackAppStart() {
    if (_startTime != null) {
      if (kDebugMode) {
        debugPrint('AppStartTracker: Startup already tracked');
      }
      return;
    }

    _startTime = DateTime.now();
    _endTime = null;
    _isCompleted = false;

    // Also track in PerformanceMonitor if initialized
    try {
      PerformanceMonitor.trackAppStart();
    } catch (e) {
      // PerformanceMonitor not initialized, ignore
    }

    if (kDebugMode) {
      debugPrint('AppStartTracker: Started tracking at ${_startTime!.toIso8601String()}');
    }
  }

  /// Complete startup tracking
  ///
  /// Should be called after the first frame is rendered or when
  /// the app is considered "started" (e.g., after initial data load).
  /// This integrates with PerformanceMonitor and logs startup metrics.
  static void completeStartup() {
    if (_startTime == null) {
      if (kDebugMode) {
        debugPrint('AppStartTracker: Startup not started, call trackAppStart() first');
      }
      return;
    }

    if (_isCompleted) {
      if (kDebugMode) {
        debugPrint('AppStartTracker: Startup already completed');
      }
      return;
    }

    _endTime = DateTime.now();
    _isCompleted = true;

    // Also complete in PerformanceMonitor if initialized
    try {
      PerformanceMonitor.completeStartup();
    } catch (e) {
      // PerformanceMonitor not initialized, ignore
    }

    // Log startup duration
    logStartupDuration();
  }

  /// Get the duration since app start
  ///
  /// Returns null if tracking hasn't started.
  /// If startup is not yet completed, returns duration from start to now.
  static Duration? getStartupDuration() {
    if (_startTime == null) return null;

    final endTime = _endTime ?? DateTime.now();
    return endTime.difference(_startTime!);
  }

  /// Get the startup duration in milliseconds
  ///
  /// Returns null if tracking hasn't started.
  static int? getStartupDurationMs() {
    return getStartupDuration()?.inMilliseconds;
  }

  /// Log the startup duration
  ///
  /// Logs the duration and includes memory usage information if available.
  static void logStartupDuration() {
    final duration = getStartupDuration();
    if (duration == null) {
      if (kDebugMode) {
        debugPrint('AppStartTracker: No startup duration available');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('App Startup Performance');
      debugPrint('═══════════════════════════════════════');
      debugPrint('Startup Duration: ${duration.inMilliseconds}ms');

      // Add breakdown
      if (duration.inSeconds >= 1) {
        debugPrint('  (${duration.inSeconds}s ${duration.inMilliseconds % 1000}ms)');
      }

      // Log memory usage after startup if available
      MemoryProfiler.getCurrentUsageMB().then((memoryMB) {
        debugPrint('Memory After Startup: ${memoryMB.toStringAsFixed(2)} MB');
        debugPrint('═══════════════════════════════════════');
      });
    }
  }

  /// Check if startup tracking is in progress
  static bool get isTracking => _startTime != null && !_isCompleted;

  /// Check if startup tracking is completed
  static bool get isCompleted => _isCompleted;

  /// Check if startup tracking has been started
  static bool get isStarted => _startTime != null;

  /// Get the start time
  static DateTime? get startTime => _startTime;

  /// Get the end time (null if not completed)
  static DateTime? get endTime => _endTime;

  /// Reset tracking state
  ///
  /// Clears all tracking state. Useful for testing or if you want
  /// to track startup multiple times (though not recommended).
  static void reset() {
    _startTime = null;
    _endTime = null;
    _isCompleted = false;

    if (kDebugMode) {
      debugPrint('AppStartTracker: Reset');
    }
  }

  /// Get startup performance summary
  ///
  /// Returns a formatted string with startup performance details.
  /// Returns null if startup hasn't been completed.
  static String? getPerformanceSummary() {
    if (!isCompleted) {
      return null;
    }

    final duration = getStartupDuration()!;
    final buffer = StringBuffer();

    buffer.writeln('App Startup Summary:');
    buffer.writeln('  Duration: ${duration.inMilliseconds}ms');

    // Performance assessment
    if (duration.inMilliseconds < 1000) {
      buffer.writeln('  Status: ✅ Excellent (< 1s)');
    } else if (duration.inMilliseconds < 2000) {
      buffer.writeln('  Status: ✅ Good (< 2s)');
    } else if (duration.inMilliseconds < 3000) {
      buffer.writeln('  Status: ⚠️ Acceptable (< 3s)');
    } else {
      buffer.writeln('  Status: ❌ Slow (> 3s)');
    }

    return buffer.toString().trim();
  }
}
