import 'package:soloadventurer/features/notifications/data/models/notification_model.dart';
import 'package:soloadventurer/features/notifications/data/models/notification_preferences_model.dart';
import 'package:soloadventurer/features/notifications/infrastructure/exceptions/notification_exceptions.dart';

/// Local data source for notifications
///
/// Handles persistence of notifications and preferences using shared_preferences
///
/// Throws [NotificationException] subclasses on errors:
/// - [NotificationCacheException]: Cache read/write failures
/// - [NotificationNotFoundException]: Requested notification not found
/// - [NotificationPreferencesException]: Preferences save/load failures
abstract class NotificationLocalDataSource {
  /// Save a notification
  ///
  /// Throws [NotificationCacheException] if save fails
  Future<void> saveNotification(NotificationModel notification);

  /// Get a notification by ID
  ///
  /// Returns the notification
  /// Throws [NotificationNotFoundException] if not found
  /// Throws [NotificationCacheException] if read fails
  Future<NotificationModel> getNotification(String id);

  /// Get all notifications
  ///
  /// Throws [NotificationCacheException] if read fails
  Future<List<NotificationModel>> getAllNotifications();

  /// Get notifications with filters
  ///
  /// Throws [NotificationCacheException] if read fails
  Future<List<NotificationModel>> getNotifications({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    bool? isRead,
    int? limit,
    int? offset,
  });

  /// Update a notification
  ///
  /// Throws [NotificationNotFoundException] if notification doesn't exist
  /// Throws [NotificationCacheException] if update fails
  Future<void> updateNotification(NotificationModel notification);

  /// Delete a notification
  ///
  /// Throws [NotificationCacheException] if delete fails
  Future<void> deleteNotification(String id);

  /// Clear all notifications
  ///
  /// Throws [NotificationCacheException] if clear fails
  Future<void> clearAllNotifications();

  /// Clear notifications before a date
  ///
  /// Throws [NotificationCacheException] if clear fails
  Future<void> clearNotificationsBefore(DateTime date);

  /// Get unread notifications
  ///
  /// Throws [NotificationCacheException] if read fails
  Future<List<NotificationModel>> getUnreadNotifications({
    int limit = 20,
  });

  /// Get pending (scheduled) notifications
  ///
  /// Throws [NotificationCacheException] if read fails
  Future<List<NotificationModel>> getPendingNotifications();

  /// Save notification preferences
  ///
  /// Throws [NotificationPreferencesException] if save fails
  Future<void> savePreferences(NotificationPreferencesModel preferences);

  /// Get notification preferences
  ///
  /// Returns default preferences if none saved
  /// Throws [NotificationPreferencesException] if read fails
  Future<NotificationPreferencesModel> getPreferences();

  /// Get pending scheduled notifications with platform ID mappings
  ///
  /// Returns map of platform notification ID to notification
  /// Throws [NotificationCacheException] if read fails
  Future<Map<int, NotificationModel>> getScheduledNotificationMap();

  /// Add a scheduled notification ID mapping
  ///
  /// Throws [NotificationCacheException] if save fails
  Future<void> addScheduledNotification(int platformId, NotificationModel notification);

  /// Remove a scheduled notification mapping
  ///
  /// Throws [NotificationCacheException] if delete fails
  Future<void> removeScheduledNotification(int platformId);
}
