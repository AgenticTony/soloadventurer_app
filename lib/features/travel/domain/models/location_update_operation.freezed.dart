// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_update_operation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocationUpdateOperation _$LocationUpdateOperationFromJson(
    Map<String, dynamic> json) {
  return _LocationUpdateOperation.fromJson(json);
}

/// @nodoc
mixin _$LocationUpdateOperation {
  String get id => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;

  /// Serializes this LocationUpdateOperation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationUpdateOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationUpdateOperationCopyWith<LocationUpdateOperation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationUpdateOperationCopyWith<$Res> {
  factory $LocationUpdateOperationCopyWith(LocationUpdateOperation value,
          $Res Function(LocationUpdateOperation) then) =
      _$LocationUpdateOperationCopyWithImpl<$Res, LocationUpdateOperation>;
  @useResult
  $Res call(
      {String id,
      double latitude,
      double longitude,
      DateTime timestamp,
      int priority});
}

/// @nodoc
class _$LocationUpdateOperationCopyWithImpl<$Res,
        $Val extends LocationUpdateOperation>
    implements $LocationUpdateOperationCopyWith<$Res> {
  _$LocationUpdateOperationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationUpdateOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = null,
    Object? priority = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationUpdateOperationImplCopyWith<$Res>
    implements $LocationUpdateOperationCopyWith<$Res> {
  factory _$$LocationUpdateOperationImplCopyWith(
          _$LocationUpdateOperationImpl value,
          $Res Function(_$LocationUpdateOperationImpl) then) =
      __$$LocationUpdateOperationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      double latitude,
      double longitude,
      DateTime timestamp,
      int priority});
}

/// @nodoc
class __$$LocationUpdateOperationImplCopyWithImpl<$Res>
    extends _$LocationUpdateOperationCopyWithImpl<$Res,
        _$LocationUpdateOperationImpl>
    implements _$$LocationUpdateOperationImplCopyWith<$Res> {
  __$$LocationUpdateOperationImplCopyWithImpl(
      _$LocationUpdateOperationImpl _value,
      $Res Function(_$LocationUpdateOperationImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationUpdateOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = null,
    Object? priority = null,
  }) {
    return _then(_$LocationUpdateOperationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationUpdateOperationImpl extends _LocationUpdateOperation {
  const _$LocationUpdateOperationImpl(
      {required this.id,
      required this.latitude,
      required this.longitude,
      required this.timestamp,
      this.priority = 1})
      : super._();

  factory _$LocationUpdateOperationImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationUpdateOperationImplFromJson(json);

  @override
  final String id;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final int priority;

  @override
  String toString() {
    return 'LocationUpdateOperation(id: $id, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationUpdateOperationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.priority, priority) ||
                other.priority == priority));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, latitude, longitude, timestamp, priority);

  /// Create a copy of LocationUpdateOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationUpdateOperationImplCopyWith<_$LocationUpdateOperationImpl>
      get copyWith => __$$LocationUpdateOperationImplCopyWithImpl<
          _$LocationUpdateOperationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationUpdateOperationImplToJson(
      this,
    );
  }
}

abstract class _LocationUpdateOperation extends LocationUpdateOperation {
  const factory _LocationUpdateOperation(
      {required final String id,
      required final double latitude,
      required final double longitude,
      required final DateTime timestamp,
      final int priority}) = _$LocationUpdateOperationImpl;
  const _LocationUpdateOperation._() : super._();

  factory _LocationUpdateOperation.fromJson(Map<String, dynamic> json) =
      _$LocationUpdateOperationImpl.fromJson;

  @override
  String get id;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  DateTime get timestamp;
  @override
  int get priority;

  /// Create a copy of LocationUpdateOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationUpdateOperationImplCopyWith<_$LocationUpdateOperationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
