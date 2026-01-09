import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:soloadventurer/features/notifications/data/models/notification_model.dart';
import 'package:soloadventurer/features/notifications/data/models/notification_preferences_model.dart';
import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';
import 'package:soloadventurer/features/notifications/infrastructure/exceptions/notification_exceptions.dart';

/// Keys for SharedPreferences
class _StorageKeys {
  static const String notifications = 'notifications';
  static const String preferences = 'notification_preferences';
  static const String scheduledNotifications = 'scheduled_notifications';
}

/// Implementation of [NotificationLocalDataSource] using SharedPreferences
class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final SharedPreferences _prefs;

  NotificationLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      final notifications = await _getAllNotificationsMap();
      notifications[notification.id] = notification.toJson();
      await _saveNotificationsMap(notifications);
    } catch (e) {
      throw NotificationCacheException(
        message: 'Failed to save notification',
        originalError: e,
      );
    }
  }

  @override
  Future<NotificationModel> getNotification(String id) async {
    try {
      final notifications = await _getAllNotificationsMap();
      final json = notifications[id];
      if (json == null) {
        throw NotificationNotFoundException(notificationId: id);
      }
      return NotificationModel.fromJson(json);
    } on NotificationNotFoundException {
      rethrow;
    } catch (e) {
      throw NotificationCacheException(
        message: 'Failed to get notification',
        originalError: e,
      );
    }
  }

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final notifications = await _getAllNotificationsMap();
      final list = notifications.values
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      return list;
    } catch (e) {
      throw NotificationCacheException(
        message: 'Failed to get all notifications',
        originalError: e,
      );
    }
  }

  @override
  Future<List<NotificationModel>> getNotifications({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    bool? isRead,
    int? limit,
    int? offset,
  }) async {
    try {
      List<NotificationModel> notifications = await _getAllNotificationsList();

      // Filter by date range
      if (startDate != null) {
        notifications = notifications
            .where((n) => n.scheduledAt.isAfter(startDate))
            .toList();
      }
      if (endDate != null) {
        notifications = notifications
            .where((n) => n.scheduledAt.isBefore(endDate))
            .toList();
      }

      // Filter by category
      if (category != null) {
        notifications =
            notifications.where((n) => n.category.name == category).toList();
      }

      // Filter by read status
      if (isRead != null) {
        notifications = notifications
            .where((n) => isRead ? n.readAt != null : n.readAt == null)
            .toList();
      }

      // Sort by scheduled date (newest first)
      notifications.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

      // Apply pagination
      if (offset != null && offset > 0) {
        if (offset >= notifications.length) {
          return [];
        }
        notifications = notifications.skip(offset).toList();
      }

      if (limit != null && limit > 0) {
        notifications = notifications.take(limit).toList();
      }

      return notifications;
    } catch (e) {
      throw NotificationCacheException(
        message: 'Failed to get notifications',
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateNotification(NotificationModel notification) async {
    try {
      final notifications = await _getAllNotificationsMap();
      if (!notifications.containsKey(notification.id)) {
        throw NotificationNotFoundException(notificationId: notification.id);
      }
      notifications[notification.id] = notification.toJson();
      await _saveNotificationsMap(notifications);
    } on NotificationNotFoundException {
      rethrow;
    } catch (e) {
      throw NotificationCacheException(
        message: 'Failed to update notification',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      final notifications = await _getAllNotificationsMap();
      notifications.remove(id);
      await _saveNotificationsMap(notifications);
    } catch (e) {
      throw NotificationCacheException(
        message: 'Failed to delete notification',
        originalError: e,
      );
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    try {
      await _prefs.remove(_StorageKeys.notifications);
    } catch (e) {
      throw NotificationCacheException(
        message: 'Failed to clear notifications',
        originalError: e,
      );
    }
  }

  @override
  Future<void> clearNotificationsBefore(DateTime date) async {
    try {
      final notifications = await _getAllNotificationsMap();
      final toRemove = notifications.entries
          .where((entry) => NotificationModel.fromJson(entry.value)
              .scheduledAt
              .isBefore(date))
          .map((entry) => entry.key)
          .toList();

      for (final id in toRemove) {
        notifications.remove(id);
      }

      await _saveNotificationsMap(notifications);
    } catch (e) {
      throw NotificationCacheException(
        message: 'Failed to clear notifications before date',
        originalError: e,
      );
    }
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications({
    int limit = 20,
  }) async {
    try {
      final notifications = await _getAllNotificationsList();
      final unread = notifications.where((n) => n.readAt == null).toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

      final result = limit > 0 ? unread.take(limit).toList() : unread;
      return result;
    } catch (e) {
      throw NotificationCacheException(
        message: 'Failed to get unread notifications',
        originalError: e,
      );
    }
  }

  @override
  Future<List<NotificationModel>> getPendingNotifications() async {
    // This method returns notifications scheduled for future delivery
    return getNotifications(startDate: DateTime.now());
  }

  @override
  Future<void> savePreferences(NotificationPreferencesModel preferences) async {
    try {
      final json = preferences.toJson();
      final jsonString = jsonEncode(json);
      await _prefs.setString(_StorageKeys.preferences, jsonString);
    } catch (e) {
      throw NotificationPreferencesException(
        message: 'Failed to save preferences',
        originalError: e,
      );
    }
  }

  @override
  Future<NotificationPreferencesModel> getPreferences() async {
    try {
      final jsonString = _prefs.getString(_StorageKeys.preferences);
      if (jsonString == null) {
        // Return default preferences if none exist
        return NotificationPreferencesModel.fromEntity(
            NotificationPreferences.defaultPrefs());
      }
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return NotificationPreferencesModel.fromJson(json);
    } catch (e) {
      throw NotificationPreferencesException(
        message: 'Failed to get preferences',
        originalError: e,
      );
    }
  }

  @override
  Future<Map<int, NotificationModel>> getScheduledNotificationMap() async {
    try {
      final jsonString = _prefs.getString(_StorageKeys.scheduledNotifications);
      if (jsonString == null) {
        return {};
      }
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final Map<int, NotificationModel> result = {};
      for (final entry in json.entries) {
        final platformId = int.tryParse(entry.key);
        if (platformId != null) {
          result[platformId] =
              NotificationModel.fromJson(entry.value as Map<String, dynamic>);
        }
      }
      return result;
    } catch (e) {
      throw NotificationCacheException(
        message: 'Failed to get scheduled notifications',
        originalError: e,
      );
    }
  }

  @override
  Future<void> addScheduledNotification(
      int platformId, NotificationModel notification) async {
    try {
      final scheduled = await _getScheduledNotificationMapInternal();
      scheduled[platformId.toString()] = notification.toJson();
      await _saveScheduledNotificationsMap(scheduled);
    } catch (e) {
      throw NotificationCacheException(
        message: 'Failed to add scheduled notification',
        originalError: e,
      );
    }
  }

  @override
  Future<void> removeScheduledNotification(int platformId) async {
    try {
      final scheduled = await _getScheduledNotificationMapInternal();
      scheduled.remove(platformId.toString());
      await _saveScheduledNotificationsMap(scheduled);
    } catch (e) {
      throw NotificationCacheException(
        message: 'Failed to remove scheduled notification',
        originalError: e,
      );
    }
  }

  // Private helper methods

  Future<Map<String, dynamic>> _getAllNotificationsMap() async {
    final jsonString = _prefs.getString(_StorageKeys.notifications);
    if (jsonString == null) {
      return {};
    }
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return json
        .map((key, value) => MapEntry(key, value as Map<String, dynamic>));
  }

  Future<void> _saveNotificationsMap(Map<String, dynamic> notifications) async {
    final jsonString = jsonEncode(notifications);
    await _prefs.setString(_StorageKeys.notifications, jsonString);
  }

  Future<List<NotificationModel>> _getAllNotificationsList() async {
    final notificationsMap = await _getAllNotificationsMap();
    return notificationsMap.values
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  Future<Map<String, dynamic>> _getScheduledNotificationMapInternal() async {
    final jsonString = _prefs.getString(_StorageKeys.scheduledNotifications);
    if (jsonString == null) {
      return {};
    }
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<void> _saveScheduledNotificationsMap(
      Map<String, dynamic> scheduled) async {
    final jsonString = jsonEncode(scheduled);
    await _prefs.setString(_StorageKeys.scheduledNotifications, jsonString);
  }
}
