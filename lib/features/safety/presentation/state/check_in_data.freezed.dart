// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckInData {
  List<CheckIn> get checkIns;
  List<CheckIn> get upcomingCheckIns;
  CheckIn? get selectedCheckIn;

  /// Create a copy of CheckInData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CheckInDataCopyWith<CheckInData> get copyWith =>
      _$CheckInDataCopyWithImpl<CheckInData>(this as CheckInData, _$identity);

  /// Serializes this CheckInData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CheckInData &&
            const DeepCollectionEquality().equals(other.checkIns, checkIns) &&
            const DeepCollectionEquality()
                .equals(other.upcomingCheckIns, upcomingCheckIns) &&
            (identical(other.selectedCheckIn, selectedCheckIn) ||
                other.selectedCheckIn == selectedCheckIn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(checkIns),
      const DeepCollectionEquality().hash(upcomingCheckIns),
      selectedCheckIn);

  @override
  String toString() {
    return 'CheckInData(checkIns: $checkIns, upcomingCheckIns: $upcomingCheckIns, selectedCheckIn: $selectedCheckIn)';
  }
}

/// @nodoc
abstract mixin class $CheckInDataCopyWith<$Res> {
  factory $CheckInDataCopyWith(
          CheckInData value, $Res Function(CheckInData) _then) =
      _$CheckInDataCopyWithImpl;
  @useResult
  $Res call(
      {List<CheckIn> checkIns,
      List<CheckIn> upcomingCheckIns,
      CheckIn? selectedCheckIn});

  $CheckInCopyWith<$Res>? get selectedCheckIn;
}

/// @nodoc
class _$CheckInDataCopyWithImpl<$Res> implements $CheckInDataCopyWith<$Res> {
  _$CheckInDataCopyWithImpl(this._self, this._then);

  final CheckInData _self;
  final $Res Function(CheckInData) _then;

  /// Create a copy of CheckInData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? checkIns = null,
    Object? upcomingCheckIns = null,
    Object? selectedCheckIn = freezed,
  }) {
    return _then(_self.copyWith(
      checkIns: null == checkIns
          ? _self.checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      upcomingCheckIns: null == upcomingCheckIns
          ? _self.upcomingCheckIns
          : upcomingCheckIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      selectedCheckIn: freezed == selectedCheckIn
          ? _self.selectedCheckIn
          : selectedCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
    ));
  }

  /// Create a copy of CheckInData
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
}

/// Adds pattern-matching-related methods to [CheckInData].
extension CheckInDataPatterns on CheckInData {
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
    TResult Function(_CheckInData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckInData() when $default != null:
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
    TResult Function(_CheckInData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInData():
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
    TResult? Function(_CheckInData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInData() when $default != null:
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
    TResult Function(List<CheckIn> checkIns, List<CheckIn> upcomingCheckIns,
            CheckIn? selectedCheckIn)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckInData() when $default != null:
        return $default(
            _that.checkIns, _that.upcomingCheckIns, _that.selectedCheckIn);
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
    TResult Function(List<CheckIn> checkIns, List<CheckIn> upcomingCheckIns,
            CheckIn? selectedCheckIn)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInData():
        return $default(
            _that.checkIns, _that.upcomingCheckIns, _that.selectedCheckIn);
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
    TResult? Function(List<CheckIn> checkIns, List<CheckIn> upcomingCheckIns,
            CheckIn? selectedCheckIn)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInData() when $default != null:
        return $default(
            _that.checkIns, _that.upcomingCheckIns, _that.selectedCheckIn);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CheckInData extends CheckInData {
  const _CheckInData(
      {final List<CheckIn> checkIns = const [],
      final List<CheckIn> upcomingCheckIns = const [],
      this.selectedCheckIn})
      : _checkIns = checkIns,
        _upcomingCheckIns = upcomingCheckIns,
        super._();
  factory _CheckInData.fromJson(Map<String, dynamic> json) =>
      _$CheckInDataFromJson(json);

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

  /// Create a copy of CheckInData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CheckInDataCopyWith<_CheckInData> get copyWith =>
      __$CheckInDataCopyWithImpl<_CheckInData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CheckInDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CheckInData &&
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

  @override
  String toString() {
    return 'CheckInData(checkIns: $checkIns, upcomingCheckIns: $upcomingCheckIns, selectedCheckIn: $selectedCheckIn)';
  }
}

/// @nodoc
abstract mixin class _$CheckInDataCopyWith<$Res>
    implements $CheckInDataCopyWith<$Res> {
  factory _$CheckInDataCopyWith(
          _CheckInData value, $Res Function(_CheckInData) _then) =
      __$CheckInDataCopyWithImpl;
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
class __$CheckInDataCopyWithImpl<$Res> implements _$CheckInDataCopyWith<$Res> {
  __$CheckInDataCopyWithImpl(this._self, this._then);

  final _CheckInData _self;
  final $Res Function(_CheckInData) _then;

  /// Create a copy of CheckInData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? checkIns = null,
    Object? upcomingCheckIns = null,
    Object? selectedCheckIn = freezed,
  }) {
    return _then(_CheckInData(
      checkIns: null == checkIns
          ? _self._checkIns
          : checkIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      upcomingCheckIns: null == upcomingCheckIns
          ? _self._upcomingCheckIns
          : upcomingCheckIns // ignore: cast_nullable_to_non_nullable
              as List<CheckIn>,
      selectedCheckIn: freezed == selectedCheckIn
          ? _self.selectedCheckIn
          : selectedCheckIn // ignore: cast_nullable_to_non_nullable
              as CheckIn?,
    ));
  }

  /// Create a copy of CheckInData
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
}

// dart format on
