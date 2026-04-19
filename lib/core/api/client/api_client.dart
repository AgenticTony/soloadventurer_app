import 'package:dio/dio.dart';
import '../api_service.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/error_interceptor.dart';
import '../../monitoring/performance/network_monitor.dart';
import '../../errors/exceptions.dart';

/// API client for making HTTP requests
///
/// This class is a wrapper around Dio HTTP client with additional
/// functionality like interceptors, error handling, and performance monitoring.
class ApiClient implements ApiService {
  /// Dio HTTP client
  final Dio _dio;

  /// Network monitor for tracking request performance
  final NetworkMonitor _networkMonitor;

  /// Whether the client is in offline mode
  bool _isOffline = false;

  /// Whether the client is in offline mode
  bool get isOffline => _isOffline;

  /// Creates a new [ApiClient] with the given configuration
  ApiClient({
    required String baseUrl,
    required AuthInterceptor authInterceptor,
    required ErrorInterceptor errorInterceptor,
    required NetworkMonitor networkMonitor,
  })  : _dio = Dio(BaseOptions(baseUrl: baseUrl)),
        _networkMonitor = networkMonitor {
    _dio.interceptors.addAll([
      authInterceptor,
      errorInterceptor,
    ]);
  }

  /// Sets whether the client is in offline mode
  @override
  void setOfflineMode(bool offline) {
    _isOffline = offline;
  }

  /// Sets the authorization token for all future requests
  @override
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clears the authorization token
  @override
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) =>
      _request('GET', endpoint);

  @override
  Future<Map<String, dynamic>> post(String endpoint,
          {Map<String, dynamic>? data}) =>
      _request('POST', endpoint, data: data);

  @override
  Future<Map<String, dynamic>> put(String endpoint,
          {Map<String, dynamic>? data}) =>
      _request('PUT', endpoint, data: data);

  @override
  Future<Map<String, dynamic>> delete(String endpoint) =>
      _request('DELETE', endpoint);

  /// Make a PATCH request to the specified endpoint
  Future<Map<String, dynamic>> patch(String endpoint,
          {Map<String, dynamic>? data}) =>
      _request('PATCH', endpoint, data: data);

  /// Template method for all HTTP requests.
  ///
  /// Eliminates the 5 duplicate method bodies by centralizing
  /// offline checks, performance tracking, and error handling.
  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    if (_isOffline) {
      throw const NetworkConnectivityException(
        message: 'No internet connection',
      );
    }

    try {
      final stopwatch = Stopwatch()..start();
      _networkMonitor.trackRequest(endpoint);

      final response = await _dio.request<Map<String, dynamic>>(
        endpoint,
        data: data,
        options: Options(method: method),
      );
      stopwatch.stop();

      _networkMonitor.trackRequestAndResponse(
        path: endpoint,
        duration: stopwatch.elapsed,
        statusCode: response.statusCode ?? 0,
        responseSize: _calculateResponseSize(response),
      );

      return response.data ?? {};
    } catch (error) {
      _handleRequestError(endpoint, error);
      rethrow;
    }
  }

  void _handleRequestError(String endpoint, dynamic error) {
    if (error is DioException) {
      _networkMonitor.trackRequestAndResponse(
        path: endpoint,
        duration: Duration.zero,
        statusCode: error.response?.statusCode ?? 0,
        responseSize: _calculateResponseSize(error.response),
        isError: true,
        errorMessage: error.message,
      );
    } else {
      _networkMonitor.trackRequestAndResponse(
        path: endpoint,
        duration: Duration.zero,
        statusCode: 0,
        responseSize: 0,
        isError: true,
        errorMessage: error.toString(),
      );
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
