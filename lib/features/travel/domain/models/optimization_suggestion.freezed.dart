// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'optimization_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OptimizationSuggestion {
  String get id;
  OptimizationType get type;
  String get title;
  String get description;
  List<ItineraryItem> get affectedItems;
  List<ItineraryItem> get suggestedOrder;
  String? get reasoning;
  Duration get timeSaved;
  double? get costSaved;

  /// Create a copy of OptimizationSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OptimizationSuggestionCopyWith<OptimizationSuggestion> get copyWith =>
      _$OptimizationSuggestionCopyWithImpl<OptimizationSuggestion>(
          this as OptimizationSuggestion, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OptimizationSuggestion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other.affectedItems, affectedItems) &&
            const DeepCollectionEquality()
                .equals(other.suggestedOrder, suggestedOrder) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning) &&
            (identical(other.timeSaved, timeSaved) ||
                other.timeSaved == timeSaved) &&
            (identical(other.costSaved, costSaved) ||
                other.costSaved == costSaved));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      title,
      description,
      const DeepCollectionEquality().hash(affectedItems),
      const DeepCollectionEquality().hash(suggestedOrder),
      reasoning,
      timeSaved,
      costSaved);

  @override
  String toString() {
    return 'OptimizationSuggestion(id: $id, type: $type, title: $title, description: $description, affectedItems: $affectedItems, suggestedOrder: $suggestedOrder, reasoning: $reasoning, timeSaved: $timeSaved, costSaved: $costSaved)';
  }
}

/// @nodoc
abstract mixin class $OptimizationSuggestionCopyWith<$Res> {
  factory $OptimizationSuggestionCopyWith(OptimizationSuggestion value,
          $Res Function(OptimizationSuggestion) _then) =
      _$OptimizationSuggestionCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      OptimizationType type,
      String title,
      String description,
      List<ItineraryItem> affectedItems,
      List<ItineraryItem> suggestedOrder,
      String? reasoning,
      Duration timeSaved,
      double? costSaved});
}

/// @nodoc
class _$OptimizationSuggestionCopyWithImpl<$Res>
    implements $OptimizationSuggestionCopyWith<$Res> {
  _$OptimizationSuggestionCopyWithImpl(this._self, this._then);

  final OptimizationSuggestion _self;
  final $Res Function(OptimizationSuggestion) _then;

  /// Create a copy of OptimizationSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? affectedItems = null,
    Object? suggestedOrder = null,
    Object? reasoning = freezed,
    Object? timeSaved = null,
    Object? costSaved = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as OptimizationType,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      affectedItems: null == affectedItems
          ? _self.affectedItems
          : affectedItems // ignore: cast_nullable_to_non_nullable
              as List<ItineraryItem>,
      suggestedOrder: null == suggestedOrder
          ? _self.suggestedOrder
          : suggestedOrder // ignore: cast_nullable_to_non_nullable
              as List<ItineraryItem>,
      reasoning: freezed == reasoning
          ? _self.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String?,
      timeSaved: null == timeSaved
          ? _self.timeSaved
          : timeSaved // ignore: cast_nullable_to_non_nullable
              as Duration,
      costSaved: freezed == costSaved
          ? _self.costSaved
          : costSaved // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// Adds pattern-matching-related methods to [OptimizationSuggestion].
extension OptimizationSuggestionPatterns on OptimizationSuggestion {
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
    TResult Function(_OptimizationSuggestion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OptimizationSuggestion() when $default != null:
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
    TResult Function(_OptimizationSuggestion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OptimizationSuggestion():
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
    TResult? Function(_OptimizationSuggestion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OptimizationSuggestion() when $default != null:
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
            OptimizationType type,
            String title,
            String description,
            List<ItineraryItem> affectedItems,
            List<ItineraryItem> suggestedOrder,
            String? reasoning,
            Duration timeSaved,
            double? costSaved)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OptimizationSuggestion() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.title,
            _that.description,
            _that.affectedItems,
            _that.suggestedOrder,
            _that.reasoning,
            _that.timeSaved,
            _that.costSaved);
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
            OptimizationType type,
            String title,
            String description,
            List<ItineraryItem> affectedItems,
            List<ItineraryItem> suggestedOrder,
            String? reasoning,
            Duration timeSaved,
            double? costSaved)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OptimizationSuggestion():
        return $default(
            _that.id,
            _that.type,
            _that.title,
            _that.description,
            _that.affectedItems,
            _that.suggestedOrder,
            _that.reasoning,
            _that.timeSaved,
            _that.costSaved);
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
            OptimizationType type,
            String title,
            String description,
            List<ItineraryItem> affectedItems,
            List<ItineraryItem> suggestedOrder,
            String? reasoning,
            Duration timeSaved,
            double? costSaved)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OptimizationSuggestion() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.title,
            _that.description,
            _that.affectedItems,
            _that.suggestedOrder,
            _that.reasoning,
            _that.timeSaved,
            _that.costSaved);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OptimizationSuggestion extends OptimizationSuggestion {
  const _OptimizationSuggestion(
      {required this.id,
      required this.type,
      required this.title,
      required this.description,
      required final List<ItineraryItem> affectedItems,
      required final List<ItineraryItem> suggestedOrder,
      this.reasoning,
      this.timeSaved = Duration.zero,
      this.costSaved})
      : _affectedItems = affectedItems,
        _suggestedOrder = suggestedOrder,
        super._();

  @override
  final String id;
  @override
  final OptimizationType type;
  @override
  final String title;
  @override
  final String description;
  final List<ItineraryItem> _affectedItems;
  @override
  List<ItineraryItem> get affectedItems {
    if (_affectedItems is EqualUnmodifiableListView) return _affectedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_affectedItems);
  }

  final List<ItineraryItem> _suggestedOrder;
  @override
  List<ItineraryItem> get suggestedOrder {
    if (_suggestedOrder is EqualUnmodifiableListView) return _suggestedOrder;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestedOrder);
  }

  @override
  final String? reasoning;
  @override
  @JsonKey()
  final Duration timeSaved;
  @override
  final double? costSaved;

  /// Create a copy of OptimizationSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OptimizationSuggestionCopyWith<_OptimizationSuggestion> get copyWith =>
      __$OptimizationSuggestionCopyWithImpl<_OptimizationSuggestion>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OptimizationSuggestion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._affectedItems, _affectedItems) &&
            const DeepCollectionEquality()
                .equals(other._suggestedOrder, _suggestedOrder) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning) &&
            (identical(other.timeSaved, timeSaved) ||
                other.timeSaved == timeSaved) &&
            (identical(other.costSaved, costSaved) ||
                other.costSaved == costSaved));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      title,
      description,
      const DeepCollectionEquality().hash(_affectedItems),
      const DeepCollectionEquality().hash(_suggestedOrder),
      reasoning,
      timeSaved,
      costSaved);

  @override
  String toString() {
    return 'OptimizationSuggestion(id: $id, type: $type, title: $title, description: $description, affectedItems: $affectedItems, suggestedOrder: $suggestedOrder, reasoning: $reasoning, timeSaved: $timeSaved, costSaved: $costSaved)';
  }
}

/// @nodoc
abstract mixin class _$OptimizationSuggestionCopyWith<$Res>
    implements $OptimizationSuggestionCopyWith<$Res> {
  factory _$OptimizationSuggestionCopyWith(_OptimizationSuggestion value,
          $Res Function(_OptimizationSuggestion) _then) =
      __$OptimizationSuggestionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      OptimizationType type,
      String title,
      String description,
      List<ItineraryItem> affectedItems,
      List<ItineraryItem> suggestedOrder,
      String? reasoning,
      Duration timeSaved,
      double? costSaved});
}

/// @nodoc
class __$OptimizationSuggestionCopyWithImpl<$Res>
    implements _$OptimizationSuggestionCopyWith<$Res> {
  __$OptimizationSuggestionCopyWithImpl(this._self, this._then);

  final _OptimizationSuggestion _self;
  final $Res Function(_OptimizationSuggestion) _then;

  /// Create a copy of OptimizationSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? affectedItems = null,
    Object? suggestedOrder = null,
    Object? reasoning = freezed,
    Object? timeSaved = null,
    Object? costSaved = freezed,
  }) {
    return _then(_OptimizationSuggestion(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as OptimizationType,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      affectedItems: null == affectedItems
          ? _self._affectedItems
          : affectedItems // ignore: cast_nullable_to_non_nullable
              as List<ItineraryItem>,
      suggestedOrder: null == suggestedOrder
          ? _self._suggestedOrder
          : suggestedOrder // ignore: cast_nullable_to_non_nullable
              as List<ItineraryItem>,
      reasoning: freezed == reasoning
          ? _self.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String?,
      timeSaved: null == timeSaved
          ? _self.timeSaved
          : timeSaved // ignore: cast_nullable_to_non_nullable
              as Duration,
      costSaved: freezed == costSaved
          ? _self.costSaved
          : costSaved // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

// dart format on
