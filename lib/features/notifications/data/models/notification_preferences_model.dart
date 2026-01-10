import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';

part 'notification_preferences_model.freezed.dart';
part 'notification_preferences_model.g.dart';

/// Model for [NotificationPreferences] with JSON serialization
@freezed
abstract class NotificationPreferencesModel
    with _$NotificationPreferencesModel {

  const factory NotificationPreferencesModel({
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
  }) = _NotificationPreferencesModel;

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesModelFromJson(json);

  /// Convert from domain entity
  factory NotificationPreferencesModel.fromEntity(
      NotificationPreferences entity) {
    return NotificationPreferencesModel(
      flightCheckInReminders: entity.flightCheckInReminders,
      flightDelaysAndCancellations: entity.flightDelaysAndCancellations,
      flightGateChanges: entity.flightGateChanges,
      bookingConfirmations: entity.bookingConfirmations,
      checkInReminders: entity.checkInReminders,
      reservationReminders: entity.reservationReminders,
      severeWeatherAlerts: entity.severeWeatherAlerts,
      dailyWeatherSummary: entity.dailyWeatherSummary,
      rainAlertsForOutdoorActivities: entity.rainAlertsForOutdoorActivities,
      safetyAlerts: entity.safetyAlerts,
      travelAdvisories: entity.travelAdvisories,
      emergencyAlerts: entity.emergencyAlerts,
      nearbyDeals: entity.nearbyDeals,
      localEventSuggestions: entity.localEventSuggestions,
      restaurantRecommendations: entity.restaurantRecommendations,
      vibrateEnabled: entity.vibrateEnabled,
      soundEnabled: entity.soundEnabled,
      bypassDoNotDisturb: entity.bypassDoNotDisturb,
      quietHoursStart: entity.quietHoursStart,
      quietHoursEnd: entity.quietHoursEnd,
      keepNotificationHistory: entity.keepNotificationHistory,
      historyRetentionDays: entity.historyRetentionDays,
      locationBasedNotificationsEnabled:
          entity.locationBasedNotificationsEnabled,
      proximityNotificationRadiusMeters:
          entity.proximityNotificationRadiusMeters,
      lastUpdated: entity.lastUpdated,
      userId: entity.userId,
    );
  }

  /// Convert to domain entity
  NotificationPreferences toEntity() {
    return NotificationPreferences(
      flightCheckInReminders: flightCheckInReminders,
      flightDelaysAndCancellations: flightDelaysAndCancellations,
      flightGateChanges: flightGateChanges,
      bookingConfirmations: bookingConfirmations,
      checkInReminders: checkInReminders,
      reservationReminders: reservationReminders,
      severeWeatherAlerts: severeWeatherAlerts,
      dailyWeatherSummary: dailyWeatherSummary,
      rainAlertsForOutdoorActivities: rainAlertsForOutdoorActivities,
      safetyAlerts: safetyAlerts,
      travelAdvisories: travelAdvisories,
      emergencyAlerts: emergencyAlerts,
      nearbyDeals: nearbyDeals,
      localEventSuggestions: localEventSuggestions,
      restaurantRecommendations: restaurantRecommendations,
      vibrateEnabled: vibrateEnabled,
      soundEnabled: soundEnabled,
      bypassDoNotDisturb: bypassDoNotDisturb,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
      keepNotificationHistory: keepNotificationHistory,
      historyRetentionDays: historyRetentionDays,
      locationBasedNotificationsEnabled: locationBasedNotificationsEnabled,
      proximityNotificationRadiusMeters: proximityNotificationRadiusMeters,
      lastUpdated: lastUpdated,
      userId: userId,
    );
  }

  /// Returns a copy with updated timestamp
  NotificationPreferencesModel withTimestamp() {
    return copyWith(lastUpdated: DateTime.now().toUtc());
  }
}
