// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    _NotificationModel(
      id: json['id'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      category: $enumDecode(_$NotificationCategoryEnumMap, json['category']),
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      dismissedAt: json['dismissedAt'] == null
          ? null
          : DateTime.parse(json['dismissedAt'] as String),
      priority: $enumDecodeNullable(
              _$NotificationPriorityEnumMap, json['priority']) ??
          NotificationPriority.normal,
      data: json['data'] as Map<String, dynamic>?,
      isActionable: json['isActionable'] as bool? ?? false,
      actions: (json['actions'] as List<dynamic>?)
          ?.map((e) => NotificationAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      isOngoing: json['isOngoing'] as bool? ?? false,
    );

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'category': _$NotificationCategoryEnumMap[instance.category]!,
      'title': instance.title,
      'body': instance.body,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
      'dismissedAt': instance.dismissedAt?.toIso8601String(),
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'data': instance.data,
      'isActionable': instance.isActionable,
      'actions': instance.actions,
      'imageUrl': instance.imageUrl,
      'isOngoing': instance.isOngoing,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.flightCheckInAvailable: 'flightCheckInAvailable',
  NotificationType.flightDelayed: 'flightDelayed',
  NotificationType.flightCancelled: 'flightCancelled',
  NotificationType.flightGateChange: 'flightGateChange',
  NotificationType.flightBoarding: 'flightBoarding',
  NotificationType.flightLanded: 'flightLanded',
  NotificationType.hotelBookingConfirmed: 'hotelBookingConfirmed',
  NotificationType.hotelCheckInReminder: 'hotelCheckInReminder',
  NotificationType.hotelCheckOutReminder: 'hotelCheckOutReminder',
  NotificationType.reservationReminder: 'reservationReminder',
  NotificationType.activityBookingReminder: 'activityBookingReminder',
  NotificationType.ticketReminder: 'ticketReminder',
  NotificationType.weatherAlert: 'weatherAlert',
  NotificationType.weatherSummary: 'weatherSummary',
  NotificationType.severeWeatherWarning: 'severeWeatherWarning',
  NotificationType.safetyAlert: 'safetyAlert',
  NotificationType.travelAdvisory: 'travelAdvisory',
  NotificationType.emergencyAlert: 'emergencyAlert',
  NotificationType.nearbyRecommendation: 'nearbyRecommendation',
  NotificationType.localDeal: 'localDeal',
  NotificationType.eventSuggestion: 'eventSuggestion',
  NotificationType.tripSummary: 'tripSummary',
  NotificationType.itineraryUpdate: 'itineraryUpdate',
  NotificationType.dailyBriefing: 'dailyBriefing',
};

const _$NotificationCategoryEnumMap = {
  NotificationCategory.flight: 'flight',
  NotificationCategory.accommodation: 'accommodation',
  NotificationCategory.activity: 'activity',
  NotificationCategory.weather: 'weather',
  NotificationCategory.safety: 'safety',
  NotificationCategory.recommendation: 'recommendation',
  NotificationCategory.trip: 'trip',
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
};
