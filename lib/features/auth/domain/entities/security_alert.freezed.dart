// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'security_alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SecurityAlert _$SecurityAlertFromJson(Map<String, dynamic> json) {
  return _SecurityAlert.fromJson(json);
}

/// @nodoc
mixin _$SecurityAlert {
  AlertType get type => throw _privateConstructorUsedError;
  AlertSeverity get severity => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this SecurityAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecurityAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecurityAlertCopyWith<SecurityAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityAlertCopyWith<$Res> {
  factory $SecurityAlertCopyWith(
          SecurityAlert value, $Res Function(SecurityAlert) then) =
      _$SecurityAlertCopyWithImpl<$Res, SecurityAlert>;
  @useResult
  $Res call(
      {AlertType type,
      AlertSeverity severity,
      String message,
      DateTime timestamp,
      String userId,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$SecurityAlertCopyWithImpl<$Res, $Val extends SecurityAlert>
    implements $SecurityAlertCopyWith<$Res> {
  _$SecurityAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecurityAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? severity = null,
    Object? message = null,
    Object? timestamp = null,
    Object? userId = null,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AlertType,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AlertSeverity,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SecurityAlertImplCopyWith<$Res>
    implements $SecurityAlertCopyWith<$Res> {
  factory _$$SecurityAlertImplCopyWith(
          _$SecurityAlertImpl value, $Res Function(_$SecurityAlertImpl) then) =
      __$$SecurityAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AlertType type,
      AlertSeverity severity,
      String message,
      DateTime timestamp,
      String userId,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$SecurityAlertImplCopyWithImpl<$Res>
    extends _$SecurityAlertCopyWithImpl<$Res, _$SecurityAlertImpl>
    implements _$$SecurityAlertImplCopyWith<$Res> {
  __$$SecurityAlertImplCopyWithImpl(
      _$SecurityAlertImpl _value, $Res Function(_$SecurityAlertImpl) _then)
      : super(_value, _then);

  /// Create a copy of SecurityAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? severity = null,
    Object? message = null,
    Object? timestamp = null,
    Object? userId = null,
    Object? metadata = freezed,
  }) {
    return _then(_$SecurityAlertImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AlertType,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AlertSeverity,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SecurityAlertImpl implements _SecurityAlert {
  const _$SecurityAlertImpl(
      {required this.type,
      required this.severity,
      required this.message,
      required this.timestamp,
      required this.userId,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$SecurityAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityAlertImplFromJson(json);

  @override
  final AlertType type;
  @override
  final AlertSeverity severity;
  @override
  final String message;
  @override
  final DateTime timestamp;
  @override
  final String userId;
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
    return 'SecurityAlert(type: $type, severity: $severity, message: $message, timestamp: $timestamp, userId: $userId, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityAlertImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, severity, message,
      timestamp, userId, const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of SecurityAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityAlertImplCopyWith<_$SecurityAlertImpl> get copyWith =>
      __$$SecurityAlertImplCopyWithImpl<_$SecurityAlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityAlertImplToJson(
      this,
    );
  }
}

abstract class _SecurityAlert implements SecurityAlert {
  const factory _SecurityAlert(
      {required final AlertType type,
      required final AlertSeverity severity,
      required final String message,
      required final DateTime timestamp,
      required final String userId,
      final Map<String, dynamic>? metadata}) = _$SecurityAlertImpl;

  factory _SecurityAlert.fromJson(Map<String, dynamic> json) =
      _$SecurityAlertImpl.fromJson;

  @override
  AlertType get type;
  @override
  AlertSeverity get severity;
  @override
  String get message;
  @override
  DateTime get timestamp;
  @override
  String get userId;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of SecurityAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityAlertImplCopyWith<_$SecurityAlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
