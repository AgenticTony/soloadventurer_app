import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Class to store information about a network request
class NetworkRequestInfo {
  /// The path of the request
  final String path;

  /// The duration of the request
  final Duration duration;

  /// The HTTP status code of the response
  final int statusCode;

  /// The size of the response in bytes
  final int responseSize;

  /// Whether the request resulted in an error
  final bool isError;

  /// The error message if the request resulted in an error
  final String? errorMessage;

  /// The timestamp when the request was made
  final DateTime timestamp;

  /// Creates a new [NetworkRequestInfo] instance
  NetworkRequestInfo({
    required this.path,
    required this.duration,
    required this.statusCode,
    required this.responseSize,
    this.isError = false,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'NetworkRequestInfo{path: $path, duration: $duration, statusCode: $statusCode, '
        'responseSize: $responseSize, isError: $isError, errorMessage: $errorMessage, '
        'timestamp: $timestamp}';
  }
}

/// Class for monitoring network performance
class NetworkMonitor {
  /// Maximum number of requests to keep in history
  static const int _maxHistorySize = 100;

  /// Queue of recent network requests
  final Queue<NetworkRequestInfo> _requestHistory = Queue<NetworkRequestInfo>();

  /// Threshold for slow requests in milliseconds
  static const int _slowRequestThresholdMs = 1000;

  /// Track a network request
  void trackRequest({
    required String path,
    required Duration duration,
    required int statusCode,
    required int responseSize,
    bool isError = false,
    String? errorMessage,
  }) {
    final request = NetworkRequestInfo(
      path: path,
      duration: duration,
      statusCode: statusCode,
      responseSize: responseSize,
      isError: isError,
      errorMessage: errorMessage,
    );

    // Add to history
    _requestHistory.add(request);

    // Trim history if needed
    while (_requestHistory.length > _maxHistorySize) {
      _requestHistory.removeFirst();
    }

    // Log slow requests
    if (duration.inMilliseconds > _slowRequestThresholdMs) {
      debugPrint(
          '⚠️ Slow network request: ${request.path} took ${duration.inMilliseconds}ms');
    }

    // Log errors
    if (isError) {
      debugPrint('❌ Network request error: ${request.path} - $errorMessage');
    }
  }

  /// Get the request history
  List<NetworkRequestInfo> getRequestHistory() {
    return List.unmodifiable(_requestHistory);
  }

  /// Get the average request duration for a specific path
  Duration getAverageRequestDuration(String path) {
    final requests = _requestHistory.where((r) => r.path == path).toList();

    if (requests.isEmpty) {
      return Duration.zero;
    }

    final totalMs = requests.fold<int>(
      0,
      (sum, request) => sum + request.duration.inMilliseconds,
    );

    return Duration(milliseconds: totalMs ~/ requests.length);
  }

  /// Get the error rate for a specific path
  double getErrorRate(String path) {
    final requests = _requestHistory.where((r) => r.path == path).toList();

    if (requests.isEmpty) {
      return 0.0;
    }

    final errorCount = requests.where((r) => r.isError).length;

    return errorCount / requests.length;
  }

  /// Clear the request history
  void clearHistory() {
    _requestHistory.clear();
  }
}
