// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_forecast.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeatherForecast {
  DateTime get date;
  double get temperatureMin;
  double get temperatureMax;
  String get condition;
  String? get iconCode;
  int? get humidity;
  int? get precipitationProbability;
  double? get windSpeed;
  String? get description;

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WeatherForecastCopyWith<WeatherForecast> get copyWith =>
      _$WeatherForecastCopyWithImpl<WeatherForecast>(
          this as WeatherForecast, _$identity);

  /// Serializes this WeatherForecast to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WeatherForecast &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.temperatureMin, temperatureMin) ||
                other.temperatureMin == temperatureMin) &&
            (identical(other.temperatureMax, temperatureMax) ||
                other.temperatureMax == temperatureMax) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.iconCode, iconCode) ||
                other.iconCode == iconCode) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(
                    other.precipitationProbability, precipitationProbability) ||
                other.precipitationProbability == precipitationProbability) &&
            (identical(other.windSpeed, windSpeed) ||
                other.windSpeed == windSpeed) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      temperatureMin,
      temperatureMax,
      condition,
      iconCode,
      humidity,
      precipitationProbability,
      windSpeed,
      description);

  @override
  String toString() {
    return 'WeatherForecast(date: $date, temperatureMin: $temperatureMin, temperatureMax: $temperatureMax, condition: $condition, iconCode: $iconCode, humidity: $humidity, precipitationProbability: $precipitationProbability, windSpeed: $windSpeed, description: $description)';
  }
}

/// @nodoc
abstract mixin class $WeatherForecastCopyWith<$Res> {
  factory $WeatherForecastCopyWith(
          WeatherForecast value, $Res Function(WeatherForecast) _then) =
      _$WeatherForecastCopyWithImpl;
  @useResult
  $Res call(
      {DateTime date,
      double temperatureMin,
      double temperatureMax,
      String condition,
      String? iconCode,
      int? humidity,
      int? precipitationProbability,
      double? windSpeed,
      String? description});
}

/// @nodoc
class _$WeatherForecastCopyWithImpl<$Res>
    implements $WeatherForecastCopyWith<$Res> {
  _$WeatherForecastCopyWithImpl(this._self, this._then);

  final WeatherForecast _self;
  final $Res Function(WeatherForecast) _then;

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? temperatureMin = null,
    Object? temperatureMax = null,
    Object? condition = null,
    Object? iconCode = freezed,
    Object? humidity = freezed,
    Object? precipitationProbability = freezed,
    Object? windSpeed = freezed,
    Object? description = freezed,
  }) {
    return _then(_self.copyWith(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      temperatureMin: null == temperatureMin
          ? _self.temperatureMin
          : temperatureMin // ignore: cast_nullable_to_non_nullable
              as double,
      temperatureMax: null == temperatureMax
          ? _self.temperatureMax
          : temperatureMax // ignore: cast_nullable_to_non_nullable
              as double,
      condition: null == condition
          ? _self.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      iconCode: freezed == iconCode
          ? _self.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as String?,
      humidity: freezed == humidity
          ? _self.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as int?,
      precipitationProbability: freezed == precipitationProbability
          ? _self.precipitationProbability
          : precipitationProbability // ignore: cast_nullable_to_non_nullable
              as int?,
      windSpeed: freezed == windSpeed
          ? _self.windSpeed
          : windSpeed // ignore: cast_nullable_to_non_nullable
              as double?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [WeatherForecast].
extension WeatherForecastPatterns on WeatherForecast {
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
    TResult Function(_WeatherForecast value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WeatherForecast() when $default != null:
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
    TResult Function(_WeatherForecast value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WeatherForecast():
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
    TResult? Function(_WeatherForecast value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WeatherForecast() when $default != null:
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
            DateTime date,
            double temperatureMin,
            double temperatureMax,
            String condition,
            String? iconCode,
            int? humidity,
            int? precipitationProbability,
            double? windSpeed,
            String? description)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WeatherForecast() when $default != null:
        return $default(
            _that.date,
            _that.temperatureMin,
            _that.temperatureMax,
            _that.condition,
            _that.iconCode,
            _that.humidity,
            _that.precipitationProbability,
            _that.windSpeed,
            _that.description);
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
            DateTime date,
            double temperatureMin,
            double temperatureMax,
            String condition,
            String? iconCode,
            int? humidity,
            int? precipitationProbability,
            double? windSpeed,
            String? description)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WeatherForecast():
        return $default(
            _that.date,
            _that.temperatureMin,
            _that.temperatureMax,
            _that.condition,
            _that.iconCode,
            _that.humidity,
            _that.precipitationProbability,
            _that.windSpeed,
            _that.description);
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
            DateTime date,
            double temperatureMin,
            double temperatureMax,
            String condition,
            String? iconCode,
            int? humidity,
            int? precipitationProbability,
            double? windSpeed,
            String? description)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WeatherForecast() when $default != null:
        return $default(
            _that.date,
            _that.temperatureMin,
            _that.temperatureMax,
            _that.condition,
            _that.iconCode,
            _that.humidity,
            _that.precipitationProbability,
            _that.windSpeed,
            _that.description);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WeatherForecast implements WeatherForecast {
  const _WeatherForecast(
      {required this.date,
      required this.temperatureMin,
      required this.temperatureMax,
      required this.condition,
      this.iconCode,
      this.humidity,
      this.precipitationProbability,
      this.windSpeed,
      this.description});
  factory _WeatherForecast.fromJson(Map<String, dynamic> json) =>
      _$WeatherForecastFromJson(json);

  @override
  final DateTime date;
  @override
  final double temperatureMin;
  @override
  final double temperatureMax;
  @override
  final String condition;
  @override
  final String? iconCode;
  @override
  final int? humidity;
  @override
  final int? precipitationProbability;
  @override
  final double? windSpeed;
  @override
  final String? description;

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WeatherForecastCopyWith<_WeatherForecast> get copyWith =>
      __$WeatherForecastCopyWithImpl<_WeatherForecast>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WeatherForecastToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WeatherForecast &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.temperatureMin, temperatureMin) ||
                other.temperatureMin == temperatureMin) &&
            (identical(other.temperatureMax, temperatureMax) ||
                other.temperatureMax == temperatureMax) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.iconCode, iconCode) ||
                other.iconCode == iconCode) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(
                    other.precipitationProbability, precipitationProbability) ||
                other.precipitationProbability == precipitationProbability) &&
            (identical(other.windSpeed, windSpeed) ||
                other.windSpeed == windSpeed) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      temperatureMin,
      temperatureMax,
      condition,
      iconCode,
      humidity,
      precipitationProbability,
      windSpeed,
      description);

  @override
  String toString() {
    return 'WeatherForecast(date: $date, temperatureMin: $temperatureMin, temperatureMax: $temperatureMax, condition: $condition, iconCode: $iconCode, humidity: $humidity, precipitationProbability: $precipitationProbability, windSpeed: $windSpeed, description: $description)';
  }
}

/// @nodoc
abstract mixin class _$WeatherForecastCopyWith<$Res>
    implements $WeatherForecastCopyWith<$Res> {
  factory _$WeatherForecastCopyWith(
          _WeatherForecast value, $Res Function(_WeatherForecast) _then) =
      __$WeatherForecastCopyWithImpl;
  @override
  @useResult
  $Res call(
      {DateTime date,
      double temperatureMin,
      double temperatureMax,
      String condition,
      String? iconCode,
      int? humidity,
      int? precipitationProbability,
      double? windSpeed,
      String? description});
}

/// @nodoc
class __$WeatherForecastCopyWithImpl<$Res>
    implements _$WeatherForecastCopyWith<$Res> {
  __$WeatherForecastCopyWithImpl(this._self, this._then);

  final _WeatherForecast _self;
  final $Res Function(_WeatherForecast) _then;

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? date = null,
    Object? temperatureMin = null,
    Object? temperatureMax = null,
    Object? condition = null,
    Object? iconCode = freezed,
    Object? humidity = freezed,
    Object? precipitationProbability = freezed,
    Object? windSpeed = freezed,
    Object? description = freezed,
  }) {
    return _then(_WeatherForecast(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      temperatureMin: null == temperatureMin
          ? _self.temperatureMin
          : temperatureMin // ignore: cast_nullable_to_non_nullable
              as double,
      temperatureMax: null == temperatureMax
          ? _self.temperatureMax
          : temperatureMax // ignore: cast_nullable_to_non_nullable
              as double,
      condition: null == condition
          ? _self.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      iconCode: freezed == iconCode
          ? _self.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as String?,
      humidity: freezed == humidity
          ? _self.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as int?,
      precipitationProbability: freezed == precipitationProbability
          ? _self.precipitationProbability
          : precipitationProbability // ignore: cast_nullable_to_non_nullable
              as int?,
      windSpeed: freezed == windSpeed
          ? _self.windSpeed
          : windSpeed // ignore: cast_nullable_to_non_nullable
              as double?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
