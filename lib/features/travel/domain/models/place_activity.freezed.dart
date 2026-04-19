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
  String get description;
  String get category;
  String? get address;
  double? get latitude;
  double? get longitude;
  double get rating;
  int get reviewCount;
  bool get isIndoor;
  int? get estimatedDuration; // in minutes
  String? get recommendedTime;
  double? get cost;
  String? get bookingUrl;
  String? get photoUrl;

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
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.isIndoor, isIndoor) ||
                other.isIndoor == isIndoor) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration) &&
            (identical(other.recommendedTime, recommendedTime) ||
                other.recommendedTime == recommendedTime) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.bookingUrl, bookingUrl) ||
                other.bookingUrl == bookingUrl) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      category,
      address,
      latitude,
      longitude,
      rating,
      reviewCount,
      isIndoor,
      estimatedDuration,
      recommendedTime,
      cost,
      bookingUrl,
      photoUrl);

  @override
  String toString() {
    return 'PlaceActivity(id: $id, name: $name, description: $description, category: $category, address: $address, latitude: $latitude, longitude: $longitude, rating: $rating, reviewCount: $reviewCount, isIndoor: $isIndoor, estimatedDuration: $estimatedDuration, recommendedTime: $recommendedTime, cost: $cost, bookingUrl: $bookingUrl, photoUrl: $photoUrl)';
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
      String description,
      String category,
      String? address,
      double? latitude,
      double? longitude,
      double rating,
      int reviewCount,
      bool isIndoor,
      int? estimatedDuration,
      String? recommendedTime,
      double? cost,
      String? bookingUrl,
      String? photoUrl});
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
    Object? description = null,
    Object? category = null,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? rating = null,
    Object? reviewCount = null,
    Object? isIndoor = null,
    Object? estimatedDuration = freezed,
    Object? recommendedTime = freezed,
    Object? cost = freezed,
    Object? bookingUrl = freezed,
    Object? photoUrl = freezed,
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
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
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
      isIndoor: null == isIndoor
          ? _self.isIndoor
          : isIndoor // ignore: cast_nullable_to_non_nullable
              as bool,
      estimatedDuration: freezed == estimatedDuration
          ? _self.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      recommendedTime: freezed == recommendedTime
          ? _self.recommendedTime
          : recommendedTime // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: freezed == cost
          ? _self.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      bookingUrl: freezed == bookingUrl
          ? _self.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _self.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
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
            String description,
            String category,
            String? address,
            double? latitude,
            double? longitude,
            double rating,
            int reviewCount,
            bool isIndoor,
            int? estimatedDuration,
            String? recommendedTime,
            double? cost,
            String? bookingUrl,
            String? photoUrl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlaceActivity() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.category,
            _that.address,
            _that.latitude,
            _that.longitude,
            _that.rating,
            _that.reviewCount,
            _that.isIndoor,
            _that.estimatedDuration,
            _that.recommendedTime,
            _that.cost,
            _that.bookingUrl,
            _that.photoUrl);
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
            String description,
            String category,
            String? address,
            double? latitude,
            double? longitude,
            double rating,
            int reviewCount,
            bool isIndoor,
            int? estimatedDuration,
            String? recommendedTime,
            double? cost,
            String? bookingUrl,
            String? photoUrl)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceActivity():
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.category,
            _that.address,
            _that.latitude,
            _that.longitude,
            _that.rating,
            _that.reviewCount,
            _that.isIndoor,
            _that.estimatedDuration,
            _that.recommendedTime,
            _that.cost,
            _that.bookingUrl,
            _that.photoUrl);
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
            String description,
            String category,
            String? address,
            double? latitude,
            double? longitude,
            double rating,
            int reviewCount,
            bool isIndoor,
            int? estimatedDuration,
            String? recommendedTime,
            double? cost,
            String? bookingUrl,
            String? photoUrl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceActivity() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.category,
            _that.address,
            _that.latitude,
            _that.longitude,
            _that.rating,
            _that.reviewCount,
            _that.isIndoor,
            _that.estimatedDuration,
            _that.recommendedTime,
            _that.cost,
            _that.bookingUrl,
            _that.photoUrl);
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
      required this.description,
      required this.category,
      this.address,
      this.latitude,
      this.longitude,
      this.rating = 0.0,
      this.reviewCount = 0,
      this.isIndoor = false,
      this.estimatedDuration,
      this.recommendedTime,
      this.cost,
      this.bookingUrl,
      this.photoUrl})
      : super._();
  factory _PlaceActivity.fromJson(Map<String, dynamic> json) =>
      _$PlaceActivityFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String category;
  @override
  final String? address;
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
  @JsonKey()
  final bool isIndoor;
  @override
  final int? estimatedDuration;
// in minutes
  @override
  final String? recommendedTime;
  @override
  final double? cost;
  @override
  final String? bookingUrl;
  @override
  final String? photoUrl;

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
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.isIndoor, isIndoor) ||
                other.isIndoor == isIndoor) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration) &&
            (identical(other.recommendedTime, recommendedTime) ||
                other.recommendedTime == recommendedTime) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.bookingUrl, bookingUrl) ||
                other.bookingUrl == bookingUrl) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      category,
      address,
      latitude,
      longitude,
      rating,
      reviewCount,
      isIndoor,
      estimatedDuration,
      recommendedTime,
      cost,
      bookingUrl,
      photoUrl);

  @override
  String toString() {
    return 'PlaceActivity(id: $id, name: $name, description: $description, category: $category, address: $address, latitude: $latitude, longitude: $longitude, rating: $rating, reviewCount: $reviewCount, isIndoor: $isIndoor, estimatedDuration: $estimatedDuration, recommendedTime: $recommendedTime, cost: $cost, bookingUrl: $bookingUrl, photoUrl: $photoUrl)';
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
      String description,
      String category,
      String? address,
      double? latitude,
      double? longitude,
      double rating,
      int reviewCount,
      bool isIndoor,
      int? estimatedDuration,
      String? recommendedTime,
      double? cost,
      String? bookingUrl,
      String? photoUrl});
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
    Object? description = null,
    Object? category = null,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? rating = null,
    Object? reviewCount = null,
    Object? isIndoor = null,
    Object? estimatedDuration = freezed,
    Object? recommendedTime = freezed,
    Object? cost = freezed,
    Object? bookingUrl = freezed,
    Object? photoUrl = freezed,
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
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
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
      isIndoor: null == isIndoor
          ? _self.isIndoor
          : isIndoor // ignore: cast_nullable_to_non_nullable
              as bool,
      estimatedDuration: freezed == estimatedDuration
          ? _self.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      recommendedTime: freezed == recommendedTime
          ? _self.recommendedTime
          : recommendedTime // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: freezed == cost
          ? _self.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      bookingUrl: freezed == bookingUrl
          ? _self.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _self.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$PeakHours {
  List<int> get hours; // Hours that are peak (0-23)
  String get dayOfWeek; // Day this applies to (or 'daily')
  int? get currentHour;

  /// Create a copy of PeakHours
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PeakHoursCopyWith<PeakHours> get copyWith =>
      _$PeakHoursCopyWithImpl<PeakHours>(this as PeakHours, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PeakHours &&
            const DeepCollectionEquality().equals(other.hours, hours) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.currentHour, currentHour) ||
                other.currentHour == currentHour));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(hours), dayOfWeek, currentHour);

  @override
  String toString() {
    return 'PeakHours(hours: $hours, dayOfWeek: $dayOfWeek, currentHour: $currentHour)';
  }
}

/// @nodoc
abstract mixin class $PeakHoursCopyWith<$Res> {
  factory $PeakHoursCopyWith(PeakHours value, $Res Function(PeakHours) _then) =
      _$PeakHoursCopyWithImpl;
  @useResult
  $Res call({List<int> hours, String dayOfWeek, int? currentHour});
}

/// @nodoc
class _$PeakHoursCopyWithImpl<$Res> implements $PeakHoursCopyWith<$Res> {
  _$PeakHoursCopyWithImpl(this._self, this._then);

  final PeakHours _self;
  final $Res Function(PeakHours) _then;

  /// Create a copy of PeakHours
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hours = null,
    Object? dayOfWeek = null,
    Object? currentHour = freezed,
  }) {
    return _then(_self.copyWith(
      hours: null == hours
          ? _self.hours
          : hours // ignore: cast_nullable_to_non_nullable
              as List<int>,
      dayOfWeek: null == dayOfWeek
          ? _self.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String,
      currentHour: freezed == currentHour
          ? _self.currentHour
          : currentHour // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PeakHours].
extension PeakHoursPatterns on PeakHours {
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
    TResult Function(_PeakHours value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PeakHours() when $default != null:
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
    TResult Function(_PeakHours value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PeakHours():
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
    TResult? Function(_PeakHours value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PeakHours() when $default != null:
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
    TResult Function(List<int> hours, String dayOfWeek, int? currentHour)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PeakHours() when $default != null:
        return $default(_that.hours, _that.dayOfWeek, _that.currentHour);
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
    TResult Function(List<int> hours, String dayOfWeek, int? currentHour)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PeakHours():
        return $default(_that.hours, _that.dayOfWeek, _that.currentHour);
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
    TResult? Function(List<int> hours, String dayOfWeek, int? currentHour)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PeakHours() when $default != null:
        return $default(_that.hours, _that.dayOfWeek, _that.currentHour);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PeakHours extends PeakHours {
  const _PeakHours(
      {required final List<int> hours,
      required this.dayOfWeek,
      this.currentHour})
      : _hours = hours,
        super._();

  final List<int> _hours;
  @override
  List<int> get hours {
    if (_hours is EqualUnmodifiableListView) return _hours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hours);
  }

// Hours that are peak (0-23)
  @override
  final String dayOfWeek;
// Day this applies to (or 'daily')
  @override
  final int? currentHour;

  /// Create a copy of PeakHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PeakHoursCopyWith<_PeakHours> get copyWith =>
      __$PeakHoursCopyWithImpl<_PeakHours>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PeakHours &&
            const DeepCollectionEquality().equals(other._hours, _hours) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.currentHour, currentHour) ||
                other.currentHour == currentHour));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_hours), dayOfWeek, currentHour);

  @override
  String toString() {
    return 'PeakHours(hours: $hours, dayOfWeek: $dayOfWeek, currentHour: $currentHour)';
  }
}

/// @nodoc
abstract mixin class _$PeakHoursCopyWith<$Res>
    implements $PeakHoursCopyWith<$Res> {
  factory _$PeakHoursCopyWith(
          _PeakHours value, $Res Function(_PeakHours) _then) =
      __$PeakHoursCopyWithImpl;
  @override
  @useResult
  $Res call({List<int> hours, String dayOfWeek, int? currentHour});
}

/// @nodoc
class __$PeakHoursCopyWithImpl<$Res> implements _$PeakHoursCopyWith<$Res> {
  __$PeakHoursCopyWithImpl(this._self, this._then);

  final _PeakHours _self;
  final $Res Function(_PeakHours) _then;

  /// Create a copy of PeakHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? hours = null,
    Object? dayOfWeek = null,
    Object? currentHour = freezed,
  }) {
    return _then(_PeakHours(
      hours: null == hours
          ? _self._hours
          : hours // ignore: cast_nullable_to_non_nullable
              as List<int>,
      dayOfWeek: null == dayOfWeek
          ? _self.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String,
      currentHour: freezed == currentHour
          ? _self.currentHour
          : currentHour // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
