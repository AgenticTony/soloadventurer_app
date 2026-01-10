// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_destination.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedDestination {
  /// Unique identifier for this save entry
  String get id;

  /// User ID who saved this destination
  String get userId;

  /// The destination being saved
  Destination get destination;

  /// Type/location of save (wishlist or trip)
  SaveType get saveType;

  /// Trip ID if saveType is trip
  /// Null when saveType is wishlist
  String? get tripId;

  /// Optional notes added by the user
  /// Users can add personal notes about why they saved this destination
  /// or specific plans for it
  String? get notes;

  /// Timestamp when this destination was saved
  DateTime get createdAt;

  /// Timestamp when this save was last updated
  /// Used for tracking when notes or other fields were modified
  DateTime get updatedAt;

  /// Create a copy of SavedDestination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SavedDestinationCopyWith<SavedDestination> get copyWith =>
      _$SavedDestinationCopyWithImpl<SavedDestination>(
          this as SavedDestination, _$identity);

  /// Serializes this SavedDestination to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SavedDestination &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.saveType, saveType) ||
                other.saveType == saveType) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, destination,
      saveType, tripId, notes, createdAt, updatedAt);

  @override
  String toString() {
    return 'SavedDestination(id: $id, userId: $userId, destination: $destination, saveType: $saveType, tripId: $tripId, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $SavedDestinationCopyWith<$Res> {
  factory $SavedDestinationCopyWith(
          SavedDestination value, $Res Function(SavedDestination) _then) =
      _$SavedDestinationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      Destination destination,
      SaveType saveType,
      String? tripId,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt});

  $DestinationCopyWith<$Res> get destination;
}

/// @nodoc
class _$SavedDestinationCopyWithImpl<$Res>
    implements $SavedDestinationCopyWith<$Res> {
  _$SavedDestinationCopyWithImpl(this._self, this._then);

  final SavedDestination _self;
  final $Res Function(SavedDestination) _then;

  /// Create a copy of SavedDestination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? destination = null,
    Object? saveType = null,
    Object? tripId = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination,
      saveType: null == saveType
          ? _self.saveType
          : saveType // ignore: cast_nullable_to_non_nullable
              as SaveType,
      tripId: freezed == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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

  /// Create a copy of SavedDestination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res> get destination {
    return $DestinationCopyWith<$Res>(_self.destination, (value) {
      return _then(_self.copyWith(destination: value));
    });
  }
}

/// Adds pattern-matching-related methods to [SavedDestination].
extension SavedDestinationPatterns on SavedDestination {
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
    TResult Function(_SavedDestination value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SavedDestination() when $default != null:
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
    TResult Function(_SavedDestination value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SavedDestination():
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
    TResult? Function(_SavedDestination value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SavedDestination() when $default != null:
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
            Destination destination,
            SaveType saveType,
            String? tripId,
            String? notes,
            DateTime createdAt,
            DateTime updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SavedDestination() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.destination,
            _that.saveType,
            _that.tripId,
            _that.notes,
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
            String userId,
            Destination destination,
            SaveType saveType,
            String? tripId,
            String? notes,
            DateTime createdAt,
            DateTime updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SavedDestination():
        return $default(
            _that.id,
            _that.userId,
            _that.destination,
            _that.saveType,
            _that.tripId,
            _that.notes,
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
            String userId,
            Destination destination,
            SaveType saveType,
            String? tripId,
            String? notes,
            DateTime createdAt,
            DateTime updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SavedDestination() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.destination,
            _that.saveType,
            _that.tripId,
            _that.notes,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SavedDestination extends SavedDestination {
  const _SavedDestination(
      {required this.id,
      required this.userId,
      required this.destination,
      required this.saveType,
      this.tripId,
      this.notes,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  factory _SavedDestination.fromJson(Map<String, dynamic> json) =>
      _$SavedDestinationFromJson(json);

  /// Unique identifier for this save entry
  @override
  final String id;

  /// User ID who saved this destination
  @override
  final String userId;

  /// The destination being saved
  @override
  final Destination destination;

  /// Type/location of save (wishlist or trip)
  @override
  final SaveType saveType;

  /// Trip ID if saveType is trip
  /// Null when saveType is wishlist
  @override
  final String? tripId;

  /// Optional notes added by the user
  /// Users can add personal notes about why they saved this destination
  /// or specific plans for it
  @override
  final String? notes;

  /// Timestamp when this destination was saved
  @override
  final DateTime createdAt;

  /// Timestamp when this save was last updated
  /// Used for tracking when notes or other fields were modified
  @override
  final DateTime updatedAt;

  /// Create a copy of SavedDestination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SavedDestinationCopyWith<_SavedDestination> get copyWith =>
      __$SavedDestinationCopyWithImpl<_SavedDestination>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SavedDestinationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SavedDestination &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.saveType, saveType) ||
                other.saveType == saveType) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, destination,
      saveType, tripId, notes, createdAt, updatedAt);

  @override
  String toString() {
    return 'SavedDestination(id: $id, userId: $userId, destination: $destination, saveType: $saveType, tripId: $tripId, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$SavedDestinationCopyWith<$Res>
    implements $SavedDestinationCopyWith<$Res> {
  factory _$SavedDestinationCopyWith(
          _SavedDestination value, $Res Function(_SavedDestination) _then) =
      __$SavedDestinationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      Destination destination,
      SaveType saveType,
      String? tripId,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt});

  @override
  $DestinationCopyWith<$Res> get destination;
}

/// @nodoc
class __$SavedDestinationCopyWithImpl<$Res>
    implements _$SavedDestinationCopyWith<$Res> {
  __$SavedDestinationCopyWithImpl(this._self, this._then);

  final _SavedDestination _self;
  final $Res Function(_SavedDestination) _then;

  /// Create a copy of SavedDestination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? destination = null,
    Object? saveType = null,
    Object? tripId = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_SavedDestination(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination,
      saveType: null == saveType
          ? _self.saveType
          : saveType // ignore: cast_nullable_to_non_nullable
              as SaveType,
      tripId: freezed == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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

  /// Create a copy of SavedDestination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res> get destination {
    return $DestinationCopyWith<$Res>(_self.destination, (value) {
      return _then(_self.copyWith(destination: value));
    });
  }
}

// dart format on
