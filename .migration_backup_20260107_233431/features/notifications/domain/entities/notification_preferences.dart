import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_preferences.freezed.dart';
part 'notification_preferences.g.dart';

/// User notification preferences
///
/// Controls which types of notifications the user receives
/// and how they are delivered.
@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const NotificationPreferences._();

  const factory NotificationPreferences({
    // Flight notifications
    @Default(true) bool flightCheckInReminders,
    @Default(true) bool flightDelaysAndCancellations,
    @Default(true) bool flightGateChanges,

    // Accommodation notifications
    @Default(true) bool bookingConfirmations,
    @Default(true) bool checkInReminders,
    @Default(true) bool reservationReminders,

    // Weather notifications
    @Default(true) bool severeWeatherAlerts,
    @Default(true) bool dailyWeatherSummary,
    @Default(false) bool rainAlertsForOutdoorActivities,

    // Safety notifications
    @Default(true) bool safetyAlerts,
    @Default(true) bool travelAdvisories,
    @Default(true) bool emergencyAlerts,

    // Recommendation notifications
    @Default(false) bool nearbyDeals,
    @Default(false) bool localEventSuggestions,
    @Default(false) bool restaurantRecommendations,

    // Notification style
    @Default(true) bool vibrateEnabled,
    @Default(true) bool soundEnabled,
    @Default(false) bool bypassDoNotDisturb,

    // Quiet hours
    @Default(22) int quietHoursStart,
    @Default(7) int quietHoursEnd,

    // Notification history
    @Default(true) bool keepNotificationHistory,
    @Default(30) int historyRetentionDays,

    // Location-based notifications
    @Default(false) bool locationBasedNotificationsEnabled,
    @Default(500) int proximityNotificationRadiusMeters,

    // Timestamps
    DateTime? lastUpdated,
    String? userId,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);

  /// Checks if the current time is within quiet hours
  bool isQuietTime(DateTime now) {
    final currentHour = now.hour;
    final start = quietHoursStart;
    final end = quietHoursEnd;

    // Handle case where quiet hours span midnight (e.g., 10 PM to 7 AM)
    if (start > end) {
      return currentHour >= start || currentHour < end;
    } else {
      return currentHour >= start && currentHour < end;
    }
  }

  /// Returns the quiet hours as a formatted string
  String get quietHoursFormatted {
    final start = _formatHour(quietHoursStart);
    final end = _formatHour(quietHoursEnd);
    return '$start - $end';
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }

  /// Returns true if flight notifications are enabled
  bool get flightNotificationsEnabled =>
      flightCheckInReminders ||
      flightDelaysAndCancellations ||
      flightGateChanges;

  /// Returns true if weather notifications are enabled
  bool get weatherNotificationsEnabled =>
      severeWeatherAlerts ||
      dailyWeatherSummary ||
      rainAlertsForOutdoorActivities;

  /// Returns true if recommendation notifications are enabled
  bool get recommendationNotificationsEnabled =>
      nearbyDeals ||
      localEventSuggestions ||
      restaurantRecommendations;

  /// Returns the count of enabled notification categories
  int get enabledCategoriesCount {
    int count = 0;
    if (flightNotificationsEnabled) count++;
    if (bookingConfirmations || checkInReminders || reservationReminders) count++;
    if (weatherNotificationsEnabled) count++;
    if (safetyAlerts || travelAdvisories || emergencyAlerts) count++;
    if (recommendationNotificationsEnabled) count++;
    return count;
  }

  /// Creates a copy with updated timestamp
  NotificationPreferences withTimestamp() {
    return copyWith(lastUpdated: DateTime.now().toUtc());
  }

  /// Returns the default notification preferences
  static NotificationPreferences defaultPrefs() {
    return const NotificationPreferences(
      flightCheckInReminders: true,
      flightDelaysAndCancellations: true,
      flightGateChanges: true,
      bookingConfirmations: true,
      checkInReminders: true,
      reservationReminders: true,
      severeWeatherAlerts: true,
      dailyWeatherSummary: true,
      rainAlertsForOutdoorActivities: false,
      safetyAlerts: true,
      travelAdvisories: true,
      emergencyAlerts: true,
      nearbyDeals: false,
      localEventSuggestions: false,
      restaurantRecommendations: false,
      vibrateEnabled: true,
      soundEnabled: true,
      bypassDoNotDisturb: false,
      quietHoursStart: 22,
      quietHoursEnd: 7,
      keepNotificationHistory: true,
      historyRetentionDays: 30,
      locationBasedNotificationsEnabled: false,
      proximityNotificationRadiusMeters: 500,
    );
  }
}

/// Notification channel configuration
class NotificationChannelConfig {
  final String id;
  final String name;
  final String description;
  final Importance importance;

  const NotificationChannelConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.importance,
  });
}

/// Notification importance levels
enum Importance {
  min,
  low,
  normal,
  high,
  max,
}
