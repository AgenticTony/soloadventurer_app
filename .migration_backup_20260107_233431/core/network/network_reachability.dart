import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/core/config/app_config.dart';

/// Result of a network reachability test
class NetworkReachabilityResult {
  /// Whether the server is reachable
  final bool isReachable;

  /// The endpoint that was tested
  final String endpoint;

  /// HTTP status code (if available)
  final int? statusCode;

  /// Response time in milliseconds
  final int? responseTimeMs;

  /// Error message (if test failed)
  final String? errorMessage;

  /// Timestamp when this test was performed
  final DateTime timestamp;

  /// Creates a new [NetworkReachabilityResult] instance
  const NetworkReachabilityResult({
    required this.isReachable,
    required this.endpoint,
    this.statusCode,
    this.responseTimeMs,
    this.errorMessage,
    required this.timestamp,
  });

  /// Creates a successful reachability result
  factory NetworkReachabilityResult.reachable({
    required String endpoint,
    int? statusCode,
    required int responseTimeMs,
  }) {
    return NetworkReachabilityResult(
      isReachable: true,
      endpoint: endpoint,
      statusCode: statusCode,
      responseTimeMs: responseTimeMs,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a failed reachability result
  factory NetworkReachabilityResult.unreachable({
    required String endpoint,
    required String errorMessage,
  }) {
    return NetworkReachabilityResult(
      isReachable: false,
      endpoint: endpoint,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a result from a cached value
  factory NetworkReachabilityResult.cached(NetworkReachabilityResult original) {
    return NetworkReachabilityResult(
      isReachable: original.isReachable,
      endpoint: original.endpoint,
      statusCode: original.statusCode,
      responseTimeMs: original.responseTimeMs,
      errorMessage: original.errorMessage,
      timestamp: original.timestamp,
    );
  }

  @override
  String toString() {
    return 'NetworkReachabilityResult{isReachable: $isReachable, '
        'endpoint: $endpoint, statusCode: $statusCode, '
        'responseTimeMs: $responseTimeMs, errorMessage: $errorMessage, '
        'timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NetworkReachabilityResult &&
        other.isReachable == isReachable &&
        other.endpoint == endpoint &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode =>
      isReachable.hashCode ^ endpoint.hashCode ^ statusCode.hashCode;
}

/// Service to test actual network reachability beyond basic connectivity checks
///
/// This service performs real HTTP requests to test if the API server is
/// reachable, not just if the device has network connectivity. It includes
/// caching with TTL to avoid excessive network requests.
///
/// Example usage:
/// ```dart
/// final reachabilityService = NetworkReachabilityService();
///
/// // Test if API is reachable
/// final result = await reachabilityService.checkReachability();
/// if (result.isReachable) {
///   print('API is reachable! Response time: ${result.responseTimeMs}ms');
/// } else {
///   print('API unreachable: ${result.errorMessage}');
/// }
///
/// // Clear cache to force a new test
/// reachabilityService.clearCache();
/// ```
class NetworkReachabilityService {
  /// Dio HTTP client for making requests
  final Dio _dio;

  /// Test endpoint path (relative to base URL)
  final String _testEndpointPath;

  /// Request timeout in milliseconds
  final int _timeoutMs;

  /// Cache time-to-live in milliseconds
  final int _cacheTtlMs;

  /// Cached reachability result
  NetworkReachabilityResult? _cachedResult;

  /// Timer for clearing cache
  Timer? _cacheTimer;

  /// Creates a new [NetworkReachabilityService] instance
  ///
  /// [dio] - Dio HTTP client (optional, creates default if not provided)
  /// [testEndpointPath] - Path to test endpoint (default: '/health')
  /// [timeoutMs] - Request timeout in milliseconds (default: 5000ms)
  /// [cacheTtlMs] - Cache TTL in milliseconds (default: 30000ms / 30 seconds)
  NetworkReachabilityService({
    Dio? dio,
    String testEndpointPath = '/health',
    int timeoutMs = 5000,
    int cacheTtlMs = 30000,
  })  : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: Duration(milliseconds: timeoutMs),
              receiveTimeout: Duration(milliseconds: timeoutMs),
              sendTimeout: Duration(milliseconds: timeoutMs),
            )),
        _testEndpointPath = testEndpointPath,
        _timeoutMs = timeoutMs,
        _cacheTtlMs = cacheTtlMs {
    debugPrint(
        '🔍 NetworkReachabilityService initialized (timeout: ${timeoutMs}ms, '
        'cache TTL: ${cacheTtlMs}ms)');
  }

  /// Check if the API server is reachable
  ///
  /// This method performs an actual HTTP request to test server reachability.
  /// Results are cached for [cacheTtlMs] to avoid excessive requests.
  ///
  /// Returns [NetworkReachabilityResult] with test outcome.
  Future<NetworkReachabilityResult> checkReachability() async {
    // Check if we have a valid cached result
    if (_cachedResult != null) {
      final age = DateTime.now().difference(_cachedResult!.timestamp);
      if (age.inMilliseconds < _cacheTtlMs) {
        debugPrint('🔍 Using cached reachability result '
            '(age: ${age.inSeconds}s, valid for: ${(_cacheTtlMs - age.inMilliseconds) / 1000}s)');
        return NetworkReachabilityResult.cached(_cachedResult!);
      } else {
        debugPrint('🔍 Cached result expired (age: ${age.inSeconds}s)');
        _cachedResult = null;
      }
    }

    // Perform actual reachability test
    debugPrint('🔍 Testing network reachability to $_testEndpointPath...');
    final stopwatch = Stopwatch()..start();

    try {
      final fullUrl = AppConfig.apiBaseUrl + _testEndpointPath;

      // Use HEAD request first (lighter than GET)
      // Fall back to GET if HEAD fails with 405 Method Not Allowed
      Response? response;
      try {
        response = await _dio.head(
          fullUrl,
          options: Options(
            receiveDataWhenStatusError: true,
            validateStatus: (status) => status != null && status < 500,
          ),
        );
      } on DioException catch (e) {
        // If HEAD is not allowed, try GET
        if (e.response?.statusCode == 405) {
          debugPrint('🔍 HEAD not allowed, trying GET...');
          response = await _dio.get(
            fullUrl,
            options: Options(
              receiveDataWhenStatusError: true,
              validateStatus: (status) => status != null && status < 500,
            ),
          );
        } else {
          rethrow;
        }
      }

      stopwatch.stop();

      // Check if response indicates server is reachable
      final isReachable = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 500;

      final result = isReachable
          ? NetworkReachabilityResult.reachable(
              endpoint: fullUrl,
              statusCode: response.statusCode,
              responseTimeMs: stopwatch.elapsedMilliseconds,
            )
          : NetworkReachabilityResult.unreachable(
              endpoint: fullUrl,
              errorMessage: 'Server returned status ${response.statusCode}',
            );

      _updateCache(result);

      debugPrint(
          '🔍 Reachability test result: ${result.isReachable ? "REACHABLE" : "UNREACHABLE"} '
          '(${stopwatch.elapsedMilliseconds}ms, status: ${result.statusCode})');

      return result;
    } on DioException catch (e) {
      stopwatch.stop();

      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout after ${stopwatch.elapsedMilliseconds}ms';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Connection error: ${e.message}';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Server error: ${e.response?.statusCode}';
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      final result = NetworkReachabilityResult.unreachable(
        endpoint: AppConfig.apiBaseUrl + _testEndpointPath,
        errorMessage: errorMessage,
      );

      _updateCache(result);

      debugPrint('🔍 Reachability test failed: $errorMessage');

      return result;
    } catch (e) {
      stopwatch.stop();

      final result = NetworkReachabilityResult.unreachable(
        endpoint: AppConfig.apiBaseUrl + _testEndpointPath,
        errorMessage: 'Unexpected error: ${e.toString()}',
      );

      _updateCache(result);

      debugPrint('🔍 Reachability test failed with unexpected error: $e');

      return result;
    }
  }

  /// Update the cached result and set cache expiration timer
  void _updateCache(NetworkReachabilityResult result) {
    _cachedResult = result;

    // Cancel existing timer
    _cacheTimer?.cancel();

    // Set new timer to clear cache
    _cacheTimer = Timer(Duration(milliseconds: _cacheTtlMs), () {
      debugPrint('🔍 Clearing expired reachability cache');
      _cachedResult = null;
      _cacheTimer = null;
    });
  }

  /// Clear the cached reachability result
  ///
  /// Call this to force a new reachability test on the next check.
  void clearCache() {
    _cachedResult = null;
    _cacheTimer?.cancel();
    _cacheTimer = null;
    debugPrint('🔍 Reachability cache cleared manually');
  }

  /// Get the cached result (if any) without performing a new test
  ///
  /// Returns null if no cached result exists or cache has expired.
  NetworkReachabilityResult? get cachedResult {
    if (_cachedResult != null) {
      final age = DateTime.now().difference(_cachedResult!.timestamp);
      if (age.inMilliseconds < _cacheTtlMs) {
        return _cachedResult;
      }
    }
    return null;
  }

  /// Check if cached result exists and is still valid
  bool get hasValidCache {
    return cachedResult != null;
  }

  /// Dispose of resources
  ///
  /// Call this when the service is no longer needed to prevent memory leaks.
  void dispose() {
    _cacheTimer?.cancel();
    _cacheTimer = null;
    _cachedResult = null;
    _dio.close();
    debugPrint('🔍 NetworkReachabilityService disposed');
  }
}
