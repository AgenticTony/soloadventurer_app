import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

/// Service for managing notifications in the app
@riverpod
class NotificationService extends _$NotificationService {
  static const _channelId = 'com.soloadventurer.background';
  static const _channelName = 'Background Operations';
  static const _channelDescription = 'Notifications for background operations';
  static const _foregroundNotificationId = 888;

  late final FlutterLocalNotificationsPlugin _notifications;

  @override
  Future<void> build() async {
    _notifications = FlutterLocalNotificationsPlugin();
    await _initialize();
  }

  Future<void> _initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notifications.initialize(initSettings);

    // Create the notification channel for Android
    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDescription,
              importance: Importance.low,
            ),
          );
    }
  }

  /// Shows a foreground service notification (required for Android)
  Future<void> showForegroundNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      category: AndroidNotificationCategory.service,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      _foregroundNotificationId,
      title,
      body,
      details,
    );
  }

  /// Clears the foreground service notification
  Future<void> clearForegroundNotification() async {
    await _notifications.cancel(_foregroundNotificationId);
  }
}
