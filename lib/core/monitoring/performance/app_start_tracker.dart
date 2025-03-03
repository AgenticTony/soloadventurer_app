import 'package:flutter/foundation.dart';

/// Utility class for tracking app startup performance
class AppStartTracker {
  static DateTime? _startTime;

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
}
