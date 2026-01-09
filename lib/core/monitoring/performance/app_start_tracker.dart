import 'package:flutter/foundation.dart';

/// Utility class for tracking app startup performance
class AppStartTracker {
  static DateTime? _startTime;
  static final Map<String, DateTime> _phaseStartTimes = {};

  /// Start tracking app startup time
  static void trackAppStart() {
    _startTime = DateTime.now();
  }

  /// Get the duration since app start
  static Duration? getStartupDuration() {
    if (_startTime == null) return null;
    return DateTime.now().difference(_startTime!);
  }

  /// Log the startup duration
  static void logStartupDuration() {
    final duration = getStartupDuration();
    if (duration != null && kDebugMode) {
      print('App startup took: ${duration.inMilliseconds}ms');
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
