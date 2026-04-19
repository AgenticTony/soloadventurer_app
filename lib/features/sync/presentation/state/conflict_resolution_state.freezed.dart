// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conflict_resolution_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConflictResolutionState {
  /// List of conflicts waiting to be resolved
  List<ConflictInfo> get pendingConflicts;

  /// Conflict currently being resolved
  ConflictInfo? get activeConflict;

  /// Resolution result when conflict has been resolved
  ConflictResolution? get resolution;

  /// Whether the user cancelled the resolution
  bool get wasCancelled;

  /// Timestamp when resolution was completed
  DateTime? get completedAt;

  /// Create a copy of ConflictResolutionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ConflictResolutionStateCopyWith<ConflictResolutionState> get copyWith =>
      _$ConflictResolutionStateCopyWithImpl<ConflictResolutionState>(
          this as ConflictResolutionState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ConflictResolutionState &&
            const DeepCollectionEquality()
                .equals(other.pendingConflicts, pendingConflicts) &&
            (identical(other.activeConflict, activeConflict) ||
                other.activeConflict == activeConflict) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.wasCancelled, wasCancelled) ||
                other.wasCancelled == wasCancelled) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(pendingConflicts),
      activeConflict,
      resolution,
      wasCancelled,
      completedAt);

  @override
  String toString() {
    return 'ConflictResolutionState(pendingConflicts: $pendingConflicts, activeConflict: $activeConflict, resolution: $resolution, wasCancelled: $wasCancelled, completedAt: $completedAt)';
  }
}

/// @nodoc
abstract mixin class $ConflictResolutionStateCopyWith<$Res> {
  factory $ConflictResolutionStateCopyWith(ConflictResolutionState value,
          $Res Function(ConflictResolutionState) _then) =
      _$ConflictResolutionStateCopyWithImpl;
  @useResult
  $Res call(
      {List<ConflictInfo> pendingConflicts,
      ConflictInfo? activeConflict,
      ConflictResolution? resolution,
      bool wasCancelled,
      DateTime? completedAt});
}

/// @nodoc
class _$ConflictResolutionStateCopyWithImpl<$Res>
    implements $ConflictResolutionStateCopyWith<$Res> {
  _$ConflictResolutionStateCopyWithImpl(this._self, this._then);

  final ConflictResolutionState _self;
  final $Res Function(ConflictResolutionState) _then;

  /// Create a copy of ConflictResolutionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pendingConflicts = null,
    Object? activeConflict = freezed,
    Object? resolution = freezed,
    Object? wasCancelled = null,
    Object? completedAt = freezed,
  }) {
    return _then(_self.copyWith(
      pendingConflicts: null == pendingConflicts
          ? _self.pendingConflicts
          : pendingConflicts // ignore: cast_nullable_to_non_nullable
              as List<ConflictInfo>,
      activeConflict: freezed == activeConflict
          ? _self.activeConflict
          : activeConflict // ignore: cast_nullable_to_non_nullable
              as ConflictInfo?,
      resolution: freezed == resolution
          ? _self.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as ConflictResolution?,
      wasCancelled: null == wasCancelled
          ? _self.wasCancelled
          : wasCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ConflictResolutionState].
extension ConflictResolutionStatePatterns on ConflictResolutionState {
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
    TResult Function(_ConflictResolutionState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConflictResolutionState() when $default != null:
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
    TResult Function(_ConflictResolutionState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConflictResolutionState():
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
    TResult? Function(_ConflictResolutionState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConflictResolutionState() when $default != null:
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
            List<ConflictInfo> pendingConflicts,
            ConflictInfo? activeConflict,
            ConflictResolution? resolution,
            bool wasCancelled,
            DateTime? completedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConflictResolutionState() when $default != null:
        return $default(_that.pendingConflicts, _that.activeConflict,
            _that.resolution, _that.wasCancelled, _that.completedAt);
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
            List<ConflictInfo> pendingConflicts,
            ConflictInfo? activeConflict,
            ConflictResolution? resolution,
            bool wasCancelled,
            DateTime? completedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConflictResolutionState():
        return $default(_that.pendingConflicts, _that.activeConflict,
            _that.resolution, _that.wasCancelled, _that.completedAt);
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
            List<ConflictInfo> pendingConflicts,
            ConflictInfo? activeConflict,
            ConflictResolution? resolution,
            bool wasCancelled,
            DateTime? completedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConflictResolutionState() when $default != null:
        return $default(_that.pendingConflicts, _that.activeConflict,
            _that.resolution, _that.wasCancelled, _that.completedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ConflictResolutionState extends ConflictResolutionState {
  const _ConflictResolutionState(
      {final List<ConflictInfo> pendingConflicts = const [],
      this.activeConflict,
      this.resolution,
      this.wasCancelled = false,
      this.completedAt})
      : _pendingConflicts = pendingConflicts,
        super._();

  /// List of conflicts waiting to be resolved
  final List<ConflictInfo> _pendingConflicts;

  /// List of conflicts waiting to be resolved
  @override
  @JsonKey()
  List<ConflictInfo> get pendingConflicts {
    if (_pendingConflicts is EqualUnmodifiableListView)
      return _pendingConflicts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingConflicts);
  }

  /// Conflict currently being resolved
  @override
  final ConflictInfo? activeConflict;

  /// Resolution result when conflict has been resolved
  @override
  final ConflictResolution? resolution;

  /// Whether the user cancelled the resolution
  @override
  @JsonKey()
  final bool wasCancelled;

  /// Timestamp when resolution was completed
  @override
  final DateTime? completedAt;

  /// Create a copy of ConflictResolutionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ConflictResolutionStateCopyWith<_ConflictResolutionState> get copyWith =>
      __$ConflictResolutionStateCopyWithImpl<_ConflictResolutionState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ConflictResolutionState &&
            const DeepCollectionEquality()
                .equals(other._pendingConflicts, _pendingConflicts) &&
            (identical(other.activeConflict, activeConflict) ||
                other.activeConflict == activeConflict) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.wasCancelled, wasCancelled) ||
                other.wasCancelled == wasCancelled) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_pendingConflicts),
      activeConflict,
      resolution,
      wasCancelled,
      completedAt);

  @override
  String toString() {
    return 'ConflictResolutionState(pendingConflicts: $pendingConflicts, activeConflict: $activeConflict, resolution: $resolution, wasCancelled: $wasCancelled, completedAt: $completedAt)';
  }
}

/// @nodoc
abstract mixin class _$ConflictResolutionStateCopyWith<$Res>
    implements $ConflictResolutionStateCopyWith<$Res> {
  factory _$ConflictResolutionStateCopyWith(_ConflictResolutionState value,
          $Res Function(_ConflictResolutionState) _then) =
      __$ConflictResolutionStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<ConflictInfo> pendingConflicts,
      ConflictInfo? activeConflict,
      ConflictResolution? resolution,
      bool wasCancelled,
      DateTime? completedAt});
}

/// @nodoc
class __$ConflictResolutionStateCopyWithImpl<$Res>
    implements _$ConflictResolutionStateCopyWith<$Res> {
  __$ConflictResolutionStateCopyWithImpl(this._self, this._then);

  final _ConflictResolutionState _self;
  final $Res Function(_ConflictResolutionState) _then;

  /// Create a copy of ConflictResolutionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? pendingConflicts = null,
    Object? activeConflict = freezed,
    Object? resolution = freezed,
    Object? wasCancelled = null,
    Object? completedAt = freezed,
  }) {
    return _then(_ConflictResolutionState(
      pendingConflicts: null == pendingConflicts
          ? _self._pendingConflicts
          : pendingConflicts // ignore: cast_nullable_to_non_nullable
              as List<ConflictInfo>,
      activeConflict: freezed == activeConflict
          ? _self.activeConflict
          : activeConflict // ignore: cast_nullable_to_non_nullable
              as ConflictInfo?,
      resolution: freezed == resolution
          ? _self.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as ConflictResolution?,
      wasCancelled: null == wasCancelled
          ? _self.wasCancelled
          : wasCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
