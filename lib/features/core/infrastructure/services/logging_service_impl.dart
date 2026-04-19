import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/services/logging_service.dart';

part 'logging_service_impl.g.dart';

/// Implementation of [LoggingService] that follows AWS best practices for logging
@Riverpod(keepAlive: true)
class LoggingServiceImpl extends _$LoggingServiceImpl
    implements LoggingService {
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
    // Logging disabled
  }

  @override
  void logError({
    required String feature,
    required String error,
    String? code,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    // Logging disabled
  }

  @override
  void logAuthEvent({
    required String event,
    required String status,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    // Logging disabled
  }

  @override
  void logTokenEvent({
    required String event,
    required String status,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    // Logging disabled
  }
}
