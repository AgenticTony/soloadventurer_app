// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'curated_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CuratedList {
  /// Unique identifier for this curated list
  String get id;

  /// Display name of the curated list
  /// Example: "Hidden Gems of Southeast Asia", "Best European Cities for Solo Travel"
  String get name;

  /// Detailed description of the curated list
  /// Explains the theme and what travelers can expect
  String get description;

  /// Type/category of this curated list
  CuratedListType get type;

  /// List of destinations in this curated collection
  /// Ordered by relevance or recommendation priority
  List<Destination> get destinations;

  /// Cover/featured image for the curated list
  /// Used in cards and headers
  String? get coverImageUrl;

  /// Additional images for the curated list (gallery)
  /// Can include destination preview images
  List<String>? get images;

  /// Name of the curator/creator
  /// Could be "SoloAdventurer Team", "Travel Expert Name", etc.
  String? get curatorName;

  /// Curator/creator profile image
  String? get curatorImageUrl;

  /// Total number of destinations in this list
  /// Useful for quick display without loading destinations
  int get destinationCount;

  /// Whether this list is featured/promoted
  /// Featured lists appear prominently in the app
  bool get isFeatured;

  /// Order/priority for display in lists
  /// Lower values appear first
  int get displayOrder;

  /// Tags for categorization and filtering
  /// Example: ["asia", "budget", "cultural"]
  List<String>? get tags;

  /// Average safety score of destinations in this list
  /// Pre-calculated for quick filtering (1-10)
  double? get averageSafetyScore;

  /// Average solo suitability score of destinations in this list
  /// Pre-calculated for quick filtering (1-10)
  double? get averageSoloSuitabilityScore;

  /// Budget level range (if applicable)
  /// Example: "Budget-friendly", "Moderate to Expensive"
  String? get budgetRange;

  /// Best season/time to visit destinations in this list
  /// Example: "March to May", "Year-round"
  String? get bestTimeToVisit;

  /// Estimated duration recommendation
  /// Example: "7-10 days", "2 weeks"
  String? get recommendedDuration;

  /// View count (popularity metric)
  int get viewCount;

  /// Save/bookmark count (popularity metric)
  int get saveCount;

  /// Timestamp when this curated list was created
  DateTime get createdAt;

  /// Timestamp when this curated list was last updated
  DateTime get updatedAt;

  /// Timestamp when this list was last published/featured
  DateTime? get publishedAt;

  /// Whether this list is currently published and visible
  bool get isPublished;

  /// Create a copy of CuratedList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CuratedListCopyWith<CuratedList> get copyWith =>
      _$CuratedListCopyWithImpl<CuratedList>(this as CuratedList, _$identity);

  /// Serializes this CuratedList to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CuratedList &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other.destinations, destinations) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            const DeepCollectionEquality().equals(other.images, images) &&
            (identical(other.curatorName, curatorName) ||
                other.curatorName == curatorName) &&
            (identical(other.curatorImageUrl, curatorImageUrl) ||
                other.curatorImageUrl == curatorImageUrl) &&
            (identical(other.destinationCount, destinationCount) ||
                other.destinationCount == destinationCount) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.averageSafetyScore, averageSafetyScore) ||
                other.averageSafetyScore == averageSafetyScore) &&
            (identical(other.averageSoloSuitabilityScore,
                    averageSoloSuitabilityScore) ||
                other.averageSoloSuitabilityScore ==
                    averageSoloSuitabilityScore) &&
            (identical(other.budgetRange, budgetRange) ||
                other.budgetRange == budgetRange) &&
            (identical(other.bestTimeToVisit, bestTimeToVisit) ||
                other.bestTimeToVisit == bestTimeToVisit) &&
            (identical(other.recommendedDuration, recommendedDuration) ||
                other.recommendedDuration == recommendedDuration) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.saveCount, saveCount) ||
                other.saveCount == saveCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        type,
        const DeepCollectionEquality().hash(destinations),
        coverImageUrl,
        const DeepCollectionEquality().hash(images),
        curatorName,
        curatorImageUrl,
        destinationCount,
        isFeatured,
        displayOrder,
        const DeepCollectionEquality().hash(tags),
        averageSafetyScore,
        averageSoloSuitabilityScore,
        budgetRange,
        bestTimeToVisit,
        recommendedDuration,
        viewCount,
        saveCount,
        createdAt,
        updatedAt,
        publishedAt,
        isPublished
      ]);

  @override
  String toString() {
    return 'CuratedList(id: $id, name: $name, description: $description, type: $type, destinations: $destinations, coverImageUrl: $coverImageUrl, images: $images, curatorName: $curatorName, curatorImageUrl: $curatorImageUrl, destinationCount: $destinationCount, isFeatured: $isFeatured, displayOrder: $displayOrder, tags: $tags, averageSafetyScore: $averageSafetyScore, averageSoloSuitabilityScore: $averageSoloSuitabilityScore, budgetRange: $budgetRange, bestTimeToVisit: $bestTimeToVisit, recommendedDuration: $recommendedDuration, viewCount: $viewCount, saveCount: $saveCount, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt, isPublished: $isPublished)';
  }
}

/// @nodoc
abstract mixin class $CuratedListCopyWith<$Res> {
  factory $CuratedListCopyWith(
          CuratedList value, $Res Function(CuratedList) _then) =
      _$CuratedListCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      CuratedListType type,
      List<Destination> destinations,
      String? coverImageUrl,
      List<String>? images,
      String? curatorName,
      String? curatorImageUrl,
      int destinationCount,
      bool isFeatured,
      int displayOrder,
      List<String>? tags,
      double? averageSafetyScore,
      double? averageSoloSuitabilityScore,
      String? budgetRange,
      String? bestTimeToVisit,
      String? recommendedDuration,
      int viewCount,
      int saveCount,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? publishedAt,
      bool isPublished});
}

/// @nodoc
class _$CuratedListCopyWithImpl<$Res> implements $CuratedListCopyWith<$Res> {
  _$CuratedListCopyWithImpl(this._self, this._then);

  final CuratedList _self;
  final $Res Function(CuratedList) _then;

  /// Create a copy of CuratedList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? destinations = null,
    Object? coverImageUrl = freezed,
    Object? images = freezed,
    Object? curatorName = freezed,
    Object? curatorImageUrl = freezed,
    Object? destinationCount = null,
    Object? isFeatured = null,
    Object? displayOrder = null,
    Object? tags = freezed,
    Object? averageSafetyScore = freezed,
    Object? averageSoloSuitabilityScore = freezed,
    Object? budgetRange = freezed,
    Object? bestTimeToVisit = freezed,
    Object? recommendedDuration = freezed,
    Object? viewCount = null,
    Object? saveCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? publishedAt = freezed,
    Object? isPublished = null,
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
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as CuratedListType,
      destinations: null == destinations
          ? _self.destinations
          : destinations // ignore: cast_nullable_to_non_nullable
              as List<Destination>,
      coverImageUrl: freezed == coverImageUrl
          ? _self.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _self.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      curatorName: freezed == curatorName
          ? _self.curatorName
          : curatorName // ignore: cast_nullable_to_non_nullable
              as String?,
      curatorImageUrl: freezed == curatorImageUrl
          ? _self.curatorImageUrl
          : curatorImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      destinationCount: null == destinationCount
          ? _self.destinationCount
          : destinationCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _self.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      displayOrder: null == displayOrder
          ? _self.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int,
      tags: freezed == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      averageSafetyScore: freezed == averageSafetyScore
          ? _self.averageSafetyScore
          : averageSafetyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      averageSoloSuitabilityScore: freezed == averageSoloSuitabilityScore
          ? _self.averageSoloSuitabilityScore
          : averageSoloSuitabilityScore // ignore: cast_nullable_to_non_nullable
              as double?,
      budgetRange: freezed == budgetRange
          ? _self.budgetRange
          : budgetRange // ignore: cast_nullable_to_non_nullable
              as String?,
      bestTimeToVisit: freezed == bestTimeToVisit
          ? _self.bestTimeToVisit
          : bestTimeToVisit // ignore: cast_nullable_to_non_nullable
              as String?,
      recommendedDuration: freezed == recommendedDuration
          ? _self.recommendedDuration
          : recommendedDuration // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: null == viewCount
          ? _self.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      saveCount: null == saveCount
          ? _self.saveCount
          : saveCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      publishedAt: freezed == publishedAt
          ? _self.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPublished: null == isPublished
          ? _self.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [CuratedList].
extension CuratedListPatterns on CuratedList {
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
    TResult Function(_CuratedList value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CuratedList() when $default != null:
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
    TResult Function(_CuratedList value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CuratedList():
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
    TResult? Function(_CuratedList value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CuratedList() when $default != null:
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
            CuratedListType type,
            List<Destination> destinations,
            String? coverImageUrl,
            List<String>? images,
            String? curatorName,
            String? curatorImageUrl,
            int destinationCount,
            bool isFeatured,
            int displayOrder,
            List<String>? tags,
            double? averageSafetyScore,
            double? averageSoloSuitabilityScore,
            String? budgetRange,
            String? bestTimeToVisit,
            String? recommendedDuration,
            int viewCount,
            int saveCount,
            DateTime createdAt,
            DateTime updatedAt,
            DateTime? publishedAt,
            bool isPublished)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CuratedList() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.type,
            _that.destinations,
            _that.coverImageUrl,
            _that.images,
            _that.curatorName,
            _that.curatorImageUrl,
            _that.destinationCount,
            _that.isFeatured,
            _that.displayOrder,
            _that.tags,
            _that.averageSafetyScore,
            _that.averageSoloSuitabilityScore,
            _that.budgetRange,
            _that.bestTimeToVisit,
            _that.recommendedDuration,
            _that.viewCount,
            _that.saveCount,
            _that.createdAt,
            _that.updatedAt,
            _that.publishedAt,
            _that.isPublished);
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
            CuratedListType type,
            List<Destination> destinations,
            String? coverImageUrl,
            List<String>? images,
            String? curatorName,
            String? curatorImageUrl,
            int destinationCount,
            bool isFeatured,
            int displayOrder,
            List<String>? tags,
            double? averageSafetyScore,
            double? averageSoloSuitabilityScore,
            String? budgetRange,
            String? bestTimeToVisit,
            String? recommendedDuration,
            int viewCount,
            int saveCount,
            DateTime createdAt,
            DateTime updatedAt,
            DateTime? publishedAt,
            bool isPublished)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CuratedList():
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.type,
            _that.destinations,
            _that.coverImageUrl,
            _that.images,
            _that.curatorName,
            _that.curatorImageUrl,
            _that.destinationCount,
            _that.isFeatured,
            _that.displayOrder,
            _that.tags,
            _that.averageSafetyScore,
            _that.averageSoloSuitabilityScore,
            _that.budgetRange,
            _that.bestTimeToVisit,
            _that.recommendedDuration,
            _that.viewCount,
            _that.saveCount,
            _that.createdAt,
            _that.updatedAt,
            _that.publishedAt,
            _that.isPublished);
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
            String name,
            String description,
            CuratedListType type,
            List<Destination> destinations,
            String? coverImageUrl,
            List<String>? images,
            String? curatorName,
            String? curatorImageUrl,
            int destinationCount,
            bool isFeatured,
            int displayOrder,
            List<String>? tags,
            double? averageSafetyScore,
            double? averageSoloSuitabilityScore,
            String? budgetRange,
            String? bestTimeToVisit,
            String? recommendedDuration,
            int viewCount,
            int saveCount,
            DateTime createdAt,
            DateTime updatedAt,
            DateTime? publishedAt,
            bool isPublished)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CuratedList() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.type,
            _that.destinations,
            _that.coverImageUrl,
            _that.images,
            _that.curatorName,
            _that.curatorImageUrl,
            _that.destinationCount,
            _that.isFeatured,
            _that.displayOrder,
            _that.tags,
            _that.averageSafetyScore,
            _that.averageSoloSuitabilityScore,
            _that.budgetRange,
            _that.bestTimeToVisit,
            _that.recommendedDuration,
            _that.viewCount,
            _that.saveCount,
            _that.createdAt,
            _that.updatedAt,
            _that.publishedAt,
            _that.isPublished);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CuratedList extends CuratedList {
  const _CuratedList(
      {required this.id,
      required this.name,
      required this.description,
      required this.type,
      required final List<Destination> destinations,
      this.coverImageUrl,
      final List<String>? images,
      this.curatorName,
      this.curatorImageUrl,
      this.destinationCount = 0,
      this.isFeatured = false,
      this.displayOrder = 0,
      final List<String>? tags,
      this.averageSafetyScore,
      this.averageSoloSuitabilityScore,
      this.budgetRange,
      this.bestTimeToVisit,
      this.recommendedDuration,
      this.viewCount = 0,
      this.saveCount = 0,
      required this.createdAt,
      required this.updatedAt,
      this.publishedAt,
      this.isPublished = true})
      : _destinations = destinations,
        _images = images,
        _tags = tags,
        super._();
  factory _CuratedList.fromJson(Map<String, dynamic> json) =>
      _$CuratedListFromJson(json);

  /// Unique identifier for this curated list
  @override
  final String id;

  /// Display name of the curated list
  /// Example: "Hidden Gems of Southeast Asia", "Best European Cities for Solo Travel"
  @override
  final String name;

  /// Detailed description of the curated list
  /// Explains the theme and what travelers can expect
  @override
  final String description;

  /// Type/category of this curated list
  @override
  final CuratedListType type;

  /// List of destinations in this curated collection
  /// Ordered by relevance or recommendation priority
  final List<Destination> _destinations;

  /// List of destinations in this curated collection
  /// Ordered by relevance or recommendation priority
  @override
  List<Destination> get destinations {
    if (_destinations is EqualUnmodifiableListView) return _destinations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_destinations);
  }

  /// Cover/featured image for the curated list
  /// Used in cards and headers
  @override
  final String? coverImageUrl;

  /// Additional images for the curated list (gallery)
  /// Can include destination preview images
  final List<String>? _images;

  /// Additional images for the curated list (gallery)
  /// Can include destination preview images
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Name of the curator/creator
  /// Could be "SoloAdventurer Team", "Travel Expert Name", etc.
  @override
  final String? curatorName;

  /// Curator/creator profile image
  @override
  final String? curatorImageUrl;

  /// Total number of destinations in this list
  /// Useful for quick display without loading destinations
  @override
  @JsonKey()
  final int destinationCount;

  /// Whether this list is featured/promoted
  /// Featured lists appear prominently in the app
  @override
  @JsonKey()
  final bool isFeatured;

  /// Order/priority for display in lists
  /// Lower values appear first
  @override
  @JsonKey()
  final int displayOrder;

  /// Tags for categorization and filtering
  /// Example: ["asia", "budget", "cultural"]
  final List<String>? _tags;

  /// Tags for categorization and filtering
  /// Example: ["asia", "budget", "cultural"]
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Average safety score of destinations in this list
  /// Pre-calculated for quick filtering (1-10)
  @override
  final double? averageSafetyScore;

  /// Average solo suitability score of destinations in this list
  /// Pre-calculated for quick filtering (1-10)
  @override
  final double? averageSoloSuitabilityScore;

  /// Budget level range (if applicable)
  /// Example: "Budget-friendly", "Moderate to Expensive"
  @override
  final String? budgetRange;

  /// Best season/time to visit destinations in this list
  /// Example: "March to May", "Year-round"
  @override
  final String? bestTimeToVisit;

  /// Estimated duration recommendation
  /// Example: "7-10 days", "2 weeks"
  @override
  final String? recommendedDuration;

  /// View count (popularity metric)
  @override
  @JsonKey()
  final int viewCount;

  /// Save/bookmark count (popularity metric)
  @override
  @JsonKey()
  final int saveCount;

  /// Timestamp when this curated list was created
  @override
  final DateTime createdAt;

  /// Timestamp when this curated list was last updated
  @override
  final DateTime updatedAt;

  /// Timestamp when this list was last published/featured
  @override
  final DateTime? publishedAt;

  /// Whether this list is currently published and visible
  @override
  @JsonKey()
  final bool isPublished;

  /// Create a copy of CuratedList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CuratedListCopyWith<_CuratedList> get copyWith =>
      __$CuratedListCopyWithImpl<_CuratedList>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CuratedListToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CuratedList &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._destinations, _destinations) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.curatorName, curatorName) ||
                other.curatorName == curatorName) &&
            (identical(other.curatorImageUrl, curatorImageUrl) ||
                other.curatorImageUrl == curatorImageUrl) &&
            (identical(other.destinationCount, destinationCount) ||
                other.destinationCount == destinationCount) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.averageSafetyScore, averageSafetyScore) ||
                other.averageSafetyScore == averageSafetyScore) &&
            (identical(other.averageSoloSuitabilityScore,
                    averageSoloSuitabilityScore) ||
                other.averageSoloSuitabilityScore ==
                    averageSoloSuitabilityScore) &&
            (identical(other.budgetRange, budgetRange) ||
                other.budgetRange == budgetRange) &&
            (identical(other.bestTimeToVisit, bestTimeToVisit) ||
                other.bestTimeToVisit == bestTimeToVisit) &&
            (identical(other.recommendedDuration, recommendedDuration) ||
                other.recommendedDuration == recommendedDuration) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.saveCount, saveCount) ||
                other.saveCount == saveCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        type,
        const DeepCollectionEquality().hash(_destinations),
        coverImageUrl,
        const DeepCollectionEquality().hash(_images),
        curatorName,
        curatorImageUrl,
        destinationCount,
        isFeatured,
        displayOrder,
        const DeepCollectionEquality().hash(_tags),
        averageSafetyScore,
        averageSoloSuitabilityScore,
        budgetRange,
        bestTimeToVisit,
        recommendedDuration,
        viewCount,
        saveCount,
        createdAt,
        updatedAt,
        publishedAt,
        isPublished
      ]);

  @override
  String toString() {
    return 'CuratedList(id: $id, name: $name, description: $description, type: $type, destinations: $destinations, coverImageUrl: $coverImageUrl, images: $images, curatorName: $curatorName, curatorImageUrl: $curatorImageUrl, destinationCount: $destinationCount, isFeatured: $isFeatured, displayOrder: $displayOrder, tags: $tags, averageSafetyScore: $averageSafetyScore, averageSoloSuitabilityScore: $averageSoloSuitabilityScore, budgetRange: $budgetRange, bestTimeToVisit: $bestTimeToVisit, recommendedDuration: $recommendedDuration, viewCount: $viewCount, saveCount: $saveCount, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt, isPublished: $isPublished)';
  }
}

/// @nodoc
abstract mixin class _$CuratedListCopyWith<$Res>
    implements $CuratedListCopyWith<$Res> {
  factory _$CuratedListCopyWith(
          _CuratedList value, $Res Function(_CuratedList) _then) =
      __$CuratedListCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      CuratedListType type,
      List<Destination> destinations,
      String? coverImageUrl,
      List<String>? images,
      String? curatorName,
      String? curatorImageUrl,
      int destinationCount,
      bool isFeatured,
      int displayOrder,
      List<String>? tags,
      double? averageSafetyScore,
      double? averageSoloSuitabilityScore,
      String? budgetRange,
      String? bestTimeToVisit,
      String? recommendedDuration,
      int viewCount,
      int saveCount,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? publishedAt,
      bool isPublished});
}

/// @nodoc
class __$CuratedListCopyWithImpl<$Res> implements _$CuratedListCopyWith<$Res> {
  __$CuratedListCopyWithImpl(this._self, this._then);

  final _CuratedList _self;
  final $Res Function(_CuratedList) _then;

  /// Create a copy of CuratedList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? destinations = null,
    Object? coverImageUrl = freezed,
    Object? images = freezed,
    Object? curatorName = freezed,
    Object? curatorImageUrl = freezed,
    Object? destinationCount = null,
    Object? isFeatured = null,
    Object? displayOrder = null,
    Object? tags = freezed,
    Object? averageSafetyScore = freezed,
    Object? averageSoloSuitabilityScore = freezed,
    Object? budgetRange = freezed,
    Object? bestTimeToVisit = freezed,
    Object? recommendedDuration = freezed,
    Object? viewCount = null,
    Object? saveCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? publishedAt = freezed,
    Object? isPublished = null,
  }) {
    return _then(_CuratedList(
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
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as CuratedListType,
      destinations: null == destinations
          ? _self._destinations
          : destinations // ignore: cast_nullable_to_non_nullable
              as List<Destination>,
      coverImageUrl: freezed == coverImageUrl
          ? _self.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _self._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      curatorName: freezed == curatorName
          ? _self.curatorName
          : curatorName // ignore: cast_nullable_to_non_nullable
              as String?,
      curatorImageUrl: freezed == curatorImageUrl
          ? _self.curatorImageUrl
          : curatorImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      destinationCount: null == destinationCount
          ? _self.destinationCount
          : destinationCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _self.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      displayOrder: null == displayOrder
          ? _self.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int,
      tags: freezed == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      averageSafetyScore: freezed == averageSafetyScore
          ? _self.averageSafetyScore
          : averageSafetyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      averageSoloSuitabilityScore: freezed == averageSoloSuitabilityScore
          ? _self.averageSoloSuitabilityScore
          : averageSoloSuitabilityScore // ignore: cast_nullable_to_non_nullable
              as double?,
      budgetRange: freezed == budgetRange
          ? _self.budgetRange
          : budgetRange // ignore: cast_nullable_to_non_nullable
              as String?,
      bestTimeToVisit: freezed == bestTimeToVisit
          ? _self.bestTimeToVisit
          : bestTimeToVisit // ignore: cast_nullable_to_non_nullable
              as String?,
      recommendedDuration: freezed == recommendedDuration
          ? _self.recommendedDuration
          : recommendedDuration // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: null == viewCount
          ? _self.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      saveCount: null == saveCount
          ? _self.saveCount
          : saveCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      publishedAt: freezed == publishedAt
          ? _self.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPublished: null == isPublished
          ? _self.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
