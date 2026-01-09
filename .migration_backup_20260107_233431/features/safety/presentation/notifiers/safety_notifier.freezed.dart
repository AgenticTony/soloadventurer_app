// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SafetyData {
  SafetyStatus? get currentStatus;
  List<SafetyAlert> get recentAlerts;
  List<SafetyAlert> get activeAlerts;
  int get trustedContactsCount;

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SafetyDataCopyWith<SafetyData> get copyWith =>
      _$SafetyDataCopyWithImpl<SafetyData>(this as SafetyData, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SafetyData &&
            (identical(other.currentStatus, currentStatus) ||
                other.currentStatus == currentStatus) &&
            const DeepCollectionEquality()
                .equals(other.recentAlerts, recentAlerts) &&
            const DeepCollectionEquality()
                .equals(other.activeAlerts, activeAlerts) &&
            (identical(other.trustedContactsCount, trustedContactsCount) ||
                other.trustedContactsCount == trustedContactsCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStatus,
      const DeepCollectionEquality().hash(recentAlerts),
      const DeepCollectionEquality().hash(activeAlerts),
      trustedContactsCount);

  @override
  String toString() {
    return 'SafetyData(currentStatus: $currentStatus, recentAlerts: $recentAlerts, activeAlerts: $activeAlerts, trustedContactsCount: $trustedContactsCount)';
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
      List<SafetyAlert> recentAlerts,
      List<SafetyAlert> activeAlerts,
      int trustedContactsCount});

  $SafetyStatusCopyWith<$Res>? get currentStatus;
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
    Object? recentAlerts = null,
    Object? activeAlerts = null,
    Object? trustedContactsCount = null,
  }) {
    return _then(_self.copyWith(
      currentStatus: freezed == currentStatus
          ? _self.currentStatus
          : currentStatus // ignore: cast_nullable_to_non_nullable
              as SafetyStatus?,
      recentAlerts: null == recentAlerts
          ? _self.recentAlerts
          : recentAlerts // ignore: cast_nullable_to_non_nullable
              as List<SafetyAlert>,
      activeAlerts: null == activeAlerts
          ? _self.activeAlerts
          : activeAlerts // ignore: cast_nullable_to_non_nullable
              as List<SafetyAlert>,
      trustedContactsCount: null == trustedContactsCount
          ? _self.trustedContactsCount
          : trustedContactsCount // ignore: cast_nullable_to_non_nullable
              as int,
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
      case _:
        throw StateError('Unexpected subclass');
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
            List<SafetyAlert> recentAlerts,
            List<SafetyAlert> activeAlerts,
            int trustedContactsCount)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyData() when $default != null:
        return $default(_that.currentStatus, _that.recentAlerts,
            _that.activeAlerts, _that.trustedContactsCount);
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
            List<SafetyAlert> recentAlerts,
            List<SafetyAlert> activeAlerts,
            int trustedContactsCount)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyData():
        return $default(_that.currentStatus, _that.recentAlerts,
            _that.activeAlerts, _that.trustedContactsCount);
      case _:
        throw StateError('Unexpected subclass');
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
            List<SafetyAlert> recentAlerts,
            List<SafetyAlert> activeAlerts,
            int trustedContactsCount)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyData() when $default != null:
        return $default(_that.currentStatus, _that.recentAlerts,
            _that.activeAlerts, _that.trustedContactsCount);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SafetyData extends SafetyData {
  const _SafetyData(
      {this.currentStatus,
      final List<SafetyAlert> recentAlerts = const [],
      final List<SafetyAlert> activeAlerts = const [],
      this.trustedContactsCount = 0})
      : _recentAlerts = recentAlerts,
        _activeAlerts = activeAlerts,
        super._();

  @override
  final SafetyStatus? currentStatus;
  final List<SafetyAlert> _recentAlerts;
  @override
  @JsonKey()
  List<SafetyAlert> get recentAlerts {
    if (_recentAlerts is EqualUnmodifiableListView) return _recentAlerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentAlerts);
  }

  final List<SafetyAlert> _activeAlerts;
  @override
  @JsonKey()
  List<SafetyAlert> get activeAlerts {
    if (_activeAlerts is EqualUnmodifiableListView) return _activeAlerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeAlerts);
  }

  @override
  @JsonKey()
  final int trustedContactsCount;

  /// Create a copy of SafetyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SafetyDataCopyWith<_SafetyData> get copyWith =>
      __$SafetyDataCopyWithImpl<_SafetyData>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SafetyData &&
            (identical(other.currentStatus, currentStatus) ||
                other.currentStatus == currentStatus) &&
            const DeepCollectionEquality()
                .equals(other._recentAlerts, _recentAlerts) &&
            const DeepCollectionEquality()
                .equals(other._activeAlerts, _activeAlerts) &&
            (identical(other.trustedContactsCount, trustedContactsCount) ||
                other.trustedContactsCount == trustedContactsCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStatus,
      const DeepCollectionEquality().hash(_recentAlerts),
      const DeepCollectionEquality().hash(_activeAlerts),
      trustedContactsCount);

  @override
  String toString() {
    return 'SafetyData(currentStatus: $currentStatus, recentAlerts: $recentAlerts, activeAlerts: $activeAlerts, trustedContactsCount: $trustedContactsCount)';
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
      List<SafetyAlert> recentAlerts,
      List<SafetyAlert> activeAlerts,
      int trustedContactsCount});

  @override
  $SafetyStatusCopyWith<$Res>? get currentStatus;
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
    Object? recentAlerts = null,
    Object? activeAlerts = null,
    Object? trustedContactsCount = null,
  }) {
    return _then(_SafetyData(
      currentStatus: freezed == currentStatus
          ? _self.currentStatus
          : currentStatus // ignore: cast_nullable_to_non_nullable
              as SafetyStatus?,
      recentAlerts: null == recentAlerts
          ? _self._recentAlerts
          : recentAlerts // ignore: cast_nullable_to_non_nullable
              as List<SafetyAlert>,
      activeAlerts: null == activeAlerts
          ? _self._activeAlerts
          : activeAlerts // ignore: cast_nullable_to_non_nullable
              as List<SafetyAlert>,
      trustedContactsCount: null == trustedContactsCount
          ? _self.trustedContactsCount
          : trustedContactsCount // ignore: cast_nullable_to_non_nullable
              as int,
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
}

// dart format on
