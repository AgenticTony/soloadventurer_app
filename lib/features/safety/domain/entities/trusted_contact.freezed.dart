// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trusted_contact.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrustedContact {
  /// Unique identifier for the trusted contact
  String get id;

  /// User ID who owns this trusted contact
  String get userId;

  /// Contact's name
  String get name;

  /// Contact's phone number
  String get phoneNumber;

  /// Contact's email (optional)
  String? get email;

  /// Source of the contact (phone or community)
  ContactSource get source;

  /// Community user ID if from community source
  String? get communityUserId;

  /// Permission level for this contact
  ContactPermission get permission;

  /// Whether location sharing is currently active with this contact
  bool get locationSharingEnabled;

  /// Whether this contact receives check-in notifications
  bool get receivesCheckIns;

  /// Whether this contact receives emergency alerts
  bool get receivesEmergencyAlerts;

  /// When this contact was added
  DateTime get addedAt;

  /// When this contact was last updated
  DateTime? get updatedAt;

  /// When this trusted contact relationship was revoked (if applicable)
  DateTime? get revokedAt;

  /// Notes about this contact
  String? get notes;

  /// Create a copy of TrustedContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TrustedContactCopyWith<TrustedContact> get copyWith =>
      _$TrustedContactCopyWithImpl<TrustedContact>(
          this as TrustedContact, _$identity);

  /// Serializes this TrustedContact to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TrustedContact &&
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

  @override
  String toString() {
    return 'TrustedContact(id: $id, userId: $userId, name: $name, phoneNumber: $phoneNumber, email: $email, source: $source, communityUserId: $communityUserId, permission: $permission, locationSharingEnabled: $locationSharingEnabled, receivesCheckIns: $receivesCheckIns, receivesEmergencyAlerts: $receivesEmergencyAlerts, addedAt: $addedAt, updatedAt: $updatedAt, revokedAt: $revokedAt, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class $TrustedContactCopyWith<$Res> {
  factory $TrustedContactCopyWith(
          TrustedContact value, $Res Function(TrustedContact) _then) =
      _$TrustedContactCopyWithImpl;
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
class _$TrustedContactCopyWithImpl<$Res>
    implements $TrustedContactCopyWith<$Res> {
  _$TrustedContactCopyWithImpl(this._self, this._then);

  final TrustedContact _self;
  final $Res Function(TrustedContact) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _self.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as ContactSource,
      communityUserId: freezed == communityUserId
          ? _self.communityUserId
          : communityUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      permission: null == permission
          ? _self.permission
          : permission // ignore: cast_nullable_to_non_nullable
              as ContactPermission,
      locationSharingEnabled: null == locationSharingEnabled
          ? _self.locationSharingEnabled
          : locationSharingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      receivesCheckIns: null == receivesCheckIns
          ? _self.receivesCheckIns
          : receivesCheckIns // ignore: cast_nullable_to_non_nullable
              as bool,
      receivesEmergencyAlerts: null == receivesEmergencyAlerts
          ? _self.receivesEmergencyAlerts
          : receivesEmergencyAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      addedAt: null == addedAt
          ? _self.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      revokedAt: freezed == revokedAt
          ? _self.revokedAt
          : revokedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [TrustedContact].
extension TrustedContactPatterns on TrustedContact {
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
    TResult Function(_TrustedContact value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TrustedContact() when $default != null:
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
    TResult Function(_TrustedContact value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrustedContact():
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
    TResult? Function(_TrustedContact value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrustedContact() when $default != null:
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
            String? notes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TrustedContact() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.name,
            _that.phoneNumber,
            _that.email,
            _that.source,
            _that.communityUserId,
            _that.permission,
            _that.locationSharingEnabled,
            _that.receivesCheckIns,
            _that.receivesEmergencyAlerts,
            _that.addedAt,
            _that.updatedAt,
            _that.revokedAt,
            _that.notes);
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
            String? notes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrustedContact():
        return $default(
            _that.id,
            _that.userId,
            _that.name,
            _that.phoneNumber,
            _that.email,
            _that.source,
            _that.communityUserId,
            _that.permission,
            _that.locationSharingEnabled,
            _that.receivesCheckIns,
            _that.receivesEmergencyAlerts,
            _that.addedAt,
            _that.updatedAt,
            _that.revokedAt,
            _that.notes);
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
            String? notes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrustedContact() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.name,
            _that.phoneNumber,
            _that.email,
            _that.source,
            _that.communityUserId,
            _that.permission,
            _that.locationSharingEnabled,
            _that.receivesCheckIns,
            _that.receivesEmergencyAlerts,
            _that.addedAt,
            _that.updatedAt,
            _that.revokedAt,
            _that.notes);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TrustedContact extends TrustedContact {
  const _TrustedContact(
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
  factory _TrustedContact.fromJson(Map<String, dynamic> json) =>
      _$TrustedContactFromJson(json);

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

  /// Create a copy of TrustedContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TrustedContactCopyWith<_TrustedContact> get copyWith =>
      __$TrustedContactCopyWithImpl<_TrustedContact>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TrustedContactToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TrustedContact &&
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

  @override
  String toString() {
    return 'TrustedContact(id: $id, userId: $userId, name: $name, phoneNumber: $phoneNumber, email: $email, source: $source, communityUserId: $communityUserId, permission: $permission, locationSharingEnabled: $locationSharingEnabled, receivesCheckIns: $receivesCheckIns, receivesEmergencyAlerts: $receivesEmergencyAlerts, addedAt: $addedAt, updatedAt: $updatedAt, revokedAt: $revokedAt, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class _$TrustedContactCopyWith<$Res>
    implements $TrustedContactCopyWith<$Res> {
  factory _$TrustedContactCopyWith(
          _TrustedContact value, $Res Function(_TrustedContact) _then) =
      __$TrustedContactCopyWithImpl;
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
class __$TrustedContactCopyWithImpl<$Res>
    implements _$TrustedContactCopyWith<$Res> {
  __$TrustedContactCopyWithImpl(this._self, this._then);

  final _TrustedContact _self;
  final $Res Function(_TrustedContact) _then;

  /// Create a copy of TrustedContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_TrustedContact(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _self.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as ContactSource,
      communityUserId: freezed == communityUserId
          ? _self.communityUserId
          : communityUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      permission: null == permission
          ? _self.permission
          : permission // ignore: cast_nullable_to_non_nullable
              as ContactPermission,
      locationSharingEnabled: null == locationSharingEnabled
          ? _self.locationSharingEnabled
          : locationSharingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      receivesCheckIns: null == receivesCheckIns
          ? _self.receivesCheckIns
          : receivesCheckIns // ignore: cast_nullable_to_non_nullable
              as bool,
      receivesEmergencyAlerts: null == receivesEmergencyAlerts
          ? _self.receivesEmergencyAlerts
          : receivesEmergencyAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      addedAt: null == addedAt
          ? _self.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      revokedAt: freezed == revokedAt
          ? _self.revokedAt
          : revokedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
