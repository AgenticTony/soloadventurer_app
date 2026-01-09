// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheckInModel _$CheckInModelFromJson(Map<String, dynamic> json) {
  return _CheckInModel.fromJson(json);
}

/// @nodoc
mixin _$CheckInModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  CheckInTriggerType get triggerType => throw _privateConstructorUsedError;
  CheckInStatus get status => throw _privateConstructorUsedError;
  DateTime? get scheduledTime => throw _privateConstructorUsedError;
  DateTime? get deadline => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  CheckInLocation? get location => throw _privateConstructorUsedError;
  String? get statusMessage => throw _privateConstructorUsedError;
  String? get tripId => throw _privateConstructorUsedError;
  List<String> get notifyContactIds => throw _privateConstructorUsedError;
  bool get alertSent => throw _privateConstructorUsedError;
  DateTime? get alertSentAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CheckInModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckInModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckInModelCopyWith<CheckInModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInModelCopyWith<$Res> {
  factory $CheckInModelCopyWith(
          CheckInModel value, $Res Function(CheckInModel) then) =
      _$CheckInModelCopyWithImpl<$Res, CheckInModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      CheckInTriggerType triggerType,
      CheckInStatus status,
      DateTime? scheduledTime,
      DateTime? deadline,
      DateTime? completedAt,
      CheckInLocation? location,
      String? statusMessage,
      String? tripId,
      List<String> notifyContactIds,
      bool alertSent,
      DateTime? alertSentAt,
      DateTime createdAt,
      DateTime? updatedAt});

  $CheckInLocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$CheckInModelCopyWithImpl<$Res, $Val extends CheckInModel>
    implements $CheckInModelCopyWith<$Res> {
  _$CheckInModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckInModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? triggerType = null,
    Object? status = null,
    Object? scheduledTime = freezed,
    Object? deadline = freezed,
    Object? completedAt = freezed,
    Object? location = freezed,
    Object? statusMessage = freezed,
    Object? tripId = freezed,
    Object? notifyContactIds = null,
    Object? alertSent = null,
    Object? alertSentAt = freezed,
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
      triggerType: null == triggerType
          ? _value.triggerType
          : triggerType // ignore: cast_nullable_to_non_nullable
              as CheckInTriggerType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CheckInStatus,
      scheduledTime: freezed == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deadline: freezed == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as CheckInLocation?,
      statusMessage: freezed == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      notifyContactIds: null == notifyContactIds
          ? _value.notifyContactIds
          : notifyContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      alertSent: null == alertSent
          ? _value.alertSent
          : alertSent // ignore: cast_nullable_to_non_nullable
              as bool,
      alertSentAt: freezed == alertSentAt
          ? _value.alertSentAt
          : alertSentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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

  /// Create a copy of CheckInModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInLocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $CheckInLocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CheckInModelImplCopyWith<$Res>
    implements $CheckInModelCopyWith<$Res> {
  factory _$$CheckInModelImplCopyWith(
          _$CheckInModelImpl value, $Res Function(_$CheckInModelImpl) then) =
      __$$CheckInModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      CheckInTriggerType triggerType,
      CheckInStatus status,
      DateTime? scheduledTime,
      DateTime? deadline,
      DateTime? completedAt,
      CheckInLocation? location,
      String? statusMessage,
      String? tripId,
      List<String> notifyContactIds,
      bool alertSent,
      DateTime? alertSentAt,
      DateTime createdAt,
      DateTime? updatedAt});

  @override
  $CheckInLocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$$CheckInModelImplCopyWithImpl<$Res>
    extends _$CheckInModelCopyWithImpl<$Res, _$CheckInModelImpl>
    implements _$$CheckInModelImplCopyWith<$Res> {
  __$$CheckInModelImplCopyWithImpl(
      _$CheckInModelImpl _value, $Res Function(_$CheckInModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckInModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? triggerType = null,
    Object? status = null,
    Object? scheduledTime = freezed,
    Object? deadline = freezed,
    Object? completedAt = freezed,
    Object? location = freezed,
    Object? statusMessage = freezed,
    Object? tripId = freezed,
    Object? notifyContactIds = null,
    Object? alertSent = null,
    Object? alertSentAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$CheckInModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      triggerType: null == triggerType
          ? _value.triggerType
          : triggerType // ignore: cast_nullable_to_non_nullable
              as CheckInTriggerType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CheckInStatus,
      scheduledTime: freezed == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deadline: freezed == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as CheckInLocation?,
      statusMessage: freezed == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      notifyContactIds: null == notifyContactIds
          ? _value._notifyContactIds
          : notifyContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      alertSent: null == alertSent
          ? _value.alertSent
          : alertSent // ignore: cast_nullable_to_non_nullable
              as bool,
      alertSentAt: freezed == alertSentAt
          ? _value.alertSentAt
          : alertSentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
class _$CheckInModelImpl extends _CheckInModel {
  const _$CheckInModelImpl(
      {required this.id,
      required this.userId,
      required this.triggerType,
      required this.status,
      this.scheduledTime,
      this.deadline,
      this.completedAt,
      this.location,
      this.statusMessage,
      this.tripId,
      required final List<String> notifyContactIds,
      this.alertSent = false,
      this.alertSentAt,
      required this.createdAt,
      this.updatedAt})
      : _notifyContactIds = notifyContactIds,
        super._();

  factory _$CheckInModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckInModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final CheckInTriggerType triggerType;
  @override
  final CheckInStatus status;
  @override
  final DateTime? scheduledTime;
  @override
  final DateTime? deadline;
  @override
  final DateTime? completedAt;
  @override
  final CheckInLocation? location;
  @override
  final String? statusMessage;
  @override
  final String? tripId;
  final List<String> _notifyContactIds;
  @override
  List<String> get notifyContactIds {
    if (_notifyContactIds is EqualUnmodifiableListView)
      return _notifyContactIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifyContactIds);
  }

  @override
  @JsonKey()
  final bool alertSent;
  @override
  final DateTime? alertSentAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'CheckInModel(id: $id, userId: $userId, triggerType: $triggerType, status: $status, scheduledTime: $scheduledTime, deadline: $deadline, completedAt: $completedAt, location: $location, statusMessage: $statusMessage, tripId: $tripId, notifyContactIds: $notifyContactIds, alertSent: $alertSent, alertSentAt: $alertSentAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.triggerType, triggerType) ||
                other.triggerType == triggerType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.statusMessage, statusMessage) ||
                other.statusMessage == statusMessage) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            const DeepCollectionEquality()
                .equals(other._notifyContactIds, _notifyContactIds) &&
            (identical(other.alertSent, alertSent) ||
                other.alertSent == alertSent) &&
            (identical(other.alertSentAt, alertSentAt) ||
                other.alertSentAt == alertSentAt) &&
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
      triggerType,
      status,
      scheduledTime,
      deadline,
      completedAt,
      location,
      statusMessage,
      tripId,
      const DeepCollectionEquality().hash(_notifyContactIds),
      alertSent,
      alertSentAt,
      createdAt,
      updatedAt);

  /// Create a copy of CheckInModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInModelImplCopyWith<_$CheckInModelImpl> get copyWith =>
      __$$CheckInModelImplCopyWithImpl<_$CheckInModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckInModelImplToJson(
      this,
    );
  }
}

abstract class _CheckInModel extends CheckInModel {
  const factory _CheckInModel(
      {required final String id,
      required final String userId,
      required final CheckInTriggerType triggerType,
      required final CheckInStatus status,
      final DateTime? scheduledTime,
      final DateTime? deadline,
      final DateTime? completedAt,
      final CheckInLocation? location,
      final String? statusMessage,
      final String? tripId,
      required final List<String> notifyContactIds,
      final bool alertSent,
      final DateTime? alertSentAt,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$CheckInModelImpl;
  const _CheckInModel._() : super._();

  factory _CheckInModel.fromJson(Map<String, dynamic> json) =
      _$CheckInModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  CheckInTriggerType get triggerType;
  @override
  CheckInStatus get status;
  @override
  DateTime? get scheduledTime;
  @override
  DateTime? get deadline;
  @override
  DateTime? get completedAt;
  @override
  CheckInLocation? get location;
  @override
  String? get statusMessage;
  @override
  String? get tripId;
  @override
  List<String> get notifyContactIds;
  @override
  bool get alertSent;
  @override
  DateTime? get alertSentAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of CheckInModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckInModelImplCopyWith<_$CheckInModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
