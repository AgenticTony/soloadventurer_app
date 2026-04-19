import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'notification_service.dart';

part 'notification_service_impl.g.dart';

/// Exception thrown when notification service operations fail
class NotificationServiceException implements Exception {
  final String message;

  NotificationServiceException(this.message);

  @override
  String toString() => 'NotificationServiceException: $message';
}

/// Exception thrown when notification permissions are not granted
class NotificationPermissionException implements Exception {
  final String message;

  NotificationPermissionException(this.message);

  @override
  String toString() => 'NotificationPermissionException: $message';
}

/// Implementation of [NotificationService] using flutter_local_notifications
class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  int _nextNotificationId = 0;

  // Map to track notification IDs by check-in ID
  final Map<String, int> _checkInNotificationIds = {};

  // Map to track notification types by ID
  final Map<int, SafetyNotificationType> _notificationTypes = {};

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz_data.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      SafetyNotificationConfig.notificationIcon,
    );

    // iOS initialization settings
    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    // Initialize the plugin
    final success = await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (success == null || !success) {
      throw NotificationServiceException(
        'Failed to initialize notification service',
      );
    }

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    _initialized = true;
  }

  /// Creates notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Check-in channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        SafetyNotificationConfig.checkInChannelId,
        SafetyNotificationConfig.checkInChannelName,
        description: SafetyNotificationConfig.checkInChannelDescription,
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
    );

    // Emergency channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        SafetyNotificationConfig.emergencyChannelId,
        SafetyNotificationConfig.emergencyChannelName,
        description: SafetyNotificationConfig.emergencyChannelDescription,
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      ),
    );

    // Location sharing channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        SafetyNotificationConfig.locationChannelId,
        SafetyNotificationConfig.locationChannelName,
        description: SafetyNotificationConfig.locationChannelDescription,
        importance: Importance.defaultImportance,
        enableVibration: false,
        playSound: true,
      ),
    );

    // General safety channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        SafetyNotificationConfig.generalChannelId,
        SafetyNotificationConfig.generalChannelName,
        description: SafetyNotificationConfig.generalChannelDescription,
        importance: Importance.defaultImportance,
        enableVibration: true,
        playSound: true,
      ),
    );
  }

  /// Called when a notification is tapped
  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    // This can be used to navigate to specific screens
    // For now, we'll just log it
    if (response.payload != null) {
      try {
        jsonDecode(response.payload!);
        // TODO: Navigate to appropriate screen based on payload
      } catch (e) {
        // Ignore JSON decode errors
      }
    }
  }

  @override
  Future<bool> arePermissionsGranted() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return false;

      final granted = await androidPlugin.areNotificationsEnabled();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iOSPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iOSPlugin == null) return false;

      final result = await iOSPlugin.checkPermissions();
      // The return type is a map, not a bool
      return result != null;
    }
    return false;
  }

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return false;

      final result = await androidPlugin.requestNotificationsPermission();
      return result ?? false;
    } else if (Platform.isIOS) {
      final iOSPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iOSPlugin == null) return false;

      final result = await iOSPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }
    return false;
  }

  @override
  Future<NotificationResult> showNotification({
    required String title,
    required String body,
    required SafetyNotificationType type,
    Map<String, dynamic>? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final details = await _getNotificationDetails(type);
      final id = _getNextNotificationId();

      final String? payloadString =
          payload != null ? jsonEncode(payload) : null;

      await _notifications.show(
        id,
        title,
        body,
        details,
        payload: payloadString,
      );

      _notificationTypes[id] = type;

      return NotificationResult.success(notificationId: id);
    } catch (e) {
      return NotificationResult.failure(
        'Failed to show notification: ${e.toString()}',
      );
    }
  }

  @override
  Future<NotificationResult> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    required SafetyNotificationType type,
    Map<String, dynamic>? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final details = await _getNotificationDetails(type);
      final id = _getNextNotificationId();

      final String? payloadString =
          payload != null ? jsonEncode(payload) : null;

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        payload: payloadString,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      _notificationTypes[id] = type;

      return NotificationResult.success(notificationId: id);
    } catch (e) {
      return NotificationResult.failure(
        'Failed to schedule notification: ${e.toString()}',
      );
    }
  }

  @override
  Future<NotificationResult> scheduleRepeatingNotification({
    required String title,
    required String body,
    required Duration interval,
    required SafetyNotificationType type,
    Map<String, dynamic>? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final details = await _getNotificationDetails(type);
      final id = _getNextNotificationId();

      final String? payloadString =
          payload != null ? jsonEncode(payload) : null;

      // Use repeat interval for repeating notifications
      await _notifications.periodicallyShow(
        id,
        title,
        body,
        _mapDurationToRepeatInterval(interval),
        details,
        payload: payloadString,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      _notificationTypes[id] = type;

      return NotificationResult.success(notificationId: id);
    } catch (e) {
      return NotificationResult.failure(
        'Failed to schedule repeating notification: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    _notificationTypes.remove(id);
    _checkInNotificationIds.removeWhere((key, value) => value == id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    _notificationTypes.clear();
    _checkInNotificationIds.clear();
  }

  @override
  Future<void> cancelNotificationsByType(SafetyNotificationType type) async {
    final idsToRemove = <int>[];
    _notificationTypes.forEach((id, notificationType) {
      if (notificationType == type) {
        idsToRemove.add(id);
      }
    });

    for (final id in idsToRemove) {
      await _notifications.cancel(id);
      _notificationTypes.remove(id);
      _checkInNotificationIds.removeWhere((key, value) => value == id);
    }
  }

  @override
  Future<NotificationResult> showCheckInReminder({
    required String checkInId,
    required DateTime scheduledTime,
    required DateTime deadline,
  }) async {
    const title = 'Check-in Reminder';
    final body =
        'You have a check-in due at ${_formatTime(deadline)}. Please check in now.';

    final result = await showNotification(
      title: title,
      body: body,
      type: SafetyNotificationType.checkInReminder,
      payload: {'checkInId': checkInId, 'type': 'reminder'},
    );

    if (result.success) {
      _checkInNotificationIds[checkInId] = result.notificationId!;
    }

    return result;
  }

  @override
  Future<NotificationResult> scheduleCheckInReminder({
    required String checkInId,
    required DateTime reminderTime,
    required DateTime deadline,
  }) async {
    const title = 'Check-in Reminder';
    final body =
        'You have a check-in due at ${_formatTime(deadline)}. Please check in now.';

    final result = await scheduleNotification(
      title: title,
      body: body,
      scheduledTime: reminderTime,
      type: SafetyNotificationType.checkInReminder,
      payload: {'checkInId': checkInId, 'type': 'reminder'},
    );

    if (result.success) {
      _checkInNotificationIds[checkInId] = result.notificationId!;
    }

    return result;
  }

  @override
  Future<NotificationResult> showMissedCheckInAlert({
    required String checkInId,
    String? lastKnownLocation,
  }) async {
    const title = 'Missed Check-in Alert';
    final body = lastKnownLocation != null
        ? 'You missed your check-in. Last known location: $lastKnownLocation'
        : 'You missed your check-in. Your trusted contacts have been notified.';

    return showNotification(
      title: title,
      body: body,
      type: SafetyNotificationType.checkInMissed,
      payload: {'checkInId': checkInId, 'type': 'missed'},
    );
  }

  @override
  Future<NotificationResult> showEmergencySOS({
    required String alertId,
    String? location,
    String? message,
  }) async {
    const title = '🆘 EMERGENCY SOS';
    final locationText = location ?? 'Unknown location';
    final messageText =
        (message != null && message.isNotEmpty) ? '\nMessage: $message' : '';
    final body = 'Emergency alert sent!\nLocation: $locationText$messageText';

    return showNotification(
      title: title,
      body: body,
      type: SafetyNotificationType.emergencySOS,
      payload: {'alertId': alertId, 'type': 'sos'},
    );
  }

  @override
  Future<NotificationResult> showSafetyStatusUpdate({
    required String status,
    String? message,
  }) async {
    const title = 'Safety Status Updated';
    final messageText = message != null ? '\n$message' : '';
    final body = 'Your status is now: $status$messageText';

    return showNotification(
      title: title,
      body: body,
      type: SafetyNotificationType.safetyStatusUpdate,
      payload: {'status': status, 'type': 'status_update'},
    );
  }

  @override
  Future<NotificationResult> showLocationSharingStarted({
    required List<String> contactNames,
  }) async {
    const title = 'Location Sharing Started';
    final contacts = contactNames.length <= 2
        ? contactNames.join(', ')
        : '${contactNames.take(2).join(', ')} and ${contactNames.length - 2} others';
    final body = 'Sharing your location with $contacts';

    return showNotification(
      title: title,
      body: body,
      type: SafetyNotificationType.locationSharing,
      payload: {'type': 'location_sharing_started'},
    );
  }

  @override
  Future<NotificationResult> showLocationSharingStopped() async {
    const title = 'Location Sharing Stopped';
    const body = 'Your location is no longer being shared';

    return showNotification(
      title: title,
      body: body,
      type: SafetyNotificationType.locationSharingStopped,
      payload: {'type': 'location_sharing_stopped'},
    );
  }

  @override
  Future<List<PendingNotification>> getPendingNotifications() async {
    // flutter_local_notifications doesn't provide a direct way to get
    // pending notifications, so we'll return an empty list for now
    // In a production app, you'd need to track scheduled notifications manually
    return [];
  }

  @override
  void dispose() {
    // Clean up resources
    _notificationTypes.clear();
    _checkInNotificationIds.clear();
  }

  /// Gets the next notification ID
  int _getNextNotificationId() {
    return ++_nextNotificationId;
  }

  /// Gets notification details for a specific type
  Future<NotificationDetails> _getNotificationDetails(
      SafetyNotificationType type) async {
    final channelId = _getChannelId(type);
    final importance = _getImportance(type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: importance,
      priority: _getPriority(importance),
      enableVibration: type == SafetyNotificationType.emergencySOS,
      vibrationPattern: type == SafetyNotificationType.emergencySOS
          ? SafetyNotificationConfig.vibrationPattern
          : null,
      playSound: true,
      autoCancel: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
  }

  /// Gets the channel ID for a notification type
  String _getChannelId(SafetyNotificationType type) {
    switch (type) {
      case SafetyNotificationType.checkInReminder:
      case SafetyNotificationType.checkInMissed:
        return SafetyNotificationConfig.checkInChannelId;
      case SafetyNotificationType.emergencySOS:
        return SafetyNotificationConfig.emergencyChannelId;
      case SafetyNotificationType.locationSharing:
      case SafetyNotificationType.locationSharingStopped:
        return SafetyNotificationConfig.locationChannelId;
      case SafetyNotificationType.safetyStatusUpdate:
      case SafetyNotificationType.generalAlert:
      case SafetyNotificationType.backgroundSync:
        return SafetyNotificationConfig.generalChannelId;
    }
  }

  /// Gets the channel name by ID
  String _getChannelName(String channelId) {
    switch (channelId) {
      case SafetyNotificationConfig.checkInChannelId:
        return SafetyNotificationConfig.checkInChannelName;
      case SafetyNotificationConfig.emergencyChannelId:
        return SafetyNotificationConfig.emergencyChannelName;
      case SafetyNotificationConfig.locationChannelId:
        return SafetyNotificationConfig.locationChannelName;
      case SafetyNotificationConfig.generalChannelId:
        return SafetyNotificationConfig.generalChannelName;
      default:
        return 'Unknown Channel';
    }
  }

  /// Gets the channel description by ID
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case SafetyNotificationConfig.checkInChannelId:
        return SafetyNotificationConfig.checkInChannelDescription;
      case SafetyNotificationConfig.emergencyChannelId:
        return SafetyNotificationConfig.emergencyChannelDescription;
      case SafetyNotificationConfig.locationChannelId:
        return SafetyNotificationConfig.locationChannelDescription;
      case SafetyNotificationConfig.generalChannelId:
        return SafetyNotificationConfig.generalChannelDescription;
      default:
        return '';
    }
  }

  /// Gets the importance level for a notification type
  Importance _getImportance(SafetyNotificationType type) {
    switch (type) {
      case SafetyNotificationType.emergencySOS:
        return Importance.max;
      case SafetyNotificationType.checkInReminder:
      case SafetyNotificationType.checkInMissed:
        return Importance.high;
      case SafetyNotificationType.locationSharing:
      case SafetyNotificationType.locationSharingStopped:
        return Importance.defaultImportance;
      case SafetyNotificationType.safetyStatusUpdate:
      case SafetyNotificationType.generalAlert:
      case SafetyNotificationType.backgroundSync:
        return Importance.defaultImportance;
    }
  }

  /// Maps importance to priority
  Priority _getPriority(Importance importance) {
    switch (importance) {
      case Importance.max:
      case Importance.high:
        return Priority.high;
      case Importance.defaultImportance:
      case Importance.low:
        return Priority.defaultPriority;
      case Importance.min:
      case Importance.none:
        return Priority.low;
      case Importance.unspecified:
        return Priority.defaultPriority;
    }
  }

  /// Maps a Duration to a RepeatInterval
  RepeatInterval _mapDurationToRepeatInterval(Duration duration) {
    if (duration.inHours >= 24) {
      return RepeatInterval.daily;
    } else if (duration.inHours >= 1) {
      return RepeatInterval.hourly;
    } else {
      return RepeatInterval.everyMinute;
    }
  }

  /// Formats a time for display
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// Provider for NotificationServiceImpl
@riverpod
NotificationService notificationServiceImpl(Ref ref) {
  final service = NotificationServiceImpl();

  // Initialize the service
  ref.onDispose(() => service.dispose());

  return service;
}

/// Provider override for NotificationService interface
@riverpod
NotificationService notificationServiceOverride(
    Ref ref) {
  return ref.watch(notificationServiceImplProvider);
}
