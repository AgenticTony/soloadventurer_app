// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'travel_note_operation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TravelNoteOperation _$TravelNoteOperationFromJson(Map<String, dynamic> json) {
  return _TravelNoteOperation.fromJson(json);
}

/// @nodoc
mixin _$TravelNoteOperation {
  String get id => throw _privateConstructorUsedError;
  String get tripId => throw _privateConstructorUsedError;
  NoteType get noteType => throw _privateConstructorUsedError;
  Map<String, dynamic> get content => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  String? get locationName => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  DateTime? get timestamp =>
      throw _privateConstructorUsedError; // Retry metadata
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastAttempt => throw _privateConstructorUsedError;
  int get attemptCount => throw _privateConstructorUsedError;
  String? get lastError => throw _privateConstructorUsedError;
  int get maxRetries => throw _privateConstructorUsedError;

  /// Serializes this TravelNoteOperation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TravelNoteOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TravelNoteOperationCopyWith<TravelNoteOperation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TravelNoteOperationCopyWith<$Res> {
  factory $TravelNoteOperationCopyWith(
          TravelNoteOperation value, $Res Function(TravelNoteOperation) then) =
      _$TravelNoteOperationCopyWithImpl<$Res, TravelNoteOperation>;
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
class _$TravelNoteOperationCopyWithImpl<$Res, $Val extends TravelNoteOperation>
    implements $TravelNoteOperationCopyWith<$Res> {
  _$TravelNoteOperationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      noteType: null == noteType
          ? _value.noteType
          : noteType // ignore: cast_nullable_to_non_nullable
              as NoteType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAttempt: freezed == lastAttempt
          ? _value.lastAttempt
          : lastAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      attemptCount: null == attemptCount
          ? _value.attemptCount
          : attemptCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TravelNoteOperationImplCopyWith<$Res>
    implements $TravelNoteOperationCopyWith<$Res> {
  factory _$$TravelNoteOperationImplCopyWith(_$TravelNoteOperationImpl value,
          $Res Function(_$TravelNoteOperationImpl) then) =
      __$$TravelNoteOperationImplCopyWithImpl<$Res>;
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
class __$$TravelNoteOperationImplCopyWithImpl<$Res>
    extends _$TravelNoteOperationCopyWithImpl<$Res, _$TravelNoteOperationImpl>
    implements _$$TravelNoteOperationImplCopyWith<$Res> {
  __$$TravelNoteOperationImplCopyWithImpl(_$TravelNoteOperationImpl _value,
      $Res Function(_$TravelNoteOperationImpl) _then)
      : super(_value, _then);

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
    return _then(_$TravelNoteOperationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      noteType: null == noteType
          ? _value.noteType
          : noteType // ignore: cast_nullable_to_non_nullable
              as NoteType,
      content: null == content
          ? _value._content
          : content // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAttempt: freezed == lastAttempt
          ? _value.lastAttempt
          : lastAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      attemptCount: null == attemptCount
          ? _value.attemptCount
          : attemptCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TravelNoteOperationImpl extends _TravelNoteOperation {
  const _$TravelNoteOperationImpl(
      {required this.id,
      required this.tripId,
      required this.noteType,
      required final Map<String, dynamic> content,
      this.priority = OperationPriority.normal,
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

  factory _$TravelNoteOperationImpl.fromJson(Map<String, dynamic> json) =>
      _$$TravelNoteOperationImplFromJson(json);

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
  @JsonKey()
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

  @override
  String toString() {
    return 'TravelNoteOperation(id: $id, tripId: $tripId, noteType: $noteType, content: $content, priority: $priority, locationName: $locationName, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, createdAt: $createdAt, lastAttempt: $lastAttempt, attemptCount: $attemptCount, lastError: $lastError, maxRetries: $maxRetries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TravelNoteOperationImpl &&
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

  /// Create a copy of TravelNoteOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TravelNoteOperationImplCopyWith<_$TravelNoteOperationImpl> get copyWith =>
      __$$TravelNoteOperationImplCopyWithImpl<_$TravelNoteOperationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TravelNoteOperationImplToJson(
      this,
    );
  }
}

abstract class _TravelNoteOperation extends TravelNoteOperation {
  const factory _TravelNoteOperation(
      {required final String id,
      required final String tripId,
      required final NoteType noteType,
      required final Map<String, dynamic> content,
      final int priority,
      final String? locationName,
      final double? latitude,
      final double? longitude,
      final DateTime? timestamp,
      final DateTime? createdAt,
      final DateTime? lastAttempt,
      final int attemptCount,
      final String? lastError,
      final int maxRetries}) = _$TravelNoteOperationImpl;
  const _TravelNoteOperation._() : super._();

  factory _TravelNoteOperation.fromJson(Map<String, dynamic> json) =
      _$TravelNoteOperationImpl.fromJson;

  @override
  String get id;
  @override
  String get tripId;
  @override
  NoteType get noteType;
  @override
  Map<String, dynamic> get content;
  @override
  int get priority;
  @override
  String? get locationName;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  DateTime? get timestamp; // Retry metadata
  @override
  DateTime? get createdAt;
  @override
  DateTime? get lastAttempt;
  @override
  int get attemptCount;
  @override
  String? get lastError;
  @override
  int get maxRetries;

  /// Create a copy of TravelNoteOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TravelNoteOperationImplCopyWith<_$TravelNoteOperationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
