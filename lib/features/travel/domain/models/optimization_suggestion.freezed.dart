// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'optimization_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OptimizationSuggestion {
  String get id => throw _privateConstructorUsedError;
  OptimizationType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<ItineraryItem> get affectedItems => throw _privateConstructorUsedError;
  List<ItineraryItem> get suggestedOrder => throw _privateConstructorUsedError;
  String? get reasoning => throw _privateConstructorUsedError;
  Duration get timeSaved => throw _privateConstructorUsedError;
  double? get costSaved => throw _privateConstructorUsedError;

  /// Create a copy of OptimizationSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OptimizationSuggestionCopyWith<OptimizationSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OptimizationSuggestionCopyWith<$Res> {
  factory $OptimizationSuggestionCopyWith(OptimizationSuggestion value,
          $Res Function(OptimizationSuggestion) then) =
      _$OptimizationSuggestionCopyWithImpl<$Res, OptimizationSuggestion>;
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
class _$OptimizationSuggestionCopyWithImpl<$Res,
        $Val extends OptimizationSuggestion>
    implements $OptimizationSuggestionCopyWith<$Res> {
  _$OptimizationSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as OptimizationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      affectedItems: null == affectedItems
          ? _value.affectedItems
          : affectedItems // ignore: cast_nullable_to_non_nullable
              as List<ItineraryItem>,
      suggestedOrder: null == suggestedOrder
          ? _value.suggestedOrder
          : suggestedOrder // ignore: cast_nullable_to_non_nullable
              as List<ItineraryItem>,
      reasoning: freezed == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String?,
      timeSaved: null == timeSaved
          ? _value.timeSaved
          : timeSaved // ignore: cast_nullable_to_non_nullable
              as Duration,
      costSaved: freezed == costSaved
          ? _value.costSaved
          : costSaved // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OptimizationSuggestionImplCopyWith<$Res>
    implements $OptimizationSuggestionCopyWith<$Res> {
  factory _$$OptimizationSuggestionImplCopyWith(
          _$OptimizationSuggestionImpl value,
          $Res Function(_$OptimizationSuggestionImpl) then) =
      __$$OptimizationSuggestionImplCopyWithImpl<$Res>;
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
class __$$OptimizationSuggestionImplCopyWithImpl<$Res>
    extends _$OptimizationSuggestionCopyWithImpl<$Res,
        _$OptimizationSuggestionImpl>
    implements _$$OptimizationSuggestionImplCopyWith<$Res> {
  __$$OptimizationSuggestionImplCopyWithImpl(
      _$OptimizationSuggestionImpl _value,
      $Res Function(_$OptimizationSuggestionImpl) _then)
      : super(_value, _then);

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
    return _then(_$OptimizationSuggestionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as OptimizationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      affectedItems: null == affectedItems
          ? _value._affectedItems
          : affectedItems // ignore: cast_nullable_to_non_nullable
              as List<ItineraryItem>,
      suggestedOrder: null == suggestedOrder
          ? _value._suggestedOrder
          : suggestedOrder // ignore: cast_nullable_to_non_nullable
              as List<ItineraryItem>,
      reasoning: freezed == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String?,
      timeSaved: null == timeSaved
          ? _value.timeSaved
          : timeSaved // ignore: cast_nullable_to_non_nullable
              as Duration,
      costSaved: freezed == costSaved
          ? _value.costSaved
          : costSaved // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$OptimizationSuggestionImpl extends _OptimizationSuggestion {
  const _$OptimizationSuggestionImpl(
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

  @override
  String toString() {
    return 'OptimizationSuggestion(id: $id, type: $type, title: $title, description: $description, affectedItems: $affectedItems, suggestedOrder: $suggestedOrder, reasoning: $reasoning, timeSaved: $timeSaved, costSaved: $costSaved)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OptimizationSuggestionImpl &&
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

  /// Create a copy of OptimizationSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OptimizationSuggestionImplCopyWith<_$OptimizationSuggestionImpl>
      get copyWith => __$$OptimizationSuggestionImplCopyWithImpl<
          _$OptimizationSuggestionImpl>(this, _$identity);
}

abstract class _OptimizationSuggestion extends OptimizationSuggestion {
  const factory _OptimizationSuggestion(
      {required final String id,
      required final OptimizationType type,
      required final String title,
      required final String description,
      required final List<ItineraryItem> affectedItems,
      required final List<ItineraryItem> suggestedOrder,
      final String? reasoning,
      final Duration timeSaved,
      final double? costSaved}) = _$OptimizationSuggestionImpl;
  const _OptimizationSuggestion._() : super._();

  @override
  String get id;
  @override
  OptimizationType get type;
  @override
  String get title;
  @override
  String get description;
  @override
  List<ItineraryItem> get affectedItems;
  @override
  List<ItineraryItem> get suggestedOrder;
  @override
  String? get reasoning;
  @override
  Duration get timeSaved;
  @override
  double? get costSaved;

  /// Create a copy of OptimizationSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OptimizationSuggestionImplCopyWith<_$OptimizationSuggestionImpl>
      get copyWith => throw _privateConstructorUsedError;
}
