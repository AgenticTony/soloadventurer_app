// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActivitySuggestion {
  PlaceActivity get activity;
  String get reason;
  double get score;

  /// Create a copy of ActivitySuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ActivitySuggestionCopyWith<ActivitySuggestion> get copyWith =>
      _$ActivitySuggestionCopyWithImpl<ActivitySuggestion>(
          this as ActivitySuggestion, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ActivitySuggestion &&
            (identical(other.activity, activity) ||
                other.activity == activity) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.score, score) || other.score == score));
  }

  @override
  int get hashCode => Object.hash(runtimeType, activity, reason, score);

  @override
  String toString() {
    return 'ActivitySuggestion(activity: $activity, reason: $reason, score: $score)';
  }
}

/// @nodoc
abstract mixin class $ActivitySuggestionCopyWith<$Res> {
  factory $ActivitySuggestionCopyWith(
          ActivitySuggestion value, $Res Function(ActivitySuggestion) _then) =
      _$ActivitySuggestionCopyWithImpl;
  @useResult
  $Res call({PlaceActivity activity, String reason, double score});

  $PlaceActivityCopyWith<$Res> get activity;
}

/// @nodoc
class _$ActivitySuggestionCopyWithImpl<$Res>
    implements $ActivitySuggestionCopyWith<$Res> {
  _$ActivitySuggestionCopyWithImpl(this._self, this._then);

  final ActivitySuggestion _self;
  final $Res Function(ActivitySuggestion) _then;

  /// Create a copy of ActivitySuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activity = null,
    Object? reason = null,
    Object? score = null,
  }) {
    return _then(_self.copyWith(
      activity: null == activity
          ? _self.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as PlaceActivity,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }

  /// Create a copy of ActivitySuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlaceActivityCopyWith<$Res> get activity {
    return $PlaceActivityCopyWith<$Res>(_self.activity, (value) {
      return _then(_self.copyWith(activity: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ActivitySuggestion].
extension ActivitySuggestionPatterns on ActivitySuggestion {
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
    TResult Function(_ActivitySuggestion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActivitySuggestion() when $default != null:
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
    TResult Function(_ActivitySuggestion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivitySuggestion():
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
    TResult? Function(_ActivitySuggestion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivitySuggestion() when $default != null:
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
    TResult Function(PlaceActivity activity, String reason, double score)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActivitySuggestion() when $default != null:
        return $default(_that.activity, _that.reason, _that.score);
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
    TResult Function(PlaceActivity activity, String reason, double score)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivitySuggestion():
        return $default(_that.activity, _that.reason, _that.score);
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
    TResult? Function(PlaceActivity activity, String reason, double score)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivitySuggestion() when $default != null:
        return $default(_that.activity, _that.reason, _that.score);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ActivitySuggestion extends ActivitySuggestion {
  const _ActivitySuggestion(
      {required this.activity, required this.reason, required this.score})
      : super._();

  @override
  final PlaceActivity activity;
  @override
  final String reason;
  @override
  final double score;

  /// Create a copy of ActivitySuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ActivitySuggestionCopyWith<_ActivitySuggestion> get copyWith =>
      __$ActivitySuggestionCopyWithImpl<_ActivitySuggestion>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ActivitySuggestion &&
            (identical(other.activity, activity) ||
                other.activity == activity) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.score, score) || other.score == score));
  }

  @override
  int get hashCode => Object.hash(runtimeType, activity, reason, score);

  @override
  String toString() {
    return 'ActivitySuggestion(activity: $activity, reason: $reason, score: $score)';
  }
}

/// @nodoc
abstract mixin class _$ActivitySuggestionCopyWith<$Res>
    implements $ActivitySuggestionCopyWith<$Res> {
  factory _$ActivitySuggestionCopyWith(
          _ActivitySuggestion value, $Res Function(_ActivitySuggestion) _then) =
      __$ActivitySuggestionCopyWithImpl;
  @override
  @useResult
  $Res call({PlaceActivity activity, String reason, double score});

  @override
  $PlaceActivityCopyWith<$Res> get activity;
}

/// @nodoc
class __$ActivitySuggestionCopyWithImpl<$Res>
    implements _$ActivitySuggestionCopyWith<$Res> {
  __$ActivitySuggestionCopyWithImpl(this._self, this._then);

  final _ActivitySuggestion _self;
  final $Res Function(_ActivitySuggestion) _then;

  /// Create a copy of ActivitySuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? activity = null,
    Object? reason = null,
    Object? score = null,
  }) {
    return _then(_ActivitySuggestion(
      activity: null == activity
          ? _self.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as PlaceActivity,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }

  /// Create a copy of ActivitySuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlaceActivityCopyWith<$Res> get activity {
    return $PlaceActivityCopyWith<$Res>(_self.activity, (value) {
      return _then(_self.copyWith(activity: value));
    });
  }
}

// dart format on
