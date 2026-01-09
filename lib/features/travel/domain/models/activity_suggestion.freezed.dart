// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ActivitySuggestion {
  PlaceActivity get activity => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;

  /// Create a copy of ActivitySuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivitySuggestionCopyWith<ActivitySuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivitySuggestionCopyWith<$Res> {
  factory $ActivitySuggestionCopyWith(
          ActivitySuggestion value, $Res Function(ActivitySuggestion) then) =
      _$ActivitySuggestionCopyWithImpl<$Res, ActivitySuggestion>;
  @useResult
  $Res call({PlaceActivity activity, String reason, double score});

  $PlaceActivityCopyWith<$Res> get activity;
}

/// @nodoc
class _$ActivitySuggestionCopyWithImpl<$Res, $Val extends ActivitySuggestion>
    implements $ActivitySuggestionCopyWith<$Res> {
  _$ActivitySuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivitySuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activity = null,
    Object? reason = null,
    Object? score = null,
  }) {
    return _then(_value.copyWith(
      activity: null == activity
          ? _value.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as PlaceActivity,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }

  /// Create a copy of ActivitySuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlaceActivityCopyWith<$Res> get activity {
    return $PlaceActivityCopyWith<$Res>(_value.activity, (value) {
      return _then(_value.copyWith(activity: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ActivitySuggestionImplCopyWith<$Res>
    implements $ActivitySuggestionCopyWith<$Res> {
  factory _$$ActivitySuggestionImplCopyWith(_$ActivitySuggestionImpl value,
          $Res Function(_$ActivitySuggestionImpl) then) =
      __$$ActivitySuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PlaceActivity activity, String reason, double score});

  @override
  $PlaceActivityCopyWith<$Res> get activity;
}

/// @nodoc
class __$$ActivitySuggestionImplCopyWithImpl<$Res>
    extends _$ActivitySuggestionCopyWithImpl<$Res, _$ActivitySuggestionImpl>
    implements _$$ActivitySuggestionImplCopyWith<$Res> {
  __$$ActivitySuggestionImplCopyWithImpl(_$ActivitySuggestionImpl _value,
      $Res Function(_$ActivitySuggestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivitySuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activity = null,
    Object? reason = null,
    Object? score = null,
  }) {
    return _then(_$ActivitySuggestionImpl(
      activity: null == activity
          ? _value.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as PlaceActivity,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$ActivitySuggestionImpl extends _ActivitySuggestion {
  const _$ActivitySuggestionImpl(
      {required this.activity, required this.reason, required this.score})
      : super._();

  @override
  final PlaceActivity activity;
  @override
  final String reason;
  @override
  final double score;

  @override
  String toString() {
    return 'ActivitySuggestion(activity: $activity, reason: $reason, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivitySuggestionImpl &&
            (identical(other.activity, activity) ||
                other.activity == activity) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.score, score) || other.score == score));
  }

  @override
  int get hashCode => Object.hash(runtimeType, activity, reason, score);

  /// Create a copy of ActivitySuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivitySuggestionImplCopyWith<_$ActivitySuggestionImpl> get copyWith =>
      __$$ActivitySuggestionImplCopyWithImpl<_$ActivitySuggestionImpl>(
          this, _$identity);
}

abstract class _ActivitySuggestion extends ActivitySuggestion {
  const factory _ActivitySuggestion(
      {required final PlaceActivity activity,
      required final String reason,
      required final double score}) = _$ActivitySuggestionImpl;
  const _ActivitySuggestion._() : super._();

  @override
  PlaceActivity get activity;
  @override
  String get reason;
  @override
  double get score;

  /// Create a copy of ActivitySuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivitySuggestionImplCopyWith<_$ActivitySuggestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
