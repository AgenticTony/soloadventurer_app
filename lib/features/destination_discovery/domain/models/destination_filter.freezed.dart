// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'destination_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DestinationFilter {
  /// Text search query to filter destinations by name or description
  String? get searchQuery;

  /// Budget level filter
  /// When set, only returns destinations matching this budget level
  BudgetLevel? get budgetLevel;

  /// Minimum safety score filter (1-10)
  /// When set, only returns destinations with safety score >= this value
  double? get minSafetyScore;

  /// Minimum solo suitability score filter (1-10)
  /// When set, only returns destinations with solo suitability >= this value
  double? get minSoloSuitabilityScore;

  /// Activity level filter
  /// When set, only returns destinations that support this activity level
  ActivityLevel? get activityLevel;

  /// Country code filter (e.g., "JP", "US", "TH")
  /// When set, only returns destinations from this country
  String? get countryCode;

  /// Region/state/province filter
  /// When set, only returns destinations from this region
  String? get region;

  /// Tags/categories multi-select filter
  /// When set, only returns destinations that match ALL specified tags
  /// Example: ["beach", "urban"] will only return destinations tagged with both
  List<String>? get tags;

  /// Whether to include only hidden gems
  /// When true, only returns destinations marked as hidden gems
  bool get hiddenGemsOnly;

  /// Minimum popularity score filter (0-1)
  /// When set, only returns destinations with popularity >= this value
  double? get minPopularityScore;

  /// Maximum daily cost filter (in USD)
  /// When set, only returns destinations with average daily cost <= this value
  int? get maxDailyCost;

  /// Sort order for results
  /// Defaults to relevance when search query is provided, popularity otherwise
  DestinationSortOrder get sortBy;

  /// Pagination offset for loading more results
  /// Used for pagination, defaults to 0
  int get offset;

  /// Number of results to return
  /// Used for pagination, defaults to 20
  int get limit;

  /// Create a copy of DestinationFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DestinationFilterCopyWith<DestinationFilter> get copyWith =>
      _$DestinationFilterCopyWithImpl<DestinationFilter>(
          this as DestinationFilter, _$identity);

  /// Serializes this DestinationFilter to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DestinationFilter &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.budgetLevel, budgetLevel) ||
                other.budgetLevel == budgetLevel) &&
            (identical(other.minSafetyScore, minSafetyScore) ||
                other.minSafetyScore == minSafetyScore) &&
            (identical(
                    other.minSoloSuitabilityScore, minSoloSuitabilityScore) ||
                other.minSoloSuitabilityScore == minSoloSuitabilityScore) &&
            (identical(other.activityLevel, activityLevel) ||
                other.activityLevel == activityLevel) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.region, region) || other.region == region) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.hiddenGemsOnly, hiddenGemsOnly) ||
                other.hiddenGemsOnly == hiddenGemsOnly) &&
            (identical(other.minPopularityScore, minPopularityScore) ||
                other.minPopularityScore == minPopularityScore) &&
            (identical(other.maxDailyCost, maxDailyCost) ||
                other.maxDailyCost == maxDailyCost) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      searchQuery,
      budgetLevel,
      minSafetyScore,
      minSoloSuitabilityScore,
      activityLevel,
      countryCode,
      region,
      const DeepCollectionEquality().hash(tags),
      hiddenGemsOnly,
      minPopularityScore,
      maxDailyCost,
      sortBy,
      offset,
      limit);

  @override
  String toString() {
    return 'DestinationFilter(searchQuery: $searchQuery, budgetLevel: $budgetLevel, minSafetyScore: $minSafetyScore, minSoloSuitabilityScore: $minSoloSuitabilityScore, activityLevel: $activityLevel, countryCode: $countryCode, region: $region, tags: $tags, hiddenGemsOnly: $hiddenGemsOnly, minPopularityScore: $minPopularityScore, maxDailyCost: $maxDailyCost, sortBy: $sortBy, offset: $offset, limit: $limit)';
  }
}

/// @nodoc
abstract mixin class $DestinationFilterCopyWith<$Res> {
  factory $DestinationFilterCopyWith(
          DestinationFilter value, $Res Function(DestinationFilter) _then) =
      _$DestinationFilterCopyWithImpl;
  @useResult
  $Res call(
      {String? searchQuery,
      BudgetLevel? budgetLevel,
      double? minSafetyScore,
      double? minSoloSuitabilityScore,
      ActivityLevel? activityLevel,
      String? countryCode,
      String? region,
      List<String>? tags,
      bool hiddenGemsOnly,
      double? minPopularityScore,
      int? maxDailyCost,
      DestinationSortOrder sortBy,
      int offset,
      int limit});
}

/// @nodoc
class _$DestinationFilterCopyWithImpl<$Res>
    implements $DestinationFilterCopyWith<$Res> {
  _$DestinationFilterCopyWithImpl(this._self, this._then);

  final DestinationFilter _self;
  final $Res Function(DestinationFilter) _then;

  /// Create a copy of DestinationFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = freezed,
    Object? budgetLevel = freezed,
    Object? minSafetyScore = freezed,
    Object? minSoloSuitabilityScore = freezed,
    Object? activityLevel = freezed,
    Object? countryCode = freezed,
    Object? region = freezed,
    Object? tags = freezed,
    Object? hiddenGemsOnly = null,
    Object? minPopularityScore = freezed,
    Object? maxDailyCost = freezed,
    Object? sortBy = null,
    Object? offset = null,
    Object? limit = null,
  }) {
    return _then(_self.copyWith(
      searchQuery: freezed == searchQuery
          ? _self.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      budgetLevel: freezed == budgetLevel
          ? _self.budgetLevel
          : budgetLevel // ignore: cast_nullable_to_non_nullable
              as BudgetLevel?,
      minSafetyScore: freezed == minSafetyScore
          ? _self.minSafetyScore
          : minSafetyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      minSoloSuitabilityScore: freezed == minSoloSuitabilityScore
          ? _self.minSoloSuitabilityScore
          : minSoloSuitabilityScore // ignore: cast_nullable_to_non_nullable
              as double?,
      activityLevel: freezed == activityLevel
          ? _self.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as ActivityLevel?,
      countryCode: freezed == countryCode
          ? _self.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      region: freezed == region
          ? _self.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      hiddenGemsOnly: null == hiddenGemsOnly
          ? _self.hiddenGemsOnly
          : hiddenGemsOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      minPopularityScore: freezed == minPopularityScore
          ? _self.minPopularityScore
          : minPopularityScore // ignore: cast_nullable_to_non_nullable
              as double?,
      maxDailyCost: freezed == maxDailyCost
          ? _self.maxDailyCost
          : maxDailyCost // ignore: cast_nullable_to_non_nullable
              as int?,
      sortBy: null == sortBy
          ? _self.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as DestinationSortOrder,
      offset: null == offset
          ? _self.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _self.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [DestinationFilter].
extension DestinationFilterPatterns on DestinationFilter {
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
    TResult Function(_DestinationFilter value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DestinationFilter() when $default != null:
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
    TResult Function(_DestinationFilter value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DestinationFilter():
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
    TResult? Function(_DestinationFilter value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DestinationFilter() when $default != null:
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
            String? searchQuery,
            BudgetLevel? budgetLevel,
            double? minSafetyScore,
            double? minSoloSuitabilityScore,
            ActivityLevel? activityLevel,
            String? countryCode,
            String? region,
            List<String>? tags,
            bool hiddenGemsOnly,
            double? minPopularityScore,
            int? maxDailyCost,
            DestinationSortOrder sortBy,
            int offset,
            int limit)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DestinationFilter() when $default != null:
        return $default(
            _that.searchQuery,
            _that.budgetLevel,
            _that.minSafetyScore,
            _that.minSoloSuitabilityScore,
            _that.activityLevel,
            _that.countryCode,
            _that.region,
            _that.tags,
            _that.hiddenGemsOnly,
            _that.minPopularityScore,
            _that.maxDailyCost,
            _that.sortBy,
            _that.offset,
            _that.limit);
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
            String? searchQuery,
            BudgetLevel? budgetLevel,
            double? minSafetyScore,
            double? minSoloSuitabilityScore,
            ActivityLevel? activityLevel,
            String? countryCode,
            String? region,
            List<String>? tags,
            bool hiddenGemsOnly,
            double? minPopularityScore,
            int? maxDailyCost,
            DestinationSortOrder sortBy,
            int offset,
            int limit)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DestinationFilter():
        return $default(
            _that.searchQuery,
            _that.budgetLevel,
            _that.minSafetyScore,
            _that.minSoloSuitabilityScore,
            _that.activityLevel,
            _that.countryCode,
            _that.region,
            _that.tags,
            _that.hiddenGemsOnly,
            _that.minPopularityScore,
            _that.maxDailyCost,
            _that.sortBy,
            _that.offset,
            _that.limit);
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
            String? searchQuery,
            BudgetLevel? budgetLevel,
            double? minSafetyScore,
            double? minSoloSuitabilityScore,
            ActivityLevel? activityLevel,
            String? countryCode,
            String? region,
            List<String>? tags,
            bool hiddenGemsOnly,
            double? minPopularityScore,
            int? maxDailyCost,
            DestinationSortOrder sortBy,
            int offset,
            int limit)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DestinationFilter() when $default != null:
        return $default(
            _that.searchQuery,
            _that.budgetLevel,
            _that.minSafetyScore,
            _that.minSoloSuitabilityScore,
            _that.activityLevel,
            _that.countryCode,
            _that.region,
            _that.tags,
            _that.hiddenGemsOnly,
            _that.minPopularityScore,
            _that.maxDailyCost,
            _that.sortBy,
            _that.offset,
            _that.limit);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DestinationFilter extends DestinationFilter {
  const _DestinationFilter(
      {this.searchQuery,
      this.budgetLevel,
      this.minSafetyScore,
      this.minSoloSuitabilityScore,
      this.activityLevel,
      this.countryCode,
      this.region,
      final List<String>? tags,
      this.hiddenGemsOnly = false,
      this.minPopularityScore,
      this.maxDailyCost,
      this.sortBy = DestinationSortOrder.popularity,
      this.offset = 0,
      this.limit = 20})
      : _tags = tags,
        super._();
  factory _DestinationFilter.fromJson(Map<String, dynamic> json) =>
      _$DestinationFilterFromJson(json);

  /// Text search query to filter destinations by name or description
  @override
  final String? searchQuery;

  /// Budget level filter
  /// When set, only returns destinations matching this budget level
  @override
  final BudgetLevel? budgetLevel;

  /// Minimum safety score filter (1-10)
  /// When set, only returns destinations with safety score >= this value
  @override
  final double? minSafetyScore;

  /// Minimum solo suitability score filter (1-10)
  /// When set, only returns destinations with solo suitability >= this value
  @override
  final double? minSoloSuitabilityScore;

  /// Activity level filter
  /// When set, only returns destinations that support this activity level
  @override
  final ActivityLevel? activityLevel;

  /// Country code filter (e.g., "JP", "US", "TH")
  /// When set, only returns destinations from this country
  @override
  final String? countryCode;

  /// Region/state/province filter
  /// When set, only returns destinations from this region
  @override
  final String? region;

  /// Tags/categories multi-select filter
  /// When set, only returns destinations that match ALL specified tags
  /// Example: ["beach", "urban"] will only return destinations tagged with both
  final List<String>? _tags;

  /// Tags/categories multi-select filter
  /// When set, only returns destinations that match ALL specified tags
  /// Example: ["beach", "urban"] will only return destinations tagged with both
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Whether to include only hidden gems
  /// When true, only returns destinations marked as hidden gems
  @override
  @JsonKey()
  final bool hiddenGemsOnly;

  /// Minimum popularity score filter (0-1)
  /// When set, only returns destinations with popularity >= this value
  @override
  final double? minPopularityScore;

  /// Maximum daily cost filter (in USD)
  /// When set, only returns destinations with average daily cost <= this value
  @override
  final int? maxDailyCost;

  /// Sort order for results
  /// Defaults to relevance when search query is provided, popularity otherwise
  @override
  @JsonKey()
  final DestinationSortOrder sortBy;

  /// Pagination offset for loading more results
  /// Used for pagination, defaults to 0
  @override
  @JsonKey()
  final int offset;

  /// Number of results to return
  /// Used for pagination, defaults to 20
  @override
  @JsonKey()
  final int limit;

  /// Create a copy of DestinationFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DestinationFilterCopyWith<_DestinationFilter> get copyWith =>
      __$DestinationFilterCopyWithImpl<_DestinationFilter>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DestinationFilterToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DestinationFilter &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.budgetLevel, budgetLevel) ||
                other.budgetLevel == budgetLevel) &&
            (identical(other.minSafetyScore, minSafetyScore) ||
                other.minSafetyScore == minSafetyScore) &&
            (identical(
                    other.minSoloSuitabilityScore, minSoloSuitabilityScore) ||
                other.minSoloSuitabilityScore == minSoloSuitabilityScore) &&
            (identical(other.activityLevel, activityLevel) ||
                other.activityLevel == activityLevel) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.region, region) || other.region == region) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.hiddenGemsOnly, hiddenGemsOnly) ||
                other.hiddenGemsOnly == hiddenGemsOnly) &&
            (identical(other.minPopularityScore, minPopularityScore) ||
                other.minPopularityScore == minPopularityScore) &&
            (identical(other.maxDailyCost, maxDailyCost) ||
                other.maxDailyCost == maxDailyCost) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      searchQuery,
      budgetLevel,
      minSafetyScore,
      minSoloSuitabilityScore,
      activityLevel,
      countryCode,
      region,
      const DeepCollectionEquality().hash(_tags),
      hiddenGemsOnly,
      minPopularityScore,
      maxDailyCost,
      sortBy,
      offset,
      limit);

  @override
  String toString() {
    return 'DestinationFilter(searchQuery: $searchQuery, budgetLevel: $budgetLevel, minSafetyScore: $minSafetyScore, minSoloSuitabilityScore: $minSoloSuitabilityScore, activityLevel: $activityLevel, countryCode: $countryCode, region: $region, tags: $tags, hiddenGemsOnly: $hiddenGemsOnly, minPopularityScore: $minPopularityScore, maxDailyCost: $maxDailyCost, sortBy: $sortBy, offset: $offset, limit: $limit)';
  }
}

/// @nodoc
abstract mixin class _$DestinationFilterCopyWith<$Res>
    implements $DestinationFilterCopyWith<$Res> {
  factory _$DestinationFilterCopyWith(
          _DestinationFilter value, $Res Function(_DestinationFilter) _then) =
      __$DestinationFilterCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? searchQuery,
      BudgetLevel? budgetLevel,
      double? minSafetyScore,
      double? minSoloSuitabilityScore,
      ActivityLevel? activityLevel,
      String? countryCode,
      String? region,
      List<String>? tags,
      bool hiddenGemsOnly,
      double? minPopularityScore,
      int? maxDailyCost,
      DestinationSortOrder sortBy,
      int offset,
      int limit});
}

/// @nodoc
class __$DestinationFilterCopyWithImpl<$Res>
    implements _$DestinationFilterCopyWith<$Res> {
  __$DestinationFilterCopyWithImpl(this._self, this._then);

  final _DestinationFilter _self;
  final $Res Function(_DestinationFilter) _then;

  /// Create a copy of DestinationFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? searchQuery = freezed,
    Object? budgetLevel = freezed,
    Object? minSafetyScore = freezed,
    Object? minSoloSuitabilityScore = freezed,
    Object? activityLevel = freezed,
    Object? countryCode = freezed,
    Object? region = freezed,
    Object? tags = freezed,
    Object? hiddenGemsOnly = null,
    Object? minPopularityScore = freezed,
    Object? maxDailyCost = freezed,
    Object? sortBy = null,
    Object? offset = null,
    Object? limit = null,
  }) {
    return _then(_DestinationFilter(
      searchQuery: freezed == searchQuery
          ? _self.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      budgetLevel: freezed == budgetLevel
          ? _self.budgetLevel
          : budgetLevel // ignore: cast_nullable_to_non_nullable
              as BudgetLevel?,
      minSafetyScore: freezed == minSafetyScore
          ? _self.minSafetyScore
          : minSafetyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      minSoloSuitabilityScore: freezed == minSoloSuitabilityScore
          ? _self.minSoloSuitabilityScore
          : minSoloSuitabilityScore // ignore: cast_nullable_to_non_nullable
              as double?,
      activityLevel: freezed == activityLevel
          ? _self.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as ActivityLevel?,
      countryCode: freezed == countryCode
          ? _self.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      region: freezed == region
          ? _self.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      hiddenGemsOnly: null == hiddenGemsOnly
          ? _self.hiddenGemsOnly
          : hiddenGemsOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      minPopularityScore: freezed == minPopularityScore
          ? _self.minPopularityScore
          : minPopularityScore // ignore: cast_nullable_to_non_nullable
              as double?,
      maxDailyCost: freezed == maxDailyCost
          ? _self.maxDailyCost
          : maxDailyCost // ignore: cast_nullable_to_non_nullable
              as int?,
      sortBy: null == sortBy
          ? _self.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as DestinationSortOrder,
      offset: null == offset
          ? _self.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _self.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
