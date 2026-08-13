// lib/core/utils/error_mapping.dart
//
// Centralized error mapping + logging utility.
//
// The audit (2026-08-12) found 1,219 catch blocks vs 244 rethrow —
// failures swallowed without logging. Any production incident is currently
// undiagnosable.
//
// This utility provides:
//   - ErrorMapping.log() — log the error with stack trace, return the error
//   - ErrorMapping.logAndRethrow() — log then rethrow (for repos that propagate)
//   - ErrorMapping.logAndReturn() — log then return a typed Failure/Result
//
// Usage (replacing silent catch blocks):
//
//   // Before (silent swallow — the anti-pattern):
//   } catch (e) {
//     return null;
//   }
//
//   // After (logged, diagnosable):
//   } catch (e, st) {
//     return ErrorMapping.logAndReturn(
//       'createTrip',
//       e,
//       stackTrace: st,
//       fallback: () => null,
//     );
//   }
//
// For repository layers that should propagate errors:
//
//   } catch (e, st) {
//     ErrorMapping.logAndRethrow('getMatches', e, stackTrace: st);
//   }

import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/monitoring/app_logger.dart';

/// Centralized error mapping that ensures every caught error is logged
/// with its stack trace before being handled.
///
/// This is the project's single point for error observability. Every
/// catch block should route through here so no failure is invisible.
abstract final class ErrorMapping {
  /// Log an error with context + stack trace. Returns the error for chaining.
  ///
  /// ```dart
  /// } catch (e, st) {
  ///   ErrorMapping.log('MatchingRepository.getMatches', e, stackTrace: st);
  ///   // continue handling...
  /// }
  /// ```
  static void log(
    String operation,
    Object? error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final contextStr = context != null ? ' context=$context' : '';
    AppLogger.e(
      '$operation failed: $error$contextStr',
      error,
    );
    if (kDebugMode && stackTrace != null) {
      debugPrint('   Stack: ${stackTrace.toString().split('\n').take(5).join('\n   ')}');
    }
  }

  /// Log an error then rethrow it. For repository layers that propagate
  /// errors to the domain/presentation layer.
  ///
  /// ```dart
  /// } catch (e, st) {
  ///   ErrorMapping.logAndRethrow('MatchingRepository.getMatches', e, stackTrace: st);
  /// }
  /// ```
  static Never logAndRethrow(
    String operation,
    Object? error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    log(operation, error, stackTrace: stackTrace, context: context);
    Error.throwWithStackTrace(error ?? Exception('Unknown error'), stackTrace ?? StackTrace.current);
  }

  /// Log an error then return a fallback value. For datasources/repositories
  /// that return null/empty on failure (but now at least log it).
  ///
  /// ```dart
  /// } catch (e, st) {
  ///   return ErrorMapping.logAndReturn(
  ///     'getProfile', e, stackTrace: st, fallback: () => null,
  ///   );
  /// }
  /// ```
  static T logAndReturn<T>(
    String operation,
    Object? error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    required T Function() fallback,
  }) {
    log(operation, error, stackTrace: stackTrace, context: context);
    return fallback();
  }

  /// Log a warning (non-fatal error that was recovered from).
  ///
  /// ```dart
  /// } catch (e) {
  ///   ErrorMapping.logWarning('cache miss, using network', e);
  ///   // fall through to network fetch...
  /// }
  /// ```
  static void logWarning(
    String operation,
    Object? error, {
    Map<String, dynamic>? context,
  }) {
    final contextStr = context != null ? ' context=$context' : '';
    AppLogger.w('$operation (recovered): $error$contextStr');
  }
}
