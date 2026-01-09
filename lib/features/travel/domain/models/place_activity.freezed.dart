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
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  bool get isIndoor => throw _privateConstructorUsedError;
  int? get estimatedDuration =>
      throw _privateConstructorUsedError; // in minutes
  String? get recommendedTime => throw _privateConstructorUsedError;
  double? get cost => throw _privateConstructorUsedError;
  String? get bookingUrl => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
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
      isIndoor: null == isIndoor
          ? _value.isIndoor
          : isIndoor // ignore: cast_nullable_to_non_nullable
              as bool,
      estimatedDuration: freezed == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      recommendedTime: freezed == recommendedTime
          ? _value.recommendedTime
          : recommendedTime // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      bookingUrl: freezed == bookingUrl
          ? _value.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
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
    return _then(_$PlaceActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
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
      isIndoor: null == isIndoor
          ? _value.isIndoor
          : isIndoor // ignore: cast_nullable_to_non_nullable
              as bool,
      estimatedDuration: freezed == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      recommendedTime: freezed == recommendedTime
          ? _value.recommendedTime
          : recommendedTime // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      bookingUrl: freezed == bookingUrl
          ? _value.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
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

  factory _$PlaceActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceActivityImplFromJson(json);

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

  @override
  String toString() {
    return 'PlaceActivity(id: $id, name: $name, description: $description, category: $category, address: $address, latitude: $latitude, longitude: $longitude, rating: $rating, reviewCount: $reviewCount, isIndoor: $isIndoor, estimatedDuration: $estimatedDuration, recommendedTime: $recommendedTime, cost: $cost, bookingUrl: $bookingUrl, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceActivityImpl &&
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
      required final String description,
      required final String category,
      final String? address,
      final double? latitude,
      final double? longitude,
      final double rating,
      final int reviewCount,
      final bool isIndoor,
      final int? estimatedDuration,
      final String? recommendedTime,
      final double? cost,
      final String? bookingUrl,
      final String? photoUrl}) = _$PlaceActivityImpl;
  const _PlaceActivity._() : super._();

  factory _PlaceActivity.fromJson(Map<String, dynamic> json) =
      _$PlaceActivityImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get category;
  @override
  String? get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  double get rating;
  @override
  int get reviewCount;
  @override
  bool get isIndoor;
  @override
  int? get estimatedDuration; // in minutes
  @override
  String? get recommendedTime;
  @override
  double? get cost;
  @override
  String? get bookingUrl;
  @override
  String? get photoUrl;

  /// Create a copy of PlaceActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceActivityImplCopyWith<_$PlaceActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PeakHours {
  List<int> get hours =>
      throw _privateConstructorUsedError; // Hours that are peak (0-23)
  String get dayOfWeek =>
      throw _privateConstructorUsedError; // Day this applies to (or 'daily')
  int? get currentHour => throw _privateConstructorUsedError;

  /// Create a copy of PeakHours
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PeakHoursCopyWith<PeakHours> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeakHoursCopyWith<$Res> {
  factory $PeakHoursCopyWith(PeakHours value, $Res Function(PeakHours) then) =
      _$PeakHoursCopyWithImpl<$Res, PeakHours>;
  @useResult
  $Res call({List<int> hours, String dayOfWeek, int? currentHour});
}

/// @nodoc
class _$PeakHoursCopyWithImpl<$Res, $Val extends PeakHours>
    implements $PeakHoursCopyWith<$Res> {
  _$PeakHoursCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PeakHours
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hours = null,
    Object? dayOfWeek = null,
    Object? currentHour = freezed,
  }) {
    return _then(_value.copyWith(
      hours: null == hours
          ? _value.hours
          : hours // ignore: cast_nullable_to_non_nullable
              as List<int>,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String,
      currentHour: freezed == currentHour
          ? _value.currentHour
          : currentHour // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PeakHoursImplCopyWith<$Res>
    implements $PeakHoursCopyWith<$Res> {
  factory _$$PeakHoursImplCopyWith(
          _$PeakHoursImpl value, $Res Function(_$PeakHoursImpl) then) =
      __$$PeakHoursImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<int> hours, String dayOfWeek, int? currentHour});
}

/// @nodoc
class __$$PeakHoursImplCopyWithImpl<$Res>
    extends _$PeakHoursCopyWithImpl<$Res, _$PeakHoursImpl>
    implements _$$PeakHoursImplCopyWith<$Res> {
  __$$PeakHoursImplCopyWithImpl(
      _$PeakHoursImpl _value, $Res Function(_$PeakHoursImpl) _then)
      : super(_value, _then);

  /// Create a copy of PeakHours
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hours = null,
    Object? dayOfWeek = null,
    Object? currentHour = freezed,
  }) {
    return _then(_$PeakHoursImpl(
      hours: null == hours
          ? _value._hours
          : hours // ignore: cast_nullable_to_non_nullable
              as List<int>,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String,
      currentHour: freezed == currentHour
          ? _value.currentHour
          : currentHour // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$PeakHoursImpl implements _PeakHours {
  const _$PeakHoursImpl(
      {required final List<int> hours,
      required this.dayOfWeek,
      this.currentHour})
      : _hours = hours;

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

  @override
  String toString() {
    return 'PeakHours(hours: $hours, dayOfWeek: $dayOfWeek, currentHour: $currentHour)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeakHoursImpl &&
            const DeepCollectionEquality().equals(other._hours, _hours) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.currentHour, currentHour) ||
                other.currentHour == currentHour));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_hours), dayOfWeek, currentHour);

  /// Create a copy of PeakHours
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeakHoursImplCopyWith<_$PeakHoursImpl> get copyWith =>
      __$$PeakHoursImplCopyWithImpl<_$PeakHoursImpl>(this, _$identity);
}

abstract class _PeakHours implements PeakHours {
  const factory _PeakHours(
      {required final List<int> hours,
      required final String dayOfWeek,
      final int? currentHour}) = _$PeakHoursImpl;

  @override
  List<int> get hours; // Hours that are peak (0-23)
  @override
  String get dayOfWeek; // Day this applies to (or 'daily')
  @override
  int? get currentHour;

  /// Create a copy of PeakHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeakHoursImplCopyWith<_$PeakHoursImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
