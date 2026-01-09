// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'itinerary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Itinerary {
  String get id;
  String get name;
  Destination get destination;
  DateRange get dateRange;
  List<ItineraryItem> get items;
  bool get isStarter;
  DateTime get createdAt;
  DateTime? get updatedAt;
  String? get userId;
  String? get coverImageUrl;

  /// Create a copy of Itinerary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ItineraryCopyWith<Itinerary> get copyWith =>
      _$ItineraryCopyWithImpl<Itinerary>(this as Itinerary, _$identity);

  /// Serializes this Itinerary to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Itinerary &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.dateRange, dateRange) ||
                other.dateRange == dateRange) &&
            const DeepCollectionEquality().equals(other.items, items) &&
            (identical(other.isStarter, isStarter) ||
                other.isStarter == isStarter) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      destination,
      dateRange,
      const DeepCollectionEquality().hash(items),
      isStarter,
      createdAt,
      updatedAt,
      userId,
      coverImageUrl);

  @override
  String toString() {
    return 'Itinerary(id: $id, name: $name, destination: $destination, dateRange: $dateRange, items: $items, isStarter: $isStarter, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, coverImageUrl: $coverImageUrl)';
  }
}

/// @nodoc
abstract mixin class $ItineraryCopyWith<$Res> {
  factory $ItineraryCopyWith(Itinerary value, $Res Function(Itinerary) _then) =
      _$ItineraryCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      Destination destination,
      DateRange dateRange,
      List<ItineraryItem> items,
      bool isStarter,
      DateTime createdAt,
      DateTime? updatedAt,
      String? userId,
      String? coverImageUrl});

  $DestinationCopyWith<$Res> get destination;
  $DateRangeCopyWith<$Res> get dateRange;
}

/// @nodoc
class _$ItineraryCopyWithImpl<$Res> implements $ItineraryCopyWith<$Res> {
  _$ItineraryCopyWithImpl(this._self, this._then);

  final Itinerary _self;
  final $Res Function(Itinerary) _then;

  /// Create a copy of Itinerary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? destination = null,
    Object? dateRange = null,
    Object? items = null,
    Object? isStarter = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? userId = freezed,
    Object? coverImageUrl = freezed,
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
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination,
      dateRange: null == dateRange
          ? _self.dateRange
          : dateRange // ignore: cast_nullable_to_non_nullable
              as DateRange,
      items: null == items
          ? _self.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ItineraryItem>,
      isStarter: null == isStarter
          ? _self.isStarter
          : isStarter // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageUrl: freezed == coverImageUrl
          ? _self.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of Itinerary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res> get destination {
    return $DestinationCopyWith<$Res>(_self.destination, (value) {
      return _then(_self.copyWith(destination: value));
    });
  }

  /// Create a copy of Itinerary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DateRangeCopyWith<$Res> get dateRange {
    return $DateRangeCopyWith<$Res>(_self.dateRange, (value) {
      return _then(_self.copyWith(dateRange: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Itinerary].
extension ItineraryPatterns on Itinerary {
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
    TResult Function(_Itinerary value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Itinerary() when $default != null:
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
    TResult Function(_Itinerary value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Itinerary():
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
    TResult? Function(_Itinerary value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Itinerary() when $default != null:
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
            Destination destination,
            DateRange dateRange,
            List<ItineraryItem> items,
            bool isStarter,
            DateTime createdAt,
            DateTime? updatedAt,
            String? userId,
            String? coverImageUrl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Itinerary() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.destination,
            _that.dateRange,
            _that.items,
            _that.isStarter,
            _that.createdAt,
            _that.updatedAt,
            _that.userId,
            _that.coverImageUrl);
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
            Destination destination,
            DateRange dateRange,
            List<ItineraryItem> items,
            bool isStarter,
            DateTime createdAt,
            DateTime? updatedAt,
            String? userId,
            String? coverImageUrl)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Itinerary():
        return $default(
            _that.id,
            _that.name,
            _that.destination,
            _that.dateRange,
            _that.items,
            _that.isStarter,
            _that.createdAt,
            _that.updatedAt,
            _that.userId,
            _that.coverImageUrl);
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
            Destination destination,
            DateRange dateRange,
            List<ItineraryItem> items,
            bool isStarter,
            DateTime createdAt,
            DateTime? updatedAt,
            String? userId,
            String? coverImageUrl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Itinerary() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.destination,
            _that.dateRange,
            _that.items,
            _that.isStarter,
            _that.createdAt,
            _that.updatedAt,
            _that.userId,
            _that.coverImageUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Itinerary extends Itinerary {
  const _Itinerary(
      {required this.id,
      required this.name,
      required this.destination,
      required this.dateRange,
      required final List<ItineraryItem> items,
      this.isStarter = false,
      required this.createdAt,
      this.updatedAt,
      this.userId,
      this.coverImageUrl})
      : _items = items,
        super._();
  factory _Itinerary.fromJson(Map<String, dynamic> json) =>
      _$ItineraryFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final Destination destination;
  @override
  final DateRange dateRange;
  final List<ItineraryItem> _items;
  @override
  List<ItineraryItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final bool isStarter;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? userId;
  @override
  final String? coverImageUrl;

  /// Create a copy of Itinerary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ItineraryCopyWith<_Itinerary> get copyWith =>
      __$ItineraryCopyWithImpl<_Itinerary>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ItineraryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Itinerary &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.dateRange, dateRange) ||
                other.dateRange == dateRange) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.isStarter, isStarter) ||
                other.isStarter == isStarter) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      destination,
      dateRange,
      const DeepCollectionEquality().hash(_items),
      isStarter,
      createdAt,
      updatedAt,
      userId,
      coverImageUrl);

  @override
  String toString() {
    return 'Itinerary(id: $id, name: $name, destination: $destination, dateRange: $dateRange, items: $items, isStarter: $isStarter, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, coverImageUrl: $coverImageUrl)';
  }
}

/// @nodoc
abstract mixin class _$ItineraryCopyWith<$Res>
    implements $ItineraryCopyWith<$Res> {
  factory _$ItineraryCopyWith(
          _Itinerary value, $Res Function(_Itinerary) _then) =
      __$ItineraryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      Destination destination,
      DateRange dateRange,
      List<ItineraryItem> items,
      bool isStarter,
      DateTime createdAt,
      DateTime? updatedAt,
      String? userId,
      String? coverImageUrl});

  @override
  $DestinationCopyWith<$Res> get destination;
  @override
  $DateRangeCopyWith<$Res> get dateRange;
}

/// @nodoc
class __$ItineraryCopyWithImpl<$Res> implements _$ItineraryCopyWith<$Res> {
  __$ItineraryCopyWithImpl(this._self, this._then);

  final _Itinerary _self;
  final $Res Function(_Itinerary) _then;

  /// Create a copy of Itinerary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? destination = null,
    Object? dateRange = null,
    Object? items = null,
    Object? isStarter = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? userId = freezed,
    Object? coverImageUrl = freezed,
  }) {
    return _then(_Itinerary(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination,
      dateRange: null == dateRange
          ? _self.dateRange
          : dateRange // ignore: cast_nullable_to_non_nullable
              as DateRange,
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ItineraryItem>,
      isStarter: null == isStarter
          ? _self.isStarter
          : isStarter // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageUrl: freezed == coverImageUrl
          ? _self.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of Itinerary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res> get destination {
    return $DestinationCopyWith<$Res>(_self.destination, (value) {
      return _then(_self.copyWith(destination: value));
    });
  }

  /// Create a copy of Itinerary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DateRangeCopyWith<$Res> get dateRange {
    return $DateRangeCopyWith<$Res>(_self.dateRange, (value) {
      return _then(_self.copyWith(dateRange: value));
    });
  }
}

// dart format on
