// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_planning_operation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TripPlanningOperation _$TripPlanningOperationFromJson(
    Map<String, dynamic> json) {
  return _TripPlanningOperation.fromJson(json);
}

/// @nodoc
mixin _$TripPlanningOperation {
  String get id => throw _privateConstructorUsedError;
  String get tripId => throw _privateConstructorUsedError;
  TripPlanningType get planningType => throw _privateConstructorUsedError;
  Map<String, dynamic> get changes => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  DateTime? get plannedStartDate => throw _privateConstructorUsedError;
  DateTime? get plannedEndDate =>
      throw _privateConstructorUsedError; // Retry metadata
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastAttempt => throw _privateConstructorUsedError;
  int get attemptCount => throw _privateConstructorUsedError;
  String? get lastError => throw _privateConstructorUsedError;
  int get maxRetries => throw _privateConstructorUsedError;

  /// Serializes this TripPlanningOperation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripPlanningOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripPlanningOperationCopyWith<TripPlanningOperation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripPlanningOperationCopyWith<$Res> {
  factory $TripPlanningOperationCopyWith(TripPlanningOperation value,
          $Res Function(TripPlanningOperation) then) =
      _$TripPlanningOperationCopyWithImpl<$Res, TripPlanningOperation>;
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
class _$TripPlanningOperationCopyWithImpl<$Res,
        $Val extends TripPlanningOperation>
    implements $TripPlanningOperationCopyWith<$Res> {
  _$TripPlanningOperationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      planningType: null == planningType
          ? _value.planningType
          : planningType // ignore: cast_nullable_to_non_nullable
              as TripPlanningType,
      changes: null == changes
          ? _value.changes
          : changes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      plannedStartDate: freezed == plannedStartDate
          ? _value.plannedStartDate
          : plannedStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      plannedEndDate: freezed == plannedEndDate
          ? _value.plannedEndDate
          : plannedEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAttempt: freezed == lastAttempt
          ? _value.lastAttempt
          : lastAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      attemptCount: null == attemptCount
          ? _value.attemptCount
          : attemptCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripPlanningOperationImplCopyWith<$Res>
    implements $TripPlanningOperationCopyWith<$Res> {
  factory _$$TripPlanningOperationImplCopyWith(
          _$TripPlanningOperationImpl value,
          $Res Function(_$TripPlanningOperationImpl) then) =
      __$$TripPlanningOperationImplCopyWithImpl<$Res>;
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
class __$$TripPlanningOperationImplCopyWithImpl<$Res>
    extends _$TripPlanningOperationCopyWithImpl<$Res,
        _$TripPlanningOperationImpl>
    implements _$$TripPlanningOperationImplCopyWith<$Res> {
  __$$TripPlanningOperationImplCopyWithImpl(_$TripPlanningOperationImpl _value,
      $Res Function(_$TripPlanningOperationImpl) _then)
      : super(_value, _then);

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
    return _then(_$TripPlanningOperationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      planningType: null == planningType
          ? _value.planningType
          : planningType // ignore: cast_nullable_to_non_nullable
              as TripPlanningType,
      changes: null == changes
          ? _value._changes
          : changes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      plannedStartDate: freezed == plannedStartDate
          ? _value.plannedStartDate
          : plannedStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      plannedEndDate: freezed == plannedEndDate
          ? _value.plannedEndDate
          : plannedEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAttempt: freezed == lastAttempt
          ? _value.lastAttempt
          : lastAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      attemptCount: null == attemptCount
          ? _value.attemptCount
          : attemptCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripPlanningOperationImpl extends _TripPlanningOperation {
  const _$TripPlanningOperationImpl(
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

  factory _$TripPlanningOperationImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripPlanningOperationImplFromJson(json);

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

  @override
  String toString() {
    return 'TripPlanningOperation(id: $id, tripId: $tripId, planningType: $planningType, changes: $changes, priority: $priority, plannedStartDate: $plannedStartDate, plannedEndDate: $plannedEndDate, createdAt: $createdAt, lastAttempt: $lastAttempt, attemptCount: $attemptCount, lastError: $lastError, maxRetries: $maxRetries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripPlanningOperationImpl &&
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

  /// Create a copy of TripPlanningOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripPlanningOperationImplCopyWith<_$TripPlanningOperationImpl>
      get copyWith => __$$TripPlanningOperationImplCopyWithImpl<
          _$TripPlanningOperationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripPlanningOperationImplToJson(
      this,
    );
  }
}

abstract class _TripPlanningOperation extends TripPlanningOperation {
  const factory _TripPlanningOperation(
      {required final String id,
      required final String tripId,
      required final TripPlanningType planningType,
      required final Map<String, dynamic> changes,
      required final int priority,
      final DateTime? plannedStartDate,
      final DateTime? plannedEndDate,
      final DateTime? createdAt,
      final DateTime? lastAttempt,
      final int attemptCount,
      final String? lastError,
      final int maxRetries}) = _$TripPlanningOperationImpl;
  const _TripPlanningOperation._() : super._();

  factory _TripPlanningOperation.fromJson(Map<String, dynamic> json) =
      _$TripPlanningOperationImpl.fromJson;

  @override
  String get id;
  @override
  String get tripId;
  @override
  TripPlanningType get planningType;
  @override
  Map<String, dynamic> get changes;
  @override
  int get priority;
  @override
  DateTime? get plannedStartDate;
  @override
  DateTime? get plannedEndDate; // Retry metadata
  @override
  DateTime? get createdAt;
  @override
  DateTime? get lastAttempt;
  @override
  int get attemptCount;
  @override
  String? get lastError;
  @override
  int get maxRetries;

  /// Create a copy of TripPlanningOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripPlanningOperationImplCopyWith<_$TripPlanningOperationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
