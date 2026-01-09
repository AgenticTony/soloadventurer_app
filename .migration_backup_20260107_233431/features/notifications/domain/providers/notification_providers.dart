import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/notifications/data/providers/notification_providers.dart'
    show notificationRepositoryOverrideProvider;
import 'package:soloadventurer/features/notifications/domain/usecases/dismiss_notification.dart';
import 'package:soloadventurer/features/notifications/domain/usecases/get_notification_history.dart';
import 'package:soloadventurer/features/notifications/domain/usecases/get_notification_preferences.dart';
import 'package:soloadventurer/features/notifications/domain/usecases/get_unread_notifications.dart';
import 'package:soloadventurer/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:soloadventurer/features/notifications/domain/usecases/schedule_notification.dart';
import 'package:soloadventurer/features/notifications/domain/usecases/schedule_itinerary_notifications.dart';
import 'package:soloadventurer/features/notifications/domain/usecases/send_notification_now.dart';
import 'package:soloadventurer/features/notifications/domain/usecases/update_notification_preferences.dart';

// ============================================================================
// USE CASE PROVIDERS
// ============================================================================

/// Provider for ScheduleNotification use case
final scheduleNotificationProvider = Provider<ScheduleNotification>((ref) {
  return ScheduleNotification(
    ref.watch(notificationRepositoryOverrideProvider),
  );
});

/// Provider for SendNotificationNow use case
final sendNotificationNowProvider = Provider<SendNotificationNow>((ref) {
  return SendNotificationNow(
    ref.watch(notificationRepositoryOverrideProvider),
  );
});

/// Provider for DismissNotification use case
final dismissNotificationProvider = Provider<DismissNotification>((ref) {
  return DismissNotification(
    ref.watch(notificationRepositoryOverrideProvider),
  );
});

/// Provider for MarkNotificationRead use case
final markNotificationReadProvider = Provider<MarkNotificationRead>((ref) {
  return MarkNotificationRead(
    ref.watch(notificationRepositoryOverrideProvider),
  );
});

/// Provider for GetNotificationHistory use case
final getNotificationHistoryProvider = Provider<GetNotificationHistory>((ref) {
  return GetNotificationHistory(
    ref.watch(notificationRepositoryOverrideProvider),
  );
});

/// Provider for GetUnreadNotifications use case
final getUnreadNotificationsProvider = Provider<GetUnreadNotifications>((ref) {
  return GetUnreadNotifications(
    ref.watch(notificationRepositoryOverrideProvider),
  );
});

/// Provider for GetNotificationPreferences use case
final getNotificationPreferencesProvider = Provider<GetNotificationPreferences>((ref) {
  return GetNotificationPreferences(
    ref.watch(notificationRepositoryOverrideProvider),
  );
});

/// Provider for UpdateNotificationPreferences use case
final updateNotificationPreferencesProvider = Provider<UpdateNotificationPreferences>((ref) {
  return UpdateNotificationPreferences(
    ref.watch(notificationRepositoryOverrideProvider),
  );
});

/// Provider for ScheduleItineraryNotifications use case
final scheduleItineraryNotificationsProvider = Provider<ScheduleItineraryNotifications>((ref) {
  return ScheduleItineraryNotifications(
    ref.watch(notificationRepositoryOverrideProvider),
  );
});
