// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheckIn _$CheckInFromJson(Map<String, dynamic> json) {
  return _CheckIn.fromJson(json);
}

/// @nodoc
mixin _$CheckIn {
  /// Unique identifier for the check-in
  String get id => throw _privateConstructorUsedError;

  /// User ID who created this check-in
  String get userId => throw _privateConstructorUsedError;

  /// Type of check-in trigger
  CheckInTriggerType get triggerType => throw _privateConstructorUsedError;

  /// Current status of the check-in
  CheckInStatus get status => throw _privateConstructorUsedError;

  /// Scheduled time for the check-in (null for manual)
  DateTime? get scheduledTime => throw _privateConstructorUsedError;

  /// Deadline for completing the check-in
  DateTime? get deadline => throw _privateConstructorUsedError;

  /// When the check-in was actually completed
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Location data at check-in time
  CheckInLocation? get location => throw _privateConstructorUsedError;

  /// User's status message at check-in
  String? get statusMessage => throw _privateConstructorUsedError;

  /// Associated trip ID (if check-in is part of a trip)
  String? get tripId => throw _privateConstructorUsedError;

  /// IDs of trusted contacts to notify
  List<String> get notifyContactIds => throw _privateConstructorUsedError;

  /// Whether alert was sent to contacts for missed check-in
  bool get alertSent => throw _privateConstructorUsedError;

  /// When alert was sent (if applicable)
  DateTime? get alertSentAt => throw _privateConstructorUsedError;

  /// Additional metadata
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// When this check-in was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// When this check-in was last updated
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CheckIn to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckInCopyWith<CheckIn> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInCopyWith<$Res> {
  factory $CheckInCopyWith(CheckIn value, $Res Function(CheckIn) then) =
      _$CheckInCopyWithImpl<$Res, CheckIn>;
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
class _$CheckInCopyWithImpl<$Res, $Val extends CheckIn>
    implements $CheckInCopyWith<$Res> {
  _$CheckInCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      triggerType: null == triggerType
          ? _value.triggerType
          : triggerType // ignore: cast_nullable_to_non_nullable
              as CheckInTriggerType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CheckInStatus,
      scheduledTime: freezed == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deadline: freezed == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as CheckInLocation?,
      statusMessage: freezed == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      notifyContactIds: null == notifyContactIds
          ? _value.notifyContactIds
          : notifyContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      alertSent: null == alertSent
          ? _value.alertSent
          : alertSent // ignore: cast_nullable_to_non_nullable
              as bool,
      alertSentAt: freezed == alertSentAt
          ? _value.alertSentAt
          : alertSentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of CheckIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInLocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $CheckInLocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CheckInImplCopyWith<$Res> implements $CheckInCopyWith<$Res> {
  factory _$$CheckInImplCopyWith(
          _$CheckInImpl value, $Res Function(_$CheckInImpl) then) =
      __$$CheckInImplCopyWithImpl<$Res>;
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
class __$$CheckInImplCopyWithImpl<$Res>
    extends _$CheckInCopyWithImpl<$Res, _$CheckInImpl>
    implements _$$CheckInImplCopyWith<$Res> {
  __$$CheckInImplCopyWithImpl(
      _$CheckInImpl _value, $Res Function(_$CheckInImpl) _then)
      : super(_value, _then);

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
    return _then(_$CheckInImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      triggerType: null == triggerType
          ? _value.triggerType
          : triggerType // ignore: cast_nullable_to_non_nullable
              as CheckInTriggerType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CheckInStatus,
      scheduledTime: freezed == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deadline: freezed == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as CheckInLocation?,
      statusMessage: freezed == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      notifyContactIds: null == notifyContactIds
          ? _value._notifyContactIds
          : notifyContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      alertSent: null == alertSent
          ? _value.alertSent
          : alertSent // ignore: cast_nullable_to_non_nullable
              as bool,
      alertSentAt: freezed == alertSentAt
          ? _value.alertSentAt
          : alertSentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckInImpl implements _CheckIn {
  const _$CheckInImpl(
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

  factory _$CheckInImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckInImplFromJson(json);

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

  @override
  String toString() {
    return 'CheckIn(id: $id, userId: $userId, triggerType: $triggerType, status: $status, scheduledTime: $scheduledTime, deadline: $deadline, completedAt: $completedAt, location: $location, statusMessage: $statusMessage, tripId: $tripId, notifyContactIds: $notifyContactIds, alertSent: $alertSent, alertSentAt: $alertSentAt, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInImpl &&
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

  /// Create a copy of CheckIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInImplCopyWith<_$CheckInImpl> get copyWith =>
      __$$CheckInImplCopyWithImpl<_$CheckInImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckInImplToJson(
      this,
    );
  }
}

abstract class _CheckIn implements CheckIn {
  const factory _CheckIn(
      {required final String id,
      required final String userId,
      required final CheckInTriggerType triggerType,
      required final CheckInStatus status,
      final DateTime? scheduledTime,
      final DateTime? deadline,
      final DateTime? completedAt,
      final CheckInLocation? location,
      final String? statusMessage,
      final String? tripId,
      required final List<String> notifyContactIds,
      final bool alertSent,
      final DateTime? alertSentAt,
      final Map<String, dynamic>? metadata,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$CheckInImpl;

  factory _CheckIn.fromJson(Map<String, dynamic> json) = _$CheckInImpl.fromJson;

  /// Unique identifier for the check-in
  @override
  String get id;

  /// User ID who created this check-in
  @override
  String get userId;

  /// Type of check-in trigger
  @override
  CheckInTriggerType get triggerType;

  /// Current status of the check-in
  @override
  CheckInStatus get status;

  /// Scheduled time for the check-in (null for manual)
  @override
  DateTime? get scheduledTime;

  /// Deadline for completing the check-in
  @override
  DateTime? get deadline;

  /// When the check-in was actually completed
  @override
  DateTime? get completedAt;

  /// Location data at check-in time
  @override
  CheckInLocation? get location;

  /// User's status message at check-in
  @override
  String? get statusMessage;

  /// Associated trip ID (if check-in is part of a trip)
  @override
  String? get tripId;

  /// IDs of trusted contacts to notify
  @override
  List<String> get notifyContactIds;

  /// Whether alert was sent to contacts for missed check-in
  @override
  bool get alertSent;

  /// When alert was sent (if applicable)
  @override
  DateTime? get alertSentAt;

  /// Additional metadata
  @override
  Map<String, dynamic>? get metadata;

  /// When this check-in was created
  @override
  DateTime get createdAt;

  /// When this check-in was last updated
  @override
  DateTime? get updatedAt;

  /// Create a copy of CheckIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckInImplCopyWith<_$CheckInImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CheckInLocation _$CheckInLocationFromJson(Map<String, dynamic> json) {
  return _CheckInLocation.fromJson(json);
}

/// @nodoc
mixin _$CheckInLocation {
  /// Latitude
  double get latitude => throw _privateConstructorUsedError;

  /// Longitude
  double get longitude => throw _privateConstructorUsedError;

  /// Accuracy of the location in meters
  double? get accuracy => throw _privateConstructorUsedError;

  /// Altitude in meters
  double? get altitude => throw _privateConstructorUsedError;

  /// Human-readable address
  String? get address => throw _privateConstructorUsedError;

  /// Place name (if applicable)
  String? get placeName => throw _privateConstructorUsedError;

  /// When this location was recorded
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this CheckInLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckInLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckInLocationCopyWith<CheckInLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInLocationCopyWith<$Res> {
  factory $CheckInLocationCopyWith(
          CheckInLocation value, $Res Function(CheckInLocation) then) =
      _$CheckInLocationCopyWithImpl<$Res, CheckInLocation>;
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
class _$CheckInLocationCopyWithImpl<$Res, $Val extends CheckInLocation>
    implements $CheckInLocationCopyWith<$Res> {
  _$CheckInLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      accuracy: freezed == accuracy
          ? _value.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as double?,
      altitude: freezed == altitude
          ? _value.altitude
          : altitude // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      placeName: freezed == placeName
          ? _value.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckInLocationImplCopyWith<$Res>
    implements $CheckInLocationCopyWith<$Res> {
  factory _$$CheckInLocationImplCopyWith(_$CheckInLocationImpl value,
          $Res Function(_$CheckInLocationImpl) then) =
      __$$CheckInLocationImplCopyWithImpl<$Res>;
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
class __$$CheckInLocationImplCopyWithImpl<$Res>
    extends _$CheckInLocationCopyWithImpl<$Res, _$CheckInLocationImpl>
    implements _$$CheckInLocationImplCopyWith<$Res> {
  __$$CheckInLocationImplCopyWithImpl(
      _$CheckInLocationImpl _value, $Res Function(_$CheckInLocationImpl) _then)
      : super(_value, _then);

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
    return _then(_$CheckInLocationImpl(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      accuracy: freezed == accuracy
          ? _value.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as double?,
      altitude: freezed == altitude
          ? _value.altitude
          : altitude // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      placeName: freezed == placeName
          ? _value.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckInLocationImpl implements _CheckInLocation {
  const _$CheckInLocationImpl(
      {required this.latitude,
      required this.longitude,
      this.accuracy,
      this.altitude,
      this.address,
      this.placeName,
      required this.timestamp});

  factory _$CheckInLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckInLocationImplFromJson(json);

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

  @override
  String toString() {
    return 'CheckInLocation(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, address: $address, placeName: $placeName, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInLocationImpl &&
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

  /// Create a copy of CheckInLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInLocationImplCopyWith<_$CheckInLocationImpl> get copyWith =>
      __$$CheckInLocationImplCopyWithImpl<_$CheckInLocationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckInLocationImplToJson(
      this,
    );
  }
}

abstract class _CheckInLocation implements CheckInLocation {
  const factory _CheckInLocation(
      {required final double latitude,
      required final double longitude,
      final double? accuracy,
      final double? altitude,
      final String? address,
      final String? placeName,
      required final DateTime timestamp}) = _$CheckInLocationImpl;

  factory _CheckInLocation.fromJson(Map<String, dynamic> json) =
      _$CheckInLocationImpl.fromJson;

  /// Latitude
  @override
  double get latitude;

  /// Longitude
  @override
  double get longitude;

  /// Accuracy of the location in meters
  @override
  double? get accuracy;

  /// Altitude in meters
  @override
  double? get altitude;

  /// Human-readable address
  @override
  String? get address;

  /// Place name (if applicable)
  @override
  String? get placeName;

  /// When this location was recorded
  @override
  DateTime get timestamp;

  /// Create a copy of CheckInLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckInLocationImplCopyWith<_$CheckInLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
