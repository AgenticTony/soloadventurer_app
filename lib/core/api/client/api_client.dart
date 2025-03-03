import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/api/interceptors/auth_interceptor.dart';
import 'package:soloadventurer/core/api/interceptors/error_interceptor.dart';
import 'package:soloadventurer/core/monitoring/performance/network_monitor.dart';

/// API client for making HTTP requests
///
/// This class is a wrapper around Dio HTTP client with additional
/// functionality like interceptors, error handling, and performance monitoring.
class ApiClient {
  /// Dio HTTP client
  final Dio _dio;

  /// Network monitor for tracking request performance
  final NetworkMonitor _networkMonitor;

  /// Whether the client is in offline mode
  bool _isOffline = false;

  /// Creates a new [ApiClient] with the given configuration
  ApiClient({
    required String baseUrl,
    required AuthInterceptor authInterceptor,
    required ErrorInterceptor errorInterceptor,
    required NetworkMonitor networkMonitor,
  })  : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.acceptHeader: 'application/json',
            },
          ),
        ),
        _networkMonitor = networkMonitor {
    // Add interceptors
    _dio.interceptors.addAll([
      authInterceptor,
      errorInterceptor,
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
    ]);
  }

  /// Sets whether the client is in offline mode
  void setOfflineMode(bool offline) {
    _isOffline = offline;
  }

  /// Sets the authorization token for all future requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clears the authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Make a GET request to the specified [path]
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (_isOffline) {
      throw Exception('No internet connection');
    }
    return _trackRequest(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      path,
    );
  }

  /// Make a POST request to the specified [path]
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (_isOffline) {
      throw Exception('No internet connection');
    }
    return _trackRequest(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      path,
    );
  }

  /// Make a PUT request to the specified [path]
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _trackRequest(
      () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      path,
    );
  }

  /// Make a DELETE request to the specified [path]
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _trackRequest(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      path,
    );
  }

  /// Make a PATCH request to the specified [path]
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _trackRequest(
      () => _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      path,
    );
  }

  /// Track the request duration and log it to the network monitor
  Future<Response<T>> _trackRequest<T>(
    Future<Response<T>> Function() request,
    String path,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await request();
      stopwatch.stop();

      _networkMonitor.trackRequest(
        path: path,
        duration: stopwatch.elapsed,
        statusCode: response.statusCode ?? 0,
        responseSize: _calculateResponseSize(response),
        isError: false,
      );

      return response;
    } catch (e) {
      stopwatch.stop();

      if (e is DioException) {
        _networkMonitor.trackRequest(
          path: path,
          duration: stopwatch.elapsed,
          statusCode: e.response?.statusCode ?? 0,
          responseSize: _calculateResponseSize(e.response),
          isError: true,
          errorMessage: e.message,
        );
      } else {
        _networkMonitor.trackRequest(
          path: path,
          duration: stopwatch.elapsed,
          statusCode: 0,
          responseSize: 0,
          isError: true,
          errorMessage: e.toString(),
        );
      }

      rethrow;
    }
  }

  /// Calculate the size of the response in bytes
  int _calculateResponseSize(Response? response) {
    if (response == null) return 0;

    int size = 0;

    // Add headers size
    response.headers.forEach((name, values) {
      size += name.length;
      for (final value in values) {
        size += value.length;
      }
    });

    // Add data size
    if (response.data is String) {
      size += (response.data as String).length;
    } else if (response.data is List<int>) {
      size += (response.data as List<int>).length;
    } else if (response.data != null) {
      size += response.data.toString().length;
    }

    return size;
  }
}
