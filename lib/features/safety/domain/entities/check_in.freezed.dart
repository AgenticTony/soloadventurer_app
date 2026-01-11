// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckIn {
  /// Unique identifier for the check-in
  String get id;

  /// User ID who created this check-in
  String get userId;

  /// Type of check-in trigger
  CheckInTriggerType get triggerType;

  /// Current status of the check-in
  CheckInStatus get status;

  /// Scheduled time for the check-in (null for manual)
  DateTime? get scheduledTime;

  /// Deadline for completing the check-in
  DateTime? get deadline;

  /// When the check-in was actually completed
  DateTime? get completedAt;

  /// Location data at check-in time
  CheckInLocation? get location;

  /// User's status message at check-in
  String? get statusMessage;

  /// Associated trip ID (if check-in is part of a trip)
  String? get tripId;

  /// IDs of trusted contacts to notify
  List<String> get notifyContactIds;

  /// Whether alert was sent to contacts for missed check-in
  bool get alertSent;

  /// When alert was sent (if applicable)
  DateTime? get alertSentAt;

  /// Additional metadata
  Map<String, dynamic>? get metadata;

  /// When this check-in was created
  DateTime get createdAt;

  /// When this check-in was last updated
  DateTime? get updatedAt;

  /// Create a copy of CheckIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CheckInCopyWith<CheckIn> get copyWith =>
      _$CheckInCopyWithImpl<CheckIn>(this as CheckIn, _$identity);

  /// Serializes this CheckIn to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CheckIn &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.triggerType, triggerType) ||
                other.triggerType == triggerType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.statusMessage, statusMessage) ||
                other.statusMessage == statusMessage) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            const DeepCollectionEquality()
                .equals(other.notifyContactIds, notifyContactIds) &&
            (identical(other.alertSent, alertSent) ||
                other.alertSent == alertSent) &&
            (identical(other.alertSentAt, alertSentAt) ||
                other.alertSentAt == alertSentAt) &&
            const DeepCollectionEquality().equals(other.metadata, metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      triggerType,
      status,
      scheduledTime,
      deadline,
      completedAt,
      location,
      statusMessage,
      tripId,
      const DeepCollectionEquality().hash(notifyContactIds),
      alertSent,
      alertSentAt,
      const DeepCollectionEquality().hash(metadata),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'CheckIn(id: $id, userId: $userId, triggerType: $triggerType, status: $status, scheduledTime: $scheduledTime, deadline: $deadline, completedAt: $completedAt, location: $location, statusMessage: $statusMessage, tripId: $tripId, notifyContactIds: $notifyContactIds, alertSent: $alertSent, alertSentAt: $alertSentAt, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $CheckInCopyWith<$Res> {
  factory $CheckInCopyWith(CheckIn value, $Res Function(CheckIn) _then) =
      _$CheckInCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      CheckInTriggerType triggerType,
      CheckInStatus status,
      DateTime? scheduledTime,
      DateTime? deadline,
      DateTime? completedAt,
      CheckInLocation? location,
      String? statusMessage,
      String? tripId,
      List<String> notifyContactIds,
      bool alertSent,
      DateTime? alertSentAt,
      Map<String, dynamic>? metadata,
      DateTime createdAt,
      DateTime? updatedAt});

  $CheckInLocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$CheckInCopyWithImpl<$Res> implements $CheckInCopyWith<$Res> {
  _$CheckInCopyWithImpl(this._self, this._then);

  final CheckIn _self;
  final $Res Function(CheckIn) _then;

  /// Create a copy of CheckIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? triggerType = null,
    Object? status = null,
    Object? scheduledTime = freezed,
    Object? deadline = freezed,
    Object? completedAt = freezed,
    Object? location = freezed,
    Object? statusMessage = freezed,
    Object? tripId = freezed,
    Object? notifyContactIds = null,
    Object? alertSent = null,
    Object? alertSentAt = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      triggerType: null == triggerType
          ? _self.triggerType
          : triggerType // ignore: cast_nullable_to_non_nullable
              as CheckInTriggerType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CheckInStatus,
      scheduledTime: freezed == scheduledTime
          ? _self.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deadline: freezed == deadline
          ? _self.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as CheckInLocation?,
      statusMessage: freezed == statusMessage
          ? _self.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      notifyContactIds: null == notifyContactIds
          ? _self.notifyContactIds
          : notifyContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      alertSent: null == alertSent
          ? _self.alertSent
          : alertSent // ignore: cast_nullable_to_non_nullable
              as bool,
      alertSentAt: freezed == alertSentAt
          ? _self.alertSentAt
          : alertSentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }

  /// Create a copy of CheckIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
      return null;
    }

    return $CheckInLocationCopyWith<$Res>(_self.location!, (value) {
      return _then(_self.copyWith(location: value));
    });
  }
}

/// Adds pattern-matching-related methods to [CheckIn].
extension CheckInPatterns on CheckIn {
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
    TResult Function(_CheckIn value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckIn() when $default != null:
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
    TResult Function(_CheckIn value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckIn():
        return $default(_that);
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
    TResult? Function(_CheckIn value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckIn() when $default != null:
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
            String id,
            String userId,
            CheckInTriggerType triggerType,
            CheckInStatus status,
            DateTime? scheduledTime,
            DateTime? deadline,
            DateTime? completedAt,
            CheckInLocation? location,
            String? statusMessage,
            String? tripId,
            List<String> notifyContactIds,
            bool alertSent,
            DateTime? alertSentAt,
            Map<String, dynamic>? metadata,
            DateTime createdAt,
            DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckIn() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.triggerType,
            _that.status,
            _that.scheduledTime,
            _that.deadline,
            _that.completedAt,
            _that.location,
            _that.statusMessage,
            _that.tripId,
            _that.notifyContactIds,
            _that.alertSent,
            _that.alertSentAt,
            _that.metadata,
            _that.createdAt,
            _that.updatedAt);
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
            String id,
            String userId,
            CheckInTriggerType triggerType,
            CheckInStatus status,
            DateTime? scheduledTime,
            DateTime? deadline,
            DateTime? completedAt,
            CheckInLocation? location,
            String? statusMessage,
            String? tripId,
            List<String> notifyContactIds,
            bool alertSent,
            DateTime? alertSentAt,
            Map<String, dynamic>? metadata,
            DateTime createdAt,
            DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckIn():
        return $default(
            _that.id,
            _that.userId,
            _that.triggerType,
            _that.status,
            _that.scheduledTime,
            _that.deadline,
            _that.completedAt,
            _that.location,
            _that.statusMessage,
            _that.tripId,
            _that.notifyContactIds,
            _that.alertSent,
            _that.alertSentAt,
            _that.metadata,
            _that.createdAt,
            _that.updatedAt);
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
            String id,
            String userId,
            CheckInTriggerType triggerType,
            CheckInStatus status,
            DateTime? scheduledTime,
            DateTime? deadline,
            DateTime? completedAt,
            CheckInLocation? location,
            String? statusMessage,
            String? tripId,
            List<String> notifyContactIds,
            bool alertSent,
            DateTime? alertSentAt,
            Map<String, dynamic>? metadata,
            DateTime createdAt,
            DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckIn() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.triggerType,
            _that.status,
            _that.scheduledTime,
            _that.deadline,
            _that.completedAt,
            _that.location,
            _that.statusMessage,
            _that.tripId,
            _that.notifyContactIds,
            _that.alertSent,
            _that.alertSentAt,
            _that.metadata,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CheckIn implements CheckIn {
  const _CheckIn(
      {required this.id,
      required this.userId,
      required this.triggerType,
      required this.status,
      this.scheduledTime,
      this.deadline,
      this.completedAt,
      this.location,
      this.statusMessage,
      this.tripId,
      required final List<String> notifyContactIds,
      this.alertSent = false,
      this.alertSentAt,
      final Map<String, dynamic>? metadata,
      required this.createdAt,
      this.updatedAt})
      : _notifyContactIds = notifyContactIds,
        _metadata = metadata;
  factory _CheckIn.fromJson(Map<String, dynamic> json) =>
      _$CheckInFromJson(json);

  /// Unique identifier for the check-in
  @override
  final String id;

  /// User ID who created this check-in
  @override
  final String userId;

  /// Type of check-in trigger
  @override
  final CheckInTriggerType triggerType;

  /// Current status of the check-in
  @override
  final CheckInStatus status;

  /// Scheduled time for the check-in (null for manual)
  @override
  final DateTime? scheduledTime;

  /// Deadline for completing the check-in
  @override
  final DateTime? deadline;

  /// When the check-in was actually completed
  @override
  final DateTime? completedAt;

  /// Location data at check-in time
  @override
  final CheckInLocation? location;

  /// User's status message at check-in
  @override
  final String? statusMessage;

  /// Associated trip ID (if check-in is part of a trip)
  @override
  final String? tripId;

  /// IDs of trusted contacts to notify
  final List<String> _notifyContactIds;

  /// IDs of trusted contacts to notify
  @override
  List<String> get notifyContactIds {
    if (_notifyContactIds is EqualUnmodifiableListView)
      return _notifyContactIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifyContactIds);
  }

  /// Whether alert was sent to contacts for missed check-in
  @override
  @JsonKey()
  final bool alertSent;

  /// When alert was sent (if applicable)
  @override
  final DateTime? alertSentAt;

  /// Additional metadata
  final Map<String, dynamic>? _metadata;

  /// Additional metadata
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// When this check-in was created
  @override
  final DateTime createdAt;

  /// When this check-in was last updated
  @override
  final DateTime? updatedAt;

  /// Create a copy of CheckIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CheckInCopyWith<_CheckIn> get copyWith =>
      __$CheckInCopyWithImpl<_CheckIn>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CheckInToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CheckIn &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.triggerType, triggerType) ||
                other.triggerType == triggerType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.statusMessage, statusMessage) ||
                other.statusMessage == statusMessage) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            const DeepCollectionEquality()
                .equals(other._notifyContactIds, _notifyContactIds) &&
            (identical(other.alertSent, alertSent) ||
                other.alertSent == alertSent) &&
            (identical(other.alertSentAt, alertSentAt) ||
                other.alertSentAt == alertSentAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      triggerType,
      status,
      scheduledTime,
      deadline,
      completedAt,
      location,
      statusMessage,
      tripId,
      const DeepCollectionEquality().hash(_notifyContactIds),
      alertSent,
      alertSentAt,
      const DeepCollectionEquality().hash(_metadata),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'CheckIn(id: $id, userId: $userId, triggerType: $triggerType, status: $status, scheduledTime: $scheduledTime, deadline: $deadline, completedAt: $completedAt, location: $location, statusMessage: $statusMessage, tripId: $tripId, notifyContactIds: $notifyContactIds, alertSent: $alertSent, alertSentAt: $alertSentAt, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$CheckInCopyWith<$Res> implements $CheckInCopyWith<$Res> {
  factory _$CheckInCopyWith(_CheckIn value, $Res Function(_CheckIn) _then) =
      __$CheckInCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      CheckInTriggerType triggerType,
      CheckInStatus status,
      DateTime? scheduledTime,
      DateTime? deadline,
      DateTime? completedAt,
      CheckInLocation? location,
      String? statusMessage,
      String? tripId,
      List<String> notifyContactIds,
      bool alertSent,
      DateTime? alertSentAt,
      Map<String, dynamic>? metadata,
      DateTime createdAt,
      DateTime? updatedAt});

  @override
  $CheckInLocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$CheckInCopyWithImpl<$Res> implements _$CheckInCopyWith<$Res> {
  __$CheckInCopyWithImpl(this._self, this._then);

  final _CheckIn _self;
  final $Res Function(_CheckIn) _then;

  /// Create a copy of CheckIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? triggerType = null,
    Object? status = null,
    Object? scheduledTime = freezed,
    Object? deadline = freezed,
    Object? completedAt = freezed,
    Object? location = freezed,
    Object? statusMessage = freezed,
    Object? tripId = freezed,
    Object? notifyContactIds = null,
    Object? alertSent = null,
    Object? alertSentAt = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_CheckIn(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      triggerType: null == triggerType
          ? _self.triggerType
          : triggerType // ignore: cast_nullable_to_non_nullable
              as CheckInTriggerType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CheckInStatus,
      scheduledTime: freezed == scheduledTime
          ? _self.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deadline: freezed == deadline
          ? _self.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as CheckInLocation?,
      statusMessage: freezed == statusMessage
          ? _self.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      notifyContactIds: null == notifyContactIds
          ? _self._notifyContactIds
          : notifyContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      alertSent: null == alertSent
          ? _self.alertSent
          : alertSent // ignore: cast_nullable_to_non_nullable
              as bool,
      alertSentAt: freezed == alertSentAt
          ? _self.alertSentAt
          : alertSentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }

  /// Create a copy of CheckIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
      return null;
    }

    return $CheckInLocationCopyWith<$Res>(_self.location!, (value) {
      return _then(_self.copyWith(location: value));
    });
  }
}

/// @nodoc
mixin _$CheckInLocation {
  /// Latitude
  double get latitude;

  /// Longitude
  double get longitude;

  /// Accuracy of the location in meters
  double? get accuracy;

  /// Altitude in meters
  double? get altitude;

  /// Human-readable address
  String? get address;

  /// Place name (if applicable)
  String? get placeName;

  /// When this location was recorded
  DateTime get timestamp;

  /// Create a copy of CheckInLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CheckInLocationCopyWith<CheckInLocation> get copyWith =>
      _$CheckInLocationCopyWithImpl<CheckInLocation>(
          this as CheckInLocation, _$identity);

  /// Serializes this CheckInLocation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CheckInLocation &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.altitude, altitude) ||
                other.altitude == altitude) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, accuracy,
      altitude, address, placeName, timestamp);

  @override
  String toString() {
    return 'CheckInLocation(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, address: $address, placeName: $placeName, timestamp: $timestamp)';
  }
}

/// @nodoc
abstract mixin class $CheckInLocationCopyWith<$Res> {
  factory $CheckInLocationCopyWith(
          CheckInLocation value, $Res Function(CheckInLocation) _then) =
      _$CheckInLocationCopyWithImpl;
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      double? accuracy,
      double? altitude,
      String? address,
      String? placeName,
      DateTime timestamp});
}

/// @nodoc
class _$CheckInLocationCopyWithImpl<$Res>
    implements $CheckInLocationCopyWith<$Res> {
  _$CheckInLocationCopyWithImpl(this._self, this._then);

  final CheckInLocation _self;
  final $Res Function(CheckInLocation) _then;

  /// Create a copy of CheckInLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracy = freezed,
    Object? altitude = freezed,
    Object? address = freezed,
    Object? placeName = freezed,
    Object? timestamp = null,
  }) {
    return _then(_self.copyWith(
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      accuracy: freezed == accuracy
          ? _self.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as double?,
      altitude: freezed == altitude
          ? _self.altitude
          : altitude // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      placeName: freezed == placeName
          ? _self.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [CheckInLocation].
extension CheckInLocationPatterns on CheckInLocation {
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
    TResult Function(_CheckInLocation value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckInLocation() when $default != null:
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
    TResult Function(_CheckInLocation value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInLocation():
        return $default(_that);
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
    TResult? Function(_CheckInLocation value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInLocation() when $default != null:
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
            double latitude,
            double longitude,
            double? accuracy,
            double? altitude,
            String? address,
            String? placeName,
            DateTime timestamp)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckInLocation() when $default != null:
        return $default(_that.latitude, _that.longitude, _that.accuracy,
            _that.altitude, _that.address, _that.placeName, _that.timestamp);
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
            double latitude,
            double longitude,
            double? accuracy,
            double? altitude,
            String? address,
            String? placeName,
            DateTime timestamp)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInLocation():
        return $default(_that.latitude, _that.longitude, _that.accuracy,
            _that.altitude, _that.address, _that.placeName, _that.timestamp);
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
            double latitude,
            double longitude,
            double? accuracy,
            double? altitude,
            String? address,
            String? placeName,
            DateTime timestamp)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInLocation() when $default != null:
        return $default(_that.latitude, _that.longitude, _that.accuracy,
            _that.altitude, _that.address, _that.placeName, _that.timestamp);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CheckInLocation implements CheckInLocation {
  const _CheckInLocation(
      {required this.latitude,
      required this.longitude,
      this.accuracy,
      this.altitude,
      this.address,
      this.placeName,
      required this.timestamp});
  factory _CheckInLocation.fromJson(Map<String, dynamic> json) =>
      _$CheckInLocationFromJson(json);

  /// Latitude
  @override
  final double latitude;

  /// Longitude
  @override
  final double longitude;

  /// Accuracy of the location in meters
  @override
  final double? accuracy;

  /// Altitude in meters
  @override
  final double? altitude;

  /// Human-readable address
  @override
  final String? address;

  /// Place name (if applicable)
  @override
  final String? placeName;

  /// When this location was recorded
  @override
  final DateTime timestamp;

  /// Create a copy of CheckInLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CheckInLocationCopyWith<_CheckInLocation> get copyWith =>
      __$CheckInLocationCopyWithImpl<_CheckInLocation>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CheckInLocationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CheckInLocation &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.altitude, altitude) ||
                other.altitude == altitude) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, accuracy,
      altitude, address, placeName, timestamp);

  @override
  String toString() {
    return 'CheckInLocation(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, address: $address, placeName: $placeName, timestamp: $timestamp)';
  }
}

/// @nodoc
abstract mixin class _$CheckInLocationCopyWith<$Res>
    implements $CheckInLocationCopyWith<$Res> {
  factory _$CheckInLocationCopyWith(
          _CheckInLocation value, $Res Function(_CheckInLocation) _then) =
      __$CheckInLocationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      double? accuracy,
      double? altitude,
      String? address,
      String? placeName,
      DateTime timestamp});
}

/// @nodoc
class __$CheckInLocationCopyWithImpl<$Res>
    implements _$CheckInLocationCopyWith<$Res> {
  __$CheckInLocationCopyWithImpl(this._self, this._then);

  final _CheckInLocation _self;
  final $Res Function(_CheckInLocation) _then;

  /// Create a copy of CheckInLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracy = freezed,
    Object? altitude = freezed,
    Object? address = freezed,
    Object? placeName = freezed,
    Object? timestamp = null,
  }) {
    return _then(_CheckInLocation(
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      accuracy: freezed == accuracy
          ? _self.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as double?,
      altitude: freezed == altitude
          ? _self.altitude
          : altitude // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      placeName: freezed == placeName
          ? _self.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
