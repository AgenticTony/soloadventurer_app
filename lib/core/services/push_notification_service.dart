import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'notification_service.dart';

part 'push_notification_service.g.dart';

/// Background message handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Show a local notification for the background message
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const iOSSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iOSSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  final notification = message.notification;
  final data = message.data;

  if (notification != null) {
    const androidDetails = AndroidNotificationDetails(
      NotificationChannels.chat,
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
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

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: data.isNotEmpty ? data.toString() : null,
    );
  }
}

/// Service managing Firebase Cloud Messaging lifecycle
class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _currentToken;
  String? get currentToken => _currentToken;

  /// Callback when a new FCM token is received
  void Function(String token)? onTokenRefresh;

  /// Callback when a notification is tapped and should navigate
  void Function(Map<String, dynamic> data)? onNotificationTap;

  /// Initialize FCM: request permissions, get token, setup listeners
  Future<void> initialize() async {
    // Request notification permissions
    await _requestPermissions();

    // Setup local notifications for foreground messages
    await _setupLocalNotifications();

    // Get initial FCM token
    _currentToken = await _messaging.getToken();

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen((token) {
      _currentToken = token;
      onTokenRefresh?.call(token);
    });

    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle notification tap when app was terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  Future<NotificationSettings> _requestPermissions() async {
    if (Platform.isIOS) {
      return await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    }
    // Android permissions are handled by the system on Android 13+
    return await _messaging.requestPermission();
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          final data = _parsePayload(response.payload!);
          if (data != null) {
            onNotificationTap?.call(data);
          }
        }
      },
    );

    // Create chat notification channel for Android
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            NotificationChannels.chat,
            'Chat Messages',
            description: 'Notifications for new chat messages',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
          ),
        );
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Show as local notification so user sees it
    const androidDetails = AndroidNotificationDetails(
      NotificationChannels.chat,
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
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

    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      onNotificationTap?.call(message.data);
    }
  }

  Map<String, dynamic>? _parsePayload(String payload) {
    try {
      // Parse the toString() format: {key: value, key2: value2}
      final map = <String, dynamic>{};
      final cleaned =
          payload.replaceAll(RegExp(r'[{}]'), '').trim();
      if (cleaned.isEmpty) return null;
      for (final pair in cleaned.split(', ')) {
        final parts = pair.split(': ');
        if (parts.length == 2) {
          map[parts[0].trim()] = parts[1].trim();
        }
      }
      return map.isNotEmpty ? map : null;
    } catch (_) {
      return null;
    }
  }

  /// Subscribe to a topic (e.g. for muted chat management)
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Delete the current FCM token (use on logout)
  Future<void> deleteToken() async {
    if (_currentToken != null) {
      await _messaging.deleteToken();
      _currentToken = null;
    }
  }
}

/// Provider for the PushNotificationService singleton
@Riverpod(keepAlive: true)
PushNotificationService pushNotificationService(Ref ref) {
  return PushNotificationService();
}
