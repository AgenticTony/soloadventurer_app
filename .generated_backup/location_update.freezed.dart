// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocationUpdate _$LocationUpdateFromJson(Map<String, dynamic> json) {
  return _LocationUpdate.fromJson(json);
}

/// @nodoc
mixin _$LocationUpdate {
  /// Unique identifier for the location update
  String get id => throw _privateConstructorUsedError;

  /// User ID who is sharing their location
  String get userId => throw _privateConstructorUsedError;

  /// Latitude
  double get latitude => throw _privateConstructorUsedError;

  /// Longitude
  double get longitude => throw _privateConstructorUsedError;

  /// Accuracy of the location in meters
  double? get accuracy => throw _privateConstructorUsedError;

  /// Altitude in meters
  double? get altitude => throw _privateConstructorUsedError;

  /// Speed in m/s
  double? get speed => throw _privateConstructorUsedError;

  /// Heading in degrees
  double? get heading => throw _privateConstructorUsedError;

  /// Human-readable address
  String? get address => throw _privateConstructorUsedError;

  /// Place name (if applicable)
  String? get placeName => throw _privateConstructorUsedError;

  /// Status of location sharing
  LocationSharingStatus get sharingStatus => throw _privateConstructorUsedError;

  /// IDs of trusted contacts receiving this update
  List<String> get sharedWithContactIds => throw _privateConstructorUsedError;

  /// Battery level at time of update (0-100)
  int? get batteryLevel => throw _privateConstructorUsedError;

  /// Whether this is an emergency location update
  bool get isEmergency => throw _privateConstructorUsedError;

  /// Associated emergency/SOS alert ID (if applicable)
  String? get emergencyAlertId => throw _privateConstructorUsedError;

  /// Associated check-in ID (if applicable)
  String? get checkInId => throw _privateConstructorUsedError;

  /// Additional metadata
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// When this location update was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LocationUpdate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationUpdateCopyWith<LocationUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationUpdateCopyWith<$Res> {
  factory $LocationUpdateCopyWith(
          LocationUpdate value, $Res Function(LocationUpdate) then) =
      _$LocationUpdateCopyWithImpl<$Res, LocationUpdate>;
  @useResult
  $Res call(
      {String id,
      String userId,
      double latitude,
      double longitude,
      double? accuracy,
      double? altitude,
      double? speed,
      double? heading,
      String? address,
      String? placeName,
      LocationSharingStatus sharingStatus,
      List<String> sharedWithContactIds,
      int? batteryLevel,
      bool isEmergency,
      String? emergencyAlertId,
      String? checkInId,
      Map<String, dynamic>? metadata,
      DateTime createdAt});
}

/// @nodoc
class _$LocationUpdateCopyWithImpl<$Res, $Val extends LocationUpdate>
    implements $LocationUpdateCopyWith<$Res> {
  _$LocationUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracy = freezed,
    Object? altitude = freezed,
    Object? speed = freezed,
    Object? heading = freezed,
    Object? address = freezed,
    Object? placeName = freezed,
    Object? sharingStatus = null,
    Object? sharedWithContactIds = null,
    Object? batteryLevel = freezed,
    Object? isEmergency = null,
    Object? emergencyAlertId = freezed,
    Object? checkInId = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
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
      speed: freezed == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double?,
      heading: freezed == heading
          ? _value.heading
          : heading // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      placeName: freezed == placeName
          ? _value.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String?,
      sharingStatus: null == sharingStatus
          ? _value.sharingStatus
          : sharingStatus // ignore: cast_nullable_to_non_nullable
              as LocationSharingStatus,
      sharedWithContactIds: null == sharedWithContactIds
          ? _value.sharedWithContactIds
          : sharedWithContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      batteryLevel: freezed == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      isEmergency: null == isEmergency
          ? _value.isEmergency
          : isEmergency // ignore: cast_nullable_to_non_nullable
              as bool,
      emergencyAlertId: freezed == emergencyAlertId
          ? _value.emergencyAlertId
          : emergencyAlertId // ignore: cast_nullable_to_non_nullable
              as String?,
      checkInId: freezed == checkInId
          ? _value.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationUpdateImplCopyWith<$Res>
    implements $LocationUpdateCopyWith<$Res> {
  factory _$$LocationUpdateImplCopyWith(_$LocationUpdateImpl value,
          $Res Function(_$LocationUpdateImpl) then) =
      __$$LocationUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      double latitude,
      double longitude,
      double? accuracy,
      double? altitude,
      double? speed,
      double? heading,
      String? address,
      String? placeName,
      LocationSharingStatus sharingStatus,
      List<String> sharedWithContactIds,
      int? batteryLevel,
      bool isEmergency,
      String? emergencyAlertId,
      String? checkInId,
      Map<String, dynamic>? metadata,
      DateTime createdAt});
}

/// @nodoc
class __$$LocationUpdateImplCopyWithImpl<$Res>
    extends _$LocationUpdateCopyWithImpl<$Res, _$LocationUpdateImpl>
    implements _$$LocationUpdateImplCopyWith<$Res> {
  __$$LocationUpdateImplCopyWithImpl(
      _$LocationUpdateImpl _value, $Res Function(_$LocationUpdateImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracy = freezed,
    Object? altitude = freezed,
    Object? speed = freezed,
    Object? heading = freezed,
    Object? address = freezed,
    Object? placeName = freezed,
    Object? sharingStatus = null,
    Object? sharedWithContactIds = null,
    Object? batteryLevel = freezed,
    Object? isEmergency = null,
    Object? emergencyAlertId = freezed,
    Object? checkInId = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$LocationUpdateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
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
      speed: freezed == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double?,
      heading: freezed == heading
          ? _value.heading
          : heading // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      placeName: freezed == placeName
          ? _value.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String?,
      sharingStatus: null == sharingStatus
          ? _value.sharingStatus
          : sharingStatus // ignore: cast_nullable_to_non_nullable
              as LocationSharingStatus,
      sharedWithContactIds: null == sharedWithContactIds
          ? _value._sharedWithContactIds
          : sharedWithContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      batteryLevel: freezed == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      isEmergency: null == isEmergency
          ? _value.isEmergency
          : isEmergency // ignore: cast_nullable_to_non_nullable
              as bool,
      emergencyAlertId: freezed == emergencyAlertId
          ? _value.emergencyAlertId
          : emergencyAlertId // ignore: cast_nullable_to_non_nullable
              as String?,
      checkInId: freezed == checkInId
          ? _value.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationUpdateImpl implements _LocationUpdate {
  const _$LocationUpdateImpl(
      {required this.id,
      required this.userId,
      required this.latitude,
      required this.longitude,
      this.accuracy,
      this.altitude,
      this.speed,
      this.heading,
      this.address,
      this.placeName,
      required this.sharingStatus,
      required final List<String> sharedWithContactIds,
      this.batteryLevel,
      this.isEmergency = false,
      this.emergencyAlertId,
      this.checkInId,
      final Map<String, dynamic>? metadata,
      required this.createdAt})
      : _sharedWithContactIds = sharedWithContactIds,
        _metadata = metadata;

  factory _$LocationUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationUpdateImplFromJson(json);

  /// Unique identifier for the location update
  @override
  final String id;

  /// User ID who is sharing their location
  @override
  final String userId;

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

  /// Speed in m/s
  @override
  final double? speed;

  /// Heading in degrees
  @override
  final double? heading;

  /// Human-readable address
  @override
  final String? address;

  /// Place name (if applicable)
  @override
  final String? placeName;

  /// Status of location sharing
  @override
  final LocationSharingStatus sharingStatus;

  /// IDs of trusted contacts receiving this update
  final List<String> _sharedWithContactIds;

  /// IDs of trusted contacts receiving this update
  @override
  List<String> get sharedWithContactIds {
    if (_sharedWithContactIds is EqualUnmodifiableListView)
      return _sharedWithContactIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sharedWithContactIds);
  }

  /// Battery level at time of update (0-100)
  @override
  final int? batteryLevel;

  /// Whether this is an emergency location update
  @override
  @JsonKey()
  final bool isEmergency;

  /// Associated emergency/SOS alert ID (if applicable)
  @override
  final String? emergencyAlertId;

  /// Associated check-in ID (if applicable)
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

  /// When this location update was created
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LocationUpdate(id: $id, userId: $userId, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, speed: $speed, heading: $heading, address: $address, placeName: $placeName, sharingStatus: $sharingStatus, sharedWithContactIds: $sharedWithContactIds, batteryLevel: $batteryLevel, isEmergency: $isEmergency, emergencyAlertId: $emergencyAlertId, checkInId: $checkInId, metadata: $metadata, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationUpdateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.altitude, altitude) ||
                other.altitude == altitude) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.heading, heading) || other.heading == heading) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            (identical(other.sharingStatus, sharingStatus) ||
                other.sharingStatus == sharingStatus) &&
            const DeepCollectionEquality()
                .equals(other._sharedWithContactIds, _sharedWithContactIds) &&
            (identical(other.batteryLevel, batteryLevel) ||
                other.batteryLevel == batteryLevel) &&
            (identical(other.isEmergency, isEmergency) ||
                other.isEmergency == isEmergency) &&
            (identical(other.emergencyAlertId, emergencyAlertId) ||
                other.emergencyAlertId == emergencyAlertId) &&
            (identical(other.checkInId, checkInId) ||
                other.checkInId == checkInId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      latitude,
      longitude,
      accuracy,
      altitude,
      speed,
      heading,
      address,
      placeName,
      sharingStatus,
      const DeepCollectionEquality().hash(_sharedWithContactIds),
      batteryLevel,
      isEmergency,
      emergencyAlertId,
      checkInId,
      const DeepCollectionEquality().hash(_metadata),
      createdAt);

  /// Create a copy of LocationUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationUpdateImplCopyWith<_$LocationUpdateImpl> get copyWith =>
      __$$LocationUpdateImplCopyWithImpl<_$LocationUpdateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationUpdateImplToJson(
      this,
    );
  }
}

abstract class _LocationUpdate implements LocationUpdate {
  const factory _LocationUpdate(
      {required final String id,
      required final String userId,
      required final double latitude,
      required final double longitude,
      final double? accuracy,
      final double? altitude,
      final double? speed,
      final double? heading,
      final String? address,
      final String? placeName,
      required final LocationSharingStatus sharingStatus,
      required final List<String> sharedWithContactIds,
      final int? batteryLevel,
      final bool isEmergency,
      final String? emergencyAlertId,
      final String? checkInId,
      final Map<String, dynamic>? metadata,
      required final DateTime createdAt}) = _$LocationUpdateImpl;

  factory _LocationUpdate.fromJson(Map<String, dynamic> json) =
      _$LocationUpdateImpl.fromJson;

  /// Unique identifier for the location update
  @override
  String get id;

  /// User ID who is sharing their location
  @override
  String get userId;

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

  /// Speed in m/s
  @override
  double? get speed;

  /// Heading in degrees
  @override
  double? get heading;

  /// Human-readable address
  @override
  String? get address;

  /// Place name (if applicable)
  @override
  String? get placeName;

  /// Status of location sharing
  @override
  LocationSharingStatus get sharingStatus;

  /// IDs of trusted contacts receiving this update
  @override
  List<String> get sharedWithContactIds;

  /// Battery level at time of update (0-100)
  @override
  int? get batteryLevel;

  /// Whether this is an emergency location update
  @override
  bool get isEmergency;

  /// Associated emergency/SOS alert ID (if applicable)
  @override
  String? get emergencyAlertId;

  /// Associated check-in ID (if applicable)
  @override
  String? get checkInId;

  /// Additional metadata
  @override
  Map<String, dynamic>? get metadata;

  /// When this location update was created
  @override
  DateTime get createdAt;

  /// Create a copy of LocationUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationUpdateImplCopyWith<_$LocationUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
