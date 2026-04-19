// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncState {
  /// Current sync status
  SyncOperationStatus get status;

  /// Number of operations in the sync queue
  int get queueSize;

  /// Timestamp of last status change
  DateTime? get lastStatusChangeAt;

  /// Timestamp of last successful sync
  DateTime? get lastSuccessfulSyncAt;

  /// Number of operations successfully synced in last sync
  int get lastSuccessCount;

  /// Number of operations that failed in last sync
  int get lastFailureCount;

  /// Whether there are pending operations
  bool get hasPendingOperations;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SyncStateCopyWith<SyncState> get copyWith =>
      _$SyncStateCopyWithImpl<SyncState>(this as SyncState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SyncState &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.queueSize, queueSize) ||
                other.queueSize == queueSize) &&
            (identical(other.lastStatusChangeAt, lastStatusChangeAt) ||
                other.lastStatusChangeAt == lastStatusChangeAt) &&
            (identical(other.lastSuccessfulSyncAt, lastSuccessfulSyncAt) ||
                other.lastSuccessfulSyncAt == lastSuccessfulSyncAt) &&
            (identical(other.lastSuccessCount, lastSuccessCount) ||
                other.lastSuccessCount == lastSuccessCount) &&
            (identical(other.lastFailureCount, lastFailureCount) ||
                other.lastFailureCount == lastFailureCount) &&
            (identical(other.hasPendingOperations, hasPendingOperations) ||
                other.hasPendingOperations == hasPendingOperations));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      queueSize,
      lastStatusChangeAt,
      lastSuccessfulSyncAt,
      lastSuccessCount,
      lastFailureCount,
      hasPendingOperations);

  @override
  String toString() {
    return 'SyncState(status: $status, queueSize: $queueSize, lastStatusChangeAt: $lastStatusChangeAt, lastSuccessfulSyncAt: $lastSuccessfulSyncAt, lastSuccessCount: $lastSuccessCount, lastFailureCount: $lastFailureCount, hasPendingOperations: $hasPendingOperations)';
  }
}

/// @nodoc
abstract mixin class $SyncStateCopyWith<$Res> {
  factory $SyncStateCopyWith(SyncState value, $Res Function(SyncState) _then) =
      _$SyncStateCopyWithImpl;
  @useResult
  $Res call(
      {SyncOperationStatus status,
      int queueSize,
      DateTime? lastStatusChangeAt,
      DateTime? lastSuccessfulSyncAt,
      int lastSuccessCount,
      int lastFailureCount,
      bool hasPendingOperations});
}

/// @nodoc
class _$SyncStateCopyWithImpl<$Res> implements $SyncStateCopyWith<$Res> {
  _$SyncStateCopyWithImpl(this._self, this._then);

  final SyncState _self;
  final $Res Function(SyncState) _then;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? queueSize = null,
    Object? lastStatusChangeAt = freezed,
    Object? lastSuccessfulSyncAt = freezed,
    Object? lastSuccessCount = null,
    Object? lastFailureCount = null,
    Object? hasPendingOperations = null,
  }) {
    return _then(_self.copyWith(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncOperationStatus,
      queueSize: null == queueSize
          ? _self.queueSize
          : queueSize // ignore: cast_nullable_to_non_nullable
              as int,
      lastStatusChangeAt: freezed == lastStatusChangeAt
          ? _self.lastStatusChangeAt
          : lastStatusChangeAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSuccessfulSyncAt: freezed == lastSuccessfulSyncAt
          ? _self.lastSuccessfulSyncAt
          : lastSuccessfulSyncAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSuccessCount: null == lastSuccessCount
          ? _self.lastSuccessCount
          : lastSuccessCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastFailureCount: null == lastFailureCount
          ? _self.lastFailureCount
          : lastFailureCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasPendingOperations: null == hasPendingOperations
          ? _self.hasPendingOperations
          : hasPendingOperations // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [SyncState].
extension SyncStatePatterns on SyncState {
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
    TResult Function(_SyncState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SyncState() when $default != null:
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
    TResult Function(_SyncState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncState():
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
    TResult? Function(_SyncState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncState() when $default != null:
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
            int queueSize,
            DateTime? lastStatusChangeAt,
            DateTime? lastSuccessfulSyncAt,
            int lastSuccessCount,
            int lastFailureCount,
            bool hasPendingOperations)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SyncState() when $default != null:
        return $default(
            _that.status,
            _that.queueSize,
            _that.lastStatusChangeAt,
            _that.lastSuccessfulSyncAt,
            _that.lastSuccessCount,
            _that.lastFailureCount,
            _that.hasPendingOperations);
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
            int queueSize,
            DateTime? lastStatusChangeAt,
            DateTime? lastSuccessfulSyncAt,
            int lastSuccessCount,
            int lastFailureCount,
            bool hasPendingOperations)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncState():
        return $default(
            _that.status,
            _that.queueSize,
            _that.lastStatusChangeAt,
            _that.lastSuccessfulSyncAt,
            _that.lastSuccessCount,
            _that.lastFailureCount,
            _that.hasPendingOperations);
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
            int queueSize,
            DateTime? lastStatusChangeAt,
            DateTime? lastSuccessfulSyncAt,
            int lastSuccessCount,
            int lastFailureCount,
            bool hasPendingOperations)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncState() when $default != null:
        return $default(
            _that.status,
            _that.queueSize,
            _that.lastStatusChangeAt,
            _that.lastSuccessfulSyncAt,
            _that.lastSuccessCount,
            _that.lastFailureCount,
            _that.hasPendingOperations);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SyncState extends SyncState {
  const _SyncState(
      {required this.status,
      this.queueSize = 0,
      this.lastStatusChangeAt,
      this.lastSuccessfulSyncAt,
      this.lastSuccessCount = 0,
      this.lastFailureCount = 0,
      this.hasPendingOperations = false})
      : super._();

  /// Current sync status
  @override
  final SyncOperationStatus status;

  /// Number of operations in the sync queue
  @override
  @JsonKey()
  final int queueSize;

  /// Timestamp of last status change
  @override
  final DateTime? lastStatusChangeAt;

  /// Timestamp of last successful sync
  @override
  final DateTime? lastSuccessfulSyncAt;

  /// Number of operations successfully synced in last sync
  @override
  @JsonKey()
  final int lastSuccessCount;

  /// Number of operations that failed in last sync
  @override
  @JsonKey()
  final int lastFailureCount;

  /// Whether there are pending operations
  @override
  @JsonKey()
  final bool hasPendingOperations;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SyncStateCopyWith<_SyncState> get copyWith =>
      __$SyncStateCopyWithImpl<_SyncState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SyncState &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.queueSize, queueSize) ||
                other.queueSize == queueSize) &&
            (identical(other.lastStatusChangeAt, lastStatusChangeAt) ||
                other.lastStatusChangeAt == lastStatusChangeAt) &&
            (identical(other.lastSuccessfulSyncAt, lastSuccessfulSyncAt) ||
                other.lastSuccessfulSyncAt == lastSuccessfulSyncAt) &&
            (identical(other.lastSuccessCount, lastSuccessCount) ||
                other.lastSuccessCount == lastSuccessCount) &&
            (identical(other.lastFailureCount, lastFailureCount) ||
                other.lastFailureCount == lastFailureCount) &&
            (identical(other.hasPendingOperations, hasPendingOperations) ||
                other.hasPendingOperations == hasPendingOperations));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      queueSize,
      lastStatusChangeAt,
      lastSuccessfulSyncAt,
      lastSuccessCount,
      lastFailureCount,
      hasPendingOperations);

  @override
  String toString() {
    return 'SyncState(status: $status, queueSize: $queueSize, lastStatusChangeAt: $lastStatusChangeAt, lastSuccessfulSyncAt: $lastSuccessfulSyncAt, lastSuccessCount: $lastSuccessCount, lastFailureCount: $lastFailureCount, hasPendingOperations: $hasPendingOperations)';
  }
}

/// @nodoc
abstract mixin class _$SyncStateCopyWith<$Res>
    implements $SyncStateCopyWith<$Res> {
  factory _$SyncStateCopyWith(
          _SyncState value, $Res Function(_SyncState) _then) =
      __$SyncStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {SyncOperationStatus status,
      int queueSize,
      DateTime? lastStatusChangeAt,
      DateTime? lastSuccessfulSyncAt,
      int lastSuccessCount,
      int lastFailureCount,
      bool hasPendingOperations});
}

/// @nodoc
class __$SyncStateCopyWithImpl<$Res> implements _$SyncStateCopyWith<$Res> {
  __$SyncStateCopyWithImpl(this._self, this._then);

  final _SyncState _self;
  final $Res Function(_SyncState) _then;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? status = null,
    Object? queueSize = null,
    Object? lastStatusChangeAt = freezed,
    Object? lastSuccessfulSyncAt = freezed,
    Object? lastSuccessCount = null,
    Object? lastFailureCount = null,
    Object? hasPendingOperations = null,
  }) {
    return _then(_SyncState(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncOperationStatus,
      queueSize: null == queueSize
          ? _self.queueSize
          : queueSize // ignore: cast_nullable_to_non_nullable
              as int,
      lastStatusChangeAt: freezed == lastStatusChangeAt
          ? _self.lastStatusChangeAt
          : lastStatusChangeAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSuccessfulSyncAt: freezed == lastSuccessfulSyncAt
          ? _self.lastSuccessfulSyncAt
          : lastSuccessfulSyncAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSuccessCount: null == lastSuccessCount
          ? _self.lastSuccessCount
          : lastSuccessCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastFailureCount: null == lastFailureCount
          ? _self.lastFailureCount
          : lastFailureCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasPendingOperations: null == hasPendingOperations
          ? _self.hasPendingOperations
          : hasPendingOperations // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
