// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is OnboardingState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'OnboardingState()';
  }
}

/// @nodoc
class $OnboardingStateCopyWith<$Res> {
  $OnboardingStateCopyWith(
      OnboardingState _, $Res Function(OnboardingState) __);
}

/// Adds pattern-matching-related methods to [OnboardingState].
extension OnboardingStatePatterns on OnboardingState {
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
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnboardingInitial value)? initial,
    TResult Function(OnboardingInProgress value)? inProgress,
    TResult Function(OnboardingSubmitting value)? submitting,
    TResult Function(OnboardingSuccess value)? success,
    TResult Function(OnboardingError value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case OnboardingInitial() when initial != null:
        return initial(_that);
      case OnboardingInProgress() when inProgress != null:
        return inProgress(_that);
      case OnboardingSubmitting() when submitting != null:
        return submitting(_that);
      case OnboardingSuccess() when success != null:
        return success(_that);
      case OnboardingError() when error != null:
        return error(_that);
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
  TResult map<TResult extends Object?>({
    required TResult Function(OnboardingInitial value) initial,
    required TResult Function(OnboardingInProgress value) inProgress,
    required TResult Function(OnboardingSubmitting value) submitting,
    required TResult Function(OnboardingSuccess value) success,
    required TResult Function(OnboardingError value) error,
  }) {
    final _that = this;
    switch (_that) {
      case OnboardingInitial():
        return initial(_that);
      case OnboardingInProgress():
        return inProgress(_that);
      case OnboardingSubmitting():
        return submitting(_that);
      case OnboardingSuccess():
        return success(_that);
      case OnboardingError():
        return error(_that);
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
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OnboardingInitial value)? initial,
    TResult? Function(OnboardingInProgress value)? inProgress,
    TResult? Function(OnboardingSubmitting value)? submitting,
    TResult? Function(OnboardingSuccess value)? success,
    TResult? Function(OnboardingError value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case OnboardingInitial() when initial != null:
        return initial(_that);
      case OnboardingInProgress() when inProgress != null:
        return inProgress(_that);
      case OnboardingSubmitting() when submitting != null:
        return submitting(_that);
      case OnboardingSuccess() when success != null:
        return success(_that);
      case OnboardingError() when error != null:
        return error(_that);
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
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(
            OnboardingData data, bool isValid, List<String> validationErrors)?
        inProgress,
    TResult Function(OnboardingData data)? submitting,
    TResult Function(OnboardingData data, Itinerary itinerary)? success,
    TResult Function(OnboardingData data, String message, String? details)?
        error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case OnboardingInitial() when initial != null:
        return initial();
      case OnboardingInProgress() when inProgress != null:
        return inProgress(_that.data, _that.isValid, _that.validationErrors);
      case OnboardingSubmitting() when submitting != null:
        return submitting(_that.data);
      case OnboardingSuccess() when success != null:
        return success(_that.data, _that.itinerary);
      case OnboardingError() when error != null:
        return error(_that.data, _that.message, _that.details);
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
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(
            OnboardingData data, bool isValid, List<String> validationErrors)
        inProgress,
    required TResult Function(OnboardingData data) submitting,
    required TResult Function(OnboardingData data, Itinerary itinerary) success,
    required TResult Function(
            OnboardingData data, String message, String? details)
        error,
  }) {
    final _that = this;
    switch (_that) {
      case OnboardingInitial():
        return initial();
      case OnboardingInProgress():
        return inProgress(_that.data, _that.isValid, _that.validationErrors);
      case OnboardingSubmitting():
        return submitting(_that.data);
      case OnboardingSuccess():
        return success(_that.data, _that.itinerary);
      case OnboardingError():
        return error(_that.data, _that.message, _that.details);
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
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(
            OnboardingData data, bool isValid, List<String> validationErrors)?
        inProgress,
    TResult? Function(OnboardingData data)? submitting,
    TResult? Function(OnboardingData data, Itinerary itinerary)? success,
    TResult? Function(OnboardingData data, String message, String? details)?
        error,
  }) {
    final _that = this;
    switch (_that) {
      case OnboardingInitial() when initial != null:
        return initial();
      case OnboardingInProgress() when inProgress != null:
        return inProgress(_that.data, _that.isValid, _that.validationErrors);
      case OnboardingSubmitting() when submitting != null:
        return submitting(_that.data);
      case OnboardingSuccess() when success != null:
        return success(_that.data, _that.itinerary);
      case OnboardingError() when error != null:
        return error(_that.data, _that.message, _that.details);
      case _:
        return null;
    }
  }
}

/// @nodoc

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is OnboardingInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'OnboardingState.initial()';
  }
}

/// @nodoc

class OnboardingInProgress extends OnboardingState {
  const OnboardingInProgress(
      {required this.data,
      this.isValid = false,
      final List<String> validationErrors = const <String>[]})
      : _validationErrors = validationErrors,
        super._();

  /// The current onboarding data being filled
  final OnboardingData data;

  /// Whether the current data passes validation
  @JsonKey()
  final bool isValid;

  /// Validation errors for the current data
  final List<String> _validationErrors;

  /// Validation errors for the current data
  @JsonKey()
  List<String> get validationErrors {
    if (_validationErrors is EqualUnmodifiableListView)
      return _validationErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_validationErrors);
  }

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OnboardingInProgressCopyWith<OnboardingInProgress> get copyWith =>
      _$OnboardingInProgressCopyWithImpl<OnboardingInProgress>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnboardingInProgress &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            const DeepCollectionEquality()
                .equals(other._validationErrors, _validationErrors));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data, isValid,
      const DeepCollectionEquality().hash(_validationErrors));

  @override
  String toString() {
    return 'OnboardingState.inProgress(data: $data, isValid: $isValid, validationErrors: $validationErrors)';
  }
}

/// @nodoc
abstract mixin class $OnboardingInProgressCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory $OnboardingInProgressCopyWith(OnboardingInProgress value,
          $Res Function(OnboardingInProgress) _then) =
      _$OnboardingInProgressCopyWithImpl;
  @useResult
  $Res call({OnboardingData data, bool isValid, List<String> validationErrors});

  $OnboardingDataCopyWith<$Res> get data;
}

/// @nodoc
class _$OnboardingInProgressCopyWithImpl<$Res>
    implements $OnboardingInProgressCopyWith<$Res> {
  _$OnboardingInProgressCopyWithImpl(this._self, this._then);

  final OnboardingInProgress _self;
  final $Res Function(OnboardingInProgress) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
    Object? isValid = null,
    Object? validationErrors = null,
  }) {
    return _then(OnboardingInProgress(
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as OnboardingData,
      isValid: null == isValid
          ? _self.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      validationErrors: null == validationErrors
          ? _self._validationErrors
          : validationErrors // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OnboardingDataCopyWith<$Res> get data {
    return $OnboardingDataCopyWith<$Res>(_self.data, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// @nodoc

class OnboardingSubmitting extends OnboardingState {
  const OnboardingSubmitting({required this.data}) : super._();

  /// The data that was submitted
  final OnboardingData data;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OnboardingSubmittingCopyWith<OnboardingSubmitting> get copyWith =>
      _$OnboardingSubmittingCopyWithImpl<OnboardingSubmitting>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnboardingSubmitting &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @override
  String toString() {
    return 'OnboardingState.submitting(data: $data)';
  }
}

/// @nodoc
abstract mixin class $OnboardingSubmittingCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory $OnboardingSubmittingCopyWith(OnboardingSubmitting value,
          $Res Function(OnboardingSubmitting) _then) =
      _$OnboardingSubmittingCopyWithImpl;
  @useResult
  $Res call({OnboardingData data});

  $OnboardingDataCopyWith<$Res> get data;
}

/// @nodoc
class _$OnboardingSubmittingCopyWithImpl<$Res>
    implements $OnboardingSubmittingCopyWith<$Res> {
  _$OnboardingSubmittingCopyWithImpl(this._self, this._then);

  final OnboardingSubmitting _self;
  final $Res Function(OnboardingSubmitting) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
  }) {
    return _then(OnboardingSubmitting(
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as OnboardingData,
    ));
  }

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OnboardingDataCopyWith<$Res> get data {
    return $OnboardingDataCopyWith<$Res>(_self.data, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// @nodoc

class OnboardingSuccess extends OnboardingState {
  const OnboardingSuccess({required this.data, required this.itinerary})
      : super._();

  /// The data that was submitted
  final OnboardingData data;

  /// The generated itinerary
  final Itinerary itinerary;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OnboardingSuccessCopyWith<OnboardingSuccess> get copyWith =>
      _$OnboardingSuccessCopyWithImpl<OnboardingSuccess>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnboardingSuccess &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.itinerary, itinerary) ||
                other.itinerary == itinerary));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data, itinerary);

  @override
  String toString() {
    return 'OnboardingState.success(data: $data, itinerary: $itinerary)';
  }
}

/// @nodoc
abstract mixin class $OnboardingSuccessCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory $OnboardingSuccessCopyWith(
          OnboardingSuccess value, $Res Function(OnboardingSuccess) _then) =
      _$OnboardingSuccessCopyWithImpl;
  @useResult
  $Res call({OnboardingData data, Itinerary itinerary});

  $OnboardingDataCopyWith<$Res> get data;
  $ItineraryCopyWith<$Res> get itinerary;
}

/// @nodoc
class _$OnboardingSuccessCopyWithImpl<$Res>
    implements $OnboardingSuccessCopyWith<$Res> {
  _$OnboardingSuccessCopyWithImpl(this._self, this._then);

  final OnboardingSuccess _self;
  final $Res Function(OnboardingSuccess) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
    Object? itinerary = null,
  }) {
    return _then(OnboardingSuccess(
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as OnboardingData,
      itinerary: null == itinerary
          ? _self.itinerary
          : itinerary // ignore: cast_nullable_to_non_nullable
              as Itinerary,
    ));
  }

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OnboardingDataCopyWith<$Res> get data {
    return $OnboardingDataCopyWith<$Res>(_self.data, (value) {
      return _then(_self.copyWith(data: value));
    });
  }

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ItineraryCopyWith<$Res> get itinerary {
    return $ItineraryCopyWith<$Res>(_self.itinerary, (value) {
      return _then(_self.copyWith(itinerary: value));
    });
  }
}

/// @nodoc

class OnboardingError extends OnboardingState {
  const OnboardingError(
      {required this.data, required this.message, this.details})
      : super._();

  /// The data that was submitted
  final OnboardingData data;

  /// The error message
  final String message;

  /// Optional error details
  final String? details;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OnboardingErrorCopyWith<OnboardingError> get copyWith =>
      _$OnboardingErrorCopyWithImpl<OnboardingError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnboardingError &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.details, details) || other.details == details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data, message, details);

  @override
  String toString() {
    return 'OnboardingState.error(data: $data, message: $message, details: $details)';
  }
}

/// @nodoc
abstract mixin class $OnboardingErrorCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory $OnboardingErrorCopyWith(
          OnboardingError value, $Res Function(OnboardingError) _then) =
      _$OnboardingErrorCopyWithImpl;
  @useResult
  $Res call({OnboardingData data, String message, String? details});

  $OnboardingDataCopyWith<$Res> get data;
}

/// @nodoc
class _$OnboardingErrorCopyWithImpl<$Res>
    implements $OnboardingErrorCopyWith<$Res> {
  _$OnboardingErrorCopyWithImpl(this._self, this._then);

  final OnboardingError _self;
  final $Res Function(OnboardingError) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
    Object? message = null,
    Object? details = freezed,
  }) {
    return _then(OnboardingError(
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as OnboardingData,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      details: freezed == details
          ? _self.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OnboardingDataCopyWith<$Res> get data {
    return $OnboardingDataCopyWith<$Res>(_self.data, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

// dart format on
