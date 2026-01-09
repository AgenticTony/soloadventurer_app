// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_sharing_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationSharingData {
  List<LocationUpdate> get locationUpdates;
  List<LocationUpdate> get activeShares;
  LocationUpdate? get latestLocation;

  /// Create a copy of LocationSharingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LocationSharingDataCopyWith<LocationSharingData> get copyWith =>
      _$LocationSharingDataCopyWithImpl<LocationSharingData>(
          this as LocationSharingData, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LocationSharingData &&
            const DeepCollectionEquality()
                .equals(other.locationUpdates, locationUpdates) &&
            const DeepCollectionEquality()
                .equals(other.activeShares, activeShares) &&
            (identical(other.latestLocation, latestLocation) ||
                other.latestLocation == latestLocation));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(locationUpdates),
      const DeepCollectionEquality().hash(activeShares),
      latestLocation);

  @override
  String toString() {
    return 'LocationSharingData(locationUpdates: $locationUpdates, activeShares: $activeShares, latestLocation: $latestLocation)';
  }
}

/// @nodoc
abstract mixin class $LocationSharingDataCopyWith<$Res> {
  factory $LocationSharingDataCopyWith(
          LocationSharingData value, $Res Function(LocationSharingData) _then) =
      _$LocationSharingDataCopyWithImpl;
  @useResult
  $Res call(
      {List<LocationUpdate> locationUpdates,
      List<LocationUpdate> activeShares,
      LocationUpdate? latestLocation});

  $LocationUpdateCopyWith<$Res>? get latestLocation;
}

/// @nodoc
class _$LocationSharingDataCopyWithImpl<$Res>
    implements $LocationSharingDataCopyWith<$Res> {
  _$LocationSharingDataCopyWithImpl(this._self, this._then);

  final LocationSharingData _self;
  final $Res Function(LocationSharingData) _then;

  /// Create a copy of LocationSharingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locationUpdates = null,
    Object? activeShares = null,
    Object? latestLocation = freezed,
  }) {
    return _then(_self.copyWith(
      locationUpdates: null == locationUpdates
          ? _self.locationUpdates
          : locationUpdates // ignore: cast_nullable_to_non_nullable
              as List<LocationUpdate>,
      activeShares: null == activeShares
          ? _self.activeShares
          : activeShares // ignore: cast_nullable_to_non_nullable
              as List<LocationUpdate>,
      latestLocation: freezed == latestLocation
          ? _self.latestLocation
          : latestLocation // ignore: cast_nullable_to_non_nullable
              as LocationUpdate?,
    ));
  }

  /// Create a copy of LocationSharingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationUpdateCopyWith<$Res>? get latestLocation {
    if (_self.latestLocation == null) {
      return null;
    }

    return $LocationUpdateCopyWith<$Res>(_self.latestLocation!, (value) {
      return _then(_self.copyWith(latestLocation: value));
    });
  }
}

/// Adds pattern-matching-related methods to [LocationSharingData].
extension LocationSharingDataPatterns on LocationSharingData {
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
    TResult Function(_LocationSharingData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationSharingData() when $default != null:
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
    TResult Function(_LocationSharingData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationSharingData():
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
    TResult? Function(_LocationSharingData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationSharingData() when $default != null:
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
    TResult Function(List<LocationUpdate> locationUpdates,
            List<LocationUpdate> activeShares, LocationUpdate? latestLocation)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationSharingData() when $default != null:
        return $default(
            _that.locationUpdates, _that.activeShares, _that.latestLocation);
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
    TResult Function(List<LocationUpdate> locationUpdates,
            List<LocationUpdate> activeShares, LocationUpdate? latestLocation)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationSharingData():
        return $default(
            _that.locationUpdates, _that.activeShares, _that.latestLocation);
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
    TResult? Function(List<LocationUpdate> locationUpdates,
            List<LocationUpdate> activeShares, LocationUpdate? latestLocation)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationSharingData() when $default != null:
        return $default(
            _that.locationUpdates, _that.activeShares, _that.latestLocation);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LocationSharingData extends LocationSharingData {
  const _LocationSharingData(
      {final List<LocationUpdate> locationUpdates = const [],
      final List<LocationUpdate> activeShares = const [],
      this.latestLocation})
      : _locationUpdates = locationUpdates,
        _activeShares = activeShares,
        super._();

  final List<LocationUpdate> _locationUpdates;
  @override
  @JsonKey()
  List<LocationUpdate> get locationUpdates {
    if (_locationUpdates is EqualUnmodifiableListView) return _locationUpdates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_locationUpdates);
  }

  final List<LocationUpdate> _activeShares;
  @override
  @JsonKey()
  List<LocationUpdate> get activeShares {
    if (_activeShares is EqualUnmodifiableListView) return _activeShares;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeShares);
  }

  @override
  final LocationUpdate? latestLocation;

  /// Create a copy of LocationSharingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LocationSharingDataCopyWith<_LocationSharingData> get copyWith =>
      __$LocationSharingDataCopyWithImpl<_LocationSharingData>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LocationSharingData &&
            const DeepCollectionEquality()
                .equals(other._locationUpdates, _locationUpdates) &&
            const DeepCollectionEquality()
                .equals(other._activeShares, _activeShares) &&
            (identical(other.latestLocation, latestLocation) ||
                other.latestLocation == latestLocation));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_locationUpdates),
      const DeepCollectionEquality().hash(_activeShares),
      latestLocation);

  @override
  String toString() {
    return 'LocationSharingData(locationUpdates: $locationUpdates, activeShares: $activeShares, latestLocation: $latestLocation)';
  }
}

/// @nodoc
abstract mixin class _$LocationSharingDataCopyWith<$Res>
    implements $LocationSharingDataCopyWith<$Res> {
  factory _$LocationSharingDataCopyWith(_LocationSharingData value,
          $Res Function(_LocationSharingData) _then) =
      __$LocationSharingDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<LocationUpdate> locationUpdates,
      List<LocationUpdate> activeShares,
      LocationUpdate? latestLocation});

  @override
  $LocationUpdateCopyWith<$Res>? get latestLocation;
}

/// @nodoc
class __$LocationSharingDataCopyWithImpl<$Res>
    implements _$LocationSharingDataCopyWith<$Res> {
  __$LocationSharingDataCopyWithImpl(this._self, this._then);

  final _LocationSharingData _self;
  final $Res Function(_LocationSharingData) _then;

  /// Create a copy of LocationSharingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? locationUpdates = null,
    Object? activeShares = null,
    Object? latestLocation = freezed,
  }) {
    return _then(_LocationSharingData(
      locationUpdates: null == locationUpdates
          ? _self._locationUpdates
          : locationUpdates // ignore: cast_nullable_to_non_nullable
              as List<LocationUpdate>,
      activeShares: null == activeShares
          ? _self._activeShares
          : activeShares // ignore: cast_nullable_to_non_nullable
              as List<LocationUpdate>,
      latestLocation: freezed == latestLocation
          ? _self.latestLocation
          : latestLocation // ignore: cast_nullable_to_non_nullable
              as LocationUpdate?,
    ));
  }

  /// Create a copy of LocationSharingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationUpdateCopyWith<$Res>? get latestLocation {
    if (_self.latestLocation == null) {
      return null;
    }

    return $LocationUpdateCopyWith<$Res>(_self.latestLocation!, (value) {
      return _then(_self.copyWith(latestLocation: value));
    });
  }
}

// dart format on
