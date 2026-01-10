// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personalized_recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecommendedDestination {
  /// The destination being recommended
  Destination get destination;

  /// Match score/relevance (0.0 to 1.0)
  /// Higher values indicate better match to user preferences
  double get matchScore;

  /// Human-readable reason for this recommendation
  /// Example: "Perfect for your love of cultural experiences and solo dining"
  String get reason;

  /// Key factors that contributed to this recommendation
  /// Example: ["high solo suitability", "cultural activities", "moderate budget"]
  List<String> get matchingFactors;

  /// Indicates if this destination is a hidden gem match
  bool get isHiddenGemMatch;

  /// Create a copy of RecommendedDestination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecommendedDestinationCopyWith<RecommendedDestination> get copyWith =>
      _$RecommendedDestinationCopyWithImpl<RecommendedDestination>(
          this as RecommendedDestination, _$identity);

  /// Serializes this RecommendedDestination to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecommendedDestination &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.matchScore, matchScore) ||
                other.matchScore == matchScore) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            const DeepCollectionEquality()
                .equals(other.matchingFactors, matchingFactors) &&
            (identical(other.isHiddenGemMatch, isHiddenGemMatch) ||
                other.isHiddenGemMatch == isHiddenGemMatch));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, destination, matchScore, reason,
      const DeepCollectionEquality().hash(matchingFactors), isHiddenGemMatch);

  @override
  String toString() {
    return 'RecommendedDestination(destination: $destination, matchScore: $matchScore, reason: $reason, matchingFactors: $matchingFactors, isHiddenGemMatch: $isHiddenGemMatch)';
  }
}

/// @nodoc
abstract mixin class $RecommendedDestinationCopyWith<$Res> {
  factory $RecommendedDestinationCopyWith(RecommendedDestination value,
          $Res Function(RecommendedDestination) _then) =
      _$RecommendedDestinationCopyWithImpl;
  @useResult
  $Res call(
      {Destination destination,
      double matchScore,
      String reason,
      List<String> matchingFactors,
      bool isHiddenGemMatch});

  $DestinationCopyWith<$Res> get destination;
}

/// @nodoc
class _$RecommendedDestinationCopyWithImpl<$Res>
    implements $RecommendedDestinationCopyWith<$Res> {
  _$RecommendedDestinationCopyWithImpl(this._self, this._then);

  final RecommendedDestination _self;
  final $Res Function(RecommendedDestination) _then;

  /// Create a copy of RecommendedDestination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? destination = null,
    Object? matchScore = null,
    Object? reason = null,
    Object? matchingFactors = null,
    Object? isHiddenGemMatch = null,
  }) {
    return _then(_self.copyWith(
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination,
      matchScore: null == matchScore
          ? _self.matchScore
          : matchScore // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      matchingFactors: null == matchingFactors
          ? _self.matchingFactors
          : matchingFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isHiddenGemMatch: null == isHiddenGemMatch
          ? _self.isHiddenGemMatch
          : isHiddenGemMatch // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of RecommendedDestination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res> get destination {
    return $DestinationCopyWith<$Res>(_self.destination, (value) {
      return _then(_self.copyWith(destination: value));
    });
  }
}

/// Adds pattern-matching-related methods to [RecommendedDestination].
extension RecommendedDestinationPatterns on RecommendedDestination {
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
    TResult Function(_RecommendedDestination value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendedDestination() when $default != null:
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
    TResult Function(_RecommendedDestination value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendedDestination():
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
    TResult? Function(_RecommendedDestination value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendedDestination() when $default != null:
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
    TResult Function(Destination destination, double matchScore, String reason,
            List<String> matchingFactors, bool isHiddenGemMatch)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecommendedDestination() when $default != null:
        return $default(_that.destination, _that.matchScore, _that.reason,
            _that.matchingFactors, _that.isHiddenGemMatch);
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
    TResult Function(Destination destination, double matchScore, String reason,
            List<String> matchingFactors, bool isHiddenGemMatch)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendedDestination():
        return $default(_that.destination, _that.matchScore, _that.reason,
            _that.matchingFactors, _that.isHiddenGemMatch);
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
    TResult? Function(Destination destination, double matchScore, String reason,
            List<String> matchingFactors, bool isHiddenGemMatch)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecommendedDestination() when $default != null:
        return $default(_that.destination, _that.matchScore, _that.reason,
            _that.matchingFactors, _that.isHiddenGemMatch);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _RecommendedDestination implements RecommendedDestination {
  const _RecommendedDestination(
      {required this.destination,
      required this.matchScore,
      required this.reason,
      required final List<String> matchingFactors,
      this.isHiddenGemMatch = false})
      : _matchingFactors = matchingFactors;
  factory _RecommendedDestination.fromJson(Map<String, dynamic> json) =>
      _$RecommendedDestinationFromJson(json);

  /// The destination being recommended
  @override
  final Destination destination;

  /// Match score/relevance (0.0 to 1.0)
  /// Higher values indicate better match to user preferences
  @override
  final double matchScore;

  /// Human-readable reason for this recommendation
  /// Example: "Perfect for your love of cultural experiences and solo dining"
  @override
  final String reason;

  /// Key factors that contributed to this recommendation
  /// Example: ["high solo suitability", "cultural activities", "moderate budget"]
  final List<String> _matchingFactors;

  /// Key factors that contributed to this recommendation
  /// Example: ["high solo suitability", "cultural activities", "moderate budget"]
  @override
  List<String> get matchingFactors {
    if (_matchingFactors is EqualUnmodifiableListView) return _matchingFactors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_matchingFactors);
  }

  /// Indicates if this destination is a hidden gem match
  @override
  @JsonKey()
  final bool isHiddenGemMatch;

  /// Create a copy of RecommendedDestination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecommendedDestinationCopyWith<_RecommendedDestination> get copyWith =>
      __$RecommendedDestinationCopyWithImpl<_RecommendedDestination>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RecommendedDestinationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecommendedDestination &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.matchScore, matchScore) ||
                other.matchScore == matchScore) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            const DeepCollectionEquality()
                .equals(other._matchingFactors, _matchingFactors) &&
            (identical(other.isHiddenGemMatch, isHiddenGemMatch) ||
                other.isHiddenGemMatch == isHiddenGemMatch));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, destination, matchScore, reason,
      const DeepCollectionEquality().hash(_matchingFactors), isHiddenGemMatch);

  @override
  String toString() {
    return 'RecommendedDestination(destination: $destination, matchScore: $matchScore, reason: $reason, matchingFactors: $matchingFactors, isHiddenGemMatch: $isHiddenGemMatch)';
  }
}

/// @nodoc
abstract mixin class _$RecommendedDestinationCopyWith<$Res>
    implements $RecommendedDestinationCopyWith<$Res> {
  factory _$RecommendedDestinationCopyWith(_RecommendedDestination value,
          $Res Function(_RecommendedDestination) _then) =
      __$RecommendedDestinationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Destination destination,
      double matchScore,
      String reason,
      List<String> matchingFactors,
      bool isHiddenGemMatch});

  @override
  $DestinationCopyWith<$Res> get destination;
}

/// @nodoc
class __$RecommendedDestinationCopyWithImpl<$Res>
    implements _$RecommendedDestinationCopyWith<$Res> {
  __$RecommendedDestinationCopyWithImpl(this._self, this._then);

  final _RecommendedDestination _self;
  final $Res Function(_RecommendedDestination) _then;

  /// Create a copy of RecommendedDestination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? destination = null,
    Object? matchScore = null,
    Object? reason = null,
    Object? matchingFactors = null,
    Object? isHiddenGemMatch = null,
  }) {
    return _then(_RecommendedDestination(
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination,
      matchScore: null == matchScore
          ? _self.matchScore
          : matchScore // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      matchingFactors: null == matchingFactors
          ? _self._matchingFactors
          : matchingFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isHiddenGemMatch: null == isHiddenGemMatch
          ? _self.isHiddenGemMatch
          : isHiddenGemMatch // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of RecommendedDestination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res> get destination {
    return $DestinationCopyWith<$Res>(_self.destination, (value) {
      return _then(_self.copyWith(destination: value));
    });
  }
}

/// @nodoc
mixin _$PersonalizedRecommendation {
  /// Unique identifier for this recommendation set
  String get id;

  /// User ID these recommendations are for
  String get userId;

  /// List of recommended destinations with match scores and reasons
  List<RecommendedDestination> get recommendations;

  /// Source/method used to generate these recommendations
  RecommendationSource get source;

  /// Human-readable summary of recommendations
  /// Example: "Based on your love for cultural immersion and solo dining"
  String? get summary;

  /// Total count of recommendations available
  /// May be greater than recommendations.length for pagination
  int get totalCount;

  /// Timestamp when recommendations were generated
  DateTime get generatedAt;

  /// Timestamp when these recommendations expire
  /// After this time, fresh recommendations should be fetched
  DateTime get expiresAt;

  /// User preferences used for generating recommendations (snapshot)
  /// Useful for explaining why certain destinations were recommended
  Map<String, dynamic>? get preferenceSnapshot;

  /// Related recommendation set IDs
  /// Example: ["rec_123", "rec_456"] for different categories
  List<String>? get relatedRecommendationIds;

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PersonalizedRecommendationCopyWith<PersonalizedRecommendation>
      get copyWith =>
          _$PersonalizedRecommendationCopyWithImpl<PersonalizedRecommendation>(
              this as PersonalizedRecommendation, _$identity);

  /// Serializes this PersonalizedRecommendation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PersonalizedRecommendation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality()
                .equals(other.recommendations, recommendations) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            const DeepCollectionEquality()
                .equals(other.preferenceSnapshot, preferenceSnapshot) &&
            const DeepCollectionEquality().equals(
                other.relatedRecommendationIds, relatedRecommendationIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      const DeepCollectionEquality().hash(recommendations),
      source,
      summary,
      totalCount,
      generatedAt,
      expiresAt,
      const DeepCollectionEquality().hash(preferenceSnapshot),
      const DeepCollectionEquality().hash(relatedRecommendationIds));

  @override
  String toString() {
    return 'PersonalizedRecommendation(id: $id, userId: $userId, recommendations: $recommendations, source: $source, summary: $summary, totalCount: $totalCount, generatedAt: $generatedAt, expiresAt: $expiresAt, preferenceSnapshot: $preferenceSnapshot, relatedRecommendationIds: $relatedRecommendationIds)';
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
      String userId,
      List<RecommendedDestination> recommendations,
      RecommendationSource source,
      String? summary,
      int totalCount,
      DateTime generatedAt,
      DateTime expiresAt,
      Map<String, dynamic>? preferenceSnapshot,
      List<String>? relatedRecommendationIds});
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
    Object? userId = null,
    Object? recommendations = null,
    Object? source = null,
    Object? summary = freezed,
    Object? totalCount = null,
    Object? generatedAt = null,
    Object? expiresAt = null,
    Object? preferenceSnapshot = freezed,
    Object? relatedRecommendationIds = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      recommendations: null == recommendations
          ? _self.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<RecommendedDestination>,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as RecommendationSource,
      summary: freezed == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCount: null == totalCount
          ? _self.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      generatedAt: null == generatedAt
          ? _self.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      preferenceSnapshot: freezed == preferenceSnapshot
          ? _self.preferenceSnapshot
          : preferenceSnapshot // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      relatedRecommendationIds: freezed == relatedRecommendationIds
          ? _self.relatedRecommendationIds
          : relatedRecommendationIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
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
            String userId,
            List<RecommendedDestination> recommendations,
            RecommendationSource source,
            String? summary,
            int totalCount,
            DateTime generatedAt,
            DateTime expiresAt,
            Map<String, dynamic>? preferenceSnapshot,
            List<String>? relatedRecommendationIds)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PersonalizedRecommendation() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.recommendations,
            _that.source,
            _that.summary,
            _that.totalCount,
            _that.generatedAt,
            _that.expiresAt,
            _that.preferenceSnapshot,
            _that.relatedRecommendationIds);
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
            String userId,
            List<RecommendedDestination> recommendations,
            RecommendationSource source,
            String? summary,
            int totalCount,
            DateTime generatedAt,
            DateTime expiresAt,
            Map<String, dynamic>? preferenceSnapshot,
            List<String>? relatedRecommendationIds)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalizedRecommendation():
        return $default(
            _that.id,
            _that.userId,
            _that.recommendations,
            _that.source,
            _that.summary,
            _that.totalCount,
            _that.generatedAt,
            _that.expiresAt,
            _that.preferenceSnapshot,
            _that.relatedRecommendationIds);
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
            String userId,
            List<RecommendedDestination> recommendations,
            RecommendationSource source,
            String? summary,
            int totalCount,
            DateTime generatedAt,
            DateTime expiresAt,
            Map<String, dynamic>? preferenceSnapshot,
            List<String>? relatedRecommendationIds)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalizedRecommendation() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.recommendations,
            _that.source,
            _that.summary,
            _that.totalCount,
            _that.generatedAt,
            _that.expiresAt,
            _that.preferenceSnapshot,
            _that.relatedRecommendationIds);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PersonalizedRecommendation extends PersonalizedRecommendation {
  _PersonalizedRecommendation(
      {required this.id,
      required this.userId,
      required final List<RecommendedDestination> recommendations,
      required this.source,
      this.summary,
      this.totalCount = 0,
      required this.generatedAt,
      required this.expiresAt,
      final Map<String, dynamic>? preferenceSnapshot,
      final List<String>? relatedRecommendationIds})
      : _recommendations = recommendations,
        _preferenceSnapshot = preferenceSnapshot,
        _relatedRecommendationIds = relatedRecommendationIds,
        super._();
  factory _PersonalizedRecommendation.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedRecommendationFromJson(json);

  /// Unique identifier for this recommendation set
  @override
  final String id;

  /// User ID these recommendations are for
  @override
  final String userId;

  /// List of recommended destinations with match scores and reasons
  final List<RecommendedDestination> _recommendations;

  /// List of recommended destinations with match scores and reasons
  @override
  List<RecommendedDestination> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  /// Source/method used to generate these recommendations
  @override
  final RecommendationSource source;

  /// Human-readable summary of recommendations
  /// Example: "Based on your love for cultural immersion and solo dining"
  @override
  final String? summary;

  /// Total count of recommendations available
  /// May be greater than recommendations.length for pagination
  @override
  @JsonKey()
  final int totalCount;

  /// Timestamp when recommendations were generated
  @override
  final DateTime generatedAt;

  /// Timestamp when these recommendations expire
  /// After this time, fresh recommendations should be fetched
  @override
  final DateTime expiresAt;

  /// User preferences used for generating recommendations (snapshot)
  /// Useful for explaining why certain destinations were recommended
  final Map<String, dynamic>? _preferenceSnapshot;

  /// User preferences used for generating recommendations (snapshot)
  /// Useful for explaining why certain destinations were recommended
  @override
  Map<String, dynamic>? get preferenceSnapshot {
    final value = _preferenceSnapshot;
    if (value == null) return null;
    if (_preferenceSnapshot is EqualUnmodifiableMapView)
      return _preferenceSnapshot;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Related recommendation set IDs
  /// Example: ["rec_123", "rec_456"] for different categories
  final List<String>? _relatedRecommendationIds;

  /// Related recommendation set IDs
  /// Example: ["rec_123", "rec_456"] for different categories
  @override
  List<String>? get relatedRecommendationIds {
    final value = _relatedRecommendationIds;
    if (value == null) return null;
    if (_relatedRecommendationIds is EqualUnmodifiableListView)
      return _relatedRecommendationIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of PersonalizedRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PersonalizedRecommendationCopyWith<_PersonalizedRecommendation>
      get copyWith => __$PersonalizedRecommendationCopyWithImpl<
          _PersonalizedRecommendation>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PersonalizedRecommendationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PersonalizedRecommendation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality()
                .equals(other._recommendations, _recommendations) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            const DeepCollectionEquality()
                .equals(other._preferenceSnapshot, _preferenceSnapshot) &&
            const DeepCollectionEquality().equals(
                other._relatedRecommendationIds, _relatedRecommendationIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      const DeepCollectionEquality().hash(_recommendations),
      source,
      summary,
      totalCount,
      generatedAt,
      expiresAt,
      const DeepCollectionEquality().hash(_preferenceSnapshot),
      const DeepCollectionEquality().hash(_relatedRecommendationIds));

  @override
  String toString() {
    return 'PersonalizedRecommendation(id: $id, userId: $userId, recommendations: $recommendations, source: $source, summary: $summary, totalCount: $totalCount, generatedAt: $generatedAt, expiresAt: $expiresAt, preferenceSnapshot: $preferenceSnapshot, relatedRecommendationIds: $relatedRecommendationIds)';
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
      String userId,
      List<RecommendedDestination> recommendations,
      RecommendationSource source,
      String? summary,
      int totalCount,
      DateTime generatedAt,
      DateTime expiresAt,
      Map<String, dynamic>? preferenceSnapshot,
      List<String>? relatedRecommendationIds});
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
    Object? userId = null,
    Object? recommendations = null,
    Object? source = null,
    Object? summary = freezed,
    Object? totalCount = null,
    Object? generatedAt = null,
    Object? expiresAt = null,
    Object? preferenceSnapshot = freezed,
    Object? relatedRecommendationIds = freezed,
  }) {
    return _then(_PersonalizedRecommendation(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      recommendations: null == recommendations
          ? _self._recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<RecommendedDestination>,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as RecommendationSource,
      summary: freezed == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCount: null == totalCount
          ? _self.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      generatedAt: null == generatedAt
          ? _self.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      preferenceSnapshot: freezed == preferenceSnapshot
          ? _self._preferenceSnapshot
          : preferenceSnapshot // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      relatedRecommendationIds: freezed == relatedRecommendationIds
          ? _self._relatedRecommendationIds
          : relatedRecommendationIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

// dart format on
