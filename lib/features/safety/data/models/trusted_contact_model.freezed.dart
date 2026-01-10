// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trusted_contact_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrustedContactModel {
  String get id;
  String get userId;
  String get name;
  String get phoneNumber;
  String? get email;
  ContactSource get source;
  String? get communityUserId;
  ContactPermission get permission;
  bool get locationSharingEnabled;
  bool get receivesCheckIns;
  bool get receivesEmergencyAlerts;
  DateTime get addedAt;
  DateTime? get updatedAt;
  DateTime? get revokedAt;
  String? get notes;

  /// Create a copy of TrustedContactModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TrustedContactModelCopyWith<TrustedContactModel> get copyWith =>
      _$TrustedContactModelCopyWithImpl<TrustedContactModel>(
          this as TrustedContactModel, _$identity);

  /// Serializes this TrustedContactModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TrustedContactModel &&
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
    return 'TrustedContactModel(id: $id, userId: $userId, name: $name, phoneNumber: $phoneNumber, email: $email, source: $source, communityUserId: $communityUserId, permission: $permission, locationSharingEnabled: $locationSharingEnabled, receivesCheckIns: $receivesCheckIns, receivesEmergencyAlerts: $receivesEmergencyAlerts, addedAt: $addedAt, updatedAt: $updatedAt, revokedAt: $revokedAt, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class $TrustedContactModelCopyWith<$Res> {
  factory $TrustedContactModelCopyWith(
          TrustedContactModel value, $Res Function(TrustedContactModel) _then) =
      _$TrustedContactModelCopyWithImpl;
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
class _$TrustedContactModelCopyWithImpl<$Res>
    implements $TrustedContactModelCopyWith<$Res> {
  _$TrustedContactModelCopyWithImpl(this._self, this._then);

  final TrustedContactModel _self;
  final $Res Function(TrustedContactModel) _then;

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

/// Adds pattern-matching-related methods to [TrustedContactModel].
extension TrustedContactModelPatterns on TrustedContactModel {
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
    TResult Function(_TrustedContactModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TrustedContactModel() when $default != null:
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
    TResult Function(_TrustedContactModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrustedContactModel():
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
    TResult? Function(_TrustedContactModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrustedContactModel() when $default != null:
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
      case _TrustedContactModel() when $default != null:
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
      case _TrustedContactModel():
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
      case _TrustedContactModel() when $default != null:
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
class _TrustedContactModel implements TrustedContactModel {
  const _TrustedContactModel(
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
  factory _TrustedContactModel.fromJson(Map<String, dynamic> json) =>
      _$TrustedContactModelFromJson(json);

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

  /// Create a copy of TrustedContactModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TrustedContactModelCopyWith<_TrustedContactModel> get copyWith =>
      __$TrustedContactModelCopyWithImpl<_TrustedContactModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TrustedContactModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TrustedContactModel &&
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
    return 'TrustedContactModel(id: $id, userId: $userId, name: $name, phoneNumber: $phoneNumber, email: $email, source: $source, communityUserId: $communityUserId, permission: $permission, locationSharingEnabled: $locationSharingEnabled, receivesCheckIns: $receivesCheckIns, receivesEmergencyAlerts: $receivesEmergencyAlerts, addedAt: $addedAt, updatedAt: $updatedAt, revokedAt: $revokedAt, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class _$TrustedContactModelCopyWith<$Res>
    implements $TrustedContactModelCopyWith<$Res> {
  factory _$TrustedContactModelCopyWith(_TrustedContactModel value,
          $Res Function(_TrustedContactModel) _then) =
      __$TrustedContactModelCopyWithImpl;
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
class __$TrustedContactModelCopyWithImpl<$Res>
    implements _$TrustedContactModelCopyWith<$Res> {
  __$TrustedContactModelCopyWithImpl(this._self, this._then);

  final _TrustedContactModel _self;
  final $Res Function(_TrustedContactModel) _then;

  /// Create a copy of TrustedContactModel
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
    return _then(_TrustedContactModel(
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
