// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SafetyData _$SafetyDataFromJson(Map<String, dynamic> json) {
  return _SafetyData.fromJson(json);
}

/// @nodoc
mixin _$SafetyData {
  /// Current safety status of the user
  SafetyStatus? get currentStatus => throw _privateConstructorUsedError;

  /// List of trusted contacts
  List<TrustedContact> get contacts => throw _privateConstructorUsedError;

  /// List of recent check-ins
  List<CheckIn> get checkIns => throw _privateConstructorUsedError;

  /// List of recent safety alerts
  List<SafetyAlert> get recentAlerts => throw _privateConstructorUsedError;

  /// List of active (unresolved) safety alerts
  List<SafetyAlert> get activeAlerts => throw _privateConstructorUsedError;

  /// Currently selected check-in (for viewing)
  CheckIn? get selectedCheckIn => throw _privateConstructorUsedError;

  /// Currently selected alert (for viewing)
  SafetyAlert? get selectedAlert => throw _privateConstructorUsedError;

  /// Serializes this SafetyData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SafetyDataCopyWith<SafetyData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SafetyDataCopyWith<$Res> {
  factory $SafetyDataCopyWith(
          SafetyData value, $Res Function(SafetyData) then) =
      _$SafetyDataCopyWithImpl<$Res, SafetyData>;
  @useResult
  $Res call(
      {SafetyStatus? currentStatus,
      List<TrustedContact> contacts,
      List<CheckIn> checkIns,
      List<SafetyAlert> recentAlerts,
      List<SafetyAlert> activeAlerts,
      CheckIn? selectedCheckIn,
      SafetyAlert? selectedAlert});

  $SafetyStatusCopyWith<$Res>? get currentStatus;
  $CheckInCopyWith<$Res>? get selectedCheckIn;
  $SafetyAlertCopyWith<$Res>? get selectedAlert;
}

/// @nodoc
class _$SafetyDataCopyWithImpl<$Res, $Val extends SafetyData>
    implements $SafetyDataCopyWith<$Res> {
  _$SafetyDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStatus = freezed,
    Object? contacts = null,
    Object? checkIns = null,
    Object? recentAlerts = null,
    Object? activeAlerts = null,
    Object? selectedCheckIn = freezed,
    Object? selectedAlert = freezed,
  }) {
    return _then(_value.copyWith(
      currentStatus: freezed == currentStatus
          ? _value.currentStatus
          : currentStatus // ignore: cast_nullable_to_non_nullable
              as SafetyStatus?,
      contacts: null == contacts
          ? _value.contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<TrustedContact>,
      checkIns: null == checkIns
          ? _value.checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      recentAlerts: null == recentAlerts
          ? _value.recentAlerts
          : recentAlerts // ignore: cast_nullable_to_non_nullable
              as List<SafetyAlert>,
      activeAlerts: null == activeAlerts
          ? _value.activeAlerts
          : activeAlerts // ignore: cast_nullable_to_non_nullable
              as List<SafetyAlert>,
      selectedCheckIn: freezed == selectedCheckIn
          ? _value.selectedCheckIn
          : selectedCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
      selectedAlert: freezed == selectedAlert
          ? _value.selectedAlert
          : selectedAlert // ignore: cast_nullable_to_non_nullable
              as SafetyAlert?,
    ) as $Val);
  }

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SafetyStatusCopyWith<$Res>? get currentStatus {
    if (_value.currentStatus == null) {
      return null;
    }

    return $SafetyStatusCopyWith<$Res>(_value.currentStatus!, (value) {
      return _then(_value.copyWith(currentStatus: value) as $Val);
    });
  }

  /// Create a copy of SafetyData
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

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SafetyAlertCopyWith<$Res>? get selectedAlert {
    if (_value.selectedAlert == null) {
      return null;
    }

    return $SafetyAlertCopyWith<$Res>(_value.selectedAlert!, (value) {
      return _then(_value.copyWith(selectedAlert: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SafetyDataImplCopyWith<$Res>
    implements $SafetyDataCopyWith<$Res> {
  factory _$$SafetyDataImplCopyWith(
          _$SafetyDataImpl value, $Res Function(_$SafetyDataImpl) then) =
      __$$SafetyDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SafetyStatus? currentStatus,
      List<TrustedContact> contacts,
      List<CheckIn> checkIns,
      List<SafetyAlert> recentAlerts,
      List<SafetyAlert> activeAlerts,
      CheckIn? selectedCheckIn,
      SafetyAlert? selectedAlert});

  @override
  $SafetyStatusCopyWith<$Res>? get currentStatus;
  @override
  $CheckInCopyWith<$Res>? get selectedCheckIn;
  @override
  $SafetyAlertCopyWith<$Res>? get selectedAlert;
}

/// @nodoc
class __$$SafetyDataImplCopyWithImpl<$Res>
    extends _$SafetyDataCopyWithImpl<$Res, _$SafetyDataImpl>
    implements _$$SafetyDataImplCopyWith<$Res> {
  __$$SafetyDataImplCopyWithImpl(
      _$SafetyDataImpl _value, $Res Function(_$SafetyDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStatus = freezed,
    Object? contacts = null,
    Object? checkIns = null,
    Object? recentAlerts = null,
    Object? activeAlerts = null,
    Object? selectedCheckIn = freezed,
    Object? selectedAlert = freezed,
  }) {
    return _then(_$SafetyDataImpl(
      currentStatus: freezed == currentStatus
          ? _value.currentStatus
          : currentStatus // ignore: cast_nullable_to_non_nullable
              as SafetyStatus?,
      contacts: null == contacts
          ? _value._contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<TrustedContact>,
      checkIns: null == checkIns
          ? _value._checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      recentAlerts: null == recentAlerts
          ? _value._recentAlerts
          : recentAlerts // ignore: cast_nullable_to_non_nullable
              as List<SafetyAlert>,
      activeAlerts: null == activeAlerts
          ? _value._activeAlerts
          : activeAlerts // ignore: cast_nullable_to_non_nullable
              as List<SafetyAlert>,
      selectedCheckIn: freezed == selectedCheckIn
          ? _value.selectedCheckIn
          : selectedCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
      selectedAlert: freezed == selectedAlert
          ? _value.selectedAlert
          : selectedAlert // ignore: cast_nullable_to_non_nullable
              as SafetyAlert?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SafetyDataImpl extends _SafetyData {
  const _$SafetyDataImpl(
      {this.currentStatus,
      final List<TrustedContact> contacts = const [],
      final List<CheckIn> checkIns = const [],
      final List<SafetyAlert> recentAlerts = const [],
      final List<SafetyAlert> activeAlerts = const [],
      this.selectedCheckIn,
      this.selectedAlert})
      : _contacts = contacts,
        _checkIns = checkIns,
        _recentAlerts = recentAlerts,
        _activeAlerts = activeAlerts,
        super._();

  factory _$SafetyDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SafetyDataImplFromJson(json);

  /// Current safety status of the user
  @override
  final SafetyStatus? currentStatus;

  /// List of trusted contacts
  final List<TrustedContact> _contacts;

  /// List of trusted contacts
  @override
  @JsonKey()
  List<TrustedContact> get contacts {
    if (_contacts is EqualUnmodifiableListView) return _contacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contacts);
  }

  /// List of recent check-ins
  final List<CheckIn> _checkIns;

  /// List of recent check-ins
  @override
  @JsonKey()
  List<CheckIn> get checkIns {
    if (_checkIns is EqualUnmodifiableListView) return _checkIns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_checkIns);
  }

  /// List of recent safety alerts
  final List<SafetyAlert> _recentAlerts;

  /// List of recent safety alerts
  @override
  @JsonKey()
  List<SafetyAlert> get recentAlerts {
    if (_recentAlerts is EqualUnmodifiableListView) return _recentAlerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentAlerts);
  }

  /// List of active (unresolved) safety alerts
  final List<SafetyAlert> _activeAlerts;

  /// List of active (unresolved) safety alerts
  @override
  @JsonKey()
  List<SafetyAlert> get activeAlerts {
    if (_activeAlerts is EqualUnmodifiableListView) return _activeAlerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeAlerts);
  }

  /// Currently selected check-in (for viewing)
  @override
  final CheckIn? selectedCheckIn;

  /// Currently selected alert (for viewing)
  @override
  final SafetyAlert? selectedAlert;

  @override
  String toString() {
    return 'SafetyData(currentStatus: $currentStatus, contacts: $contacts, checkIns: $checkIns, recentAlerts: $recentAlerts, activeAlerts: $activeAlerts, selectedCheckIn: $selectedCheckIn, selectedAlert: $selectedAlert)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SafetyDataImpl &&
            (identical(other.currentStatus, currentStatus) ||
                other.currentStatus == currentStatus) &&
            const DeepCollectionEquality().equals(other._contacts, _contacts) &&
            const DeepCollectionEquality().equals(other._checkIns, _checkIns) &&
            const DeepCollectionEquality()
                .equals(other._recentAlerts, _recentAlerts) &&
            const DeepCollectionEquality()
                .equals(other._activeAlerts, _activeAlerts) &&
            (identical(other.selectedCheckIn, selectedCheckIn) ||
                other.selectedCheckIn == selectedCheckIn) &&
            (identical(other.selectedAlert, selectedAlert) ||
                other.selectedAlert == selectedAlert));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStatus,
      const DeepCollectionEquality().hash(_contacts),
      const DeepCollectionEquality().hash(_checkIns),
      const DeepCollectionEquality().hash(_recentAlerts),
      const DeepCollectionEquality().hash(_activeAlerts),
      selectedCheckIn,
      selectedAlert);

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SafetyDataImplCopyWith<_$SafetyDataImpl> get copyWith =>
      __$$SafetyDataImplCopyWithImpl<_$SafetyDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SafetyDataImplToJson(
      this,
    );
  }
}

abstract class _SafetyData extends SafetyData {
  const factory _SafetyData(
      {final SafetyStatus? currentStatus,
      final List<TrustedContact> contacts,
      final List<CheckIn> checkIns,
      final List<SafetyAlert> recentAlerts,
      final List<SafetyAlert> activeAlerts,
      final CheckIn? selectedCheckIn,
      final SafetyAlert? selectedAlert}) = _$SafetyDataImpl;
  const _SafetyData._() : super._();

  factory _SafetyData.fromJson(Map<String, dynamic> json) =
      _$SafetyDataImpl.fromJson;

  /// Current safety status of the user
  @override
  SafetyStatus? get currentStatus;

  /// List of trusted contacts
  @override
  List<TrustedContact> get contacts;

  /// List of recent check-ins
  @override
  List<CheckIn> get checkIns;

  /// List of recent safety alerts
  @override
  List<SafetyAlert> get recentAlerts;

  /// List of active (unresolved) safety alerts
  @override
  List<SafetyAlert> get activeAlerts;

  /// Currently selected check-in (for viewing)
  @override
  CheckIn? get selectedCheckIn;

  /// Currently selected alert (for viewing)
  @override
  SafetyAlert? get selectedAlert;

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SafetyDataImplCopyWith<_$SafetyDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
