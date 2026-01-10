// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Photo {
  /// Unique identifier for the photo
  String get id;

  /// URL of the photo image
  String get imageUrl;

  /// Optional thumbnail URL for efficient grid rendering
  String? get thumbnailUrl;

  /// Optional caption or description
  String? get caption;

  /// Trip ID this photo belongs to
  String get tripId;

  /// Optional location where photo was taken
  String? get location;

  /// Optional latitude coordinate
  double? get latitude;

  /// Optional longitude coordinate
  double? get longitude;

  /// Timestamp when photo was taken
  DateTime get takenAt;

  /// Photo width in pixels
  int get width;

  /// Photo height in pixels
  int get height;

  /// Photo file size in bytes
  int get sizeInBytes;

  /// When the photo was uploaded
  DateTime get createdAt;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PhotoCopyWith<Photo> get copyWith =>
      _$PhotoCopyWithImpl<Photo>(this as Photo, _$identity);

  /// Serializes this Photo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Photo &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.takenAt, takenAt) || other.takenAt == takenAt) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.sizeInBytes, sizeInBytes) ||
                other.sizeInBytes == sizeInBytes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      imageUrl,
      thumbnailUrl,
      caption,
      tripId,
      location,
      latitude,
      longitude,
      takenAt,
      width,
      height,
      sizeInBytes,
      createdAt);

  @override
  String toString() {
    return 'Photo(id: $id, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, caption: $caption, tripId: $tripId, location: $location, latitude: $latitude, longitude: $longitude, takenAt: $takenAt, width: $width, height: $height, sizeInBytes: $sizeInBytes, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $PhotoCopyWith<$Res> {
  factory $PhotoCopyWith(Photo value, $Res Function(Photo) _then) =
      _$PhotoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String imageUrl,
      String? thumbnailUrl,
      String? caption,
      String tripId,
      String? location,
      double? latitude,
      double? longitude,
      DateTime takenAt,
      int width,
      int height,
      int sizeInBytes,
      DateTime createdAt});
}

/// @nodoc
class _$PhotoCopyWithImpl<$Res> implements $PhotoCopyWith<$Res> {
  _$PhotoCopyWithImpl(this._self, this._then);

  final Photo _self;
  final $Res Function(Photo) _then;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? thumbnailUrl = freezed,
    Object? caption = freezed,
    Object? tripId = null,
    Object? location = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? takenAt = null,
    Object? width = null,
    Object? height = null,
    Object? sizeInBytes = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      caption: freezed == caption
          ? _self.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: null == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
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
      takenAt: null == takenAt
          ? _self.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      width: null == width
          ? _self.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      sizeInBytes: null == sizeInBytes
          ? _self.sizeInBytes
          : sizeInBytes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [Photo].
extension PhotoPatterns on Photo {
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
    TResult Function(_Photo value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Photo() when $default != null:
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
    TResult Function(_Photo value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Photo():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
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
    TResult? Function(_Photo value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Photo() when $default != null:
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
            String imageUrl,
            String? thumbnailUrl,
            String? caption,
            String tripId,
            String? location,
            double? latitude,
            double? longitude,
            DateTime takenAt,
            int width,
            int height,
            int sizeInBytes,
            DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Photo() when $default != null:
        return $default(
            _that.id,
            _that.imageUrl,
            _that.thumbnailUrl,
            _that.caption,
            _that.tripId,
            _that.location,
            _that.latitude,
            _that.longitude,
            _that.takenAt,
            _that.width,
            _that.height,
            _that.sizeInBytes,
            _that.createdAt);
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
            String imageUrl,
            String? thumbnailUrl,
            String? caption,
            String tripId,
            String? location,
            double? latitude,
            double? longitude,
            DateTime takenAt,
            int width,
            int height,
            int sizeInBytes,
            DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Photo():
        return $default(
            _that.id,
            _that.imageUrl,
            _that.thumbnailUrl,
            _that.caption,
            _that.tripId,
            _that.location,
            _that.latitude,
            _that.longitude,
            _that.takenAt,
            _that.width,
            _that.height,
            _that.sizeInBytes,
            _that.createdAt);
      case _:
        throw StateError('Unexpected subclass');
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
            String imageUrl,
            String? thumbnailUrl,
            String? caption,
            String tripId,
            String? location,
            double? latitude,
            double? longitude,
            DateTime takenAt,
            int width,
            int height,
            int sizeInBytes,
            DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Photo() when $default != null:
        return $default(
            _that.id,
            _that.imageUrl,
            _that.thumbnailUrl,
            _that.caption,
            _that.tripId,
            _that.location,
            _that.latitude,
            _that.longitude,
            _that.takenAt,
            _that.width,
            _that.height,
            _that.sizeInBytes,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Photo implements Photo {
  const _Photo(
      {required this.id,
      required this.imageUrl,
      this.thumbnailUrl,
      this.caption,
      required this.tripId,
      this.location,
      this.latitude,
      this.longitude,
      required this.takenAt,
      required this.width,
      required this.height,
      required this.sizeInBytes,
      required this.createdAt});
  factory _Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);

  /// Unique identifier for the photo
  @override
  final String id;

  /// URL of the photo image
  @override
  final String imageUrl;

  /// Optional thumbnail URL for efficient grid rendering
  @override
  final String? thumbnailUrl;

  /// Optional caption or description
  @override
  final String? caption;

  /// Trip ID this photo belongs to
  @override
  final String tripId;

  /// Optional location where photo was taken
  @override
  final String? location;

  /// Optional latitude coordinate
  @override
  final double? latitude;

  /// Optional longitude coordinate
  @override
  final double? longitude;

  /// Timestamp when photo was taken
  @override
  final DateTime takenAt;

  /// Photo width in pixels
  @override
  final int width;

  /// Photo height in pixels
  @override
  final int height;

  /// Photo file size in bytes
  @override
  final int sizeInBytes;

  /// When the photo was uploaded
  @override
  final DateTime createdAt;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PhotoCopyWith<_Photo> get copyWith =>
      __$PhotoCopyWithImpl<_Photo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PhotoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Photo &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.takenAt, takenAt) || other.takenAt == takenAt) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.sizeInBytes, sizeInBytes) ||
                other.sizeInBytes == sizeInBytes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      imageUrl,
      thumbnailUrl,
      caption,
      tripId,
      location,
      latitude,
      longitude,
      takenAt,
      width,
      height,
      sizeInBytes,
      createdAt);

  @override
  String toString() {
    return 'Photo(id: $id, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, caption: $caption, tripId: $tripId, location: $location, latitude: $latitude, longitude: $longitude, takenAt: $takenAt, width: $width, height: $height, sizeInBytes: $sizeInBytes, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$PhotoCopyWith<$Res> implements $PhotoCopyWith<$Res> {
  factory _$PhotoCopyWith(_Photo value, $Res Function(_Photo) _then) =
      __$PhotoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String imageUrl,
      String? thumbnailUrl,
      String? caption,
      String tripId,
      String? location,
      double? latitude,
      double? longitude,
      DateTime takenAt,
      int width,
      int height,
      int sizeInBytes,
      DateTime createdAt});
}

/// @nodoc
class __$PhotoCopyWithImpl<$Res> implements _$PhotoCopyWith<$Res> {
  __$PhotoCopyWithImpl(this._self, this._then);

  final _Photo _self;
  final $Res Function(_Photo) _then;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? thumbnailUrl = freezed,
    Object? caption = freezed,
    Object? tripId = null,
    Object? location = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? takenAt = null,
    Object? width = null,
    Object? height = null,
    Object? sizeInBytes = null,
    Object? createdAt = null,
  }) {
    return _then(_Photo(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      caption: freezed == caption
          ? _self.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: null == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
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
      takenAt: null == takenAt
          ? _self.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      width: null == width
          ? _self.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      sizeInBytes: null == sizeInBytes
          ? _self.sizeInBytes
          : sizeInBytes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
