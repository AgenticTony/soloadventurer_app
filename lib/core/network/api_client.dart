import 'package:dio/dio.dart';

/// Client for making HTTP requests to the API
class ApiClient {
  final Dio _dio;
  bool _isOffline = false;

  /// Creates a new [ApiClient] with the given base URL
  ApiClient({required String baseUrl})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  /// Sets whether the client is in offline mode
  void setOfflineMode(bool offline) {
    _isOffline = offline;
  }

  /// Makes a GET request to the given path
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    if (_isOffline) {
      throw Exception('No internet connection');
    }
    return _dio.get(path, queryParameters: queryParameters);
  }

  /// Makes a POST request to the given path
  Future<Response> post(String path, {dynamic data}) async {
    if (_isOffline) {
      throw Exception('No internet connection');
    }
    return _dio.post(path, data: data);
  }

  /// Makes a PUT request to the given path
  Future<Response> put(String path, {dynamic data}) async {
    if (_isOffline) {
      throw Exception('No internet connection');
    }
    return _dio.put(path, data: data);
  }

  /// Makes a DELETE request to the given path
  Future<Response> delete(String path) async {
    if (_isOffline) {
      throw Exception('No internet connection');
    }
    return _dio.delete(path);
  }

  /// Sets the authorization token for all future requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clears the authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
