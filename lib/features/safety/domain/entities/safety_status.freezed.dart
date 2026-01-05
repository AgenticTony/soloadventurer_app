// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SafetyStatus _$SafetyStatusFromJson(Map<String, dynamic> json) {
  return _SafetyStatus.fromJson(json);
}

/// @nodoc
mixin _$SafetyStatus {
  /// Unique identifier for the safety status
  String get id => throw _privateConstructorUsedError;

  /// User ID
  String get userId => throw _privateConstructorUsedError;

  /// Current safety status
  SafetyStatusType get status => throw _privateConstructorUsedError;

  /// Optional message describing the status
  String? get message => throw _privateConstructorUsedError;

  /// Location associated with this status
  SafetyStatusLocation? get location => throw _privateConstructorUsedError;

  /// Battery level at time of status update (0-100)
  int? get batteryLevel => throw _privateConstructorUsedError;

  /// When this status was set
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// When this status was last updated
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Associated safety alert ID (if status was set via alert)
  String? get safetyAlertId => throw _privateConstructorUsedError;

  /// Associated check-in ID (if status was set via check-in)
  String? get checkInId => throw _privateConstructorUsedError;

  /// Additional metadata
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this SafetyStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SafetyStatusCopyWith<SafetyStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SafetyStatusCopyWith<$Res> {
  factory $SafetyStatusCopyWith(
          SafetyStatus value, $Res Function(SafetyStatus) then) =
      _$SafetyStatusCopyWithImpl<$Res, SafetyStatus>;
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
class _$SafetyStatusCopyWithImpl<$Res, $Val extends SafetyStatus>
    implements $SafetyStatusCopyWith<$Res> {
  _$SafetyStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SafetyStatusType,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as SafetyStatusLocation?,
      batteryLevel: freezed == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      safetyAlertId: freezed == safetyAlertId
          ? _value.safetyAlertId
          : safetyAlertId // ignore: cast_nullable_to_non_nullable
              as String?,
      checkInId: freezed == checkInId
          ? _value.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SafetyStatusLocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $SafetyStatusLocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SafetyStatusImplCopyWith<$Res>
    implements $SafetyStatusCopyWith<$Res> {
  factory _$$SafetyStatusImplCopyWith(
          _$SafetyStatusImpl value, $Res Function(_$SafetyStatusImpl) then) =
      __$$SafetyStatusImplCopyWithImpl<$Res>;
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
class __$$SafetyStatusImplCopyWithImpl<$Res>
    extends _$SafetyStatusCopyWithImpl<$Res, _$SafetyStatusImpl>
    implements _$$SafetyStatusImplCopyWith<$Res> {
  __$$SafetyStatusImplCopyWithImpl(
      _$SafetyStatusImpl _value, $Res Function(_$SafetyStatusImpl) _then)
      : super(_value, _then);

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
    return _then(_$SafetyStatusImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SafetyStatusType,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as SafetyStatusLocation?,
      batteryLevel: freezed == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      safetyAlertId: freezed == safetyAlertId
          ? _value.safetyAlertId
          : safetyAlertId // ignore: cast_nullable_to_non_nullable
              as String?,
      checkInId: freezed == checkInId
          ? _value.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SafetyStatusImpl implements _SafetyStatus {
  const _$SafetyStatusImpl(
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

  factory _$SafetyStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$SafetyStatusImplFromJson(json);

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

  @override
  String toString() {
    return 'SafetyStatus(id: $id, userId: $userId, status: $status, message: $message, location: $location, batteryLevel: $batteryLevel, timestamp: $timestamp, updatedAt: $updatedAt, safetyAlertId: $safetyAlertId, checkInId: $checkInId, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SafetyStatusImpl &&
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

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SafetyStatusImplCopyWith<_$SafetyStatusImpl> get copyWith =>
      __$$SafetyStatusImplCopyWithImpl<_$SafetyStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SafetyStatusImplToJson(
      this,
    );
  }
}

abstract class _SafetyStatus implements SafetyStatus {
  const factory _SafetyStatus(
      {required final String id,
      required final String userId,
      required final SafetyStatusType status,
      final String? message,
      final SafetyStatusLocation? location,
      final int? batteryLevel,
      required final DateTime timestamp,
      final DateTime? updatedAt,
      final String? safetyAlertId,
      final String? checkInId,
      final Map<String, dynamic>? metadata}) = _$SafetyStatusImpl;

  factory _SafetyStatus.fromJson(Map<String, dynamic> json) =
      _$SafetyStatusImpl.fromJson;

  /// Unique identifier for the safety status
  @override
  String get id;

  /// User ID
  @override
  String get userId;

  /// Current safety status
  @override
  SafetyStatusType get status;

  /// Optional message describing the status
  @override
  String? get message;

  /// Location associated with this status
  @override
  SafetyStatusLocation? get location;

  /// Battery level at time of status update (0-100)
  @override
  int? get batteryLevel;

  /// When this status was set
  @override
  DateTime get timestamp;

  /// When this status was last updated
  @override
  DateTime? get updatedAt;

  /// Associated safety alert ID (if status was set via alert)
  @override
  String? get safetyAlertId;

  /// Associated check-in ID (if status was set via check-in)
  @override
  String? get checkInId;

  /// Additional metadata
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of SafetyStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SafetyStatusImplCopyWith<_$SafetyStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SafetyStatusLocation _$SafetyStatusLocationFromJson(Map<String, dynamic> json) {
  return _SafetyStatusLocation.fromJson(json);
}

/// @nodoc
mixin _$SafetyStatusLocation {
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

  /// Serializes this SafetyStatusLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SafetyStatusLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SafetyStatusLocationCopyWith<SafetyStatusLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SafetyStatusLocationCopyWith<$Res> {
  factory $SafetyStatusLocationCopyWith(SafetyStatusLocation value,
          $Res Function(SafetyStatusLocation) then) =
      _$SafetyStatusLocationCopyWithImpl<$Res, SafetyStatusLocation>;
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
class _$SafetyStatusLocationCopyWithImpl<$Res,
        $Val extends SafetyStatusLocation>
    implements $SafetyStatusLocationCopyWith<$Res> {
  _$SafetyStatusLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
abstract class _$$SafetyStatusLocationImplCopyWith<$Res>
    implements $SafetyStatusLocationCopyWith<$Res> {
  factory _$$SafetyStatusLocationImplCopyWith(_$SafetyStatusLocationImpl value,
          $Res Function(_$SafetyStatusLocationImpl) then) =
      __$$SafetyStatusLocationImplCopyWithImpl<$Res>;
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
class __$$SafetyStatusLocationImplCopyWithImpl<$Res>
    extends _$SafetyStatusLocationCopyWithImpl<$Res, _$SafetyStatusLocationImpl>
    implements _$$SafetyStatusLocationImplCopyWith<$Res> {
  __$$SafetyStatusLocationImplCopyWithImpl(_$SafetyStatusLocationImpl _value,
      $Res Function(_$SafetyStatusLocationImpl) _then)
      : super(_value, _then);

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
    return _then(_$SafetyStatusLocationImpl(
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
class _$SafetyStatusLocationImpl implements _SafetyStatusLocation {
  const _$SafetyStatusLocationImpl(
      {required this.latitude,
      required this.longitude,
      this.accuracy,
      this.altitude,
      this.address,
      this.placeName,
      required this.timestamp});

  factory _$SafetyStatusLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SafetyStatusLocationImplFromJson(json);

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
    return 'SafetyStatusLocation(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, address: $address, placeName: $placeName, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SafetyStatusLocationImpl &&
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

  /// Create a copy of SafetyStatusLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SafetyStatusLocationImplCopyWith<_$SafetyStatusLocationImpl>
      get copyWith =>
          __$$SafetyStatusLocationImplCopyWithImpl<_$SafetyStatusLocationImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SafetyStatusLocationImplToJson(
      this,
    );
  }
}

abstract class _SafetyStatusLocation implements SafetyStatusLocation {
  const factory _SafetyStatusLocation(
      {required final double latitude,
      required final double longitude,
      final double? accuracy,
      final double? altitude,
      final String? address,
      final String? placeName,
      required final DateTime timestamp}) = _$SafetyStatusLocationImpl;

  factory _SafetyStatusLocation.fromJson(Map<String, dynamic> json) =
      _$SafetyStatusLocationImpl.fromJson;

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

  /// Create a copy of SafetyStatusLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SafetyStatusLocationImplCopyWith<_$SafetyStatusLocationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
