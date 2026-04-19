// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_sharing_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationSharingState {
  /// Whether location sharing is being started
  bool get isStarting;

  /// Whether location sharing is being stopped
  bool get isStopping;

  /// List of all location updates
  List<LocationUpdate> get locationUpdates;

  /// List of currently active location shares
  List<LocationUpdate> get activeShares;

  /// Most recent location update
  LocationUpdate? get latestLocation;

  /// Create a copy of LocationSharingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LocationSharingStateCopyWith<LocationSharingState> get copyWith =>
      _$LocationSharingStateCopyWithImpl<LocationSharingState>(
          this as LocationSharingState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LocationSharingState &&
            (identical(other.isStarting, isStarting) ||
                other.isStarting == isStarting) &&
            (identical(other.isStopping, isStopping) ||
                other.isStopping == isStopping) &&
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
      isStarting,
      isStopping,
      const DeepCollectionEquality().hash(locationUpdates),
      const DeepCollectionEquality().hash(activeShares),
      latestLocation);

  @override
  String toString() {
    return 'LocationSharingState(isStarting: $isStarting, isStopping: $isStopping, locationUpdates: $locationUpdates, activeShares: $activeShares, latestLocation: $latestLocation)';
  }
}

/// @nodoc
abstract mixin class $LocationSharingStateCopyWith<$Res> {
  factory $LocationSharingStateCopyWith(LocationSharingState value,
          $Res Function(LocationSharingState) _then) =
      _$LocationSharingStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isStarting,
      bool isStopping,
      List<LocationUpdate> locationUpdates,
      List<LocationUpdate> activeShares,
      LocationUpdate? latestLocation});

  $LocationUpdateCopyWith<$Res>? get latestLocation;
}

/// @nodoc
class _$LocationSharingStateCopyWithImpl<$Res>
    implements $LocationSharingStateCopyWith<$Res> {
  _$LocationSharingStateCopyWithImpl(this._self, this._then);

  final LocationSharingState _self;
  final $Res Function(LocationSharingState) _then;

  /// Create a copy of LocationSharingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isStarting = null,
    Object? isStopping = null,
    Object? locationUpdates = null,
    Object? activeShares = null,
    Object? latestLocation = freezed,
  }) {
    return _then(_self.copyWith(
      isStarting: null == isStarting
          ? _self.isStarting
          : isStarting // ignore: cast_nullable_to_non_nullable
              as bool,
      isStopping: null == isStopping
          ? _self.isStopping
          : isStopping // ignore: cast_nullable_to_non_nullable
              as bool,
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

  /// Create a copy of LocationSharingState
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

/// Adds pattern-matching-related methods to [LocationSharingState].
extension LocationSharingStatePatterns on LocationSharingState {
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
    TResult Function(_LocationSharingState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationSharingState() when $default != null:
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
    TResult Function(_LocationSharingState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationSharingState():
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
    TResult? Function(_LocationSharingState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationSharingState() when $default != null:
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
            bool isStarting,
            bool isStopping,
            List<LocationUpdate> locationUpdates,
            List<LocationUpdate> activeShares,
            LocationUpdate? latestLocation)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationSharingState() when $default != null:
        return $default(_that.isStarting, _that.isStopping,
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
    TResult Function(
            bool isStarting,
            bool isStopping,
            List<LocationUpdate> locationUpdates,
            List<LocationUpdate> activeShares,
            LocationUpdate? latestLocation)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationSharingState():
        return $default(_that.isStarting, _that.isStopping,
            _that.locationUpdates, _that.activeShares, _that.latestLocation);
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
            bool isStarting,
            bool isStopping,
            List<LocationUpdate> locationUpdates,
            List<LocationUpdate> activeShares,
            LocationUpdate? latestLocation)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationSharingState() when $default != null:
        return $default(_that.isStarting, _that.isStopping,
            _that.locationUpdates, _that.activeShares, _that.latestLocation);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LocationSharingState extends LocationSharingState {
  const _LocationSharingState(
      {this.isStarting = false,
      this.isStopping = false,
      final List<LocationUpdate> locationUpdates = const [],
      final List<LocationUpdate> activeShares = const [],
      this.latestLocation})
      : _locationUpdates = locationUpdates,
        _activeShares = activeShares,
        super._();

  /// Whether location sharing is being started
  @override
  @JsonKey()
  final bool isStarting;

  /// Whether location sharing is being stopped
  @override
  @JsonKey()
  final bool isStopping;

  /// List of all location updates
  final List<LocationUpdate> _locationUpdates;

  /// List of all location updates
  @override
  @JsonKey()
  List<LocationUpdate> get locationUpdates {
    if (_locationUpdates is EqualUnmodifiableListView) return _locationUpdates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_locationUpdates);
  }

  /// List of currently active location shares
  final List<LocationUpdate> _activeShares;

  /// List of currently active location shares
  @override
  @JsonKey()
  List<LocationUpdate> get activeShares {
    if (_activeShares is EqualUnmodifiableListView) return _activeShares;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeShares);
  }

  /// Most recent location update
  @override
  final LocationUpdate? latestLocation;

  /// Create a copy of LocationSharingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LocationSharingStateCopyWith<_LocationSharingState> get copyWith =>
      __$LocationSharingStateCopyWithImpl<_LocationSharingState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LocationSharingState &&
            (identical(other.isStarting, isStarting) ||
                other.isStarting == isStarting) &&
            (identical(other.isStopping, isStopping) ||
                other.isStopping == isStopping) &&
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
      isStarting,
      isStopping,
      const DeepCollectionEquality().hash(_locationUpdates),
      const DeepCollectionEquality().hash(_activeShares),
      latestLocation);

  @override
  String toString() {
    return 'LocationSharingState(isStarting: $isStarting, isStopping: $isStopping, locationUpdates: $locationUpdates, activeShares: $activeShares, latestLocation: $latestLocation)';
  }
}

/// @nodoc
abstract mixin class _$LocationSharingStateCopyWith<$Res>
    implements $LocationSharingStateCopyWith<$Res> {
  factory _$LocationSharingStateCopyWith(_LocationSharingState value,
          $Res Function(_LocationSharingState) _then) =
      __$LocationSharingStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isStarting,
      bool isStopping,
      List<LocationUpdate> locationUpdates,
      List<LocationUpdate> activeShares,
      LocationUpdate? latestLocation});

  @override
  $LocationUpdateCopyWith<$Res>? get latestLocation;
}

/// @nodoc
class __$LocationSharingStateCopyWithImpl<$Res>
    implements _$LocationSharingStateCopyWith<$Res> {
  __$LocationSharingStateCopyWithImpl(this._self, this._then);

  final _LocationSharingState _self;
  final $Res Function(_LocationSharingState) _then;

  /// Create a copy of LocationSharingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isStarting = null,
    Object? isStopping = null,
    Object? locationUpdates = null,
    Object? activeShares = null,
    Object? latestLocation = freezed,
  }) {
    return _then(_LocationSharingState(
      isStarting: null == isStarting
          ? _self.isStarting
          : isStarting // ignore: cast_nullable_to_non_nullable
              as bool,
      isStopping: null == isStopping
          ? _self.isStopping
          : isStopping // ignore: cast_nullable_to_non_nullable
              as bool,
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

  /// Create a copy of LocationSharingState
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
