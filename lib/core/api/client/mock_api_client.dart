import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/api/models/api_response.dart';
import 'package:soloadventurer/core/api/models/api_error.dart';
import 'package:soloadventurer/core/api/interceptors/mock_auth_interceptor.dart';
import 'package:soloadventurer/core/api/interceptors/mock_error_interceptor.dart';
import 'package:soloadventurer/core/monitoring/performance/mock_network_monitor.dart';

/// A mock implementation of [ApiClient] for testing
class MockApiClient extends ApiClient {
  /// Creates a new [MockApiClient] instance
  MockApiClient()
      : super(
          baseUrl: 'http://mock.test',
          authInterceptor: MockAuthInterceptor(),
          errorInterceptor: MockErrorInterceptor(),
          networkMonitor: MockNetworkMonitor(),
        );

  bool _isOffline = false;

  @override
  void setOfflineMode(bool offline) {
    _isOffline = offline;
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (_isOffline) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    // Simulate successful responses based on the endpoint
    switch (path) {
      case '/auth/register':
        final username = (data as Map<String, dynamic>)['username'];
        return Response<T>(
          requestOptions: RequestOptions(path: path),
          data: {
            'user': {
              'id': '1',
              'email': (data)['email'],
              'username': username,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            },
            'token': 'mock_token',
            'refresh_token': 'mock_refresh_token',
            'expires_at':
                DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
          } as T,
          statusCode: 201,
        );

      case '/auth/login':
        return Response<T>(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: {
            'token': 'mock_auth_token',
            'refresh_token': 'mock_refresh_token',
            'expires_at':
                DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
            'user': {
              'id': '1',
              'email': (data as Map<String, dynamic>)['email'],
              'username': 'Test User',
              'created_at': DateTime.now().toIso8601String(),
              'last_login_at': DateTime.now().toIso8601String(),
            },
          } as T,
        );

      case '/auth/refresh':
        return Response<T>(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: {
            'token': 'mock_new_auth_token',
            'refresh_token': 'mock_new_refresh_token',
            'expires_at':
                DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
          } as T,
        );

      case '/auth/logout':
        return Response<T>(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: {'success': true} as T,
        );

      default:
        throw DioException(
          requestOptions: RequestOptions(path: path),
          error: 'Endpoint not mocked',
          type: DioExceptionType.badResponse,
        );
    }
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (_isOffline) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    // Simulate successful responses based on the endpoint
    switch (path) {
      case '/auth/user':
        return Response<T>(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: {
            'id': '1',
            'email': 'test@example.com',
            'username': 'Test User',
            'created_at': DateTime.now().toIso8601String(),
            'last_login_at': DateTime.now().toIso8601String(),
          } as T,
        );

      default:
        throw DioException(
          requestOptions: RequestOptions(path: path),
          error: 'Endpoint not mocked',
          type: DioExceptionType.badResponse,
        );
    }
  }
}
