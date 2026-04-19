// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_status_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SafetyStatusModel {
  String get id;
  String get userId;
  SafetyStatusType get statusType;
  String? get message;
  SafetyStatusLocation? get location;
  int? get batteryLevel;
  DateTime get timestamp;
  DateTime? get updatedAt;
  String? get safetyAlertId;
  String? get checkInId;
  Map<String, dynamic>? get metadata;

  /// Create a copy of SafetyStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SafetyStatusModelCopyWith<SafetyStatusModel> get copyWith =>
      _$SafetyStatusModelCopyWithImpl<SafetyStatusModel>(
          this as SafetyStatusModel, _$identity);

  /// Serializes this SafetyStatusModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SafetyStatusModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.statusType, statusType) ||
                other.statusType == statusType) &&
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
      statusType,
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
    return 'SafetyStatusModel(id: $id, userId: $userId, statusType: $statusType, message: $message, location: $location, batteryLevel: $batteryLevel, timestamp: $timestamp, updatedAt: $updatedAt, safetyAlertId: $safetyAlertId, checkInId: $checkInId, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $SafetyStatusModelCopyWith<$Res> {
  factory $SafetyStatusModelCopyWith(
          SafetyStatusModel value, $Res Function(SafetyStatusModel) _then) =
      _$SafetyStatusModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      SafetyStatusType statusType,
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
class _$SafetyStatusModelCopyWithImpl<$Res>
    implements $SafetyStatusModelCopyWith<$Res> {
  _$SafetyStatusModelCopyWithImpl(this._self, this._then);

  final SafetyStatusModel _self;
  final $Res Function(SafetyStatusModel) _then;

  /// Create a copy of SafetyStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? statusType = null,
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
      statusType: null == statusType
          ? _self.statusType
          : statusType // ignore: cast_nullable_to_non_nullable
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

  /// Create a copy of SafetyStatusModel
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

/// Adds pattern-matching-related methods to [SafetyStatusModel].
extension SafetyStatusModelPatterns on SafetyStatusModel {
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
    TResult Function(_SafetyStatusModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyStatusModel() when $default != null:
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
    TResult Function(_SafetyStatusModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyStatusModel():
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
    TResult? Function(_SafetyStatusModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyStatusModel() when $default != null:
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
            SafetyStatusType statusType,
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
      case _SafetyStatusModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.statusType,
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
            SafetyStatusType statusType,
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
      case _SafetyStatusModel():
        return $default(
            _that.id,
            _that.userId,
            _that.statusType,
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
            SafetyStatusType statusType,
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
      case _SafetyStatusModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.statusType,
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
class _SafetyStatusModel extends SafetyStatusModel {
  const _SafetyStatusModel(
      {required this.id,
      required this.userId,
      required this.statusType,
      this.message,
      this.location,
      this.batteryLevel,
      required this.timestamp,
      this.updatedAt,
      this.safetyAlertId,
      this.checkInId,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata,
        super._();
  factory _SafetyStatusModel.fromJson(Map<String, dynamic> json) =>
      _$SafetyStatusModelFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final SafetyStatusType statusType;
  @override
  final String? message;
  @override
  final SafetyStatusLocation? location;
  @override
  final int? batteryLevel;
  @override
  final DateTime timestamp;
  @override
  final DateTime? updatedAt;
  @override
  final String? safetyAlertId;
  @override
  final String? checkInId;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of SafetyStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SafetyStatusModelCopyWith<_SafetyStatusModel> get copyWith =>
      __$SafetyStatusModelCopyWithImpl<_SafetyStatusModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SafetyStatusModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SafetyStatusModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.statusType, statusType) ||
                other.statusType == statusType) &&
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
      statusType,
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
    return 'SafetyStatusModel(id: $id, userId: $userId, statusType: $statusType, message: $message, location: $location, batteryLevel: $batteryLevel, timestamp: $timestamp, updatedAt: $updatedAt, safetyAlertId: $safetyAlertId, checkInId: $checkInId, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$SafetyStatusModelCopyWith<$Res>
    implements $SafetyStatusModelCopyWith<$Res> {
  factory _$SafetyStatusModelCopyWith(
          _SafetyStatusModel value, $Res Function(_SafetyStatusModel) _then) =
      __$SafetyStatusModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      SafetyStatusType statusType,
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
class __$SafetyStatusModelCopyWithImpl<$Res>
    implements _$SafetyStatusModelCopyWith<$Res> {
  __$SafetyStatusModelCopyWithImpl(this._self, this._then);

  final _SafetyStatusModel _self;
  final $Res Function(_SafetyStatusModel) _then;

  /// Create a copy of SafetyStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? statusType = null,
    Object? message = freezed,
    Object? location = freezed,
    Object? batteryLevel = freezed,
    Object? timestamp = null,
    Object? updatedAt = freezed,
    Object? safetyAlertId = freezed,
    Object? checkInId = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_SafetyStatusModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      statusType: null == statusType
          ? _self.statusType
          : statusType // ignore: cast_nullable_to_non_nullable
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

  /// Create a copy of SafetyStatusModel
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

// dart format on
