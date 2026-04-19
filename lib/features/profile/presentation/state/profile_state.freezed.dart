// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileState {
  /// The user profile data
  Profile? get profile;

  /// Whether there are unsaved changes in the edit form
  bool get hasChanges;

  /// Pending field changes waiting to be saved
  Map<String, dynamic>? get pendingChanges;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileStateCopyWith<ProfileState> get copyWith =>
      _$ProfileStateCopyWithImpl<ProfileState>(
          this as ProfileState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileState &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.hasChanges, hasChanges) ||
                other.hasChanges == hasChanges) &&
            const DeepCollectionEquality()
                .equals(other.pendingChanges, pendingChanges));
  }

  @override
  int get hashCode => Object.hash(runtimeType, profile, hasChanges,
      const DeepCollectionEquality().hash(pendingChanges));

  @override
  String toString() {
    return 'ProfileState(profile: $profile, hasChanges: $hasChanges, pendingChanges: $pendingChanges)';
  }
}

/// @nodoc
abstract mixin class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
          ProfileState value, $Res Function(ProfileState) _then) =
      _$ProfileStateCopyWithImpl;
  @useResult
  $Res call(
      {Profile? profile,
      bool hasChanges,
      Map<String, dynamic>? pendingChanges});
}

/// @nodoc
class _$ProfileStateCopyWithImpl<$Res> implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._self, this._then);

  final ProfileState _self;
  final $Res Function(ProfileState) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profile = freezed,
    Object? hasChanges = null,
    Object? pendingChanges = freezed,
  }) {
    return _then(_self.copyWith(
      profile: freezed == profile
          ? _self.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as Profile?,
      hasChanges: null == hasChanges
          ? _self.hasChanges
          : hasChanges // ignore: cast_nullable_to_non_nullable
              as bool,
      pendingChanges: freezed == pendingChanges
          ? _self.pendingChanges
          : pendingChanges // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns on ProfileState {
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
    TResult Function(_ProfileState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileState() when $default != null:
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
    TResult Function(_ProfileState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileState():
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
    TResult? Function(_ProfileState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileState() when $default != null:
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
    TResult Function(Profile? profile, bool hasChanges,
            Map<String, dynamic>? pendingChanges)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileState() when $default != null:
        return $default(_that.profile, _that.hasChanges, _that.pendingChanges);
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
    TResult Function(Profile? profile, bool hasChanges,
            Map<String, dynamic>? pendingChanges)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileState():
        return $default(_that.profile, _that.hasChanges, _that.pendingChanges);
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
    TResult? Function(Profile? profile, bool hasChanges,
            Map<String, dynamic>? pendingChanges)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileState() when $default != null:
        return $default(_that.profile, _that.hasChanges, _that.pendingChanges);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ProfileState extends ProfileState {
  const _ProfileState(
      {this.profile,
      this.hasChanges = false,
      final Map<String, dynamic>? pendingChanges})
      : _pendingChanges = pendingChanges,
        super._();

  /// The user profile data
  @override
  final Profile? profile;

  /// Whether there are unsaved changes in the edit form
  @override
  @JsonKey()
  final bool hasChanges;

  /// Pending field changes waiting to be saved
  final Map<String, dynamic>? _pendingChanges;

  /// Pending field changes waiting to be saved
  @override
  Map<String, dynamic>? get pendingChanges {
    final value = _pendingChanges;
    if (value == null) return null;
    if (_pendingChanges is EqualUnmodifiableMapView) return _pendingChanges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProfileStateCopyWith<_ProfileState> get copyWith =>
      __$ProfileStateCopyWithImpl<_ProfileState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProfileState &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.hasChanges, hasChanges) ||
                other.hasChanges == hasChanges) &&
            const DeepCollectionEquality()
                .equals(other._pendingChanges, _pendingChanges));
  }

  @override
  int get hashCode => Object.hash(runtimeType, profile, hasChanges,
      const DeepCollectionEquality().hash(_pendingChanges));

  @override
  String toString() {
    return 'ProfileState(profile: $profile, hasChanges: $hasChanges, pendingChanges: $pendingChanges)';
  }
}

/// @nodoc
abstract mixin class _$ProfileStateCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateCopyWith(
          _ProfileState value, $Res Function(_ProfileState) _then) =
      __$ProfileStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Profile? profile,
      bool hasChanges,
      Map<String, dynamic>? pendingChanges});
}

/// @nodoc
class __$ProfileStateCopyWithImpl<$Res>
    implements _$ProfileStateCopyWith<$Res> {
  __$ProfileStateCopyWithImpl(this._self, this._then);

  final _ProfileState _self;
  final $Res Function(_ProfileState) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? profile = freezed,
    Object? hasChanges = null,
    Object? pendingChanges = freezed,
  }) {
    return _then(_ProfileState(
      profile: freezed == profile
          ? _self.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as Profile?,
      hasChanges: null == hasChanges
          ? _self.hasChanges
          : hasChanges // ignore: cast_nullable_to_non_nullable
              as bool,
      pendingChanges: freezed == pendingChanges
          ? _self._pendingChanges
          : pendingChanges // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

// dart format on
