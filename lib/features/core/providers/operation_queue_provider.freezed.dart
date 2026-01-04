// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'operation_queue_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OperationQueueState {
  /// List of pending operations waiting to be processed
  List<QueueableOperation> get pendingOperations =>
      throw _privateConstructorUsedError;

  /// List of failed operations that exceeded max retries
  List<QueueableOperation> get failedOperations =>
      throw _privateConstructorUsedError;

  /// Whether the queue is currently processing operations
  bool get isProcessing => throw _privateConstructorUsedError;

  /// Count of pending operations
  int get pendingCount => throw _privateConstructorUsedError;

  /// Count of failed operations
  int get failedCount => throw _privateConstructorUsedError;

  /// Create a copy of OperationQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OperationQueueStateCopyWith<OperationQueueState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OperationQueueStateCopyWith<$Res> {
  factory $OperationQueueStateCopyWith(
          OperationQueueState value, $Res Function(OperationQueueState) then) =
      _$OperationQueueStateCopyWithImpl<$Res, OperationQueueState>;
  @useResult
  $Res call(
      {List<QueueableOperation> pendingOperations,
      List<QueueableOperation> failedOperations,
      bool isProcessing,
      int pendingCount,
      int failedCount});
}

/// @nodoc
class _$OperationQueueStateCopyWithImpl<$Res, $Val extends OperationQueueState>
    implements $OperationQueueStateCopyWith<$Res> {
  _$OperationQueueStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      pendingOperations: null == pendingOperations
          ? _value.pendingOperations
          : pendingOperations // ignore: cast_nullable_to_non_nullable
              as List<QueueableOperation>,
      failedOperations: null == failedOperations
          ? _value.failedOperations
          : failedOperations // ignore: cast_nullable_to_non_nullable
              as List<QueueableOperation>,
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      pendingCount: null == pendingCount
          ? _value.pendingCount
          : pendingCount // ignore: cast_nullable_to_non_nullable
              as int,
      failedCount: null == failedCount
          ? _value.failedCount
          : failedCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OperationQueueStateImplCopyWith<$Res>
    implements $OperationQueueStateCopyWith<$Res> {
  factory _$$OperationQueueStateImplCopyWith(_$OperationQueueStateImpl value,
          $Res Function(_$OperationQueueStateImpl) then) =
      __$$OperationQueueStateImplCopyWithImpl<$Res>;
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
class __$$OperationQueueStateImplCopyWithImpl<$Res>
    extends _$OperationQueueStateCopyWithImpl<$Res, _$OperationQueueStateImpl>
    implements _$$OperationQueueStateImplCopyWith<$Res> {
  __$$OperationQueueStateImplCopyWithImpl(_$OperationQueueStateImpl _value,
      $Res Function(_$OperationQueueStateImpl) _then)
      : super(_value, _then);

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
    return _then(_$OperationQueueStateImpl(
      pendingOperations: null == pendingOperations
          ? _value._pendingOperations
          : pendingOperations // ignore: cast_nullable_to_non_nullable
              as List<QueueableOperation>,
      failedOperations: null == failedOperations
          ? _value._failedOperations
          : failedOperations // ignore: cast_nullable_to_non_nullable
              as List<QueueableOperation>,
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      pendingCount: null == pendingCount
          ? _value.pendingCount
          : pendingCount // ignore: cast_nullable_to_non_nullable
              as int,
      failedCount: null == failedCount
          ? _value.failedCount
          : failedCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$OperationQueueStateImpl extends _OperationQueueState {
  const _$OperationQueueStateImpl(
      {final List<QueueableOperation> pendingOperations = const [],
      final List<QueueableOperation> failedOperations = const [],
      this.isProcessing = false,
      this.pendingCount = 0,
      this.failedCount = 0})
      : _pendingOperations = pendingOperations,
        _failedOperations = failedOperations,
        super._();

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

  @override
  String toString() {
    return 'OperationQueueState(pendingOperations: $pendingOperations, failedOperations: $failedOperations, isProcessing: $isProcessing, pendingCount: $pendingCount, failedCount: $failedCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OperationQueueStateImpl &&
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

  /// Create a copy of OperationQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OperationQueueStateImplCopyWith<_$OperationQueueStateImpl> get copyWith =>
      __$$OperationQueueStateImplCopyWithImpl<_$OperationQueueStateImpl>(
          this, _$identity);
}

abstract class _OperationQueueState extends OperationQueueState {
  const factory _OperationQueueState(
      {final List<QueueableOperation> pendingOperations,
      final List<QueueableOperation> failedOperations,
      final bool isProcessing,
      final int pendingCount,
      final int failedCount}) = _$OperationQueueStateImpl;
  const _OperationQueueState._() : super._();

  /// List of pending operations waiting to be processed
  @override
  List<QueueableOperation> get pendingOperations;

  /// List of failed operations that exceeded max retries
  @override
  List<QueueableOperation> get failedOperations;

  /// Whether the queue is currently processing operations
  @override
  bool get isProcessing;

  /// Count of pending operations
  @override
  int get pendingCount;

  /// Count of failed operations
  @override
  int get failedCount;

  /// Create a copy of OperationQueueState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OperationQueueStateImplCopyWith<_$OperationQueueStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
