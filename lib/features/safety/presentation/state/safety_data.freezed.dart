// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SafetyData {
  /// Current safety status of the user
  SafetyStatus? get currentStatus;

  /// List of trusted contacts
  List<TrustedContact> get contacts;

  /// List of recent check-ins
  List<CheckIn> get checkIns;

  /// List of recent safety alerts
  List<SafetyAlert> get recentAlerts;

  /// List of active (unresolved) safety alerts
  List<SafetyAlert> get activeAlerts;

  /// Currently selected check-in (for viewing)
  CheckIn? get selectedCheckIn;

  /// Currently selected alert (for viewing)
  SafetyAlert? get selectedAlert;

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SafetyDataCopyWith<SafetyData> get copyWith =>
      _$SafetyDataCopyWithImpl<SafetyData>(this as SafetyData, _$identity);

  /// Serializes this SafetyData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SafetyData &&
            (identical(other.currentStatus, currentStatus) ||
                other.currentStatus == currentStatus) &&
            const DeepCollectionEquality().equals(other.contacts, contacts) &&
            const DeepCollectionEquality().equals(other.checkIns, checkIns) &&
            const DeepCollectionEquality()
                .equals(other.recentAlerts, recentAlerts) &&
            const DeepCollectionEquality()
                .equals(other.activeAlerts, activeAlerts) &&
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
      const DeepCollectionEquality().hash(contacts),
      const DeepCollectionEquality().hash(checkIns),
      const DeepCollectionEquality().hash(recentAlerts),
      const DeepCollectionEquality().hash(activeAlerts),
      selectedCheckIn,
      selectedAlert);

  @override
  String toString() {
    return 'SafetyData(currentStatus: $currentStatus, contacts: $contacts, checkIns: $checkIns, recentAlerts: $recentAlerts, activeAlerts: $activeAlerts, selectedCheckIn: $selectedCheckIn, selectedAlert: $selectedAlert)';
  }
}

/// @nodoc
abstract mixin class $SafetyDataCopyWith<$Res> {
  factory $SafetyDataCopyWith(
          SafetyData value, $Res Function(SafetyData) _then) =
      _$SafetyDataCopyWithImpl;
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
class _$SafetyDataCopyWithImpl<$Res> implements $SafetyDataCopyWith<$Res> {
  _$SafetyDataCopyWithImpl(this._self, this._then);

  final SafetyData _self;
  final $Res Function(SafetyData) _then;

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
    return _then(_self.copyWith(
      currentStatus: freezed == currentStatus
          ? _self.currentStatus
          : currentStatus // ignore: cast_nullable_to_non_nullable
              as SafetyStatus?,
      contacts: null == contacts
          ? _self.contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<TrustedContact>,
      checkIns: null == checkIns
          ? _self.checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      recentAlerts: null == recentAlerts
          ? _self.recentAlerts
          : recentAlerts // ignore: cast_nullable_to_non_nullable
              as List<SafetyAlert>,
      activeAlerts: null == activeAlerts
          ? _self.activeAlerts
          : activeAlerts // ignore: cast_nullable_to_non_nullable
              as List<SafetyAlert>,
      selectedCheckIn: freezed == selectedCheckIn
          ? _self.selectedCheckIn
          : selectedCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
      selectedAlert: freezed == selectedAlert
          ? _self.selectedAlert
          : selectedAlert // ignore: cast_nullable_to_non_nullable
              as SafetyAlert?,
    ));
  }

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SafetyStatusCopyWith<$Res>? get currentStatus {
    if (_self.currentStatus == null) {
      return null;
    }

    return $SafetyStatusCopyWith<$Res>(_self.currentStatus!, (value) {
      return _then(_self.copyWith(currentStatus: value));
    });
  }

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInCopyWith<$Res>? get selectedCheckIn {
    if (_self.selectedCheckIn == null) {
      return null;
    }

    return $CheckInCopyWith<$Res>(_self.selectedCheckIn!, (value) {
      return _then(_self.copyWith(selectedCheckIn: value));
    });
  }

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SafetyAlertCopyWith<$Res>? get selectedAlert {
    if (_self.selectedAlert == null) {
      return null;
    }

    return $SafetyAlertCopyWith<$Res>(_self.selectedAlert!, (value) {
      return _then(_self.copyWith(selectedAlert: value));
    });
  }
}

/// Adds pattern-matching-related methods to [SafetyData].
extension SafetyDataPatterns on SafetyData {
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
    TResult Function(_SafetyData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyData() when $default != null:
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
    TResult Function(_SafetyData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyData():
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
    TResult? Function(_SafetyData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyData() when $default != null:
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
            SafetyStatus? currentStatus,
            List<TrustedContact> contacts,
            List<CheckIn> checkIns,
            List<SafetyAlert> recentAlerts,
            List<SafetyAlert> activeAlerts,
            CheckIn? selectedCheckIn,
            SafetyAlert? selectedAlert)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyData() when $default != null:
        return $default(
            _that.currentStatus,
            _that.contacts,
            _that.checkIns,
            _that.recentAlerts,
            _that.activeAlerts,
            _that.selectedCheckIn,
            _that.selectedAlert);
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
            SafetyStatus? currentStatus,
            List<TrustedContact> contacts,
            List<CheckIn> checkIns,
            List<SafetyAlert> recentAlerts,
            List<SafetyAlert> activeAlerts,
            CheckIn? selectedCheckIn,
            SafetyAlert? selectedAlert)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyData():
        return $default(
            _that.currentStatus,
            _that.contacts,
            _that.checkIns,
            _that.recentAlerts,
            _that.activeAlerts,
            _that.selectedCheckIn,
            _that.selectedAlert);
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
            SafetyStatus? currentStatus,
            List<TrustedContact> contacts,
            List<CheckIn> checkIns,
            List<SafetyAlert> recentAlerts,
            List<SafetyAlert> activeAlerts,
            CheckIn? selectedCheckIn,
            SafetyAlert? selectedAlert)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyData() when $default != null:
        return $default(
            _that.currentStatus,
            _that.contacts,
            _that.checkIns,
            _that.recentAlerts,
            _that.activeAlerts,
            _that.selectedCheckIn,
            _that.selectedAlert);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SafetyData extends SafetyData {
  const _SafetyData(
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
  factory _SafetyData.fromJson(Map<String, dynamic> json) =>
      _$SafetyDataFromJson(json);

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

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SafetyDataCopyWith<_SafetyData> get copyWith =>
      __$SafetyDataCopyWithImpl<_SafetyData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SafetyDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SafetyData &&
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

  @override
  String toString() {
    return 'SafetyData(currentStatus: $currentStatus, contacts: $contacts, checkIns: $checkIns, recentAlerts: $recentAlerts, activeAlerts: $activeAlerts, selectedCheckIn: $selectedCheckIn, selectedAlert: $selectedAlert)';
  }
}

/// @nodoc
abstract mixin class _$SafetyDataCopyWith<$Res>
    implements $SafetyDataCopyWith<$Res> {
  factory _$SafetyDataCopyWith(
          _SafetyData value, $Res Function(_SafetyData) _then) =
      __$SafetyDataCopyWithImpl;
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
class __$SafetyDataCopyWithImpl<$Res> implements _$SafetyDataCopyWith<$Res> {
  __$SafetyDataCopyWithImpl(this._self, this._then);

  final _SafetyData _self;
  final $Res Function(_SafetyData) _then;

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? currentStatus = freezed,
    Object? contacts = null,
    Object? checkIns = null,
    Object? recentAlerts = null,
    Object? activeAlerts = null,
    Object? selectedCheckIn = freezed,
    Object? selectedAlert = freezed,
  }) {
    return _then(_SafetyData(
      currentStatus: freezed == currentStatus
          ? _self.currentStatus
          : currentStatus // ignore: cast_nullable_to_non_nullable
              as SafetyStatus?,
      contacts: null == contacts
          ? _self._contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<TrustedContact>,
      checkIns: null == checkIns
          ? _self._checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      recentAlerts: null == recentAlerts
          ? _self._recentAlerts
          : recentAlerts // ignore: cast_nullable_to_non_nullable
              as List<SafetyAlert>,
      activeAlerts: null == activeAlerts
          ? _self._activeAlerts
          : activeAlerts // ignore: cast_nullable_to_non_nullable
              as List<SafetyAlert>,
      selectedCheckIn: freezed == selectedCheckIn
          ? _self.selectedCheckIn
          : selectedCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
      selectedAlert: freezed == selectedAlert
          ? _self.selectedAlert
          : selectedAlert // ignore: cast_nullable_to_non_nullable
              as SafetyAlert?,
    ));
  }

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SafetyStatusCopyWith<$Res>? get currentStatus {
    if (_self.currentStatus == null) {
      return null;
    }

    return $SafetyStatusCopyWith<$Res>(_self.currentStatus!, (value) {
      return _then(_self.copyWith(currentStatus: value));
    });
  }

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInCopyWith<$Res>? get selectedCheckIn {
    if (_self.selectedCheckIn == null) {
      return null;
    }

    return $CheckInCopyWith<$Res>(_self.selectedCheckIn!, (value) {
      return _then(_self.copyWith(selectedCheckIn: value));
    });
  }

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SafetyAlertCopyWith<$Res>? get selectedAlert {
    if (_self.selectedAlert == null) {
      return null;
    }

    return $SafetyAlertCopyWith<$Res>(_self.selectedAlert!, (value) {
      return _then(_self.copyWith(selectedAlert: value));
    });
  }
}

// dart format on
