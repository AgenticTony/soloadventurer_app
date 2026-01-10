// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_planning_operation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TripPlanningOperation {
  String get id;
  String get tripId;
  TripPlanningType get planningType;
  Map<String, dynamic> get changes;
  int get priority;
  DateTime? get plannedStartDate;
  DateTime? get plannedEndDate; // Retry metadata
  DateTime? get createdAt;
  DateTime? get lastAttempt;
  int get attemptCount;
  String? get lastError;
  int get maxRetries;

  /// Create a copy of TripPlanningOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TripPlanningOperationCopyWith<TripPlanningOperation> get copyWith =>
      _$TripPlanningOperationCopyWithImpl<TripPlanningOperation>(
          this as TripPlanningOperation, _$identity);

  /// Serializes this TripPlanningOperation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TripPlanningOperation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.planningType, planningType) ||
                other.planningType == planningType) &&
            const DeepCollectionEquality().equals(other.changes, changes) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.plannedStartDate, plannedStartDate) ||
                other.plannedStartDate == plannedStartDate) &&
            (identical(other.plannedEndDate, plannedEndDate) ||
                other.plannedEndDate == plannedEndDate) &&
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
      tripId,
      planningType,
      const DeepCollectionEquality().hash(changes),
      priority,
      plannedStartDate,
      plannedEndDate,
      createdAt,
      lastAttempt,
      attemptCount,
      lastError,
      maxRetries);

  @override
  String toString() {
    return 'TripPlanningOperation(id: $id, tripId: $tripId, planningType: $planningType, changes: $changes, priority: $priority, plannedStartDate: $plannedStartDate, plannedEndDate: $plannedEndDate, createdAt: $createdAt, lastAttempt: $lastAttempt, attemptCount: $attemptCount, lastError: $lastError, maxRetries: $maxRetries)';
  }
}

/// @nodoc
abstract mixin class $TripPlanningOperationCopyWith<$Res> {
  factory $TripPlanningOperationCopyWith(TripPlanningOperation value,
          $Res Function(TripPlanningOperation) _then) =
      _$TripPlanningOperationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String tripId,
      TripPlanningType planningType,
      Map<String, dynamic> changes,
      int priority,
      DateTime? plannedStartDate,
      DateTime? plannedEndDate,
      DateTime? createdAt,
      DateTime? lastAttempt,
      int attemptCount,
      String? lastError,
      int maxRetries});
}

/// @nodoc
class _$TripPlanningOperationCopyWithImpl<$Res>
    implements $TripPlanningOperationCopyWith<$Res> {
  _$TripPlanningOperationCopyWithImpl(this._self, this._then);

  final TripPlanningOperation _self;
  final $Res Function(TripPlanningOperation) _then;

  /// Create a copy of TripPlanningOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? planningType = null,
    Object? changes = null,
    Object? priority = null,
    Object? plannedStartDate = freezed,
    Object? plannedEndDate = freezed,
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
      tripId: null == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      planningType: null == planningType
          ? _self.planningType
          : planningType // ignore: cast_nullable_to_non_nullable
              as TripPlanningType,
      changes: null == changes
          ? _self.changes
          : changes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      plannedStartDate: freezed == plannedStartDate
          ? _self.plannedStartDate
          : plannedStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      plannedEndDate: freezed == plannedEndDate
          ? _self.plannedEndDate
          : plannedEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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

/// Adds pattern-matching-related methods to [TripPlanningOperation].
extension TripPlanningOperationPatterns on TripPlanningOperation {
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
    TResult Function(_TripPlanningOperation value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TripPlanningOperation() when $default != null:
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
    TResult Function(_TripPlanningOperation value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TripPlanningOperation():
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
    TResult? Function(_TripPlanningOperation value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TripPlanningOperation() when $default != null:
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
            String tripId,
            TripPlanningType planningType,
            Map<String, dynamic> changes,
            int priority,
            DateTime? plannedStartDate,
            DateTime? plannedEndDate,
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
      case _TripPlanningOperation() when $default != null:
        return $default(
            _that.id,
            _that.tripId,
            _that.planningType,
            _that.changes,
            _that.priority,
            _that.plannedStartDate,
            _that.plannedEndDate,
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
            String tripId,
            TripPlanningType planningType,
            Map<String, dynamic> changes,
            int priority,
            DateTime? plannedStartDate,
            DateTime? plannedEndDate,
            DateTime? createdAt,
            DateTime? lastAttempt,
            int attemptCount,
            String? lastError,
            int maxRetries)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TripPlanningOperation():
        return $default(
            _that.id,
            _that.tripId,
            _that.planningType,
            _that.changes,
            _that.priority,
            _that.plannedStartDate,
            _that.plannedEndDate,
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
            String tripId,
            TripPlanningType planningType,
            Map<String, dynamic> changes,
            int priority,
            DateTime? plannedStartDate,
            DateTime? plannedEndDate,
            DateTime? createdAt,
            DateTime? lastAttempt,
            int attemptCount,
            String? lastError,
            int maxRetries)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TripPlanningOperation() when $default != null:
        return $default(
            _that.id,
            _that.tripId,
            _that.planningType,
            _that.changes,
            _that.priority,
            _that.plannedStartDate,
            _that.plannedEndDate,
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
class _TripPlanningOperation extends TripPlanningOperation {
  const _TripPlanningOperation(
      {required this.id,
      required this.tripId,
      required this.planningType,
      required final Map<String, dynamic> changes,
      required this.priority,
      this.plannedStartDate,
      this.plannedEndDate,
      this.createdAt,
      this.lastAttempt,
      this.attemptCount = 0,
      this.lastError,
      this.maxRetries = 3})
      : _changes = changes,
        super._();
  factory _TripPlanningOperation.fromJson(Map<String, dynamic> json) =>
      _$TripPlanningOperationFromJson(json);

  @override
  final String id;
  @override
  final String tripId;
  @override
  final TripPlanningType planningType;
  final Map<String, dynamic> _changes;
  @override
  Map<String, dynamic> get changes {
    if (_changes is EqualUnmodifiableMapView) return _changes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_changes);
  }

  @override
  final int priority;
  @override
  final DateTime? plannedStartDate;
  @override
  final DateTime? plannedEndDate;
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

  /// Create a copy of TripPlanningOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TripPlanningOperationCopyWith<_TripPlanningOperation> get copyWith =>
      __$TripPlanningOperationCopyWithImpl<_TripPlanningOperation>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TripPlanningOperationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TripPlanningOperation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.planningType, planningType) ||
                other.planningType == planningType) &&
            const DeepCollectionEquality().equals(other._changes, _changes) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.plannedStartDate, plannedStartDate) ||
                other.plannedStartDate == plannedStartDate) &&
            (identical(other.plannedEndDate, plannedEndDate) ||
                other.plannedEndDate == plannedEndDate) &&
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
      tripId,
      planningType,
      const DeepCollectionEquality().hash(_changes),
      priority,
      plannedStartDate,
      plannedEndDate,
      createdAt,
      lastAttempt,
      attemptCount,
      lastError,
      maxRetries);

  @override
  String toString() {
    return 'TripPlanningOperation(id: $id, tripId: $tripId, planningType: $planningType, changes: $changes, priority: $priority, plannedStartDate: $plannedStartDate, plannedEndDate: $plannedEndDate, createdAt: $createdAt, lastAttempt: $lastAttempt, attemptCount: $attemptCount, lastError: $lastError, maxRetries: $maxRetries)';
  }
}

/// @nodoc
abstract mixin class _$TripPlanningOperationCopyWith<$Res>
    implements $TripPlanningOperationCopyWith<$Res> {
  factory _$TripPlanningOperationCopyWith(_TripPlanningOperation value,
          $Res Function(_TripPlanningOperation) _then) =
      __$TripPlanningOperationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String tripId,
      TripPlanningType planningType,
      Map<String, dynamic> changes,
      int priority,
      DateTime? plannedStartDate,
      DateTime? plannedEndDate,
      DateTime? createdAt,
      DateTime? lastAttempt,
      int attemptCount,
      String? lastError,
      int maxRetries});
}

/// @nodoc
class __$TripPlanningOperationCopyWithImpl<$Res>
    implements _$TripPlanningOperationCopyWith<$Res> {
  __$TripPlanningOperationCopyWithImpl(this._self, this._then);

  final _TripPlanningOperation _self;
  final $Res Function(_TripPlanningOperation) _then;

  /// Create a copy of TripPlanningOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? planningType = null,
    Object? changes = null,
    Object? priority = null,
    Object? plannedStartDate = freezed,
    Object? plannedEndDate = freezed,
    Object? createdAt = freezed,
    Object? lastAttempt = freezed,
    Object? attemptCount = null,
    Object? lastError = freezed,
    Object? maxRetries = null,
  }) {
    return _then(_TripPlanningOperation(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      planningType: null == planningType
          ? _self.planningType
          : planningType // ignore: cast_nullable_to_non_nullable
              as TripPlanningType,
      changes: null == changes
          ? _self._changes
          : changes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      plannedStartDate: freezed == plannedStartDate
          ? _self.plannedStartDate
          : plannedStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      plannedEndDate: freezed == plannedEndDate
          ? _self.plannedEndDate
          : plannedEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
