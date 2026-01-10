import 'dart:async';
import 'package:flutter/foundation.dart';

/// Result of a debounced operation
class DebounceResult<T> {
  /// The value returned from the debounced operation
  final T? value;

  /// Whether the operation was executed (false if cancelled)
  final bool executed;

  /// Timestamp when the operation completed
  final DateTime timestamp;

  /// The input that triggered this result
  final String input;

  const DebounceResult({
    this.value,
    required this.executed,
    required this.timestamp,
    required this.input,
  });

  @override
  String toString() {
    return 'DebounceResult('
        'value: $value, '
        'executed: $executed, '
        'input: $input, '
        'timestamp: $timestamp)';
  }
}

/// A utility class for debouncing operations (e.g., search queries, filter updates)
///
/// Debouncing ensures that rapidly triggered operations are only executed
/// after a specified period of inactivity. This is essential for:
/// - Search queries (avoid API calls on every keystroke)
/// - Filter updates (wait for user to finish selecting filters)
/// - Auto-save operations (save only after user stops typing)
///
/// Example usage:
/// ```dart
/// final debouncer = Debouncer<String>(duration: const Duration(milliseconds: 500));
///
/// // In a search field callback
/// debouncer.debounce(
///   input: searchQuery,
///   action: (query) async {
///     final results = await repository.search(query);
///     return results;
///   },
///   onComplete: (result) {
///     if (result.executed) {
///       showResults(result.value);
///     }
///   },
/// );
/// ```
class Debouncer<T> {
  /// Timer for the debounce delay
  Timer? _timer;

  /// The most recent input value
  String? _lastInput;

  /// Whether a debounce operation is currently pending
  bool _isPending = false;

  /// Timestamp of the last input
  DateTime? _lastInputTime;

  /// Number of times debounce has been called
  int _callCount = 0;

  /// Number of times the action has been executed
  int _executionCount = 0;

  /// Duration to wait before executing the action
  final Duration duration;

  /// Optional callback for when debounce starts
  final VoidCallback? onDebounceStart;

  /// Optional callback for when debounce completes
  final void Function(DebounceResult<T>)? onComplete;

  /// Whether to log debug messages
  final bool debug;

  Debouncer({
    this.duration = const Duration(milliseconds: 500),
    this.onDebounceStart,
    this.onComplete,
    this.debug = false,
  });

  /// Debounce an operation with the given input
  ///
  /// If called multiple times within [duration], only the last call's
  /// [action] will be executed after [duration] has passed since the last call.
  ///
  /// Parameters:
  /// - [input]: The input value (e.g., search query, filter state)
  /// - [action]: The async operation to execute (e.g., API call)
  /// - [onCompleteOverride]: Optional callback to override the default [onComplete]
  ///
  /// Returns the debounced result (may be null if cancelled)
  Future<void> debounce({
    required String input,
    required Future<T> Function() action,
    void Function(DebounceResult<T>)? onCompleteOverride,
  }) async {
    // Cancel any pending debounce
    _timer?.cancel();

    _lastInput = input;
    _lastInputTime = DateTime.now();
    _callCount++;
    _isPending = true;

    if (debug) {
      debugPrint('[Debouncer] Debouncing with input: "$input" '
          '(call #$_callCount)');
    }

    // Notify debounce started
    onDebounceStart?.call();

    // Start new timer
    _timer = Timer(duration, () async {
      if (_lastInput == null) return;

      _isPending = false;
      _executionCount++;
      final currentInput = _lastInput!;

      if (debug) {
        debugPrint('[Debouncer] Executing action for input: "$currentInput" '
            '(execution #$_executionCount)');
      }

      try {
        // Execute the action
        final value = await action();

        final result = DebounceResult<T>(
          value: value,
          executed: true,
          timestamp: DateTime.now(),
          input: currentInput,
        );

        if (debug) {
          debugPrint('[Debouncer] Action completed with value: $value');
        }

        // Call completion callback
        (onCompleteOverride ?? onComplete)?.call(result);
      } catch (error, stackTrace) {
        if (debug) {
          debugPrint('[Debouncer] Action failed: $error');
          debugPrint(stackTrace.toString());
        }

        // Create error result
        final result = DebounceResult<T>(
          value: null,
          executed: true,
          timestamp: DateTime.now(),
          input: currentInput,
        );

        (onCompleteOverride ?? onComplete)?.call(result);
      }

      _timer = null;
    });
  }

  /// Cancel any pending debounce operation
  ///
  /// This prevents the action from executing if debounce is still pending.
  /// Returns true if an operation was cancelled, false if nothing was pending.
  bool cancel() {
    if (_timer != null && _isPending) {
      _timer!.cancel();
      _timer = null;
      _isPending = false;

      if (debug) {
        debugPrint('[Debouncer] Cancelled pending operation');
      }

      return true;
    }
    return false;
  }

  /// Check if a debounce operation is currently pending
  bool get isPending => _isPending;

  /// Get the last input value (may be null if never called)
  String? get lastInput => _lastInput;

  /// Get the timestamp of the last input (may be null if never called)
  DateTime? get lastInputTime => _lastInputTime;

  /// Get the number of times debounce has been called
  int get callCount => _callCount;

  /// Get the number of times the action has been executed
  int get executionCount => _executionCount;

  /// Reset the debouncer state (clear all counters)
  void reset() {
    _timer?.cancel();
    _timer = null;
    _lastInput = null;
    _lastInputTime = null;
    _isPending = false;
    _callCount = 0;
    _executionCount = 0;

    if (debug) {
      debugPrint('[Debouncer] Reset');
    }
  }

  /// Dispose the debouncer (cleanup resources)
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  String toString() {
    return 'Debouncer('
        'duration: ${duration.inMilliseconds}ms, '
        'isPending: $isPending, '
        'callCount: $callCount, '
        'executionCount: $executionCount, '
        'lastInput: "$_lastInput")';
  }
}

/// A simplified debouncer for synchronous operations
///
/// Use this when you need to debounce operations that don't return a value
/// or when you don't need to track the result.
///
/// Example:
/// ```dart
/// final debouncer = SimpleDebouncer(duration: const Duration(milliseconds: 300));
///
/// onChanged: (value) {
///   debouncer.debounce(() {
///     updateFilter(value);
///   });
/// }
/// ```
class SimpleDebouncer {
  final Debouncer<void> _debouncer;

  /// Duration to wait before executing the action
  Duration get duration => _debouncer.duration;

  /// Check if a debounce operation is currently pending
  bool get isPending => _debouncer.isPending;

  /// Create a simple debouncer
  SimpleDebouncer({
    Duration duration = const Duration(milliseconds: 300),
    VoidCallback? onDebounceStart,
    VoidCallback? onDebounceComplete,
    bool debug = false,
  }) : _debouncer = Debouncer<void>(
          duration: duration,
          onDebounceStart: onDebounceStart,
          onComplete: (result) => onDebounceComplete?.call(),
          debug: debug,
        );

  /// Debounce a synchronous operation
  void debounce(VoidCallback action) {
    _debouncer.debounce(
      input: DateTime.now().toIso8601String(),
      action: () async {
        action();
        return;
      },
    );
  }

  /// Cancel any pending debounce operation
  bool cancel() => _debouncer.cancel();

  /// Reset the debouncer state
  void reset() => _debouncer.reset();

  /// Dispose the debouncer
  void dispose() => _debouncer.dispose();
}
