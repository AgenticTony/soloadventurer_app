import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Interceptor for handling authentication in API requests
class AuthInterceptor extends Interceptor {
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

      // Get access token
      final token = await authRepository.getAccessToken();

      if (token != null && token.isNotEmpty) {
        // Add token to request headers
        options.headers['Authorization'] = 'Bearer $token';
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
}
