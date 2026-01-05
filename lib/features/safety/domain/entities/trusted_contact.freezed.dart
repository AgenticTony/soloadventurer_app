// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trusted_contact.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrustedContact _$TrustedContactFromJson(Map<String, dynamic> json) {
  return _TrustedContact.fromJson(json);
}

/// @nodoc
mixin _$TrustedContact {
  /// Unique identifier for the trusted contact
  String get id => throw _privateConstructorUsedError;

  /// User ID who owns this trusted contact
  String get userId => throw _privateConstructorUsedError;

  /// Contact's name
  String get name => throw _privateConstructorUsedError;

  /// Contact's phone number
  String get phoneNumber => throw _privateConstructorUsedError;

  /// Contact's email (optional)
  String? get email => throw _privateConstructorUsedError;

  /// Source of the contact (phone or community)
  ContactSource get source => throw _privateConstructorUsedError;

  /// Community user ID if from community source
  String? get communityUserId => throw _privateConstructorUsedError;

  /// Permission level for this contact
  ContactPermission get permission => throw _privateConstructorUsedError;

  /// Whether location sharing is currently active with this contact
  bool get locationSharingEnabled => throw _privateConstructorUsedError;

  /// Whether this contact receives check-in notifications
  bool get receivesCheckIns => throw _privateConstructorUsedError;

  /// Whether this contact receives emergency alerts
  bool get receivesEmergencyAlerts => throw _privateConstructorUsedError;

  /// When this contact was added
  DateTime get addedAt => throw _privateConstructorUsedError;

  /// When this contact was last updated
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// When this trusted contact relationship was revoked (if applicable)
  DateTime? get revokedAt => throw _privateConstructorUsedError;

  /// Notes about this contact
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this TrustedContact to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrustedContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrustedContactCopyWith<TrustedContact> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrustedContactCopyWith<$Res> {
  factory $TrustedContactCopyWith(
          TrustedContact value, $Res Function(TrustedContact) then) =
      _$TrustedContactCopyWithImpl<$Res, TrustedContact>;
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
class _$TrustedContactCopyWithImpl<$Res, $Val extends TrustedContact>
    implements $TrustedContactCopyWith<$Res> {
  _$TrustedContactCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrustedContact
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
abstract class _$$TrustedContactImplCopyWith<$Res>
    implements $TrustedContactCopyWith<$Res> {
  factory _$$TrustedContactImplCopyWith(_$TrustedContactImpl value,
          $Res Function(_$TrustedContactImpl) then) =
      __$$TrustedContactImplCopyWithImpl<$Res>;
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
class __$$TrustedContactImplCopyWithImpl<$Res>
    extends _$TrustedContactCopyWithImpl<$Res, _$TrustedContactImpl>
    implements _$$TrustedContactImplCopyWith<$Res> {
  __$$TrustedContactImplCopyWithImpl(
      _$TrustedContactImpl _value, $Res Function(_$TrustedContactImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrustedContact
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
    return _then(_$TrustedContactImpl(
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
class _$TrustedContactImpl implements _TrustedContact {
  const _$TrustedContactImpl(
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
      this.notes});

  factory _$TrustedContactImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrustedContactImplFromJson(json);

  /// Unique identifier for the trusted contact
  @override
  final String id;

  /// User ID who owns this trusted contact
  @override
  final String userId;

  /// Contact's name
  @override
  final String name;

  /// Contact's phone number
  @override
  final String phoneNumber;

  /// Contact's email (optional)
  @override
  final String? email;

  /// Source of the contact (phone or community)
  @override
  final ContactSource source;

  /// Community user ID if from community source
  @override
  final String? communityUserId;

  /// Permission level for this contact
  @override
  final ContactPermission permission;

  /// Whether location sharing is currently active with this contact
  @override
  @JsonKey()
  final bool locationSharingEnabled;

  /// Whether this contact receives check-in notifications
  @override
  @JsonKey()
  final bool receivesCheckIns;

  /// Whether this contact receives emergency alerts
  @override
  @JsonKey()
  final bool receivesEmergencyAlerts;

  /// When this contact was added
  @override
  final DateTime addedAt;

  /// When this contact was last updated
  @override
  final DateTime? updatedAt;

  /// When this trusted contact relationship was revoked (if applicable)
  @override
  final DateTime? revokedAt;

  /// Notes about this contact
  @override
  final String? notes;

  @override
  String toString() {
    return 'TrustedContact(id: $id, userId: $userId, name: $name, phoneNumber: $phoneNumber, email: $email, source: $source, communityUserId: $communityUserId, permission: $permission, locationSharingEnabled: $locationSharingEnabled, receivesCheckIns: $receivesCheckIns, receivesEmergencyAlerts: $receivesEmergencyAlerts, addedAt: $addedAt, updatedAt: $updatedAt, revokedAt: $revokedAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrustedContactImpl &&
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

  /// Create a copy of TrustedContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrustedContactImplCopyWith<_$TrustedContactImpl> get copyWith =>
      __$$TrustedContactImplCopyWithImpl<_$TrustedContactImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrustedContactImplToJson(
      this,
    );
  }
}

abstract class _TrustedContact implements TrustedContact {
  const factory _TrustedContact(
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
      final String? notes}) = _$TrustedContactImpl;

  factory _TrustedContact.fromJson(Map<String, dynamic> json) =
      _$TrustedContactImpl.fromJson;

  /// Unique identifier for the trusted contact
  @override
  String get id;

  /// User ID who owns this trusted contact
  @override
  String get userId;

  /// Contact's name
  @override
  String get name;

  /// Contact's phone number
  @override
  String get phoneNumber;

  /// Contact's email (optional)
  @override
  String? get email;

  /// Source of the contact (phone or community)
  @override
  ContactSource get source;

  /// Community user ID if from community source
  @override
  String? get communityUserId;

  /// Permission level for this contact
  @override
  ContactPermission get permission;

  /// Whether location sharing is currently active with this contact
  @override
  bool get locationSharingEnabled;

  /// Whether this contact receives check-in notifications
  @override
  bool get receivesCheckIns;

  /// Whether this contact receives emergency alerts
  @override
  bool get receivesEmergencyAlerts;

  /// When this contact was added
  @override
  DateTime get addedAt;

  /// When this contact was last updated
  @override
  DateTime? get updatedAt;

  /// When this trusted contact relationship was revoked (if applicable)
  @override
  DateTime? get revokedAt;

  /// Notes about this contact
  @override
  String? get notes;

  /// Create a copy of TrustedContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrustedContactImplCopyWith<_$TrustedContactImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
