// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SafetyAlert _$SafetyAlertFromJson(Map<String, dynamic> json) {
  return _SafetyAlert.fromJson(json);
}

/// @nodoc
mixin _$SafetyAlert {
  /// Unique identifier for the safety alert
  String get id => throw _privateConstructorUsedError;

  /// User ID who triggered the alert
  String get userId => throw _privateConstructorUsedError;

  /// Type of safety alert
  SafetyAlertType get type => throw _privateConstructorUsedError;

  /// Current status of the alert
  SafetyAlertStatus get status => throw _privateConstructorUsedError;

  /// User's safety status message
  String? get message => throw _privateConstructorUsedError;

  /// Location data at time of alert
  SafetyAlertLocation? get location => throw _privateConstructorUsedError;

  /// IDs of trusted contacts who were notified
  List<String> get notifiedContactIds => throw _privateConstructorUsedError;

  /// IDs of trusted contacts who acknowledged the alert
  List<String> get acknowledgedByContactIds =>
      throw _privateConstructorUsedError;

  /// When the alert was triggered
  DateTime get triggeredAt => throw _privateConstructorUsedError;

  /// When the alert was first acknowledged
  DateTime? get firstAcknowledgedAt => throw _privateConstructorUsedError;

  /// When the alert was resolved
  DateTime? get resolvedAt => throw _privateConstructorUsedError;

  /// When the alert was cancelled
  DateTime? get cancelledAt => throw _privateConstructorUsedError;

  /// Battery level at time of alert (0-100)
  int? get batteryLevel => throw _privateConstructorUsedError;

  /// Associated check-in ID (if alert is for missed check-in)
  String? get checkInId => throw _privateConstructorUsedError;

  /// Associated trip ID (if applicable)
  String? get tripId => throw _privateConstructorUsedError;

  /// Additional metadata
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// When this safety alert was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// When this safety alert was last updated
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SafetyAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SafetyAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SafetyAlertCopyWith<SafetyAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SafetyAlertCopyWith<$Res> {
  factory $SafetyAlertCopyWith(
          SafetyAlert value, $Res Function(SafetyAlert) then) =
      _$SafetyAlertCopyWithImpl<$Res, SafetyAlert>;
  @useResult
  $Res call(
      {String id,
      String userId,
      SafetyAlertType type,
      SafetyAlertStatus status,
      String? message,
      SafetyAlertLocation? location,
      List<String> notifiedContactIds,
      List<String> acknowledgedByContactIds,
      DateTime triggeredAt,
      DateTime? firstAcknowledgedAt,
      DateTime? resolvedAt,
      DateTime? cancelledAt,
      int? batteryLevel,
      String? checkInId,
      String? tripId,
      Map<String, dynamic>? metadata,
      DateTime createdAt,
      DateTime? updatedAt});

  $SafetyAlertLocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$SafetyAlertCopyWithImpl<$Res, $Val extends SafetyAlert>
    implements $SafetyAlertCopyWith<$Res> {
  _$SafetyAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SafetyAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? status = null,
    Object? message = freezed,
    Object? location = freezed,
    Object? notifiedContactIds = null,
    Object? acknowledgedByContactIds = null,
    Object? triggeredAt = null,
    Object? firstAcknowledgedAt = freezed,
    Object? resolvedAt = freezed,
    Object? cancelledAt = freezed,
    Object? batteryLevel = freezed,
    Object? checkInId = freezed,
    Object? tripId = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SafetyAlertType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SafetyAlertStatus,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as SafetyAlertLocation?,
      notifiedContactIds: null == notifiedContactIds
          ? _value.notifiedContactIds
          : notifiedContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      acknowledgedByContactIds: null == acknowledgedByContactIds
          ? _value.acknowledgedByContactIds
          : acknowledgedByContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      triggeredAt: null == triggeredAt
          ? _value.triggeredAt
          : triggeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      firstAcknowledgedAt: freezed == firstAcknowledgedAt
          ? _value.firstAcknowledgedAt
          : firstAcknowledgedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      batteryLevel: freezed == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      checkInId: freezed == checkInId
          ? _value.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
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

  /// Create a copy of SafetyAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SafetyAlertLocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $SafetyAlertLocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SafetyAlertImplCopyWith<$Res>
    implements $SafetyAlertCopyWith<$Res> {
  factory _$$SafetyAlertImplCopyWith(
          _$SafetyAlertImpl value, $Res Function(_$SafetyAlertImpl) then) =
      __$$SafetyAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      SafetyAlertType type,
      SafetyAlertStatus status,
      String? message,
      SafetyAlertLocation? location,
      List<String> notifiedContactIds,
      List<String> acknowledgedByContactIds,
      DateTime triggeredAt,
      DateTime? firstAcknowledgedAt,
      DateTime? resolvedAt,
      DateTime? cancelledAt,
      int? batteryLevel,
      String? checkInId,
      String? tripId,
      Map<String, dynamic>? metadata,
      DateTime createdAt,
      DateTime? updatedAt});

  @override
  $SafetyAlertLocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$$SafetyAlertImplCopyWithImpl<$Res>
    extends _$SafetyAlertCopyWithImpl<$Res, _$SafetyAlertImpl>
    implements _$$SafetyAlertImplCopyWith<$Res> {
  __$$SafetyAlertImplCopyWithImpl(
      _$SafetyAlertImpl _value, $Res Function(_$SafetyAlertImpl) _then)
      : super(_value, _then);

  /// Create a copy of SafetyAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? status = null,
    Object? message = freezed,
    Object? location = freezed,
    Object? notifiedContactIds = null,
    Object? acknowledgedByContactIds = null,
    Object? triggeredAt = null,
    Object? firstAcknowledgedAt = freezed,
    Object? resolvedAt = freezed,
    Object? cancelledAt = freezed,
    Object? batteryLevel = freezed,
    Object? checkInId = freezed,
    Object? tripId = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$SafetyAlertImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SafetyAlertType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SafetyAlertStatus,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as SafetyAlertLocation?,
      notifiedContactIds: null == notifiedContactIds
          ? _value._notifiedContactIds
          : notifiedContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      acknowledgedByContactIds: null == acknowledgedByContactIds
          ? _value._acknowledgedByContactIds
          : acknowledgedByContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      triggeredAt: null == triggeredAt
          ? _value.triggeredAt
          : triggeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      firstAcknowledgedAt: freezed == firstAcknowledgedAt
          ? _value.firstAcknowledgedAt
          : firstAcknowledgedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      batteryLevel: freezed == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      checkInId: freezed == checkInId
          ? _value.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$SafetyAlertImpl implements _SafetyAlert {
  const _$SafetyAlertImpl(
      {required this.id,
      required this.userId,
      required this.type,
      required this.status,
      this.message,
      this.location,
      required final List<String> notifiedContactIds,
      required final List<String> acknowledgedByContactIds,
      required this.triggeredAt,
      this.firstAcknowledgedAt,
      this.resolvedAt,
      this.cancelledAt,
      this.batteryLevel,
      this.checkInId,
      this.tripId,
      final Map<String, dynamic>? metadata,
      required this.createdAt,
      this.updatedAt})
      : _notifiedContactIds = notifiedContactIds,
        _acknowledgedByContactIds = acknowledgedByContactIds,
        _metadata = metadata;

  factory _$SafetyAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$SafetyAlertImplFromJson(json);

  /// Unique identifier for the safety alert
  @override
  final String id;

  /// User ID who triggered the alert
  @override
  final String userId;

  /// Type of safety alert
  @override
  final SafetyAlertType type;

  /// Current status of the alert
  @override
  final SafetyAlertStatus status;

  /// User's safety status message
  @override
  final String? message;

  /// Location data at time of alert
  @override
  final SafetyAlertLocation? location;

  /// IDs of trusted contacts who were notified
  final List<String> _notifiedContactIds;

  /// IDs of trusted contacts who were notified
  @override
  List<String> get notifiedContactIds {
    if (_notifiedContactIds is EqualUnmodifiableListView)
      return _notifiedContactIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifiedContactIds);
  }

  /// IDs of trusted contacts who acknowledged the alert
  final List<String> _acknowledgedByContactIds;

  /// IDs of trusted contacts who acknowledged the alert
  @override
  List<String> get acknowledgedByContactIds {
    if (_acknowledgedByContactIds is EqualUnmodifiableListView)
      return _acknowledgedByContactIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_acknowledgedByContactIds);
  }

  /// When the alert was triggered
  @override
  final DateTime triggeredAt;

  /// When the alert was first acknowledged
  @override
  final DateTime? firstAcknowledgedAt;

  /// When the alert was resolved
  @override
  final DateTime? resolvedAt;

  /// When the alert was cancelled
  @override
  final DateTime? cancelledAt;

  /// Battery level at time of alert (0-100)
  @override
  final int? batteryLevel;

  /// Associated check-in ID (if alert is for missed check-in)
  @override
  final String? checkInId;

  /// Associated trip ID (if applicable)
  @override
  final String? tripId;

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

  /// When this safety alert was created
  @override
  final DateTime createdAt;

  /// When this safety alert was last updated
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'SafetyAlert(id: $id, userId: $userId, type: $type, status: $status, message: $message, location: $location, notifiedContactIds: $notifiedContactIds, acknowledgedByContactIds: $acknowledgedByContactIds, triggeredAt: $triggeredAt, firstAcknowledgedAt: $firstAcknowledgedAt, resolvedAt: $resolvedAt, cancelledAt: $cancelledAt, batteryLevel: $batteryLevel, checkInId: $checkInId, tripId: $tripId, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SafetyAlertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality()
                .equals(other._notifiedContactIds, _notifiedContactIds) &&
            const DeepCollectionEquality().equals(
                other._acknowledgedByContactIds, _acknowledgedByContactIds) &&
            (identical(other.triggeredAt, triggeredAt) ||
                other.triggeredAt == triggeredAt) &&
            (identical(other.firstAcknowledgedAt, firstAcknowledgedAt) ||
                other.firstAcknowledgedAt == firstAcknowledgedAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.batteryLevel, batteryLevel) ||
                other.batteryLevel == batteryLevel) &&
            (identical(other.checkInId, checkInId) ||
                other.checkInId == checkInId) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
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
      type,
      status,
      message,
      location,
      const DeepCollectionEquality().hash(_notifiedContactIds),
      const DeepCollectionEquality().hash(_acknowledgedByContactIds),
      triggeredAt,
      firstAcknowledgedAt,
      resolvedAt,
      cancelledAt,
      batteryLevel,
      checkInId,
      tripId,
      const DeepCollectionEquality().hash(_metadata),
      createdAt,
      updatedAt);

  /// Create a copy of SafetyAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SafetyAlertImplCopyWith<_$SafetyAlertImpl> get copyWith =>
      __$$SafetyAlertImplCopyWithImpl<_$SafetyAlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SafetyAlertImplToJson(
      this,
    );
  }
}

abstract class _SafetyAlert implements SafetyAlert {
  const factory _SafetyAlert(
      {required final String id,
      required final String userId,
      required final SafetyAlertType type,
      required final SafetyAlertStatus status,
      final String? message,
      final SafetyAlertLocation? location,
      required final List<String> notifiedContactIds,
      required final List<String> acknowledgedByContactIds,
      required final DateTime triggeredAt,
      final DateTime? firstAcknowledgedAt,
      final DateTime? resolvedAt,
      final DateTime? cancelledAt,
      final int? batteryLevel,
      final String? checkInId,
      final String? tripId,
      final Map<String, dynamic>? metadata,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$SafetyAlertImpl;

  factory _SafetyAlert.fromJson(Map<String, dynamic> json) =
      _$SafetyAlertImpl.fromJson;

  /// Unique identifier for the safety alert
  @override
  String get id;

  /// User ID who triggered the alert
  @override
  String get userId;

  /// Type of safety alert
  @override
  SafetyAlertType get type;

  /// Current status of the alert
  @override
  SafetyAlertStatus get status;

  /// User's safety status message
  @override
  String? get message;

  /// Location data at time of alert
  @override
  SafetyAlertLocation? get location;

  /// IDs of trusted contacts who were notified
  @override
  List<String> get notifiedContactIds;

  /// IDs of trusted contacts who acknowledged the alert
  @override
  List<String> get acknowledgedByContactIds;

  /// When the alert was triggered
  @override
  DateTime get triggeredAt;

  /// When the alert was first acknowledged
  @override
  DateTime? get firstAcknowledgedAt;

  /// When the alert was resolved
  @override
  DateTime? get resolvedAt;

  /// When the alert was cancelled
  @override
  DateTime? get cancelledAt;

  /// Battery level at time of alert (0-100)
  @override
  int? get batteryLevel;

  /// Associated check-in ID (if alert is for missed check-in)
  @override
  String? get checkInId;

  /// Associated trip ID (if applicable)
  @override
  String? get tripId;

  /// Additional metadata
  @override
  Map<String, dynamic>? get metadata;

  /// When this safety alert was created
  @override
  DateTime get createdAt;

  /// When this safety alert was last updated
  @override
  DateTime? get updatedAt;

  /// Create a copy of SafetyAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SafetyAlertImplCopyWith<_$SafetyAlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SafetyAlertLocation _$SafetyAlertLocationFromJson(Map<String, dynamic> json) {
  return _SafetyAlertLocation.fromJson(json);
}

/// @nodoc
mixin _$SafetyAlertLocation {
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

  /// Google Maps URL
  String? get mapsUrl => throw _privateConstructorUsedError;

  /// Serializes this SafetyAlertLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SafetyAlertLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SafetyAlertLocationCopyWith<SafetyAlertLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SafetyAlertLocationCopyWith<$Res> {
  factory $SafetyAlertLocationCopyWith(
          SafetyAlertLocation value, $Res Function(SafetyAlertLocation) then) =
      _$SafetyAlertLocationCopyWithImpl<$Res, SafetyAlertLocation>;
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      double? accuracy,
      double? altitude,
      String? address,
      String? placeName,
      DateTime timestamp,
      String? mapsUrl});
}

/// @nodoc
class _$SafetyAlertLocationCopyWithImpl<$Res, $Val extends SafetyAlertLocation>
    implements $SafetyAlertLocationCopyWith<$Res> {
  _$SafetyAlertLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SafetyAlertLocation
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
    Object? mapsUrl = freezed,
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
      mapsUrl: freezed == mapsUrl
          ? _value.mapsUrl
          : mapsUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SafetyAlertLocationImplCopyWith<$Res>
    implements $SafetyAlertLocationCopyWith<$Res> {
  factory _$$SafetyAlertLocationImplCopyWith(_$SafetyAlertLocationImpl value,
          $Res Function(_$SafetyAlertLocationImpl) then) =
      __$$SafetyAlertLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      double? accuracy,
      double? altitude,
      String? address,
      String? placeName,
      DateTime timestamp,
      String? mapsUrl});
}

/// @nodoc
class __$$SafetyAlertLocationImplCopyWithImpl<$Res>
    extends _$SafetyAlertLocationCopyWithImpl<$Res, _$SafetyAlertLocationImpl>
    implements _$$SafetyAlertLocationImplCopyWith<$Res> {
  __$$SafetyAlertLocationImplCopyWithImpl(_$SafetyAlertLocationImpl _value,
      $Res Function(_$SafetyAlertLocationImpl) _then)
      : super(_value, _then);

  /// Create a copy of SafetyAlertLocation
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
    Object? mapsUrl = freezed,
  }) {
    return _then(_$SafetyAlertLocationImpl(
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
      mapsUrl: freezed == mapsUrl
          ? _value.mapsUrl
          : mapsUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SafetyAlertLocationImpl implements _SafetyAlertLocation {
  const _$SafetyAlertLocationImpl(
      {required this.latitude,
      required this.longitude,
      this.accuracy,
      this.altitude,
      this.address,
      this.placeName,
      required this.timestamp,
      this.mapsUrl});

  factory _$SafetyAlertLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SafetyAlertLocationImplFromJson(json);

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

  /// Google Maps URL
  @override
  final String? mapsUrl;

  @override
  String toString() {
    return 'SafetyAlertLocation(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, address: $address, placeName: $placeName, timestamp: $timestamp, mapsUrl: $mapsUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SafetyAlertLocationImpl &&
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
                other.timestamp == timestamp) &&
            (identical(other.mapsUrl, mapsUrl) || other.mapsUrl == mapsUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, accuracy,
      altitude, address, placeName, timestamp, mapsUrl);

  /// Create a copy of SafetyAlertLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SafetyAlertLocationImplCopyWith<_$SafetyAlertLocationImpl> get copyWith =>
      __$$SafetyAlertLocationImplCopyWithImpl<_$SafetyAlertLocationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SafetyAlertLocationImplToJson(
      this,
    );
  }
}

abstract class _SafetyAlertLocation implements SafetyAlertLocation {
  const factory _SafetyAlertLocation(
      {required final double latitude,
      required final double longitude,
      final double? accuracy,
      final double? altitude,
      final String? address,
      final String? placeName,
      required final DateTime timestamp,
      final String? mapsUrl}) = _$SafetyAlertLocationImpl;

  factory _SafetyAlertLocation.fromJson(Map<String, dynamic> json) =
      _$SafetyAlertLocationImpl.fromJson;

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

  /// Google Maps URL
  @override
  String? get mapsUrl;

  /// Create a copy of SafetyAlertLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SafetyAlertLocationImplCopyWith<_$SafetyAlertLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
