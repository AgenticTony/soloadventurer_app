import 'package:soloadventurer/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:soloadventurer/features/notifications/data/models/notification_model.dart';
import 'package:soloadventurer/features/notifications/data/models/notification_preferences_model.dart';
import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';
import 'package:soloadventurer/features/notifications/domain/entities/travel_notification.dart';
import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';
import 'package:uuid/uuid.dart';

/// Implementation of [NotificationRepository]
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource _localDataSource;
  final Uuid _uuid = const Uuid();

  NotificationRepositoryImpl(
    this._localDataSource,
  );

  @override
  Future<void> schedule(TravelNotification notification) async {
    // Get preferences and check if notification should be shown
    final prefs = await getPreferences();

    // Convert to model to check if this notification type is enabled
    final model = NotificationModel.fromEntity(notification);
    if (!model.shouldShow(prefs)) {
      return;
    }

    // Check if we're in quiet hours and this is not urgent
    if (notification.priority != NotificationPriority.urgent &&
        prefs.isQuietTime(notification.scheduledAt)) {
      return;
    }

    // Save the notification to local storage
    await _localDataSource.saveNotification(model);
  }

  @override
  Future<void> sendNow(TravelNotification notification) async {
    // Get preferences and check if notification should be shown
    final prefs = await getPreferences();

    // Convert to model to check if this notification type is enabled
    final model = NotificationModel.fromEntity(notification);
    if (!model.shouldShow(prefs)) {
      return;
    }

    // Check quiet hours for non-urgent notifications
    if (notification.priority != NotificationPriority.urgent &&
        prefs.isQuietTime(DateTime.now())) {
      return;
    }

    // Mark as delivered and save
    final delivered = model.markAsDelivered();
    await _localDataSource.saveNotification(delivered);
  }

  @override
  Future<void> cancel(String notificationId) async {
    await _localDataSource.deleteNotification(notificationId);
  }

  @override
  Future<void> cancelAll() async {
    await _localDataSource.clearAllNotifications();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final model = await _localDataSource.getNotification(notificationId);
    final updated = model.markAsRead();
    await _localDataSource.updateNotification(updated);
  }

  @override
  Future<void> dismiss(String notificationId) async {
    final model = await _localDataSource.getNotification(notificationId);
    final updated = model.markAsDismissed();
    await _localDataSource.updateNotification(updated);
  }

  @override
  Future<List<TravelNotification>> getHistory({
    DateTime? startDate,
    DateTime? endDate,
    NotificationCategory? category,
    int limit = 50,
    int offset = 0,
  }) async {
    final models = await _localDataSource.getNotifications(
      startDate: startDate,
      endDate: endDate,
      category: category?.name,
      limit: limit,
      offset: offset,
    );

    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TravelNotification>> getUnread({
    int limit = 20,
  }) async {
    final models = await _localDataSource.getUnreadNotifications(limit: limit);

    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TravelNotification>> getPending() async {
    final models = await _localDataSource.getPendingNotifications();

    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    final model = NotificationPreferencesModel.fromEntity(preferences);
    await _localDataSource.savePreferences(model);
  }

  @override
  Future<NotificationPreferences> getPreferences() async {
    final model = await _localDataSource.getPreferences();
    return model.toEntity();
  }

  @override
  Future<void> clearHistory({DateTime? beforeDate}) async {
    if (beforeDate != null) {
      await _localDataSource.clearNotificationsBefore(beforeDate);
    } else {
      await _localDataSource.clearAllNotifications();
    }
  }

  @override
  Future<NotificationStats> getStats() async {
    final models = await _localDataSource.getAllNotifications();

    final totalSent = models.length;
    final totalRead = models.where((n) => n.readAt != null).length;
    final totalDismissed = models.where((n) => n.dismissedAt != null).length;
    final unreadCount = models.where((n) => n.readAt == null).length;

    // Get pending count
    final pending = models
        .where((n) =>
            n.scheduledAt.isAfter(DateTime.now()) && n.deliveredAt == null)
        .length;

    // Group by category
    final byCategory = <NotificationCategory, int>{};
    for (final model in models) {
      byCategory[model.category] = (byCategory[model.category] ?? 0) + 1;
    }

    return NotificationStats(
      totalSent: totalSent,
      totalRead: totalRead,
      totalDismissed: totalDismissed,
      unreadCount: unreadCount,
      pendingCount: pending,
      byCategory: byCategory,
    );
  }

  @override
  Future<void> scheduleItineraryNotifications(String itineraryId) async {
    // This will be implemented by the NotificationSchedulerService
    // which has access to the ItineraryRepository and other dependencies
    // No-op here since the scheduler service handles this
  }

  @override
  Future<void> cancelItineraryNotifications(String itineraryId) async {
    final models = await _localDataSource.getAllNotifications();

    // Find notifications for this itinerary
    final toRemove = models
        .where((model) => model.data?['itineraryId'] == itineraryId)
        .toList();

    // Delete each notification
    for (final model in toRemove) {
      await _localDataSource.deleteNotification(model.id);
    }
  }

  @override
  Future<bool> isNotificationTypeEnabled(NotificationType type) async {
    final prefs = await getPreferences();

    // Map notification type to preference
    switch (type) {
      case NotificationType.flightCheckInAvailable:
        return prefs.flightCheckInReminders;
      case NotificationType.flightDelayed:
      case NotificationType.flightCancelled:
      case NotificationType.flightGateChange:
        return prefs.flightDelaysAndCancellations;
      case NotificationType.weatherAlert:
      case NotificationType.severeWeatherWarning:
        return prefs.severeWeatherAlerts;
      case NotificationType.weatherSummary:
        return prefs.dailyWeatherSummary;
      case NotificationType.safetyAlert:
      case NotificationType.travelAdvisory:
        return prefs.safetyAlerts;
      case NotificationType.emergencyAlert:
        return prefs.emergencyAlerts;
      case NotificationType.nearbyRecommendation:
      case NotificationType.localDeal:
        return prefs.nearbyDeals;
      case NotificationType.eventSuggestion:
        return prefs.localEventSuggestions;
      default:
        return true;
    }
  }

  @override
  Future<void> sendTestNotification() async {
    final notification = TravelNotification(
      id: _uuid.v4(),
      type: NotificationType.tripSummary,
      category: NotificationCategory.trip,
      title: 'Test Notification',
      body: 'This is a test notification from SoloAdventurer.',
      scheduledAt: DateTime.now(),
      priority: NotificationPriority.normal,
    );

    await sendNow(notification);
  }
}
