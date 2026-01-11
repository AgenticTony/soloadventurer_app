// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_update_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationUpdateModel {
  String get id;
  String get userId;
  double get latitude;
  double get longitude;
  double? get accuracy;
  double? get altitude;
  String? get address;
  String? get placeName;
  int? get batteryLevel;
  LocationSharingStatus get sharingStatus;
  List<String> get sharedWithContactIds;
  bool get emergency;
  String? get checkInId;
  String? get alertId;
  String? get tripId;
  DateTime? get expiresAt;
  DateTime get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of LocationUpdateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LocationUpdateModelCopyWith<LocationUpdateModel> get copyWith =>
      _$LocationUpdateModelCopyWithImpl<LocationUpdateModel>(
          this as LocationUpdateModel, _$identity);

  /// Serializes this LocationUpdateModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LocationUpdateModel &&
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
                .equals(other.sharedWithContactIds, sharedWithContactIds) &&
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
      const DeepCollectionEquality().hash(sharedWithContactIds),
      emergency,
      checkInId,
      alertId,
      tripId,
      expiresAt,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'LocationUpdateModel(id: $id, userId: $userId, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, address: $address, placeName: $placeName, batteryLevel: $batteryLevel, sharingStatus: $sharingStatus, sharedWithContactIds: $sharedWithContactIds, emergency: $emergency, checkInId: $checkInId, alertId: $alertId, tripId: $tripId, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $LocationUpdateModelCopyWith<$Res> {
  factory $LocationUpdateModelCopyWith(
          LocationUpdateModel value, $Res Function(LocationUpdateModel) _then) =
      _$LocationUpdateModelCopyWithImpl;
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
class _$LocationUpdateModelCopyWithImpl<$Res>
    implements $LocationUpdateModelCopyWith<$Res> {
  _$LocationUpdateModelCopyWithImpl(this._self, this._then);

  final LocationUpdateModel _self;
  final $Res Function(LocationUpdateModel) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
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
      batteryLevel: freezed == batteryLevel
          ? _self.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      sharingStatus: null == sharingStatus
          ? _self.sharingStatus
          : sharingStatus // ignore: cast_nullable_to_non_nullable
              as LocationSharingStatus,
      sharedWithContactIds: null == sharedWithContactIds
          ? _self.sharedWithContactIds
          : sharedWithContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      emergency: null == emergency
          ? _self.emergency
          : emergency // ignore: cast_nullable_to_non_nullable
              as bool,
      checkInId: freezed == checkInId
          ? _self.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      alertId: freezed == alertId
          ? _self.alertId
          : alertId // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
}

/// Adds pattern-matching-related methods to [LocationUpdateModel].
extension LocationUpdateModelPatterns on LocationUpdateModel {
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
    TResult Function(_LocationUpdateModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationUpdateModel() when $default != null:
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
    TResult Function(_LocationUpdateModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationUpdateModel():
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
    TResult? Function(_LocationUpdateModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationUpdateModel() when $default != null:
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
            DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationUpdateModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.latitude,
            _that.longitude,
            _that.accuracy,
            _that.altitude,
            _that.address,
            _that.placeName,
            _that.batteryLevel,
            _that.sharingStatus,
            _that.sharedWithContactIds,
            _that.emergency,
            _that.checkInId,
            _that.alertId,
            _that.tripId,
            _that.expiresAt,
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
            DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationUpdateModel():
        return $default(
            _that.id,
            _that.userId,
            _that.latitude,
            _that.longitude,
            _that.accuracy,
            _that.altitude,
            _that.address,
            _that.placeName,
            _that.batteryLevel,
            _that.sharingStatus,
            _that.sharedWithContactIds,
            _that.emergency,
            _that.checkInId,
            _that.alertId,
            _that.tripId,
            _that.expiresAt,
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
            DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationUpdateModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.latitude,
            _that.longitude,
            _that.accuracy,
            _that.altitude,
            _that.address,
            _that.placeName,
            _that.batteryLevel,
            _that.sharingStatus,
            _that.sharedWithContactIds,
            _that.emergency,
            _that.checkInId,
            _that.alertId,
            _that.tripId,
            _that.expiresAt,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _LocationUpdateModel implements LocationUpdateModel {
  const _LocationUpdateModel(
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
      : _sharedWithContactIds = sharedWithContactIds;
  factory _LocationUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateModelFromJson(json);

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

  /// Create a copy of LocationUpdateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LocationUpdateModelCopyWith<_LocationUpdateModel> get copyWith =>
      __$LocationUpdateModelCopyWithImpl<_LocationUpdateModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LocationUpdateModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LocationUpdateModel &&
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

  @override
  String toString() {
    return 'LocationUpdateModel(id: $id, userId: $userId, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, address: $address, placeName: $placeName, batteryLevel: $batteryLevel, sharingStatus: $sharingStatus, sharedWithContactIds: $sharedWithContactIds, emergency: $emergency, checkInId: $checkInId, alertId: $alertId, tripId: $tripId, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$LocationUpdateModelCopyWith<$Res>
    implements $LocationUpdateModelCopyWith<$Res> {
  factory _$LocationUpdateModelCopyWith(_LocationUpdateModel value,
          $Res Function(_LocationUpdateModel) _then) =
      __$LocationUpdateModelCopyWithImpl;
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
class __$LocationUpdateModelCopyWithImpl<$Res>
    implements _$LocationUpdateModelCopyWith<$Res> {
  __$LocationUpdateModelCopyWithImpl(this._self, this._then);

  final _LocationUpdateModel _self;
  final $Res Function(_LocationUpdateModel) _then;

  /// Create a copy of LocationUpdateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_LocationUpdateModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
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
      batteryLevel: freezed == batteryLevel
          ? _self.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      sharingStatus: null == sharingStatus
          ? _self.sharingStatus
          : sharingStatus // ignore: cast_nullable_to_non_nullable
              as LocationSharingStatus,
      sharedWithContactIds: null == sharedWithContactIds
          ? _self._sharedWithContactIds
          : sharedWithContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      emergency: null == emergency
          ? _self.emergency
          : emergency // ignore: cast_nullable_to_non_nullable
              as bool,
      checkInId: freezed == checkInId
          ? _self.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      alertId: freezed == alertId
          ? _self.alertId
          : alertId // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
}

// dart format on
