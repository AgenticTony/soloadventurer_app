// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Photo _$PhotoFromJson(Map<String, dynamic> json) {
  return _Photo.fromJson(json);
}

/// @nodoc
mixin _$Photo {
  /// Unique identifier for the photo
  String get id => throw _privateConstructorUsedError;

  /// URL of the photo image
  String get imageUrl => throw _privateConstructorUsedError;

  /// Optional thumbnail URL for efficient grid rendering
  String? get thumbnailUrl => throw _privateConstructorUsedError;

  /// Optional caption or description
  String? get caption => throw _privateConstructorUsedError;

  /// Trip ID this photo belongs to
  String get tripId => throw _privateConstructorUsedError;

  /// Optional location where photo was taken
  String? get location => throw _privateConstructorUsedError;

  /// Optional latitude coordinate
  double? get latitude => throw _privateConstructorUsedError;

  /// Optional longitude coordinate
  double? get longitude => throw _privateConstructorUsedError;

  /// Timestamp when photo was taken
  DateTime get takenAt => throw _privateConstructorUsedError;

  /// Photo width in pixels
  int get width => throw _privateConstructorUsedError;

  /// Photo height in pixels
  int get height => throw _privateConstructorUsedError;

  /// Photo file size in bytes
  int get sizeInBytes => throw _privateConstructorUsedError;

  /// When the photo was uploaded
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Photo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoCopyWith<Photo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoCopyWith<$Res> {
  factory $PhotoCopyWith(Photo value, $Res Function(Photo) then) =
      _$PhotoCopyWithImpl<$Res, Photo>;
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
class _$PhotoCopyWithImpl<$Res, $Val extends Photo>
    implements $PhotoCopyWith<$Res> {
  _$PhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
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
      takenAt: null == takenAt
          ? _value.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      sizeInBytes: null == sizeInBytes
          ? _value.sizeInBytes
          : sizeInBytes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhotoImplCopyWith<$Res> implements $PhotoCopyWith<$Res> {
  factory _$$PhotoImplCopyWith(
          _$PhotoImpl value, $Res Function(_$PhotoImpl) then) =
      __$$PhotoImplCopyWithImpl<$Res>;
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
class __$$PhotoImplCopyWithImpl<$Res>
    extends _$PhotoCopyWithImpl<$Res, _$PhotoImpl>
    implements _$$PhotoImplCopyWith<$Res> {
  __$$PhotoImplCopyWithImpl(
      _$PhotoImpl _value, $Res Function(_$PhotoImpl) _then)
      : super(_value, _then);

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
    return _then(_$PhotoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
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
      takenAt: null == takenAt
          ? _value.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      sizeInBytes: null == sizeInBytes
          ? _value.sizeInBytes
          : sizeInBytes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoImpl extends _Photo {
  const _$PhotoImpl(
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
      required this.createdAt})
      : super._();

  factory _$PhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoImplFromJson(json);

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

  @override
  String toString() {
    return 'Photo(id: $id, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, caption: $caption, tripId: $tripId, location: $location, latitude: $latitude, longitude: $longitude, takenAt: $takenAt, width: $width, height: $height, sizeInBytes: $sizeInBytes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoImpl &&
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

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      __$$PhotoImplCopyWithImpl<_$PhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoImplToJson(
      this,
    );
  }
}

abstract class _Photo extends Photo {
  const factory _Photo(
      {required final String id,
      required final String imageUrl,
      final String? thumbnailUrl,
      final String? caption,
      required final String tripId,
      final String? location,
      final double? latitude,
      final double? longitude,
      required final DateTime takenAt,
      required final int width,
      required final int height,
      required final int sizeInBytes,
      required final DateTime createdAt}) = _$PhotoImpl;
  const _Photo._() : super._();

  factory _Photo.fromJson(Map<String, dynamic> json) = _$PhotoImpl.fromJson;

  /// Unique identifier for the photo
  @override
  String get id;

  /// URL of the photo image
  @override
  String get imageUrl;

  /// Optional thumbnail URL for efficient grid rendering
  @override
  String? get thumbnailUrl;

  /// Optional caption or description
  @override
  String? get caption;

  /// Trip ID this photo belongs to
  @override
  String get tripId;

  /// Optional location where photo was taken
  @override
  String? get location;

  /// Optional latitude coordinate
  @override
  double? get latitude;

  /// Optional longitude coordinate
  @override
  double? get longitude;

  /// Timestamp when photo was taken
  @override
  DateTime get takenAt;

  /// Photo width in pixels
  @override
  int get width;

  /// Photo height in pixels
  @override
  int get height;

  /// Photo file size in bytes
  @override
  int get sizeInBytes;

  /// When the photo was uploaded
  @override
  DateTime get createdAt;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
