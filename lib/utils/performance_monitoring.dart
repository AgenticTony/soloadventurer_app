import 'package:flutter/foundation.dart';
import 'package:soloadventurer/services/monitoring/monitoring_service.dart';
import 'package:soloadventurer/utils/performance_metrics.dart';

/// Performance thresholds for different operations in milliseconds
class PerformanceThresholds {
  // Network operations
  static const Duration apiCall = Duration(milliseconds: 1000);
  static const Duration imageLoad = Duration(milliseconds: 500);
  static const Duration fileUpload = Duration(milliseconds: 3000);

  // UI operations
  static const Duration screenTransition = Duration(milliseconds: 300);
  static const Duration listRendering = Duration(milliseconds: 100);
  static const Duration animationFrame = Duration(milliseconds: 16); // ~60fps

  // Database operations
  static const Duration databaseQuery = Duration(milliseconds: 200);
  static const Duration databaseWrite = Duration(milliseconds: 300);

  // Authentication operations
  static const Duration signIn = Duration(milliseconds: 2000);
  static const Duration tokenRefresh = Duration(milliseconds: 500);
}

/// Utility class for performance monitoring in the app
class PerformanceMonitoring {
  /// Initialize performance monitoring with the given monitoring service
  static void initialize(MonitoringService monitoringService) {
    PerformanceMetrics.initialize(monitoringService);
    debugPrint('Performance monitoring initialized');
  }

  /// Measure a network operation and check against thresholds
  static Future<T> measureNetworkOperation<T>({
    required String operationName,
    required Future<T> Function() operation,
    Duration? threshold,
  }) async {
    final result = await PerformanceMetrics.measureFunction(
      operationName,
      operation,
      category: MetricCategory.network,
    );

    // Check against threshold if provided
    if (threshold != null) {
      final duration = PerformanceMetrics.getAverageDuration(operationName);
      if (duration > threshold) {
        PerformanceMetrics.trackThresholdBreach(
            operationName, threshold, duration);
      }
    }

    return result;
  }

  /// Measure a UI operation and check against thresholds
  static Future<T> measureUiOperation<T>({
    required String operationName,
    required Future<T> Function() operation,
    Duration? threshold,
  }) async {
    final result = await PerformanceMetrics.measureFunction(
      operationName,
      operation,
      category: MetricCategory.ui,
    );

    // Check against threshold if provided
    if (threshold != null) {
      final duration = PerformanceMetrics.getAverageDuration(operationName);
      if (duration > threshold) {
        PerformanceMetrics.trackThresholdBreach(
            operationName, threshold, duration);
      }
    }

    return result;
  }

  /// Measure a database operation and check against thresholds
  static Future<T> measureDatabaseOperation<T>({
    required String operationName,
    required Future<T> Function() operation,
    Duration? threshold,
  }) async {
    final result = await PerformanceMetrics.measureFunction(
      operationName,
      operation,
      category: MetricCategory.database,
    );

    // Check against threshold if provided
    if (threshold != null) {
      final duration = PerformanceMetrics.getAverageDuration(operationName);
      if (duration > threshold) {
        PerformanceMetrics.trackThresholdBreach(
            operationName, threshold, duration);
      }
    }

    return result;
  }

  /// Measure an authentication operation and check against thresholds
  static Future<T> measureAuthOperation<T>({
    required String operationName,
    required Future<T> Function() operation,
    Duration? threshold,
  }) async {
    final result = await PerformanceMetrics.measureFunction(
      operationName,
      operation,
      category: MetricCategory.authentication,
    );

    // Check against threshold if provided
    if (threshold != null) {
      final duration = PerformanceMetrics.getAverageDuration(operationName);
      if (duration > threshold) {
        PerformanceMetrics.trackThresholdBreach(
            operationName, threshold, duration);
      }
    }

    return result;
  }

  /// Generate a performance report for the current session
  static String generatePerformanceReport() {
    final buffer = StringBuffer();
    buffer.writeln('Performance Report - ${DateTime.now().toIso8601String()}');
    buffer.writeln('----------------------------------------');

    // Print metrics summary
    PerformanceMetrics.printSummary();

    return buffer.toString();
  }
}

/// Example usage:
/// ```dart
/// // Initialize in your app startup
/// final monitoringService = AwsCloudWatchMonitoring(apiService);
/// PerformanceMonitoring.initialize(monitoringService);
/// 
/// // Measure network operations
/// final userData = await PerformanceMonitoring.measureNetworkOperation(
///   operationName: 'fetch_user_profile',
///   operation: () => apiService.getUserProfile(userId),
///   threshold: PerformanceThresholds.apiCall,
/// );
/// 
/// // Measure UI operations
/// await PerformanceMonitoring.measureUiOperation(
///   operationName: 'render_trip_list',
///   operation: () async {
///     await tripListController.loadData();
///     setState(() {});
///     await Future.delayed(Duration(milliseconds: 100)); // Wait for render
///   },
///   threshold: PerformanceThresholds.listRendering,
/// );
/// 
/// // Generate a report
/// final report = PerformanceMonitoring.generatePerformanceReport();
/// print(report);
/// ``` 