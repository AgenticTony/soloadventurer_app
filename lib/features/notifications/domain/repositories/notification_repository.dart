import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';
import 'package:soloadventurer/features/notifications/domain/entities/travel_notification.dart';

/// Repository interface for notification operations
///
/// Provides methods for scheduling, sending, and managing notifications
/// as well as managing user notification preferences.
abstract class NotificationRepository {
  /// Schedule a notification for future delivery
  Future<void> schedule(TravelNotification notification);

  /// Send a notification immediately
  Future<void> sendNow(TravelNotification notification);

  /// Cancel a scheduled notification
  Future<void> cancel(String notificationId);

  /// Cancel all scheduled notifications
  Future<void> cancelAll();

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId);

  /// Dismiss a notification
  Future<void> dismiss(String notificationId);

  /// Get notification history with optional filters
  Future<List<TravelNotification>> getHistory({
    DateTime? startDate,
    DateTime? endDate,
    NotificationCategory? category,
    int limit = 50,
    int offset = 0,
  });

  /// Get unread notifications
  Future<List<TravelNotification>> getUnread({
    int limit = 20,
  });

  /// Get pending (scheduled) notifications
  Future<List<TravelNotification>> getPending();

  /// Update user notification preferences
  Future<void> updatePreferences(NotificationPreferences preferences);

  /// Get user notification preferences
  Future<NotificationPreferences> getPreferences();

  /// Clear notification history
  Future<void> clearHistory({
    DateTime? beforeDate,
  });

  /// Get notification statistics
  Future<NotificationStats> getStats();

  /// Schedule notifications for an entire itinerary
  Future<void> scheduleItineraryNotifications(String itineraryId);

  /// Cancel all notifications for an itinerary
  Future<void> cancelItineraryNotifications(String itineraryId);

  /// Check if a notification type is enabled based on preferences
  Future<bool> isNotificationTypeEnabled(NotificationType type);

  /// Test notification delivery
  Future<void> sendTestNotification();
}

/// Notification statistics
class NotificationStats {
  final int totalSent;
  final int totalRead;
  final int totalDismissed;
  final int unreadCount;
  final int pendingCount;
  final Map<NotificationCategory, int> byCategory;

  const NotificationStats({
    required this.totalSent,
    required this.totalRead,
    required this.totalDismissed,
    required this.unreadCount,
    required this.pendingCount,
    required this.byCategory,
  });

  /// Calculate open rate percentage
  double get openRate {
    if (totalSent == 0) return 0.0;
    return (totalRead / totalSent) * 100;
  }

  /// Calculate dismiss rate percentage
  double get dismissRate {
    if (totalSent == 0) return 0.0;
    return (totalDismissed / totalSent) * 100;
  }

  NotificationStats copyWith({
    int? totalSent,
    int? totalRead,
    int? totalDismissed,
    int? unreadCount,
    int? pendingCount,
    Map<NotificationCategory, int>? byCategory,
  }) {
    return NotificationStats(
      totalSent: totalSent ?? this.totalSent,
      totalRead: totalRead ?? this.totalRead,
      totalDismissed: totalDismissed ?? this.totalDismissed,
      unreadCount: unreadCount ?? this.unreadCount,
      pendingCount: pendingCount ?? this.pendingCount,
      byCategory: byCategory ?? this.byCategory,
    );
  }
}
