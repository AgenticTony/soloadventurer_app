// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OnboardingData _$OnboardingDataFromJson(Map<String, dynamic> json) {
  return _OnboardingData.fromJson(json);
}

/// @nodoc
mixin _$OnboardingData {
  String get name => throw _privateConstructorUsedError;
  Destination get destination => throw _privateConstructorUsedError;
  DateRange get dateRange => throw _privateConstructorUsedError;
  Set<TravelInterest> get interests => throw _privateConstructorUsedError;
  BudgetRange? get budget => throw _privateConstructorUsedError;

  /// Serializes this OnboardingData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnboardingDataCopyWith<OnboardingData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingDataCopyWith<$Res> {
  factory $OnboardingDataCopyWith(
          OnboardingData value, $Res Function(OnboardingData) then) =
      _$OnboardingDataCopyWithImpl<$Res, OnboardingData>;
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
class _$OnboardingDataCopyWithImpl<$Res, $Val extends OnboardingData>
    implements $OnboardingDataCopyWith<$Res> {
  _$OnboardingDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination,
      dateRange: null == dateRange
          ? _value.dateRange
          : dateRange // ignore: cast_nullable_to_non_nullable
              as DateRange,
      interests: null == interests
          ? _value.interests
          : interests // ignore: cast_nullable_to_non_nullable
              as Set<TravelInterest>,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as BudgetRange?,
    ) as $Val);
  }

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res> get destination {
    return $DestinationCopyWith<$Res>(_value.destination, (value) {
      return _then(_value.copyWith(destination: value) as $Val);
    });
  }

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DateRangeCopyWith<$Res> get dateRange {
    return $DateRangeCopyWith<$Res>(_value.dateRange, (value) {
      return _then(_value.copyWith(dateRange: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OnboardingDataImplCopyWith<$Res>
    implements $OnboardingDataCopyWith<$Res> {
  factory _$$OnboardingDataImplCopyWith(_$OnboardingDataImpl value,
          $Res Function(_$OnboardingDataImpl) then) =
      __$$OnboardingDataImplCopyWithImpl<$Res>;
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
class __$$OnboardingDataImplCopyWithImpl<$Res>
    extends _$OnboardingDataCopyWithImpl<$Res, _$OnboardingDataImpl>
    implements _$$OnboardingDataImplCopyWith<$Res> {
  __$$OnboardingDataImplCopyWithImpl(
      _$OnboardingDataImpl _value, $Res Function(_$OnboardingDataImpl) _then)
      : super(_value, _then);

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
    return _then(_$OnboardingDataImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as Destination,
      dateRange: null == dateRange
          ? _value.dateRange
          : dateRange // ignore: cast_nullable_to_non_nullable
              as DateRange,
      interests: null == interests
          ? _value._interests
          : interests // ignore: cast_nullable_to_non_nullable
              as Set<TravelInterest>,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as BudgetRange?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OnboardingDataImpl extends _OnboardingData {
  const _$OnboardingDataImpl(
      {required this.name,
      required this.destination,
      required this.dateRange,
      required final Set<TravelInterest> interests,
      this.budget})
      : _interests = interests,
        super._();

  factory _$OnboardingDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$OnboardingDataImplFromJson(json);

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

  @override
  String toString() {
    return 'OnboardingData(name: $name, destination: $destination, dateRange: $dateRange, interests: $interests, budget: $budget)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingDataImpl &&
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

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingDataImplCopyWith<_$OnboardingDataImpl> get copyWith =>
      __$$OnboardingDataImplCopyWithImpl<_$OnboardingDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OnboardingDataImplToJson(
      this,
    );
  }
}

abstract class _OnboardingData extends OnboardingData {
  const factory _OnboardingData(
      {required final String name,
      required final Destination destination,
      required final DateRange dateRange,
      required final Set<TravelInterest> interests,
      final BudgetRange? budget}) = _$OnboardingDataImpl;
  const _OnboardingData._() : super._();

  factory _OnboardingData.fromJson(Map<String, dynamic> json) =
      _$OnboardingDataImpl.fromJson;

  @override
  String get name;
  @override
  Destination get destination;
  @override
  DateRange get dateRange;
  @override
  Set<TravelInterest> get interests;
  @override
  BudgetRange? get budget;

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingDataImplCopyWith<_$OnboardingDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
