// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trusted_contact_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrustedContactModel _$TrustedContactModelFromJson(Map<String, dynamic> json) {
  return _TrustedContactModel.fromJson(json);
}

/// @nodoc
mixin _$TrustedContactModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  ContactSource get source => throw _privateConstructorUsedError;
  String? get communityUserId => throw _privateConstructorUsedError;
  ContactPermission get permission => throw _privateConstructorUsedError;
  bool get locationSharingEnabled => throw _privateConstructorUsedError;
  bool get receivesCheckIns => throw _privateConstructorUsedError;
  bool get receivesEmergencyAlerts => throw _privateConstructorUsedError;
  DateTime get addedAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get revokedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this TrustedContactModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrustedContactModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrustedContactModelCopyWith<TrustedContactModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrustedContactModelCopyWith<$Res> {
  factory $TrustedContactModelCopyWith(
          TrustedContactModel value, $Res Function(TrustedContactModel) then) =
      _$TrustedContactModelCopyWithImpl<$Res, TrustedContactModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String phoneNumber,
      String? email,
      ContactSource source,
      String? communityUserId,
      ContactPermission permission,
      bool locationSharingEnabled,
      bool receivesCheckIns,
      bool receivesEmergencyAlerts,
      DateTime addedAt,
      DateTime? updatedAt,
      DateTime? revokedAt,
      String? notes});
}

/// @nodoc
class _$TrustedContactModelCopyWithImpl<$Res, $Val extends TrustedContactModel>
    implements $TrustedContactModelCopyWith<$Res> {
  _$TrustedContactModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrustedContactModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? phoneNumber = null,
    Object? email = freezed,
    Object? source = null,
    Object? communityUserId = freezed,
    Object? permission = null,
    Object? locationSharingEnabled = null,
    Object? receivesCheckIns = null,
    Object? receivesEmergencyAlerts = null,
    Object? addedAt = null,
    Object? updatedAt = freezed,
    Object? revokedAt = freezed,
    Object? notes = freezed,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as ContactSource,
      communityUserId: freezed == communityUserId
          ? _value.communityUserId
          : communityUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      permission: null == permission
          ? _value.permission
          : permission // ignore: cast_nullable_to_non_nullable
              as ContactPermission,
      locationSharingEnabled: null == locationSharingEnabled
          ? _value.locationSharingEnabled
          : locationSharingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      receivesCheckIns: null == receivesCheckIns
          ? _value.receivesCheckIns
          : receivesCheckIns // ignore: cast_nullable_to_non_nullable
              as bool,
      receivesEmergencyAlerts: null == receivesEmergencyAlerts
          ? _value.receivesEmergencyAlerts
          : receivesEmergencyAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      addedAt: null == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      revokedAt: freezed == revokedAt
          ? _value.revokedAt
          : revokedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrustedContactModelImplCopyWith<$Res>
    implements $TrustedContactModelCopyWith<$Res> {
  factory _$$TrustedContactModelImplCopyWith(_$TrustedContactModelImpl value,
          $Res Function(_$TrustedContactModelImpl) then) =
      __$$TrustedContactModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String phoneNumber,
      String? email,
      ContactSource source,
      String? communityUserId,
      ContactPermission permission,
      bool locationSharingEnabled,
      bool receivesCheckIns,
      bool receivesEmergencyAlerts,
      DateTime addedAt,
      DateTime? updatedAt,
      DateTime? revokedAt,
      String? notes});
}

/// @nodoc
class __$$TrustedContactModelImplCopyWithImpl<$Res>
    extends _$TrustedContactModelCopyWithImpl<$Res, _$TrustedContactModelImpl>
    implements _$$TrustedContactModelImplCopyWith<$Res> {
  __$$TrustedContactModelImplCopyWithImpl(_$TrustedContactModelImpl _value,
      $Res Function(_$TrustedContactModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrustedContactModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? phoneNumber = null,
    Object? email = freezed,
    Object? source = null,
    Object? communityUserId = freezed,
    Object? permission = null,
    Object? locationSharingEnabled = null,
    Object? receivesCheckIns = null,
    Object? receivesEmergencyAlerts = null,
    Object? addedAt = null,
    Object? updatedAt = freezed,
    Object? revokedAt = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$TrustedContactModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as ContactSource,
      communityUserId: freezed == communityUserId
          ? _value.communityUserId
          : communityUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      permission: null == permission
          ? _value.permission
          : permission // ignore: cast_nullable_to_non_nullable
              as ContactPermission,
      locationSharingEnabled: null == locationSharingEnabled
          ? _value.locationSharingEnabled
          : locationSharingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      receivesCheckIns: null == receivesCheckIns
          ? _value.receivesCheckIns
          : receivesCheckIns // ignore: cast_nullable_to_non_nullable
              as bool,
      receivesEmergencyAlerts: null == receivesEmergencyAlerts
          ? _value.receivesEmergencyAlerts
          : receivesEmergencyAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      addedAt: null == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      revokedAt: freezed == revokedAt
          ? _value.revokedAt
          : revokedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrustedContactModelImpl extends _TrustedContactModel {
  const _$TrustedContactModelImpl(
      {required this.id,
      required this.userId,
      required this.name,
      required this.phoneNumber,
      this.email,
      required this.source,
      this.communityUserId,
      required this.permission,
      this.locationSharingEnabled = false,
      this.receivesCheckIns = true,
      this.receivesEmergencyAlerts = true,
      required this.addedAt,
      this.updatedAt,
      this.revokedAt,
      this.notes})
      : super._();

  factory _$TrustedContactModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrustedContactModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String phoneNumber;
  @override
  final String? email;
  @override
  final ContactSource source;
  @override
  final String? communityUserId;
  @override
  final ContactPermission permission;
  @override
  @JsonKey()
  final bool locationSharingEnabled;
  @override
  @JsonKey()
  final bool receivesCheckIns;
  @override
  @JsonKey()
  final bool receivesEmergencyAlerts;
  @override
  final DateTime addedAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? revokedAt;
  @override
  final String? notes;

  @override
  String toString() {
    return 'TrustedContactModel(id: $id, userId: $userId, name: $name, phoneNumber: $phoneNumber, email: $email, source: $source, communityUserId: $communityUserId, permission: $permission, locationSharingEnabled: $locationSharingEnabled, receivesCheckIns: $receivesCheckIns, receivesEmergencyAlerts: $receivesEmergencyAlerts, addedAt: $addedAt, updatedAt: $updatedAt, revokedAt: $revokedAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrustedContactModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.communityUserId, communityUserId) ||
                other.communityUserId == communityUserId) &&
            (identical(other.permission, permission) ||
                other.permission == permission) &&
            (identical(other.locationSharingEnabled, locationSharingEnabled) ||
                other.locationSharingEnabled == locationSharingEnabled) &&
            (identical(other.receivesCheckIns, receivesCheckIns) ||
                other.receivesCheckIns == receivesCheckIns) &&
            (identical(
                    other.receivesEmergencyAlerts, receivesEmergencyAlerts) ||
                other.receivesEmergencyAlerts == receivesEmergencyAlerts) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.revokedAt, revokedAt) ||
                other.revokedAt == revokedAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      phoneNumber,
      email,
      source,
      communityUserId,
      permission,
      locationSharingEnabled,
      receivesCheckIns,
      receivesEmergencyAlerts,
      addedAt,
      updatedAt,
      revokedAt,
      notes);

  /// Create a copy of TrustedContactModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrustedContactModelImplCopyWith<_$TrustedContactModelImpl> get copyWith =>
      __$$TrustedContactModelImplCopyWithImpl<_$TrustedContactModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrustedContactModelImplToJson(
      this,
    );
  }
}

abstract class _TrustedContactModel extends TrustedContactModel {
  const factory _TrustedContactModel(
      {required final String id,
      required final String userId,
      required final String name,
      required final String phoneNumber,
      final String? email,
      required final ContactSource source,
      final String? communityUserId,
      required final ContactPermission permission,
      final bool locationSharingEnabled,
      final bool receivesCheckIns,
      final bool receivesEmergencyAlerts,
      required final DateTime addedAt,
      final DateTime? updatedAt,
      final DateTime? revokedAt,
      final String? notes}) = _$TrustedContactModelImpl;
  const _TrustedContactModel._() : super._();

  factory _TrustedContactModel.fromJson(Map<String, dynamic> json) =
      _$TrustedContactModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String get phoneNumber;
  @override
  String? get email;
  @override
  ContactSource get source;
  @override
  String? get communityUserId;
  @override
  ContactPermission get permission;
  @override
  bool get locationSharingEnabled;
  @override
  bool get receivesCheckIns;
  @override
  bool get receivesEmergencyAlerts;
  @override
  DateTime get addedAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get revokedAt;
  @override
  String? get notes;

  /// Create a copy of TrustedContactModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrustedContactModelImplCopyWith<_$TrustedContactModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
