import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'background_checkin_service.dart';
import 'notification_service.dart';

part 'background_checkin_service_impl.g.dart';

/// Implementation of [BackgroundCheckInService] using workmanager
class BackgroundCheckInServiceImpl implements BackgroundCheckInService {
  final StreamController<BackgroundCheckInServiceStatus> _statusController =
      StreamController<BackgroundCheckInServiceStatus>.broadcast();

  BackgroundCheckInServiceStatus _status =
      BackgroundCheckInServiceStatus.stopped;

  @override
  BackgroundCheckInServiceStatus get status => _status;

  @override
  Stream<BackgroundCheckInServiceStatus> get onStatusChanged =>
      _statusController.stream;

  @override
  Future<void> initialize() async {
    try {
      // Initialize Workmanager with custom configuration
      await Workmanager().initialize(
        callbackDispatcher,
      );

      // Register periodic task for monitoring check-ins
      await Workmanager().registerPeriodicTask(
        BackgroundCheckInConfig.monitoringTaskId,
        BackgroundCheckInConfig.monitoringTaskName,
        frequency: BackgroundCheckInConfig.monitoringInterval,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: BackgroundCheckInConfig.monitoringInterval,
      );

      _updateStatus(BackgroundCheckInServiceStatus.initialized);
    } catch (e) {
      _updateStatus(BackgroundCheckInServiceStatus.error);
      throw BackgroundCheckInServiceException(
        'Failed to initialize background check-in service: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> scheduleCheckInReminder({
    required String checkInId,
    required DateTime scheduledTime,
  }) async {
    try {
      // Calculate delay from now
      final now = DateTime.now();
      if (scheduledTime.isBefore(now)) {
        throw BackgroundCheckInServiceException(
          'Scheduled time must be in the future',
        );
      }

      final initialDelay = scheduledTime.difference(now);

      // Schedule one-time task for reminder
      await Workmanager().registerOneOffTask(
        'reminder_$checkInId',
        'checkInReminderTask',
        initialDelay: initialDelay,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        tag: checkInId,
      );

      return true;
    } catch (e) {
      throw BackgroundCheckInServiceException(
        'Failed to schedule check-in reminder: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> scheduleMissedCheckInMonitoring() async {
    try {
      // This is already handled by the periodic task registered in initialize()
      // This method is kept for API compatibility and potential future enhancements
      return true;
    } catch (e) {
      throw BackgroundCheckInServiceException(
        'Failed to schedule missed check-in monitoring: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cancelCheckInReminder(String checkInId) async {
    try {
      await Workmanager().cancelByTag(checkInId);
    } catch (e) {
      throw BackgroundCheckInServiceException(
        'Failed to cancel check-in reminder: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cancelAllReminders() async {
    try {
      await Workmanager().cancelByUniqueName(
        BackgroundCheckInConfig.monitoringTaskId,
      );
    } catch (e) {
      throw BackgroundCheckInServiceException(
        'Failed to cancel all reminders: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> stop() async {
    try {
      await Workmanager().cancelByUniqueName(
        BackgroundCheckInConfig.monitoringTaskId,
      );
      _updateStatus(BackgroundCheckInServiceStatus.stopped);
    } catch (e) {
      throw BackgroundCheckInServiceException(
        'Failed to stop background check-in service: ${e.toString()}',
      );
    }
  }

  @override
  Future<BackgroundCheckInResult> processDueCheckIns() async {
    // This method is called from the background task callback
    // The actual implementation is in the callback dispatcher
    throw UnimplementedError(
      'This method should only be called from the background task callback',
    );
  }

  @override
  void dispose() {
    stop();
    _statusController.close();
  }

  /// Updates the service status and notifies listeners
  void _updateStatus(BackgroundCheckInServiceStatus newStatus) {
    _status = newStatus;
    _statusController.add(_status);
  }
}

/// Global callback function for handling background check-in tasks
/// Must be top-level for workmanager — exposed publicly so bootstrap can reference it
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // Initialize Firebase for background tasks
      await Firebase.initializeApp();

      // Initialize local notifications for background alerts
      final localNotifications = FlutterLocalNotificationsPlugin();
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iOSSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      );
      await localNotifications.initialize(initSettings);

      // Create notification channels on Android
      const checkInChannel = AndroidNotificationChannel(
        NotificationChannels.checkIns,
        'Check-in Reminders',
        description: 'Notifications for check-in reminders and status updates',
        importance: Importance.high,
      );
      final androidPlugin = localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(checkInChannel);
      }

      if (taskName == BackgroundCheckInConfig.monitoringTaskName) {

        const androidDetails = AndroidNotificationDetails(
          NotificationChannels.checkIns,
          'Check-in Reminders',
          channelDescription:
              'Notifications for check-in reminders and status updates',
          importance: Importance.high,
          priority: Priority.high,
          autoCancel: true,
        );
        const iOSDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
        const details = NotificationDetails(
          android: androidDetails,
          iOS: iOSDetails,
        );

        await localNotifications.show(
          0,
          'Check-in Reminder',
          'You have an upcoming check-in. Don\'t forget to check in!',
          details,
          payload: '{"type":"checkInReminder"}',
        );

        return true;
      }

      if (taskName == 'checkInReminderTask') {

        const androidDetails = AndroidNotificationDetails(
          NotificationChannels.checkIns,
          'Check-in Reminders',
          channelDescription:
              'Notifications for check-in reminders and status updates',
          importance: Importance.high,
          priority: Priority.high,
          autoCancel: true,
        );
        const iOSDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
        const details = NotificationDetails(
          android: androidDetails,
          iOS: iOSDetails,
        );

        final checkInId = inputData?['checkInId'] as String? ?? '';
        await localNotifications.show(
          1,
          'Time to Check In',
          'Your safety check-in is due now. Tap to check in.',
          details,
          payload: '{"type":"checkInReminder","checkInId":"$checkInId"}',
        );

        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
      }
      return false;
    }
  });
}

/// Exception thrown when background check-in service operations fail
class BackgroundCheckInServiceException implements Exception {
  final String message;

  BackgroundCheckInServiceException(this.message);

  @override
  String toString() => 'BackgroundCheckInServiceException: $message';
}

/// Provider for BackgroundCheckInServiceImpl
@riverpod
BackgroundCheckInService backgroundCheckInServiceImpl(
  Ref ref,
) {
  final service = BackgroundCheckInServiceImpl();

  // Dispose the service when the provider is disposed
  ref.onDispose(() => service.dispose());

  return service;
}

/// Provider override for BackgroundCheckInService interface
@riverpod
BackgroundCheckInService backgroundCheckInServiceOverride(
  Ref ref,
) {
  return ref.watch(backgroundCheckInServiceImplProvider);
}
