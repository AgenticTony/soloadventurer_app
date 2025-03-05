import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// Implementation of ApiService using Dio HTTP client
class DioApiService implements ApiService {
  late Dio _dio;
  bool _isInitialized = false;
  final String _baseUrl;
  final Map<String, String> _defaultHeaders;

  @override
  bool get isInitialized => _isInitialized;

  /// Creates a new DioApiService
  ///
  /// [baseUrl] - The base URL for all API requests
  /// [defaultHeaders] - Default headers to include with all requests
  /// [connectTimeout] - Connection timeout in milliseconds
  /// [receiveTimeout] - Receive timeout in milliseconds
  DioApiService({
    required String baseUrl,
    Map<String, String>? defaultHeaders,
    int connectTimeout = 30000,
    int receiveTimeout = 30000,
  })  : _baseUrl = baseUrl,
        _defaultHeaders = defaultHeaders ?? {} {
    _initializeDio();
  }

  /// Initialize the Dio HTTP client with interceptors and timeouts
  Future<void> _initializeDio() async {
    try {
      // Initialize Dio with base configuration
      _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add interceptors
      _dio.interceptors.addAll([
        _authInterceptor,
        _errorInterceptor,
        if (kDebugMode)
          LogInterceptor(
            requestBody: true,
            responseBody: true,
          ),
      ]);

      _isInitialized = true;
    } catch (e) {
      // Handle initialization error
      rethrow;
    }
  }

  /// Set the authentication token for subsequent requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear the authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  @override
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _handleRequest(() => _dio.get(
          endpoint,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  @override
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _handleRequest(() => _dio.post(
          endpoint,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  @override
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _handleRequest(() => _dio.put(
          endpoint,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  @override
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _handleRequest(() => _dio.delete(
          endpoint,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  /// Handle Dio errors and convert them to a standardized format
  Future<Response> _handleDioError(DioException error) async {
    // Log the error
    debugPrint('API Error: ${error.message}');

    // Create a standardized error response
    final response = Response(
      requestOptions: error.requestOptions,
      statusCode: error.response?.statusCode ?? 500,
      data: error.response?.data ??
          {
            'error': true,
            'message': _getErrorMessage(error),
            'code': _getErrorCode(error),
          },
    );

    // Rethrow the error with the standardized response
    throw DioException(
      requestOptions: error.requestOptions,
      response: response,
      type: error.type,
      error: error.error,
      message: _getErrorMessage(error),
    );
  }

  /// Get a user-friendly error message based on the error type
  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again later.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again later.';
      case DioExceptionType.badResponse:
        return error.response?.statusMessage ?? 'Bad response from server.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return 'No internet connection. Please check your network.';
        }
        return error.message ?? 'An unexpected error occurred.';
    }
  }

  /// Get an error code based on the error type
  String _getErrorCode(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'CONNECTION_TIMEOUT';
      case DioExceptionType.sendTimeout:
        return 'SEND_TIMEOUT';
      case DioExceptionType.receiveTimeout:
        return 'RECEIVE_TIMEOUT';
      case DioExceptionType.badResponse:
        return 'BAD_RESPONSE';
      case DioExceptionType.cancel:
        return 'REQUEST_CANCELLED';
      case DioExceptionType.connectionError:
        return 'CONNECTION_ERROR';
      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return 'NO_INTERNET';
        }
        return 'UNKNOWN_ERROR';
    }
  }

  Future<Response<T>> _handleRequest<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }
}
