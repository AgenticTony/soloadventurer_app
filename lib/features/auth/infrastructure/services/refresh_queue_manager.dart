import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';

/// Result of a queued refresh request
class QueuedRefreshResult {
  /// The status of the queued refresh
  final bool success;

  /// The new auth session if refresh was successful
  final AuthSession? session;

  /// The error that caused the refresh to fail
  final AuthException? error;

  /// Whether this request timed out
  final bool timedOut;

  /// Time spent waiting in queue (in milliseconds)
  final int queueTimeMs;

  const QueuedRefreshResult({
    required this.success,
    this.session,
    this.error,
    this.timedOut = false,
    this.queueTimeMs = 0,
  });

  /// Creates a success result
  factory QueuedRefreshResult.success({
    required AuthSession session,
    required int queueTimeMs,
  }) {
    return QueuedRefreshResult(
      success: true,
      session: session,
      queueTimeMs: queueTimeMs,
    );
  }

  /// Creates a failure result
  factory QueuedRefreshResult.failure({
    required AuthException error,
    required int queueTimeMs,
  }) {
    return QueuedRefreshResult(
      success: false,
      error: error,
      queueTimeMs: queueTimeMs,
    );
  }

  /// Creates a timeout result
  factory QueuedRefreshResult.timeout({
    required int queueTimeMs,
  }) {
    return QueuedRefreshResult(
      success: false,
      timedOut: true,
      error: const AuthException(
        'Refresh request timed out',
        code: 'QUEUE_TIMEOUT',
      ),
      queueTimeMs: queueTimeMs,
    );
  }

  @override
  String toString() {
    return 'QueuedRefreshResult{success: $success, timedOut: $timedOut, queueTimeMs: $queueTimeMs}';
  }
}

/// Manager for queuing token refresh requests to prevent duplicate refresh attempts
///
/// This service manages pending token refresh requests by:
/// - Queuing requests when a refresh is already in progress
/// - Resolving all queued requests with the same result
/// - Preventing duplicate refresh calls to the underlying service
/// - Handling queue timeout after 30 seconds
///
/// Example usage:
/// ```dart
/// final queueManager = RefreshQueueManager(
///   refreshService: tokenRefreshService,
/// );
///
/// // Multiple concurrent calls will only trigger one refresh
/// final result1 = await queueManager.enqueueRefresh();
/// final result2 = await queueManager.enqueueRefresh();
/// // Both results will resolve with the same session
/// ```
class RefreshQueueManager {
  /// Service for performing token refresh operations
  final TokenRefreshService _refreshService;

  /// Maximum time to wait in queue before timing out (30 seconds)
  static const Duration queueTimeout = Duration(seconds: 30);

  /// Completers for queued refresh requests
  final List<_QueuedRequest> _queue = [];

  /// Whether a refresh operation is currently in progress
  bool _isRefreshing = false;

  /// Creates a new [RefreshQueueManager]
  RefreshQueueManager({
    required TokenRefreshService refreshService,
  }) : _refreshService = refreshService;

  /// Whether a refresh operation is currently in progress
  bool get isRefreshing => _isRefreshing;

  /// Number of requests currently waiting in the queue
  int get queueLength => _queue.length;

  /// Enqueues a token refresh request
  ///
  /// If a refresh is already in progress, the request will be queued and
  /// resolved when the current refresh completes.
  ///
  /// If no refresh is in progress, a new refresh will be initiated.
  ///
  /// Returns a [QueuedRefreshResult] containing either the new session or
  /// an error. Throws if the request times out after 30 seconds.
  Future<QueuedRefreshResult> enqueueRefresh() async {
    final startTime = DateTime.now();
    debugPrint(
        'RefreshQueueManager: Enqueueing refresh request (queue length: ${_queue.length})');

    // Create a completer for this request
    final completer = Completer<QueuedRefreshResult>();
    final request = _QueuedRequest(
      completer: completer,
      startTime: startTime,
    );

    // Add to queue
    _queue.add(request);

    // If no refresh is in progress, start one
    if (!_isRefreshing) {
      _isRefreshing = true;
      debugPrint('RefreshQueueManager: Starting refresh operation');
      _performRefresh();
    } else {
      debugPrint(
          'RefreshQueueManager: Refresh already in progress, request queued');
    }

    // Set up timeout for this request
    Timer? timeoutTimer;
    timeoutTimer = Timer(queueTimeout, () {
      if (!completer.isCompleted) {
        final queueTime = DateTime.now().difference(startTime).inMilliseconds;
        debugPrint(
            'RefreshQueueManager: Request timed out after ${queueTime}ms');
        completer.complete(QueuedRefreshResult.timeout(queueTimeMs: queueTime));
      }
    });

    // Wait for either completion or timeout
    final result = await completer.future;
    timeoutTimer.cancel(); // Cancel timeout timer

    // Remove from queue
    _queue.remove(request);

    return result;
  }

  /// Performs the refresh operation and resolves all queued requests
  Future<void> _performRefresh() async {
    debugPrint('RefreshQueueManager: Performing refresh operation');

    try {
      // Perform the actual refresh
      final session = await _refreshService.refreshToken();

      debugPrint(
          'RefreshQueueManager: Refresh successful, resolving ${_queue.length} queued requests');

      // Resolve all queued requests with the same result
      final now = DateTime.now();
      for (final request in _queue) {
        if (!request.completer.isCompleted) {
          final queueTime = now.difference(request.startTime).inMilliseconds;
          request.completer.complete(
            QueuedRefreshResult.success(
              session: session,
              queueTimeMs: queueTime,
            ),
          );
        }
      }

      // Clear the queue
      _queue.clear();
    } on AuthException catch (e) {
      debugPrint('RefreshQueueManager: Refresh failed: ${e.message}');

      // Resolve all queued requests with the error
      final now = DateTime.now();
      for (final request in _queue) {
        if (!request.completer.isCompleted) {
          final queueTime = now.difference(request.startTime).inMilliseconds;
          request.completer.complete(
            QueuedRefreshResult.failure(
              error: e,
              queueTimeMs: queueTime,
            ),
          );
        }
      }

      // Clear the queue
      _queue.clear();
    } catch (e) {
      debugPrint('RefreshQueueManager: Unexpected error during refresh: $e');

      // Wrap unexpected errors in AuthException
      final authException = AuthException(
        'Unexpected error during token refresh: ${e.toString()}',
      );

      // Resolve all queued requests with the error
      final now = DateTime.now();
      for (final request in _queue) {
        if (!request.completer.isCompleted) {
          final queueTime = now.difference(request.startTime).inMilliseconds;
          request.completer.complete(
            QueuedRefreshResult.failure(
              error: authException,
              queueTimeMs: queueTime,
            ),
          );
        }
      }

      // Clear the queue
      _queue.clear();
    } finally {
      // Reset the refreshing flag
      _isRefreshing = false;
    }
  }

  /// Clears all queued requests and cancels any pending refresh
  ///
  /// This will resolve all pending requests with a timeout error.
  void clearQueue() {
    debugPrint(
        'RefreshQueueManager: Clearing queue (${_queue.length} requests)');

    final now = DateTime.now();
    for (final request in _queue) {
      if (!request.completer.isCompleted) {
        final queueTime = now.difference(request.startTime).inMilliseconds;
        request.completer.complete(
          QueuedRefreshResult.timeout(queueTimeMs: queueTime),
        );
      }
    }

    _queue.clear();
    _isRefreshing = false;
  }

  /// Disposes of the manager and clears all queued requests
  void dispose() {
    debugPrint('RefreshQueueManager: Disposing manager');
    clearQueue();
  }

  /// Resets the manager state (useful for testing)
  void reset() {
    debugPrint('RefreshQueueManager: Resetting manager state');
    clearQueue();
  }
}

/// Internal class representing a queued refresh request
class _QueuedRequest {
  /// Completer for this request
  final Completer<QueuedRefreshResult> completer;

  /// Time when this request was queued
  final DateTime startTime;

  _QueuedRequest({
    required this.completer,
    required this.startTime,
  });
}
