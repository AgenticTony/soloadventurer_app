// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CheckInState {
  /// Loading indicator - always a field on State
  bool get isLoading => throw _privateConstructorUsedError;

  /// Whether a check-in creation is in progress
  bool get isCreating => throw _privateConstructorUsedError;

  /// Whether a check-in completion is in progress
  bool get isCompleting => throw _privateConstructorUsedError;

  /// Whether a check-in cancellation is in progress
  bool get isCancelling => throw _privateConstructorUsedError;

  /// List of all check-ins
  List<CheckIn> get checkIns => throw _privateConstructorUsedError;

  /// List of upcoming (scheduled/active) check-ins
  List<CheckIn> get upcomingCheckIns => throw _privateConstructorUsedError;

  /// Currently selected check-in (for viewing/editing)
  CheckIn? get selectedCheckIn => throw _privateConstructorUsedError;

  /// Error message - always a field on State
  String? get error => throw _privateConstructorUsedError;

  /// Whether there are any upcoming check-ins (was a getter, now a field)
  bool get hasUpcomingCheckIns => throw _privateConstructorUsedError;

  /// Whether operations are in progress (was a getter, now a field)
  bool get isProcessing => throw _privateConstructorUsedError;

  /// Count of check-ins due within the next hour (was a getter, now a field)
  int get dueSoonCount => throw _privateConstructorUsedError;

  /// Count of missed check-ins (was a getter, now a field)
  int get missedCount => throw _privateConstructorUsedError;

  /// Next check-in (if any) - was a getter, now a field
  CheckIn? get nextCheckIn => throw _privateConstructorUsedError;

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckInStateCopyWith<CheckInState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInStateCopyWith<$Res> {
  factory $CheckInStateCopyWith(
          CheckInState value, $Res Function(CheckInState) then) =
      _$CheckInStateCopyWithImpl<$Res, CheckInState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isCreating,
      bool isCompleting,
      bool isCancelling,
      List<CheckIn> checkIns,
      List<CheckIn> upcomingCheckIns,
      CheckIn? selectedCheckIn,
      String? error,
      bool hasUpcomingCheckIns,
      bool isProcessing,
      int dueSoonCount,
      int missedCount,
      CheckIn? nextCheckIn});

  $CheckInCopyWith<$Res>? get selectedCheckIn;
  $CheckInCopyWith<$Res>? get nextCheckIn;
}

/// @nodoc
class _$CheckInStateCopyWithImpl<$Res, $Val extends CheckInState>
    implements $CheckInStateCopyWith<$Res> {
  _$CheckInStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isCreating = null,
    Object? isCompleting = null,
    Object? isCancelling = null,
    Object? checkIns = null,
    Object? upcomingCheckIns = null,
    Object? selectedCheckIn = freezed,
    Object? error = freezed,
    Object? hasUpcomingCheckIns = null,
    Object? isProcessing = null,
    Object? dueSoonCount = null,
    Object? missedCount = null,
    Object? nextCheckIn = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCreating: null == isCreating
          ? _value.isCreating
          : isCreating // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleting: null == isCompleting
          ? _value.isCompleting
          : isCompleting // ignore: cast_nullable_to_non_nullable
              as bool,
      isCancelling: null == isCancelling
          ? _value.isCancelling
          : isCancelling // ignore: cast_nullable_to_non_nullable
              as bool,
      checkIns: null == checkIns
          ? _value.checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      upcomingCheckIns: null == upcomingCheckIns
          ? _value.upcomingCheckIns
          : upcomingCheckIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      selectedCheckIn: freezed == selectedCheckIn
          ? _value.selectedCheckIn
          : selectedCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      hasUpcomingCheckIns: null == hasUpcomingCheckIns
          ? _value.hasUpcomingCheckIns
          : hasUpcomingCheckIns // ignore: cast_nullable_to_non_nullable
              as bool,
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      dueSoonCount: null == dueSoonCount
          ? _value.dueSoonCount
          : dueSoonCount // ignore: cast_nullable_to_non_nullable
              as int,
      missedCount: null == missedCount
          ? _value.missedCount
          : missedCount // ignore: cast_nullable_to_non_nullable
              as int,
      nextCheckIn: freezed == nextCheckIn
          ? _value.nextCheckIn
          : nextCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
    ) as $Val);
  }

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInCopyWith<$Res>? get selectedCheckIn {
    if (_value.selectedCheckIn == null) {
      return null;
    }

    return $CheckInCopyWith<$Res>(_value.selectedCheckIn!, (value) {
      return _then(_value.copyWith(selectedCheckIn: value) as $Val);
    });
  }

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInCopyWith<$Res>? get nextCheckIn {
    if (_value.nextCheckIn == null) {
      return null;
    }

    return $CheckInCopyWith<$Res>(_value.nextCheckIn!, (value) {
      return _then(_value.copyWith(nextCheckIn: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CheckInStateImplCopyWith<$Res>
    implements $CheckInStateCopyWith<$Res> {
  factory _$$CheckInStateImplCopyWith(
          _$CheckInStateImpl value, $Res Function(_$CheckInStateImpl) then) =
      __$$CheckInStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isCreating,
      bool isCompleting,
      bool isCancelling,
      List<CheckIn> checkIns,
      List<CheckIn> upcomingCheckIns,
      CheckIn? selectedCheckIn,
      String? error,
      bool hasUpcomingCheckIns,
      bool isProcessing,
      int dueSoonCount,
      int missedCount,
      CheckIn? nextCheckIn});

  @override
  $CheckInCopyWith<$Res>? get selectedCheckIn;
  @override
  $CheckInCopyWith<$Res>? get nextCheckIn;
}

/// @nodoc
class __$$CheckInStateImplCopyWithImpl<$Res>
    extends _$CheckInStateCopyWithImpl<$Res, _$CheckInStateImpl>
    implements _$$CheckInStateImplCopyWith<$Res> {
  __$$CheckInStateImplCopyWithImpl(
      _$CheckInStateImpl _value, $Res Function(_$CheckInStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isCreating = null,
    Object? isCompleting = null,
    Object? isCancelling = null,
    Object? checkIns = null,
    Object? upcomingCheckIns = null,
    Object? selectedCheckIn = freezed,
    Object? error = freezed,
    Object? hasUpcomingCheckIns = null,
    Object? isProcessing = null,
    Object? dueSoonCount = null,
    Object? missedCount = null,
    Object? nextCheckIn = freezed,
  }) {
    return _then(_$CheckInStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCreating: null == isCreating
          ? _value.isCreating
          : isCreating // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleting: null == isCompleting
          ? _value.isCompleting
          : isCompleting // ignore: cast_nullable_to_non_nullable
              as bool,
      isCancelling: null == isCancelling
          ? _value.isCancelling
          : isCancelling // ignore: cast_nullable_to_non_nullable
              as bool,
      checkIns: null == checkIns
          ? _value._checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      upcomingCheckIns: null == upcomingCheckIns
          ? _value._upcomingCheckIns
          : upcomingCheckIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      selectedCheckIn: freezed == selectedCheckIn
          ? _value.selectedCheckIn
          : selectedCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      hasUpcomingCheckIns: null == hasUpcomingCheckIns
          ? _value.hasUpcomingCheckIns
          : hasUpcomingCheckIns // ignore: cast_nullable_to_non_nullable
              as bool,
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      dueSoonCount: null == dueSoonCount
          ? _value.dueSoonCount
          : dueSoonCount // ignore: cast_nullable_to_non_nullable
              as int,
      missedCount: null == missedCount
          ? _value.missedCount
          : missedCount // ignore: cast_nullable_to_non_nullable
              as int,
      nextCheckIn: freezed == nextCheckIn
          ? _value.nextCheckIn
          : nextCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
    ));
  }
}

/// @nodoc

class _$CheckInStateImpl extends _CheckInState {
  const _$CheckInStateImpl(
      {this.isLoading = false,
      this.isCreating = false,
      this.isCompleting = false,
      this.isCancelling = false,
      final List<CheckIn> checkIns = const [],
      final List<CheckIn> upcomingCheckIns = const [],
      this.selectedCheckIn,
      this.error,
      this.hasUpcomingCheckIns = false,
      this.isProcessing = false,
      this.dueSoonCount = 0,
      this.missedCount = 0,
      this.nextCheckIn})
      : _checkIns = checkIns,
        _upcomingCheckIns = upcomingCheckIns,
        super._();

  /// Loading indicator - always a field on State
  @override
  @JsonKey()
  final bool isLoading;

  /// Whether a check-in creation is in progress
  @override
  @JsonKey()
  final bool isCreating;

  /// Whether a check-in completion is in progress
  @override
  @JsonKey()
  final bool isCompleting;

  /// Whether a check-in cancellation is in progress
  @override
  @JsonKey()
  final bool isCancelling;

  /// List of all check-ins
  final List<CheckIn> _checkIns;

  /// List of all check-ins
  @override
  @JsonKey()
  List<CheckIn> get checkIns {
    if (_checkIns is EqualUnmodifiableListView) return _checkIns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_checkIns);
  }

  /// List of upcoming (scheduled/active) check-ins
  final List<CheckIn> _upcomingCheckIns;

  /// List of upcoming (scheduled/active) check-ins
  @override
  @JsonKey()
  List<CheckIn> get upcomingCheckIns {
    if (_upcomingCheckIns is EqualUnmodifiableListView)
      return _upcomingCheckIns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_upcomingCheckIns);
  }

  /// Currently selected check-in (for viewing/editing)
  @override
  final CheckIn? selectedCheckIn;

  /// Error message - always a field on State
  @override
  final String? error;

  /// Whether there are any upcoming check-ins (was a getter, now a field)
  @override
  @JsonKey()
  final bool hasUpcomingCheckIns;

  /// Whether operations are in progress (was a getter, now a field)
  @override
  @JsonKey()
  final bool isProcessing;

  /// Count of check-ins due within the next hour (was a getter, now a field)
  @override
  @JsonKey()
  final int dueSoonCount;

  /// Count of missed check-ins (was a getter, now a field)
  @override
  @JsonKey()
  final int missedCount;

  /// Next check-in (if any) - was a getter, now a field
  @override
  final CheckIn? nextCheckIn;

  @override
  String toString() {
    return 'CheckInState(isLoading: $isLoading, isCreating: $isCreating, isCompleting: $isCompleting, isCancelling: $isCancelling, checkIns: $checkIns, upcomingCheckIns: $upcomingCheckIns, selectedCheckIn: $selectedCheckIn, error: $error, hasUpcomingCheckIns: $hasUpcomingCheckIns, isProcessing: $isProcessing, dueSoonCount: $dueSoonCount, missedCount: $missedCount, nextCheckIn: $nextCheckIn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isCreating, isCreating) ||
                other.isCreating == isCreating) &&
            (identical(other.isCompleting, isCompleting) ||
                other.isCompleting == isCompleting) &&
            (identical(other.isCancelling, isCancelling) ||
                other.isCancelling == isCancelling) &&
            const DeepCollectionEquality().equals(other._checkIns, _checkIns) &&
            const DeepCollectionEquality()
                .equals(other._upcomingCheckIns, _upcomingCheckIns) &&
            (identical(other.selectedCheckIn, selectedCheckIn) ||
                other.selectedCheckIn == selectedCheckIn) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.hasUpcomingCheckIns, hasUpcomingCheckIns) ||
                other.hasUpcomingCheckIns == hasUpcomingCheckIns) &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.dueSoonCount, dueSoonCount) ||
                other.dueSoonCount == dueSoonCount) &&
            (identical(other.missedCount, missedCount) ||
                other.missedCount == missedCount) &&
            (identical(other.nextCheckIn, nextCheckIn) ||
                other.nextCheckIn == nextCheckIn));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isCreating,
      isCompleting,
      isCancelling,
      const DeepCollectionEquality().hash(_checkIns),
      const DeepCollectionEquality().hash(_upcomingCheckIns),
      selectedCheckIn,
      error,
      hasUpcomingCheckIns,
      isProcessing,
      dueSoonCount,
      missedCount,
      nextCheckIn);

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInStateImplCopyWith<_$CheckInStateImpl> get copyWith =>
      __$$CheckInStateImplCopyWithImpl<_$CheckInStateImpl>(this, _$identity);
}

abstract class _CheckInState extends CheckInState {
  const factory _CheckInState(
      {final bool isLoading,
      final bool isCreating,
      final bool isCompleting,
      final bool isCancelling,
      final List<CheckIn> checkIns,
      final List<CheckIn> upcomingCheckIns,
      final CheckIn? selectedCheckIn,
      final String? error,
      final bool hasUpcomingCheckIns,
      final bool isProcessing,
      final int dueSoonCount,
      final int missedCount,
      final CheckIn? nextCheckIn}) = _$CheckInStateImpl;
  const _CheckInState._() : super._();

  /// Loading indicator - always a field on State
  @override
  bool get isLoading;

  /// Whether a check-in creation is in progress
  @override
  bool get isCreating;

  /// Whether a check-in completion is in progress
  @override
  bool get isCompleting;

  /// Whether a check-in cancellation is in progress
  @override
  bool get isCancelling;

  /// List of all check-ins
  @override
  List<CheckIn> get checkIns;

  /// List of upcoming (scheduled/active) check-ins
  @override
  List<CheckIn> get upcomingCheckIns;

  /// Currently selected check-in (for viewing/editing)
  @override
  CheckIn? get selectedCheckIn;

  /// Error message - always a field on State
  @override
  String? get error;

  /// Whether there are any upcoming check-ins (was a getter, now a field)
  @override
  bool get hasUpcomingCheckIns;

  /// Whether operations are in progress (was a getter, now a field)
  @override
  bool get isProcessing;

  /// Count of check-ins due within the next hour (was a getter, now a field)
  @override
  int get dueSoonCount;

  /// Count of missed check-ins (was a getter, now a field)
  @override
  int get missedCount;

  /// Next check-in (if any) - was a getter, now a field
  @override
  CheckIn? get nextCheckIn;

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckInStateImplCopyWith<_$CheckInStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
