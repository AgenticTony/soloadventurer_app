// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PersonalizedRecommendation {
  String get id;
  PlaceActivity get activity;
  RecommendationMetadata get metadata;
  String get reasoning;
  double get relevanceScore;
  RecommendationSource get source;
  bool get isSaved;
  bool get isAddedToItinerary;

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PersonalizedRecommendationCopyWith<PersonalizedRecommendation>
      get copyWith =>
          _$PersonalizedRecommendationCopyWithImpl<PersonalizedRecommendation>(
              this as PersonalizedRecommendation, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PersonalizedRecommendation &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other.activity, activity) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning) &&
            (identical(other.relevanceScore, relevanceScore) ||
                other.relevanceScore == relevanceScore) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.isSaved, isSaved) || other.isSaved == isSaved) &&
            (identical(other.isAddedToItinerary, isAddedToItinerary) ||
                other.isAddedToItinerary == isAddedToItinerary));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(activity),
      metadata,
      reasoning,
      relevanceScore,
      source,
      isSaved,
      isAddedToItinerary);

  @override
  String toString() {
    return 'PersonalizedRecommendation(id: $id, activity: $activity, metadata: $metadata, reasoning: $reasoning, relevanceScore: $relevanceScore, source: $source, isSaved: $isSaved, isAddedToItinerary: $isAddedToItinerary)';
  }
}

/// @nodoc
abstract mixin class $PersonalizedRecommendationCopyWith<$Res> {
  factory $PersonalizedRecommendationCopyWith(PersonalizedRecommendation value,
          $Res Function(PersonalizedRecommendation) _then) =
      _$PersonalizedRecommendationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      PlaceActivity activity,
      RecommendationMetadata metadata,
      String reasoning,
      double relevanceScore,
      RecommendationSource source,
      bool isSaved,
      bool isAddedToItinerary});

  $RecommendationMetadataCopyWith<$Res> get metadata;
}

/// @nodoc
class _$PersonalizedRecommendationCopyWithImpl<$Res>
    implements $PersonalizedRecommendationCopyWith<$Res> {
  _$PersonalizedRecommendationCopyWithImpl(this._self, this._then);

  final PersonalizedRecommendation _self;
  final $Res Function(PersonalizedRecommendation) _then;

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activity = freezed,
    Object? metadata = null,
    Object? reasoning = null,
    Object? relevanceScore = null,
    Object? source = null,
    Object? isSaved = null,
    Object? isAddedToItinerary = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      activity: freezed == activity
          ? _self.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as PlaceActivity,
      metadata: null == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as RecommendationMetadata,
      reasoning: null == reasoning
          ? _self.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String,
      relevanceScore: null == relevanceScore
          ? _self.relevanceScore
          : relevanceScore // ignore: cast_nullable_to_non_nullable
              as double,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as RecommendationSource,
      isSaved: null == isSaved
          ? _self.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      isAddedToItinerary: null == isAddedToItinerary
          ? _self.isAddedToItinerary
          : isAddedToItinerary // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecommendationMetadataCopyWith<$Res> get metadata {
    return $RecommendationMetadataCopyWith<$Res>(_self.metadata, (value) {
      return _then(_self.copyWith(metadata: value));
    });
  }
}

/// Adds pattern-matching-related methods to [PersonalizedRecommendation].
extension PersonalizedRecommendationPatterns on PersonalizedRecommendation {
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
    TResult Function(_PersonalizedRecommendation value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PersonalizedRecommendation() when $default != null:
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
    TResult Function(_PersonalizedRecommendation value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalizedRecommendation():
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
    TResult? Function(_PersonalizedRecommendation value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalizedRecommendation() when $default != null:
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
            PlaceActivity activity,
            RecommendationMetadata metadata,
            String reasoning,
            double relevanceScore,
            RecommendationSource source,
            bool isSaved,
            bool isAddedToItinerary)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PersonalizedRecommendation() when $default != null:
        return $default(
            _that.id,
            _that.activity,
            _that.metadata,
            _that.reasoning,
            _that.relevanceScore,
            _that.source,
            _that.isSaved,
            _that.isAddedToItinerary);
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
            PlaceActivity activity,
            RecommendationMetadata metadata,
            String reasoning,
            double relevanceScore,
            RecommendationSource source,
            bool isSaved,
            bool isAddedToItinerary)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalizedRecommendation():
        return $default(
            _that.id,
            _that.activity,
            _that.metadata,
            _that.reasoning,
            _that.relevanceScore,
            _that.source,
            _that.isSaved,
            _that.isAddedToItinerary);
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
            PlaceActivity activity,
            RecommendationMetadata metadata,
            String reasoning,
            double relevanceScore,
            RecommendationSource source,
            bool isSaved,
            bool isAddedToItinerary)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalizedRecommendation() when $default != null:
        return $default(
            _that.id,
            _that.activity,
            _that.metadata,
            _that.reasoning,
            _that.relevanceScore,
            _that.source,
            _that.isSaved,
            _that.isAddedToItinerary);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PersonalizedRecommendation extends PersonalizedRecommendation {
  const _PersonalizedRecommendation(
      {required this.id,
      required this.activity,
      required this.metadata,
      required this.reasoning,
      this.relevanceScore = 0.0,
      this.source = RecommendationSource.personalized,
      this.isSaved = false,
      this.isAddedToItinerary = false})
      : super._();

  @override
  final String id;
  @override
  final PlaceActivity activity;
  @override
  final RecommendationMetadata metadata;
  @override
  final String reasoning;
  @override
  @JsonKey()
  final double relevanceScore;
  @override
  @JsonKey()
  final RecommendationSource source;
  @override
  @JsonKey()
  final bool isSaved;
  @override
  @JsonKey()
  final bool isAddedToItinerary;

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PersonalizedRecommendationCopyWith<_PersonalizedRecommendation>
      get copyWith => __$PersonalizedRecommendationCopyWithImpl<
          _PersonalizedRecommendation>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PersonalizedRecommendation &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other.activity, activity) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning) &&
            (identical(other.relevanceScore, relevanceScore) ||
                other.relevanceScore == relevanceScore) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.isSaved, isSaved) || other.isSaved == isSaved) &&
            (identical(other.isAddedToItinerary, isAddedToItinerary) ||
                other.isAddedToItinerary == isAddedToItinerary));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(activity),
      metadata,
      reasoning,
      relevanceScore,
      source,
      isSaved,
      isAddedToItinerary);

  @override
  String toString() {
    return 'PersonalizedRecommendation(id: $id, activity: $activity, metadata: $metadata, reasoning: $reasoning, relevanceScore: $relevanceScore, source: $source, isSaved: $isSaved, isAddedToItinerary: $isAddedToItinerary)';
  }
}

/// @nodoc
abstract mixin class _$PersonalizedRecommendationCopyWith<$Res>
    implements $PersonalizedRecommendationCopyWith<$Res> {
  factory _$PersonalizedRecommendationCopyWith(
          _PersonalizedRecommendation value,
          $Res Function(_PersonalizedRecommendation) _then) =
      __$PersonalizedRecommendationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      PlaceActivity activity,
      RecommendationMetadata metadata,
      String reasoning,
      double relevanceScore,
      RecommendationSource source,
      bool isSaved,
      bool isAddedToItinerary});

  @override
  $RecommendationMetadataCopyWith<$Res> get metadata;
}

/// @nodoc
class __$PersonalizedRecommendationCopyWithImpl<$Res>
    implements _$PersonalizedRecommendationCopyWith<$Res> {
  __$PersonalizedRecommendationCopyWithImpl(this._self, this._then);

  final _PersonalizedRecommendation _self;
  final $Res Function(_PersonalizedRecommendation) _then;

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? activity = freezed,
    Object? metadata = null,
    Object? reasoning = null,
    Object? relevanceScore = null,
    Object? source = null,
    Object? isSaved = null,
    Object? isAddedToItinerary = null,
  }) {
    return _then(_PersonalizedRecommendation(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      activity: freezed == activity
          ? _self.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as PlaceActivity,
      metadata: null == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as RecommendationMetadata,
      reasoning: null == reasoning
          ? _self.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String,
      relevanceScore: null == relevanceScore
          ? _self.relevanceScore
          : relevanceScore // ignore: cast_nullable_to_non_nullable
              as double,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as RecommendationSource,
      isSaved: null == isSaved
          ? _self.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      isAddedToItinerary: null == isAddedToItinerary
          ? _self.isAddedToItinerary
          : isAddedToItinerary // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecommendationMetadataCopyWith<$Res> get metadata {
    return $RecommendationMetadataCopyWith<$Res>(_self.metadata, (value) {
      return _then(_self.copyWith(metadata: value));
    });
  }
}

/// @nodoc
mixin _$RecommendationMetadata {
  Set<TravelInterest> get matchedInterests;
  DateTime get suggestedDate;
  TimeOfDay get suggestedTime;
  DistanceFromHotel get distance;
  WeatherContext get weather;
  CrowdLevel get crowdLevel;
  Money? get estimatedCost;
  Duration get estimatedDuration;
  String? get bookingUrl;
  bool get requiresAdvanceBooking;
  bool get isIndoor;

  /// Create a copy of RecommendationMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecommendationMetadataCopyWith<RecommendationMetadata> get copyWith =>
      _$RecommendationMetadataCopyWithImpl<RecommendationMetadata>(
          this as RecommendationMetadata, _$identity);

  /// Serializes this RecommendationMetadata to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecommendationMetadata &&
            const DeepCollectionEquality()
                .equals(other.matchedInterests, matchedInterests) &&
            (identical(other.suggestedDate, suggestedDate) ||
                other.suggestedDate == suggestedDate) &&
            (identical(other.suggestedTime, suggestedTime) ||
                other.suggestedTime == suggestedTime) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.weather, weather) || other.weather == weather) &&
            (identical(other.crowdLevel, crowdLevel) ||
                other.crowdLevel == crowdLevel) &&
            (identical(other.estimatedCost, estimatedCost) ||
                other.estimatedCost == estimatedCost) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration) &&
            (identical(other.bookingUrl, bookingUrl) ||
                other.bookingUrl == bookingUrl) &&
            (identical(other.requiresAdvanceBooking, requiresAdvanceBooking) ||
                other.requiresAdvanceBooking == requiresAdvanceBooking) &&
            (identical(other.isIndoor, isIndoor) ||
                other.isIndoor == isIndoor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(matchedInterests),
      suggestedDate,
      suggestedTime,
      distance,
      weather,
      crowdLevel,
      estimatedCost,
      estimatedDuration,
      bookingUrl,
      requiresAdvanceBooking,
      isIndoor);

  @override
  String toString() {
    return 'RecommendationMetadata(matchedInterests: $matchedInterests, suggestedDate: $suggestedDate, suggestedTime: $suggestedTime, distance: $distance, weather: $weather, crowdLevel: $crowdLevel, estimatedCost: $estimatedCost, estimatedDuration: $estimatedDuration, bookingUrl: $bookingUrl, requiresAdvanceBooking: $requiresAdvanceBooking, isIndoor: $isIndoor)';
  }
}

/// @nodoc
abstract mixin class $RecommendationMetadataCopyWith<$Res> {
  factory $RecommendationMetadataCopyWith(RecommendationMetadata value,
          $Res Function(RecommendationMetadata) _then) =
      _$RecommendationMetadataCopyWithImpl;
  @useResult
  $Res call(
      {Set<TravelInterest> matchedInterests,
      DateTime suggestedDate,
      TimeOfDay suggestedTime,
      DistanceFromHotel distance,
      WeatherContext weather,
      CrowdLevel crowdLevel,
      Money? estimatedCost,
      Duration estimatedDuration,
      String? bookingUrl,
      bool requiresAdvanceBooking,
      bool isIndoor});

  $TimeOfDayCopyWith<$Res> get suggestedTime;
  $MoneyCopyWith<$Res>? get estimatedCost;
}

/// @nodoc
class _$RecommendationMetadataCopyWithImpl<$Res>
    implements $RecommendationMetadataCopyWith<$Res> {
  _$RecommendationMetadataCopyWithImpl(this._self, this._then);

  final RecommendationMetadata _self;
  final $Res Function(RecommendationMetadata) _then;

  /// Create a copy of RecommendationMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matchedInterests = null,
    Object? suggestedDate = null,
    Object? suggestedTime = null,
    Object? distance = null,
    Object? weather = null,
    Object? crowdLevel = null,
    Object? estimatedCost = freezed,
    Object? estimatedDuration = null,
    Object? bookingUrl = freezed,
    Object? requiresAdvanceBooking = null,
    Object? isIndoor = null,
  }) {
    return _then(_self.copyWith(
      matchedInterests: null == matchedInterests
          ? _self.matchedInterests
          : matchedInterests // ignore: cast_nullable_to_non_nullable
              as Set<TravelInterest>,
      suggestedDate: null == suggestedDate
          ? _self.suggestedDate
          : suggestedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      suggestedTime: null == suggestedTime
          ? _self.suggestedTime
          : suggestedTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as DistanceFromHotel,
      weather: null == weather
          ? _self.weather
          : weather // ignore: cast_nullable_to_non_nullable
              as WeatherContext,
      crowdLevel: null == crowdLevel
          ? _self.crowdLevel
          : crowdLevel // ignore: cast_nullable_to_non_nullable
              as CrowdLevel,
      estimatedCost: freezed == estimatedCost
          ? _self.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as Money?,
      estimatedDuration: null == estimatedDuration
          ? _self.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      bookingUrl: freezed == bookingUrl
          ? _self.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      requiresAdvanceBooking: null == requiresAdvanceBooking
          ? _self.requiresAdvanceBooking
          : requiresAdvanceBooking // ignore: cast_nullable_to_non_nullable
              as bool,
      isIndoor: null == isIndoor
          ? _self.isIndoor
          : isIndoor // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of RecommendationMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayCopyWith<$Res> get suggestedTime {
    return $TimeOfDayCopyWith<$Res>(_self.suggestedTime, (value) {
      return _then(_self.copyWith(suggestedTime: value));
    });
  }

  /// Create a copy of RecommendationMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MoneyCopyWith<$Res>? get estimatedCost {
    if (_self.estimatedCost == null) {
      return null;
    }

    return $MoneyCopyWith<$Res>(_self.estimatedCost!, (value) {
      return _then(_self.copyWith(estimatedCost: value));
    });
  }
}

/// Adds pattern-matching-related methods to [RecommendationMetadata].
extension RecommendationMetadataPatterns on RecommendationMetadata {
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
    TResult Function(_RecommendationMetadata value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationMetadata() when $default != null:
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
    TResult Function(_RecommendationMetadata value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationMetadata():
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
    TResult? Function(_RecommendationMetadata value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationMetadata() when $default != null:
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
            Set<TravelInterest> matchedInterests,
            DateTime suggestedDate,
            TimeOfDay suggestedTime,
            DistanceFromHotel distance,
            WeatherContext weather,
            CrowdLevel crowdLevel,
            Money? estimatedCost,
            Duration estimatedDuration,
            String? bookingUrl,
            bool requiresAdvanceBooking,
            bool isIndoor)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendationMetadata() when $default != null:
        return $default(
            _that.matchedInterests,
            _that.suggestedDate,
            _that.suggestedTime,
            _that.distance,
            _that.weather,
            _that.crowdLevel,
            _that.estimatedCost,
            _that.estimatedDuration,
            _that.bookingUrl,
            _that.requiresAdvanceBooking,
            _that.isIndoor);
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
            Set<TravelInterest> matchedInterests,
            DateTime suggestedDate,
            TimeOfDay suggestedTime,
            DistanceFromHotel distance,
            WeatherContext weather,
            CrowdLevel crowdLevel,
            Money? estimatedCost,
            Duration estimatedDuration,
            String? bookingUrl,
            bool requiresAdvanceBooking,
            bool isIndoor)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationMetadata():
        return $default(
            _that.matchedInterests,
            _that.suggestedDate,
            _that.suggestedTime,
            _that.distance,
            _that.weather,
            _that.crowdLevel,
            _that.estimatedCost,
            _that.estimatedDuration,
            _that.bookingUrl,
            _that.requiresAdvanceBooking,
            _that.isIndoor);
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
            Set<TravelInterest> matchedInterests,
            DateTime suggestedDate,
            TimeOfDay suggestedTime,
            DistanceFromHotel distance,
            WeatherContext weather,
            CrowdLevel crowdLevel,
            Money? estimatedCost,
            Duration estimatedDuration,
            String? bookingUrl,
            bool requiresAdvanceBooking,
            bool isIndoor)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendationMetadata() when $default != null:
        return $default(
            _that.matchedInterests,
            _that.suggestedDate,
            _that.suggestedTime,
            _that.distance,
            _that.weather,
            _that.crowdLevel,
            _that.estimatedCost,
            _that.estimatedDuration,
            _that.bookingUrl,
            _that.requiresAdvanceBooking,
            _that.isIndoor);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _RecommendationMetadata extends RecommendationMetadata {
  const _RecommendationMetadata(
      {required final Set<TravelInterest> matchedInterests,
      required this.suggestedDate,
      required this.suggestedTime,
      required this.distance,
      required this.weather,
      required this.crowdLevel,
      this.estimatedCost,
      this.estimatedDuration = Duration.zero,
      this.bookingUrl,
      this.requiresAdvanceBooking = false,
      this.isIndoor = false})
      : _matchedInterests = matchedInterests,
        super._();
  factory _RecommendationMetadata.fromJson(Map<String, dynamic> json) =>
      _$RecommendationMetadataFromJson(json);

  final Set<TravelInterest> _matchedInterests;
  @override
  Set<TravelInterest> get matchedInterests {
    if (_matchedInterests is EqualUnmodifiableSetView) return _matchedInterests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_matchedInterests);
  }

  @override
  final DateTime suggestedDate;
  @override
  final TimeOfDay suggestedTime;
  @override
  final DistanceFromHotel distance;
  @override
  final WeatherContext weather;
  @override
  final CrowdLevel crowdLevel;
  @override
  final Money? estimatedCost;
  @override
  @JsonKey()
  final Duration estimatedDuration;
  @override
  final String? bookingUrl;
  @override
  @JsonKey()
  final bool requiresAdvanceBooking;
  @override
  @JsonKey()
  final bool isIndoor;

  /// Create a copy of RecommendationMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecommendationMetadataCopyWith<_RecommendationMetadata> get copyWith =>
      __$RecommendationMetadataCopyWithImpl<_RecommendationMetadata>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RecommendationMetadataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecommendationMetadata &&
            const DeepCollectionEquality()
                .equals(other._matchedInterests, _matchedInterests) &&
            (identical(other.suggestedDate, suggestedDate) ||
                other.suggestedDate == suggestedDate) &&
            (identical(other.suggestedTime, suggestedTime) ||
                other.suggestedTime == suggestedTime) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.weather, weather) || other.weather == weather) &&
            (identical(other.crowdLevel, crowdLevel) ||
                other.crowdLevel == crowdLevel) &&
            (identical(other.estimatedCost, estimatedCost) ||
                other.estimatedCost == estimatedCost) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration) &&
            (identical(other.bookingUrl, bookingUrl) ||
                other.bookingUrl == bookingUrl) &&
            (identical(other.requiresAdvanceBooking, requiresAdvanceBooking) ||
                other.requiresAdvanceBooking == requiresAdvanceBooking) &&
            (identical(other.isIndoor, isIndoor) ||
                other.isIndoor == isIndoor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_matchedInterests),
      suggestedDate,
      suggestedTime,
      distance,
      weather,
      crowdLevel,
      estimatedCost,
      estimatedDuration,
      bookingUrl,
      requiresAdvanceBooking,
      isIndoor);

  @override
  String toString() {
    return 'RecommendationMetadata(matchedInterests: $matchedInterests, suggestedDate: $suggestedDate, suggestedTime: $suggestedTime, distance: $distance, weather: $weather, crowdLevel: $crowdLevel, estimatedCost: $estimatedCost, estimatedDuration: $estimatedDuration, bookingUrl: $bookingUrl, requiresAdvanceBooking: $requiresAdvanceBooking, isIndoor: $isIndoor)';
  }
}

/// @nodoc
abstract mixin class _$RecommendationMetadataCopyWith<$Res>
    implements $RecommendationMetadataCopyWith<$Res> {
  factory _$RecommendationMetadataCopyWith(_RecommendationMetadata value,
          $Res Function(_RecommendationMetadata) _then) =
      __$RecommendationMetadataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Set<TravelInterest> matchedInterests,
      DateTime suggestedDate,
      TimeOfDay suggestedTime,
      DistanceFromHotel distance,
      WeatherContext weather,
      CrowdLevel crowdLevel,
      Money? estimatedCost,
      Duration estimatedDuration,
      String? bookingUrl,
      bool requiresAdvanceBooking,
      bool isIndoor});

  @override
  $TimeOfDayCopyWith<$Res> get suggestedTime;
  @override
  $MoneyCopyWith<$Res>? get estimatedCost;
}

/// @nodoc
class __$RecommendationMetadataCopyWithImpl<$Res>
    implements _$RecommendationMetadataCopyWith<$Res> {
  __$RecommendationMetadataCopyWithImpl(this._self, this._then);

  final _RecommendationMetadata _self;
  final $Res Function(_RecommendationMetadata) _then;

  /// Create a copy of RecommendationMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? matchedInterests = null,
    Object? suggestedDate = null,
    Object? suggestedTime = null,
    Object? distance = null,
    Object? weather = null,
    Object? crowdLevel = null,
    Object? estimatedCost = freezed,
    Object? estimatedDuration = null,
    Object? bookingUrl = freezed,
    Object? requiresAdvanceBooking = null,
    Object? isIndoor = null,
  }) {
    return _then(_RecommendationMetadata(
      matchedInterests: null == matchedInterests
          ? _self._matchedInterests
          : matchedInterests // ignore: cast_nullable_to_non_nullable
              as Set<TravelInterest>,
      suggestedDate: null == suggestedDate
          ? _self.suggestedDate
          : suggestedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      suggestedTime: null == suggestedTime
          ? _self.suggestedTime
          : suggestedTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as DistanceFromHotel,
      weather: null == weather
          ? _self.weather
          : weather // ignore: cast_nullable_to_non_nullable
              as WeatherContext,
      crowdLevel: null == crowdLevel
          ? _self.crowdLevel
          : crowdLevel // ignore: cast_nullable_to_non_nullable
              as CrowdLevel,
      estimatedCost: freezed == estimatedCost
          ? _self.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as Money?,
      estimatedDuration: null == estimatedDuration
          ? _self.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      bookingUrl: freezed == bookingUrl
          ? _self.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      requiresAdvanceBooking: null == requiresAdvanceBooking
          ? _self.requiresAdvanceBooking
          : requiresAdvanceBooking // ignore: cast_nullable_to_non_nullable
              as bool,
      isIndoor: null == isIndoor
          ? _self.isIndoor
          : isIndoor // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of RecommendationMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayCopyWith<$Res> get suggestedTime {
    return $TimeOfDayCopyWith<$Res>(_self.suggestedTime, (value) {
      return _then(_self.copyWith(suggestedTime: value));
    });
  }

  /// Create a copy of RecommendationMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MoneyCopyWith<$Res>? get estimatedCost {
    if (_self.estimatedCost == null) {
      return null;
    }

    return $MoneyCopyWith<$Res>(_self.estimatedCost!, (value) {
      return _then(_self.copyWith(estimatedCost: value));
    });
  }
}

/// @nodoc
mixin _$TimeOfDay {
  int get hour;
  int get minute;

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TimeOfDayCopyWith<TimeOfDay> get copyWith =>
      _$TimeOfDayCopyWithImpl<TimeOfDay>(this as TimeOfDay, _$identity);

  /// Serializes this TimeOfDay to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TimeOfDay &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute);

  @override
  String toString() {
    return 'TimeOfDay(hour: $hour, minute: $minute)';
  }
}

/// @nodoc
abstract mixin class $TimeOfDayCopyWith<$Res> {
  factory $TimeOfDayCopyWith(TimeOfDay value, $Res Function(TimeOfDay) _then) =
      _$TimeOfDayCopyWithImpl;
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class _$TimeOfDayCopyWithImpl<$Res> implements $TimeOfDayCopyWith<$Res> {
  _$TimeOfDayCopyWithImpl(this._self, this._then);

  final TimeOfDay _self;
  final $Res Function(TimeOfDay) _then;

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
  }) {
    return _then(_self.copyWith(
      hour: null == hour
          ? _self.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _self.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [TimeOfDay].
extension TimeOfDayPatterns on TimeOfDay {
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
    TResult Function(_TimeOfDay value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TimeOfDay() when $default != null:
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
    TResult Function(_TimeOfDay value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TimeOfDay():
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
    TResult? Function(_TimeOfDay value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TimeOfDay() when $default != null:
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
    TResult Function(int hour, int minute)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TimeOfDay() when $default != null:
        return $default(_that.hour, _that.minute);
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
    TResult Function(int hour, int minute) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TimeOfDay():
        return $default(_that.hour, _that.minute);
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
    TResult? Function(int hour, int minute)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TimeOfDay() when $default != null:
        return $default(_that.hour, _that.minute);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TimeOfDay extends TimeOfDay {
  const _TimeOfDay({required this.hour, this.minute = 0}) : super._();
  factory _TimeOfDay.fromJson(Map<String, dynamic> json) =>
      _$TimeOfDayFromJson(json);

  @override
  final int hour;
  @override
  @JsonKey()
  final int minute;

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TimeOfDayCopyWith<_TimeOfDay> get copyWith =>
      __$TimeOfDayCopyWithImpl<_TimeOfDay>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TimeOfDayToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TimeOfDay &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute);

  @override
  String toString() {
    return 'TimeOfDay(hour: $hour, minute: $minute)';
  }
}

/// @nodoc
abstract mixin class _$TimeOfDayCopyWith<$Res>
    implements $TimeOfDayCopyWith<$Res> {
  factory _$TimeOfDayCopyWith(
          _TimeOfDay value, $Res Function(_TimeOfDay) _then) =
      __$TimeOfDayCopyWithImpl;
  @override
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class __$TimeOfDayCopyWithImpl<$Res> implements _$TimeOfDayCopyWith<$Res> {
  __$TimeOfDayCopyWithImpl(this._self, this._then);

  final _TimeOfDay _self;
  final $Res Function(_TimeOfDay) _then;

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? hour = null,
    Object? minute = null,
  }) {
    return _then(_TimeOfDay(
      hour: null == hour
          ? _self.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _self.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$Money {
  double get amount;
  String get currency;

  /// Create a copy of Money
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MoneyCopyWith<Money> get copyWith =>
      _$MoneyCopyWithImpl<Money>(this as Money, _$identity);

  /// Serializes this Money to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Money &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, amount, currency);

  @override
  String toString() {
    return 'Money(amount: $amount, currency: $currency)';
  }
}

/// @nodoc
abstract mixin class $MoneyCopyWith<$Res> {
  factory $MoneyCopyWith(Money value, $Res Function(Money) _then) =
      _$MoneyCopyWithImpl;
  @useResult
  $Res call({double amount, String currency});
}

/// @nodoc
class _$MoneyCopyWithImpl<$Res> implements $MoneyCopyWith<$Res> {
  _$MoneyCopyWithImpl(this._self, this._then);

  final Money _self;
  final $Res Function(Money) _then;

  /// Create a copy of Money
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? currency = null,
  }) {
    return _then(_self.copyWith(
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [Money].
extension MoneyPatterns on Money {
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
    TResult Function(_Money value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Money() when $default != null:
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
    TResult Function(_Money value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Money():
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
    TResult? Function(_Money value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Money() when $default != null:
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
    TResult Function(double amount, String currency)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Money() when $default != null:
        return $default(_that.amount, _that.currency);
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
    TResult Function(double amount, String currency) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Money():
        return $default(_that.amount, _that.currency);
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
    TResult? Function(double amount, String currency)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Money() when $default != null:
        return $default(_that.amount, _that.currency);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Money extends Money {
  const _Money({required this.amount, this.currency = 'USD'}) : super._();
  factory _Money.fromJson(Map<String, dynamic> json) => _$MoneyFromJson(json);

  @override
  final double amount;
  @override
  @JsonKey()
  final String currency;

  /// Create a copy of Money
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MoneyCopyWith<_Money> get copyWith =>
      __$MoneyCopyWithImpl<_Money>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MoneyToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Money &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, amount, currency);

  @override
  String toString() {
    return 'Money(amount: $amount, currency: $currency)';
  }
}

/// @nodoc
abstract mixin class _$MoneyCopyWith<$Res> implements $MoneyCopyWith<$Res> {
  factory _$MoneyCopyWith(_Money value, $Res Function(_Money) _then) =
      __$MoneyCopyWithImpl;
  @override
  @useResult
  $Res call({double amount, String currency});
}

/// @nodoc
class __$MoneyCopyWithImpl<$Res> implements _$MoneyCopyWith<$Res> {
  __$MoneyCopyWithImpl(this._self, this._then);

  final _Money _self;
  final $Res Function(_Money) _then;

  /// Create a copy of Money
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? amount = null,
    Object? currency = null,
  }) {
    return _then(_Money(
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
