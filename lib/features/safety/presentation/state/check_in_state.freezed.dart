// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckInState {
  /// Loading indicator - always a field on State
  bool get isLoading;

  /// Whether a check-in creation is in progress
  bool get isCreating;

  /// Whether a check-in completion is in progress
  bool get isCompleting;

  /// Whether a check-in cancellation is in progress
  bool get isCancelling;

  /// List of all check-ins
  List<CheckIn> get checkIns;

  /// List of upcoming (scheduled/active) check-ins
  List<CheckIn> get upcomingCheckIns;

  /// Currently selected check-in (for viewing/editing)
  CheckIn? get selectedCheckIn;

  /// Error message - always a field on State
  String? get error;

  /// Whether there are any upcoming check-ins (was a getter, now a field)
  bool get hasUpcomingCheckIns;

  /// Whether operations are in progress (was a getter, now a field)
  bool get isProcessing;

  /// Count of check-ins due within the next hour (was a getter, now a field)
  int get dueSoonCount;

  /// Count of missed check-ins (was a getter, now a field)
  int get missedCount;

  /// Next check-in (if any) - was a getter, now a field
  CheckIn? get nextCheckIn;

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CheckInStateCopyWith<CheckInState> get copyWith =>
      _$CheckInStateCopyWithImpl<CheckInState>(
          this as CheckInState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CheckInState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isCreating, isCreating) ||
                other.isCreating == isCreating) &&
            (identical(other.isCompleting, isCompleting) ||
                other.isCompleting == isCompleting) &&
            (identical(other.isCancelling, isCancelling) ||
                other.isCancelling == isCancelling) &&
            const DeepCollectionEquality().equals(other.checkIns, checkIns) &&
            const DeepCollectionEquality()
                .equals(other.upcomingCheckIns, upcomingCheckIns) &&
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
      const DeepCollectionEquality().hash(checkIns),
      const DeepCollectionEquality().hash(upcomingCheckIns),
      selectedCheckIn,
      error,
      hasUpcomingCheckIns,
      isProcessing,
      dueSoonCount,
      missedCount,
      nextCheckIn);

  @override
  String toString() {
    return 'CheckInState(isLoading: $isLoading, isCreating: $isCreating, isCompleting: $isCompleting, isCancelling: $isCancelling, checkIns: $checkIns, upcomingCheckIns: $upcomingCheckIns, selectedCheckIn: $selectedCheckIn, error: $error, hasUpcomingCheckIns: $hasUpcomingCheckIns, isProcessing: $isProcessing, dueSoonCount: $dueSoonCount, missedCount: $missedCount, nextCheckIn: $nextCheckIn)';
  }
}

/// @nodoc
abstract mixin class $CheckInStateCopyWith<$Res> {
  factory $CheckInStateCopyWith(
          CheckInState value, $Res Function(CheckInState) _then) =
      _$CheckInStateCopyWithImpl;
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
class _$CheckInStateCopyWithImpl<$Res> implements $CheckInStateCopyWith<$Res> {
  _$CheckInStateCopyWithImpl(this._self, this._then);

  final CheckInState _self;
  final $Res Function(CheckInState) _then;

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
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCreating: null == isCreating
          ? _self.isCreating
          : isCreating // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleting: null == isCompleting
          ? _self.isCompleting
          : isCompleting // ignore: cast_nullable_to_non_nullable
              as bool,
      isCancelling: null == isCancelling
          ? _self.isCancelling
          : isCancelling // ignore: cast_nullable_to_non_nullable
              as bool,
      checkIns: null == checkIns
          ? _self.checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      upcomingCheckIns: null == upcomingCheckIns
          ? _self.upcomingCheckIns
          : upcomingCheckIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      selectedCheckIn: freezed == selectedCheckIn
          ? _self.selectedCheckIn
          : selectedCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      hasUpcomingCheckIns: null == hasUpcomingCheckIns
          ? _self.hasUpcomingCheckIns
          : hasUpcomingCheckIns // ignore: cast_nullable_to_non_nullable
              as bool,
      isProcessing: null == isProcessing
          ? _self.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      dueSoonCount: null == dueSoonCount
          ? _self.dueSoonCount
          : dueSoonCount // ignore: cast_nullable_to_non_nullable
              as int,
      missedCount: null == missedCount
          ? _self.missedCount
          : missedCount // ignore: cast_nullable_to_non_nullable
              as int,
      nextCheckIn: freezed == nextCheckIn
          ? _self.nextCheckIn
          : nextCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
    ));
  }

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInCopyWith<$Res>? get selectedCheckIn {
    if (_self.selectedCheckIn == null) {
      return null;
    }

    return $CheckInCopyWith<$Res>(_self.selectedCheckIn!, (value) {
      return _then(_self.copyWith(selectedCheckIn: value));
    });
  }

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInCopyWith<$Res>? get nextCheckIn {
    if (_self.nextCheckIn == null) {
      return null;
    }

    return $CheckInCopyWith<$Res>(_self.nextCheckIn!, (value) {
      return _then(_self.copyWith(nextCheckIn: value));
    });
  }
}

/// Adds pattern-matching-related methods to [CheckInState].
extension CheckInStatePatterns on CheckInState {
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
    TResult Function(_CheckInState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckInState() when $default != null:
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
    TResult Function(_CheckInState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInState():
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
    TResult? Function(_CheckInState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInState() when $default != null:
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
            bool isLoading,
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
            CheckIn? nextCheckIn)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckInState() when $default != null:
        return $default(
            _that.isLoading,
            _that.isCreating,
            _that.isCompleting,
            _that.isCancelling,
            _that.checkIns,
            _that.upcomingCheckIns,
            _that.selectedCheckIn,
            _that.error,
            _that.hasUpcomingCheckIns,
            _that.isProcessing,
            _that.dueSoonCount,
            _that.missedCount,
            _that.nextCheckIn);
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
            bool isLoading,
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
            CheckIn? nextCheckIn)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInState():
        return $default(
            _that.isLoading,
            _that.isCreating,
            _that.isCompleting,
            _that.isCancelling,
            _that.checkIns,
            _that.upcomingCheckIns,
            _that.selectedCheckIn,
            _that.error,
            _that.hasUpcomingCheckIns,
            _that.isProcessing,
            _that.dueSoonCount,
            _that.missedCount,
            _that.nextCheckIn);
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
            bool isLoading,
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
            CheckIn? nextCheckIn)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInState() when $default != null:
        return $default(
            _that.isLoading,
            _that.isCreating,
            _that.isCompleting,
            _that.isCancelling,
            _that.checkIns,
            _that.upcomingCheckIns,
            _that.selectedCheckIn,
            _that.error,
            _that.hasUpcomingCheckIns,
            _that.isProcessing,
            _that.dueSoonCount,
            _that.missedCount,
            _that.nextCheckIn);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CheckInState implements CheckInState {
  const _CheckInState(
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
        _upcomingCheckIns = upcomingCheckIns;

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

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CheckInStateCopyWith<_CheckInState> get copyWith =>
      __$CheckInStateCopyWithImpl<_CheckInState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CheckInState &&
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

  @override
  String toString() {
    return 'CheckInState(isLoading: $isLoading, isCreating: $isCreating, isCompleting: $isCompleting, isCancelling: $isCancelling, checkIns: $checkIns, upcomingCheckIns: $upcomingCheckIns, selectedCheckIn: $selectedCheckIn, error: $error, hasUpcomingCheckIns: $hasUpcomingCheckIns, isProcessing: $isProcessing, dueSoonCount: $dueSoonCount, missedCount: $missedCount, nextCheckIn: $nextCheckIn)';
  }
}

/// @nodoc
abstract mixin class _$CheckInStateCopyWith<$Res>
    implements $CheckInStateCopyWith<$Res> {
  factory _$CheckInStateCopyWith(
          _CheckInState value, $Res Function(_CheckInState) _then) =
      __$CheckInStateCopyWithImpl;
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
class __$CheckInStateCopyWithImpl<$Res>
    implements _$CheckInStateCopyWith<$Res> {
  __$CheckInStateCopyWithImpl(this._self, this._then);

  final _CheckInState _self;
  final $Res Function(_CheckInState) _then;

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_CheckInState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCreating: null == isCreating
          ? _self.isCreating
          : isCreating // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleting: null == isCompleting
          ? _self.isCompleting
          : isCompleting // ignore: cast_nullable_to_non_nullable
              as bool,
      isCancelling: null == isCancelling
          ? _self.isCancelling
          : isCancelling // ignore: cast_nullable_to_non_nullable
              as bool,
      checkIns: null == checkIns
          ? _self._checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      upcomingCheckIns: null == upcomingCheckIns
          ? _self._upcomingCheckIns
          : upcomingCheckIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      selectedCheckIn: freezed == selectedCheckIn
          ? _self.selectedCheckIn
          : selectedCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      hasUpcomingCheckIns: null == hasUpcomingCheckIns
          ? _self.hasUpcomingCheckIns
          : hasUpcomingCheckIns // ignore: cast_nullable_to_non_nullable
              as bool,
      isProcessing: null == isProcessing
          ? _self.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      dueSoonCount: null == dueSoonCount
          ? _self.dueSoonCount
          : dueSoonCount // ignore: cast_nullable_to_non_nullable
              as int,
      missedCount: null == missedCount
          ? _self.missedCount
          : missedCount // ignore: cast_nullable_to_non_nullable
              as int,
      nextCheckIn: freezed == nextCheckIn
          ? _self.nextCheckIn
          : nextCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
    ));
  }

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInCopyWith<$Res>? get selectedCheckIn {
    if (_self.selectedCheckIn == null) {
      return null;
    }

    return $CheckInCopyWith<$Res>(_self.selectedCheckIn!, (value) {
      return _then(_self.copyWith(selectedCheckIn: value));
    });
  }

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInCopyWith<$Res>? get nextCheckIn {
    if (_self.nextCheckIn == null) {
      return null;
    }

    return $CheckInCopyWith<$Res>(_self.nextCheckIn!, (value) {
      return _then(_self.copyWith(nextCheckIn: value));
    });
  }
}

// dart format on
