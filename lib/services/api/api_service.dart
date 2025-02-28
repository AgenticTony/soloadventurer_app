import 'package:dio/dio.dart';

/// Interface for API communication
/// This abstraction allows for different implementations (mock, real, etc.)
abstract class ApiService {
  /// Whether the API service is initialized and ready to make requests
  bool get isInitialized;

  /// Perform a GET request to the specified endpoint
  ///
  /// [endpoint] - The API endpoint to call
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  /// Perform a POST request to the specified endpoint
  ///
  /// [endpoint] - The API endpoint to call
  /// [data] - The data to send in the request body
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  /// Perform a PUT request to the specified endpoint
  ///
  /// [endpoint] - The API endpoint to call
  /// [data] - The data to send in the request body
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  /// Perform a DELETE request to the specified endpoint
  ///
  /// [endpoint] - The API endpoint to call
  /// [data] - Optional data to send in the request body
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional Dio request options
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
}
