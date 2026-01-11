import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

/// Implementation of [LoggingService]
class LoggingServiceImpl implements LoggingService {
  @override
  void logStateTransition({
    required String feature,
    required String fromState,
    required String toState,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      print('STATE TRANSITION [$feature]: $fromState -> $toState');
      if (metadata != null) {
        print('Metadata: $metadata');
      }
      if (stackTrace != null) {
        print('STACK: $stackTrace');
      }
    }
  }

  @override
  void logError({
    required String feature,
    required String error,
    String? code,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final codeStr = code != null ? ' [$code]' : '';
      print('ERROR [$feature]$codeStr: $error');
      if (metadata != null) {
        print('Metadata: $metadata');
      }
      if (stackTrace != null) {
        print('STACK: $stackTrace');
      }
    }
  }

  @override
  void logAuthEvent({
    required String event,
    required String status,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      print('AUTH EVENT: $event - $status');
      if (metadata != null) {
        print('Metadata: $metadata');
      }
      if (stackTrace != null) {
        print('STACK: $stackTrace');
      }
    }
  }

  @override
  void logTokenEvent({
    required String event,
    required String status,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      print('TOKEN EVENT: $event - $status');
      if (metadata != null) {
        print('Metadata: $metadata');
      }
      if (stackTrace != null) {
        print('STACK: $stackTrace');
      }
    }
  }

  @override
  void logTokenRotation({
    required Object oldSession,
    required Object newSession,
    String? reason,
  }) {
    if (kDebugMode) {
      print('TOKEN ROTATION: ${reason ?? "No reason provided"}');
      print('Old session: $oldSession');
      print('New session: $newSession');
    }
  }

  @override
  void logTokenBlacklist({
    required String token,
    required String reason,
    DateTime? expiryTime,
  }) {
    if (kDebugMode) {
      print('TOKEN BLACKLIST: $reason');
      print('Token: ${token.substring(0, 10)}...');
      if (expiryTime != null) {
        print('Expires: $expiryTime');
      }
    }
  }

  @override
  void logTokenRefresh({
    required bool success,
    String? error,
    int attemptNumber = 1,
    Map<String, dynamic>? additionalInfo,
  }) {
    if (kDebugMode) {
      final status = success ? 'SUCCESS' : 'FAILED';
      print('TOKEN REFRESH (attempt $attemptNumber): $status');
      if (error != null) {
        print('Error: $error');
      }
      if (additionalInfo != null) {
        print('Info: $additionalInfo');
      }
    }
  }

  // Additional convenience methods
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('DEBUG: $message');
      if (error != null) {
        print('ERROR: $error');
      }
      if (stackTrace != null) {
        print('STACK: $stackTrace');
      }
    }
  }

  void info(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('INFO: $message');
      if (error != null) {
        print('ERROR: $error');
      }
      if (stackTrace != null) {
        print('STACK: $stackTrace');
      }
    }
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('WARNING: $message');
      if (error != null) {
        print('ERROR: $error');
      }
      if (stackTrace != null) {
        print('STACK: $stackTrace');
      }
    }
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('ERROR: $message');
      if (error != null) {
        print('ERROR DETAILS: $error');
      }
      if (stackTrace != null) {
        print('STACK: $stackTrace');
      }
    }
  }

  void critical(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('CRITICAL: $message');
      if (error != null) {
        print('ERROR DETAILS: $error');
      }
      if (stackTrace != null) {
        print('STACK: $stackTrace');
      }
    }
  }
}
