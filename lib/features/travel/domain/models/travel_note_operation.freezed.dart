// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'travel_note_operation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TravelNoteOperation {
  String get id;
  String get tripId;
  NoteType get noteType;
  Map<String, dynamic> get content;
  int get priority;
  String? get locationName;
  double? get latitude;
  double? get longitude;
  DateTime? get timestamp; // Retry metadata
  DateTime? get createdAt;
  DateTime? get lastAttempt;
  int get attemptCount;
  String? get lastError;
  int get maxRetries;

  /// Create a copy of TravelNoteOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TravelNoteOperationCopyWith<TravelNoteOperation> get copyWith =>
      _$TravelNoteOperationCopyWithImpl<TravelNoteOperation>(
          this as TravelNoteOperation, _$identity);

  /// Serializes this TravelNoteOperation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TravelNoteOperation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.noteType, noteType) ||
                other.noteType == noteType) &&
            const DeepCollectionEquality().equals(other.content, content) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastAttempt, lastAttempt) ||
                other.lastAttempt == lastAttempt) &&
            (identical(other.attemptCount, attemptCount) ||
                other.attemptCount == attemptCount) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tripId,
      noteType,
      const DeepCollectionEquality().hash(content),
      priority,
      locationName,
      latitude,
      longitude,
      timestamp,
      createdAt,
      lastAttempt,
      attemptCount,
      lastError,
      maxRetries);

  @override
  String toString() {
    return 'TravelNoteOperation(id: $id, tripId: $tripId, noteType: $noteType, content: $content, priority: $priority, locationName: $locationName, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, createdAt: $createdAt, lastAttempt: $lastAttempt, attemptCount: $attemptCount, lastError: $lastError, maxRetries: $maxRetries)';
  }
}

/// @nodoc
abstract mixin class $TravelNoteOperationCopyWith<$Res> {
  factory $TravelNoteOperationCopyWith(
          TravelNoteOperation value, $Res Function(TravelNoteOperation) _then) =
      _$TravelNoteOperationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String tripId,
      NoteType noteType,
      Map<String, dynamic> content,
      int priority,
      String? locationName,
      double? latitude,
      double? longitude,
      DateTime? timestamp,
      DateTime? createdAt,
      DateTime? lastAttempt,
      int attemptCount,
      String? lastError,
      int maxRetries});
}

/// @nodoc
class _$TravelNoteOperationCopyWithImpl<$Res>
    implements $TravelNoteOperationCopyWith<$Res> {
  _$TravelNoteOperationCopyWithImpl(this._self, this._then);

  final TravelNoteOperation _self;
  final $Res Function(TravelNoteOperation) _then;

  /// Create a copy of TravelNoteOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? noteType = null,
    Object? content = null,
    Object? priority = null,
    Object? locationName = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? timestamp = freezed,
    Object? createdAt = freezed,
    Object? lastAttempt = freezed,
    Object? attemptCount = null,
    Object? lastError = freezed,
    Object? maxRetries = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      noteType: null == noteType
          ? _self.noteType
          : noteType // ignore: cast_nullable_to_non_nullable
              as NoteType,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      locationName: freezed == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      timestamp: freezed == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAttempt: freezed == lastAttempt
          ? _self.lastAttempt
          : lastAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      attemptCount: null == attemptCount
          ? _self.attemptCount
          : attemptCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _self.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      maxRetries: null == maxRetries
          ? _self.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [TravelNoteOperation].
extension TravelNoteOperationPatterns on TravelNoteOperation {
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
    TResult Function(_TravelNoteOperation value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TravelNoteOperation() when $default != null:
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
    TResult Function(_TravelNoteOperation value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TravelNoteOperation():
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
    TResult? Function(_TravelNoteOperation value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TravelNoteOperation() when $default != null:
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
            String id,
            String tripId,
            NoteType noteType,
            Map<String, dynamic> content,
            int priority,
            String? locationName,
            double? latitude,
            double? longitude,
            DateTime? timestamp,
            DateTime? createdAt,
            DateTime? lastAttempt,
            int attemptCount,
            String? lastError,
            int maxRetries)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TravelNoteOperation() when $default != null:
        return $default(
            _that.id,
            _that.tripId,
            _that.noteType,
            _that.content,
            _that.priority,
            _that.locationName,
            _that.latitude,
            _that.longitude,
            _that.timestamp,
            _that.createdAt,
            _that.lastAttempt,
            _that.attemptCount,
            _that.lastError,
            _that.maxRetries);
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
            String id,
            String tripId,
            NoteType noteType,
            Map<String, dynamic> content,
            int priority,
            String? locationName,
            double? latitude,
            double? longitude,
            DateTime? timestamp,
            DateTime? createdAt,
            DateTime? lastAttempt,
            int attemptCount,
            String? lastError,
            int maxRetries)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TravelNoteOperation():
        return $default(
            _that.id,
            _that.tripId,
            _that.noteType,
            _that.content,
            _that.priority,
            _that.locationName,
            _that.latitude,
            _that.longitude,
            _that.timestamp,
            _that.createdAt,
            _that.lastAttempt,
            _that.attemptCount,
            _that.lastError,
            _that.maxRetries);
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
            String id,
            String tripId,
            NoteType noteType,
            Map<String, dynamic> content,
            int priority,
            String? locationName,
            double? latitude,
            double? longitude,
            DateTime? timestamp,
            DateTime? createdAt,
            DateTime? lastAttempt,
            int attemptCount,
            String? lastError,
            int maxRetries)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TravelNoteOperation() when $default != null:
        return $default(
            _that.id,
            _that.tripId,
            _that.noteType,
            _that.content,
            _that.priority,
            _that.locationName,
            _that.latitude,
            _that.longitude,
            _that.timestamp,
            _that.createdAt,
            _that.lastAttempt,
            _that.attemptCount,
            _that.lastError,
            _that.maxRetries);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TravelNoteOperation extends TravelNoteOperation {
  const _TravelNoteOperation(
      {required this.id,
      required this.tripId,
      required this.noteType,
      required final Map<String, dynamic> content,
      required this.priority,
      this.locationName,
      this.latitude,
      this.longitude,
      this.timestamp,
      this.createdAt,
      this.lastAttempt,
      this.attemptCount = 0,
      this.lastError,
      this.maxRetries = 3})
      : _content = content,
        super._();
  factory _TravelNoteOperation.fromJson(Map<String, dynamic> json) =>
      _$TravelNoteOperationFromJson(json);

  @override
  final String id;
  @override
  final String tripId;
  @override
  final NoteType noteType;
  final Map<String, dynamic> _content;
  @override
  Map<String, dynamic> get content {
    if (_content is EqualUnmodifiableMapView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_content);
  }

  @override
  final int priority;
  @override
  final String? locationName;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final DateTime? timestamp;
// Retry metadata
  @override
  final DateTime? createdAt;
  @override
  final DateTime? lastAttempt;
  @override
  @JsonKey()
  final int attemptCount;
  @override
  final String? lastError;
  @override
  @JsonKey()
  final int maxRetries;

  /// Create a copy of TravelNoteOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TravelNoteOperationCopyWith<_TravelNoteOperation> get copyWith =>
      __$TravelNoteOperationCopyWithImpl<_TravelNoteOperation>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TravelNoteOperationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TravelNoteOperation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.noteType, noteType) ||
                other.noteType == noteType) &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastAttempt, lastAttempt) ||
                other.lastAttempt == lastAttempt) &&
            (identical(other.attemptCount, attemptCount) ||
                other.attemptCount == attemptCount) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tripId,
      noteType,
      const DeepCollectionEquality().hash(_content),
      priority,
      locationName,
      latitude,
      longitude,
      timestamp,
      createdAt,
      lastAttempt,
      attemptCount,
      lastError,
      maxRetries);

  @override
  String toString() {
    return 'TravelNoteOperation(id: $id, tripId: $tripId, noteType: $noteType, content: $content, priority: $priority, locationName: $locationName, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, createdAt: $createdAt, lastAttempt: $lastAttempt, attemptCount: $attemptCount, lastError: $lastError, maxRetries: $maxRetries)';
  }
}

/// @nodoc
abstract mixin class _$TravelNoteOperationCopyWith<$Res>
    implements $TravelNoteOperationCopyWith<$Res> {
  factory _$TravelNoteOperationCopyWith(_TravelNoteOperation value,
          $Res Function(_TravelNoteOperation) _then) =
      __$TravelNoteOperationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String tripId,
      NoteType noteType,
      Map<String, dynamic> content,
      int priority,
      String? locationName,
      double? latitude,
      double? longitude,
      DateTime? timestamp,
      DateTime? createdAt,
      DateTime? lastAttempt,
      int attemptCount,
      String? lastError,
      int maxRetries});
}

/// @nodoc
class __$TravelNoteOperationCopyWithImpl<$Res>
    implements _$TravelNoteOperationCopyWith<$Res> {
  __$TravelNoteOperationCopyWithImpl(this._self, this._then);

  final _TravelNoteOperation _self;
  final $Res Function(_TravelNoteOperation) _then;

  /// Create a copy of TravelNoteOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? noteType = null,
    Object? content = null,
    Object? priority = null,
    Object? locationName = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? timestamp = freezed,
    Object? createdAt = freezed,
    Object? lastAttempt = freezed,
    Object? attemptCount = null,
    Object? lastError = freezed,
    Object? maxRetries = null,
  }) {
    return _then(_TravelNoteOperation(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      noteType: null == noteType
          ? _self.noteType
          : noteType // ignore: cast_nullable_to_non_nullable
              as NoteType,
      content: null == content
          ? _self._content
          : content // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      locationName: freezed == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      timestamp: freezed == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAttempt: freezed == lastAttempt
          ? _self.lastAttempt
          : lastAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      attemptCount: null == attemptCount
          ? _self.attemptCount
          : attemptCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _self.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      maxRetries: null == maxRetries
          ? _self.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
