// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileModel {
  String get id;
  String get displayName;
  String? get bio;
  String? get avatarUrl;
  bool get isPublic;
  List<String> get interests;
  Map<String, String> get preferences;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileModelCopyWith<ProfileModel> get copyWith =>
      _$ProfileModelCopyWithImpl<ProfileModel>(
          this as ProfileModel, _$identity);

  /// Serializes this ProfileModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            const DeepCollectionEquality().equals(other.interests, interests) &&
            const DeepCollectionEquality()
                .equals(other.preferences, preferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      displayName,
      bio,
      avatarUrl,
      isPublic,
      const DeepCollectionEquality().hash(interests),
      const DeepCollectionEquality().hash(preferences));

  @override
  String toString() {
    return 'ProfileModel(id: $id, displayName: $displayName, bio: $bio, avatarUrl: $avatarUrl, isPublic: $isPublic, interests: $interests, preferences: $preferences)';
  }
}

/// @nodoc
abstract mixin class $ProfileModelCopyWith<$Res> {
  factory $ProfileModelCopyWith(
          ProfileModel value, $Res Function(ProfileModel) _then) =
      _$ProfileModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String displayName,
      String? bio,
      String? avatarUrl,
      bool isPublic,
      List<String> interests,
      Map<String, String> preferences});
}

/// @nodoc
class _$ProfileModelCopyWithImpl<$Res> implements $ProfileModelCopyWith<$Res> {
  _$ProfileModelCopyWithImpl(this._self, this._then);

  final ProfileModel _self;
  final $Res Function(ProfileModel) _then;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? bio = freezed,
    Object? avatarUrl = freezed,
    Object? isPublic = null,
    Object? interests = null,
    Object? preferences = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      bio: freezed == bio
          ? _self.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublic: null == isPublic
          ? _self.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      interests: null == interests
          ? _self.interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferences: null == preferences
          ? _self.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ProfileModel implements ProfileModel {
  const _ProfileModel(
      {required this.id,
      required this.displayName,
      this.bio,
      this.avatarUrl,
      this.isPublic = false,
      final List<String> interests = const [],
      final Map<String, String> preferences = const {}})
      : _interests = interests,
        _preferences = preferences;
  factory _ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  @override
  final String id;
  @override
  final String displayName;
  @override
  final String? bio;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool isPublic;
  final List<String> _interests;
  @override
  @JsonKey()
  List<String> get interests {
    if (_interests is EqualUnmodifiableListView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interests);
  }

  final Map<String, String> _preferences;
  @override
  @JsonKey()
  Map<String, String> get preferences {
    if (_preferences is EqualUnmodifiableMapView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_preferences);
  }

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProfileModelCopyWith<_ProfileModel> get copyWith =>
      __$ProfileModelCopyWithImpl<_ProfileModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProfileModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProfileModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            const DeepCollectionEquality()
                .equals(other._interests, _interests) &&
            const DeepCollectionEquality()
                .equals(other._preferences, _preferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      displayName,
      bio,
      avatarUrl,
      isPublic,
      const DeepCollectionEquality().hash(_interests),
      const DeepCollectionEquality().hash(_preferences));

  @override
  String toString() {
    return 'ProfileModel(id: $id, displayName: $displayName, bio: $bio, avatarUrl: $avatarUrl, isPublic: $isPublic, interests: $interests, preferences: $preferences)';
  }
}

/// @nodoc
abstract mixin class _$ProfileModelCopyWith<$Res>
    implements $ProfileModelCopyWith<$Res> {
  factory _$ProfileModelCopyWith(
          _ProfileModel value, $Res Function(_ProfileModel) _then) =
      __$ProfileModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String displayName,
      String? bio,
      String? avatarUrl,
      bool isPublic,
      List<String> interests,
      Map<String, String> preferences});
}

/// @nodoc
class __$ProfileModelCopyWithImpl<$Res>
    implements _$ProfileModelCopyWith<$Res> {
  __$ProfileModelCopyWithImpl(this._self, this._then);

  final _ProfileModel _self;
  final $Res Function(_ProfileModel) _then;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? bio = freezed,
    Object? avatarUrl = freezed,
    Object? isPublic = null,
    Object? interests = null,
    Object? preferences = null,
  }) {
    return _then(_ProfileModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      bio: freezed == bio
          ? _self.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublic: null == isPublic
          ? _self.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      interests: null == interests
          ? _self._interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferences: null == preferences
          ? _self._preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

// dart format on
