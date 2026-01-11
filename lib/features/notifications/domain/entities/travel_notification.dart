import 'package:freezed_annotation/freezed_annotation.dart';

part 'travel_notification.freezed.dart';
part 'travel_notification.g.dart';

/// Types of travel notifications
enum NotificationType {
  // Flight notifications
  @JsonValue('flightCheckInAvailable')
  flightCheckInAvailable,
  @JsonValue('flightDelayed')
  flightDelayed,
  @JsonValue('flightCancelled')
  flightCancelled,
  @JsonValue('flightGateChange')
  flightGateChange,
  @JsonValue('flightBoarding')
  flightBoarding,
  @JsonValue('flightLanded')
  flightLanded,

  // Accommodation notifications
  @JsonValue('hotelBookingConfirmed')
  hotelBookingConfirmed,
  @JsonValue('hotelCheckInReminder')
  hotelCheckInReminder,
  @JsonValue('hotelCheckOutReminder')
  hotelCheckOutReminder,

  // Activity notifications
  @JsonValue('reservationReminder')
  reservationReminder,
  @JsonValue('activityBookingReminder')
  activityBookingReminder,
  @JsonValue('ticketReminder')
  ticketReminder,

  // Weather notifications
  @JsonValue('weatherAlert')
  weatherAlert,
  @JsonValue('weatherSummary')
  weatherSummary,
  @JsonValue('severeWeatherWarning')
  severeWeatherWarning,

  // Safety notifications
  @JsonValue('safetyAlert')
  safetyAlert,
  @JsonValue('travelAdvisory')
  travelAdvisory,
  @JsonValue('emergencyAlert')
  emergencyAlert,

  // Recommendation notifications
  @JsonValue('nearbyRecommendation')
  nearbyRecommendation,
  @JsonValue('localDeal')
  localDeal,
  @JsonValue('eventSuggestion')
  eventSuggestion,

  // Trip notifications
  @JsonValue('tripSummary')
  tripSummary,
  @JsonValue('itineraryUpdate')
  itineraryUpdate,
  @JsonValue('dailyBriefing')
  dailyBriefing,
}

/// Categories of notifications for grouping
enum NotificationCategory {
  @JsonValue('flight')
  flight,
  @JsonValue('accommodation')
  accommodation,
  @JsonValue('activity')
  activity,
  @JsonValue('weather')
  weather,
  @JsonValue('safety')
  safety,
  @JsonValue('recommendation')
  recommendation,
  @JsonValue('trip')
  trip,
}

/// Priority levels for notifications
enum NotificationPriority {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

/// Represents an action button on a notification
@freezed
abstract class NotificationAction with _$NotificationAction {
  const factory NotificationAction({
    required String id,
    required String label,
    required NotificationActionType type,
    String? deepLink,
    Map<String, dynamic>? metadata,
  }) = _NotificationAction;

  factory NotificationAction.fromJson(Map<String, dynamic> json) =>
      _$NotificationActionFromJson(json);
}

/// Types of notification actions
enum NotificationActionType {
  @JsonValue('deepLink')
  deepLink,
  @JsonValue('dismiss')
  dismiss,
  @JsonValue('snooze')
  snooze,
  @JsonValue('acknowledge')
  acknowledge,
  @JsonValue('custom')
  custom,
}

/// Represents a travel notification
@freezed
abstract class TravelNotification with _$TravelNotification {
  const factory TravelNotification({
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
  }) = _TravelNotification;

  factory TravelNotification.fromJson(Map<String, dynamic> json) =>
      _$TravelNotificationFromJson(json);

  /// Whether the notification has been read
  bool get isRead => readAt != null;

  /// Whether the notification has been delivered
  bool get isDelivered => deliveredAt != null;

  /// Whether the notification has been dismissed
  bool get isDismissed => dismissedAt != null;

  /// Whether the notification is still relevant (not dismissed or delivered too long ago)
  bool get isActive =>
      !isDismissed &&
      (deliveredAt == null ||
          DateTime.now().difference(deliveredAt!).inDays < 7);

  /// Returns the icon to display for this notification type
  String get icon {
    switch (type) {
      case NotificationType.flightCheckInAvailable:
      case NotificationType.flightDelayed:
      case NotificationType.flightCancelled:
      case NotificationType.flightGateChange:
      case NotificationType.flightBoarding:
      case NotificationType.flightLanded:
        return '✈️';
      case NotificationType.hotelBookingConfirmed:
      case NotificationType.hotelCheckInReminder:
      case NotificationType.hotelCheckOutReminder:
        return '🏨';
      case NotificationType.reservationReminder:
      case NotificationType.activityBookingReminder:
      case NotificationType.ticketReminder:
        return '🎫';
      case NotificationType.weatherAlert:
      case NotificationType.weatherSummary:
      case NotificationType.severeWeatherWarning:
        return '🌤️';
      case NotificationType.safetyAlert:
      case NotificationType.travelAdvisory:
      case NotificationType.emergencyAlert:
        return '🛡️';
      case NotificationType.nearbyRecommendation:
      case NotificationType.localDeal:
      case NotificationType.eventSuggestion:
        return '📍';
      case NotificationType.tripSummary:
      case NotificationType.itineraryUpdate:
      case NotificationType.dailyBriefing:
        return '📅';
    }
  }

  // Private constructor for freezed getters
  const TravelNotification._();
}

/// Extension to provide display names for notification types
extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.flightCheckInAvailable:
        return 'Flight Check-In Available';
      case NotificationType.flightDelayed:
        return 'Flight Delayed';
      case NotificationType.flightCancelled:
        return 'Flight Cancelled';
      case NotificationType.flightGateChange:
        return 'Gate Change';
      case NotificationType.flightBoarding:
        return 'Now Boarding';
      case NotificationType.flightLanded:
        return 'Flight Landed';
      case NotificationType.hotelBookingConfirmed:
        return 'Booking Confirmed';
      case NotificationType.hotelCheckInReminder:
        return 'Check-In Reminder';
      case NotificationType.hotelCheckOutReminder:
        return 'Check-Out Reminder';
      case NotificationType.reservationReminder:
        return 'Reservation Reminder';
      case NotificationType.activityBookingReminder:
        return 'Booking Reminder';
      case NotificationType.ticketReminder:
        return 'Ticket Reminder';
      case NotificationType.weatherAlert:
        return 'Weather Alert';
      case NotificationType.weatherSummary:
        return 'Weather Summary';
      case NotificationType.severeWeatherWarning:
        return 'Severe Weather Warning';
      case NotificationType.safetyAlert:
        return 'Safety Alert';
      case NotificationType.travelAdvisory:
        return 'Travel Advisory';
      case NotificationType.emergencyAlert:
        return 'Emergency Alert';
      case NotificationType.nearbyRecommendation:
        return 'Nearby Recommendation';
      case NotificationType.localDeal:
        return 'Local Deal';
      case NotificationType.eventSuggestion:
        return 'Event Suggestion';
      case NotificationType.tripSummary:
        return 'Trip Summary';
      case NotificationType.itineraryUpdate:
        return 'Itinerary Updated';
      case NotificationType.dailyBriefing:
        return 'Daily Briefing';
    }
  }
}
