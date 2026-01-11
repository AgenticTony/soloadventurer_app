// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'destination.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SoloSuitabilityFactors {
  /// Safety score for solo travelers (1-10)
  double get safety;

  /// Nightlife and social scene score (1-10)
  double get nightlife;

  /// Walkability and public transport (1-10)
  double get walkability;

  /// Hostel and accommodation options (1-10)
  double get accommodation;

  /// Solo dining and activities (1-10)
  double get soloDining;

  /// English proficiency and communication (1-10)
  double get communication;

  /// Overall solo suitability score (1-10)
  double get overall;

  /// Create a copy of SoloSuitabilityFactors
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SoloSuitabilityFactorsCopyWith<SoloSuitabilityFactors> get copyWith =>
      _$SoloSuitabilityFactorsCopyWithImpl<SoloSuitabilityFactors>(
          this as SoloSuitabilityFactors, _$identity);

  /// Serializes this SoloSuitabilityFactors to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SoloSuitabilityFactors &&
            (identical(other.safety, safety) || other.safety == safety) &&
            (identical(other.nightlife, nightlife) ||
                other.nightlife == nightlife) &&
            (identical(other.walkability, walkability) ||
                other.walkability == walkability) &&
            (identical(other.accommodation, accommodation) ||
                other.accommodation == accommodation) &&
            (identical(other.soloDining, soloDining) ||
                other.soloDining == soloDining) &&
            (identical(other.communication, communication) ||
                other.communication == communication) &&
            (identical(other.overall, overall) || other.overall == overall));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, safety, nightlife, walkability,
      accommodation, soloDining, communication, overall);

  @override
  String toString() {
    return 'SoloSuitabilityFactors(safety: $safety, nightlife: $nightlife, walkability: $walkability, accommodation: $accommodation, soloDining: $soloDining, communication: $communication, overall: $overall)';
  }
}

/// @nodoc
abstract mixin class $SoloSuitabilityFactorsCopyWith<$Res> {
  factory $SoloSuitabilityFactorsCopyWith(SoloSuitabilityFactors value,
          $Res Function(SoloSuitabilityFactors) _then) =
      _$SoloSuitabilityFactorsCopyWithImpl;
  @useResult
  $Res call(
      {double safety,
      double nightlife,
      double walkability,
      double accommodation,
      double soloDining,
      double communication,
      double overall});
}

/// @nodoc
class _$SoloSuitabilityFactorsCopyWithImpl<$Res>
    implements $SoloSuitabilityFactorsCopyWith<$Res> {
  _$SoloSuitabilityFactorsCopyWithImpl(this._self, this._then);

  final SoloSuitabilityFactors _self;
  final $Res Function(SoloSuitabilityFactors) _then;

  /// Create a copy of SoloSuitabilityFactors
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? safety = null,
    Object? nightlife = null,
    Object? walkability = null,
    Object? accommodation = null,
    Object? soloDining = null,
    Object? communication = null,
    Object? overall = null,
  }) {
    return _then(_self.copyWith(
      safety: null == safety
          ? _self.safety
          : safety // ignore: cast_nullable_to_non_nullable
              as double,
      nightlife: null == nightlife
          ? _self.nightlife
          : nightlife // ignore: cast_nullable_to_non_nullable
              as double,
      walkability: null == walkability
          ? _self.walkability
          : walkability // ignore: cast_nullable_to_non_nullable
              as double,
      accommodation: null == accommodation
          ? _self.accommodation
          : accommodation // ignore: cast_nullable_to_non_nullable
              as double,
      soloDining: null == soloDining
          ? _self.soloDining
          : soloDining // ignore: cast_nullable_to_non_nullable
              as double,
      communication: null == communication
          ? _self.communication
          : communication // ignore: cast_nullable_to_non_nullable
              as double,
      overall: null == overall
          ? _self.overall
          : overall // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [SoloSuitabilityFactors].
extension SoloSuitabilityFactorsPatterns on SoloSuitabilityFactors {
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
    TResult Function(_SoloSuitabilityFactors value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SoloSuitabilityFactors() when $default != null:
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
    TResult Function(_SoloSuitabilityFactors value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SoloSuitabilityFactors():
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
    TResult? Function(_SoloSuitabilityFactors value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SoloSuitabilityFactors() when $default != null:
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
            double safety,
            double nightlife,
            double walkability,
            double accommodation,
            double soloDining,
            double communication,
            double overall)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SoloSuitabilityFactors() when $default != null:
        return $default(
            _that.safety,
            _that.nightlife,
            _that.walkability,
            _that.accommodation,
            _that.soloDining,
            _that.communication,
            _that.overall);
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
            double safety,
            double nightlife,
            double walkability,
            double accommodation,
            double soloDining,
            double communication,
            double overall)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SoloSuitabilityFactors():
        return $default(
            _that.safety,
            _that.nightlife,
            _that.walkability,
            _that.accommodation,
            _that.soloDining,
            _that.communication,
            _that.overall);
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
            double safety,
            double nightlife,
            double walkability,
            double accommodation,
            double soloDining,
            double communication,
            double overall)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SoloSuitabilityFactors() when $default != null:
        return $default(
            _that.safety,
            _that.nightlife,
            _that.walkability,
            _that.accommodation,
            _that.soloDining,
            _that.communication,
            _that.overall);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SoloSuitabilityFactors implements SoloSuitabilityFactors {
  const _SoloSuitabilityFactors(
      {required this.safety,
      required this.nightlife,
      required this.walkability,
      required this.accommodation,
      required this.soloDining,
      required this.communication,
      required this.overall});
  factory _SoloSuitabilityFactors.fromJson(Map<String, dynamic> json) =>
      _$SoloSuitabilityFactorsFromJson(json);

  /// Safety score for solo travelers (1-10)
  @override
  final double safety;

  /// Nightlife and social scene score (1-10)
  @override
  final double nightlife;

  /// Walkability and public transport (1-10)
  @override
  final double walkability;

  /// Hostel and accommodation options (1-10)
  @override
  final double accommodation;

  /// Solo dining and activities (1-10)
  @override
  final double soloDining;

  /// English proficiency and communication (1-10)
  @override
  final double communication;

  /// Overall solo suitability score (1-10)
  @override
  final double overall;

  /// Create a copy of SoloSuitabilityFactors
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SoloSuitabilityFactorsCopyWith<_SoloSuitabilityFactors> get copyWith =>
      __$SoloSuitabilityFactorsCopyWithImpl<_SoloSuitabilityFactors>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SoloSuitabilityFactorsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SoloSuitabilityFactors &&
            (identical(other.safety, safety) || other.safety == safety) &&
            (identical(other.nightlife, nightlife) ||
                other.nightlife == nightlife) &&
            (identical(other.walkability, walkability) ||
                other.walkability == walkability) &&
            (identical(other.accommodation, accommodation) ||
                other.accommodation == accommodation) &&
            (identical(other.soloDining, soloDining) ||
                other.soloDining == soloDining) &&
            (identical(other.communication, communication) ||
                other.communication == communication) &&
            (identical(other.overall, overall) || other.overall == overall));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, safety, nightlife, walkability,
      accommodation, soloDining, communication, overall);

  @override
  String toString() {
    return 'SoloSuitabilityFactors(safety: $safety, nightlife: $nightlife, walkability: $walkability, accommodation: $accommodation, soloDining: $soloDining, communication: $communication, overall: $overall)';
  }
}

/// @nodoc
abstract mixin class _$SoloSuitabilityFactorsCopyWith<$Res>
    implements $SoloSuitabilityFactorsCopyWith<$Res> {
  factory _$SoloSuitabilityFactorsCopyWith(_SoloSuitabilityFactors value,
          $Res Function(_SoloSuitabilityFactors) _then) =
      __$SoloSuitabilityFactorsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double safety,
      double nightlife,
      double walkability,
      double accommodation,
      double soloDining,
      double communication,
      double overall});
}

/// @nodoc
class __$SoloSuitabilityFactorsCopyWithImpl<$Res>
    implements _$SoloSuitabilityFactorsCopyWith<$Res> {
  __$SoloSuitabilityFactorsCopyWithImpl(this._self, this._then);

  final _SoloSuitabilityFactors _self;
  final $Res Function(_SoloSuitabilityFactors) _then;

  /// Create a copy of SoloSuitabilityFactors
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? safety = null,
    Object? nightlife = null,
    Object? walkability = null,
    Object? accommodation = null,
    Object? soloDining = null,
    Object? communication = null,
    Object? overall = null,
  }) {
    return _then(_SoloSuitabilityFactors(
      safety: null == safety
          ? _self.safety
          : safety // ignore: cast_nullable_to_non_nullable
              as double,
      nightlife: null == nightlife
          ? _self.nightlife
          : nightlife // ignore: cast_nullable_to_non_nullable
              as double,
      walkability: null == walkability
          ? _self.walkability
          : walkability // ignore: cast_nullable_to_non_nullable
              as double,
      accommodation: null == accommodation
          ? _self.accommodation
          : accommodation // ignore: cast_nullable_to_non_nullable
              as double,
      soloDining: null == soloDining
          ? _self.soloDining
          : soloDining // ignore: cast_nullable_to_non_nullable
              as double,
      communication: null == communication
          ? _self.communication
          : communication // ignore: cast_nullable_to_non_nullable
              as double,
      overall: null == overall
          ? _self.overall
          : overall // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$SafetyInsight {
  /// Category of the safety insight (e.g., "theft", "transportation", "nightlife")
  String get category;

  /// Detailed description of the safety insight
  String get description;

  /// Severity level (low, medium, high)
  String get severity;

  /// Tips for staying safe in this category
  List<String> get tips;

  /// Create a copy of SafetyInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SafetyInsightCopyWith<SafetyInsight> get copyWith =>
      _$SafetyInsightCopyWithImpl<SafetyInsight>(
          this as SafetyInsight, _$identity);

  /// Serializes this SafetyInsight to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SafetyInsight &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            const DeepCollectionEquality().equals(other.tips, tips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, category, description, severity,
      const DeepCollectionEquality().hash(tips));

  @override
  String toString() {
    return 'SafetyInsight(category: $category, description: $description, severity: $severity, tips: $tips)';
  }
}

/// @nodoc
abstract mixin class $SafetyInsightCopyWith<$Res> {
  factory $SafetyInsightCopyWith(
          SafetyInsight value, $Res Function(SafetyInsight) _then) =
      _$SafetyInsightCopyWithImpl;
  @useResult
  $Res call(
      {String category,
      String description,
      String severity,
      List<String> tips});
}

/// @nodoc
class _$SafetyInsightCopyWithImpl<$Res>
    implements $SafetyInsightCopyWith<$Res> {
  _$SafetyInsightCopyWithImpl(this._self, this._then);

  final SafetyInsight _self;
  final $Res Function(SafetyInsight) _then;

  /// Create a copy of SafetyInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? description = null,
    Object? severity = null,
    Object? tips = null,
  }) {
    return _then(_self.copyWith(
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _self.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      tips: null == tips
          ? _self.tips
          : tips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [SafetyInsight].
extension SafetyInsightPatterns on SafetyInsight {
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
    TResult Function(_SafetyInsight value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyInsight() when $default != null:
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
    TResult Function(_SafetyInsight value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyInsight():
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
    TResult? Function(_SafetyInsight value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyInsight() when $default != null:
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
    TResult Function(String category, String description, String severity,
            List<String> tips)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyInsight() when $default != null:
        return $default(
            _that.category, _that.description, _that.severity, _that.tips);
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
    TResult Function(String category, String description, String severity,
            List<String> tips)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyInsight():
        return $default(
            _that.category, _that.description, _that.severity, _that.tips);
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
    TResult? Function(String category, String description, String severity,
            List<String> tips)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyInsight() when $default != null:
        return $default(
            _that.category, _that.description, _that.severity, _that.tips);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SafetyInsight implements SafetyInsight {
  const _SafetyInsight(
      {required this.category,
      required this.description,
      required this.severity,
      required final List<String> tips})
      : _tips = tips;
  factory _SafetyInsight.fromJson(Map<String, dynamic> json) =>
      _$SafetyInsightFromJson(json);

  /// Category of the safety insight (e.g., "theft", "transportation", "nightlife")
  @override
  final String category;

  /// Detailed description of the safety insight
  @override
  final String description;

  /// Severity level (low, medium, high)
  @override
  final String severity;

  /// Tips for staying safe in this category
  final List<String> _tips;

  /// Tips for staying safe in this category
  @override
  List<String> get tips {
    if (_tips is EqualUnmodifiableListView) return _tips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tips);
  }

  /// Create a copy of SafetyInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SafetyInsightCopyWith<_SafetyInsight> get copyWith =>
      __$SafetyInsightCopyWithImpl<_SafetyInsight>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SafetyInsightToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SafetyInsight &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            const DeepCollectionEquality().equals(other._tips, _tips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, category, description, severity,
      const DeepCollectionEquality().hash(_tips));

  @override
  String toString() {
    return 'SafetyInsight(category: $category, description: $description, severity: $severity, tips: $tips)';
  }
}

/// @nodoc
abstract mixin class _$SafetyInsightCopyWith<$Res>
    implements $SafetyInsightCopyWith<$Res> {
  factory _$SafetyInsightCopyWith(
          _SafetyInsight value, $Res Function(_SafetyInsight) _then) =
      __$SafetyInsightCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String category,
      String description,
      String severity,
      List<String> tips});
}

/// @nodoc
class __$SafetyInsightCopyWithImpl<$Res>
    implements _$SafetyInsightCopyWith<$Res> {
  __$SafetyInsightCopyWithImpl(this._self, this._then);

  final _SafetyInsight _self;
  final $Res Function(_SafetyInsight) _then;

  /// Create a copy of SafetyInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? category = null,
    Object? description = null,
    Object? severity = null,
    Object? tips = null,
  }) {
    return _then(_SafetyInsight(
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _self.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      tips: null == tips
          ? _self._tips
          : tips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
mixin _$Activity {
  /// Activity ID
  String get id;

  /// Activity name
  String get name;

  /// Activity description
  String? get description;

  /// Category of activity (e.g., "outdoor", "cultural", "food")
  String get category;

  /// Whether activity is suitable for solo travelers
  bool get soloFriendly;

  /// Estimated cost level
  String? get costLevel;

  /// Image URL for the activity
  String? get imageUrl;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ActivityCopyWith<Activity> get copyWith =>
      _$ActivityCopyWithImpl<Activity>(this as Activity, _$identity);

  /// Serializes this Activity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Activity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.soloFriendly, soloFriendly) ||
                other.soloFriendly == soloFriendly) &&
            (identical(other.costLevel, costLevel) ||
                other.costLevel == costLevel) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, category,
      soloFriendly, costLevel, imageUrl);

  @override
  String toString() {
    return 'Activity(id: $id, name: $name, description: $description, category: $category, soloFriendly: $soloFriendly, costLevel: $costLevel, imageUrl: $imageUrl)';
  }
}

/// @nodoc
abstract mixin class $ActivityCopyWith<$Res> {
  factory $ActivityCopyWith(Activity value, $Res Function(Activity) _then) =
      _$ActivityCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String category,
      bool soloFriendly,
      String? costLevel,
      String? imageUrl});
}

/// @nodoc
class _$ActivityCopyWithImpl<$Res> implements $ActivityCopyWith<$Res> {
  _$ActivityCopyWithImpl(this._self, this._then);

  final Activity _self;
  final $Res Function(Activity) _then;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? category = null,
    Object? soloFriendly = null,
    Object? costLevel = freezed,
    Object? imageUrl = freezed,
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
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      soloFriendly: null == soloFriendly
          ? _self.soloFriendly
          : soloFriendly // ignore: cast_nullable_to_non_nullable
              as bool,
      costLevel: freezed == costLevel
          ? _self.costLevel
          : costLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Activity].
extension ActivityPatterns on Activity {
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
    TResult Function(_Activity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Activity() when $default != null:
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
    TResult Function(_Activity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Activity():
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
    TResult? Function(_Activity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Activity() when $default != null:
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
            String? description,
            String category,
            bool soloFriendly,
            String? costLevel,
            String? imageUrl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Activity() when $default != null:
        return $default(_that.id, _that.name, _that.description, _that.category,
            _that.soloFriendly, _that.costLevel, _that.imageUrl);
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
            String? description,
            String category,
            bool soloFriendly,
            String? costLevel,
            String? imageUrl)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Activity():
        return $default(_that.id, _that.name, _that.description, _that.category,
            _that.soloFriendly, _that.costLevel, _that.imageUrl);
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
            String? description,
            String category,
            bool soloFriendly,
            String? costLevel,
            String? imageUrl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Activity() when $default != null:
        return $default(_that.id, _that.name, _that.description, _that.category,
            _that.soloFriendly, _that.costLevel, _that.imageUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Activity implements Activity {
  const _Activity(
      {required this.id,
      required this.name,
      this.description,
      required this.category,
      required this.soloFriendly,
      this.costLevel,
      this.imageUrl});
  factory _Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  /// Activity ID
  @override
  final String id;

  /// Activity name
  @override
  final String name;

  /// Activity description
  @override
  final String? description;

  /// Category of activity (e.g., "outdoor", "cultural", "food")
  @override
  final String category;

  /// Whether activity is suitable for solo travelers
  @override
  final bool soloFriendly;

  /// Estimated cost level
  @override
  final String? costLevel;

  /// Image URL for the activity
  @override
  final String? imageUrl;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ActivityCopyWith<_Activity> get copyWith =>
      __$ActivityCopyWithImpl<_Activity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ActivityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Activity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.soloFriendly, soloFriendly) ||
                other.soloFriendly == soloFriendly) &&
            (identical(other.costLevel, costLevel) ||
                other.costLevel == costLevel) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, category,
      soloFriendly, costLevel, imageUrl);

  @override
  String toString() {
    return 'Activity(id: $id, name: $name, description: $description, category: $category, soloFriendly: $soloFriendly, costLevel: $costLevel, imageUrl: $imageUrl)';
  }
}

/// @nodoc
abstract mixin class _$ActivityCopyWith<$Res>
    implements $ActivityCopyWith<$Res> {
  factory _$ActivityCopyWith(_Activity value, $Res Function(_Activity) _then) =
      __$ActivityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String category,
      bool soloFriendly,
      String? costLevel,
      String? imageUrl});
}

/// @nodoc
class __$ActivityCopyWithImpl<$Res> implements _$ActivityCopyWith<$Res> {
  __$ActivityCopyWithImpl(this._self, this._then);

  final _Activity _self;
  final $Res Function(_Activity) _then;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? category = null,
    Object? soloFriendly = null,
    Object? costLevel = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_Activity(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      soloFriendly: null == soloFriendly
          ? _self.soloFriendly
          : soloFriendly // ignore: cast_nullable_to_non_nullable
              as bool,
      costLevel: freezed == costLevel
          ? _self.costLevel
          : costLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$Destination {
  /// Unique identifier
  String get id;

  /// Destination name
  String get name;

  /// Detailed description
  String get description;

  /// Location latitude
  double get latitude;

  /// Location longitude
  double get longitude;

  /// Country code (e.g., "JP", "US")
  String get countryCode;

  /// Region/state/province
  String? get region;

  /// Overall safety score (1-10)
  double get safetyScore;

  /// Detailed safety insights
  List<SafetyInsight> get safetyInsights;

  /// Solo suitability score (1-10)
  double get soloSuitabilityScore;

  /// Individual solo suitability factors
  SoloSuitabilityFactors get soloSuitabilityFactors;

  /// Budget level
  BudgetLevel get budgetLevel;

  /// Activity level options available
  List<ActivityLevel> get activityLevels;

  /// Tags/categories (e.g., ["beach", "mountain", "urban"])
  List<String> get tags;

  /// Image URLs for the destination
  List<String> get images;

  /// Cover/featured image
  String? get coverImageUrl;

  /// Popular activities at the destination
  List<Activity> get popularActivities;

  /// Best time to visit (e.g., "March to May", "Year-round")
  String? get bestTimeToVisit;

  /// Average daily cost estimate (in USD)
  int? get averageDailyCost;

  /// Currency code
  String? get currencyCode;

  /// Language spoken
  String? get language;

  /// Timezone
  String? get timezone;

  /// Whether this is a curated "hidden gem"
  bool get isHiddenGem;

  /// Popularity score (0-1)
  double get popularityScore;

  /// Created timestamp
  DateTime get createdAt;

  /// Updated timestamp
  DateTime get updatedAt;

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<Destination> get copyWith =>
      _$DestinationCopyWithImpl<Destination>(this as Destination, _$identity);

  /// Serializes this Destination to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Destination &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.safetyScore, safetyScore) ||
                other.safetyScore == safetyScore) &&
            const DeepCollectionEquality()
                .equals(other.safetyInsights, safetyInsights) &&
            (identical(other.soloSuitabilityScore, soloSuitabilityScore) ||
                other.soloSuitabilityScore == soloSuitabilityScore) &&
            (identical(other.soloSuitabilityFactors, soloSuitabilityFactors) ||
                other.soloSuitabilityFactors == soloSuitabilityFactors) &&
            (identical(other.budgetLevel, budgetLevel) ||
                other.budgetLevel == budgetLevel) &&
            const DeepCollectionEquality()
                .equals(other.activityLevels, activityLevels) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality().equals(other.images, images) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            const DeepCollectionEquality()
                .equals(other.popularActivities, popularActivities) &&
            (identical(other.bestTimeToVisit, bestTimeToVisit) ||
                other.bestTimeToVisit == bestTimeToVisit) &&
            (identical(other.averageDailyCost, averageDailyCost) ||
                other.averageDailyCost == averageDailyCost) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.isHiddenGem, isHiddenGem) ||
                other.isHiddenGem == isHiddenGem) &&
            (identical(other.popularityScore, popularityScore) ||
                other.popularityScore == popularityScore) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        latitude,
        longitude,
        countryCode,
        region,
        safetyScore,
        const DeepCollectionEquality().hash(safetyInsights),
        soloSuitabilityScore,
        soloSuitabilityFactors,
        budgetLevel,
        const DeepCollectionEquality().hash(activityLevels),
        const DeepCollectionEquality().hash(tags),
        const DeepCollectionEquality().hash(images),
        coverImageUrl,
        const DeepCollectionEquality().hash(popularActivities),
        bestTimeToVisit,
        averageDailyCost,
        currencyCode,
        language,
        timezone,
        isHiddenGem,
        popularityScore,
        createdAt,
        updatedAt
      ]);

  @override
  String toString() {
    return 'Destination(id: $id, name: $name, description: $description, latitude: $latitude, longitude: $longitude, countryCode: $countryCode, region: $region, safetyScore: $safetyScore, safetyInsights: $safetyInsights, soloSuitabilityScore: $soloSuitabilityScore, soloSuitabilityFactors: $soloSuitabilityFactors, budgetLevel: $budgetLevel, activityLevels: $activityLevels, tags: $tags, images: $images, coverImageUrl: $coverImageUrl, popularActivities: $popularActivities, bestTimeToVisit: $bestTimeToVisit, averageDailyCost: $averageDailyCost, currencyCode: $currencyCode, language: $language, timezone: $timezone, isHiddenGem: $isHiddenGem, popularityScore: $popularityScore, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $DestinationCopyWith<$Res> {
  factory $DestinationCopyWith(
          Destination value, $Res Function(Destination) _then) =
      _$DestinationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      double latitude,
      double longitude,
      String countryCode,
      String? region,
      double safetyScore,
      List<SafetyInsight> safetyInsights,
      double soloSuitabilityScore,
      SoloSuitabilityFactors soloSuitabilityFactors,
      BudgetLevel budgetLevel,
      List<ActivityLevel> activityLevels,
      List<String> tags,
      List<String> images,
      String? coverImageUrl,
      List<Activity> popularActivities,
      String? bestTimeToVisit,
      int? averageDailyCost,
      String? currencyCode,
      String? language,
      String? timezone,
      bool isHiddenGem,
      double popularityScore,
      DateTime createdAt,
      DateTime updatedAt});

  $SoloSuitabilityFactorsCopyWith<$Res> get soloSuitabilityFactors;
}

/// @nodoc
class _$DestinationCopyWithImpl<$Res> implements $DestinationCopyWith<$Res> {
  _$DestinationCopyWithImpl(this._self, this._then);

  final Destination _self;
  final $Res Function(Destination) _then;

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? countryCode = null,
    Object? region = freezed,
    Object? safetyScore = null,
    Object? safetyInsights = null,
    Object? soloSuitabilityScore = null,
    Object? soloSuitabilityFactors = null,
    Object? budgetLevel = null,
    Object? activityLevels = null,
    Object? tags = null,
    Object? images = null,
    Object? coverImageUrl = freezed,
    Object? popularActivities = null,
    Object? bestTimeToVisit = freezed,
    Object? averageDailyCost = freezed,
    Object? currencyCode = freezed,
    Object? language = freezed,
    Object? timezone = freezed,
    Object? isHiddenGem = null,
    Object? popularityScore = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      countryCode: null == countryCode
          ? _self.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String,
      region: freezed == region
          ? _self.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      safetyScore: null == safetyScore
          ? _self.safetyScore
          : safetyScore // ignore: cast_nullable_to_non_nullable
              as double,
      safetyInsights: null == safetyInsights
          ? _self.safetyInsights
          : safetyInsights // ignore: cast_nullable_to_non_nullable
              as List<SafetyInsight>,
      soloSuitabilityScore: null == soloSuitabilityScore
          ? _self.soloSuitabilityScore
          : soloSuitabilityScore // ignore: cast_nullable_to_non_nullable
              as double,
      soloSuitabilityFactors: null == soloSuitabilityFactors
          ? _self.soloSuitabilityFactors
          : soloSuitabilityFactors // ignore: cast_nullable_to_non_nullable
              as SoloSuitabilityFactors,
      budgetLevel: null == budgetLevel
          ? _self.budgetLevel
          : budgetLevel // ignore: cast_nullable_to_non_nullable
              as BudgetLevel,
      activityLevels: null == activityLevels
          ? _self.activityLevels
          : activityLevels // ignore: cast_nullable_to_non_nullable
              as List<ActivityLevel>,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      images: null == images
          ? _self.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      coverImageUrl: freezed == coverImageUrl
          ? _self.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      popularActivities: null == popularActivities
          ? _self.popularActivities
          : popularActivities // ignore: cast_nullable_to_non_nullable
              as List<Activity>,
      bestTimeToVisit: freezed == bestTimeToVisit
          ? _self.bestTimeToVisit
          : bestTimeToVisit // ignore: cast_nullable_to_non_nullable
              as String?,
      averageDailyCost: freezed == averageDailyCost
          ? _self.averageDailyCost
          : averageDailyCost // ignore: cast_nullable_to_non_nullable
              as int?,
      currencyCode: freezed == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      timezone: freezed == timezone
          ? _self.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
      isHiddenGem: null == isHiddenGem
          ? _self.isHiddenGem
          : isHiddenGem // ignore: cast_nullable_to_non_nullable
              as bool,
      popularityScore: null == popularityScore
          ? _self.popularityScore
          : popularityScore // ignore: cast_nullable_to_non_nullable
              as double,
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

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SoloSuitabilityFactorsCopyWith<$Res> get soloSuitabilityFactors {
    return $SoloSuitabilityFactorsCopyWith<$Res>(_self.soloSuitabilityFactors,
        (value) {
      return _then(_self.copyWith(soloSuitabilityFactors: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Destination].
extension DestinationPatterns on Destination {
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
    TResult Function(_Destination value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Destination() when $default != null:
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
    TResult Function(_Destination value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Destination():
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
    TResult? Function(_Destination value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Destination() when $default != null:
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
            double latitude,
            double longitude,
            String countryCode,
            String? region,
            double safetyScore,
            List<SafetyInsight> safetyInsights,
            double soloSuitabilityScore,
            SoloSuitabilityFactors soloSuitabilityFactors,
            BudgetLevel budgetLevel,
            List<ActivityLevel> activityLevels,
            List<String> tags,
            List<String> images,
            String? coverImageUrl,
            List<Activity> popularActivities,
            String? bestTimeToVisit,
            int? averageDailyCost,
            String? currencyCode,
            String? language,
            String? timezone,
            bool isHiddenGem,
            double popularityScore,
            DateTime createdAt,
            DateTime updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Destination() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.latitude,
            _that.longitude,
            _that.countryCode,
            _that.region,
            _that.safetyScore,
            _that.safetyInsights,
            _that.soloSuitabilityScore,
            _that.soloSuitabilityFactors,
            _that.budgetLevel,
            _that.activityLevels,
            _that.tags,
            _that.images,
            _that.coverImageUrl,
            _that.popularActivities,
            _that.bestTimeToVisit,
            _that.averageDailyCost,
            _that.currencyCode,
            _that.language,
            _that.timezone,
            _that.isHiddenGem,
            _that.popularityScore,
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
            String name,
            String description,
            double latitude,
            double longitude,
            String countryCode,
            String? region,
            double safetyScore,
            List<SafetyInsight> safetyInsights,
            double soloSuitabilityScore,
            SoloSuitabilityFactors soloSuitabilityFactors,
            BudgetLevel budgetLevel,
            List<ActivityLevel> activityLevels,
            List<String> tags,
            List<String> images,
            String? coverImageUrl,
            List<Activity> popularActivities,
            String? bestTimeToVisit,
            int? averageDailyCost,
            String? currencyCode,
            String? language,
            String? timezone,
            bool isHiddenGem,
            double popularityScore,
            DateTime createdAt,
            DateTime updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Destination():
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.latitude,
            _that.longitude,
            _that.countryCode,
            _that.region,
            _that.safetyScore,
            _that.safetyInsights,
            _that.soloSuitabilityScore,
            _that.soloSuitabilityFactors,
            _that.budgetLevel,
            _that.activityLevels,
            _that.tags,
            _that.images,
            _that.coverImageUrl,
            _that.popularActivities,
            _that.bestTimeToVisit,
            _that.averageDailyCost,
            _that.currencyCode,
            _that.language,
            _that.timezone,
            _that.isHiddenGem,
            _that.popularityScore,
            _that.createdAt,
            _that.updatedAt);
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
            double latitude,
            double longitude,
            String countryCode,
            String? region,
            double safetyScore,
            List<SafetyInsight> safetyInsights,
            double soloSuitabilityScore,
            SoloSuitabilityFactors soloSuitabilityFactors,
            BudgetLevel budgetLevel,
            List<ActivityLevel> activityLevels,
            List<String> tags,
            List<String> images,
            String? coverImageUrl,
            List<Activity> popularActivities,
            String? bestTimeToVisit,
            int? averageDailyCost,
            String? currencyCode,
            String? language,
            String? timezone,
            bool isHiddenGem,
            double popularityScore,
            DateTime createdAt,
            DateTime updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Destination() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.latitude,
            _that.longitude,
            _that.countryCode,
            _that.region,
            _that.safetyScore,
            _that.safetyInsights,
            _that.soloSuitabilityScore,
            _that.soloSuitabilityFactors,
            _that.budgetLevel,
            _that.activityLevels,
            _that.tags,
            _that.images,
            _that.coverImageUrl,
            _that.popularActivities,
            _that.bestTimeToVisit,
            _that.averageDailyCost,
            _that.currencyCode,
            _that.language,
            _that.timezone,
            _that.isHiddenGem,
            _that.popularityScore,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Destination implements Destination {
  const _Destination(
      {required this.id,
      required this.name,
      required this.description,
      required this.latitude,
      required this.longitude,
      required this.countryCode,
      this.region,
      required this.safetyScore,
      required final List<SafetyInsight> safetyInsights,
      required this.soloSuitabilityScore,
      required this.soloSuitabilityFactors,
      required this.budgetLevel,
      required final List<ActivityLevel> activityLevels,
      required final List<String> tags,
      required final List<String> images,
      this.coverImageUrl,
      required final List<Activity> popularActivities,
      this.bestTimeToVisit,
      this.averageDailyCost,
      this.currencyCode,
      this.language,
      this.timezone,
      this.isHiddenGem = false,
      this.popularityScore = 0.5,
      required this.createdAt,
      required this.updatedAt})
      : _safetyInsights = safetyInsights,
        _activityLevels = activityLevels,
        _tags = tags,
        _images = images,
        _popularActivities = popularActivities;
  factory _Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);

  /// Unique identifier
  @override
  final String id;

  /// Destination name
  @override
  final String name;

  /// Detailed description
  @override
  final String description;

  /// Location latitude
  @override
  final double latitude;

  /// Location longitude
  @override
  final double longitude;

  /// Country code (e.g., "JP", "US")
  @override
  final String countryCode;

  /// Region/state/province
  @override
  final String? region;

  /// Overall safety score (1-10)
  @override
  final double safetyScore;

  /// Detailed safety insights
  final List<SafetyInsight> _safetyInsights;

  /// Detailed safety insights
  @override
  List<SafetyInsight> get safetyInsights {
    if (_safetyInsights is EqualUnmodifiableListView) return _safetyInsights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_safetyInsights);
  }

  /// Solo suitability score (1-10)
  @override
  final double soloSuitabilityScore;

  /// Individual solo suitability factors
  @override
  final SoloSuitabilityFactors soloSuitabilityFactors;

  /// Budget level
  @override
  final BudgetLevel budgetLevel;

  /// Activity level options available
  final List<ActivityLevel> _activityLevels;

  /// Activity level options available
  @override
  List<ActivityLevel> get activityLevels {
    if (_activityLevels is EqualUnmodifiableListView) return _activityLevels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activityLevels);
  }

  /// Tags/categories (e.g., ["beach", "mountain", "urban"])
  final List<String> _tags;

  /// Tags/categories (e.g., ["beach", "mountain", "urban"])
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Image URLs for the destination
  final List<String> _images;

  /// Image URLs for the destination
  @override
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  /// Cover/featured image
  @override
  final String? coverImageUrl;

  /// Popular activities at the destination
  final List<Activity> _popularActivities;

  /// Popular activities at the destination
  @override
  List<Activity> get popularActivities {
    if (_popularActivities is EqualUnmodifiableListView)
      return _popularActivities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_popularActivities);
  }

  /// Best time to visit (e.g., "March to May", "Year-round")
  @override
  final String? bestTimeToVisit;

  /// Average daily cost estimate (in USD)
  @override
  final int? averageDailyCost;

  /// Currency code
  @override
  final String? currencyCode;

  /// Language spoken
  @override
  final String? language;

  /// Timezone
  @override
  final String? timezone;

  /// Whether this is a curated "hidden gem"
  @override
  @JsonKey()
  final bool isHiddenGem;

  /// Popularity score (0-1)
  @override
  @JsonKey()
  final double popularityScore;

  /// Created timestamp
  @override
  final DateTime createdAt;

  /// Updated timestamp
  @override
  final DateTime updatedAt;

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DestinationCopyWith<_Destination> get copyWith =>
      __$DestinationCopyWithImpl<_Destination>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DestinationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Destination &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.safetyScore, safetyScore) ||
                other.safetyScore == safetyScore) &&
            const DeepCollectionEquality()
                .equals(other._safetyInsights, _safetyInsights) &&
            (identical(other.soloSuitabilityScore, soloSuitabilityScore) ||
                other.soloSuitabilityScore == soloSuitabilityScore) &&
            (identical(other.soloSuitabilityFactors, soloSuitabilityFactors) ||
                other.soloSuitabilityFactors == soloSuitabilityFactors) &&
            (identical(other.budgetLevel, budgetLevel) ||
                other.budgetLevel == budgetLevel) &&
            const DeepCollectionEquality()
                .equals(other._activityLevels, _activityLevels) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            const DeepCollectionEquality()
                .equals(other._popularActivities, _popularActivities) &&
            (identical(other.bestTimeToVisit, bestTimeToVisit) ||
                other.bestTimeToVisit == bestTimeToVisit) &&
            (identical(other.averageDailyCost, averageDailyCost) ||
                other.averageDailyCost == averageDailyCost) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.isHiddenGem, isHiddenGem) ||
                other.isHiddenGem == isHiddenGem) &&
            (identical(other.popularityScore, popularityScore) ||
                other.popularityScore == popularityScore) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        latitude,
        longitude,
        countryCode,
        region,
        safetyScore,
        const DeepCollectionEquality().hash(_safetyInsights),
        soloSuitabilityScore,
        soloSuitabilityFactors,
        budgetLevel,
        const DeepCollectionEquality().hash(_activityLevels),
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_images),
        coverImageUrl,
        const DeepCollectionEquality().hash(_popularActivities),
        bestTimeToVisit,
        averageDailyCost,
        currencyCode,
        language,
        timezone,
        isHiddenGem,
        popularityScore,
        createdAt,
        updatedAt
      ]);

  @override
  String toString() {
    return 'Destination(id: $id, name: $name, description: $description, latitude: $latitude, longitude: $longitude, countryCode: $countryCode, region: $region, safetyScore: $safetyScore, safetyInsights: $safetyInsights, soloSuitabilityScore: $soloSuitabilityScore, soloSuitabilityFactors: $soloSuitabilityFactors, budgetLevel: $budgetLevel, activityLevels: $activityLevels, tags: $tags, images: $images, coverImageUrl: $coverImageUrl, popularActivities: $popularActivities, bestTimeToVisit: $bestTimeToVisit, averageDailyCost: $averageDailyCost, currencyCode: $currencyCode, language: $language, timezone: $timezone, isHiddenGem: $isHiddenGem, popularityScore: $popularityScore, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$DestinationCopyWith<$Res>
    implements $DestinationCopyWith<$Res> {
  factory _$DestinationCopyWith(
          _Destination value, $Res Function(_Destination) _then) =
      __$DestinationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      double latitude,
      double longitude,
      String countryCode,
      String? region,
      double safetyScore,
      List<SafetyInsight> safetyInsights,
      double soloSuitabilityScore,
      SoloSuitabilityFactors soloSuitabilityFactors,
      BudgetLevel budgetLevel,
      List<ActivityLevel> activityLevels,
      List<String> tags,
      List<String> images,
      String? coverImageUrl,
      List<Activity> popularActivities,
      String? bestTimeToVisit,
      int? averageDailyCost,
      String? currencyCode,
      String? language,
      String? timezone,
      bool isHiddenGem,
      double popularityScore,
      DateTime createdAt,
      DateTime updatedAt});

  @override
  $SoloSuitabilityFactorsCopyWith<$Res> get soloSuitabilityFactors;
}

/// @nodoc
class __$DestinationCopyWithImpl<$Res> implements _$DestinationCopyWith<$Res> {
  __$DestinationCopyWithImpl(this._self, this._then);

  final _Destination _self;
  final $Res Function(_Destination) _then;

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? countryCode = null,
    Object? region = freezed,
    Object? safetyScore = null,
    Object? safetyInsights = null,
    Object? soloSuitabilityScore = null,
    Object? soloSuitabilityFactors = null,
    Object? budgetLevel = null,
    Object? activityLevels = null,
    Object? tags = null,
    Object? images = null,
    Object? coverImageUrl = freezed,
    Object? popularActivities = null,
    Object? bestTimeToVisit = freezed,
    Object? averageDailyCost = freezed,
    Object? currencyCode = freezed,
    Object? language = freezed,
    Object? timezone = freezed,
    Object? isHiddenGem = null,
    Object? popularityScore = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_Destination(
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
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      countryCode: null == countryCode
          ? _self.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String,
      region: freezed == region
          ? _self.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      safetyScore: null == safetyScore
          ? _self.safetyScore
          : safetyScore // ignore: cast_nullable_to_non_nullable
              as double,
      safetyInsights: null == safetyInsights
          ? _self._safetyInsights
          : safetyInsights // ignore: cast_nullable_to_non_nullable
              as List<SafetyInsight>,
      soloSuitabilityScore: null == soloSuitabilityScore
          ? _self.soloSuitabilityScore
          : soloSuitabilityScore // ignore: cast_nullable_to_non_nullable
              as double,
      soloSuitabilityFactors: null == soloSuitabilityFactors
          ? _self.soloSuitabilityFactors
          : soloSuitabilityFactors // ignore: cast_nullable_to_non_nullable
              as SoloSuitabilityFactors,
      budgetLevel: null == budgetLevel
          ? _self.budgetLevel
          : budgetLevel // ignore: cast_nullable_to_non_nullable
              as BudgetLevel,
      activityLevels: null == activityLevels
          ? _self._activityLevels
          : activityLevels // ignore: cast_nullable_to_non_nullable
              as List<ActivityLevel>,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      images: null == images
          ? _self._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      coverImageUrl: freezed == coverImageUrl
          ? _self.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      popularActivities: null == popularActivities
          ? _self._popularActivities
          : popularActivities // ignore: cast_nullable_to_non_nullable
              as List<Activity>,
      bestTimeToVisit: freezed == bestTimeToVisit
          ? _self.bestTimeToVisit
          : bestTimeToVisit // ignore: cast_nullable_to_non_nullable
              as String?,
      averageDailyCost: freezed == averageDailyCost
          ? _self.averageDailyCost
          : averageDailyCost // ignore: cast_nullable_to_non_nullable
              as int?,
      currencyCode: freezed == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      timezone: freezed == timezone
          ? _self.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
      isHiddenGem: null == isHiddenGem
          ? _self.isHiddenGem
          : isHiddenGem // ignore: cast_nullable_to_non_nullable
              as bool,
      popularityScore: null == popularityScore
          ? _self.popularityScore
          : popularityScore // ignore: cast_nullable_to_non_nullable
              as double,
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

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SoloSuitabilityFactorsCopyWith<$Res> get soloSuitabilityFactors {
    return $SoloSuitabilityFactorsCopyWith<$Res>(_self.soloSuitabilityFactors,
        (value) {
      return _then(_self.copyWith(soloSuitabilityFactors: value));
    });
  }
}

// dart format on
