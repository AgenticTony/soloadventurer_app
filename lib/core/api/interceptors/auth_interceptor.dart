import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';

/// Interceptor for handling authentication in API requests
class AuthInterceptor extends Interceptor {
  /// Threshold for proactive token refresh (5 minutes)
  static const _refreshThreshold = Duration(minutes: 5);

  /// Flag to track if a refresh is currently in progress
  bool _isRefreshing = false;

  /// Add authentication token to requests
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip authentication for login/register endpoints
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    try {
      // Get auth repository from service locator
      final authRepository = getIt<AuthRepository>();

      // Get current session to check expiration
      final session = await authRepository.getSession();

      if (session != null) {
        // Check if token is expiring soon and needs proactive refresh
        if (_shouldRefreshToken(session)) {
          debugPrint('AuthInterceptor: Token expiring soon, triggering proactive refresh');

          // Wait for in-progress refresh or start a new one
          final newSession = await _performProactiveRefresh(authRepository);

          // Use the new session if refresh was successful
          if (newSession != null) {
            options.headers['Authorization'] = 'Bearer ${newSession.accessToken}';
            return handler.next(options);
          }
          // If refresh failed, continue with the existing token
          // The server will return 401 if the token is expired, which will be handled in onError
        }

        // Add token to request headers
        options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      }

      return handler.next(options);
    } catch (e) {
      debugPrint('Error in AuthInterceptor: $e');
      return handler.next(options);
    }
  }

  /// Handle authentication errors
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if error is due to authentication
    if (err.response?.statusCode == 401) {
      try {
        // Get auth repository from service locator
        final authRepository = getIt<AuthRepository>();

        // Try to refresh token
        final session = await authRepository.refreshToken();

        // Get new token from session
        final newToken = session.accessToken;

        if (newToken.isNotEmpty) {
          // Create new request with updated token
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';

          // Retry request with new token
          final response = await Dio().fetch(options);
          return handler.resolve(response);
        }

        // If token refresh failed, proceed with error
        return handler.next(err);
      } catch (e) {
        debugPrint('Error refreshing token: $e');
        return handler.next(err);
      }
    }

    // For other errors, proceed normally
    return handler.next(err);
  }

  /// Check if the endpoint is an authentication endpoint
  bool _isAuthEndpoint(String path) {
    final authEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/auth/reset-password',
    ];

    return authEndpoints.any((endpoint) => path.contains(endpoint));
  }

  /// Checks if a token should be refreshed based on expiration time
  bool _shouldRefreshToken(AuthSession session) {
    // Check if token has no expiration information
    if (session.expiresAt == DateTime(0)) {
      return false;
    }

    // Calculate time until expiration
    final timeUntilExpiration = session.expiresAt.difference(DateTime.now());

    // Refresh if token expires in less than the threshold
    return timeUntilExpiration < _refreshThreshold;
  }

  /// Performs a proactive token refresh
  ///
  /// This method implements a mutex-like pattern to ensure that only one
  /// refresh operation is in progress at a time. Multiple concurrent requests
  /// will wait for the same refresh operation to complete.
  Future<AuthSession?> _performProactiveRefresh(AuthRepository authRepository) async {
    // If a refresh is already in progress, wait for it to complete
    if (_isRefreshing) {
      debugPrint('AuthInterceptor: Refresh already in progress, waiting...');
      // Wait a bit for the refresh to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Try to get the new session
      try {
        return await authRepository.getSession();
      } catch (e) {
        debugPrint('AuthInterceptor: Error waiting for refresh: $e');
        return null;
      }
    }

    // Start a new refresh operation
    _isRefreshing = true;
    try {
      debugPrint('AuthInterceptor: Starting proactive token refresh');
      final newSession = await authRepository.refreshToken();
      debugPrint('AuthInterceptor: Proactive token refresh successful');
      return newSession;
    } catch (e) {
      debugPrint('AuthInterceptor: Proactive token refresh failed: $e');
      // Return null to indicate refresh failure
      // The request will proceed with the old token and 401 will be handled if needed
      return null;
    } finally {
      _isRefreshing = false;
    }
  }
}
