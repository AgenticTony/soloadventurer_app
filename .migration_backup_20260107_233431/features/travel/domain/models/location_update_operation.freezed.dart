// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_update_operation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationUpdateOperation {
  String get id;
  double get latitude;
  double get longitude;
  DateTime get timestamp;
  @OperationPriorityConverter()
  OperationPriority get priority; // Retry metadata
  DateTime? get createdAt;
  DateTime? get lastAttempt;
  int get attemptCount;
  String? get lastError;
  int get maxRetries;

  /// Create a copy of LocationUpdateOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LocationUpdateOperationCopyWith<LocationUpdateOperation> get copyWith =>
      _$LocationUpdateOperationCopyWithImpl<LocationUpdateOperation>(
          this as LocationUpdateOperation, _$identity);

  /// Serializes this LocationUpdateOperation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LocationUpdateOperation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastAttempt, lastAttempt) ||
                other.lastAttempt == lastAttempt) &&
            (identical(other.attemptCount, attemptCount) ||
                other.attemptCount == attemptCount) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      latitude,
      longitude,
      timestamp,
      priority,
      createdAt,
      lastAttempt,
      attemptCount,
      lastError,
      maxRetries);

  @override
  String toString() {
    return 'LocationUpdateOperation(id: $id, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, priority: $priority, createdAt: $createdAt, lastAttempt: $lastAttempt, attemptCount: $attemptCount, lastError: $lastError, maxRetries: $maxRetries)';
  }
}

/// @nodoc
abstract mixin class $LocationUpdateOperationCopyWith<$Res> {
  factory $LocationUpdateOperationCopyWith(LocationUpdateOperation value,
          $Res Function(LocationUpdateOperation) _then) =
      _$LocationUpdateOperationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      double latitude,
      double longitude,
      DateTime timestamp,
      @OperationPriorityConverter() OperationPriority priority,
      DateTime? createdAt,
      DateTime? lastAttempt,
      int attemptCount,
      String? lastError,
      int maxRetries});
}

/// @nodoc
class _$LocationUpdateOperationCopyWithImpl<$Res>
    implements $LocationUpdateOperationCopyWith<$Res> {
  _$LocationUpdateOperationCopyWithImpl(this._self, this._then);

  final LocationUpdateOperation _self;
  final $Res Function(LocationUpdateOperation) _then;

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
    Object? createdAt = freezed,
    Object? lastAttempt = freezed,
    Object? attemptCount = null,
    Object? lastError = freezed,
    Object? maxRetries = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as OperationPriority,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAttempt: freezed == lastAttempt
          ? _self.lastAttempt
          : lastAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      attemptCount: null == attemptCount
          ? _self.attemptCount
          : attemptCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _self.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      maxRetries: null == maxRetries
          ? _self.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [LocationUpdateOperation].
extension LocationUpdateOperationPatterns on LocationUpdateOperation {
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
    TResult Function(_LocationUpdateOperation value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationUpdateOperation() when $default != null:
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
    TResult Function(_LocationUpdateOperation value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationUpdateOperation():
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
    TResult? Function(_LocationUpdateOperation value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationUpdateOperation() when $default != null:
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
            double latitude,
            double longitude,
            DateTime timestamp,
            @OperationPriorityConverter() OperationPriority priority,
            DateTime? createdAt,
            DateTime? lastAttempt,
            int attemptCount,
            String? lastError,
            int maxRetries)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationUpdateOperation() when $default != null:
        return $default(
            _that.id,
            _that.latitude,
            _that.longitude,
            _that.timestamp,
            _that.priority,
            _that.createdAt,
            _that.lastAttempt,
            _that.attemptCount,
            _that.lastError,
            _that.maxRetries);
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
            double latitude,
            double longitude,
            DateTime timestamp,
            @OperationPriorityConverter() OperationPriority priority,
            DateTime? createdAt,
            DateTime? lastAttempt,
            int attemptCount,
            String? lastError,
            int maxRetries)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationUpdateOperation():
        return $default(
            _that.id,
            _that.latitude,
            _that.longitude,
            _that.timestamp,
            _that.priority,
            _that.createdAt,
            _that.lastAttempt,
            _that.attemptCount,
            _that.lastError,
            _that.maxRetries);
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
            double latitude,
            double longitude,
            DateTime timestamp,
            @OperationPriorityConverter() OperationPriority priority,
            DateTime? createdAt,
            DateTime? lastAttempt,
            int attemptCount,
            String? lastError,
            int maxRetries)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationUpdateOperation() when $default != null:
        return $default(
            _that.id,
            _that.latitude,
            _that.longitude,
            _that.timestamp,
            _that.priority,
            _that.createdAt,
            _that.lastAttempt,
            _that.attemptCount,
            _that.lastError,
            _that.maxRetries);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _LocationUpdateOperation extends LocationUpdateOperation {
  const _LocationUpdateOperation(
      {required this.id,
      required this.latitude,
      required this.longitude,
      required this.timestamp,
      @OperationPriorityConverter() this.priority = OperationPriority.low,
      this.createdAt,
      this.lastAttempt,
      this.attemptCount = 0,
      this.lastError,
      this.maxRetries = 3})
      : super._();
  factory _LocationUpdateOperation.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateOperationFromJson(json);

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
  @OperationPriorityConverter()
  final OperationPriority priority;
// Retry metadata
  @override
  final DateTime? createdAt;
  @override
  final DateTime? lastAttempt;
  @override
  @JsonKey()
  final int attemptCount;
  @override
  final String? lastError;
  @override
  @JsonKey()
  final int maxRetries;

  /// Create a copy of LocationUpdateOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LocationUpdateOperationCopyWith<_LocationUpdateOperation> get copyWith =>
      __$LocationUpdateOperationCopyWithImpl<_LocationUpdateOperation>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LocationUpdateOperationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LocationUpdateOperation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastAttempt, lastAttempt) ||
                other.lastAttempt == lastAttempt) &&
            (identical(other.attemptCount, attemptCount) ||
                other.attemptCount == attemptCount) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      latitude,
      longitude,
      timestamp,
      priority,
      createdAt,
      lastAttempt,
      attemptCount,
      lastError,
      maxRetries);

  @override
  String toString() {
    return 'LocationUpdateOperation(id: $id, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, priority: $priority, createdAt: $createdAt, lastAttempt: $lastAttempt, attemptCount: $attemptCount, lastError: $lastError, maxRetries: $maxRetries)';
  }
}

/// @nodoc
abstract mixin class _$LocationUpdateOperationCopyWith<$Res>
    implements $LocationUpdateOperationCopyWith<$Res> {
  factory _$LocationUpdateOperationCopyWith(_LocationUpdateOperation value,
          $Res Function(_LocationUpdateOperation) _then) =
      __$LocationUpdateOperationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      double latitude,
      double longitude,
      DateTime timestamp,
      @OperationPriorityConverter() OperationPriority priority,
      DateTime? createdAt,
      DateTime? lastAttempt,
      int attemptCount,
      String? lastError,
      int maxRetries});
}

/// @nodoc
class __$LocationUpdateOperationCopyWithImpl<$Res>
    implements _$LocationUpdateOperationCopyWith<$Res> {
  __$LocationUpdateOperationCopyWithImpl(this._self, this._then);

  final _LocationUpdateOperation _self;
  final $Res Function(_LocationUpdateOperation) _then;

  /// Create a copy of LocationUpdateOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = null,
    Object? priority = null,
    Object? createdAt = freezed,
    Object? lastAttempt = freezed,
    Object? attemptCount = null,
    Object? lastError = freezed,
    Object? maxRetries = null,
  }) {
    return _then(_LocationUpdateOperation(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as OperationPriority,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAttempt: freezed == lastAttempt
          ? _self.lastAttempt
          : lastAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      attemptCount: null == attemptCount
          ? _self.attemptCount
          : attemptCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _self.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      maxRetries: null == maxRetries
          ? _self.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
