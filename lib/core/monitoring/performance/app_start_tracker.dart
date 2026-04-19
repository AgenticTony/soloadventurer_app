import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/monitoring/performance/performance_monitor.dart';
import 'package:soloadventurer/core/monitoring/performance/memory_profiler.dart';

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
  static final Map<String, DateTime> _phaseStartTimes = {};

  /// Start tracking app startup time
  ///
  /// Should be called as early as possible in main() before runApp().
  /// This also integrates with PerformanceMonitor if it's initialized.
  static void trackAppStart() {
    if (_startTime != null) {
      if (kDebugMode) {
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
      }
      return;
    }

    if (_isCompleted) {
      if (kDebugMode) {
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
      }
      return;
    }

    if (kDebugMode) {

      // Add breakdown
      if (duration.inSeconds >= 1) {
      }

      // Log memory usage after startup if available
      MemoryProfiler.getCurrentUsageMB().then((memoryMB) {
      });
    }
  }

  /// Start tracking a phase
  static void startPhase(String phaseName) {
    _phaseStartTimes[phaseName] = DateTime.now();
  }

  /// End tracking a phase and log duration
  static void endPhase(String phaseName) {
    final startTime = _phaseStartTimes[phaseName];
    if (startTime != null && kDebugMode) {
      final duration = DateTime.now().difference(startTime);
      print('$phaseName took: ${duration.inMilliseconds}ms');
      _phaseStartTimes.remove(phaseName);
    }
  }

  /// Log complete startup report
  static void logStartupReport() {
    if (kDebugMode) {
      logStartupDuration();
      print('Startup phases completed');
    }
  }
}
