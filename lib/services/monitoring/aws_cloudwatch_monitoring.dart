import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:soloadventurer/core/api/api_service.dart';
import 'monitoring_service.dart';

/// Implementation of MonitoringService that sends data to AWS CloudWatch
/// via API Gateway and Lambda
class AwsCloudWatchMonitoring implements MonitoringService {
  final ApiService _apiService;
  String _appVersion = 'unknown';
  String _deviceInfo = 'unknown';
  String? _userId;
  Map<String, dynamic> _userProperties = {};
  bool _isInitialized = false;

  AwsCloudWatchMonitoring(this._apiService) {
    _initializeDeviceInfo();
  }

  /// Initialize device and app information
  Future<void> _initializeDeviceInfo() async {
    try {
      // Get app version
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      // Get device info
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        _deviceInfo =
            '${androidInfo.manufacturer} ${androidInfo.model} (Android ${androidInfo.version.release})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        _deviceInfo = '${iosInfo.name} (iOS ${iosInfo.systemVersion})';
      } else {
        _deviceInfo = 'Unknown device';
      }

      _isInitialized = true;
    } catch (e) {
      // Handle device info initialization error
      rethrow;
    }
  }

  /// Get common metadata to include with all monitoring events
  Map<String, dynamic> _getCommonMetadata() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'appVersion': _appVersion,
      'deviceInfo': _deviceInfo,
      'platform': kIsWeb ? 'web' : Platform.operatingSystem,
      'userId': _userId ?? 'anonymous',
      'userProperties': _userProperties,
    };
  }

  @override
  void trackOperation(String operationName, Duration duration,
      {MetricCategory? category}) {
    // Log locally in debug mode
    debugPrint(
        'METRIC: $operationName - ${duration.inMilliseconds}ms [${category?.name ?? 'uncategorized'}]');

    // Only send to backend if initialized and not in debug mode
    if (_isInitialized && !kDebugMode) {
      _apiService.post('/monitoring/metrics', data: {
        ..._getCommonMetadata(),
        'metricName': operationName,
        'durationMs': duration.inMilliseconds,
        'category': category?.name ?? 'uncategorized',
      }).catchError((error) {
        // Silently handle errors to prevent monitoring from affecting app
        debugPrint('Error sending metric to CloudWatch: $error');
      });
    }
  }

  @override
  void reportError(String errorType, dynamic error, StackTrace stackTrace,
      {Map<String, dynamic>? context}) {
    // Log locally in debug mode
    debugPrint('ERROR: $errorType - $error');
    debugPrint(stackTrace.toString());

    // Only send to backend if initialized and not in debug mode
    if (_isInitialized && !kDebugMode) {
      _apiService.post('/monitoring/errors', data: {
        ..._getCommonMetadata(),
        'errorType': errorType,
        'errorMessage': error.toString(),
        'stackTrace': stackTrace.toString(),
        'context': context ?? {},
      }).catchError((error) {
        // Silently handle errors to prevent monitoring from affecting app
        debugPrint('Error sending error to CloudWatch: $error');
      });
    }
  }

  @override
  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    // Log locally in debug mode
    debugPrint('EVENT: $eventName - ${parameters ?? {}}');

    // Only send to backend if initialized and not in debug mode
    if (_isInitialized && !kDebugMode) {
      _apiService.post('/monitoring/events', data: {
        ..._getCommonMetadata(),
        'eventName': eventName,
        'parameters': parameters ?? {},
      }).catchError((error) {
        // Silently handle errors to prevent monitoring from affecting app
        debugPrint('Error sending event to CloudWatch: $error');
      });
    }
  }

  @override
  void startSession() {
    trackEvent('session_start');
  }

  @override
  void endSession() {
    trackEvent('session_end');
  }

  @override
  void setUserId(String userId) {
    _userId = userId;
    trackEvent('user_identified', parameters: {'userId': userId});
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    _userProperties = properties;
    trackEvent('user_properties_set', parameters: properties);
  }
}
