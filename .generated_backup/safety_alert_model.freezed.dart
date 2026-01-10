// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_alert_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SafetyAlertModel _$SafetyAlertModelFromJson(Map<String, dynamic> json) {
  return _SafetyAlertModel.fromJson(json);
}

/// @nodoc
mixin _$SafetyAlertModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  SafetyAlertType get type => throw _privateConstructorUsedError;
  SafetyAlertStatus get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  SafetyAlertLocation? get location => throw _privateConstructorUsedError;
  List<String> get notifiedContactIds => throw _privateConstructorUsedError;
  List<String> get acknowledgedByContactIds =>
      throw _privateConstructorUsedError;
  DateTime get triggeredAt => throw _privateConstructorUsedError;
  DateTime? get firstAcknowledgedAt => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  int? get batteryLevel => throw _privateConstructorUsedError;
  String? get checkInId => throw _privateConstructorUsedError;
  String? get tripId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SafetyAlertModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SafetyAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SafetyAlertModelCopyWith<SafetyAlertModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SafetyAlertModelCopyWith<$Res> {
  factory $SafetyAlertModelCopyWith(
          SafetyAlertModel value, $Res Function(SafetyAlertModel) then) =
      _$SafetyAlertModelCopyWithImpl<$Res, SafetyAlertModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      SafetyAlertType type,
      SafetyAlertStatus status,
      String? message,
      SafetyAlertLocation? location,
      List<String> notifiedContactIds,
      List<String> acknowledgedByContactIds,
      DateTime triggeredAt,
      DateTime? firstAcknowledgedAt,
      DateTime? resolvedAt,
      DateTime? cancelledAt,
      int? batteryLevel,
      String? checkInId,
      String? tripId,
      Map<String, dynamic>? metadata,
      DateTime createdAt,
      DateTime? updatedAt});

  $SafetyAlertLocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$SafetyAlertModelCopyWithImpl<$Res, $Val extends SafetyAlertModel>
    implements $SafetyAlertModelCopyWith<$Res> {
  _$SafetyAlertModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SafetyAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? status = null,
    Object? message = freezed,
    Object? location = freezed,
    Object? notifiedContactIds = null,
    Object? acknowledgedByContactIds = null,
    Object? triggeredAt = null,
    Object? firstAcknowledgedAt = freezed,
    Object? resolvedAt = freezed,
    Object? cancelledAt = freezed,
    Object? batteryLevel = freezed,
    Object? checkInId = freezed,
    Object? tripId = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SafetyAlertType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SafetyAlertStatus,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as SafetyAlertLocation?,
      notifiedContactIds: null == notifiedContactIds
          ? _value.notifiedContactIds
          : notifiedContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      acknowledgedByContactIds: null == acknowledgedByContactIds
          ? _value.acknowledgedByContactIds
          : acknowledgedByContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      triggeredAt: null == triggeredAt
          ? _value.triggeredAt
          : triggeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      firstAcknowledgedAt: freezed == firstAcknowledgedAt
          ? _value.firstAcknowledgedAt
          : firstAcknowledgedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      batteryLevel: freezed == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      checkInId: freezed == checkInId
          ? _value.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of SafetyAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SafetyAlertLocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $SafetyAlertLocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SafetyAlertModelImplCopyWith<$Res>
    implements $SafetyAlertModelCopyWith<$Res> {
  factory _$$SafetyAlertModelImplCopyWith(_$SafetyAlertModelImpl value,
          $Res Function(_$SafetyAlertModelImpl) then) =
      __$$SafetyAlertModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      SafetyAlertType type,
      SafetyAlertStatus status,
      String? message,
      SafetyAlertLocation? location,
      List<String> notifiedContactIds,
      List<String> acknowledgedByContactIds,
      DateTime triggeredAt,
      DateTime? firstAcknowledgedAt,
      DateTime? resolvedAt,
      DateTime? cancelledAt,
      int? batteryLevel,
      String? checkInId,
      String? tripId,
      Map<String, dynamic>? metadata,
      DateTime createdAt,
      DateTime? updatedAt});

  @override
  $SafetyAlertLocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$$SafetyAlertModelImplCopyWithImpl<$Res>
    extends _$SafetyAlertModelCopyWithImpl<$Res, _$SafetyAlertModelImpl>
    implements _$$SafetyAlertModelImplCopyWith<$Res> {
  __$$SafetyAlertModelImplCopyWithImpl(_$SafetyAlertModelImpl _value,
      $Res Function(_$SafetyAlertModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SafetyAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? status = null,
    Object? message = freezed,
    Object? location = freezed,
    Object? notifiedContactIds = null,
    Object? acknowledgedByContactIds = null,
    Object? triggeredAt = null,
    Object? firstAcknowledgedAt = freezed,
    Object? resolvedAt = freezed,
    Object? cancelledAt = freezed,
    Object? batteryLevel = freezed,
    Object? checkInId = freezed,
    Object? tripId = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$SafetyAlertModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SafetyAlertType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SafetyAlertStatus,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as SafetyAlertLocation?,
      notifiedContactIds: null == notifiedContactIds
          ? _value._notifiedContactIds
          : notifiedContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      acknowledgedByContactIds: null == acknowledgedByContactIds
          ? _value._acknowledgedByContactIds
          : acknowledgedByContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      triggeredAt: null == triggeredAt
          ? _value.triggeredAt
          : triggeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      firstAcknowledgedAt: freezed == firstAcknowledgedAt
          ? _value.firstAcknowledgedAt
          : firstAcknowledgedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      batteryLevel: freezed == batteryLevel
          ? _value.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      checkInId: freezed == checkInId
          ? _value.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SafetyAlertModelImpl extends _SafetyAlertModel {
  const _$SafetyAlertModelImpl(
      {required this.id,
      required this.userId,
      required this.type,
      required this.status,
      this.message,
      this.location,
      required final List<String> notifiedContactIds,
      required final List<String> acknowledgedByContactIds,
      required this.triggeredAt,
      this.firstAcknowledgedAt,
      this.resolvedAt,
      this.cancelledAt,
      this.batteryLevel,
      this.checkInId,
      this.tripId,
      final Map<String, dynamic>? metadata,
      required this.createdAt,
      this.updatedAt})
      : _notifiedContactIds = notifiedContactIds,
        _acknowledgedByContactIds = acknowledgedByContactIds,
        _metadata = metadata,
        super._();

  factory _$SafetyAlertModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SafetyAlertModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final SafetyAlertType type;
  @override
  final SafetyAlertStatus status;
  @override
  final String? message;
  @override
  final SafetyAlertLocation? location;
  final List<String> _notifiedContactIds;
  @override
  List<String> get notifiedContactIds {
    if (_notifiedContactIds is EqualUnmodifiableListView)
      return _notifiedContactIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifiedContactIds);
  }

  final List<String> _acknowledgedByContactIds;
  @override
  List<String> get acknowledgedByContactIds {
    if (_acknowledgedByContactIds is EqualUnmodifiableListView)
      return _acknowledgedByContactIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_acknowledgedByContactIds);
  }

  @override
  final DateTime triggeredAt;
  @override
  final DateTime? firstAcknowledgedAt;
  @override
  final DateTime? resolvedAt;
  @override
  final DateTime? cancelledAt;
  @override
  final int? batteryLevel;
  @override
  final String? checkInId;
  @override
  final String? tripId;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'SafetyAlertModel(id: $id, userId: $userId, type: $type, status: $status, message: $message, location: $location, notifiedContactIds: $notifiedContactIds, acknowledgedByContactIds: $acknowledgedByContactIds, triggeredAt: $triggeredAt, firstAcknowledgedAt: $firstAcknowledgedAt, resolvedAt: $resolvedAt, cancelledAt: $cancelledAt, batteryLevel: $batteryLevel, checkInId: $checkInId, tripId: $tripId, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SafetyAlertModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality()
                .equals(other._notifiedContactIds, _notifiedContactIds) &&
            const DeepCollectionEquality().equals(
                other._acknowledgedByContactIds, _acknowledgedByContactIds) &&
            (identical(other.triggeredAt, triggeredAt) ||
                other.triggeredAt == triggeredAt) &&
            (identical(other.firstAcknowledgedAt, firstAcknowledgedAt) ||
                other.firstAcknowledgedAt == firstAcknowledgedAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.batteryLevel, batteryLevel) ||
                other.batteryLevel == batteryLevel) &&
            (identical(other.checkInId, checkInId) ||
                other.checkInId == checkInId) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      type,
      status,
      message,
      location,
      const DeepCollectionEquality().hash(_notifiedContactIds),
      const DeepCollectionEquality().hash(_acknowledgedByContactIds),
      triggeredAt,
      firstAcknowledgedAt,
      resolvedAt,
      cancelledAt,
      batteryLevel,
      checkInId,
      tripId,
      const DeepCollectionEquality().hash(_metadata),
      createdAt,
      updatedAt);

  /// Create a copy of SafetyAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SafetyAlertModelImplCopyWith<_$SafetyAlertModelImpl> get copyWith =>
      __$$SafetyAlertModelImplCopyWithImpl<_$SafetyAlertModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SafetyAlertModelImplToJson(
      this,
    );
  }
}

abstract class _SafetyAlertModel extends SafetyAlertModel {
  const factory _SafetyAlertModel(
      {required final String id,
      required final String userId,
      required final SafetyAlertType type,
      required final SafetyAlertStatus status,
      final String? message,
      final SafetyAlertLocation? location,
      required final List<String> notifiedContactIds,
      required final List<String> acknowledgedByContactIds,
      required final DateTime triggeredAt,
      final DateTime? firstAcknowledgedAt,
      final DateTime? resolvedAt,
      final DateTime? cancelledAt,
      final int? batteryLevel,
      final String? checkInId,
      final String? tripId,
      final Map<String, dynamic>? metadata,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$SafetyAlertModelImpl;
  const _SafetyAlertModel._() : super._();

  factory _SafetyAlertModel.fromJson(Map<String, dynamic> json) =
      _$SafetyAlertModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  SafetyAlertType get type;
  @override
  SafetyAlertStatus get status;
  @override
  String? get message;
  @override
  SafetyAlertLocation? get location;
  @override
  List<String> get notifiedContactIds;
  @override
  List<String> get acknowledgedByContactIds;
  @override
  DateTime get triggeredAt;
  @override
  DateTime? get firstAcknowledgedAt;
  @override
  DateTime? get resolvedAt;
  @override
  DateTime? get cancelledAt;
  @override
  int? get batteryLevel;
  @override
  String? get checkInId;
  @override
  String? get tripId;
  @override
  Map<String, dynamic>? get metadata;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of SafetyAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SafetyAlertModelImplCopyWith<_$SafetyAlertModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
