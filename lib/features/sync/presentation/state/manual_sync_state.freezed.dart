// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manual_sync_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ManualSyncState {
  /// Current sync status
  SyncOperationStatus get status;

  /// Number of operations successfully synced in last manual sync
  int get successCount;

  /// Number of operations that failed in last manual sync
  int get failureCount;

  /// Timestamp when the last manual sync completed
  DateTime? get completedAt;

  /// Timestamp when the current manual sync started
  DateTime? get startedAt;

  /// Total number of operations processed
  int get totalProcessed;

  /// Create a copy of ManualSyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ManualSyncStateCopyWith<ManualSyncState> get copyWith =>
      _$ManualSyncStateCopyWithImpl<ManualSyncState>(
          this as ManualSyncState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ManualSyncState &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.successCount, successCount) ||
                other.successCount == successCount) &&
            (identical(other.failureCount, failureCount) ||
                other.failureCount == failureCount) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.totalProcessed, totalProcessed) ||
                other.totalProcessed == totalProcessed));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status, successCount,
      failureCount, completedAt, startedAt, totalProcessed);

  @override
  String toString() {
    return 'ManualSyncState(status: $status, successCount: $successCount, failureCount: $failureCount, completedAt: $completedAt, startedAt: $startedAt, totalProcessed: $totalProcessed)';
  }
}

/// @nodoc
abstract mixin class $ManualSyncStateCopyWith<$Res> {
  factory $ManualSyncStateCopyWith(
          ManualSyncState value, $Res Function(ManualSyncState) _then) =
      _$ManualSyncStateCopyWithImpl;
  @useResult
  $Res call(
      {SyncOperationStatus status,
      int successCount,
      int failureCount,
      DateTime? completedAt,
      DateTime? startedAt,
      int totalProcessed});
}

/// @nodoc
class _$ManualSyncStateCopyWithImpl<$Res>
    implements $ManualSyncStateCopyWith<$Res> {
  _$ManualSyncStateCopyWithImpl(this._self, this._then);

  final ManualSyncState _self;
  final $Res Function(ManualSyncState) _then;

  /// Create a copy of ManualSyncState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? successCount = null,
    Object? failureCount = null,
    Object? completedAt = freezed,
    Object? startedAt = freezed,
    Object? totalProcessed = null,
  }) {
    return _then(_self.copyWith(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncOperationStatus,
      successCount: null == successCount
          ? _self.successCount
          : successCount // ignore: cast_nullable_to_non_nullable
              as int,
      failureCount: null == failureCount
          ? _self.failureCount
          : failureCount // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startedAt: freezed == startedAt
          ? _self.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalProcessed: null == totalProcessed
          ? _self.totalProcessed
          : totalProcessed // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [ManualSyncState].
extension ManualSyncStatePatterns on ManualSyncState {
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
    TResult Function(_ManualSyncState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ManualSyncState() when $default != null:
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
    TResult Function(_ManualSyncState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ManualSyncState():
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
    TResult? Function(_ManualSyncState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ManualSyncState() when $default != null:
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
            SyncOperationStatus status,
            int successCount,
            int failureCount,
            DateTime? completedAt,
            DateTime? startedAt,
            int totalProcessed)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ManualSyncState() when $default != null:
        return $default(_that.status, _that.successCount, _that.failureCount,
            _that.completedAt, _that.startedAt, _that.totalProcessed);
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
            SyncOperationStatus status,
            int successCount,
            int failureCount,
            DateTime? completedAt,
            DateTime? startedAt,
            int totalProcessed)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ManualSyncState():
        return $default(_that.status, _that.successCount, _that.failureCount,
            _that.completedAt, _that.startedAt, _that.totalProcessed);
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
            SyncOperationStatus status,
            int successCount,
            int failureCount,
            DateTime? completedAt,
            DateTime? startedAt,
            int totalProcessed)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ManualSyncState() when $default != null:
        return $default(_that.status, _that.successCount, _that.failureCount,
            _that.completedAt, _that.startedAt, _that.totalProcessed);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ManualSyncState extends ManualSyncState {
  const _ManualSyncState(
      {required this.status,
      this.successCount = 0,
      this.failureCount = 0,
      this.completedAt,
      this.startedAt,
      this.totalProcessed = 0})
      : super._();

  /// Current sync status
  @override
  final SyncOperationStatus status;

  /// Number of operations successfully synced in last manual sync
  @override
  @JsonKey()
  final int successCount;

  /// Number of operations that failed in last manual sync
  @override
  @JsonKey()
  final int failureCount;

  /// Timestamp when the last manual sync completed
  @override
  final DateTime? completedAt;

  /// Timestamp when the current manual sync started
  @override
  final DateTime? startedAt;

  /// Total number of operations processed
  @override
  @JsonKey()
  final int totalProcessed;

  /// Create a copy of ManualSyncState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ManualSyncStateCopyWith<_ManualSyncState> get copyWith =>
      __$ManualSyncStateCopyWithImpl<_ManualSyncState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ManualSyncState &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.successCount, successCount) ||
                other.successCount == successCount) &&
            (identical(other.failureCount, failureCount) ||
                other.failureCount == failureCount) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.totalProcessed, totalProcessed) ||
                other.totalProcessed == totalProcessed));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status, successCount,
      failureCount, completedAt, startedAt, totalProcessed);

  @override
  String toString() {
    return 'ManualSyncState(status: $status, successCount: $successCount, failureCount: $failureCount, completedAt: $completedAt, startedAt: $startedAt, totalProcessed: $totalProcessed)';
  }
}

/// @nodoc
abstract mixin class _$ManualSyncStateCopyWith<$Res>
    implements $ManualSyncStateCopyWith<$Res> {
  factory _$ManualSyncStateCopyWith(
          _ManualSyncState value, $Res Function(_ManualSyncState) _then) =
      __$ManualSyncStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {SyncOperationStatus status,
      int successCount,
      int failureCount,
      DateTime? completedAt,
      DateTime? startedAt,
      int totalProcessed});
}

/// @nodoc
class __$ManualSyncStateCopyWithImpl<$Res>
    implements _$ManualSyncStateCopyWith<$Res> {
  __$ManualSyncStateCopyWithImpl(this._self, this._then);

  final _ManualSyncState _self;
  final $Res Function(_ManualSyncState) _then;

  /// Create a copy of ManualSyncState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? status = null,
    Object? successCount = null,
    Object? failureCount = null,
    Object? completedAt = freezed,
    Object? startedAt = freezed,
    Object? totalProcessed = null,
  }) {
    return _then(_ManualSyncState(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncOperationStatus,
      successCount: null == successCount
          ? _self.successCount
          : successCount // ignore: cast_nullable_to_non_nullable
              as int,
      failureCount: null == failureCount
          ? _self.failureCount
          : failureCount // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startedAt: freezed == startedAt
          ? _self.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalProcessed: null == totalProcessed
          ? _self.totalProcessed
          : totalProcessed // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
