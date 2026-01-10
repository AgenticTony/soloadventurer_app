// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'destination.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Destination {
  String get placeId;
  String get name;
  String? get description;
  double get latitude;
  double get longitude;
  String? get airportCode;
  String? get country;
  String? get city;
  String? get imageUrl;

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<Destination> get copyWith =>
      _$DestinationCopyWithImpl<Destination>(this as Destination, _$identity);

  /// Serializes this Destination to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Destination &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.airportCode, airportCode) ||
                other.airportCode == airportCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, placeId, name, description,
      latitude, longitude, airportCode, country, city, imageUrl);

  @override
  String toString() {
    return 'Destination(placeId: $placeId, name: $name, description: $description, latitude: $latitude, longitude: $longitude, airportCode: $airportCode, country: $country, city: $city, imageUrl: $imageUrl)';
  }
}

/// @nodoc
abstract mixin class $DestinationCopyWith<$Res> {
  factory $DestinationCopyWith(
          Destination value, $Res Function(Destination) _then) =
      _$DestinationCopyWithImpl;
  @useResult
  $Res call(
      {String placeId,
      String name,
      String? description,
      double latitude,
      double longitude,
      String? airportCode,
      String? country,
      String? city,
      String? imageUrl});
}

/// @nodoc
class _$DestinationCopyWithImpl<$Res> implements $DestinationCopyWith<$Res> {
  _$DestinationCopyWithImpl(this._self, this._then);

  final Destination _self;
  final $Res Function(Destination) _then;

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placeId = null,
    Object? name = null,
    Object? description = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? airportCode = freezed,
    Object? country = freezed,
    Object? city = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_self.copyWith(
      placeId: null == placeId
          ? _self.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      airportCode: freezed == airportCode
          ? _self.airportCode
          : airportCode // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _self.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Destination].
extension DestinationPatterns on Destination {
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
    TResult Function(_Destination value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Destination() when $default != null:
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
    TResult Function(_Destination value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Destination():
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
    TResult? Function(_Destination value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Destination() when $default != null:
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
            String placeId,
            String name,
            String? description,
            double latitude,
            double longitude,
            String? airportCode,
            String? country,
            String? city,
            String? imageUrl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Destination() when $default != null:
        return $default(
            _that.placeId,
            _that.name,
            _that.description,
            _that.latitude,
            _that.longitude,
            _that.airportCode,
            _that.country,
            _that.city,
            _that.imageUrl);
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
            String placeId,
            String name,
            String? description,
            double latitude,
            double longitude,
            String? airportCode,
            String? country,
            String? city,
            String? imageUrl)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Destination():
        return $default(
            _that.placeId,
            _that.name,
            _that.description,
            _that.latitude,
            _that.longitude,
            _that.airportCode,
            _that.country,
            _that.city,
            _that.imageUrl);
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
            String placeId,
            String name,
            String? description,
            double latitude,
            double longitude,
            String? airportCode,
            String? country,
            String? city,
            String? imageUrl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Destination() when $default != null:
        return $default(
            _that.placeId,
            _that.name,
            _that.description,
            _that.latitude,
            _that.longitude,
            _that.airportCode,
            _that.country,
            _that.city,
            _that.imageUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Destination extends Destination {
  const _Destination(
      {required this.placeId,
      required this.name,
      this.description,
      required this.latitude,
      required this.longitude,
      this.airportCode,
      this.country,
      this.city,
      this.imageUrl})
      : super._();
  factory _Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);

  @override
  final String placeId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? airportCode;
  @override
  final String? country;
  @override
  final String? city;
  @override
  final String? imageUrl;

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DestinationCopyWith<_Destination> get copyWith =>
      __$DestinationCopyWithImpl<_Destination>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DestinationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Destination &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.airportCode, airportCode) ||
                other.airportCode == airportCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, placeId, name, description,
      latitude, longitude, airportCode, country, city, imageUrl);

  @override
  String toString() {
    return 'Destination(placeId: $placeId, name: $name, description: $description, latitude: $latitude, longitude: $longitude, airportCode: $airportCode, country: $country, city: $city, imageUrl: $imageUrl)';
  }
}

/// @nodoc
abstract mixin class _$DestinationCopyWith<$Res>
    implements $DestinationCopyWith<$Res> {
  factory _$DestinationCopyWith(
          _Destination value, $Res Function(_Destination) _then) =
      __$DestinationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String placeId,
      String name,
      String? description,
      double latitude,
      double longitude,
      String? airportCode,
      String? country,
      String? city,
      String? imageUrl});
}

/// @nodoc
class __$DestinationCopyWithImpl<$Res> implements _$DestinationCopyWith<$Res> {
  __$DestinationCopyWithImpl(this._self, this._then);

  final _Destination _self;
  final $Res Function(_Destination) _then;

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? placeId = null,
    Object? name = null,
    Object? description = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? airportCode = freezed,
    Object? country = freezed,
    Object? city = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_Destination(
      placeId: null == placeId
          ? _self.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      airportCode: freezed == airportCode
          ? _self.airportCode
          : airportCode // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _self.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
