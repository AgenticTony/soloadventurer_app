// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_preferences_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationPreferencesModel _$NotificationPreferencesModelFromJson(
    Map<String, dynamic> json) {
  return _NotificationPreferencesModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationPreferencesModel {
// Flight notifications
  bool get flightCheckInReminders => throw _privateConstructorUsedError;
  bool get flightDelaysAndCancellations => throw _privateConstructorUsedError;
  bool get flightGateChanges =>
      throw _privateConstructorUsedError; // Accommodation notifications
  bool get bookingConfirmations => throw _privateConstructorUsedError;
  bool get checkInReminders => throw _privateConstructorUsedError;
  bool get reservationReminders =>
      throw _privateConstructorUsedError; // Weather notifications
  bool get severeWeatherAlerts => throw _privateConstructorUsedError;
  bool get dailyWeatherSummary => throw _privateConstructorUsedError;
  bool get rainAlertsForOutdoorActivities =>
      throw _privateConstructorUsedError; // Safety notifications
  bool get safetyAlerts => throw _privateConstructorUsedError;
  bool get travelAdvisories => throw _privateConstructorUsedError;
  bool get emergencyAlerts =>
      throw _privateConstructorUsedError; // Recommendation notifications
  bool get nearbyDeals => throw _privateConstructorUsedError;
  bool get localEventSuggestions => throw _privateConstructorUsedError;
  bool get restaurantRecommendations =>
      throw _privateConstructorUsedError; // Notification style
  bool get vibrateEnabled => throw _privateConstructorUsedError;
  bool get soundEnabled => throw _privateConstructorUsedError;
  bool get bypassDoNotDisturb =>
      throw _privateConstructorUsedError; // Quiet hours
  int get quietHoursStart => throw _privateConstructorUsedError;
  int get quietHoursEnd =>
      throw _privateConstructorUsedError; // Notification history
  bool get keepNotificationHistory => throw _privateConstructorUsedError;
  int get historyRetentionDays =>
      throw _privateConstructorUsedError; // Location-based notifications
  bool get locationBasedNotificationsEnabled =>
      throw _privateConstructorUsedError;
  int get proximityNotificationRadiusMeters =>
      throw _privateConstructorUsedError; // Timestamps
  DateTime? get lastUpdated => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;

  /// Serializes this NotificationPreferencesModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPreferencesModelCopyWith<NotificationPreferencesModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPreferencesModelCopyWith<$Res> {
  factory $NotificationPreferencesModelCopyWith(
          NotificationPreferencesModel value,
          $Res Function(NotificationPreferencesModel) then) =
      _$NotificationPreferencesModelCopyWithImpl<$Res,
          NotificationPreferencesModel>;
  @useResult
  $Res call(
      {bool flightCheckInReminders,
      bool flightDelaysAndCancellations,
      bool flightGateChanges,
      bool bookingConfirmations,
      bool checkInReminders,
      bool reservationReminders,
      bool severeWeatherAlerts,
      bool dailyWeatherSummary,
      bool rainAlertsForOutdoorActivities,
      bool safetyAlerts,
      bool travelAdvisories,
      bool emergencyAlerts,
      bool nearbyDeals,
      bool localEventSuggestions,
      bool restaurantRecommendations,
      bool vibrateEnabled,
      bool soundEnabled,
      bool bypassDoNotDisturb,
      int quietHoursStart,
      int quietHoursEnd,
      bool keepNotificationHistory,
      int historyRetentionDays,
      bool locationBasedNotificationsEnabled,
      int proximityNotificationRadiusMeters,
      DateTime? lastUpdated,
      String? userId});
}

/// @nodoc
class _$NotificationPreferencesModelCopyWithImpl<$Res,
        $Val extends NotificationPreferencesModel>
    implements $NotificationPreferencesModelCopyWith<$Res> {
  _$NotificationPreferencesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? flightCheckInReminders = null,
    Object? flightDelaysAndCancellations = null,
    Object? flightGateChanges = null,
    Object? bookingConfirmations = null,
    Object? checkInReminders = null,
    Object? reservationReminders = null,
    Object? severeWeatherAlerts = null,
    Object? dailyWeatherSummary = null,
    Object? rainAlertsForOutdoorActivities = null,
    Object? safetyAlerts = null,
    Object? travelAdvisories = null,
    Object? emergencyAlerts = null,
    Object? nearbyDeals = null,
    Object? localEventSuggestions = null,
    Object? restaurantRecommendations = null,
    Object? vibrateEnabled = null,
    Object? soundEnabled = null,
    Object? bypassDoNotDisturb = null,
    Object? quietHoursStart = null,
    Object? quietHoursEnd = null,
    Object? keepNotificationHistory = null,
    Object? historyRetentionDays = null,
    Object? locationBasedNotificationsEnabled = null,
    Object? proximityNotificationRadiusMeters = null,
    Object? lastUpdated = freezed,
    Object? userId = freezed,
  }) {
    return _then(_value.copyWith(
      flightCheckInReminders: null == flightCheckInReminders
          ? _value.flightCheckInReminders
          : flightCheckInReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      flightDelaysAndCancellations: null == flightDelaysAndCancellations
          ? _value.flightDelaysAndCancellations
          : flightDelaysAndCancellations // ignore: cast_nullable_to_non_nullable
              as bool,
      flightGateChanges: null == flightGateChanges
          ? _value.flightGateChanges
          : flightGateChanges // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingConfirmations: null == bookingConfirmations
          ? _value.bookingConfirmations
          : bookingConfirmations // ignore: cast_nullable_to_non_nullable
              as bool,
      checkInReminders: null == checkInReminders
          ? _value.checkInReminders
          : checkInReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      reservationReminders: null == reservationReminders
          ? _value.reservationReminders
          : reservationReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      severeWeatherAlerts: null == severeWeatherAlerts
          ? _value.severeWeatherAlerts
          : severeWeatherAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      dailyWeatherSummary: null == dailyWeatherSummary
          ? _value.dailyWeatherSummary
          : dailyWeatherSummary // ignore: cast_nullable_to_non_nullable
              as bool,
      rainAlertsForOutdoorActivities: null == rainAlertsForOutdoorActivities
          ? _value.rainAlertsForOutdoorActivities
          : rainAlertsForOutdoorActivities // ignore: cast_nullable_to_non_nullable
              as bool,
      safetyAlerts: null == safetyAlerts
          ? _value.safetyAlerts
          : safetyAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      travelAdvisories: null == travelAdvisories
          ? _value.travelAdvisories
          : travelAdvisories // ignore: cast_nullable_to_non_nullable
              as bool,
      emergencyAlerts: null == emergencyAlerts
          ? _value.emergencyAlerts
          : emergencyAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      nearbyDeals: null == nearbyDeals
          ? _value.nearbyDeals
          : nearbyDeals // ignore: cast_nullable_to_non_nullable
              as bool,
      localEventSuggestions: null == localEventSuggestions
          ? _value.localEventSuggestions
          : localEventSuggestions // ignore: cast_nullable_to_non_nullable
              as bool,
      restaurantRecommendations: null == restaurantRecommendations
          ? _value.restaurantRecommendations
          : restaurantRecommendations // ignore: cast_nullable_to_non_nullable
              as bool,
      vibrateEnabled: null == vibrateEnabled
          ? _value.vibrateEnabled
          : vibrateEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      soundEnabled: null == soundEnabled
          ? _value.soundEnabled
          : soundEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      bypassDoNotDisturb: null == bypassDoNotDisturb
          ? _value.bypassDoNotDisturb
          : bypassDoNotDisturb // ignore: cast_nullable_to_non_nullable
              as bool,
      quietHoursStart: null == quietHoursStart
          ? _value.quietHoursStart
          : quietHoursStart // ignore: cast_nullable_to_non_nullable
              as int,
      quietHoursEnd: null == quietHoursEnd
          ? _value.quietHoursEnd
          : quietHoursEnd // ignore: cast_nullable_to_non_nullable
              as int,
      keepNotificationHistory: null == keepNotificationHistory
          ? _value.keepNotificationHistory
          : keepNotificationHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      historyRetentionDays: null == historyRetentionDays
          ? _value.historyRetentionDays
          : historyRetentionDays // ignore: cast_nullable_to_non_nullable
              as int,
      locationBasedNotificationsEnabled: null ==
              locationBasedNotificationsEnabled
          ? _value.locationBasedNotificationsEnabled
          : locationBasedNotificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      proximityNotificationRadiusMeters: null ==
              proximityNotificationRadiusMeters
          ? _value.proximityNotificationRadiusMeters
          : proximityNotificationRadiusMeters // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationPreferencesModelImplCopyWith<$Res>
    implements $NotificationPreferencesModelCopyWith<$Res> {
  factory _$$NotificationPreferencesModelImplCopyWith(
          _$NotificationPreferencesModelImpl value,
          $Res Function(_$NotificationPreferencesModelImpl) then) =
      __$$NotificationPreferencesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool flightCheckInReminders,
      bool flightDelaysAndCancellations,
      bool flightGateChanges,
      bool bookingConfirmations,
      bool checkInReminders,
      bool reservationReminders,
      bool severeWeatherAlerts,
      bool dailyWeatherSummary,
      bool rainAlertsForOutdoorActivities,
      bool safetyAlerts,
      bool travelAdvisories,
      bool emergencyAlerts,
      bool nearbyDeals,
      bool localEventSuggestions,
      bool restaurantRecommendations,
      bool vibrateEnabled,
      bool soundEnabled,
      bool bypassDoNotDisturb,
      int quietHoursStart,
      int quietHoursEnd,
      bool keepNotificationHistory,
      int historyRetentionDays,
      bool locationBasedNotificationsEnabled,
      int proximityNotificationRadiusMeters,
      DateTime? lastUpdated,
      String? userId});
}

/// @nodoc
class __$$NotificationPreferencesModelImplCopyWithImpl<$Res>
    extends _$NotificationPreferencesModelCopyWithImpl<$Res,
        _$NotificationPreferencesModelImpl>
    implements _$$NotificationPreferencesModelImplCopyWith<$Res> {
  __$$NotificationPreferencesModelImplCopyWithImpl(
      _$NotificationPreferencesModelImpl _value,
      $Res Function(_$NotificationPreferencesModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? flightCheckInReminders = null,
    Object? flightDelaysAndCancellations = null,
    Object? flightGateChanges = null,
    Object? bookingConfirmations = null,
    Object? checkInReminders = null,
    Object? reservationReminders = null,
    Object? severeWeatherAlerts = null,
    Object? dailyWeatherSummary = null,
    Object? rainAlertsForOutdoorActivities = null,
    Object? safetyAlerts = null,
    Object? travelAdvisories = null,
    Object? emergencyAlerts = null,
    Object? nearbyDeals = null,
    Object? localEventSuggestions = null,
    Object? restaurantRecommendations = null,
    Object? vibrateEnabled = null,
    Object? soundEnabled = null,
    Object? bypassDoNotDisturb = null,
    Object? quietHoursStart = null,
    Object? quietHoursEnd = null,
    Object? keepNotificationHistory = null,
    Object? historyRetentionDays = null,
    Object? locationBasedNotificationsEnabled = null,
    Object? proximityNotificationRadiusMeters = null,
    Object? lastUpdated = freezed,
    Object? userId = freezed,
  }) {
    return _then(_$NotificationPreferencesModelImpl(
      flightCheckInReminders: null == flightCheckInReminders
          ? _value.flightCheckInReminders
          : flightCheckInReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      flightDelaysAndCancellations: null == flightDelaysAndCancellations
          ? _value.flightDelaysAndCancellations
          : flightDelaysAndCancellations // ignore: cast_nullable_to_non_nullable
              as bool,
      flightGateChanges: null == flightGateChanges
          ? _value.flightGateChanges
          : flightGateChanges // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingConfirmations: null == bookingConfirmations
          ? _value.bookingConfirmations
          : bookingConfirmations // ignore: cast_nullable_to_non_nullable
              as bool,
      checkInReminders: null == checkInReminders
          ? _value.checkInReminders
          : checkInReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      reservationReminders: null == reservationReminders
          ? _value.reservationReminders
          : reservationReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      severeWeatherAlerts: null == severeWeatherAlerts
          ? _value.severeWeatherAlerts
          : severeWeatherAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      dailyWeatherSummary: null == dailyWeatherSummary
          ? _value.dailyWeatherSummary
          : dailyWeatherSummary // ignore: cast_nullable_to_non_nullable
              as bool,
      rainAlertsForOutdoorActivities: null == rainAlertsForOutdoorActivities
          ? _value.rainAlertsForOutdoorActivities
          : rainAlertsForOutdoorActivities // ignore: cast_nullable_to_non_nullable
              as bool,
      safetyAlerts: null == safetyAlerts
          ? _value.safetyAlerts
          : safetyAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      travelAdvisories: null == travelAdvisories
          ? _value.travelAdvisories
          : travelAdvisories // ignore: cast_nullable_to_non_nullable
              as bool,
      emergencyAlerts: null == emergencyAlerts
          ? _value.emergencyAlerts
          : emergencyAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      nearbyDeals: null == nearbyDeals
          ? _value.nearbyDeals
          : nearbyDeals // ignore: cast_nullable_to_non_nullable
              as bool,
      localEventSuggestions: null == localEventSuggestions
          ? _value.localEventSuggestions
          : localEventSuggestions // ignore: cast_nullable_to_non_nullable
              as bool,
      restaurantRecommendations: null == restaurantRecommendations
          ? _value.restaurantRecommendations
          : restaurantRecommendations // ignore: cast_nullable_to_non_nullable
              as bool,
      vibrateEnabled: null == vibrateEnabled
          ? _value.vibrateEnabled
          : vibrateEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      soundEnabled: null == soundEnabled
          ? _value.soundEnabled
          : soundEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      bypassDoNotDisturb: null == bypassDoNotDisturb
          ? _value.bypassDoNotDisturb
          : bypassDoNotDisturb // ignore: cast_nullable_to_non_nullable
              as bool,
      quietHoursStart: null == quietHoursStart
          ? _value.quietHoursStart
          : quietHoursStart // ignore: cast_nullable_to_non_nullable
              as int,
      quietHoursEnd: null == quietHoursEnd
          ? _value.quietHoursEnd
          : quietHoursEnd // ignore: cast_nullable_to_non_nullable
              as int,
      keepNotificationHistory: null == keepNotificationHistory
          ? _value.keepNotificationHistory
          : keepNotificationHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      historyRetentionDays: null == historyRetentionDays
          ? _value.historyRetentionDays
          : historyRetentionDays // ignore: cast_nullable_to_non_nullable
              as int,
      locationBasedNotificationsEnabled: null ==
              locationBasedNotificationsEnabled
          ? _value.locationBasedNotificationsEnabled
          : locationBasedNotificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      proximityNotificationRadiusMeters: null ==
              proximityNotificationRadiusMeters
          ? _value.proximityNotificationRadiusMeters
          : proximityNotificationRadiusMeters // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPreferencesModelImpl extends _NotificationPreferencesModel {
  const _$NotificationPreferencesModelImpl(
      {this.flightCheckInReminders = true,
      this.flightDelaysAndCancellations = true,
      this.flightGateChanges = true,
      this.bookingConfirmations = true,
      this.checkInReminders = true,
      this.reservationReminders = true,
      this.severeWeatherAlerts = true,
      this.dailyWeatherSummary = true,
      this.rainAlertsForOutdoorActivities = false,
      this.safetyAlerts = true,
      this.travelAdvisories = true,
      this.emergencyAlerts = true,
      this.nearbyDeals = false,
      this.localEventSuggestions = false,
      this.restaurantRecommendations = false,
      this.vibrateEnabled = true,
      this.soundEnabled = true,
      this.bypassDoNotDisturb = false,
      this.quietHoursStart = 22,
      this.quietHoursEnd = 7,
      this.keepNotificationHistory = true,
      this.historyRetentionDays = 30,
      this.locationBasedNotificationsEnabled = false,
      this.proximityNotificationRadiusMeters = 500,
      this.lastUpdated,
      this.userId})
      : super._();

  factory _$NotificationPreferencesModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$NotificationPreferencesModelImplFromJson(json);

// Flight notifications
  @override
  @JsonKey()
  final bool flightCheckInReminders;
  @override
  @JsonKey()
  final bool flightDelaysAndCancellations;
  @override
  @JsonKey()
  final bool flightGateChanges;
// Accommodation notifications
  @override
  @JsonKey()
  final bool bookingConfirmations;
  @override
  @JsonKey()
  final bool checkInReminders;
  @override
  @JsonKey()
  final bool reservationReminders;
// Weather notifications
  @override
  @JsonKey()
  final bool severeWeatherAlerts;
  @override
  @JsonKey()
  final bool dailyWeatherSummary;
  @override
  @JsonKey()
  final bool rainAlertsForOutdoorActivities;
// Safety notifications
  @override
  @JsonKey()
  final bool safetyAlerts;
  @override
  @JsonKey()
  final bool travelAdvisories;
  @override
  @JsonKey()
  final bool emergencyAlerts;
// Recommendation notifications
  @override
  @JsonKey()
  final bool nearbyDeals;
  @override
  @JsonKey()
  final bool localEventSuggestions;
  @override
  @JsonKey()
  final bool restaurantRecommendations;
// Notification style
  @override
  @JsonKey()
  final bool vibrateEnabled;
  @override
  @JsonKey()
  final bool soundEnabled;
  @override
  @JsonKey()
  final bool bypassDoNotDisturb;
// Quiet hours
  @override
  @JsonKey()
  final int quietHoursStart;
  @override
  @JsonKey()
  final int quietHoursEnd;
// Notification history
  @override
  @JsonKey()
  final bool keepNotificationHistory;
  @override
  @JsonKey()
  final int historyRetentionDays;
// Location-based notifications
  @override
  @JsonKey()
  final bool locationBasedNotificationsEnabled;
  @override
  @JsonKey()
  final int proximityNotificationRadiusMeters;
// Timestamps
  @override
  final DateTime? lastUpdated;
  @override
  final String? userId;

  @override
  String toString() {
    return 'NotificationPreferencesModel(flightCheckInReminders: $flightCheckInReminders, flightDelaysAndCancellations: $flightDelaysAndCancellations, flightGateChanges: $flightGateChanges, bookingConfirmations: $bookingConfirmations, checkInReminders: $checkInReminders, reservationReminders: $reservationReminders, severeWeatherAlerts: $severeWeatherAlerts, dailyWeatherSummary: $dailyWeatherSummary, rainAlertsForOutdoorActivities: $rainAlertsForOutdoorActivities, safetyAlerts: $safetyAlerts, travelAdvisories: $travelAdvisories, emergencyAlerts: $emergencyAlerts, nearbyDeals: $nearbyDeals, localEventSuggestions: $localEventSuggestions, restaurantRecommendations: $restaurantRecommendations, vibrateEnabled: $vibrateEnabled, soundEnabled: $soundEnabled, bypassDoNotDisturb: $bypassDoNotDisturb, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, keepNotificationHistory: $keepNotificationHistory, historyRetentionDays: $historyRetentionDays, locationBasedNotificationsEnabled: $locationBasedNotificationsEnabled, proximityNotificationRadiusMeters: $proximityNotificationRadiusMeters, lastUpdated: $lastUpdated, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPreferencesModelImpl &&
            (identical(other.flightCheckInReminders, flightCheckInReminders) ||
                other.flightCheckInReminders == flightCheckInReminders) &&
            (identical(other.flightDelaysAndCancellations, flightDelaysAndCancellations) ||
                other.flightDelaysAndCancellations ==
                    flightDelaysAndCancellations) &&
            (identical(other.flightGateChanges, flightGateChanges) ||
                other.flightGateChanges == flightGateChanges) &&
            (identical(other.bookingConfirmations, bookingConfirmations) ||
                other.bookingConfirmations == bookingConfirmations) &&
            (identical(other.checkInReminders, checkInReminders) ||
                other.checkInReminders == checkInReminders) &&
            (identical(other.reservationReminders, reservationReminders) ||
                other.reservationReminders == reservationReminders) &&
            (identical(other.severeWeatherAlerts, severeWeatherAlerts) ||
                other.severeWeatherAlerts == severeWeatherAlerts) &&
            (identical(other.dailyWeatherSummary, dailyWeatherSummary) ||
                other.dailyWeatherSummary == dailyWeatherSummary) &&
            (identical(other.rainAlertsForOutdoorActivities, rainAlertsForOutdoorActivities) ||
                other.rainAlertsForOutdoorActivities ==
                    rainAlertsForOutdoorActivities) &&
            (identical(other.safetyAlerts, safetyAlerts) ||
                other.safetyAlerts == safetyAlerts) &&
            (identical(other.travelAdvisories, travelAdvisories) ||
                other.travelAdvisories == travelAdvisories) &&
            (identical(other.emergencyAlerts, emergencyAlerts) ||
                other.emergencyAlerts == emergencyAlerts) &&
            (identical(other.nearbyDeals, nearbyDeals) ||
                other.nearbyDeals == nearbyDeals) &&
            (identical(other.localEventSuggestions, localEventSuggestions) ||
                other.localEventSuggestions == localEventSuggestions) &&
            (identical(other.restaurantRecommendations, restaurantRecommendations) ||
                other.restaurantRecommendations == restaurantRecommendations) &&
            (identical(other.vibrateEnabled, vibrateEnabled) ||
                other.vibrateEnabled == vibrateEnabled) &&
            (identical(other.soundEnabled, soundEnabled) ||
                other.soundEnabled == soundEnabled) &&
            (identical(other.bypassDoNotDisturb, bypassDoNotDisturb) ||
                other.bypassDoNotDisturb == bypassDoNotDisturb) &&
            (identical(other.quietHoursStart, quietHoursStart) ||
                other.quietHoursStart == quietHoursStart) &&
            (identical(other.quietHoursEnd, quietHoursEnd) ||
                other.quietHoursEnd == quietHoursEnd) &&
            (identical(other.keepNotificationHistory, keepNotificationHistory) ||
                other.keepNotificationHistory == keepNotificationHistory) &&
            (identical(other.historyRetentionDays, historyRetentionDays) ||
                other.historyRetentionDays == historyRetentionDays) &&
            (identical(other.locationBasedNotificationsEnabled, locationBasedNotificationsEnabled) ||
                other.locationBasedNotificationsEnabled ==
                    locationBasedNotificationsEnabled) &&
            (identical(other.proximityNotificationRadiusMeters, proximityNotificationRadiusMeters) ||
                other.proximityNotificationRadiusMeters ==
                    proximityNotificationRadiusMeters) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        flightCheckInReminders,
        flightDelaysAndCancellations,
        flightGateChanges,
        bookingConfirmations,
        checkInReminders,
        reservationReminders,
        severeWeatherAlerts,
        dailyWeatherSummary,
        rainAlertsForOutdoorActivities,
        safetyAlerts,
        travelAdvisories,
        emergencyAlerts,
        nearbyDeals,
        localEventSuggestions,
        restaurantRecommendations,
        vibrateEnabled,
        soundEnabled,
        bypassDoNotDisturb,
        quietHoursStart,
        quietHoursEnd,
        keepNotificationHistory,
        historyRetentionDays,
        locationBasedNotificationsEnabled,
        proximityNotificationRadiusMeters,
        lastUpdated,
        userId
      ]);

  /// Create a copy of NotificationPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPreferencesModelImplCopyWith<
          _$NotificationPreferencesModelImpl>
      get copyWith => __$$NotificationPreferencesModelImplCopyWithImpl<
          _$NotificationPreferencesModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPreferencesModelImplToJson(
      this,
    );
  }
}

abstract class _NotificationPreferencesModel
    extends NotificationPreferencesModel {
  const factory _NotificationPreferencesModel(
      {final bool flightCheckInReminders,
      final bool flightDelaysAndCancellations,
      final bool flightGateChanges,
      final bool bookingConfirmations,
      final bool checkInReminders,
      final bool reservationReminders,
      final bool severeWeatherAlerts,
      final bool dailyWeatherSummary,
      final bool rainAlertsForOutdoorActivities,
      final bool safetyAlerts,
      final bool travelAdvisories,
      final bool emergencyAlerts,
      final bool nearbyDeals,
      final bool localEventSuggestions,
      final bool restaurantRecommendations,
      final bool vibrateEnabled,
      final bool soundEnabled,
      final bool bypassDoNotDisturb,
      final int quietHoursStart,
      final int quietHoursEnd,
      final bool keepNotificationHistory,
      final int historyRetentionDays,
      final bool locationBasedNotificationsEnabled,
      final int proximityNotificationRadiusMeters,
      final DateTime? lastUpdated,
      final String? userId}) = _$NotificationPreferencesModelImpl;
  const _NotificationPreferencesModel._() : super._();

  factory _NotificationPreferencesModel.fromJson(Map<String, dynamic> json) =
      _$NotificationPreferencesModelImpl.fromJson;

// Flight notifications
  @override
  bool get flightCheckInReminders;
  @override
  bool get flightDelaysAndCancellations;
  @override
  bool get flightGateChanges; // Accommodation notifications
  @override
  bool get bookingConfirmations;
  @override
  bool get checkInReminders;
  @override
  bool get reservationReminders; // Weather notifications
  @override
  bool get severeWeatherAlerts;
  @override
  bool get dailyWeatherSummary;
  @override
  bool get rainAlertsForOutdoorActivities; // Safety notifications
  @override
  bool get safetyAlerts;
  @override
  bool get travelAdvisories;
  @override
  bool get emergencyAlerts; // Recommendation notifications
  @override
  bool get nearbyDeals;
  @override
  bool get localEventSuggestions;
  @override
  bool get restaurantRecommendations; // Notification style
  @override
  bool get vibrateEnabled;
  @override
  bool get soundEnabled;
  @override
  bool get bypassDoNotDisturb; // Quiet hours
  @override
  int get quietHoursStart;
  @override
  int get quietHoursEnd; // Notification history
  @override
  bool get keepNotificationHistory;
  @override
  int get historyRetentionDays; // Location-based notifications
  @override
  bool get locationBasedNotificationsEnabled;
  @override
  int get proximityNotificationRadiusMeters; // Timestamps
  @override
  DateTime? get lastUpdated;
  @override
  String? get userId;

  /// Create a copy of NotificationPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPreferencesModelImplCopyWith<
          _$NotificationPreferencesModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
