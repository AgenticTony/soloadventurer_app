// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecommendationRequest {
  String get itineraryId;
  Destination get destination;
  DateRange get tripDates;
  Set<TravelInterest> get interests;
  HotelLocation? get hotelLocation;
  BudgetRange? get budget;
  Set<RecommendationCategory>? get categories;
  Set<WeatherContext>? get weatherPreference;
  DistanceFromHotel? get maxDistance;
  int get limit;
  bool get excludeItineraryItems;

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecommendationRequestCopyWith<RecommendationRequest> get copyWith =>
      _$RecommendationRequestCopyWithImpl<RecommendationRequest>(
          this as RecommendationRequest, _$identity);

  /// Serializes this RecommendationRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecommendationRequest &&
            (identical(other.itineraryId, itineraryId) ||
                other.itineraryId == itineraryId) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.tripDates, tripDates) ||
                other.tripDates == tripDates) &&
            const DeepCollectionEquality().equals(other.interests, interests) &&
            (identical(other.hotelLocation, hotelLocation) ||
                other.hotelLocation == hotelLocation) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            const DeepCollectionEquality()
                .equals(other.categories, categories) &&
            const DeepCollectionEquality()
                .equals(other.weatherPreference, weatherPreference) &&
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
      const DeepCollectionEquality().hash(interests),
      hotelLocation,
      budget,
      const DeepCollectionEquality().hash(categories),
      const DeepCollectionEquality().hash(weatherPreference),
      maxDistance,
      limit,
      excludeItineraryItems);

  @override
  String toString() {
    return 'RecommendationRequest(itineraryId: $itineraryId, destination: $destination, tripDates: $tripDates, interests: $interests, hotelLocation: $hotelLocation, budget: $budget, categories: $categories, weatherPreference: $weatherPreference, maxDistance: $maxDistance, limit: $limit, excludeItineraryItems: $excludeItineraryItems)';
  }
}

/// @nodoc
abstract mixin class $RecommendationRequestCopyWith<$Res> {
  factory $RecommendationRequestCopyWith(RecommendationRequest value,
          $Res Function(RecommendationRequest) _then) =
      _$RecommendationRequestCopyWithImpl;
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
class _$RecommendationRequestCopyWithImpl<$Res>
    implements $RecommendationRequestCopyWith<$Res> {
  _$RecommendationRequestCopyWithImpl(this._self, this._then);

  final RecommendationRequest _self;
  final $Res Function(RecommendationRequest) _then;

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
    return _then(_self.copyWith(
      itineraryId: null == itineraryId
          ? _self.itineraryId
          : itineraryId // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination,
      tripDates: null == tripDates
          ? _self.tripDates
          : tripDates // ignore: cast_nullable_to_non_nullable
              as DateRange,
      interests: null == interests
          ? _self.interests
          : interests // ignore: cast_nullable_to_non_nullable
              as Set<TravelInterest>,
      hotelLocation: freezed == hotelLocation
          ? _self.hotelLocation
          : hotelLocation // ignore: cast_nullable_to_non_nullable
              as HotelLocation?,
      budget: freezed == budget
          ? _self.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as BudgetRange?,
      categories: freezed == categories
          ? _self.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as Set<RecommendationCategory>?,
      weatherPreference: freezed == weatherPreference
          ? _self.weatherPreference
          : weatherPreference // ignore: cast_nullable_to_non_nullable
              as Set<WeatherContext>?,
      maxDistance: freezed == maxDistance
          ? _self.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as DistanceFromHotel?,
      limit: null == limit
          ? _self.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      excludeItineraryItems: null == excludeItineraryItems
          ? _self.excludeItineraryItems
          : excludeItineraryItems // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res> get destination {
    return $DestinationCopyWith<$Res>(_self.destination, (value) {
      return _then(_self.copyWith(destination: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DateRangeCopyWith<$Res> get tripDates {
    return $DateRangeCopyWith<$Res>(_self.tripDates, (value) {
      return _then(_self.copyWith(tripDates: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HotelLocationCopyWith<$Res>? get hotelLocation {
    if (_self.hotelLocation == null) {
      return null;
    }

    return $HotelLocationCopyWith<$Res>(_self.hotelLocation!, (value) {
      return _then(_self.copyWith(hotelLocation: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BudgetRangeCopyWith<$Res>? get budget {
    if (_self.budget == null) {
      return null;
    }

    return $BudgetRangeCopyWith<$Res>(_self.budget!, (value) {
      return _then(_self.copyWith(budget: value));
    });
  }
}

/// Adds pattern-matching-related methods to [RecommendationRequest].
extension RecommendationRequestPatterns on RecommendationRequest {
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
    TResult Function(_RecommendationRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationRequest() when $default != null:
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
    TResult Function(_RecommendationRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationRequest():
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
    TResult? Function(_RecommendationRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationRequest() when $default != null:
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
            String itineraryId,
            Destination destination,
            DateRange tripDates,
            Set<TravelInterest> interests,
            HotelLocation? hotelLocation,
            BudgetRange? budget,
            Set<RecommendationCategory>? categories,
            Set<WeatherContext>? weatherPreference,
            DistanceFromHotel? maxDistance,
            int limit,
            bool excludeItineraryItems)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationRequest() when $default != null:
        return $default(
            _that.itineraryId,
            _that.destination,
            _that.tripDates,
            _that.interests,
            _that.hotelLocation,
            _that.budget,
            _that.categories,
            _that.weatherPreference,
            _that.maxDistance,
            _that.limit,
            _that.excludeItineraryItems);
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
            String itineraryId,
            Destination destination,
            DateRange tripDates,
            Set<TravelInterest> interests,
            HotelLocation? hotelLocation,
            BudgetRange? budget,
            Set<RecommendationCategory>? categories,
            Set<WeatherContext>? weatherPreference,
            DistanceFromHotel? maxDistance,
            int limit,
            bool excludeItineraryItems)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationRequest():
        return $default(
            _that.itineraryId,
            _that.destination,
            _that.tripDates,
            _that.interests,
            _that.hotelLocation,
            _that.budget,
            _that.categories,
            _that.weatherPreference,
            _that.maxDistance,
            _that.limit,
            _that.excludeItineraryItems);
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
            String itineraryId,
            Destination destination,
            DateRange tripDates,
            Set<TravelInterest> interests,
            HotelLocation? hotelLocation,
            BudgetRange? budget,
            Set<RecommendationCategory>? categories,
            Set<WeatherContext>? weatherPreference,
            DistanceFromHotel? maxDistance,
            int limit,
            bool excludeItineraryItems)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationRequest() when $default != null:
        return $default(
            _that.itineraryId,
            _that.destination,
            _that.tripDates,
            _that.interests,
            _that.hotelLocation,
            _that.budget,
            _that.categories,
            _that.weatherPreference,
            _that.maxDistance,
            _that.limit,
            _that.excludeItineraryItems);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _RecommendationRequest extends RecommendationRequest {
  const _RecommendationRequest(
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
  factory _RecommendationRequest.fromJson(Map<String, dynamic> json) =>
      _$RecommendationRequestFromJson(json);

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

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecommendationRequestCopyWith<_RecommendationRequest> get copyWith =>
      __$RecommendationRequestCopyWithImpl<_RecommendationRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RecommendationRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecommendationRequest &&
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

  @override
  String toString() {
    return 'RecommendationRequest(itineraryId: $itineraryId, destination: $destination, tripDates: $tripDates, interests: $interests, hotelLocation: $hotelLocation, budget: $budget, categories: $categories, weatherPreference: $weatherPreference, maxDistance: $maxDistance, limit: $limit, excludeItineraryItems: $excludeItineraryItems)';
  }
}

/// @nodoc
abstract mixin class _$RecommendationRequestCopyWith<$Res>
    implements $RecommendationRequestCopyWith<$Res> {
  factory _$RecommendationRequestCopyWith(_RecommendationRequest value,
          $Res Function(_RecommendationRequest) _then) =
      __$RecommendationRequestCopyWithImpl;
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
class __$RecommendationRequestCopyWithImpl<$Res>
    implements _$RecommendationRequestCopyWith<$Res> {
  __$RecommendationRequestCopyWithImpl(this._self, this._then);

  final _RecommendationRequest _self;
  final $Res Function(_RecommendationRequest) _then;

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_RecommendationRequest(
      itineraryId: null == itineraryId
          ? _self.itineraryId
          : itineraryId // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination,
      tripDates: null == tripDates
          ? _self.tripDates
          : tripDates // ignore: cast_nullable_to_non_nullable
              as DateRange,
      interests: null == interests
          ? _self._interests
          : interests // ignore: cast_nullable_to_non_nullable
              as Set<TravelInterest>,
      hotelLocation: freezed == hotelLocation
          ? _self.hotelLocation
          : hotelLocation // ignore: cast_nullable_to_non_nullable
              as HotelLocation?,
      budget: freezed == budget
          ? _self.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as BudgetRange?,
      categories: freezed == categories
          ? _self._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as Set<RecommendationCategory>?,
      weatherPreference: freezed == weatherPreference
          ? _self._weatherPreference
          : weatherPreference // ignore: cast_nullable_to_non_nullable
              as Set<WeatherContext>?,
      maxDistance: freezed == maxDistance
          ? _self.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as DistanceFromHotel?,
      limit: null == limit
          ? _self.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      excludeItineraryItems: null == excludeItineraryItems
          ? _self.excludeItineraryItems
          : excludeItineraryItems // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res> get destination {
    return $DestinationCopyWith<$Res>(_self.destination, (value) {
      return _then(_self.copyWith(destination: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DateRangeCopyWith<$Res> get tripDates {
    return $DateRangeCopyWith<$Res>(_self.tripDates, (value) {
      return _then(_self.copyWith(tripDates: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HotelLocationCopyWith<$Res>? get hotelLocation {
    if (_self.hotelLocation == null) {
      return null;
    }

    return $HotelLocationCopyWith<$Res>(_self.hotelLocation!, (value) {
      return _then(_self.copyWith(hotelLocation: value));
    });
  }

  /// Create a copy of RecommendationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BudgetRangeCopyWith<$Res>? get budget {
    if (_self.budget == null) {
      return null;
    }

    return $BudgetRangeCopyWith<$Res>(_self.budget!, (value) {
      return _then(_self.copyWith(budget: value));
    });
  }
}

/// @nodoc
mixin _$HotelLocation {
  String get name;
  String? get address;
  double get latitude;
  double get longitude;

  /// Create a copy of HotelLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HotelLocationCopyWith<HotelLocation> get copyWith =>
      _$HotelLocationCopyWithImpl<HotelLocation>(
          this as HotelLocation, _$identity);

  /// Serializes this HotelLocation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HotelLocation &&
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

  @override
  String toString() {
    return 'HotelLocation(name: $name, address: $address, latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class $HotelLocationCopyWith<$Res> {
  factory $HotelLocationCopyWith(
          HotelLocation value, $Res Function(HotelLocation) _then) =
      _$HotelLocationCopyWithImpl;
  @useResult
  $Res call({String name, String? address, double latitude, double longitude});
}

/// @nodoc
class _$HotelLocationCopyWithImpl<$Res>
    implements $HotelLocationCopyWith<$Res> {
  _$HotelLocationCopyWithImpl(this._self, this._then);

  final HotelLocation _self;
  final $Res Function(HotelLocation) _then;

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
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [HotelLocation].
extension HotelLocationPatterns on HotelLocation {
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
    TResult Function(_HotelLocation value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HotelLocation() when $default != null:
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
    TResult Function(_HotelLocation value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HotelLocation():
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
    TResult? Function(_HotelLocation value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HotelLocation() when $default != null:
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
            String name, String? address, double latitude, double longitude)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HotelLocation() when $default != null:
        return $default(
            _that.name, _that.address, _that.latitude, _that.longitude);
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
            String name, String? address, double latitude, double longitude)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HotelLocation():
        return $default(
            _that.name, _that.address, _that.latitude, _that.longitude);
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
            String name, String? address, double latitude, double longitude)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HotelLocation() when $default != null:
        return $default(
            _that.name, _that.address, _that.latitude, _that.longitude);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HotelLocation implements HotelLocation {
  const _HotelLocation(
      {required this.name,
      this.address,
      required this.latitude,
      required this.longitude});
  factory _HotelLocation.fromJson(Map<String, dynamic> json) =>
      _$HotelLocationFromJson(json);

  @override
  final String name;
  @override
  final String? address;
  @override
  final double latitude;
  @override
  final double longitude;

  /// Create a copy of HotelLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HotelLocationCopyWith<_HotelLocation> get copyWith =>
      __$HotelLocationCopyWithImpl<_HotelLocation>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HotelLocationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HotelLocation &&
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

  @override
  String toString() {
    return 'HotelLocation(name: $name, address: $address, latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class _$HotelLocationCopyWith<$Res>
    implements $HotelLocationCopyWith<$Res> {
  factory _$HotelLocationCopyWith(
          _HotelLocation value, $Res Function(_HotelLocation) _then) =
      __$HotelLocationCopyWithImpl;
  @override
  @useResult
  $Res call({String name, String? address, double latitude, double longitude});
}

/// @nodoc
class __$HotelLocationCopyWithImpl<$Res>
    implements _$HotelLocationCopyWith<$Res> {
  __$HotelLocationCopyWithImpl(this._self, this._then);

  final _HotelLocation _self;
  final $Res Function(_HotelLocation) _then;

  /// Create a copy of HotelLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? address = freezed,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(_HotelLocation(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$BudgetRange {
  double? get min;
  double? get max;
  String get currency;

  /// Create a copy of BudgetRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BudgetRangeCopyWith<BudgetRange> get copyWith =>
      _$BudgetRangeCopyWithImpl<BudgetRange>(this as BudgetRange, _$identity);

  /// Serializes this BudgetRange to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BudgetRange &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, min, max, currency);

  @override
  String toString() {
    return 'BudgetRange(min: $min, max: $max, currency: $currency)';
  }
}

/// @nodoc
abstract mixin class $BudgetRangeCopyWith<$Res> {
  factory $BudgetRangeCopyWith(
          BudgetRange value, $Res Function(BudgetRange) _then) =
      _$BudgetRangeCopyWithImpl;
  @useResult
  $Res call({double? min, double? max, String currency});
}

/// @nodoc
class _$BudgetRangeCopyWithImpl<$Res> implements $BudgetRangeCopyWith<$Res> {
  _$BudgetRangeCopyWithImpl(this._self, this._then);

  final BudgetRange _self;
  final $Res Function(BudgetRange) _then;

  /// Create a copy of BudgetRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = freezed,
    Object? max = freezed,
    Object? currency = null,
  }) {
    return _then(_self.copyWith(
      min: freezed == min
          ? _self.min
          : min // ignore: cast_nullable_to_non_nullable
              as double?,
      max: freezed == max
          ? _self.max
          : max // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [BudgetRange].
extension BudgetRangePatterns on BudgetRange {
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
    TResult Function(_BudgetRange value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BudgetRange() when $default != null:
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
    TResult Function(_BudgetRange value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BudgetRange():
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
    TResult? Function(_BudgetRange value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BudgetRange() when $default != null:
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
    TResult Function(double? min, double? max, String currency)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BudgetRange() when $default != null:
        return $default(_that.min, _that.max, _that.currency);
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
    TResult Function(double? min, double? max, String currency) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BudgetRange():
        return $default(_that.min, _that.max, _that.currency);
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
    TResult? Function(double? min, double? max, String currency)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BudgetRange() when $default != null:
        return $default(_that.min, _that.max, _that.currency);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _BudgetRange extends BudgetRange {
  const _BudgetRange({this.min, this.max, this.currency = 'USD'}) : super._();
  factory _BudgetRange.fromJson(Map<String, dynamic> json) =>
      _$BudgetRangeFromJson(json);

  @override
  final double? min;
  @override
  final double? max;
  @override
  @JsonKey()
  final String currency;

  /// Create a copy of BudgetRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BudgetRangeCopyWith<_BudgetRange> get copyWith =>
      __$BudgetRangeCopyWithImpl<_BudgetRange>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BudgetRangeToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BudgetRange &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, min, max, currency);

  @override
  String toString() {
    return 'BudgetRange(min: $min, max: $max, currency: $currency)';
  }
}

/// @nodoc
abstract mixin class _$BudgetRangeCopyWith<$Res>
    implements $BudgetRangeCopyWith<$Res> {
  factory _$BudgetRangeCopyWith(
          _BudgetRange value, $Res Function(_BudgetRange) _then) =
      __$BudgetRangeCopyWithImpl;
  @override
  @useResult
  $Res call({double? min, double? max, String currency});
}

/// @nodoc
class __$BudgetRangeCopyWithImpl<$Res> implements _$BudgetRangeCopyWith<$Res> {
  __$BudgetRangeCopyWithImpl(this._self, this._then);

  final _BudgetRange _self;
  final $Res Function(_BudgetRange) _then;

  /// Create a copy of BudgetRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? min = freezed,
    Object? max = freezed,
    Object? currency = null,
  }) {
    return _then(_BudgetRange(
      min: freezed == min
          ? _self.min
          : min // ignore: cast_nullable_to_non_nullable
              as double?,
      max: freezed == max
          ? _self.max
          : max // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
