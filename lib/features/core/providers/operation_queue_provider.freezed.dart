// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'operation_queue_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OperationQueueState {
  /// List of pending operations waiting to be processed
  List<QueueableOperation> get pendingOperations;

  /// List of failed operations that exceeded max retries
  List<QueueableOperation> get failedOperations;

  /// Whether the queue is currently processing operations
  bool get isProcessing;

  /// Count of pending operations
  int get pendingCount;

  /// Count of failed operations
  int get failedCount;

  /// Create a copy of OperationQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OperationQueueStateCopyWith<OperationQueueState> get copyWith =>
      _$OperationQueueStateCopyWithImpl<OperationQueueState>(
          this as OperationQueueState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OperationQueueState &&
            const DeepCollectionEquality()
                .equals(other.pendingOperations, pendingOperations) &&
            const DeepCollectionEquality()
                .equals(other.failedOperations, failedOperations) &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.pendingCount, pendingCount) ||
                other.pendingCount == pendingCount) &&
            (identical(other.failedCount, failedCount) ||
                other.failedCount == failedCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(pendingOperations),
      const DeepCollectionEquality().hash(failedOperations),
      isProcessing,
      pendingCount,
      failedCount);

  @override
  String toString() {
    return 'OperationQueueState(pendingOperations: $pendingOperations, failedOperations: $failedOperations, isProcessing: $isProcessing, pendingCount: $pendingCount, failedCount: $failedCount)';
  }
}

/// @nodoc
abstract mixin class $OperationQueueStateCopyWith<$Res> {
  factory $OperationQueueStateCopyWith(
          OperationQueueState value, $Res Function(OperationQueueState) _then) =
      _$OperationQueueStateCopyWithImpl;
  @useResult
  $Res call(
      {List<QueueableOperation> pendingOperations,
      List<QueueableOperation> failedOperations,
      bool isProcessing,
      int pendingCount,
      int failedCount});
}

/// @nodoc
class _$OperationQueueStateCopyWithImpl<$Res>
    implements $OperationQueueStateCopyWith<$Res> {
  _$OperationQueueStateCopyWithImpl(this._self, this._then);

  final OperationQueueState _self;
  final $Res Function(OperationQueueState) _then;

  /// Create a copy of OperationQueueState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pendingOperations = null,
    Object? failedOperations = null,
    Object? isProcessing = null,
    Object? pendingCount = null,
    Object? failedCount = null,
  }) {
    return _then(_self.copyWith(
      pendingOperations: null == pendingOperations
          ? _self.pendingOperations
          : pendingOperations // ignore: cast_nullable_to_non_nullable
              as List<QueueableOperation>,
      failedOperations: null == failedOperations
          ? _self.failedOperations
          : failedOperations // ignore: cast_nullable_to_non_nullable
              as List<QueueableOperation>,
      isProcessing: null == isProcessing
          ? _self.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      pendingCount: null == pendingCount
          ? _self.pendingCount
          : pendingCount // ignore: cast_nullable_to_non_nullable
              as int,
      failedCount: null == failedCount
          ? _self.failedCount
          : failedCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [OperationQueueState].
extension OperationQueueStatePatterns on OperationQueueState {
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
    TResult Function(_OperationQueueState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OperationQueueState() when $default != null:
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
    TResult Function(_OperationQueueState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OperationQueueState():
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
    TResult? Function(_OperationQueueState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OperationQueueState() when $default != null:
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
            List<QueueableOperation> pendingOperations,
            List<QueueableOperation> failedOperations,
            bool isProcessing,
            int pendingCount,
            int failedCount)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OperationQueueState() when $default != null:
        return $default(_that.pendingOperations, _that.failedOperations,
            _that.isProcessing, _that.pendingCount, _that.failedCount);
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
            List<QueueableOperation> pendingOperations,
            List<QueueableOperation> failedOperations,
            bool isProcessing,
            int pendingCount,
            int failedCount)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OperationQueueState():
        return $default(_that.pendingOperations, _that.failedOperations,
            _that.isProcessing, _that.pendingCount, _that.failedCount);
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
            List<QueueableOperation> pendingOperations,
            List<QueueableOperation> failedOperations,
            bool isProcessing,
            int pendingCount,
            int failedCount)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OperationQueueState() when $default != null:
        return $default(_that.pendingOperations, _that.failedOperations,
            _that.isProcessing, _that.pendingCount, _that.failedCount);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OperationQueueState implements OperationQueueState {
  const _OperationQueueState(
      {final List<QueueableOperation> pendingOperations = const [],
      final List<QueueableOperation> failedOperations = const [],
      this.isProcessing = false,
      this.pendingCount = 0,
      this.failedCount = 0})
      : _pendingOperations = pendingOperations,
        _failedOperations = failedOperations;

  /// List of pending operations waiting to be processed
  final List<QueueableOperation> _pendingOperations;

  /// List of pending operations waiting to be processed
  @override
  @JsonKey()
  List<QueueableOperation> get pendingOperations {
    if (_pendingOperations is EqualUnmodifiableListView)
      return _pendingOperations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingOperations);
  }

  /// List of failed operations that exceeded max retries
  final List<QueueableOperation> _failedOperations;

  /// List of failed operations that exceeded max retries
  @override
  @JsonKey()
  List<QueueableOperation> get failedOperations {
    if (_failedOperations is EqualUnmodifiableListView)
      return _failedOperations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_failedOperations);
  }

  /// Whether the queue is currently processing operations
  @override
  @JsonKey()
  final bool isProcessing;

  /// Count of pending operations
  @override
  @JsonKey()
  final int pendingCount;

  /// Count of failed operations
  @override
  @JsonKey()
  final int failedCount;

  /// Create a copy of OperationQueueState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OperationQueueStateCopyWith<_OperationQueueState> get copyWith =>
      __$OperationQueueStateCopyWithImpl<_OperationQueueState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OperationQueueState &&
            const DeepCollectionEquality()
                .equals(other._pendingOperations, _pendingOperations) &&
            const DeepCollectionEquality()
                .equals(other._failedOperations, _failedOperations) &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.pendingCount, pendingCount) ||
                other.pendingCount == pendingCount) &&
            (identical(other.failedCount, failedCount) ||
                other.failedCount == failedCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_pendingOperations),
      const DeepCollectionEquality().hash(_failedOperations),
      isProcessing,
      pendingCount,
      failedCount);

  @override
  String toString() {
    return 'OperationQueueState(pendingOperations: $pendingOperations, failedOperations: $failedOperations, isProcessing: $isProcessing, pendingCount: $pendingCount, failedCount: $failedCount)';
  }
}

/// @nodoc
abstract mixin class _$OperationQueueStateCopyWith<$Res>
    implements $OperationQueueStateCopyWith<$Res> {
  factory _$OperationQueueStateCopyWith(_OperationQueueState value,
          $Res Function(_OperationQueueState) _then) =
      __$OperationQueueStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<QueueableOperation> pendingOperations,
      List<QueueableOperation> failedOperations,
      bool isProcessing,
      int pendingCount,
      int failedCount});
}

/// @nodoc
class __$OperationQueueStateCopyWithImpl<$Res>
    implements _$OperationQueueStateCopyWith<$Res> {
  __$OperationQueueStateCopyWithImpl(this._self, this._then);

  final _OperationQueueState _self;
  final $Res Function(_OperationQueueState) _then;

  /// Create a copy of OperationQueueState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? pendingOperations = null,
    Object? failedOperations = null,
    Object? isProcessing = null,
    Object? pendingCount = null,
    Object? failedCount = null,
  }) {
    return _then(_OperationQueueState(
      pendingOperations: null == pendingOperations
          ? _self._pendingOperations
          : pendingOperations // ignore: cast_nullable_to_non_nullable
              as List<QueueableOperation>,
      failedOperations: null == failedOperations
          ? _self._failedOperations
          : failedOperations // ignore: cast_nullable_to_non_nullable
              as List<QueueableOperation>,
      isProcessing: null == isProcessing
          ? _self.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      pendingCount: null == pendingCount
          ? _self.pendingCount
          : pendingCount // ignore: cast_nullable_to_non_nullable
              as int,
      failedCount: null == failedCount
          ? _self.failedCount
          : failedCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
