// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SafetyStatus {
  /// Unique identifier for the safety status
  String get id;

  /// User ID
  String get userId;

  /// Current safety status
  SafetyStatusType get status;

  /// Optional message describing the status
  String? get message;

  /// Location associated with this status
  SafetyStatusLocation? get location;

  /// Battery level at time of status update (0-100)
  int? get batteryLevel;

  /// When this status was set
  DateTime get timestamp;

  /// When this status was last updated
  DateTime? get updatedAt;

  /// Associated safety alert ID (if status was set via alert)
  String? get safetyAlertId;

  /// Associated check-in ID (if status was set via check-in)
  String? get checkInId;

  /// Additional metadata
  Map<String, dynamic>? get metadata;

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SafetyStatusCopyWith<SafetyStatus> get copyWith =>
      _$SafetyStatusCopyWithImpl<SafetyStatus>(
          this as SafetyStatus, _$identity);

  /// Serializes this SafetyStatus to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SafetyStatus &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.batteryLevel, batteryLevel) ||
                other.batteryLevel == batteryLevel) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.safetyAlertId, safetyAlertId) ||
                other.safetyAlertId == safetyAlertId) &&
            (identical(other.checkInId, checkInId) ||
                other.checkInId == checkInId) &&
            const DeepCollectionEquality().equals(other.metadata, metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      status,
      message,
      location,
      batteryLevel,
      timestamp,
      updatedAt,
      safetyAlertId,
      checkInId,
      const DeepCollectionEquality().hash(metadata));

  @override
  String toString() {
    return 'SafetyStatus(id: $id, userId: $userId, status: $status, message: $message, location: $location, batteryLevel: $batteryLevel, timestamp: $timestamp, updatedAt: $updatedAt, safetyAlertId: $safetyAlertId, checkInId: $checkInId, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $SafetyStatusCopyWith<$Res> {
  factory $SafetyStatusCopyWith(
          SafetyStatus value, $Res Function(SafetyStatus) _then) =
      _$SafetyStatusCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      SafetyStatusType status,
      String? message,
      SafetyStatusLocation? location,
      int? batteryLevel,
      DateTime timestamp,
      DateTime? updatedAt,
      String? safetyAlertId,
      String? checkInId,
      Map<String, dynamic>? metadata});

  $SafetyStatusLocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$SafetyStatusCopyWithImpl<$Res> implements $SafetyStatusCopyWith<$Res> {
  _$SafetyStatusCopyWithImpl(this._self, this._then);

  final SafetyStatus _self;
  final $Res Function(SafetyStatus) _then;

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? status = null,
    Object? message = freezed,
    Object? location = freezed,
    Object? batteryLevel = freezed,
    Object? timestamp = null,
    Object? updatedAt = freezed,
    Object? safetyAlertId = freezed,
    Object? checkInId = freezed,
    Object? metadata = freezed,
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
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SafetyStatusType,
      message: freezed == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as SafetyStatusLocation?,
      batteryLevel: freezed == batteryLevel
          ? _self.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      safetyAlertId: freezed == safetyAlertId
          ? _self.safetyAlertId
          : safetyAlertId // ignore: cast_nullable_to_non_nullable
              as String?,
      checkInId: freezed == checkInId
          ? _self.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SafetyStatusLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
      return null;
    }

    return $SafetyStatusLocationCopyWith<$Res>(_self.location!, (value) {
      return _then(_self.copyWith(location: value));
    });
  }
}

/// Adds pattern-matching-related methods to [SafetyStatus].
extension SafetyStatusPatterns on SafetyStatus {
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
    TResult Function(_SafetyStatus value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyStatus() when $default != null:
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
    TResult Function(_SafetyStatus value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyStatus():
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
    TResult? Function(_SafetyStatus value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyStatus() when $default != null:
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
            SafetyStatusType status,
            String? message,
            SafetyStatusLocation? location,
            int? batteryLevel,
            DateTime timestamp,
            DateTime? updatedAt,
            String? safetyAlertId,
            String? checkInId,
            Map<String, dynamic>? metadata)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyStatus() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.status,
            _that.message,
            _that.location,
            _that.batteryLevel,
            _that.timestamp,
            _that.updatedAt,
            _that.safetyAlertId,
            _that.checkInId,
            _that.metadata);
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
            SafetyStatusType status,
            String? message,
            SafetyStatusLocation? location,
            int? batteryLevel,
            DateTime timestamp,
            DateTime? updatedAt,
            String? safetyAlertId,
            String? checkInId,
            Map<String, dynamic>? metadata)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyStatus():
        return $default(
            _that.id,
            _that.userId,
            _that.status,
            _that.message,
            _that.location,
            _that.batteryLevel,
            _that.timestamp,
            _that.updatedAt,
            _that.safetyAlertId,
            _that.checkInId,
            _that.metadata);
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
            SafetyStatusType status,
            String? message,
            SafetyStatusLocation? location,
            int? batteryLevel,
            DateTime timestamp,
            DateTime? updatedAt,
            String? safetyAlertId,
            String? checkInId,
            Map<String, dynamic>? metadata)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyStatus() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.status,
            _that.message,
            _that.location,
            _that.batteryLevel,
            _that.timestamp,
            _that.updatedAt,
            _that.safetyAlertId,
            _that.checkInId,
            _that.metadata);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SafetyStatus implements SafetyStatus {
  const _SafetyStatus(
      {required this.id,
      required this.userId,
      required this.status,
      this.message,
      this.location,
      this.batteryLevel,
      required this.timestamp,
      this.updatedAt,
      this.safetyAlertId,
      this.checkInId,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;
  factory _SafetyStatus.fromJson(Map<String, dynamic> json) =>
      _$SafetyStatusFromJson(json);

  /// Unique identifier for the safety status
  @override
  final String id;

  /// User ID
  @override
  final String userId;

  /// Current safety status
  @override
  final SafetyStatusType status;

  /// Optional message describing the status
  @override
  final String? message;

  /// Location associated with this status
  @override
  final SafetyStatusLocation? location;

  /// Battery level at time of status update (0-100)
  @override
  final int? batteryLevel;

  /// When this status was set
  @override
  final DateTime timestamp;

  /// When this status was last updated
  @override
  final DateTime? updatedAt;

  /// Associated safety alert ID (if status was set via alert)
  @override
  final String? safetyAlertId;

  /// Associated check-in ID (if status was set via check-in)
  @override
  final String? checkInId;

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

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SafetyStatusCopyWith<_SafetyStatus> get copyWith =>
      __$SafetyStatusCopyWithImpl<_SafetyStatus>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SafetyStatusToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SafetyStatus &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.batteryLevel, batteryLevel) ||
                other.batteryLevel == batteryLevel) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.safetyAlertId, safetyAlertId) ||
                other.safetyAlertId == safetyAlertId) &&
            (identical(other.checkInId, checkInId) ||
                other.checkInId == checkInId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      status,
      message,
      location,
      batteryLevel,
      timestamp,
      updatedAt,
      safetyAlertId,
      checkInId,
      const DeepCollectionEquality().hash(_metadata));

  @override
  String toString() {
    return 'SafetyStatus(id: $id, userId: $userId, status: $status, message: $message, location: $location, batteryLevel: $batteryLevel, timestamp: $timestamp, updatedAt: $updatedAt, safetyAlertId: $safetyAlertId, checkInId: $checkInId, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$SafetyStatusCopyWith<$Res>
    implements $SafetyStatusCopyWith<$Res> {
  factory _$SafetyStatusCopyWith(
          _SafetyStatus value, $Res Function(_SafetyStatus) _then) =
      __$SafetyStatusCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      SafetyStatusType status,
      String? message,
      SafetyStatusLocation? location,
      int? batteryLevel,
      DateTime timestamp,
      DateTime? updatedAt,
      String? safetyAlertId,
      String? checkInId,
      Map<String, dynamic>? metadata});

  @override
  $SafetyStatusLocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$SafetyStatusCopyWithImpl<$Res>
    implements _$SafetyStatusCopyWith<$Res> {
  __$SafetyStatusCopyWithImpl(this._self, this._then);

  final _SafetyStatus _self;
  final $Res Function(_SafetyStatus) _then;

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? status = null,
    Object? message = freezed,
    Object? location = freezed,
    Object? batteryLevel = freezed,
    Object? timestamp = null,
    Object? updatedAt = freezed,
    Object? safetyAlertId = freezed,
    Object? checkInId = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_SafetyStatus(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SafetyStatusType,
      message: freezed == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as SafetyStatusLocation?,
      batteryLevel: freezed == batteryLevel
          ? _self.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      safetyAlertId: freezed == safetyAlertId
          ? _self.safetyAlertId
          : safetyAlertId // ignore: cast_nullable_to_non_nullable
              as String?,
      checkInId: freezed == checkInId
          ? _self.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SafetyStatusLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
      return null;
    }

    return $SafetyStatusLocationCopyWith<$Res>(_self.location!, (value) {
      return _then(_self.copyWith(location: value));
    });
  }
}

/// @nodoc
mixin _$SafetyStatusLocation {
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

  /// Create a copy of SafetyStatusLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SafetyStatusLocationCopyWith<SafetyStatusLocation> get copyWith =>
      _$SafetyStatusLocationCopyWithImpl<SafetyStatusLocation>(
          this as SafetyStatusLocation, _$identity);

  /// Serializes this SafetyStatusLocation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SafetyStatusLocation &&
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
    return 'SafetyStatusLocation(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, address: $address, placeName: $placeName, timestamp: $timestamp)';
  }
}

/// @nodoc
abstract mixin class $SafetyStatusLocationCopyWith<$Res> {
  factory $SafetyStatusLocationCopyWith(SafetyStatusLocation value,
          $Res Function(SafetyStatusLocation) _then) =
      _$SafetyStatusLocationCopyWithImpl;
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
class _$SafetyStatusLocationCopyWithImpl<$Res>
    implements $SafetyStatusLocationCopyWith<$Res> {
  _$SafetyStatusLocationCopyWithImpl(this._self, this._then);

  final SafetyStatusLocation _self;
  final $Res Function(SafetyStatusLocation) _then;

  /// Create a copy of SafetyStatusLocation
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

/// Adds pattern-matching-related methods to [SafetyStatusLocation].
extension SafetyStatusLocationPatterns on SafetyStatusLocation {
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
    TResult Function(_SafetyStatusLocation value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyStatusLocation() when $default != null:
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
    TResult Function(_SafetyStatusLocation value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyStatusLocation():
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
    TResult? Function(_SafetyStatusLocation value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyStatusLocation() when $default != null:
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
      case _SafetyStatusLocation() when $default != null:
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
      case _SafetyStatusLocation():
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
      case _SafetyStatusLocation() when $default != null:
        return $default(_that.latitude, _that.longitude, _that.accuracy,
            _that.altitude, _that.address, _that.placeName, _that.timestamp);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SafetyStatusLocation implements SafetyStatusLocation {
  const _SafetyStatusLocation(
      {required this.latitude,
      required this.longitude,
      this.accuracy,
      this.altitude,
      this.address,
      this.placeName,
      required this.timestamp});
  factory _SafetyStatusLocation.fromJson(Map<String, dynamic> json) =>
      _$SafetyStatusLocationFromJson(json);

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

  /// Create a copy of SafetyStatusLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SafetyStatusLocationCopyWith<_SafetyStatusLocation> get copyWith =>
      __$SafetyStatusLocationCopyWithImpl<_SafetyStatusLocation>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SafetyStatusLocationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SafetyStatusLocation &&
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
    return 'SafetyStatusLocation(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, address: $address, placeName: $placeName, timestamp: $timestamp)';
  }
}

/// @nodoc
abstract mixin class _$SafetyStatusLocationCopyWith<$Res>
    implements $SafetyStatusLocationCopyWith<$Res> {
  factory _$SafetyStatusLocationCopyWith(_SafetyStatusLocation value,
          $Res Function(_SafetyStatusLocation) _then) =
      __$SafetyStatusLocationCopyWithImpl;
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
class __$SafetyStatusLocationCopyWithImpl<$Res>
    implements _$SafetyStatusLocationCopyWith<$Res> {
  __$SafetyStatusLocationCopyWithImpl(this._self, this._then);

  final _SafetyStatusLocation _self;
  final $Res Function(_SafetyStatusLocation) _then;

  /// Create a copy of SafetyStatusLocation
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
    return _then(_SafetyStatusLocation(
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
