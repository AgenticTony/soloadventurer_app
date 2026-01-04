import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';

/// Interceptor for handling authentication in API requests
class AuthInterceptor extends Interceptor {
  /// Threshold for proactive token refresh (5 minutes)
  static const _refreshThreshold = Duration(minutes: 5);

  /// Cached repository reference to avoid repeated service locator lookups
  final AuthRepository _authRepository;

  /// Creates a new [AuthInterceptor]
  AuthInterceptor() : _authRepository = getIt<AuthRepository>();

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
      // Get current session to check expiration
      final session = await _authRepository.getSession();

      if (session != null) {
        // Check if token is expiring soon and needs proactive refresh
        if (_shouldRefreshToken(session)) {
          if (kDebugMode) {
            debugPrint('AuthInterceptor: Token expiring soon, triggering proactive refresh');
          }

          // Wait for in-progress refresh or start a new one
          final newSession = await _performProactiveRefresh();

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
      if (kDebugMode) {
        debugPrint('Error in AuthInterceptor: $e');
      }
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
        // Try to refresh token
        final session = await _authRepository.refreshToken();

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
        if (kDebugMode) {
          debugPrint('Error refreshing token: $e');
        }
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
  /// This method relies on the RefreshQueueManager in AuthRepository
  /// to handle concurrent refresh requests and prevent duplicate refresh attempts.
  Future<AuthSession?> _performProactiveRefresh() async {
    try {
      if (kDebugMode) {
        debugPrint('AuthInterceptor: Starting proactive token refresh');
      }
      final newSession = await _authRepository.refreshToken();
      if (kDebugMode) {
        debugPrint('AuthInterceptor: Proactive token refresh successful');
      }
      return newSession;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthInterceptor: Proactive token refresh failed: $e');
      }
      // Return null to indicate refresh failure
      // The request will proceed with the old token and 401 will be handled if needed
      return null;
    }
  }
}
