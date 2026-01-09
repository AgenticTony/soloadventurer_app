// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Journal {
  /// Unique identifier for the journal
  String get id;

  /// ID of the trip this journal belongs to
  String get tripId;

  /// ID of the user who created the journal
  String get userId;

  /// Title of the journal entry
  String get title;

  /// Main content of the journal
  String get content;

  /// Date the journal entry was written (optional, defaults to createdAt)
  DateTime? get entryDate;

  /// Mood or emotional state associated with the entry
  String? get mood;

  /// Location where the journal was written
  String? get location;

  /// List of image URLs attached to the journal
  List<String>? get imageUrls;

  /// List of tags for categorizing the journal
  List<String>? get tags;

  /// Timestamp when the journal was created
  DateTime get createdAt;

  /// Timestamp when the journal was last updated
  DateTime get updatedAt;

  /// Create a copy of Journal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $JournalCopyWith<Journal> get copyWith =>
      _$JournalCopyWithImpl<Journal>(this as Journal, _$identity);

  /// Serializes this Journal to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Journal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.entryDate, entryDate) ||
                other.entryDate == entryDate) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other.imageUrls, imageUrls) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tripId,
      userId,
      title,
      content,
      entryDate,
      mood,
      location,
      const DeepCollectionEquality().hash(imageUrls),
      const DeepCollectionEquality().hash(tags),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Journal(id: $id, tripId: $tripId, userId: $userId, title: $title, content: $content, entryDate: $entryDate, mood: $mood, location: $location, imageUrls: $imageUrls, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $JournalCopyWith<$Res> {
  factory $JournalCopyWith(Journal value, $Res Function(Journal) _then) =
      _$JournalCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String tripId,
      String userId,
      String title,
      String content,
      DateTime? entryDate,
      String? mood,
      String? location,
      List<String>? imageUrls,
      List<String>? tags,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$JournalCopyWithImpl<$Res> implements $JournalCopyWith<$Res> {
  _$JournalCopyWithImpl(this._self, this._then);

  final Journal _self;
  final $Res Function(Journal) _then;

  /// Create a copy of Journal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? userId = null,
    Object? title = null,
    Object? content = null,
    Object? entryDate = freezed,
    Object? mood = freezed,
    Object? location = freezed,
    Object? imageUrls = freezed,
    Object? tags = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      entryDate: freezed == entryDate
          ? _self.entryDate
          : entryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mood: freezed == mood
          ? _self.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: freezed == imageUrls
          ? _self.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [Journal].
extension JournalPatterns on Journal {
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
    TResult Function(_Journal value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Journal() when $default != null:
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
    TResult Function(_Journal value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Journal():
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
    TResult? Function(_Journal value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Journal() when $default != null:
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
            String tripId,
            String userId,
            String title,
            String content,
            DateTime? entryDate,
            String? mood,
            String? location,
            List<String>? imageUrls,
            List<String>? tags,
            DateTime createdAt,
            DateTime updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Journal() when $default != null:
        return $default(
            _that.id,
            _that.tripId,
            _that.userId,
            _that.title,
            _that.content,
            _that.entryDate,
            _that.mood,
            _that.location,
            _that.imageUrls,
            _that.tags,
            _that.createdAt,
            _that.updatedAt);
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
            String tripId,
            String userId,
            String title,
            String content,
            DateTime? entryDate,
            String? mood,
            String? location,
            List<String>? imageUrls,
            List<String>? tags,
            DateTime createdAt,
            DateTime updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Journal():
        return $default(
            _that.id,
            _that.tripId,
            _that.userId,
            _that.title,
            _that.content,
            _that.entryDate,
            _that.mood,
            _that.location,
            _that.imageUrls,
            _that.tags,
            _that.createdAt,
            _that.updatedAt);
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
            String tripId,
            String userId,
            String title,
            String content,
            DateTime? entryDate,
            String? mood,
            String? location,
            List<String>? imageUrls,
            List<String>? tags,
            DateTime createdAt,
            DateTime updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Journal() when $default != null:
        return $default(
            _that.id,
            _that.tripId,
            _that.userId,
            _that.title,
            _that.content,
            _that.entryDate,
            _that.mood,
            _that.location,
            _that.imageUrls,
            _that.tags,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Journal implements Journal {
  const _Journal(
      {required this.id,
      required this.tripId,
      required this.userId,
      required this.title,
      required this.content,
      this.entryDate,
      this.mood,
      this.location,
      final List<String>? imageUrls,
      final List<String>? tags,
      required this.createdAt,
      required this.updatedAt})
      : _imageUrls = imageUrls,
        _tags = tags;
  factory _Journal.fromJson(Map<String, dynamic> json) =>
      _$JournalFromJson(json);

  /// Unique identifier for the journal
  @override
  final String id;

  /// ID of the trip this journal belongs to
  @override
  final String tripId;

  /// ID of the user who created the journal
  @override
  final String userId;

  /// Title of the journal entry
  @override
  final String title;

  /// Main content of the journal
  @override
  final String content;

  /// Date the journal entry was written (optional, defaults to createdAt)
  @override
  final DateTime? entryDate;

  /// Mood or emotional state associated with the entry
  @override
  final String? mood;

  /// Location where the journal was written
  @override
  final String? location;

  /// List of image URLs attached to the journal
  final List<String>? _imageUrls;

  /// List of image URLs attached to the journal
  @override
  List<String>? get imageUrls {
    final value = _imageUrls;
    if (value == null) return null;
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// List of tags for categorizing the journal
  final List<String>? _tags;

  /// List of tags for categorizing the journal
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Timestamp when the journal was created
  @override
  final DateTime createdAt;

  /// Timestamp when the journal was last updated
  @override
  final DateTime updatedAt;

  /// Create a copy of Journal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$JournalCopyWith<_Journal> get copyWith =>
      __$JournalCopyWithImpl<_Journal>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$JournalToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Journal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.entryDate, entryDate) ||
                other.entryDate == entryDate) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tripId,
      userId,
      title,
      content,
      entryDate,
      mood,
      location,
      const DeepCollectionEquality().hash(_imageUrls),
      const DeepCollectionEquality().hash(_tags),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Journal(id: $id, tripId: $tripId, userId: $userId, title: $title, content: $content, entryDate: $entryDate, mood: $mood, location: $location, imageUrls: $imageUrls, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$JournalCopyWith<$Res> implements $JournalCopyWith<$Res> {
  factory _$JournalCopyWith(_Journal value, $Res Function(_Journal) _then) =
      __$JournalCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String tripId,
      String userId,
      String title,
      String content,
      DateTime? entryDate,
      String? mood,
      String? location,
      List<String>? imageUrls,
      List<String>? tags,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$JournalCopyWithImpl<$Res> implements _$JournalCopyWith<$Res> {
  __$JournalCopyWithImpl(this._self, this._then);

  final _Journal _self;
  final $Res Function(_Journal) _then;

  /// Create a copy of Journal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? userId = null,
    Object? title = null,
    Object? content = null,
    Object? entryDate = freezed,
    Object? mood = freezed,
    Object? location = freezed,
    Object? imageUrls = freezed,
    Object? tags = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_Journal(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      entryDate: freezed == entryDate
          ? _self.entryDate
          : entryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mood: freezed == mood
          ? _self.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: freezed == imageUrls
          ? _self._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
