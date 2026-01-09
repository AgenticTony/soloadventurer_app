import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Utility class for tracking app startup performance
///
/// Tracks multiple phases of app startup to identify bottlenecks.
/// Usage:
/// ```dart
/// // In main.dart
/// AppStartTracker.trackAppStart();
///
/// // After each major initialization phase
/// AppStartTracker.trackPhase('framework_init');
/// await WidgetsFlutterBinding.ensureInitialized();
/// AppStartTracker.endPhase('framework_init');
///
/// // At the end, log all phases
/// AppStartTracker.logStartupReport();
/// ```
class AppStartTracker {
  static DateTime? _appStartTime;
  static final Map<String, DateTime> _phaseStartTimes = {};
  static final Map<String, Duration> _phaseDurations = {};

  /// Start tracking app startup time
  static void trackAppStart() {
    _appStartTime = DateTime.now();
    developer.log('🚀 App startup tracking started', name: 'Performance');
  }

  /// Mark the start of a startup phase
  static void startPhase(String phaseName) {
    _phaseStartTimes[phaseName] = DateTime.now();
    developer.log('⏱️  Phase started: $phaseName', name: 'Performance');
  }

  /// Mark the end of a startup phase
  static void endPhase(String phaseName) {
    final startTime = _phaseStartTimes[phaseName];
    if (startTime == null) {
      developer.log(
        '⚠️  Phase "$phaseName" was not started',
        name: 'Performance',
      );
      return;
    }

    final duration = DateTime.now().difference(startTime);
    _phaseDurations[phaseName] = duration;

    developer.log(
      '✅ Phase completed: $phaseName (${duration.inMilliseconds}ms)',
      name: 'Performance',
    );
  }

  /// Get the duration since app start
  static Duration? getStartupDuration() {
    if (_appStartTime == null) return null;
    return DateTime.now().difference(_appStartTime!);
  }

  /// Get the duration of a specific phase
  static Duration? getPhaseDuration(String phaseName) {
    return _phaseDurations[phaseName];
  }

  /// Log the startup duration (deprecated - use logStartupReport instead)
  static void logStartupDuration() {
    final duration = getStartupDuration();
    if (duration != null && kDebugMode) {
      debugPrint('App startup took: ${duration.inMilliseconds}ms');
    }
  }

  /// Log a comprehensive startup performance report
  static void logStartupReport() {
    if (!kDebugMode) return;

    final totalDuration = getStartupDuration();
    if (totalDuration == null) {
      developer.log('⚠️  App startup was not tracked', name: 'Performance');
      return;
    }

    developer.log(
      '\n'
      '═' * 50 + '\n'
      '📊 App Startup Performance Report\n'
      '═' * 50,
      name: 'Performance',
    );

    // Log total startup time
    final totalMs = totalDuration.inMilliseconds;
    final status = totalMs < 3000 ? '✅' : totalMs < 5000 ? '⚠️ ' : '❌';
    developer.log(
      '$status Total Startup Time: ${totalMs}ms',
      name: 'Performance',
    );

    // Log individual phases
    if (_phaseDurations.isNotEmpty) {
      developer.log('\n📋 Phase Breakdown:', name: 'Performance');

      _phaseDurations.forEach((phase, duration) {
        final ms = duration.inMilliseconds;
        final percent = ((ms / totalMs) * 100).toStringAsFixed(1);
        final phaseStatus = ms < 500 ? '✅' : ms < 1000 ? '⚠️ ' : '❌';
        developer.log(
          '  $phaseStatus $phase: ${ms}ms ($percent%)',
          name: 'Performance',
        );
      });
    }

    // Performance recommendations
    developer.log('\n💡 Recommendations:', name: 'Performance');

    if (totalMs > 3000) {
      developer.log(
        '  ⚠️  Startup time exceeds 3s target',
        name: 'Performance',
      );
    }

    final slowPhases = _phaseDurations.entries
        .where((e) => e.value.inMilliseconds > 500)
        .toList();

    if (slowPhases.isNotEmpty) {
      developer.log(
        '  ⚠️  Slow phases detected (> 500ms):',
        name: 'Performance',
      );
      for (final entry in slowPhases) {
        developer.log(
          '    - ${entry.key}: ${entry.value.inMilliseconds}ms',
          name: 'Performance',
        );
      }
    } else {
      developer.log(
        '  ✅ All phases completed within acceptable time',
        name: 'Performance',
      );
    }

    developer.log('═' * 50 + '\n', name: 'Performance');

    // Log to analytics in production
    if (!kDebugMode) {
      _logToAnalytics(totalMs, _phaseDurations);
    }
  }

  /// Log metrics to analytics service
  static void _logToAnalytics(
    Duration totalDuration,
    Map<String, Duration> phases,
  ) {
    // Implementation depends on your analytics service
    // Example:
    // AnalyticsService.track('app_startup', {
    //   'total_duration_ms': totalDuration.inMilliseconds,
    //   ...{for (var e in phases.entries) e.key: e.value.inMilliseconds},
    // });
  }

  /// Reset all tracking data (useful for testing)
  static void reset() {
    _appStartTime = null;
    _phaseStartTimes.clear();
    _phaseDurations.clear();
  }

  /// Get all tracked phases
  static Map<String, Duration> get allPhases => Map.unmodifiable(_phaseDurations);

  /// Get startup summary as a map (for reporting)
  static Map<String, dynamic> getSummary() {
    final totalDuration = getStartupDuration();
    return {
      'total_duration_ms': totalDuration?.inMilliseconds,
      'phases': {
        for (var e in _phaseDurations.entries)
          e.key: e.value.inMilliseconds,
      },
    };
  }
}
