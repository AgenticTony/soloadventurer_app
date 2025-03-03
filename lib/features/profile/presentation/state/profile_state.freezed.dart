// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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
  bool get isLoading;
  bool get isUpdating;
  bool get isUploading;
  Profile? get profile;
  String? get error;
  bool get hasChanges;
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
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.isUploading, isUploading) ||
                other.isUploading == isUploading) &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.hasChanges, hasChanges) ||
                other.hasChanges == hasChanges) &&
            const DeepCollectionEquality()
                .equals(other.pendingChanges, pendingChanges));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isUpdating,
      isUploading,
      profile,
      error,
      hasChanges,
      const DeepCollectionEquality().hash(pendingChanges));

  @override
  String toString() {
    return 'ProfileState(isLoading: $isLoading, isUpdating: $isUpdating, isUploading: $isUploading, profile: $profile, error: $error, hasChanges: $hasChanges, pendingChanges: $pendingChanges)';
  }
}

/// @nodoc
abstract mixin class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
          ProfileState value, $Res Function(ProfileState) _then) =
      _$ProfileStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      bool isUpdating,
      bool isUploading,
      Profile? profile,
      String? error,
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
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? isUploading = null,
    Object? profile = freezed,
    Object? error = freezed,
    Object? hasChanges = null,
    Object? pendingChanges = freezed,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      isUploading: null == isUploading
          ? _self.isUploading
          : isUploading // ignore: cast_nullable_to_non_nullable
              as bool,
      profile: freezed == profile
          ? _self.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as Profile?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
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

/// @nodoc

class _ProfileState extends ProfileState {
  const _ProfileState(
      {this.isLoading = false,
      this.isUpdating = false,
      this.isUploading = false,
      this.profile,
      this.error,
      this.hasChanges = false,
      final Map<String, dynamic>? pendingChanges})
      : _pendingChanges = pendingChanges,
        super._();

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isUpdating;
  @override
  @JsonKey()
  final bool isUploading;
  @override
  final Profile? profile;
  @override
  final String? error;
  @override
  @JsonKey()
  final bool hasChanges;
  final Map<String, dynamic>? _pendingChanges;
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
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.isUploading, isUploading) ||
                other.isUploading == isUploading) &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.hasChanges, hasChanges) ||
                other.hasChanges == hasChanges) &&
            const DeepCollectionEquality()
                .equals(other._pendingChanges, _pendingChanges));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isUpdating,
      isUploading,
      profile,
      error,
      hasChanges,
      const DeepCollectionEquality().hash(_pendingChanges));

  @override
  String toString() {
    return 'ProfileState(isLoading: $isLoading, isUpdating: $isUpdating, isUploading: $isUploading, profile: $profile, error: $error, hasChanges: $hasChanges, pendingChanges: $pendingChanges)';
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
      {bool isLoading,
      bool isUpdating,
      bool isUploading,
      Profile? profile,
      String? error,
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
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? isUploading = null,
    Object? profile = freezed,
    Object? error = freezed,
    Object? hasChanges = null,
    Object? pendingChanges = freezed,
  }) {
    return _then(_ProfileState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      isUploading: null == isUploading
          ? _self.isUploading
          : isUploading // ignore: cast_nullable_to_non_nullable
              as bool,
      profile: freezed == profile
          ? _self.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as Profile?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
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
