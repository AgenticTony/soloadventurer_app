import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/services/logging_service.dart';

part 'logging_service_impl.g.dart';

/// Implementation of [LoggingService] that follows AWS best practices for logging
@Riverpod(keepAlive: true)
class LoggingServiceImpl extends _$LoggingServiceImpl
    implements LoggingService {
  static const String _logPrefix = '[SoloAdventurer]';

  @override
  LoggingService build() {
    return this;
  }

  @override
  void logStateTransition({
    required String feature,
    required String fromState,
    required String toState,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logData = {
      'timestamp': timestamp,
      'type': 'StateTransition',
      'feature': feature,
      'from_state': fromState,
      'to_state': toState,
      if (metadata != null) 'metadata': metadata,
      if (stackTrace != null) 'stack_trace': stackTrace.toString(),
    };

    debugPrint('$_logPrefix State Transition: ${jsonEncode(logData)}');
  }

  @override
  void logError({
    required String feature,
    required String error,
    String? code,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logData = {
      'timestamp': timestamp,
      'type': 'Error',
      'feature': feature,
      'error': error,
      if (code != null) 'code': code,
      if (metadata != null) 'metadata': metadata,
      if (stackTrace != null) 'stack_trace': stackTrace.toString(),
    };

    debugPrint('$_logPrefix Error: ${jsonEncode(logData)}');
  }

  @override
  void logAuthEvent({
    required String event,
    required String status,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logData = {
      'timestamp': timestamp,
      'type': 'AuthEvent',
      'event': event,
      'status': status,
      if (metadata != null) 'metadata': metadata,
      if (stackTrace != null) 'stack_trace': stackTrace.toString(),
    };

    debugPrint('$_logPrefix Auth Event: ${jsonEncode(logData)}');
  }

  @override
  void logTokenEvent({
    required String event,
    required String status,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logData = {
      'timestamp': timestamp,
      'type': 'TokenEvent',
      'event': event,
      'status': status,
      if (metadata != null) 'metadata': metadata,
      if (stackTrace != null) 'stack_trace': stackTrace.toString(),
    };

    debugPrint('$_logPrefix Token Event: ${jsonEncode(logData)}');
  }
}
