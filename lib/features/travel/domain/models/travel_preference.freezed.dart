// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'travel_preference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TravelPreference _$TravelPreferenceFromJson(Map<String, dynamic> json) {
  return _TravelPreference.fromJson(json);
}

/// @nodoc
mixin _$TravelPreference {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  List<String> get travelStyles => throw _privateConstructorUsedError;
  List<String> get accommodationTypes => throw _privateConstructorUsedError;
  List<String> get transportationTypes => throw _privateConstructorUsedError;
  int get minBudget => throw _privateConstructorUsedError;
  int get maxBudget => throw _privateConstructorUsedError;
  int get minTripDuration => throw _privateConstructorUsedError;
  int get maxTripDuration => throw _privateConstructorUsedError;
  List<String> get preferredDestinations => throw _privateConstructorUsedError;
  List<String> get avoidDestinations => throw _privateConstructorUsedError;
  bool get isFlexibleDates => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TravelPreference to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TravelPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TravelPreferenceCopyWith<TravelPreference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TravelPreferenceCopyWith<$Res> {
  factory $TravelPreferenceCopyWith(
          TravelPreference value, $Res Function(TravelPreference) then) =
      _$TravelPreferenceCopyWithImpl<$Res, TravelPreference>;
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
class _$TravelPreferenceCopyWithImpl<$Res, $Val extends TravelPreference>
    implements $TravelPreferenceCopyWith<$Res> {
  _$TravelPreferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      travelStyles: null == travelStyles
          ? _value.travelStyles
          : travelStyles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      accommodationTypes: null == accommodationTypes
          ? _value.accommodationTypes
          : accommodationTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      transportationTypes: null == transportationTypes
          ? _value.transportationTypes
          : transportationTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      minBudget: null == minBudget
          ? _value.minBudget
          : minBudget // ignore: cast_nullable_to_non_nullable
              as int,
      maxBudget: null == maxBudget
          ? _value.maxBudget
          : maxBudget // ignore: cast_nullable_to_non_nullable
              as int,
      minTripDuration: null == minTripDuration
          ? _value.minTripDuration
          : minTripDuration // ignore: cast_nullable_to_non_nullable
              as int,
      maxTripDuration: null == maxTripDuration
          ? _value.maxTripDuration
          : maxTripDuration // ignore: cast_nullable_to_non_nullable
              as int,
      preferredDestinations: null == preferredDestinations
          ? _value.preferredDestinations
          : preferredDestinations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      avoidDestinations: null == avoidDestinations
          ? _value.avoidDestinations
          : avoidDestinations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFlexibleDates: null == isFlexibleDates
          ? _value.isFlexibleDates
          : isFlexibleDates // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$TravelPreferenceImplCopyWith<$Res>
    implements $TravelPreferenceCopyWith<$Res> {
  factory _$$TravelPreferenceImplCopyWith(_$TravelPreferenceImpl value,
          $Res Function(_$TravelPreferenceImpl) then) =
      __$$TravelPreferenceImplCopyWithImpl<$Res>;
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
class __$$TravelPreferenceImplCopyWithImpl<$Res>
    extends _$TravelPreferenceCopyWithImpl<$Res, _$TravelPreferenceImpl>
    implements _$$TravelPreferenceImplCopyWith<$Res> {
  __$$TravelPreferenceImplCopyWithImpl(_$TravelPreferenceImpl _value,
      $Res Function(_$TravelPreferenceImpl) _then)
      : super(_value, _then);

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
    return _then(_$TravelPreferenceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      travelStyles: null == travelStyles
          ? _value._travelStyles
          : travelStyles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      accommodationTypes: null == accommodationTypes
          ? _value._accommodationTypes
          : accommodationTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      transportationTypes: null == transportationTypes
          ? _value._transportationTypes
          : transportationTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      minBudget: null == minBudget
          ? _value.minBudget
          : minBudget // ignore: cast_nullable_to_non_nullable
              as int,
      maxBudget: null == maxBudget
          ? _value.maxBudget
          : maxBudget // ignore: cast_nullable_to_non_nullable
              as int,
      minTripDuration: null == minTripDuration
          ? _value.minTripDuration
          : minTripDuration // ignore: cast_nullable_to_non_nullable
              as int,
      maxTripDuration: null == maxTripDuration
          ? _value.maxTripDuration
          : maxTripDuration // ignore: cast_nullable_to_non_nullable
              as int,
      preferredDestinations: null == preferredDestinations
          ? _value._preferredDestinations
          : preferredDestinations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      avoidDestinations: null == avoidDestinations
          ? _value._avoidDestinations
          : avoidDestinations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFlexibleDates: null == isFlexibleDates
          ? _value.isFlexibleDates
          : isFlexibleDates // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$TravelPreferenceImpl implements _TravelPreference {
  const _$TravelPreferenceImpl(
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

  factory _$TravelPreferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$TravelPreferenceImplFromJson(json);

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

  @override
  String toString() {
    return 'TravelPreference(id: $id, userId: $userId, travelStyles: $travelStyles, accommodationTypes: $accommodationTypes, transportationTypes: $transportationTypes, minBudget: $minBudget, maxBudget: $maxBudget, minTripDuration: $minTripDuration, maxTripDuration: $maxTripDuration, preferredDestinations: $preferredDestinations, avoidDestinations: $avoidDestinations, isFlexibleDates: $isFlexibleDates, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TravelPreferenceImpl &&
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

  /// Create a copy of TravelPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TravelPreferenceImplCopyWith<_$TravelPreferenceImpl> get copyWith =>
      __$$TravelPreferenceImplCopyWithImpl<_$TravelPreferenceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TravelPreferenceImplToJson(
      this,
    );
  }
}

abstract class _TravelPreference implements TravelPreference {
  const factory _TravelPreference(
      {required final String id,
      required final String userId,
      required final List<String> travelStyles,
      required final List<String> accommodationTypes,
      required final List<String> transportationTypes,
      required final int minBudget,
      required final int maxBudget,
      required final int minTripDuration,
      required final int maxTripDuration,
      required final List<String> preferredDestinations,
      required final List<String> avoidDestinations,
      required final bool isFlexibleDates,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$TravelPreferenceImpl;

  factory _TravelPreference.fromJson(Map<String, dynamic> json) =
      _$TravelPreferenceImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  List<String> get travelStyles;
  @override
  List<String> get accommodationTypes;
  @override
  List<String> get transportationTypes;
  @override
  int get minBudget;
  @override
  int get maxBudget;
  @override
  int get minTripDuration;
  @override
  int get maxTripDuration;
  @override
  List<String> get preferredDestinations;
  @override
  List<String> get avoidDestinations;
  @override
  bool get isFlexibleDates;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of TravelPreference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TravelPreferenceImplCopyWith<_$TravelPreferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
