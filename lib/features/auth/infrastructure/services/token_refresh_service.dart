import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Status of a token refresh operation
enum TokenRefreshStatus {
  /// Refresh operation is in progress
  inProgress,

  /// Refresh operation completed successfully
  success,

  /// Refresh operation failed
  failure,

  /// Refresh operation was cancelled
  cancelled,
}

/// Result of a token refresh operation
class TokenRefreshResult {
  /// The status of the refresh operation
  final TokenRefreshStatus status;

  /// The new auth session if refresh was successful
  final AuthSession? session;

  /// The error that caused the refresh to fail
  final AuthException? error;

  /// The number of retry attempts made
  final int attemptNumber;

  /// The total delay before this result in milliseconds
  final int totalDelayMs;

  const TokenRefreshResult({
    required this.status,
    this.session,
    this.error,
    required this.attemptNumber,
    required this.totalDelayMs,
  });

  /// Creates a success result
  factory TokenRefreshResult.success({
    required AuthSession session,
    required int attemptNumber,
    required int totalDelayMs,
  }) {
    return TokenRefreshResult(
      status: TokenRefreshStatus.success,
      session: session,
      attemptNumber: attemptNumber,
      totalDelayMs: totalDelayMs,
    );
  }

  /// Creates a failure result
  factory TokenRefreshResult.failure({
    required AuthException error,
    required int attemptNumber,
    required int totalDelayMs,
  }) {
    return TokenRefreshResult(
      status: TokenRefreshStatus.failure,
      error: error,
      attemptNumber: attemptNumber,
      totalDelayMs: totalDelayMs,
    );
  }

  /// Creates an in-progress result
  factory TokenRefreshResult.inProgress({
    required int attemptNumber,
  }) {
    return TokenRefreshResult(
      status: TokenRefreshStatus.inProgress,
      attemptNumber: attemptNumber,
      totalDelayMs: 0,
    );
  }

  /// Creates a cancelled result
  factory TokenRefreshResult.cancelled() {
    return const TokenRefreshResult(
      status: TokenRefreshStatus.cancelled,
      attemptNumber: 0,
      totalDelayMs: 0,
    );
  }

  @override
  String toString() {
    return 'TokenRefreshResult{status: $status, attemptNumber: $attemptNumber, totalDelayMs: $totalDelayMs}';
  }
}

/// Service for managing token refresh operations with retry logic and exponential backoff
///
/// This service implements a robust token refresh mechanism with:
/// - Exponential backoff: 1s, 2s, 4s, 8s, 16s, 32s max
/// - Mutex pattern to prevent concurrent refresh attempts
/// - Max retry attempts: 3
/// - Status events emitted via Stream
/// - Graceful network error handling
class TokenRefreshService {
  /// Repository for authentication operations
  final AuthRepository _authRepository;

  /// Maximum number of retry attempts
  static const int maxRetryAttempts = 3;

  /// Maximum backoff delay in seconds
  static const int maxBackoffSeconds = 32;

  /// Stream controller for emitting refresh status events
  final StreamController<TokenRefreshResult> _statusController;

  /// Mutex flag to prevent concurrent refresh attempts
  bool _isRefreshing = false;

  /// Completer for in-progress refresh operation
  Completer<TokenRefreshResult>? _refreshCompleter;

  /// Creates a new [TokenRefreshService]
  TokenRefreshService({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        _statusController = StreamController<TokenRefreshResult>.broadcast();

  /// Stream of token refresh status events
  Stream<TokenRefreshResult> get statusStream => _statusController.stream;

  /// Whether a refresh operation is currently in progress
  bool get isRefreshing => _isRefreshing;

  /// Refresh the authentication token with retry logic and exponential backoff
  ///
  /// If a refresh is already in progress, this method will wait for the existing
  /// operation to complete and return its result (mutex pattern).
  ///
  /// Returns the new [AuthSession] if refresh was successful.
  /// Throws [AuthException] if all retry attempts fail.
  Future<AuthSession> refreshToken() async {
    // If a refresh is already in progress, wait for it to complete (mutex pattern)
    if (_isRefreshing && _refreshCompleter != null) {
      debugPrint('TokenRefreshService: Refresh already in progress, waiting for completion');
      final result = await _refreshCompleter!.future;
      return _handleResult(result);
    }

    // Acquire the mutex lock
    _isRefreshing = true;
    _refreshCompleter = Completer<TokenRefreshResult>();

    debugPrint('TokenRefreshService: Starting token refresh operation');

    try {
      final result = await _performRefreshWithRetry();
      _refreshCompleter!.complete(result);
      return _handleResult(result);
    } finally {
      // Release the mutex lock
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// Performs the refresh operation with retry logic and exponential backoff
  Future<TokenRefreshResult> _performRefreshWithRetry() async {
    int attemptNumber = 0;
    int totalDelayMs = 0;

    while (attemptNumber < maxRetryAttempts) {
      attemptNumber++;
      debugPrint('TokenRefreshService: Refresh attempt $attemptNumber of $maxRetryAttempts');

      // Emit in-progress status
      _emitStatus(TokenRefreshResult.inProgress(attemptNumber: attemptNumber));

      // Calculate backoff delay if this is a retry attempt
      if (attemptNumber > 1) {
        final delayMs = _calculateBackoffDelay(attemptNumber);
        totalDelayMs += delayMs;
        debugPrint('TokenRefreshService: Backing off for ${delayMs}ms before retry');
        await Future.delayed(Duration(milliseconds: delayMs));
      }

      try {
        // Attempt to refresh the token
        final session = await _authRepository.refreshToken();

        debugPrint('TokenRefreshService: Token refresh successful on attempt $attemptNumber');

        final result = TokenRefreshResult.success(
          session: session,
          attemptNumber: attemptNumber,
          totalDelayMs: totalDelayMs,
        );

        _emitStatus(result);
        return result;
      } on AuthException catch (e) {
        debugPrint('TokenRefreshService: Token refresh failed on attempt $attemptNumber: ${e.message}');

        // Check if this is a network error that should be retried
        if (_shouldRetry(e) && attemptNumber < maxRetryAttempts) {
          debugPrint('TokenRefreshService: Retrying due to recoverable error');
          continue;
        }

        // Don't retry if it's the last attempt or error is not recoverable
        final result = TokenRefreshResult.failure(
          error: e,
          attemptNumber: attemptNumber,
          totalDelayMs: totalDelayMs,
        );

        _emitStatus(result);
        return result;
      } catch (e) {
        debugPrint('TokenRefreshService: Unexpected error on attempt $attemptNumber: $e');

        // Wrap unexpected errors in AuthException
        final authException = AuthException(
          'Unexpected error during token refresh: ${e.toString()}',
        );

        final result = TokenRefreshResult.failure(
          error: authException,
          attemptNumber: attemptNumber,
          totalDelayMs: totalDelayMs,
        );

        _emitStatus(result);
        return result;
      }
    }

    // All retry attempts exhausted
    final result = TokenRefreshResult.failure(
      error: const AuthException(
        'Token refresh failed after $maxRetryAttempts attempts',
        code: 'MAX_RETRIES_EXCEEDED',
      ),
      attemptNumber: attemptNumber,
      totalDelayMs: totalDelayMs,
    );

    _emitStatus(result);
    return result;
  }

  /// Calculates exponential backoff delay for a given attempt number
  ///
  /// Implements exponential backoff: 1s, 2s, 4s, 8s, 16s, 32s max
  int _calculateBackoffDelay(int attemptNumber) {
    // Exponential backoff: 2^(attempt-1) seconds
    final delaySeconds = min(
      (1 << (attemptNumber - 1)).clamp(1, maxBackoffSeconds),
      maxBackoffSeconds,
    );

    // Convert to milliseconds
    return delaySeconds * 1000;
  }

  /// Determines if an error should trigger a retry
  bool _shouldRetry(AuthException error) {
    // Retry on network errors
    if (error.code == 'NETWORK_ERROR' ||
        error.code == 'network_connectivity' ||
        error.code == 'network_timeout') {
      return true;
    }

    // Don't retry on credential errors
    if (error.code == 'INVALID_CREDENTIALS' ||
        error.code == 'USER_NOT_FOUND' ||
        error.code == 'EMAIL_NOT_VERIFIED') {
      return false;
    }

    // Default to retrying for other errors
    return true;
  }

  /// Emits a status event to the stream
  void _emitStatus(TokenRefreshResult result) {
    if (!_statusController.isClosed) {
      _statusController.add(result);
    }
  }

  /// Handles the refresh result and returns the session or throws an error
  AuthSession _handleResult(TokenRefreshResult result) {
    switch (result.status) {
      case TokenRefreshStatus.success:
        if (result.session != null) {
          return result.session!;
        }
        throw const AuthException(
          'Token refresh succeeded but no session was returned',
          code: 'NO_SESSION',
        );

      case TokenRefreshStatus.failure:
        throw result.error ??
            const AuthException(
              'Token refresh failed',
              code: 'REFRESH_FAILED',
            );

      case TokenRefreshStatus.cancelled:
        throw const AuthException(
          'Token refresh was cancelled',
          code: 'REFRESH_CANCELLED',
        );

      case TokenRefreshStatus.inProgress:
        throw const AuthException(
          'Token refresh is still in progress',
          code: 'REFRESH_IN_PROGRESS',
        );
    }
  }

  /// Cancels any in-progress refresh operation
  void cancelRefresh() {
    if (_isRefreshing && _refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      debugPrint('TokenRefreshService: Cancelling in-progress refresh');
      _emitStatus(TokenRefreshResult.cancelled());
      _refreshCompleter!.complete(TokenRefreshResult.cancelled());
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// Disposes of the service and closes the status stream
  void dispose() {
    debugPrint('TokenRefreshService: Disposing service');
    cancelRefresh();
    _statusController.close();
  }

  /// Resets the service state (useful for testing)
  void reset() {
    debugPrint('TokenRefreshService: Resetting service state');
    cancelRefresh();
    _isRefreshing = false;
    _refreshCompleter = null;
  }
}
