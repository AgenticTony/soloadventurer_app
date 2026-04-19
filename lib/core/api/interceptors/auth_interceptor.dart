import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';

/// Interceptor for handling authentication in API requests
class AuthInterceptor extends Interceptor {
  /// Threshold for proactive token refresh (5 minutes)
  static const _refreshThreshold = Duration(minutes: 5);

  /// Cached repository reference
  final AuthRepository _authRepository;

  /// The Dio instance to use for retry requests.
  /// Injected via constructor to ensure correct base URL and interceptors.
  final Dio _dio;

  /// Tracks retry count per request to prevent infinite refresh loops.
  /// Keyed by request hashCode to uniquely identify each request.
  final Map<int, int> _retryCount = {};

  /// Maximum number of retries after token refresh.
  static const _maxRetries = 1;

  /// Creates a new [AuthInterceptor]
  ///
  /// [authRepository] is injected via constructor rather than service locator.
  /// [dio] is the handler-provided Dio instance for retry requests.
  AuthInterceptor({
    required AuthRepository authRepository,
    required Dio dio,
  })  : _authRepository = authRepository,
        _dio = dio;

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
          }

          // Wait for in-progress refresh or start a new one
          final newSession = await _performProactiveRefresh();

          // Use the new session if refresh was successful
          if (newSession != null) {
            options.headers['Authorization'] =
                'Bearer ${newSession.accessToken}';
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
      // Guard against infinite retry loops — max 1 retry after refresh.
      final requestId = err.requestOptions.hashCode;
      final retries = _retryCount[requestId] ?? 0;
      if (retries >= _maxRetries) {
        _retryCount.remove(requestId);
        return handler.next(err);
      }
      _retryCount[requestId] = retries + 1;

      try {
        // Try to refresh token
        final session = await _authRepository.refreshToken();

        // Get new token from session
        final newToken = session.accessToken;

        if (newToken.isNotEmpty) {
          // Create new request with updated token
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';

          // Retry using injected Dio instance (correct base URL + interceptors)
          final response = await _dio.fetch(options);
          _retryCount.remove(requestId);
          return handler.resolve(response);
        }

        // If token refresh failed, proceed with error
        _retryCount.remove(requestId);
        return handler.next(err);
      } catch (e) {
        if (kDebugMode) {
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
      }
      final newSession = await _authRepository.refreshToken();
      if (kDebugMode) {
      }
      return newSession;
    } catch (e) {
      if (kDebugMode) {
      }
      // Return null to indicate refresh failure
      // The request will proceed with the old token and 401 will be handled if needed
      return null;
    }
  }
}
