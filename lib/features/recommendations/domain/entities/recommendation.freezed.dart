// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PersonalizedRecommendation {
  String get id => throw _privateConstructorUsedError;
  PlaceActivity get activity => throw _privateConstructorUsedError;
  RecommendationMetadata get metadata => throw _privateConstructorUsedError;
  String get reasoning => throw _privateConstructorUsedError;
  double get relevanceScore => throw _privateConstructorUsedError;
  RecommendationSource get source => throw _privateConstructorUsedError;
  bool get isSaved => throw _privateConstructorUsedError;
  bool get isAddedToItinerary => throw _privateConstructorUsedError;

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonalizedRecommendationCopyWith<PersonalizedRecommendation>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonalizedRecommendationCopyWith<$Res> {
  factory $PersonalizedRecommendationCopyWith(PersonalizedRecommendation value,
          $Res Function(PersonalizedRecommendation) then) =
      _$PersonalizedRecommendationCopyWithImpl<$Res,
          PersonalizedRecommendation>;
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

  $PlaceActivityCopyWith<$Res> get activity;
  $RecommendationMetadataCopyWith<$Res> get metadata;
}

/// @nodoc
class _$PersonalizedRecommendationCopyWithImpl<$Res,
        $Val extends PersonalizedRecommendation>
    implements $PersonalizedRecommendationCopyWith<$Res> {
  _$PersonalizedRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activity = null,
    Object? metadata = null,
    Object? reasoning = null,
    Object? relevanceScore = null,
    Object? source = null,
    Object? isSaved = null,
    Object? isAddedToItinerary = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      activity: null == activity
          ? _value.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as PlaceActivity,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as RecommendationMetadata,
      reasoning: null == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String,
      relevanceScore: null == relevanceScore
          ? _value.relevanceScore
          : relevanceScore // ignore: cast_nullable_to_non_nullable
              as double,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as RecommendationSource,
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      isAddedToItinerary: null == isAddedToItinerary
          ? _value.isAddedToItinerary
          : isAddedToItinerary // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlaceActivityCopyWith<$Res> get activity {
    return $PlaceActivityCopyWith<$Res>(_value.activity, (value) {
      return _then(_value.copyWith(activity: value) as $Val);
    });
  }

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecommendationMetadataCopyWith<$Res> get metadata {
    return $RecommendationMetadataCopyWith<$Res>(_value.metadata, (value) {
      return _then(_value.copyWith(metadata: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PersonalizedRecommendationImplCopyWith<$Res>
    implements $PersonalizedRecommendationCopyWith<$Res> {
  factory _$$PersonalizedRecommendationImplCopyWith(
          _$PersonalizedRecommendationImpl value,
          $Res Function(_$PersonalizedRecommendationImpl) then) =
      __$$PersonalizedRecommendationImplCopyWithImpl<$Res>;
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
  $PlaceActivityCopyWith<$Res> get activity;
  @override
  $RecommendationMetadataCopyWith<$Res> get metadata;
}

/// @nodoc
class __$$PersonalizedRecommendationImplCopyWithImpl<$Res>
    extends _$PersonalizedRecommendationCopyWithImpl<$Res,
        _$PersonalizedRecommendationImpl>
    implements _$$PersonalizedRecommendationImplCopyWith<$Res> {
  __$$PersonalizedRecommendationImplCopyWithImpl(
      _$PersonalizedRecommendationImpl _value,
      $Res Function(_$PersonalizedRecommendationImpl) _then)
      : super(_value, _then);

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activity = null,
    Object? metadata = null,
    Object? reasoning = null,
    Object? relevanceScore = null,
    Object? source = null,
    Object? isSaved = null,
    Object? isAddedToItinerary = null,
  }) {
    return _then(_$PersonalizedRecommendationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      activity: null == activity
          ? _value.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as PlaceActivity,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as RecommendationMetadata,
      reasoning: null == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String,
      relevanceScore: null == relevanceScore
          ? _value.relevanceScore
          : relevanceScore // ignore: cast_nullable_to_non_nullable
              as double,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as RecommendationSource,
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      isAddedToItinerary: null == isAddedToItinerary
          ? _value.isAddedToItinerary
          : isAddedToItinerary // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$PersonalizedRecommendationImpl extends _PersonalizedRecommendation {
  const _$PersonalizedRecommendationImpl(
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

  @override
  String toString() {
    return 'PersonalizedRecommendation(id: $id, activity: $activity, metadata: $metadata, reasoning: $reasoning, relevanceScore: $relevanceScore, source: $source, isSaved: $isSaved, isAddedToItinerary: $isAddedToItinerary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonalizedRecommendationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.activity, activity) ||
                other.activity == activity) &&
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
  int get hashCode => Object.hash(runtimeType, id, activity, metadata,
      reasoning, relevanceScore, source, isSaved, isAddedToItinerary);

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonalizedRecommendationImplCopyWith<_$PersonalizedRecommendationImpl>
      get copyWith => __$$PersonalizedRecommendationImplCopyWithImpl<
          _$PersonalizedRecommendationImpl>(this, _$identity);
}

abstract class _PersonalizedRecommendation extends PersonalizedRecommendation {
  const factory _PersonalizedRecommendation(
      {required final String id,
      required final PlaceActivity activity,
      required final RecommendationMetadata metadata,
      required final String reasoning,
      final double relevanceScore,
      final RecommendationSource source,
      final bool isSaved,
      final bool isAddedToItinerary}) = _$PersonalizedRecommendationImpl;
  const _PersonalizedRecommendation._() : super._();

  @override
  String get id;
  @override
  PlaceActivity get activity;
  @override
  RecommendationMetadata get metadata;
  @override
  String get reasoning;
  @override
  double get relevanceScore;
  @override
  RecommendationSource get source;
  @override
  bool get isSaved;
  @override
  bool get isAddedToItinerary;

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonalizedRecommendationImplCopyWith<_$PersonalizedRecommendationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RecommendationMetadata _$RecommendationMetadataFromJson(
    Map<String, dynamic> json) {
  return _RecommendationMetadata.fromJson(json);
}

/// @nodoc
mixin _$RecommendationMetadata {
  Set<TravelInterest> get matchedInterests =>
      throw _privateConstructorUsedError;
  DateTime get suggestedDate => throw _privateConstructorUsedError;
  TimeOfDay get suggestedTime => throw _privateConstructorUsedError;
  DistanceFromHotel get distance => throw _privateConstructorUsedError;
  WeatherContext get weather => throw _privateConstructorUsedError;
  CrowdLevel get crowdLevel => throw _privateConstructorUsedError;
  Money? get estimatedCost => throw _privateConstructorUsedError;
  Duration get estimatedDuration => throw _privateConstructorUsedError;
  String? get bookingUrl => throw _privateConstructorUsedError;
  bool get requiresAdvanceBooking => throw _privateConstructorUsedError;
  bool get isIndoor => throw _privateConstructorUsedError;

  /// Serializes this RecommendationMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationMetadataCopyWith<RecommendationMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationMetadataCopyWith<$Res> {
  factory $RecommendationMetadataCopyWith(RecommendationMetadata value,
          $Res Function(RecommendationMetadata) then) =
      _$RecommendationMetadataCopyWithImpl<$Res, RecommendationMetadata>;
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
class _$RecommendationMetadataCopyWithImpl<$Res,
        $Val extends RecommendationMetadata>
    implements $RecommendationMetadataCopyWith<$Res> {
  _$RecommendationMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      matchedInterests: null == matchedInterests
          ? _value.matchedInterests
          : matchedInterests // ignore: cast_nullable_to_non_nullable
              as Set<TravelInterest>,
      suggestedDate: null == suggestedDate
          ? _value.suggestedDate
          : suggestedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      suggestedTime: null == suggestedTime
          ? _value.suggestedTime
          : suggestedTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as DistanceFromHotel,
      weather: null == weather
          ? _value.weather
          : weather // ignore: cast_nullable_to_non_nullable
              as WeatherContext,
      crowdLevel: null == crowdLevel
          ? _value.crowdLevel
          : crowdLevel // ignore: cast_nullable_to_non_nullable
              as CrowdLevel,
      estimatedCost: freezed == estimatedCost
          ? _value.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as Money?,
      estimatedDuration: null == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      bookingUrl: freezed == bookingUrl
          ? _value.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      requiresAdvanceBooking: null == requiresAdvanceBooking
          ? _value.requiresAdvanceBooking
          : requiresAdvanceBooking // ignore: cast_nullable_to_non_nullable
              as bool,
      isIndoor: null == isIndoor
          ? _value.isIndoor
          : isIndoor // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of RecommendationMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayCopyWith<$Res> get suggestedTime {
    return $TimeOfDayCopyWith<$Res>(_value.suggestedTime, (value) {
      return _then(_value.copyWith(suggestedTime: value) as $Val);
    });
  }

  /// Create a copy of RecommendationMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MoneyCopyWith<$Res>? get estimatedCost {
    if (_value.estimatedCost == null) {
      return null;
    }

    return $MoneyCopyWith<$Res>(_value.estimatedCost!, (value) {
      return _then(_value.copyWith(estimatedCost: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecommendationMetadataImplCopyWith<$Res>
    implements $RecommendationMetadataCopyWith<$Res> {
  factory _$$RecommendationMetadataImplCopyWith(
          _$RecommendationMetadataImpl value,
          $Res Function(_$RecommendationMetadataImpl) then) =
      __$$RecommendationMetadataImplCopyWithImpl<$Res>;
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
class __$$RecommendationMetadataImplCopyWithImpl<$Res>
    extends _$RecommendationMetadataCopyWithImpl<$Res,
        _$RecommendationMetadataImpl>
    implements _$$RecommendationMetadataImplCopyWith<$Res> {
  __$$RecommendationMetadataImplCopyWithImpl(
      _$RecommendationMetadataImpl _value,
      $Res Function(_$RecommendationMetadataImpl) _then)
      : super(_value, _then);

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
    return _then(_$RecommendationMetadataImpl(
      matchedInterests: null == matchedInterests
          ? _value._matchedInterests
          : matchedInterests // ignore: cast_nullable_to_non_nullable
              as Set<TravelInterest>,
      suggestedDate: null == suggestedDate
          ? _value.suggestedDate
          : suggestedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      suggestedTime: null == suggestedTime
          ? _value.suggestedTime
          : suggestedTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as DistanceFromHotel,
      weather: null == weather
          ? _value.weather
          : weather // ignore: cast_nullable_to_non_nullable
              as WeatherContext,
      crowdLevel: null == crowdLevel
          ? _value.crowdLevel
          : crowdLevel // ignore: cast_nullable_to_non_nullable
              as CrowdLevel,
      estimatedCost: freezed == estimatedCost
          ? _value.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as Money?,
      estimatedDuration: null == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      bookingUrl: freezed == bookingUrl
          ? _value.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      requiresAdvanceBooking: null == requiresAdvanceBooking
          ? _value.requiresAdvanceBooking
          : requiresAdvanceBooking // ignore: cast_nullable_to_non_nullable
              as bool,
      isIndoor: null == isIndoor
          ? _value.isIndoor
          : isIndoor // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationMetadataImpl extends _RecommendationMetadata {
  const _$RecommendationMetadataImpl(
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

  factory _$RecommendationMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationMetadataImplFromJson(json);

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

  @override
  String toString() {
    return 'RecommendationMetadata(matchedInterests: $matchedInterests, suggestedDate: $suggestedDate, suggestedTime: $suggestedTime, distance: $distance, weather: $weather, crowdLevel: $crowdLevel, estimatedCost: $estimatedCost, estimatedDuration: $estimatedDuration, bookingUrl: $bookingUrl, requiresAdvanceBooking: $requiresAdvanceBooking, isIndoor: $isIndoor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationMetadataImpl &&
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

  /// Create a copy of RecommendationMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationMetadataImplCopyWith<_$RecommendationMetadataImpl>
      get copyWith => __$$RecommendationMetadataImplCopyWithImpl<
          _$RecommendationMetadataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationMetadataImplToJson(
      this,
    );
  }
}

abstract class _RecommendationMetadata extends RecommendationMetadata {
  const factory _RecommendationMetadata(
      {required final Set<TravelInterest> matchedInterests,
      required final DateTime suggestedDate,
      required final TimeOfDay suggestedTime,
      required final DistanceFromHotel distance,
      required final WeatherContext weather,
      required final CrowdLevel crowdLevel,
      final Money? estimatedCost,
      final Duration estimatedDuration,
      final String? bookingUrl,
      final bool requiresAdvanceBooking,
      final bool isIndoor}) = _$RecommendationMetadataImpl;
  const _RecommendationMetadata._() : super._();

  factory _RecommendationMetadata.fromJson(Map<String, dynamic> json) =
      _$RecommendationMetadataImpl.fromJson;

  @override
  Set<TravelInterest> get matchedInterests;
  @override
  DateTime get suggestedDate;
  @override
  TimeOfDay get suggestedTime;
  @override
  DistanceFromHotel get distance;
  @override
  WeatherContext get weather;
  @override
  CrowdLevel get crowdLevel;
  @override
  Money? get estimatedCost;
  @override
  Duration get estimatedDuration;
  @override
  String? get bookingUrl;
  @override
  bool get requiresAdvanceBooking;
  @override
  bool get isIndoor;

  /// Create a copy of RecommendationMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationMetadataImplCopyWith<_$RecommendationMetadataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TimeOfDay _$TimeOfDayFromJson(Map<String, dynamic> json) {
  return _TimeOfDay.fromJson(json);
}

/// @nodoc
mixin _$TimeOfDay {
  int get hour => throw _privateConstructorUsedError;
  int get minute => throw _privateConstructorUsedError;

  /// Serializes this TimeOfDay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeOfDayCopyWith<TimeOfDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeOfDayCopyWith<$Res> {
  factory $TimeOfDayCopyWith(TimeOfDay value, $Res Function(TimeOfDay) then) =
      _$TimeOfDayCopyWithImpl<$Res, TimeOfDay>;
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class _$TimeOfDayCopyWithImpl<$Res, $Val extends TimeOfDay>
    implements $TimeOfDayCopyWith<$Res> {
  _$TimeOfDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
  }) {
    return _then(_value.copyWith(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeOfDayImplCopyWith<$Res>
    implements $TimeOfDayCopyWith<$Res> {
  factory _$$TimeOfDayImplCopyWith(
          _$TimeOfDayImpl value, $Res Function(_$TimeOfDayImpl) then) =
      __$$TimeOfDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class __$$TimeOfDayImplCopyWithImpl<$Res>
    extends _$TimeOfDayCopyWithImpl<$Res, _$TimeOfDayImpl>
    implements _$$TimeOfDayImplCopyWith<$Res> {
  __$$TimeOfDayImplCopyWithImpl(
      _$TimeOfDayImpl _value, $Res Function(_$TimeOfDayImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
  }) {
    return _then(_$TimeOfDayImpl(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeOfDayImpl extends _TimeOfDay {
  const _$TimeOfDayImpl({required this.hour, this.minute = 0}) : super._();

  factory _$TimeOfDayImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeOfDayImplFromJson(json);

  @override
  final int hour;
  @override
  @JsonKey()
  final int minute;

  @override
  String toString() {
    return 'TimeOfDay(hour: $hour, minute: $minute)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeOfDayImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute);

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeOfDayImplCopyWith<_$TimeOfDayImpl> get copyWith =>
      __$$TimeOfDayImplCopyWithImpl<_$TimeOfDayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeOfDayImplToJson(
      this,
    );
  }
}

abstract class _TimeOfDay extends TimeOfDay {
  const factory _TimeOfDay({required final int hour, final int minute}) =
      _$TimeOfDayImpl;
  const _TimeOfDay._() : super._();

  factory _TimeOfDay.fromJson(Map<String, dynamic> json) =
      _$TimeOfDayImpl.fromJson;

  @override
  int get hour;
  @override
  int get minute;

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeOfDayImplCopyWith<_$TimeOfDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Money _$MoneyFromJson(Map<String, dynamic> json) {
  return _Money.fromJson(json);
}

/// @nodoc
mixin _$Money {
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this Money to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Money
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MoneyCopyWith<Money> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MoneyCopyWith<$Res> {
  factory $MoneyCopyWith(Money value, $Res Function(Money) then) =
      _$MoneyCopyWithImpl<$Res, Money>;
  @useResult
  $Res call({double amount, String currency});
}

/// @nodoc
class _$MoneyCopyWithImpl<$Res, $Val extends Money>
    implements $MoneyCopyWith<$Res> {
  _$MoneyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Money
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? currency = null,
  }) {
    return _then(_value.copyWith(
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MoneyImplCopyWith<$Res> implements $MoneyCopyWith<$Res> {
  factory _$$MoneyImplCopyWith(
          _$MoneyImpl value, $Res Function(_$MoneyImpl) then) =
      __$$MoneyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double amount, String currency});
}

/// @nodoc
class __$$MoneyImplCopyWithImpl<$Res>
    extends _$MoneyCopyWithImpl<$Res, _$MoneyImpl>
    implements _$$MoneyImplCopyWith<$Res> {
  __$$MoneyImplCopyWithImpl(
      _$MoneyImpl _value, $Res Function(_$MoneyImpl) _then)
      : super(_value, _then);

  /// Create a copy of Money
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? currency = null,
  }) {
    return _then(_$MoneyImpl(
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MoneyImpl extends _Money {
  const _$MoneyImpl({required this.amount, this.currency = 'USD'}) : super._();

  factory _$MoneyImpl.fromJson(Map<String, dynamic> json) =>
      _$$MoneyImplFromJson(json);

  @override
  final double amount;
  @override
  @JsonKey()
  final String currency;

  @override
  String toString() {
    return 'Money(amount: $amount, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MoneyImpl &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, amount, currency);

  /// Create a copy of Money
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MoneyImplCopyWith<_$MoneyImpl> get copyWith =>
      __$$MoneyImplCopyWithImpl<_$MoneyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MoneyImplToJson(
      this,
    );
  }
}

abstract class _Money extends Money {
  const factory _Money({required final double amount, final String currency}) =
      _$MoneyImpl;
  const _Money._() : super._();

  factory _Money.fromJson(Map<String, dynamic> json) = _$MoneyImpl.fromJson;

  @override
  double get amount;
  @override
  String get currency;

  /// Create a copy of Money
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MoneyImplCopyWith<_$MoneyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
