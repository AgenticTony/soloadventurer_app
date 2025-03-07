import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import './api_service.dart';

/// Implementation of [ApiService] using Dio HTTP client
class DioApiService implements ApiService {
  final Dio _dio;
  String? _authToken;
  Map<String, String> _headers = {};

  DioApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        ));

  @override
  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> post(String path,
      {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> put(String path,
      {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> multipart(
    String path, {
    required String method,
    required Map<String, dynamic> files,
  }) async {
    try {
      final formData = FormData.fromMap(files);
      late Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(path, data: formData);
          break;
        case 'PUT':
          response = await _dio.put(path, data: formData);
          break;
        case 'PATCH':
          response = await _dio.patch(path, data: formData);
          break;
        default:
          throw ArgumentError('Unsupported method: $method');
      }

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  @override
  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  @override
  String? getAuthToken() => _authToken;

  @override
  void setHeaders(Map<String, String> headers) {
    _headers = headers;
    _dio.options.headers.addAll(headers);
  }

  @override
  Map<String, String> getHeaders() => Map.from(_headers);

  @override
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  @override
  String getBaseUrl() => _dio.options.baseUrl;

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timed out');
        case DioExceptionType.badResponse:
          return Exception('Server error: ${error.response?.statusCode}');
        case DioExceptionType.cancel:
          return Exception('Request cancelled');
        default:
          return Exception('Network error occurred');
      }
    }
    return Exception('An unexpected error occurred');
  }
}
