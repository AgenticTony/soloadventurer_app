// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Journal _$JournalFromJson(Map<String, dynamic> json) {
  return _Journal.fromJson(json);
}

/// @nodoc
mixin _$Journal {
  /// Unique identifier for the journal
  String get id => throw _privateConstructorUsedError;

  /// ID of the trip this journal belongs to
  String get tripId => throw _privateConstructorUsedError;

  /// ID of the user who created the journal
  String get userId => throw _privateConstructorUsedError;

  /// Title of the journal entry
  String get title => throw _privateConstructorUsedError;

  /// Main content of the journal
  String get content => throw _privateConstructorUsedError;

  /// Date the journal entry was written (optional, defaults to createdAt)
  DateTime? get entryDate => throw _privateConstructorUsedError;

  /// Mood or emotional state associated with the entry
  String? get mood => throw _privateConstructorUsedError;

  /// Location where the journal was written
  String? get location => throw _privateConstructorUsedError;

  /// List of image URLs attached to the journal
  List<String>? get imageUrls => throw _privateConstructorUsedError;

  /// List of tags for categorizing the journal
  List<String>? get tags => throw _privateConstructorUsedError;

  /// Timestamp when the journal was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the journal was last updated
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Journal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Journal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JournalCopyWith<Journal> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JournalCopyWith<$Res> {
  factory $JournalCopyWith(Journal value, $Res Function(Journal) then) =
      _$JournalCopyWithImpl<$Res, Journal>;
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
class _$JournalCopyWithImpl<$Res, $Val extends Journal>
    implements $JournalCopyWith<$Res> {
  _$JournalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      entryDate: freezed == entryDate
          ? _value.entryDate
          : entryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mood: freezed == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: freezed == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JournalImplCopyWith<$Res> implements $JournalCopyWith<$Res> {
  factory _$$JournalImplCopyWith(
          _$JournalImpl value, $Res Function(_$JournalImpl) then) =
      __$$JournalImplCopyWithImpl<$Res>;
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
class __$$JournalImplCopyWithImpl<$Res>
    extends _$JournalCopyWithImpl<$Res, _$JournalImpl>
    implements _$$JournalImplCopyWith<$Res> {
  __$$JournalImplCopyWithImpl(
      _$JournalImpl _value, $Res Function(_$JournalImpl) _then)
      : super(_value, _then);

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
    return _then(_$JournalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      entryDate: freezed == entryDate
          ? _value.entryDate
          : entryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mood: freezed == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: freezed == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JournalImpl implements _Journal {
  const _$JournalImpl(
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

  factory _$JournalImpl.fromJson(Map<String, dynamic> json) =>
      _$$JournalImplFromJson(json);

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

  @override
  String toString() {
    return 'Journal(id: $id, tripId: $tripId, userId: $userId, title: $title, content: $content, entryDate: $entryDate, mood: $mood, location: $location, imageUrls: $imageUrls, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JournalImpl &&
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

  /// Create a copy of Journal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JournalImplCopyWith<_$JournalImpl> get copyWith =>
      __$$JournalImplCopyWithImpl<_$JournalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JournalImplToJson(
      this,
    );
  }
}

abstract class _Journal implements Journal {
  const factory _Journal(
      {required final String id,
      required final String tripId,
      required final String userId,
      required final String title,
      required final String content,
      final DateTime? entryDate,
      final String? mood,
      final String? location,
      final List<String>? imageUrls,
      final List<String>? tags,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$JournalImpl;

  factory _Journal.fromJson(Map<String, dynamic> json) = _$JournalImpl.fromJson;

  /// Unique identifier for the journal
  @override
  String get id;

  /// ID of the trip this journal belongs to
  @override
  String get tripId;

  /// ID of the user who created the journal
  @override
  String get userId;

  /// Title of the journal entry
  @override
  String get title;

  /// Main content of the journal
  @override
  String get content;

  /// Date the journal entry was written (optional, defaults to createdAt)
  @override
  DateTime? get entryDate;

  /// Mood or emotional state associated with the entry
  @override
  String? get mood;

  /// Location where the journal was written
  @override
  String? get location;

  /// List of image URLs attached to the journal
  @override
  List<String>? get imageUrls;

  /// List of tags for categorizing the journal
  @override
  List<String>? get tags;

  /// Timestamp when the journal was created
  @override
  DateTime get createdAt;

  /// Timestamp when the journal was last updated
  @override
  DateTime get updatedAt;

  /// Create a copy of Journal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JournalImplCopyWith<_$JournalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
