import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

/// Implementation of [LoggingService]
class LoggingServiceImpl implements LoggingService {
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
