// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'travel_preference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TravelPreference {
  String get id;
  String get userId;
  List<String> get travelStyles;
  List<String> get accommodationTypes;
  List<String> get transportationTypes;
  int get minBudget;
  int get maxBudget;
  int get minTripDuration;
  int get maxTripDuration;
  List<String> get preferredDestinations;
  List<String> get avoidDestinations;
  bool get isFlexibleDates;
  DateTime get createdAt;
  DateTime get updatedAt;

  /// Create a copy of TravelPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TravelPreferenceCopyWith<TravelPreference> get copyWith =>
      _$TravelPreferenceCopyWithImpl<TravelPreference>(
          this as TravelPreference, _$identity);

  /// Serializes this TravelPreference to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TravelPreference &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality()
                .equals(other.travelStyles, travelStyles) &&
            const DeepCollectionEquality()
                .equals(other.accommodationTypes, accommodationTypes) &&
            const DeepCollectionEquality()
                .equals(other.transportationTypes, transportationTypes) &&
            (identical(other.minBudget, minBudget) ||
                other.minBudget == minBudget) &&
            (identical(other.maxBudget, maxBudget) ||
                other.maxBudget == maxBudget) &&
            (identical(other.minTripDuration, minTripDuration) ||
                other.minTripDuration == minTripDuration) &&
            (identical(other.maxTripDuration, maxTripDuration) ||
                other.maxTripDuration == maxTripDuration) &&
            const DeepCollectionEquality()
                .equals(other.preferredDestinations, preferredDestinations) &&
            const DeepCollectionEquality()
                .equals(other.avoidDestinations, avoidDestinations) &&
            (identical(other.isFlexibleDates, isFlexibleDates) ||
                other.isFlexibleDates == isFlexibleDates) &&
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
      userId,
      const DeepCollectionEquality().hash(travelStyles),
      const DeepCollectionEquality().hash(accommodationTypes),
      const DeepCollectionEquality().hash(transportationTypes),
      minBudget,
      maxBudget,
      minTripDuration,
      maxTripDuration,
      const DeepCollectionEquality().hash(preferredDestinations),
      const DeepCollectionEquality().hash(avoidDestinations),
      isFlexibleDates,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'TravelPreference(id: $id, userId: $userId, travelStyles: $travelStyles, accommodationTypes: $accommodationTypes, transportationTypes: $transportationTypes, minBudget: $minBudget, maxBudget: $maxBudget, minTripDuration: $minTripDuration, maxTripDuration: $maxTripDuration, preferredDestinations: $preferredDestinations, avoidDestinations: $avoidDestinations, isFlexibleDates: $isFlexibleDates, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $TravelPreferenceCopyWith<$Res> {
  factory $TravelPreferenceCopyWith(
          TravelPreference value, $Res Function(TravelPreference) _then) =
      _$TravelPreferenceCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      List<String> travelStyles,
      List<String> accommodationTypes,
      List<String> transportationTypes,
      int minBudget,
      int maxBudget,
      int minTripDuration,
      int maxTripDuration,
      List<String> preferredDestinations,
      List<String> avoidDestinations,
      bool isFlexibleDates,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$TravelPreferenceCopyWithImpl<$Res>
    implements $TravelPreferenceCopyWith<$Res> {
  _$TravelPreferenceCopyWithImpl(this._self, this._then);

  final TravelPreference _self;
  final $Res Function(TravelPreference) _then;

  /// Create a copy of TravelPreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? travelStyles = null,
    Object? accommodationTypes = null,
    Object? transportationTypes = null,
    Object? minBudget = null,
    Object? maxBudget = null,
    Object? minTripDuration = null,
    Object? maxTripDuration = null,
    Object? preferredDestinations = null,
    Object? avoidDestinations = null,
    Object? isFlexibleDates = null,
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
      travelStyles: null == travelStyles
          ? _self.travelStyles
          : travelStyles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      accommodationTypes: null == accommodationTypes
          ? _self.accommodationTypes
          : accommodationTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      transportationTypes: null == transportationTypes
          ? _self.transportationTypes
          : transportationTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      minBudget: null == minBudget
          ? _self.minBudget
          : minBudget // ignore: cast_nullable_to_non_nullable
              as int,
      maxBudget: null == maxBudget
          ? _self.maxBudget
          : maxBudget // ignore: cast_nullable_to_non_nullable
              as int,
      minTripDuration: null == minTripDuration
          ? _self.minTripDuration
          : minTripDuration // ignore: cast_nullable_to_non_nullable
              as int,
      maxTripDuration: null == maxTripDuration
          ? _self.maxTripDuration
          : maxTripDuration // ignore: cast_nullable_to_non_nullable
              as int,
      preferredDestinations: null == preferredDestinations
          ? _self.preferredDestinations
          : preferredDestinations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      avoidDestinations: null == avoidDestinations
          ? _self.avoidDestinations
          : avoidDestinations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFlexibleDates: null == isFlexibleDates
          ? _self.isFlexibleDates
          : isFlexibleDates // ignore: cast_nullable_to_non_nullable
              as bool,
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

/// Adds pattern-matching-related methods to [TravelPreference].
extension TravelPreferencePatterns on TravelPreference {
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
    TResult Function(_TravelPreference value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TravelPreference() when $default != null:
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
    TResult Function(_TravelPreference value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TravelPreference():
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
    TResult? Function(_TravelPreference value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TravelPreference() when $default != null:
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
            List<String> travelStyles,
            List<String> accommodationTypes,
            List<String> transportationTypes,
            int minBudget,
            int maxBudget,
            int minTripDuration,
            int maxTripDuration,
            List<String> preferredDestinations,
            List<String> avoidDestinations,
            bool isFlexibleDates,
            DateTime createdAt,
            DateTime updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TravelPreference() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.travelStyles,
            _that.accommodationTypes,
            _that.transportationTypes,
            _that.minBudget,
            _that.maxBudget,
            _that.minTripDuration,
            _that.maxTripDuration,
            _that.preferredDestinations,
            _that.avoidDestinations,
            _that.isFlexibleDates,
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
            List<String> travelStyles,
            List<String> accommodationTypes,
            List<String> transportationTypes,
            int minBudget,
            int maxBudget,
            int minTripDuration,
            int maxTripDuration,
            List<String> preferredDestinations,
            List<String> avoidDestinations,
            bool isFlexibleDates,
            DateTime createdAt,
            DateTime updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TravelPreference():
        return $default(
            _that.id,
            _that.userId,
            _that.travelStyles,
            _that.accommodationTypes,
            _that.transportationTypes,
            _that.minBudget,
            _that.maxBudget,
            _that.minTripDuration,
            _that.maxTripDuration,
            _that.preferredDestinations,
            _that.avoidDestinations,
            _that.isFlexibleDates,
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
            List<String> travelStyles,
            List<String> accommodationTypes,
            List<String> transportationTypes,
            int minBudget,
            int maxBudget,
            int minTripDuration,
            int maxTripDuration,
            List<String> preferredDestinations,
            List<String> avoidDestinations,
            bool isFlexibleDates,
            DateTime createdAt,
            DateTime updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TravelPreference() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.travelStyles,
            _that.accommodationTypes,
            _that.transportationTypes,
            _that.minBudget,
            _that.maxBudget,
            _that.minTripDuration,
            _that.maxTripDuration,
            _that.preferredDestinations,
            _that.avoidDestinations,
            _that.isFlexibleDates,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TravelPreference implements TravelPreference {
  const _TravelPreference(
      {required this.id,
      required this.userId,
      required final List<String> travelStyles,
      required final List<String> accommodationTypes,
      required final List<String> transportationTypes,
      required this.minBudget,
      required this.maxBudget,
      required this.minTripDuration,
      required this.maxTripDuration,
      required final List<String> preferredDestinations,
      required final List<String> avoidDestinations,
      required this.isFlexibleDates,
      required this.createdAt,
      required this.updatedAt})
      : _travelStyles = travelStyles,
        _accommodationTypes = accommodationTypes,
        _transportationTypes = transportationTypes,
        _preferredDestinations = preferredDestinations,
        _avoidDestinations = avoidDestinations;
  factory _TravelPreference.fromJson(Map<String, dynamic> json) =>
      _$TravelPreferenceFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  final List<String> _travelStyles;
  @override
  List<String> get travelStyles {
    if (_travelStyles is EqualUnmodifiableListView) return _travelStyles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_travelStyles);
  }

  final List<String> _accommodationTypes;
  @override
  List<String> get accommodationTypes {
    if (_accommodationTypes is EqualUnmodifiableListView)
      return _accommodationTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_accommodationTypes);
  }

  final List<String> _transportationTypes;
  @override
  List<String> get transportationTypes {
    if (_transportationTypes is EqualUnmodifiableListView)
      return _transportationTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transportationTypes);
  }

  @override
  final int minBudget;
  @override
  final int maxBudget;
  @override
  final int minTripDuration;
  @override
  final int maxTripDuration;
  final List<String> _preferredDestinations;
  @override
  List<String> get preferredDestinations {
    if (_preferredDestinations is EqualUnmodifiableListView)
      return _preferredDestinations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredDestinations);
  }

  final List<String> _avoidDestinations;
  @override
  List<String> get avoidDestinations {
    if (_avoidDestinations is EqualUnmodifiableListView)
      return _avoidDestinations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_avoidDestinations);
  }

  @override
  final bool isFlexibleDates;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  /// Create a copy of TravelPreference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TravelPreferenceCopyWith<_TravelPreference> get copyWith =>
      __$TravelPreferenceCopyWithImpl<_TravelPreference>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TravelPreferenceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TravelPreference &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality()
                .equals(other._travelStyles, _travelStyles) &&
            const DeepCollectionEquality()
                .equals(other._accommodationTypes, _accommodationTypes) &&
            const DeepCollectionEquality()
                .equals(other._transportationTypes, _transportationTypes) &&
            (identical(other.minBudget, minBudget) ||
                other.minBudget == minBudget) &&
            (identical(other.maxBudget, maxBudget) ||
                other.maxBudget == maxBudget) &&
            (identical(other.minTripDuration, minTripDuration) ||
                other.minTripDuration == minTripDuration) &&
            (identical(other.maxTripDuration, maxTripDuration) ||
                other.maxTripDuration == maxTripDuration) &&
            const DeepCollectionEquality()
                .equals(other._preferredDestinations, _preferredDestinations) &&
            const DeepCollectionEquality()
                .equals(other._avoidDestinations, _avoidDestinations) &&
            (identical(other.isFlexibleDates, isFlexibleDates) ||
                other.isFlexibleDates == isFlexibleDates) &&
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
      userId,
      const DeepCollectionEquality().hash(_travelStyles),
      const DeepCollectionEquality().hash(_accommodationTypes),
      const DeepCollectionEquality().hash(_transportationTypes),
      minBudget,
      maxBudget,
      minTripDuration,
      maxTripDuration,
      const DeepCollectionEquality().hash(_preferredDestinations),
      const DeepCollectionEquality().hash(_avoidDestinations),
      isFlexibleDates,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'TravelPreference(id: $id, userId: $userId, travelStyles: $travelStyles, accommodationTypes: $accommodationTypes, transportationTypes: $transportationTypes, minBudget: $minBudget, maxBudget: $maxBudget, minTripDuration: $minTripDuration, maxTripDuration: $maxTripDuration, preferredDestinations: $preferredDestinations, avoidDestinations: $avoidDestinations, isFlexibleDates: $isFlexibleDates, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$TravelPreferenceCopyWith<$Res>
    implements $TravelPreferenceCopyWith<$Res> {
  factory _$TravelPreferenceCopyWith(
          _TravelPreference value, $Res Function(_TravelPreference) _then) =
      __$TravelPreferenceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      List<String> travelStyles,
      List<String> accommodationTypes,
      List<String> transportationTypes,
      int minBudget,
      int maxBudget,
      int minTripDuration,
      int maxTripDuration,
      List<String> preferredDestinations,
      List<String> avoidDestinations,
      bool isFlexibleDates,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$TravelPreferenceCopyWithImpl<$Res>
    implements _$TravelPreferenceCopyWith<$Res> {
  __$TravelPreferenceCopyWithImpl(this._self, this._then);

  final _TravelPreference _self;
  final $Res Function(_TravelPreference) _then;

  /// Create a copy of TravelPreference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? travelStyles = null,
    Object? accommodationTypes = null,
    Object? transportationTypes = null,
    Object? minBudget = null,
    Object? maxBudget = null,
    Object? minTripDuration = null,
    Object? maxTripDuration = null,
    Object? preferredDestinations = null,
    Object? avoidDestinations = null,
    Object? isFlexibleDates = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_TravelPreference(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      travelStyles: null == travelStyles
          ? _self._travelStyles
          : travelStyles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      accommodationTypes: null == accommodationTypes
          ? _self._accommodationTypes
          : accommodationTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      transportationTypes: null == transportationTypes
          ? _self._transportationTypes
          : transportationTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      minBudget: null == minBudget
          ? _self.minBudget
          : minBudget // ignore: cast_nullable_to_non_nullable
              as int,
      maxBudget: null == maxBudget
          ? _self.maxBudget
          : maxBudget // ignore: cast_nullable_to_non_nullable
              as int,
      minTripDuration: null == minTripDuration
          ? _self.minTripDuration
          : minTripDuration // ignore: cast_nullable_to_non_nullable
              as int,
      maxTripDuration: null == maxTripDuration
          ? _self.maxTripDuration
          : maxTripDuration // ignore: cast_nullable_to_non_nullable
              as int,
      preferredDestinations: null == preferredDestinations
          ? _self._preferredDestinations
          : preferredDestinations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      avoidDestinations: null == avoidDestinations
          ? _self._avoidDestinations
          : avoidDestinations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFlexibleDates: null == isFlexibleDates
          ? _self.isFlexibleDates
          : isFlexibleDates // ignore: cast_nullable_to_non_nullable
              as bool,
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
