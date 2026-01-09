// Notification providers - TODO: Implement notification providers
// This is a stub to unblock the build

// Re-export the generated providers
export 'package:soloadventurer/features/notifications/presentation/notifiers/notifications_notifier.dart'
    show notificationsNotifierProvider;
export 'package:soloadventurer/features/notifications/presentation/notifiers/notification_preferences_notifier.dart'
    show notificationPreferencesNotifierProvider;
export 'package:soloadventurer/features/notifications/presentation/notifiers/unread_notifications_notifier.dart'
    show unreadNotificationsNotifierProvider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';

// Stub provider for notification preferences
final notificationPreferencesProvider =
    Provider<NotificationPreferences>((ref) {
  return NotificationPreferences.defaultPrefs();
});
