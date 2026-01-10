// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationPreferences _$NotificationPreferencesFromJson(
        Map<String, dynamic> json) =>
    _NotificationPreferences(
      flightCheckInReminders: json['flightCheckInReminders'] as bool? ?? true,
      flightDelaysAndCancellations:
          json['flightDelaysAndCancellations'] as bool? ?? true,
      flightGateChanges: json['flightGateChanges'] as bool? ?? true,
      bookingConfirmations: json['bookingConfirmations'] as bool? ?? true,
      checkInReminders: json['checkInReminders'] as bool? ?? true,
      reservationReminders: json['reservationReminders'] as bool? ?? true,
      severeWeatherAlerts: json['severeWeatherAlerts'] as bool? ?? true,
      dailyWeatherSummary: json['dailyWeatherSummary'] as bool? ?? true,
      rainAlertsForOutdoorActivities:
          json['rainAlertsForOutdoorActivities'] as bool? ?? false,
      safetyAlerts: json['safetyAlerts'] as bool? ?? true,
      travelAdvisories: json['travelAdvisories'] as bool? ?? true,
      emergencyAlerts: json['emergencyAlerts'] as bool? ?? true,
      nearbyDeals: json['nearbyDeals'] as bool? ?? false,
      localEventSuggestions: json['localEventSuggestions'] as bool? ?? false,
      restaurantRecommendations:
          json['restaurantRecommendations'] as bool? ?? false,
      vibrateEnabled: json['vibrateEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      bypassDoNotDisturb: json['bypassDoNotDisturb'] as bool? ?? false,
      quietHoursStart: (json['quietHoursStart'] as num?)?.toInt() ?? 22,
      quietHoursEnd: (json['quietHoursEnd'] as num?)?.toInt() ?? 7,
      keepNotificationHistory: json['keepNotificationHistory'] as bool? ?? true,
      historyRetentionDays:
          (json['historyRetentionDays'] as num?)?.toInt() ?? 30,
      locationBasedNotificationsEnabled:
          json['locationBasedNotificationsEnabled'] as bool? ?? false,
      proximityNotificationRadiusMeters:
          (json['proximityNotificationRadiusMeters'] as num?)?.toInt() ?? 500,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$NotificationPreferencesToJson(
        _NotificationPreferences instance) =>
    <String, dynamic>{
      'flightCheckInReminders': instance.flightCheckInReminders,
      'flightDelaysAndCancellations': instance.flightDelaysAndCancellations,
      'flightGateChanges': instance.flightGateChanges,
      'bookingConfirmations': instance.bookingConfirmations,
      'checkInReminders': instance.checkInReminders,
      'reservationReminders': instance.reservationReminders,
      'severeWeatherAlerts': instance.severeWeatherAlerts,
      'dailyWeatherSummary': instance.dailyWeatherSummary,
      'rainAlertsForOutdoorActivities': instance.rainAlertsForOutdoorActivities,
      'safetyAlerts': instance.safetyAlerts,
      'travelAdvisories': instance.travelAdvisories,
      'emergencyAlerts': instance.emergencyAlerts,
      'nearbyDeals': instance.nearbyDeals,
      'localEventSuggestions': instance.localEventSuggestions,
      'restaurantRecommendations': instance.restaurantRecommendations,
      'vibrateEnabled': instance.vibrateEnabled,
      'soundEnabled': instance.soundEnabled,
      'bypassDoNotDisturb': instance.bypassDoNotDisturb,
      'quietHoursStart': instance.quietHoursStart,
      'quietHoursEnd': instance.quietHoursEnd,
      'keepNotificationHistory': instance.keepNotificationHistory,
      'historyRetentionDays': instance.historyRetentionDays,
      'locationBasedNotificationsEnabled':
          instance.locationBasedNotificationsEnabled,
      'proximityNotificationRadiusMeters':
          instance.proximityNotificationRadiusMeters,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'userId': instance.userId,
    };
