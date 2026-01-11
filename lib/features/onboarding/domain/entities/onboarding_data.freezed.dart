// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingData {
  String get name;
  Destination get destination;
  DateRange get dateRange;
  Set<TravelInterest> get interests;
  BudgetRange? get budget;

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OnboardingDataCopyWith<OnboardingData> get copyWith =>
      _$OnboardingDataCopyWithImpl<OnboardingData>(
          this as OnboardingData, _$identity);

  /// Serializes this OnboardingData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnboardingData &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.dateRange, dateRange) ||
                other.dateRange == dateRange) &&
            const DeepCollectionEquality().equals(other.interests, interests) &&
            (identical(other.budget, budget) || other.budget == budget));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, destination, dateRange,
      const DeepCollectionEquality().hash(interests), budget);

  @override
  String toString() {
    return 'OnboardingData(name: $name, destination: $destination, dateRange: $dateRange, interests: $interests, budget: $budget)';
  }
}

/// @nodoc
abstract mixin class $OnboardingDataCopyWith<$Res> {
  factory $OnboardingDataCopyWith(
          OnboardingData value, $Res Function(OnboardingData) _then) =
      _$OnboardingDataCopyWithImpl;
  @useResult
  $Res call(
      {String name,
      Destination destination,
      DateRange dateRange,
      Set<TravelInterest> interests,
      BudgetRange? budget});

  $DestinationCopyWith<$Res> get destination;
  $DateRangeCopyWith<$Res> get dateRange;
}

/// @nodoc
class _$OnboardingDataCopyWithImpl<$Res>
    implements $OnboardingDataCopyWith<$Res> {
  _$OnboardingDataCopyWithImpl(this._self, this._then);

  final OnboardingData _self;
  final $Res Function(OnboardingData) _then;

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? destination = null,
    Object? dateRange = null,
    Object? interests = null,
    Object? budget = freezed,
  }) {
    return _then(_self.copyWith(
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
      interests: null == interests
          ? _self.interests
          : interests // ignore: cast_nullable_to_non_nullable
              as Set<TravelInterest>,
      budget: freezed == budget
          ? _self.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as BudgetRange?,
    ));
  }

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res> get destination {
    return $DestinationCopyWith<$Res>(_self.destination, (value) {
      return _then(_self.copyWith(destination: value));
    });
  }

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DateRangeCopyWith<$Res> get dateRange {
    return $DateRangeCopyWith<$Res>(_self.dateRange, (value) {
      return _then(_self.copyWith(dateRange: value));
    });
  }
}

/// Adds pattern-matching-related methods to [OnboardingData].
extension OnboardingDataPatterns on OnboardingData {
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
    TResult Function(_OnboardingData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OnboardingData() when $default != null:
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
    TResult Function(_OnboardingData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingData():
        return $default(_that);
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
    TResult? Function(_OnboardingData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingData() when $default != null:
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
    TResult Function(String name, Destination destination, DateRange dateRange,
            Set<TravelInterest> interests, BudgetRange? budget)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OnboardingData() when $default != null:
        return $default(_that.name, _that.destination, _that.dateRange,
            _that.interests, _that.budget);
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
    TResult Function(String name, Destination destination, DateRange dateRange,
            Set<TravelInterest> interests, BudgetRange? budget)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingData():
        return $default(_that.name, _that.destination, _that.dateRange,
            _that.interests, _that.budget);
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
    TResult? Function(String name, Destination destination, DateRange dateRange,
            Set<TravelInterest> interests, BudgetRange? budget)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingData() when $default != null:
        return $default(_that.name, _that.destination, _that.dateRange,
            _that.interests, _that.budget);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _OnboardingData extends OnboardingData {
  const _OnboardingData(
      {required this.name,
      required this.destination,
      required this.dateRange,
      required final Set<TravelInterest> interests,
      this.budget})
      : _interests = interests,
        super._();
  factory _OnboardingData.fromJson(Map<String, dynamic> json) =>
      _$OnboardingDataFromJson(json);

  @override
  final String name;
  @override
  final Destination destination;
  @override
  final DateRange dateRange;
  final Set<TravelInterest> _interests;
  @override
  Set<TravelInterest> get interests {
    if (_interests is EqualUnmodifiableSetView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_interests);
  }

  @override
  final BudgetRange? budget;

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OnboardingDataCopyWith<_OnboardingData> get copyWith =>
      __$OnboardingDataCopyWithImpl<_OnboardingData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OnboardingDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OnboardingData &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.dateRange, dateRange) ||
                other.dateRange == dateRange) &&
            const DeepCollectionEquality()
                .equals(other._interests, _interests) &&
            (identical(other.budget, budget) || other.budget == budget));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, destination, dateRange,
      const DeepCollectionEquality().hash(_interests), budget);

  @override
  String toString() {
    return 'OnboardingData(name: $name, destination: $destination, dateRange: $dateRange, interests: $interests, budget: $budget)';
  }
}

/// @nodoc
abstract mixin class _$OnboardingDataCopyWith<$Res>
    implements $OnboardingDataCopyWith<$Res> {
  factory _$OnboardingDataCopyWith(
          _OnboardingData value, $Res Function(_OnboardingData) _then) =
      __$OnboardingDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String name,
      Destination destination,
      DateRange dateRange,
      Set<TravelInterest> interests,
      BudgetRange? budget});

  @override
  $DestinationCopyWith<$Res> get destination;
  @override
  $DateRangeCopyWith<$Res> get dateRange;
}

/// @nodoc
class __$OnboardingDataCopyWithImpl<$Res>
    implements _$OnboardingDataCopyWith<$Res> {
  __$OnboardingDataCopyWithImpl(this._self, this._then);

  final _OnboardingData _self;
  final $Res Function(_OnboardingData) _then;

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? destination = null,
    Object? dateRange = null,
    Object? interests = null,
    Object? budget = freezed,
  }) {
    return _then(_OnboardingData(
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
      interests: null == interests
          ? _self._interests
          : interests // ignore: cast_nullable_to_non_nullable
              as Set<TravelInterest>,
      budget: freezed == budget
          ? _self.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as BudgetRange?,
    ));
  }

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res> get destination {
    return $DestinationCopyWith<$Res>(_self.destination, (value) {
      return _then(_self.copyWith(destination: value));
    });
  }

  /// Create a copy of OnboardingData
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
