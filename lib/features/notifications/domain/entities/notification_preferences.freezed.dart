// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationPreferences {
// Flight notifications
  bool get flightCheckInReminders;
  bool get flightDelaysAndCancellations;
  bool get flightGateChanges; // Accommodation notifications
  bool get bookingConfirmations;
  bool get checkInReminders;
  bool get reservationReminders; // Weather notifications
  bool get severeWeatherAlerts;
  bool get dailyWeatherSummary;
  bool get rainAlertsForOutdoorActivities; // Safety notifications
  bool get safetyAlerts;
  bool get travelAdvisories;
  bool get emergencyAlerts; // Recommendation notifications
  bool get nearbyDeals;
  bool get localEventSuggestions;
  bool get restaurantRecommendations; // Notification style
  bool get vibrateEnabled;
  bool get soundEnabled;
  bool get bypassDoNotDisturb; // Quiet hours
  int get quietHoursStart;
  int get quietHoursEnd; // Notification history
  bool get keepNotificationHistory;
  int get historyRetentionDays; // Location-based notifications
  bool get locationBasedNotificationsEnabled;
  int get proximityNotificationRadiusMeters; // Chat notification preferences
  List<String> get mutedChatIds;
  bool get chatMessageNotifications; // Timestamps
  DateTime? get lastUpdated;
  String? get userId;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotificationPreferencesCopyWith<NotificationPreferences> get copyWith =>
      _$NotificationPreferencesCopyWithImpl<NotificationPreferences>(
          this as NotificationPreferences, _$identity);

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NotificationPreferences &&
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
            const DeepCollectionEquality()
                .equals(other.mutedChatIds, mutedChatIds) &&
            (identical(other.chatMessageNotifications, chatMessageNotifications) || other.chatMessageNotifications == chatMessageNotifications) &&
            (identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated) &&
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
        const DeepCollectionEquality().hash(mutedChatIds),
        chatMessageNotifications,
        lastUpdated,
        userId
      ]);

  @override
  String toString() {
    return 'NotificationPreferences(flightCheckInReminders: $flightCheckInReminders, flightDelaysAndCancellations: $flightDelaysAndCancellations, flightGateChanges: $flightGateChanges, bookingConfirmations: $bookingConfirmations, checkInReminders: $checkInReminders, reservationReminders: $reservationReminders, severeWeatherAlerts: $severeWeatherAlerts, dailyWeatherSummary: $dailyWeatherSummary, rainAlertsForOutdoorActivities: $rainAlertsForOutdoorActivities, safetyAlerts: $safetyAlerts, travelAdvisories: $travelAdvisories, emergencyAlerts: $emergencyAlerts, nearbyDeals: $nearbyDeals, localEventSuggestions: $localEventSuggestions, restaurantRecommendations: $restaurantRecommendations, vibrateEnabled: $vibrateEnabled, soundEnabled: $soundEnabled, bypassDoNotDisturb: $bypassDoNotDisturb, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, keepNotificationHistory: $keepNotificationHistory, historyRetentionDays: $historyRetentionDays, locationBasedNotificationsEnabled: $locationBasedNotificationsEnabled, proximityNotificationRadiusMeters: $proximityNotificationRadiusMeters, mutedChatIds: $mutedChatIds, chatMessageNotifications: $chatMessageNotifications, lastUpdated: $lastUpdated, userId: $userId)';
  }
}

/// @nodoc
abstract mixin class $NotificationPreferencesCopyWith<$Res> {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value,
          $Res Function(NotificationPreferences) _then) =
      _$NotificationPreferencesCopyWithImpl;
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
      List<String> mutedChatIds,
      bool chatMessageNotifications,
      DateTime? lastUpdated,
      String? userId});
}

/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final NotificationPreferences _self;
  final $Res Function(NotificationPreferences) _then;

  /// Create a copy of NotificationPreferences
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
    Object? mutedChatIds = null,
    Object? chatMessageNotifications = null,
    Object? lastUpdated = freezed,
    Object? userId = freezed,
  }) {
    return _then(_self.copyWith(
      flightCheckInReminders: null == flightCheckInReminders
          ? _self.flightCheckInReminders
          : flightCheckInReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      flightDelaysAndCancellations: null == flightDelaysAndCancellations
          ? _self.flightDelaysAndCancellations
          : flightDelaysAndCancellations // ignore: cast_nullable_to_non_nullable
              as bool,
      flightGateChanges: null == flightGateChanges
          ? _self.flightGateChanges
          : flightGateChanges // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingConfirmations: null == bookingConfirmations
          ? _self.bookingConfirmations
          : bookingConfirmations // ignore: cast_nullable_to_non_nullable
              as bool,
      checkInReminders: null == checkInReminders
          ? _self.checkInReminders
          : checkInReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      reservationReminders: null == reservationReminders
          ? _self.reservationReminders
          : reservationReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      severeWeatherAlerts: null == severeWeatherAlerts
          ? _self.severeWeatherAlerts
          : severeWeatherAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      dailyWeatherSummary: null == dailyWeatherSummary
          ? _self.dailyWeatherSummary
          : dailyWeatherSummary // ignore: cast_nullable_to_non_nullable
              as bool,
      rainAlertsForOutdoorActivities: null == rainAlertsForOutdoorActivities
          ? _self.rainAlertsForOutdoorActivities
          : rainAlertsForOutdoorActivities // ignore: cast_nullable_to_non_nullable
              as bool,
      safetyAlerts: null == safetyAlerts
          ? _self.safetyAlerts
          : safetyAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      travelAdvisories: null == travelAdvisories
          ? _self.travelAdvisories
          : travelAdvisories // ignore: cast_nullable_to_non_nullable
              as bool,
      emergencyAlerts: null == emergencyAlerts
          ? _self.emergencyAlerts
          : emergencyAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      nearbyDeals: null == nearbyDeals
          ? _self.nearbyDeals
          : nearbyDeals // ignore: cast_nullable_to_non_nullable
              as bool,
      localEventSuggestions: null == localEventSuggestions
          ? _self.localEventSuggestions
          : localEventSuggestions // ignore: cast_nullable_to_non_nullable
              as bool,
      restaurantRecommendations: null == restaurantRecommendations
          ? _self.restaurantRecommendations
          : restaurantRecommendations // ignore: cast_nullable_to_non_nullable
              as bool,
      vibrateEnabled: null == vibrateEnabled
          ? _self.vibrateEnabled
          : vibrateEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      soundEnabled: null == soundEnabled
          ? _self.soundEnabled
          : soundEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      bypassDoNotDisturb: null == bypassDoNotDisturb
          ? _self.bypassDoNotDisturb
          : bypassDoNotDisturb // ignore: cast_nullable_to_non_nullable
              as bool,
      quietHoursStart: null == quietHoursStart
          ? _self.quietHoursStart
          : quietHoursStart // ignore: cast_nullable_to_non_nullable
              as int,
      quietHoursEnd: null == quietHoursEnd
          ? _self.quietHoursEnd
          : quietHoursEnd // ignore: cast_nullable_to_non_nullable
              as int,
      keepNotificationHistory: null == keepNotificationHistory
          ? _self.keepNotificationHistory
          : keepNotificationHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      historyRetentionDays: null == historyRetentionDays
          ? _self.historyRetentionDays
          : historyRetentionDays // ignore: cast_nullable_to_non_nullable
              as int,
      locationBasedNotificationsEnabled: null ==
              locationBasedNotificationsEnabled
          ? _self.locationBasedNotificationsEnabled
          : locationBasedNotificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      proximityNotificationRadiusMeters: null ==
              proximityNotificationRadiusMeters
          ? _self.proximityNotificationRadiusMeters
          : proximityNotificationRadiusMeters // ignore: cast_nullable_to_non_nullable
              as int,
      mutedChatIds: null == mutedChatIds
          ? _self.mutedChatIds
          : mutedChatIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      chatMessageNotifications: null == chatMessageNotifications
          ? _self.chatMessageNotifications
          : chatMessageNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdated: freezed == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [NotificationPreferences].
extension NotificationPreferencesPatterns on NotificationPreferences {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_NotificationPreferences value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotificationPreferences() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_NotificationPreferences value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationPreferences():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_NotificationPreferences value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationPreferences() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            bool flightCheckInReminders,
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
            List<String> mutedChatIds,
            bool chatMessageNotifications,
            DateTime? lastUpdated,
            String? userId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotificationPreferences() when $default != null:
        return $default(
            _that.flightCheckInReminders,
            _that.flightDelaysAndCancellations,
            _that.flightGateChanges,
            _that.bookingConfirmations,
            _that.checkInReminders,
            _that.reservationReminders,
            _that.severeWeatherAlerts,
            _that.dailyWeatherSummary,
            _that.rainAlertsForOutdoorActivities,
            _that.safetyAlerts,
            _that.travelAdvisories,
            _that.emergencyAlerts,
            _that.nearbyDeals,
            _that.localEventSuggestions,
            _that.restaurantRecommendations,
            _that.vibrateEnabled,
            _that.soundEnabled,
            _that.bypassDoNotDisturb,
            _that.quietHoursStart,
            _that.quietHoursEnd,
            _that.keepNotificationHistory,
            _that.historyRetentionDays,
            _that.locationBasedNotificationsEnabled,
            _that.proximityNotificationRadiusMeters,
            _that.mutedChatIds,
            _that.chatMessageNotifications,
            _that.lastUpdated,
            _that.userId);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            bool flightCheckInReminders,
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
            List<String> mutedChatIds,
            bool chatMessageNotifications,
            DateTime? lastUpdated,
            String? userId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationPreferences():
        return $default(
            _that.flightCheckInReminders,
            _that.flightDelaysAndCancellations,
            _that.flightGateChanges,
            _that.bookingConfirmations,
            _that.checkInReminders,
            _that.reservationReminders,
            _that.severeWeatherAlerts,
            _that.dailyWeatherSummary,
            _that.rainAlertsForOutdoorActivities,
            _that.safetyAlerts,
            _that.travelAdvisories,
            _that.emergencyAlerts,
            _that.nearbyDeals,
            _that.localEventSuggestions,
            _that.restaurantRecommendations,
            _that.vibrateEnabled,
            _that.soundEnabled,
            _that.bypassDoNotDisturb,
            _that.quietHoursStart,
            _that.quietHoursEnd,
            _that.keepNotificationHistory,
            _that.historyRetentionDays,
            _that.locationBasedNotificationsEnabled,
            _that.proximityNotificationRadiusMeters,
            _that.mutedChatIds,
            _that.chatMessageNotifications,
            _that.lastUpdated,
            _that.userId);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            bool flightCheckInReminders,
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
            List<String> mutedChatIds,
            bool chatMessageNotifications,
            DateTime? lastUpdated,
            String? userId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationPreferences() when $default != null:
        return $default(
            _that.flightCheckInReminders,
            _that.flightDelaysAndCancellations,
            _that.flightGateChanges,
            _that.bookingConfirmations,
            _that.checkInReminders,
            _that.reservationReminders,
            _that.severeWeatherAlerts,
            _that.dailyWeatherSummary,
            _that.rainAlertsForOutdoorActivities,
            _that.safetyAlerts,
            _that.travelAdvisories,
            _that.emergencyAlerts,
            _that.nearbyDeals,
            _that.localEventSuggestions,
            _that.restaurantRecommendations,
            _that.vibrateEnabled,
            _that.soundEnabled,
            _that.bypassDoNotDisturb,
            _that.quietHoursStart,
            _that.quietHoursEnd,
            _that.keepNotificationHistory,
            _that.historyRetentionDays,
            _that.locationBasedNotificationsEnabled,
            _that.proximityNotificationRadiusMeters,
            _that.mutedChatIds,
            _that.chatMessageNotifications,
            _that.lastUpdated,
            _that.userId);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _NotificationPreferences extends NotificationPreferences {
  const _NotificationPreferences(
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
      final List<String> mutedChatIds = const [],
      this.chatMessageNotifications = true,
      this.lastUpdated,
      this.userId})
      : _mutedChatIds = mutedChatIds,
        super._();
  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);

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
// Chat notification preferences
  final List<String> _mutedChatIds;
// Chat notification preferences
  @override
  @JsonKey()
  List<String> get mutedChatIds {
    if (_mutedChatIds is EqualUnmodifiableListView) return _mutedChatIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mutedChatIds);
  }

  @override
  @JsonKey()
  final bool chatMessageNotifications;
// Timestamps
  @override
  final DateTime? lastUpdated;
  @override
  final String? userId;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NotificationPreferencesCopyWith<_NotificationPreferences> get copyWith =>
      __$NotificationPreferencesCopyWithImpl<_NotificationPreferences>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NotificationPreferencesToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NotificationPreferences &&
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
            const DeepCollectionEquality()
                .equals(other._mutedChatIds, _mutedChatIds) &&
            (identical(other.chatMessageNotifications, chatMessageNotifications) || other.chatMessageNotifications == chatMessageNotifications) &&
            (identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated) &&
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
        const DeepCollectionEquality().hash(_mutedChatIds),
        chatMessageNotifications,
        lastUpdated,
        userId
      ]);

  @override
  String toString() {
    return 'NotificationPreferences(flightCheckInReminders: $flightCheckInReminders, flightDelaysAndCancellations: $flightDelaysAndCancellations, flightGateChanges: $flightGateChanges, bookingConfirmations: $bookingConfirmations, checkInReminders: $checkInReminders, reservationReminders: $reservationReminders, severeWeatherAlerts: $severeWeatherAlerts, dailyWeatherSummary: $dailyWeatherSummary, rainAlertsForOutdoorActivities: $rainAlertsForOutdoorActivities, safetyAlerts: $safetyAlerts, travelAdvisories: $travelAdvisories, emergencyAlerts: $emergencyAlerts, nearbyDeals: $nearbyDeals, localEventSuggestions: $localEventSuggestions, restaurantRecommendations: $restaurantRecommendations, vibrateEnabled: $vibrateEnabled, soundEnabled: $soundEnabled, bypassDoNotDisturb: $bypassDoNotDisturb, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, keepNotificationHistory: $keepNotificationHistory, historyRetentionDays: $historyRetentionDays, locationBasedNotificationsEnabled: $locationBasedNotificationsEnabled, proximityNotificationRadiusMeters: $proximityNotificationRadiusMeters, mutedChatIds: $mutedChatIds, chatMessageNotifications: $chatMessageNotifications, lastUpdated: $lastUpdated, userId: $userId)';
  }
}

/// @nodoc
abstract mixin class _$NotificationPreferencesCopyWith<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  factory _$NotificationPreferencesCopyWith(_NotificationPreferences value,
          $Res Function(_NotificationPreferences) _then) =
      __$NotificationPreferencesCopyWithImpl;
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
      List<String> mutedChatIds,
      bool chatMessageNotifications,
      DateTime? lastUpdated,
      String? userId});
}

/// @nodoc
class __$NotificationPreferencesCopyWithImpl<$Res>
    implements _$NotificationPreferencesCopyWith<$Res> {
  __$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final _NotificationPreferences _self;
  final $Res Function(_NotificationPreferences) _then;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    Object? mutedChatIds = null,
    Object? chatMessageNotifications = null,
    Object? lastUpdated = freezed,
    Object? userId = freezed,
  }) {
    return _then(_NotificationPreferences(
      flightCheckInReminders: null == flightCheckInReminders
          ? _self.flightCheckInReminders
          : flightCheckInReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      flightDelaysAndCancellations: null == flightDelaysAndCancellations
          ? _self.flightDelaysAndCancellations
          : flightDelaysAndCancellations // ignore: cast_nullable_to_non_nullable
              as bool,
      flightGateChanges: null == flightGateChanges
          ? _self.flightGateChanges
          : flightGateChanges // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingConfirmations: null == bookingConfirmations
          ? _self.bookingConfirmations
          : bookingConfirmations // ignore: cast_nullable_to_non_nullable
              as bool,
      checkInReminders: null == checkInReminders
          ? _self.checkInReminders
          : checkInReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      reservationReminders: null == reservationReminders
          ? _self.reservationReminders
          : reservationReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      severeWeatherAlerts: null == severeWeatherAlerts
          ? _self.severeWeatherAlerts
          : severeWeatherAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      dailyWeatherSummary: null == dailyWeatherSummary
          ? _self.dailyWeatherSummary
          : dailyWeatherSummary // ignore: cast_nullable_to_non_nullable
              as bool,
      rainAlertsForOutdoorActivities: null == rainAlertsForOutdoorActivities
          ? _self.rainAlertsForOutdoorActivities
          : rainAlertsForOutdoorActivities // ignore: cast_nullable_to_non_nullable
              as bool,
      safetyAlerts: null == safetyAlerts
          ? _self.safetyAlerts
          : safetyAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      travelAdvisories: null == travelAdvisories
          ? _self.travelAdvisories
          : travelAdvisories // ignore: cast_nullable_to_non_nullable
              as bool,
      emergencyAlerts: null == emergencyAlerts
          ? _self.emergencyAlerts
          : emergencyAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      nearbyDeals: null == nearbyDeals
          ? _self.nearbyDeals
          : nearbyDeals // ignore: cast_nullable_to_non_nullable
              as bool,
      localEventSuggestions: null == localEventSuggestions
          ? _self.localEventSuggestions
          : localEventSuggestions // ignore: cast_nullable_to_non_nullable
              as bool,
      restaurantRecommendations: null == restaurantRecommendations
          ? _self.restaurantRecommendations
          : restaurantRecommendations // ignore: cast_nullable_to_non_nullable
              as bool,
      vibrateEnabled: null == vibrateEnabled
          ? _self.vibrateEnabled
          : vibrateEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      soundEnabled: null == soundEnabled
          ? _self.soundEnabled
          : soundEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      bypassDoNotDisturb: null == bypassDoNotDisturb
          ? _self.bypassDoNotDisturb
          : bypassDoNotDisturb // ignore: cast_nullable_to_non_nullable
              as bool,
      quietHoursStart: null == quietHoursStart
          ? _self.quietHoursStart
          : quietHoursStart // ignore: cast_nullable_to_non_nullable
              as int,
      quietHoursEnd: null == quietHoursEnd
          ? _self.quietHoursEnd
          : quietHoursEnd // ignore: cast_nullable_to_non_nullable
              as int,
      keepNotificationHistory: null == keepNotificationHistory
          ? _self.keepNotificationHistory
          : keepNotificationHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      historyRetentionDays: null == historyRetentionDays
          ? _self.historyRetentionDays
          : historyRetentionDays // ignore: cast_nullable_to_non_nullable
              as int,
      locationBasedNotificationsEnabled: null ==
              locationBasedNotificationsEnabled
          ? _self.locationBasedNotificationsEnabled
          : locationBasedNotificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      proximityNotificationRadiusMeters: null ==
              proximityNotificationRadiusMeters
          ? _self.proximityNotificationRadiusMeters
          : proximityNotificationRadiusMeters // ignore: cast_nullable_to_non_nullable
              as int,
      mutedChatIds: null == mutedChatIds
          ? _self._mutedChatIds
          : mutedChatIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      chatMessageNotifications: null == chatMessageNotifications
          ? _self.chatMessageNotifications
          : chatMessageNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdated: freezed == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
