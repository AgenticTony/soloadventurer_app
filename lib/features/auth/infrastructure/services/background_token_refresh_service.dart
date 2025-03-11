import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workmanager/workmanager.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/services/token_manager.dart';
import '../monitoring/aws_cloudwatch_monitoring.dart';
import '../logging/token_audit_logger.dart';

part 'background_token_refresh_service.g.dart';

/// Configuration for background refresh operations
class BackgroundRefreshConfig {
  /// Unique identifier for the background refresh task
  static const String taskId = 'com.soloadventurer.token.refresh';

  /// Task name for the background refresh operation
  static const String taskName = 'tokenRefreshTask';

  /// Minimum interval between refresh attempts (15 minutes)
  static const Duration minRefreshInterval = Duration(minutes: 15);

  /// Maximum interval between refresh attempts (45 minutes)
  static const Duration maxRefreshInterval = Duration(minutes: 45);

  /// Network timeout for refresh operations
  static const Duration networkTimeout = Duration(seconds: 30);

  /// Battery level threshold for background operations
  static const int minBatteryLevel = 15;

  /// Notification title for foreground service
  static const String notificationTitle = 'Keeping You Connected';

  /// Notification message for foreground service
  static const String notificationMessage = 'Refreshing your session...';
}

/// Service responsible for managing background token refresh operations
@riverpod
class BackgroundTokenRefreshService extends _$BackgroundTokenRefreshService {
  bool _isInitialized = false;

  @override
  FutureOr<void> build() async {
    if (!_isInitialized) {
      await _initialize();
      _isInitialized = true;
    }
  }

  /// Initialize the background refresh service
  Future<void> _initialize() async {
    try {
      // Initialize Workmanager with custom configuration
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );

      // Register periodic task with constraints
      await Workmanager().registerPeriodicTask(
        BackgroundRefreshConfig.taskId,
        BackgroundRefreshConfig.taskName,
        frequency: BackgroundRefreshConfig.minRefreshInterval,
        constraints: WorkManagerConstraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: BackgroundRefreshConfig.minRefreshInterval,
      );

      ref.read(tokenAuditLoggerProvider).logTokenEvent(
        event: 'background_refresh_initialized',
        status: 'info',
        metadata: {
          'min_interval': BackgroundRefreshConfig.minRefreshInterval.inMinutes,
          'max_interval': BackgroundRefreshConfig.maxRefreshInterval.inMinutes,
          'network_timeout': BackgroundRefreshConfig.networkTimeout.inSeconds,
          'min_battery_level': BackgroundRefreshConfig.minBatteryLevel,
        },
      );
    } catch (e, stack) {
      ref.read(tokenAuditLoggerProvider).logError(
            feature: 'background_refresh',
            error: e.toString(),
            code: 'initialization_failed',
            stackTrace: stack,
          );
      rethrow;
    }
  }

  /// Stop background refresh operations
  Future<void> stop() async {
    try {
      await Workmanager().cancelByUniqueName(BackgroundRefreshConfig.taskId);
      ref.read(tokenAuditLoggerProvider).logTokenEvent(
            event: 'background_refresh_stopped',
            status: 'info',
          );
    } catch (e, stack) {
      ref.read(tokenAuditLoggerProvider).logError(
            feature: 'background_refresh',
            error: e.toString(),
            code: 'stop_failed',
            stackTrace: stack,
          );
    }
  }
}

/// Global callback function for handling background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (taskName == BackgroundRefreshConfig.taskName) {
        final container = ProviderContainer();

        // Show notification for foreground service (Android requirement)
        if (Platform.isAndroid) {
          await container
              .read(notificationServiceProvider)
              .showForegroundNotification(
                title: BackgroundRefreshConfig.notificationTitle,
                body: BackgroundRefreshConfig.notificationMessage,
              );
        }

        // Perform token refresh
        await container.read(tokenManagerProvider.notifier).refreshToken();

        // Record successful refresh metric
        container.read(awsCloudWatchMonitoringProvider).recordMetric(
          'BackgroundTokenRefresh',
          1.0,
          dimensions: {'Status': 'Success'},
        );

        // Log successful refresh
        container.read(tokenAuditLoggerProvider).logTokenEvent(
              event: 'background_refresh_success',
              status: 'info',
            );

        // Clear the notification
        if (Platform.isAndroid) {
          await container
              .read(notificationServiceProvider)
              .clearForegroundNotification();
        }

        return true;
      }
      return false;
    } catch (e, stack) {
      final container = ProviderContainer();

      // Log error
      container.read(tokenAuditLoggerProvider).logError(
            feature: 'background_refresh',
            error: e.toString(),
            code: 'refresh_failed',
            stackTrace: stack,
          );

      // Record failure metric
      container.read(awsCloudWatchMonitoringProvider).recordMetric(
        'BackgroundTokenRefresh',
        1.0,
        dimensions: {'Status': 'Failure'},
      );

      return false;
    }
  });
}
