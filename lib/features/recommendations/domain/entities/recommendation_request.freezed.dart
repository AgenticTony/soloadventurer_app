// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecommendationRequest _$RecommendationRequestFromJson(
    Map<String, dynamic> json) {
  return _RecommendationRequest.fromJson(json);
}

/// @nodoc
mixin _$RecommendationRequest {
  String get itineraryId => throw _privateConstructorUsedError;
  Destination get destination => throw _privateConstructorUsedError;
  DateRange get tripDates => throw _privateConstructorUsedError;
  Set<TravelInterest> get interests => throw _privateConstructorUsedError;
  HotelLocation? get hotelLocation => throw _privateConstructorUsedError;
  BudgetRange? get budget => throw _privateConstructorUsedError;
  Set<RecommendationCategory>? get categories =>
      throw _privateConstructorUsedError;
  Set<WeatherContext>? get weatherPreference =>
      throw _privateConstructorUsedError;
  DistanceFromHotel? get maxDistance => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  bool get excludeItineraryItems => throw _privateConstructorUsedError;

  /// Serializes this RecommendationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationRequestCopyWith<RecommendationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationRequestCopyWith<$Res> {
  factory $RecommendationRequestCopyWith(RecommendationRequest value,
          $Res Function(RecommendationRequest) then) =
      _$RecommendationRequestCopyWithImpl<$Res, RecommendationRequest>;
  @useResult
  $Res call(
      {String itineraryId,
      Destination destination,
      DateRange tripDates,
      Set<TravelInterest> interests,
      HotelLocation? hotelLocation,
      BudgetRange? budget,
      Set<RecommendationCategory>? categories,
      Set<WeatherContext>? weatherPreference,
      DistanceFromHotel? maxDistance,
      int limit,
      bool excludeItineraryItems});

  $DestinationCopyWith<$Res> get destination;
  $DateRangeCopyWith<$Res> get tripDates;
  $HotelLocationCopyWith<$Res>? get hotelLocation;
  $BudgetRangeCopyWith<$Res>? get budget;
}

/// @nodoc
class _$RecommendationRequestCopyWithImpl<$Res,
        $Val extends RecommendationRequest>
    implements $RecommendationRequestCopyWith<$Res> {
  _$RecommendationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itineraryId = null,
    Object? destination = null,
    Object? tripDates = null,
    Object? interests = null,
    Object? hotelLocation = freezed,
    Object? budget = freezed,
    Object? categories = freezed,
    Object? weatherPreference = freezed,
    Object? maxDistance = freezed,
    Object? limit = null,
    Object? excludeItineraryItems = null,
  }) {
    return _then(_value.copyWith(
      itineraryId: null == itineraryId
          ? _value.itineraryId
          : itineraryId // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination,
      tripDates: null == tripDates
          ? _value.tripDates
          : tripDates // ignore: cast_nullable_to_non_nullable
              as DateRange,
      interests: null == interests
          ? _value.interests
          : interests // ignore: cast_nullable_to_non_nullable
              as Set<TravelInterest>,
      hotelLocation: freezed == hotelLocation
          ? _value.hotelLocation
          : hotelLocation // ignore: cast_nullable_to_non_nullable
              as HotelLocation?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as BudgetRange?,
      categories: freezed == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as Set<RecommendationCategory>?,
      weatherPreference: freezed == weatherPreference
          ? _value.weatherPreference
          : weatherPreference // ignore: cast_nullable_to_non_nullable
              as Set<WeatherContext>?,
      maxDistance: freezed == maxDistance
          ? _value.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as DistanceFromHotel?,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      excludeItineraryItems: null == excludeItineraryItems
          ? _value.excludeItineraryItems
          : excludeItineraryItems // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res> get destination {
    return $DestinationCopyWith<$Res>(_value.destination, (value) {
      return _then(_value.copyWith(destination: value) as $Val);
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DateRangeCopyWith<$Res> get tripDates {
    return $DateRangeCopyWith<$Res>(_value.tripDates, (value) {
      return _then(_value.copyWith(tripDates: value) as $Val);
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HotelLocationCopyWith<$Res>? get hotelLocation {
    if (_value.hotelLocation == null) {
      return null;
    }

    return $HotelLocationCopyWith<$Res>(_value.hotelLocation!, (value) {
      return _then(_value.copyWith(hotelLocation: value) as $Val);
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BudgetRangeCopyWith<$Res>? get budget {
    if (_value.budget == null) {
      return null;
    }

    return $BudgetRangeCopyWith<$Res>(_value.budget!, (value) {
      return _then(_value.copyWith(budget: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecommendationRequestImplCopyWith<$Res>
    implements $RecommendationRequestCopyWith<$Res> {
  factory _$$RecommendationRequestImplCopyWith(
          _$RecommendationRequestImpl value,
          $Res Function(_$RecommendationRequestImpl) then) =
      __$$RecommendationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String itineraryId,
      Destination destination,
      DateRange tripDates,
      Set<TravelInterest> interests,
      HotelLocation? hotelLocation,
      BudgetRange? budget,
      Set<RecommendationCategory>? categories,
      Set<WeatherContext>? weatherPreference,
      DistanceFromHotel? maxDistance,
      int limit,
      bool excludeItineraryItems});

  @override
  $DestinationCopyWith<$Res> get destination;
  @override
  $DateRangeCopyWith<$Res> get tripDates;
  @override
  $HotelLocationCopyWith<$Res>? get hotelLocation;
  @override
  $BudgetRangeCopyWith<$Res>? get budget;
}

/// @nodoc
class __$$RecommendationRequestImplCopyWithImpl<$Res>
    extends _$RecommendationRequestCopyWithImpl<$Res,
        _$RecommendationRequestImpl>
    implements _$$RecommendationRequestImplCopyWith<$Res> {
  __$$RecommendationRequestImplCopyWithImpl(_$RecommendationRequestImpl _value,
      $Res Function(_$RecommendationRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itineraryId = null,
    Object? destination = null,
    Object? tripDates = null,
    Object? interests = null,
    Object? hotelLocation = freezed,
    Object? budget = freezed,
    Object? categories = freezed,
    Object? weatherPreference = freezed,
    Object? maxDistance = freezed,
    Object? limit = null,
    Object? excludeItineraryItems = null,
  }) {
    return _then(_$RecommendationRequestImpl(
      itineraryId: null == itineraryId
          ? _value.itineraryId
          : itineraryId // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination,
      tripDates: null == tripDates
          ? _value.tripDates
          : tripDates // ignore: cast_nullable_to_non_nullable
              as DateRange,
      interests: null == interests
          ? _value._interests
          : interests // ignore: cast_nullable_to_non_nullable
              as Set<TravelInterest>,
      hotelLocation: freezed == hotelLocation
          ? _value.hotelLocation
          : hotelLocation // ignore: cast_nullable_to_non_nullable
              as HotelLocation?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as BudgetRange?,
      categories: freezed == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as Set<RecommendationCategory>?,
      weatherPreference: freezed == weatherPreference
          ? _value._weatherPreference
          : weatherPreference // ignore: cast_nullable_to_non_nullable
              as Set<WeatherContext>?,
      maxDistance: freezed == maxDistance
          ? _value.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as DistanceFromHotel?,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      excludeItineraryItems: null == excludeItineraryItems
          ? _value.excludeItineraryItems
          : excludeItineraryItems // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationRequestImpl extends _RecommendationRequest {
  const _$RecommendationRequestImpl(
      {required this.itineraryId,
      required this.destination,
      required this.tripDates,
      required final Set<TravelInterest> interests,
      this.hotelLocation,
      this.budget,
      final Set<RecommendationCategory>? categories,
      final Set<WeatherContext>? weatherPreference,
      this.maxDistance,
      this.limit = 20,
      this.excludeItineraryItems = true})
      : _interests = interests,
        _categories = categories,
        _weatherPreference = weatherPreference,
        super._();

  factory _$RecommendationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationRequestImplFromJson(json);

  @override
  final String itineraryId;
  @override
  final Destination destination;
  @override
  final DateRange tripDates;
  final Set<TravelInterest> _interests;
  @override
  Set<TravelInterest> get interests {
    if (_interests is EqualUnmodifiableSetView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_interests);
  }

  @override
  final HotelLocation? hotelLocation;
  @override
  final BudgetRange? budget;
  final Set<RecommendationCategory>? _categories;
  @override
  Set<RecommendationCategory>? get categories {
    final value = _categories;
    if (value == null) return null;
    if (_categories is EqualUnmodifiableSetView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(value);
  }

  final Set<WeatherContext>? _weatherPreference;
  @override
  Set<WeatherContext>? get weatherPreference {
    final value = _weatherPreference;
    if (value == null) return null;
    if (_weatherPreference is EqualUnmodifiableSetView)
      return _weatherPreference;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(value);
  }

  @override
  final DistanceFromHotel? maxDistance;
  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final bool excludeItineraryItems;

  @override
  String toString() {
    return 'RecommendationRequest(itineraryId: $itineraryId, destination: $destination, tripDates: $tripDates, interests: $interests, hotelLocation: $hotelLocation, budget: $budget, categories: $categories, weatherPreference: $weatherPreference, maxDistance: $maxDistance, limit: $limit, excludeItineraryItems: $excludeItineraryItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationRequestImpl &&
            (identical(other.itineraryId, itineraryId) ||
                other.itineraryId == itineraryId) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.tripDates, tripDates) ||
                other.tripDates == tripDates) &&
            const DeepCollectionEquality()
                .equals(other._interests, _interests) &&
            (identical(other.hotelLocation, hotelLocation) ||
                other.hotelLocation == hotelLocation) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality()
                .equals(other._weatherPreference, _weatherPreference) &&
            (identical(other.maxDistance, maxDistance) ||
                other.maxDistance == maxDistance) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.excludeItineraryItems, excludeItineraryItems) ||
                other.excludeItineraryItems == excludeItineraryItems));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      itineraryId,
      destination,
      tripDates,
      const DeepCollectionEquality().hash(_interests),
      hotelLocation,
      budget,
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_weatherPreference),
      maxDistance,
      limit,
      excludeItineraryItems);

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationRequestImplCopyWith<_$RecommendationRequestImpl>
      get copyWith => __$$RecommendationRequestImplCopyWithImpl<
          _$RecommendationRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationRequestImplToJson(
      this,
    );
  }
}

abstract class _RecommendationRequest extends RecommendationRequest {
  const factory _RecommendationRequest(
      {required final String itineraryId,
      required final Destination destination,
      required final DateRange tripDates,
      required final Set<TravelInterest> interests,
      final HotelLocation? hotelLocation,
      final BudgetRange? budget,
      final Set<RecommendationCategory>? categories,
      final Set<WeatherContext>? weatherPreference,
      final DistanceFromHotel? maxDistance,
      final int limit,
      final bool excludeItineraryItems}) = _$RecommendationRequestImpl;
  const _RecommendationRequest._() : super._();

  factory _RecommendationRequest.fromJson(Map<String, dynamic> json) =
      _$RecommendationRequestImpl.fromJson;

  @override
  String get itineraryId;
  @override
  Destination get destination;
  @override
  DateRange get tripDates;
  @override
  Set<TravelInterest> get interests;
  @override
  HotelLocation? get hotelLocation;
  @override
  BudgetRange? get budget;
  @override
  Set<RecommendationCategory>? get categories;
  @override
  Set<WeatherContext>? get weatherPreference;
  @override
  DistanceFromHotel? get maxDistance;
  @override
  int get limit;
  @override
  bool get excludeItineraryItems;

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationRequestImplCopyWith<_$RecommendationRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

HotelLocation _$HotelLocationFromJson(Map<String, dynamic> json) {
  return _HotelLocation.fromJson(json);
}

/// @nodoc
mixin _$HotelLocation {
  String get name => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// Serializes this HotelLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HotelLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HotelLocationCopyWith<HotelLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HotelLocationCopyWith<$Res> {
  factory $HotelLocationCopyWith(
          HotelLocation value, $Res Function(HotelLocation) then) =
      _$HotelLocationCopyWithImpl<$Res, HotelLocation>;
  @useResult
  $Res call({String name, String? address, double latitude, double longitude});
}

/// @nodoc
class _$HotelLocationCopyWithImpl<$Res, $Val extends HotelLocation>
    implements $HotelLocationCopyWith<$Res> {
  _$HotelLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HotelLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = freezed,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HotelLocationImplCopyWith<$Res>
    implements $HotelLocationCopyWith<$Res> {
  factory _$$HotelLocationImplCopyWith(
          _$HotelLocationImpl value, $Res Function(_$HotelLocationImpl) then) =
      __$$HotelLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? address, double latitude, double longitude});
}

/// @nodoc
class __$$HotelLocationImplCopyWithImpl<$Res>
    extends _$HotelLocationCopyWithImpl<$Res, _$HotelLocationImpl>
    implements _$$HotelLocationImplCopyWith<$Res> {
  __$$HotelLocationImplCopyWithImpl(
      _$HotelLocationImpl _value, $Res Function(_$HotelLocationImpl) _then)
      : super(_value, _then);

  /// Create a copy of HotelLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = freezed,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(_$HotelLocationImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HotelLocationImpl extends _HotelLocation {
  const _$HotelLocationImpl(
      {required this.name,
      this.address,
      required this.latitude,
      required this.longitude})
      : super._();

  factory _$HotelLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$HotelLocationImplFromJson(json);

  @override
  final String name;
  @override
  final String? address;
  @override
  final double latitude;
  @override
  final double longitude;

  @override
  String toString() {
    return 'HotelLocation(name: $name, address: $address, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HotelLocationImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, address, latitude, longitude);

  /// Create a copy of HotelLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HotelLocationImplCopyWith<_$HotelLocationImpl> get copyWith =>
      __$$HotelLocationImplCopyWithImpl<_$HotelLocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HotelLocationImplToJson(
      this,
    );
  }
}

abstract class _HotelLocation extends HotelLocation {
  const factory _HotelLocation(
      {required final String name,
      final String? address,
      required final double latitude,
      required final double longitude}) = _$HotelLocationImpl;
  const _HotelLocation._() : super._();

  factory _HotelLocation.fromJson(Map<String, dynamic> json) =
      _$HotelLocationImpl.fromJson;

  @override
  String get name;
  @override
  String? get address;
  @override
  double get latitude;
  @override
  double get longitude;

  /// Create a copy of HotelLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HotelLocationImplCopyWith<_$HotelLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BudgetRange _$BudgetRangeFromJson(Map<String, dynamic> json) {
  return _BudgetRange.fromJson(json);
}

/// @nodoc
mixin _$BudgetRange {
  double? get min => throw _privateConstructorUsedError;
  double? get max => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this BudgetRange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BudgetRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BudgetRangeCopyWith<BudgetRange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BudgetRangeCopyWith<$Res> {
  factory $BudgetRangeCopyWith(
          BudgetRange value, $Res Function(BudgetRange) then) =
      _$BudgetRangeCopyWithImpl<$Res, BudgetRange>;
  @useResult
  $Res call({double? min, double? max, String currency});
}

/// @nodoc
class _$BudgetRangeCopyWithImpl<$Res, $Val extends BudgetRange>
    implements $BudgetRangeCopyWith<$Res> {
  _$BudgetRangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BudgetRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = freezed,
    Object? max = freezed,
    Object? currency = null,
  }) {
    return _then(_value.copyWith(
      min: freezed == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double?,
      max: freezed == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BudgetRangeImplCopyWith<$Res>
    implements $BudgetRangeCopyWith<$Res> {
  factory _$$BudgetRangeImplCopyWith(
          _$BudgetRangeImpl value, $Res Function(_$BudgetRangeImpl) then) =
      __$$BudgetRangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double? min, double? max, String currency});
}

/// @nodoc
class __$$BudgetRangeImplCopyWithImpl<$Res>
    extends _$BudgetRangeCopyWithImpl<$Res, _$BudgetRangeImpl>
    implements _$$BudgetRangeImplCopyWith<$Res> {
  __$$BudgetRangeImplCopyWithImpl(
      _$BudgetRangeImpl _value, $Res Function(_$BudgetRangeImpl) _then)
      : super(_value, _then);

  /// Create a copy of BudgetRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = freezed,
    Object? max = freezed,
    Object? currency = null,
  }) {
    return _then(_$BudgetRangeImpl(
      min: freezed == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double?,
      max: freezed == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BudgetRangeImpl extends _BudgetRange {
  const _$BudgetRangeImpl({this.min, this.max, this.currency = 'USD'})
      : super._();

  factory _$BudgetRangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$BudgetRangeImplFromJson(json);

  @override
  final double? min;
  @override
  final double? max;
  @override
  @JsonKey()
  final String currency;

  @override
  String toString() {
    return 'BudgetRange(min: $min, max: $max, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BudgetRangeImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, min, max, currency);

  /// Create a copy of BudgetRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BudgetRangeImplCopyWith<_$BudgetRangeImpl> get copyWith =>
      __$$BudgetRangeImplCopyWithImpl<_$BudgetRangeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BudgetRangeImplToJson(
      this,
    );
  }
}

abstract class _BudgetRange extends BudgetRange {
  const factory _BudgetRange(
      {final double? min,
      final double? max,
      final String currency}) = _$BudgetRangeImpl;
  const _BudgetRange._() : super._();

  factory _BudgetRange.fromJson(Map<String, dynamic> json) =
      _$BudgetRangeImpl.fromJson;

  @override
  double? get min;
  @override
  double? get max;
  @override
  String get currency;

  /// Create a copy of BudgetRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BudgetRangeImplCopyWith<_$BudgetRangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
