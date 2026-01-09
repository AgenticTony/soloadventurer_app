// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationUpdate {
  /// Unique identifier for the location update
  String get id;

  /// User ID who is sharing their location
  String get userId;

  /// Latitude
  double get latitude;

  /// Longitude
  double get longitude;

  /// Accuracy of the location in meters
  double? get accuracy;

  /// Altitude in meters
  double? get altitude;

  /// Speed in m/s
  double? get speed;

  /// Heading in degrees
  double? get heading;

  /// Human-readable address
  String? get address;

  /// Place name (if applicable)
  String? get placeName;

  /// Status of location sharing
  LocationSharingStatus get sharingStatus;

  /// IDs of trusted contacts receiving this update
  List<String> get sharedWithContactIds;

  /// Battery level at time of update (0-100)
  int? get batteryLevel;

  /// Whether this is an emergency location update
  bool get isEmergency;

  /// Associated emergency/SOS alert ID (if applicable)
  String? get emergencyAlertId;

  /// Associated check-in ID (if applicable)
  String? get checkInId;

  /// Additional metadata
  Map<String, dynamic>? get metadata;

  /// When this location update was created
  DateTime get createdAt;

  /// Create a copy of LocationUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LocationUpdateCopyWith<LocationUpdate> get copyWith =>
      _$LocationUpdateCopyWithImpl<LocationUpdate>(
          this as LocationUpdate, _$identity);

  /// Serializes this LocationUpdate to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LocationUpdate &&
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
                .equals(other.sharedWithContactIds, sharedWithContactIds) &&
            (identical(other.batteryLevel, batteryLevel) ||
                other.batteryLevel == batteryLevel) &&
            (identical(other.isEmergency, isEmergency) ||
                other.isEmergency == isEmergency) &&
            (identical(other.emergencyAlertId, emergencyAlertId) ||
                other.emergencyAlertId == emergencyAlertId) &&
            (identical(other.checkInId, checkInId) ||
                other.checkInId == checkInId) &&
            const DeepCollectionEquality().equals(other.metadata, metadata) &&
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
      const DeepCollectionEquality().hash(sharedWithContactIds),
      batteryLevel,
      isEmergency,
      emergencyAlertId,
      checkInId,
      const DeepCollectionEquality().hash(metadata),
      createdAt);

  @override
  String toString() {
    return 'LocationUpdate(id: $id, userId: $userId, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, speed: $speed, heading: $heading, address: $address, placeName: $placeName, sharingStatus: $sharingStatus, sharedWithContactIds: $sharedWithContactIds, batteryLevel: $batteryLevel, isEmergency: $isEmergency, emergencyAlertId: $emergencyAlertId, checkInId: $checkInId, metadata: $metadata, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $LocationUpdateCopyWith<$Res> {
  factory $LocationUpdateCopyWith(
          LocationUpdate value, $Res Function(LocationUpdate) _then) =
      _$LocationUpdateCopyWithImpl;
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
class _$LocationUpdateCopyWithImpl<$Res>
    implements $LocationUpdateCopyWith<$Res> {
  _$LocationUpdateCopyWithImpl(this._self, this._then);

  final LocationUpdate _self;
  final $Res Function(LocationUpdate) _then;

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
      speed: freezed == speed
          ? _self.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double?,
      heading: freezed == heading
          ? _self.heading
          : heading // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      placeName: freezed == placeName
          ? _self.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String?,
      sharingStatus: null == sharingStatus
          ? _self.sharingStatus
          : sharingStatus // ignore: cast_nullable_to_non_nullable
              as LocationSharingStatus,
      sharedWithContactIds: null == sharedWithContactIds
          ? _self.sharedWithContactIds
          : sharedWithContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      batteryLevel: freezed == batteryLevel
          ? _self.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      isEmergency: null == isEmergency
          ? _self.isEmergency
          : isEmergency // ignore: cast_nullable_to_non_nullable
              as bool,
      emergencyAlertId: freezed == emergencyAlertId
          ? _self.emergencyAlertId
          : emergencyAlertId // ignore: cast_nullable_to_non_nullable
              as String?,
      checkInId: freezed == checkInId
          ? _self.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [LocationUpdate].
extension LocationUpdatePatterns on LocationUpdate {
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
    TResult Function(_LocationUpdate value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationUpdate() when $default != null:
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
    TResult Function(_LocationUpdate value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationUpdate():
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
    TResult? Function(_LocationUpdate value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationUpdate() when $default != null:
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
            DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationUpdate() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.latitude,
            _that.longitude,
            _that.accuracy,
            _that.altitude,
            _that.speed,
            _that.heading,
            _that.address,
            _that.placeName,
            _that.sharingStatus,
            _that.sharedWithContactIds,
            _that.batteryLevel,
            _that.isEmergency,
            _that.emergencyAlertId,
            _that.checkInId,
            _that.metadata,
            _that.createdAt);
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
            DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationUpdate():
        return $default(
            _that.id,
            _that.userId,
            _that.latitude,
            _that.longitude,
            _that.accuracy,
            _that.altitude,
            _that.speed,
            _that.heading,
            _that.address,
            _that.placeName,
            _that.sharingStatus,
            _that.sharedWithContactIds,
            _that.batteryLevel,
            _that.isEmergency,
            _that.emergencyAlertId,
            _that.checkInId,
            _that.metadata,
            _that.createdAt);
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
            String id,
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
            DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationUpdate() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.latitude,
            _that.longitude,
            _that.accuracy,
            _that.altitude,
            _that.speed,
            _that.heading,
            _that.address,
            _that.placeName,
            _that.sharingStatus,
            _that.sharedWithContactIds,
            _that.batteryLevel,
            _that.isEmergency,
            _that.emergencyAlertId,
            _that.checkInId,
            _that.metadata,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _LocationUpdate extends LocationUpdate {
  const _LocationUpdate(
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
        _metadata = metadata,
        super._();
  factory _LocationUpdate.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateFromJson(json);

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

  /// Create a copy of LocationUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LocationUpdateCopyWith<_LocationUpdate> get copyWith =>
      __$LocationUpdateCopyWithImpl<_LocationUpdate>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LocationUpdateToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LocationUpdate &&
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

  @override
  String toString() {
    return 'LocationUpdate(id: $id, userId: $userId, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, speed: $speed, heading: $heading, address: $address, placeName: $placeName, sharingStatus: $sharingStatus, sharedWithContactIds: $sharedWithContactIds, batteryLevel: $batteryLevel, isEmergency: $isEmergency, emergencyAlertId: $emergencyAlertId, checkInId: $checkInId, metadata: $metadata, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$LocationUpdateCopyWith<$Res>
    implements $LocationUpdateCopyWith<$Res> {
  factory _$LocationUpdateCopyWith(
          _LocationUpdate value, $Res Function(_LocationUpdate) _then) =
      __$LocationUpdateCopyWithImpl;
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
class __$LocationUpdateCopyWithImpl<$Res>
    implements _$LocationUpdateCopyWith<$Res> {
  __$LocationUpdateCopyWithImpl(this._self, this._then);

  final _LocationUpdate _self;
  final $Res Function(_LocationUpdate) _then;

  /// Create a copy of LocationUpdate
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
    return _then(_LocationUpdate(
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
      speed: freezed == speed
          ? _self.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double?,
      heading: freezed == heading
          ? _self.heading
          : heading // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      placeName: freezed == placeName
          ? _self.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String?,
      sharingStatus: null == sharingStatus
          ? _self.sharingStatus
          : sharingStatus // ignore: cast_nullable_to_non_nullable
              as LocationSharingStatus,
      sharedWithContactIds: null == sharedWithContactIds
          ? _self._sharedWithContactIds
          : sharedWithContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      batteryLevel: freezed == batteryLevel
          ? _self.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      isEmergency: null == isEmergency
          ? _self.isEmergency
          : isEmergency // ignore: cast_nullable_to_non_nullable
              as bool,
      emergencyAlertId: freezed == emergencyAlertId
          ? _self.emergencyAlertId
          : emergencyAlertId // ignore: cast_nullable_to_non_nullable
              as String?,
      checkInId: freezed == checkInId
          ? _self.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
