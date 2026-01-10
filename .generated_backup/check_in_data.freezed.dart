// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheckInData _$CheckInDataFromJson(Map<String, dynamic> json) {
  return _CheckInData.fromJson(json);
}

/// @nodoc
mixin _$CheckInData {
  List<CheckIn> get checkIns => throw _privateConstructorUsedError;
  List<CheckIn> get upcomingCheckIns => throw _privateConstructorUsedError;
  CheckIn? get selectedCheckIn => throw _privateConstructorUsedError;

  /// Serializes this CheckInData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckInData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckInDataCopyWith<CheckInData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInDataCopyWith<$Res> {
  factory $CheckInDataCopyWith(
          CheckInData value, $Res Function(CheckInData) then) =
      _$CheckInDataCopyWithImpl<$Res, CheckInData>;
  @useResult
  $Res call(
      {List<CheckIn> checkIns,
      List<CheckIn> upcomingCheckIns,
      CheckIn? selectedCheckIn});

  $CheckInCopyWith<$Res>? get selectedCheckIn;
}

/// @nodoc
class _$CheckInDataCopyWithImpl<$Res, $Val extends CheckInData>
    implements $CheckInDataCopyWith<$Res> {
  _$CheckInDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckInData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? checkIns = null,
    Object? upcomingCheckIns = null,
    Object? selectedCheckIn = freezed,
  }) {
    return _then(_value.copyWith(
      checkIns: null == checkIns
          ? _value.checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      upcomingCheckIns: null == upcomingCheckIns
          ? _value.upcomingCheckIns
          : upcomingCheckIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      selectedCheckIn: freezed == selectedCheckIn
          ? _value.selectedCheckIn
          : selectedCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
    ) as $Val);
  }

  /// Create a copy of CheckInData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInCopyWith<$Res>? get selectedCheckIn {
    if (_value.selectedCheckIn == null) {
      return null;
    }

    return $CheckInCopyWith<$Res>(_value.selectedCheckIn!, (value) {
      return _then(_value.copyWith(selectedCheckIn: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CheckInDataImplCopyWith<$Res>
    implements $CheckInDataCopyWith<$Res> {
  factory _$$CheckInDataImplCopyWith(
          _$CheckInDataImpl value, $Res Function(_$CheckInDataImpl) then) =
      __$$CheckInDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<CheckIn> checkIns,
      List<CheckIn> upcomingCheckIns,
      CheckIn? selectedCheckIn});

  @override
  $CheckInCopyWith<$Res>? get selectedCheckIn;
}

/// @nodoc
class __$$CheckInDataImplCopyWithImpl<$Res>
    extends _$CheckInDataCopyWithImpl<$Res, _$CheckInDataImpl>
    implements _$$CheckInDataImplCopyWith<$Res> {
  __$$CheckInDataImplCopyWithImpl(
      _$CheckInDataImpl _value, $Res Function(_$CheckInDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckInData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? checkIns = null,
    Object? upcomingCheckIns = null,
    Object? selectedCheckIn = freezed,
  }) {
    return _then(_$CheckInDataImpl(
      checkIns: null == checkIns
          ? _value._checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      upcomingCheckIns: null == upcomingCheckIns
          ? _value._upcomingCheckIns
          : upcomingCheckIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      selectedCheckIn: freezed == selectedCheckIn
          ? _value.selectedCheckIn
          : selectedCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckInDataImpl extends _CheckInData {
  const _$CheckInDataImpl(
      {final List<CheckIn> checkIns = const [],
      final List<CheckIn> upcomingCheckIns = const [],
      this.selectedCheckIn})
      : _checkIns = checkIns,
        _upcomingCheckIns = upcomingCheckIns,
        super._();

  factory _$CheckInDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckInDataImplFromJson(json);

  final List<CheckIn> _checkIns;
  @override
  @JsonKey()
  List<CheckIn> get checkIns {
    if (_checkIns is EqualUnmodifiableListView) return _checkIns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_checkIns);
  }

  final List<CheckIn> _upcomingCheckIns;
  @override
  @JsonKey()
  List<CheckIn> get upcomingCheckIns {
    if (_upcomingCheckIns is EqualUnmodifiableListView)
      return _upcomingCheckIns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_upcomingCheckIns);
  }

  @override
  final CheckIn? selectedCheckIn;

  @override
  String toString() {
    return 'CheckInData(checkIns: $checkIns, upcomingCheckIns: $upcomingCheckIns, selectedCheckIn: $selectedCheckIn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInDataImpl &&
            const DeepCollectionEquality().equals(other._checkIns, _checkIns) &&
            const DeepCollectionEquality()
                .equals(other._upcomingCheckIns, _upcomingCheckIns) &&
            (identical(other.selectedCheckIn, selectedCheckIn) ||
                other.selectedCheckIn == selectedCheckIn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_checkIns),
      const DeepCollectionEquality().hash(_upcomingCheckIns),
      selectedCheckIn);

  /// Create a copy of CheckInData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInDataImplCopyWith<_$CheckInDataImpl> get copyWith =>
      __$$CheckInDataImplCopyWithImpl<_$CheckInDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckInDataImplToJson(
      this,
    );
  }
}

abstract class _CheckInData extends CheckInData {
  const factory _CheckInData(
      {final List<CheckIn> checkIns,
      final List<CheckIn> upcomingCheckIns,
      final CheckIn? selectedCheckIn}) = _$CheckInDataImpl;
  const _CheckInData._() : super._();

  factory _CheckInData.fromJson(Map<String, dynamic> json) =
      _$CheckInDataImpl.fromJson;

  @override
  List<CheckIn> get checkIns;
  @override
  List<CheckIn> get upcomingCheckIns;
  @override
  CheckIn? get selectedCheckIn;

  /// Create a copy of CheckInData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckInDataImplCopyWith<_$CheckInDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
