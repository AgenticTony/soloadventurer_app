// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaceActivity {
  String get id;
  String get name;
  RecommendationCategory get category;
  String? get description;
  String? get location;
  double? get latitude;
  double? get longitude;
  double get rating;
  int get reviewCount;
  String? get priceLevel;
  double? get cost;
  Duration? get estimatedDuration;
  List<String> get images;
  List<String> get tags;
  List<String> get localTips;
  String? get bookingUrl;
  bool get requiresBooking;
  String? get openingHours;

  /// Create a copy of PlaceActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PlaceActivityCopyWith<PlaceActivity> get copyWith =>
      _$PlaceActivityCopyWithImpl<PlaceActivity>(
          this as PlaceActivity, _$identity);

  /// Serializes this PlaceActivity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PlaceActivity &&
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
            const DeepCollectionEquality().equals(other.images, images) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality().equals(other.localTips, localTips) &&
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
      const DeepCollectionEquality().hash(images),
      const DeepCollectionEquality().hash(tags),
      const DeepCollectionEquality().hash(localTips),
      bookingUrl,
      requiresBooking,
      openingHours);

  @override
  String toString() {
    return 'PlaceActivity(id: $id, name: $name, category: $category, description: $description, location: $location, latitude: $latitude, longitude: $longitude, rating: $rating, reviewCount: $reviewCount, priceLevel: $priceLevel, cost: $cost, estimatedDuration: $estimatedDuration, images: $images, tags: $tags, localTips: $localTips, bookingUrl: $bookingUrl, requiresBooking: $requiresBooking, openingHours: $openingHours)';
  }
}

/// @nodoc
abstract mixin class $PlaceActivityCopyWith<$Res> {
  factory $PlaceActivityCopyWith(
          PlaceActivity value, $Res Function(PlaceActivity) _then) =
      _$PlaceActivityCopyWithImpl;
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
class _$PlaceActivityCopyWithImpl<$Res>
    implements $PlaceActivityCopyWith<$Res> {
  _$PlaceActivityCopyWithImpl(this._self, this._then);

  final PlaceActivity _self;
  final $Res Function(PlaceActivity) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as RecommendationCategory,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      rating: null == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _self.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      priceLevel: freezed == priceLevel
          ? _self.priceLevel
          : priceLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: freezed == cost
          ? _self.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedDuration: freezed == estimatedDuration
          ? _self.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as Duration?,
      images: null == images
          ? _self.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      localTips: null == localTips
          ? _self.localTips
          : localTips // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bookingUrl: freezed == bookingUrl
          ? _self.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      requiresBooking: null == requiresBooking
          ? _self.requiresBooking
          : requiresBooking // ignore: cast_nullable_to_non_nullable
              as bool,
      openingHours: freezed == openingHours
          ? _self.openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PlaceActivity].
extension PlaceActivityPatterns on PlaceActivity {
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
    TResult Function(_PlaceActivity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlaceActivity() when $default != null:
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
    TResult Function(_PlaceActivity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceActivity():
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
    TResult? Function(_PlaceActivity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceActivity() when $default != null:
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
            String id,
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
            String? openingHours)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlaceActivity() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.category,
            _that.description,
            _that.location,
            _that.latitude,
            _that.longitude,
            _that.rating,
            _that.reviewCount,
            _that.priceLevel,
            _that.cost,
            _that.estimatedDuration,
            _that.images,
            _that.tags,
            _that.localTips,
            _that.bookingUrl,
            _that.requiresBooking,
            _that.openingHours);
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
            String id,
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
            String? openingHours)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceActivity():
        return $default(
            _that.id,
            _that.name,
            _that.category,
            _that.description,
            _that.location,
            _that.latitude,
            _that.longitude,
            _that.rating,
            _that.reviewCount,
            _that.priceLevel,
            _that.cost,
            _that.estimatedDuration,
            _that.images,
            _that.tags,
            _that.localTips,
            _that.bookingUrl,
            _that.requiresBooking,
            _that.openingHours);
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
            String id,
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
            String? openingHours)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceActivity() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.category,
            _that.description,
            _that.location,
            _that.latitude,
            _that.longitude,
            _that.rating,
            _that.reviewCount,
            _that.priceLevel,
            _that.cost,
            _that.estimatedDuration,
            _that.images,
            _that.tags,
            _that.localTips,
            _that.bookingUrl,
            _that.requiresBooking,
            _that.openingHours);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PlaceActivity extends PlaceActivity {
  const _PlaceActivity(
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
  factory _PlaceActivity.fromJson(Map<String, dynamic> json) =>
      _$PlaceActivityFromJson(json);

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

  /// Create a copy of PlaceActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PlaceActivityCopyWith<_PlaceActivity> get copyWith =>
      __$PlaceActivityCopyWithImpl<_PlaceActivity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PlaceActivityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PlaceActivity &&
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

  @override
  String toString() {
    return 'PlaceActivity(id: $id, name: $name, category: $category, description: $description, location: $location, latitude: $latitude, longitude: $longitude, rating: $rating, reviewCount: $reviewCount, priceLevel: $priceLevel, cost: $cost, estimatedDuration: $estimatedDuration, images: $images, tags: $tags, localTips: $localTips, bookingUrl: $bookingUrl, requiresBooking: $requiresBooking, openingHours: $openingHours)';
  }
}

/// @nodoc
abstract mixin class _$PlaceActivityCopyWith<$Res>
    implements $PlaceActivityCopyWith<$Res> {
  factory _$PlaceActivityCopyWith(
          _PlaceActivity value, $Res Function(_PlaceActivity) _then) =
      __$PlaceActivityCopyWithImpl;
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
class __$PlaceActivityCopyWithImpl<$Res>
    implements _$PlaceActivityCopyWith<$Res> {
  __$PlaceActivityCopyWithImpl(this._self, this._then);

  final _PlaceActivity _self;
  final $Res Function(_PlaceActivity) _then;

  /// Create a copy of PlaceActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_PlaceActivity(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as RecommendationCategory,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      rating: null == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _self.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      priceLevel: freezed == priceLevel
          ? _self.priceLevel
          : priceLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: freezed == cost
          ? _self.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedDuration: freezed == estimatedDuration
          ? _self.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as Duration?,
      images: null == images
          ? _self._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      localTips: null == localTips
          ? _self._localTips
          : localTips // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bookingUrl: freezed == bookingUrl
          ? _self.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      requiresBooking: null == requiresBooking
          ? _self.requiresBooking
          : requiresBooking // ignore: cast_nullable_to_non_nullable
              as bool,
      openingHours: freezed == openingHours
          ? _self.openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
