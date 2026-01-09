// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_status_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SafetyStatusModel _$SafetyStatusModelFromJson(Map<String, dynamic> json) {
  return _SafetyStatusModel.fromJson(json);
}

/// @nodoc
mixin _$SafetyStatusModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  SafetyStatusType get statusType => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  SafetyStatusLocation? get location => throw _privateConstructorUsedError;
  int? get batteryLevel => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get safetyAlertId => throw _privateConstructorUsedError;
  String? get checkInId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this SafetyStatusModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SafetyStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SafetyStatusModelCopyWith<SafetyStatusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SafetyStatusModelCopyWith<$Res> {
  factory $SafetyStatusModelCopyWith(
          SafetyStatusModel value, $Res Function(SafetyStatusModel) then) =
      _$SafetyStatusModelCopyWithImpl<$Res, SafetyStatusModel>;
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
class _$SafetyStatusModelCopyWithImpl<$Res, $Val extends SafetyStatusModel>
    implements $SafetyStatusModelCopyWith<$Res> {
  _$SafetyStatusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      statusType: null == statusType
          ? _value.statusType
          : statusType // ignore: cast_nullable_to_non_nullable
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

  /// Create a copy of SafetyStatusModel
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
abstract class _$$SafetyStatusModelImplCopyWith<$Res>
    implements $SafetyStatusModelCopyWith<$Res> {
  factory _$$SafetyStatusModelImplCopyWith(_$SafetyStatusModelImpl value,
          $Res Function(_$SafetyStatusModelImpl) then) =
      __$$SafetyStatusModelImplCopyWithImpl<$Res>;
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
class __$$SafetyStatusModelImplCopyWithImpl<$Res>
    extends _$SafetyStatusModelCopyWithImpl<$Res, _$SafetyStatusModelImpl>
    implements _$$SafetyStatusModelImplCopyWith<$Res> {
  __$$SafetyStatusModelImplCopyWithImpl(_$SafetyStatusModelImpl _value,
      $Res Function(_$SafetyStatusModelImpl) _then)
      : super(_value, _then);

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
    return _then(_$SafetyStatusModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      statusType: null == statusType
          ? _value.statusType
          : statusType // ignore: cast_nullable_to_non_nullable
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
class _$SafetyStatusModelImpl extends _SafetyStatusModel {
  const _$SafetyStatusModelImpl(
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

  factory _$SafetyStatusModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SafetyStatusModelImplFromJson(json);

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

  @override
  String toString() {
    return 'SafetyStatusModel(id: $id, userId: $userId, statusType: $statusType, message: $message, location: $location, batteryLevel: $batteryLevel, timestamp: $timestamp, updatedAt: $updatedAt, safetyAlertId: $safetyAlertId, checkInId: $checkInId, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SafetyStatusModelImpl &&
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

  /// Create a copy of SafetyStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SafetyStatusModelImplCopyWith<_$SafetyStatusModelImpl> get copyWith =>
      __$$SafetyStatusModelImplCopyWithImpl<_$SafetyStatusModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SafetyStatusModelImplToJson(
      this,
    );
  }
}

abstract class _SafetyStatusModel extends SafetyStatusModel {
  const factory _SafetyStatusModel(
      {required final String id,
      required final String userId,
      required final SafetyStatusType statusType,
      final String? message,
      final SafetyStatusLocation? location,
      final int? batteryLevel,
      required final DateTime timestamp,
      final DateTime? updatedAt,
      final String? safetyAlertId,
      final String? checkInId,
      final Map<String, dynamic>? metadata}) = _$SafetyStatusModelImpl;
  const _SafetyStatusModel._() : super._();

  factory _SafetyStatusModel.fromJson(Map<String, dynamic> json) =
      _$SafetyStatusModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  SafetyStatusType get statusType;
  @override
  String? get message;
  @override
  SafetyStatusLocation? get location;
  @override
  int? get batteryLevel;
  @override
  DateTime get timestamp;
  @override
  DateTime? get updatedAt;
  @override
  String? get safetyAlertId;
  @override
  String? get checkInId;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of SafetyStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SafetyStatusModelImplCopyWith<_$SafetyStatusModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
