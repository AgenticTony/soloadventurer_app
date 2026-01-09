// Notification providers - TODO: Implement notification providers
// This is a stub to unblock the build

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';

// Stub provider for notification preferences
final notificationPreferencesProvider = Provider<NotificationPreferences>((ref) {
  return NotificationPreferences.defaultPrefs();
});
