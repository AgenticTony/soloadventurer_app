// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'security_alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SecurityAlert {
  AlertType get type;
  AlertSeverity get severity;
  String get message;
  DateTime get timestamp;
  String get userId;
  Map<String, dynamic>? get metadata;

  /// Create a copy of SecurityAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SecurityAlertCopyWith<SecurityAlert> get copyWith =>
      _$SecurityAlertCopyWithImpl<SecurityAlert>(
          this as SecurityAlert, _$identity);

  /// Serializes this SecurityAlert to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SecurityAlert &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other.metadata, metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, severity, message,
      timestamp, userId, const DeepCollectionEquality().hash(metadata));

  @override
  String toString() {
    return 'SecurityAlert(type: $type, severity: $severity, message: $message, timestamp: $timestamp, userId: $userId, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $SecurityAlertCopyWith<$Res> {
  factory $SecurityAlertCopyWith(
          SecurityAlert value, $Res Function(SecurityAlert) _then) =
      _$SecurityAlertCopyWithImpl;
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
class _$SecurityAlertCopyWithImpl<$Res>
    implements $SecurityAlertCopyWith<$Res> {
  _$SecurityAlertCopyWithImpl(this._self, this._then);

  final SecurityAlert _self;
  final $Res Function(SecurityAlert) _then;

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
    return _then(_self.copyWith(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as AlertType,
      severity: null == severity
          ? _self.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AlertSeverity,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// Adds pattern-matching-related methods to [SecurityAlert].
extension SecurityAlertPatterns on SecurityAlert {
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
    TResult Function(_SecurityAlert value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SecurityAlert() when $default != null:
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
    TResult Function(_SecurityAlert value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SecurityAlert():
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
    TResult? Function(_SecurityAlert value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SecurityAlert() when $default != null:
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
    TResult Function(AlertType type, AlertSeverity severity, String message,
            DateTime timestamp, String userId, Map<String, dynamic>? metadata)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SecurityAlert() when $default != null:
        return $default(_that.type, _that.severity, _that.message,
            _that.timestamp, _that.userId, _that.metadata);
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
    TResult Function(AlertType type, AlertSeverity severity, String message,
            DateTime timestamp, String userId, Map<String, dynamic>? metadata)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SecurityAlert():
        return $default(_that.type, _that.severity, _that.message,
            _that.timestamp, _that.userId, _that.metadata);
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
    TResult? Function(AlertType type, AlertSeverity severity, String message,
            DateTime timestamp, String userId, Map<String, dynamic>? metadata)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SecurityAlert() when $default != null:
        return $default(_that.type, _that.severity, _that.message,
            _that.timestamp, _that.userId, _that.metadata);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SecurityAlert implements SecurityAlert {
  const _SecurityAlert(
      {required this.type,
      required this.severity,
      required this.message,
      required this.timestamp,
      required this.userId,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;
  factory _SecurityAlert.fromJson(Map<String, dynamic> json) =>
      _$SecurityAlertFromJson(json);

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

  /// Create a copy of SecurityAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SecurityAlertCopyWith<_SecurityAlert> get copyWith =>
      __$SecurityAlertCopyWithImpl<_SecurityAlert>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SecurityAlertToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SecurityAlert &&
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

  @override
  String toString() {
    return 'SecurityAlert(type: $type, severity: $severity, message: $message, timestamp: $timestamp, userId: $userId, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$SecurityAlertCopyWith<$Res>
    implements $SecurityAlertCopyWith<$Res> {
  factory _$SecurityAlertCopyWith(
          _SecurityAlert value, $Res Function(_SecurityAlert) _then) =
      __$SecurityAlertCopyWithImpl;
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
class __$SecurityAlertCopyWithImpl<$Res>
    implements _$SecurityAlertCopyWith<$Res> {
  __$SecurityAlertCopyWithImpl(this._self, this._then);

  final _SecurityAlert _self;
  final $Res Function(_SecurityAlert) _then;

  /// Create a copy of SecurityAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? type = null,
    Object? severity = null,
    Object? message = null,
    Object? timestamp = null,
    Object? userId = null,
    Object? metadata = freezed,
  }) {
    return _then(_SecurityAlert(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as AlertType,
      severity: null == severity
          ? _self.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AlertSeverity,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: freezed == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

// dart format on
