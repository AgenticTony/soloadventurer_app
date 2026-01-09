import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';
import 'package:soloadventurer/features/notifications/domain/entities/travel_notification.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Model for [TravelNotification] with JSON serialization
@freezed
abstract class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required String id,
    required NotificationType type,
    required NotificationCategory category,
    required String title,
    required String body,
    required DateTime scheduledAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    DateTime? dismissedAt,
    @Default(NotificationPriority.normal) NotificationPriority priority,
    Map<String, dynamic>? data,
    @Default(false) bool isActionable,
    List<NotificationAction>? actions,
    String? imageUrl,
    @Default(false) bool isOngoing,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  /// Convert from domain entity
  factory NotificationModel.fromEntity(TravelNotification entity) {
    return NotificationModel(
      id: entity.id,
      type: entity.type,
      category: entity.category,
      title: entity.title,
      body: entity.body,
      scheduledAt: entity.scheduledAt,
      deliveredAt: entity.deliveredAt,
      readAt: entity.readAt,
      dismissedAt: entity.dismissedAt,
      priority: entity.priority,
      data: entity.data,
      isActionable: entity.isActionable,
      actions: entity.actions,
      imageUrl: entity.imageUrl,
      isOngoing: entity.isOngoing,
    );
  }

  /// Convert to domain entity
  TravelNotification toEntity() {
    return TravelNotification(
      id: id,
      type: type,
      category: category,
      title: title,
      body: body,
      scheduledAt: scheduledAt,
      deliveredAt: deliveredAt,
      readAt: readAt,
      dismissedAt: dismissedAt,
      priority: priority,
      data: data,
      isActionable: isActionable,
      actions: actions,
      imageUrl: imageUrl,
      isOngoing: isOngoing,
    );
  }

  /// Returns a copy with read status updated
  NotificationModel markAsRead() {
    return copyWith(readAt: DateTime.now().toUtc());
  }

  /// Returns a copy with dismissed status updated
  NotificationModel markAsDismissed() {
    return copyWith(dismissedAt: DateTime.now().toUtc());
  }

  /// Returns a copy with delivered status updated
  NotificationModel markAsDelivered() {
    return copyWith(deliveredAt: DateTime.now().toUtc());
  }

  /// Check if notification should be shown based on preferences
  bool shouldShow(NotificationPreferences prefs) {
    switch (category) {
      case NotificationCategory.flight:
        return prefs.flightCheckInReminders ||
               prefs.flightDelaysAndCancellations ||
               prefs.flightGateChanges;
      case NotificationCategory.accommodation:
        return prefs.bookingConfirmations ||
               prefs.checkInReminders ||
               prefs.reservationReminders;
      case NotificationCategory.activity:
        return prefs.reservationReminders;
      case NotificationCategory.weather:
        return prefs.severeWeatherAlerts ||
               prefs.dailyWeatherSummary ||
               prefs.rainAlertsForOutdoorActivities;
      case NotificationCategory.safety:
        return prefs.safetyAlerts ||
               prefs.travelAdvisories ||
               prefs.emergencyAlerts;
      case NotificationCategory.recommendation:
        return prefs.nearbyDeals ||
               prefs.localEventSuggestions ||
               prefs.restaurantRecommendations;
      case NotificationCategory.trip:
        return true; // Trip notifications are always shown
    }
  }
}
