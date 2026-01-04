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
  List<QueueableOperation> get pendingOperations => throw _privateConstructorUsedError;
  List<QueueableOperation> get failedOperations => throw _privateConstructorUsedError;
  bool get isProcessing => throw _privateConstructorUsedError;
  int get pendingCount => throw _privateConstructorUsedError;
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
  factory _$$OperationQueueStateImplCopyWith(
          _$OperationQueueStateImpl value, $Res Function(_$OperationQueueStateImpl) then) =
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
  __$$OperationQueueStateImplCopyWithImpl(
      _$OperationQueueStateImpl _value, $Res Function(_$OperationQueueStateImpl) _then)
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
    ));
  }
}

/// @nodoc
class _$OperationQueueStateImpl implements _OperationQueueState {
  const _$OperationQueueStateImpl(
      {required this.pendingOperations,
      required this.failedOperations,
      required this.isProcessing,
      required this.pendingCount,
      required this.failedCount});

  @override
  final List<QueueableOperation> pendingOperations;
  @override
  final List<QueueableOperation> failedOperations;
  @override
  final bool isProcessing;
  @override
  final int pendingCount;
  @override
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
            (identical(other.pendingOperations, pendingOperations) ||
                other.pendingOperations == pendingOperations) &&
            (identical(other.failedOperations, failedOperations) ||
                other.failedOperations == failedOperations) &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.pendingCount, pendingCount) ||
                other.pendingCount == pendingCount) &&
            (identical(other.failedCount, failedCount) ||
                other.failedCount == failedCount));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, pendingOperations, failedOperations, isProcessing, pendingCount, failedCount);

  /// Create a copy of OperationQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OperationQueueStateImplCopyWith<_$OperationQueueStateImpl> get copyWith =>
      __$$OperationQueueStateImplCopyWithImpl<_$OperationQueueStateImpl>(this, _$identity);
}

abstract class _OperationQueueState implements OperationQueueState {
  const factory _OperationQueueState(
      {required final List<QueueableOperation> pendingOperations,
      required final List<QueueableOperation> failedOperations,
      required final bool isProcessing,
      required final int pendingCount,
      required final int failedCount}) = _$OperationQueueStateImpl;

  @override
  List<QueueableOperation> get pendingOperations;
  @override
  List<QueueableOperation> get failedOperations;
  @override
  bool get isProcessing;
  @override
  int get pendingCount;
  @override
  int get failedCount;

  /// Create a copy of OperationQueueState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OperationQueueStateImplCopyWith<_$OperationQueueStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
