// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_update_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocationUpdateModel _$LocationUpdateModelFromJson(Map<String, dynamic> json) {
  return _LocationUpdateModel.fromJson(json);
}

/// @nodoc
mixin _$LocationUpdateModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  double? get accuracy => throw _privateConstructorUsedError;
  double? get altitude => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get placeName => throw _privateConstructorUsedError;
  int? get batteryLevel => throw _privateConstructorUsedError;
  LocationSharingStatus get sharingStatus => throw _privateConstructorUsedError;
  List<String> get sharedWithContactIds => throw _privateConstructorUsedError;
  bool get emergency => throw _privateConstructorUsedError;
  String? get checkInId => throw _privateConstructorUsedError;
  String? get alertId => throw _privateConstructorUsedError;
  String? get tripId => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LocationUpdateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationUpdateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationUpdateModelCopyWith<LocationUpdateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationUpdateModelCopyWith<$Res> {
  factory $LocationUpdateModelCopyWith(
          LocationUpdateModel value, $Res Function(LocationUpdateModel) then) =
      _$LocationUpdateModelCopyWithImpl<$Res, LocationUpdateModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      double latitude,
      double longitude,
      double? accuracy,
      double? altitude,
      String? address,
      String? placeName,
      int? batteryLevel,
      LocationSharingStatus sharingStatus,
      List<String> sharedWithContactIds,
      bool emergency,
      String? checkInId,
      String? alertId,
      String? tripId,
      DateTime? expiresAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$LocationUpdateModelCopyWithImpl<$Res, $Val extends LocationUpdateModel>
    implements $LocationUpdateModelCopyWith<$Res> {
  _$LocationUpdateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationUpdateModel
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
    Object? address = freezed,
    Object? placeName = freezed,
    Object? batteryLevel = freezed,
    Object? sharingStatus = null,
    Object? sharedWithContactIds = null,
    Object? emergency = null,
    Object? checkInId = freezed,
    Object? alertId = freezed,
    Object? tripId = freezed,
    Object? expiresAt = freezed,
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
      batteryLevel: freezed == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      sharingStatus: null == sharingStatus
          ? _value.sharingStatus
          : sharingStatus // ignore: cast_nullable_to_non_nullable
              as LocationSharingStatus,
      sharedWithContactIds: null == sharedWithContactIds
          ? _value.sharedWithContactIds
          : sharedWithContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      emergency: null == emergency
          ? _value.emergency
          : emergency // ignore: cast_nullable_to_non_nullable
              as bool,
      checkInId: freezed == checkInId
          ? _value.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      alertId: freezed == alertId
          ? _value.alertId
          : alertId // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
}

/// @nodoc
abstract class _$$LocationUpdateModelImplCopyWith<$Res>
    implements $LocationUpdateModelCopyWith<$Res> {
  factory _$$LocationUpdateModelImplCopyWith(_$LocationUpdateModelImpl value,
          $Res Function(_$LocationUpdateModelImpl) then) =
      __$$LocationUpdateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      double latitude,
      double longitude,
      double? accuracy,
      double? altitude,
      String? address,
      String? placeName,
      int? batteryLevel,
      LocationSharingStatus sharingStatus,
      List<String> sharedWithContactIds,
      bool emergency,
      String? checkInId,
      String? alertId,
      String? tripId,
      DateTime? expiresAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$LocationUpdateModelImplCopyWithImpl<$Res>
    extends _$LocationUpdateModelCopyWithImpl<$Res, _$LocationUpdateModelImpl>
    implements _$$LocationUpdateModelImplCopyWith<$Res> {
  __$$LocationUpdateModelImplCopyWithImpl(_$LocationUpdateModelImpl _value,
      $Res Function(_$LocationUpdateModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationUpdateModel
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
    Object? address = freezed,
    Object? placeName = freezed,
    Object? batteryLevel = freezed,
    Object? sharingStatus = null,
    Object? sharedWithContactIds = null,
    Object? emergency = null,
    Object? checkInId = freezed,
    Object? alertId = freezed,
    Object? tripId = freezed,
    Object? expiresAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$LocationUpdateModelImpl(
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
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      placeName: freezed == placeName
          ? _value.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String?,
      batteryLevel: freezed == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      sharingStatus: null == sharingStatus
          ? _value.sharingStatus
          : sharingStatus // ignore: cast_nullable_to_non_nullable
              as LocationSharingStatus,
      sharedWithContactIds: null == sharedWithContactIds
          ? _value._sharedWithContactIds
          : sharedWithContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      emergency: null == emergency
          ? _value.emergency
          : emergency // ignore: cast_nullable_to_non_nullable
              as bool,
      checkInId: freezed == checkInId
          ? _value.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      alertId: freezed == alertId
          ? _value.alertId
          : alertId // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
class _$LocationUpdateModelImpl extends _LocationUpdateModel {
  const _$LocationUpdateModelImpl(
      {required this.id,
      required this.userId,
      required this.latitude,
      required this.longitude,
      this.accuracy,
      this.altitude,
      this.address,
      this.placeName,
      this.batteryLevel,
      required this.sharingStatus,
      required final List<String> sharedWithContactIds,
      this.emergency = false,
      this.checkInId,
      this.alertId,
      this.tripId,
      this.expiresAt,
      required this.createdAt,
      this.updatedAt})
      : _sharedWithContactIds = sharedWithContactIds,
        super._();

  factory _$LocationUpdateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationUpdateModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final double? accuracy;
  @override
  final double? altitude;
  @override
  final String? address;
  @override
  final String? placeName;
  @override
  final int? batteryLevel;
  @override
  final LocationSharingStatus sharingStatus;
  final List<String> _sharedWithContactIds;
  @override
  List<String> get sharedWithContactIds {
    if (_sharedWithContactIds is EqualUnmodifiableListView)
      return _sharedWithContactIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sharedWithContactIds);
  }

  @override
  @JsonKey()
  final bool emergency;
  @override
  final String? checkInId;
  @override
  final String? alertId;
  @override
  final String? tripId;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'LocationUpdateModel(id: $id, userId: $userId, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, address: $address, placeName: $placeName, batteryLevel: $batteryLevel, sharingStatus: $sharingStatus, sharedWithContactIds: $sharedWithContactIds, emergency: $emergency, checkInId: $checkInId, alertId: $alertId, tripId: $tripId, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationUpdateModelImpl &&
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
            (identical(other.address, address) || other.address == address) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            (identical(other.batteryLevel, batteryLevel) ||
                other.batteryLevel == batteryLevel) &&
            (identical(other.sharingStatus, sharingStatus) ||
                other.sharingStatus == sharingStatus) &&
            const DeepCollectionEquality()
                .equals(other._sharedWithContactIds, _sharedWithContactIds) &&
            (identical(other.emergency, emergency) ||
                other.emergency == emergency) &&
            (identical(other.checkInId, checkInId) ||
                other.checkInId == checkInId) &&
            (identical(other.alertId, alertId) || other.alertId == alertId) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
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
      latitude,
      longitude,
      accuracy,
      altitude,
      address,
      placeName,
      batteryLevel,
      sharingStatus,
      const DeepCollectionEquality().hash(_sharedWithContactIds),
      emergency,
      checkInId,
      alertId,
      tripId,
      expiresAt,
      createdAt,
      updatedAt);

  /// Create a copy of LocationUpdateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationUpdateModelImplCopyWith<_$LocationUpdateModelImpl> get copyWith =>
      __$$LocationUpdateModelImplCopyWithImpl<_$LocationUpdateModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationUpdateModelImplToJson(
      this,
    );
  }
}

abstract class _LocationUpdateModel extends LocationUpdateModel {
  const factory _LocationUpdateModel(
      {required final String id,
      required final String userId,
      required final double latitude,
      required final double longitude,
      final double? accuracy,
      final double? altitude,
      final String? address,
      final String? placeName,
      final int? batteryLevel,
      required final LocationSharingStatus sharingStatus,
      required final List<String> sharedWithContactIds,
      final bool emergency,
      final String? checkInId,
      final String? alertId,
      final String? tripId,
      final DateTime? expiresAt,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$LocationUpdateModelImpl;
  const _LocationUpdateModel._() : super._();

  factory _LocationUpdateModel.fromJson(Map<String, dynamic> json) =
      _$LocationUpdateModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  double? get accuracy;
  @override
  double? get altitude;
  @override
  String? get address;
  @override
  String? get placeName;
  @override
  int? get batteryLevel;
  @override
  LocationSharingStatus get sharingStatus;
  @override
  List<String> get sharedWithContactIds;
  @override
  bool get emergency;
  @override
  String? get checkInId;
  @override
  String? get alertId;
  @override
  String? get tripId;
  @override
  DateTime? get expiresAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of LocationUpdateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationUpdateModelImplCopyWith<_$LocationUpdateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
