// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlaceActivity _$PlaceActivityFromJson(Map<String, dynamic> json) {
  return _PlaceActivity.fromJson(json);
}

/// @nodoc
mixin _$PlaceActivity {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  RecommendationCategory get category => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  String? get priceLevel => throw _privateConstructorUsedError;
  double? get cost => throw _privateConstructorUsedError;
  Duration? get estimatedDuration => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<String> get localTips => throw _privateConstructorUsedError;
  String? get bookingUrl => throw _privateConstructorUsedError;
  bool get requiresBooking => throw _privateConstructorUsedError;
  String? get openingHours => throw _privateConstructorUsedError;

  /// Serializes this PlaceActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaceActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceActivityCopyWith<PlaceActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceActivityCopyWith<$Res> {
  factory $PlaceActivityCopyWith(
          PlaceActivity value, $Res Function(PlaceActivity) then) =
      _$PlaceActivityCopyWithImpl<$Res, PlaceActivity>;
  @useResult
  $Res call(
      {String id,
      String name,
      RecommendationCategory category,
      String? description,
      String? location,
      double? latitude,
      double? longitude,
      double rating,
      int reviewCount,
      String? priceLevel,
      double? cost,
      Duration? estimatedDuration,
      List<String> images,
      List<String> tags,
      List<String> localTips,
      String? bookingUrl,
      bool requiresBooking,
      String? openingHours});
}

/// @nodoc
class _$PlaceActivityCopyWithImpl<$Res, $Val extends PlaceActivity>
    implements $PlaceActivityCopyWith<$Res> {
  _$PlaceActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaceActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? description = freezed,
    Object? location = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? rating = null,
    Object? reviewCount = null,
    Object? priceLevel = freezed,
    Object? cost = freezed,
    Object? estimatedDuration = freezed,
    Object? images = null,
    Object? tags = null,
    Object? localTips = null,
    Object? bookingUrl = freezed,
    Object? requiresBooking = null,
    Object? openingHours = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as RecommendationCategory,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      priceLevel: freezed == priceLevel
          ? _value.priceLevel
          : priceLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedDuration: freezed == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as Duration?,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      localTips: null == localTips
          ? _value.localTips
          : localTips // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bookingUrl: freezed == bookingUrl
          ? _value.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      requiresBooking: null == requiresBooking
          ? _value.requiresBooking
          : requiresBooking // ignore: cast_nullable_to_non_nullable
              as bool,
      openingHours: freezed == openingHours
          ? _value.openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaceActivityImplCopyWith<$Res>
    implements $PlaceActivityCopyWith<$Res> {
  factory _$$PlaceActivityImplCopyWith(
          _$PlaceActivityImpl value, $Res Function(_$PlaceActivityImpl) then) =
      __$$PlaceActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      RecommendationCategory category,
      String? description,
      String? location,
      double? latitude,
      double? longitude,
      double rating,
      int reviewCount,
      String? priceLevel,
      double? cost,
      Duration? estimatedDuration,
      List<String> images,
      List<String> tags,
      List<String> localTips,
      String? bookingUrl,
      bool requiresBooking,
      String? openingHours});
}

/// @nodoc
class __$$PlaceActivityImplCopyWithImpl<$Res>
    extends _$PlaceActivityCopyWithImpl<$Res, _$PlaceActivityImpl>
    implements _$$PlaceActivityImplCopyWith<$Res> {
  __$$PlaceActivityImplCopyWithImpl(
      _$PlaceActivityImpl _value, $Res Function(_$PlaceActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlaceActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? description = freezed,
    Object? location = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? rating = null,
    Object? reviewCount = null,
    Object? priceLevel = freezed,
    Object? cost = freezed,
    Object? estimatedDuration = freezed,
    Object? images = null,
    Object? tags = null,
    Object? localTips = null,
    Object? bookingUrl = freezed,
    Object? requiresBooking = null,
    Object? openingHours = freezed,
  }) {
    return _then(_$PlaceActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as RecommendationCategory,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      priceLevel: freezed == priceLevel
          ? _value.priceLevel
          : priceLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedDuration: freezed == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as Duration?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      localTips: null == localTips
          ? _value._localTips
          : localTips // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bookingUrl: freezed == bookingUrl
          ? _value.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      requiresBooking: null == requiresBooking
          ? _value.requiresBooking
          : requiresBooking // ignore: cast_nullable_to_non_nullable
              as bool,
      openingHours: freezed == openingHours
          ? _value.openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceActivityImpl extends _PlaceActivity {
  const _$PlaceActivityImpl(
      {required this.id,
      required this.name,
      required this.category,
      this.description,
      this.location,
      this.latitude,
      this.longitude,
      this.rating = 0.0,
      this.reviewCount = 0,
      this.priceLevel,
      this.cost,
      this.estimatedDuration,
      final List<String> images = const <String>[],
      final List<String> tags = const <String>[],
      final List<String> localTips = const <String>[],
      this.bookingUrl,
      this.requiresBooking = false,
      this.openingHours})
      : _images = images,
        _tags = tags,
        _localTips = localTips,
        super._();

  factory _$PlaceActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceActivityImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final RecommendationCategory category;
  @override
  final String? description;
  @override
  final String? location;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int reviewCount;
  @override
  final String? priceLevel;
  @override
  final double? cost;
  @override
  final Duration? estimatedDuration;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<String> _localTips;
  @override
  @JsonKey()
  List<String> get localTips {
    if (_localTips is EqualUnmodifiableListView) return _localTips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_localTips);
  }

  @override
  final String? bookingUrl;
  @override
  @JsonKey()
  final bool requiresBooking;
  @override
  final String? openingHours;

  @override
  String toString() {
    return 'PlaceActivity(id: $id, name: $name, category: $category, description: $description, location: $location, latitude: $latitude, longitude: $longitude, rating: $rating, reviewCount: $reviewCount, priceLevel: $priceLevel, cost: $cost, estimatedDuration: $estimatedDuration, images: $images, tags: $tags, localTips: $localTips, bookingUrl: $bookingUrl, requiresBooking: $requiresBooking, openingHours: $openingHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.priceLevel, priceLevel) ||
                other.priceLevel == priceLevel) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._localTips, _localTips) &&
            (identical(other.bookingUrl, bookingUrl) ||
                other.bookingUrl == bookingUrl) &&
            (identical(other.requiresBooking, requiresBooking) ||
                other.requiresBooking == requiresBooking) &&
            (identical(other.openingHours, openingHours) ||
                other.openingHours == openingHours));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      category,
      description,
      location,
      latitude,
      longitude,
      rating,
      reviewCount,
      priceLevel,
      cost,
      estimatedDuration,
      const DeepCollectionEquality().hash(_images),
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_localTips),
      bookingUrl,
      requiresBooking,
      openingHours);

  /// Create a copy of PlaceActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceActivityImplCopyWith<_$PlaceActivityImpl> get copyWith =>
      __$$PlaceActivityImplCopyWithImpl<_$PlaceActivityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceActivityImplToJson(
      this,
    );
  }
}

abstract class _PlaceActivity extends PlaceActivity {
  const factory _PlaceActivity(
      {required final String id,
      required final String name,
      required final RecommendationCategory category,
      final String? description,
      final String? location,
      final double? latitude,
      final double? longitude,
      final double rating,
      final int reviewCount,
      final String? priceLevel,
      final double? cost,
      final Duration? estimatedDuration,
      final List<String> images,
      final List<String> tags,
      final List<String> localTips,
      final String? bookingUrl,
      final bool requiresBooking,
      final String? openingHours}) = _$PlaceActivityImpl;
  const _PlaceActivity._() : super._();

  factory _PlaceActivity.fromJson(Map<String, dynamic> json) =
      _$PlaceActivityImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  RecommendationCategory get category;
  @override
  String? get description;
  @override
  String? get location;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  double get rating;
  @override
  int get reviewCount;
  @override
  String? get priceLevel;
  @override
  double? get cost;
  @override
  Duration? get estimatedDuration;
  @override
  List<String> get images;
  @override
  List<String> get tags;
  @override
  List<String> get localTips;
  @override
  String? get bookingUrl;
  @override
  bool get requiresBooking;
  @override
  String? get openingHours;

  /// Create a copy of PlaceActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceActivityImplCopyWith<_$PlaceActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
