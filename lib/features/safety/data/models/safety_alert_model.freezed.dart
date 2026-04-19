// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_alert_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SafetyAlertModel {
  String get id;
  String get userId;
  SafetyAlertType get type;
  SafetyAlertStatus get status;
  String? get message;
  SafetyAlertLocation? get location;
  List<String> get notifiedContactIds;
  List<String> get acknowledgedByContactIds;
  DateTime get triggeredAt;
  DateTime? get firstAcknowledgedAt;
  DateTime? get resolvedAt;
  DateTime? get cancelledAt;
  int? get batteryLevel;
  String? get checkInId;
  String? get tripId;
  Map<String, dynamic>? get metadata;
  DateTime get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of SafetyAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SafetyAlertModelCopyWith<SafetyAlertModel> get copyWith =>
      _$SafetyAlertModelCopyWithImpl<SafetyAlertModel>(
          this as SafetyAlertModel, _$identity);

  /// Serializes this SafetyAlertModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SafetyAlertModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality()
                .equals(other.notifiedContactIds, notifiedContactIds) &&
            const DeepCollectionEquality().equals(
                other.acknowledgedByContactIds, acknowledgedByContactIds) &&
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
            const DeepCollectionEquality().equals(other.metadata, metadata) &&
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
      const DeepCollectionEquality().hash(notifiedContactIds),
      const DeepCollectionEquality().hash(acknowledgedByContactIds),
      triggeredAt,
      firstAcknowledgedAt,
      resolvedAt,
      cancelledAt,
      batteryLevel,
      checkInId,
      tripId,
      const DeepCollectionEquality().hash(metadata),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'SafetyAlertModel(id: $id, userId: $userId, type: $type, status: $status, message: $message, location: $location, notifiedContactIds: $notifiedContactIds, acknowledgedByContactIds: $acknowledgedByContactIds, triggeredAt: $triggeredAt, firstAcknowledgedAt: $firstAcknowledgedAt, resolvedAt: $resolvedAt, cancelledAt: $cancelledAt, batteryLevel: $batteryLevel, checkInId: $checkInId, tripId: $tripId, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $SafetyAlertModelCopyWith<$Res> {
  factory $SafetyAlertModelCopyWith(
          SafetyAlertModel value, $Res Function(SafetyAlertModel) _then) =
      _$SafetyAlertModelCopyWithImpl;
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
class _$SafetyAlertModelCopyWithImpl<$Res>
    implements $SafetyAlertModelCopyWith<$Res> {
  _$SafetyAlertModelCopyWithImpl(this._self, this._then);

  final SafetyAlertModel _self;
  final $Res Function(SafetyAlertModel) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as SafetyAlertType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SafetyAlertStatus,
      message: freezed == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as SafetyAlertLocation?,
      notifiedContactIds: null == notifiedContactIds
          ? _self.notifiedContactIds
          : notifiedContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      acknowledgedByContactIds: null == acknowledgedByContactIds
          ? _self.acknowledgedByContactIds
          : acknowledgedByContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      triggeredAt: null == triggeredAt
          ? _self.triggeredAt
          : triggeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      firstAcknowledgedAt: freezed == firstAcknowledgedAt
          ? _self.firstAcknowledgedAt
          : firstAcknowledgedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _self.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _self.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      batteryLevel: freezed == batteryLevel
          ? _self.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      checkInId: freezed == checkInId
          ? _self.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }

  /// Create a copy of SafetyAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SafetyAlertLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
      return null;
    }

    return $SafetyAlertLocationCopyWith<$Res>(_self.location!, (value) {
      return _then(_self.copyWith(location: value));
    });
  }
}

/// Adds pattern-matching-related methods to [SafetyAlertModel].
extension SafetyAlertModelPatterns on SafetyAlertModel {
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
    TResult Function(_SafetyAlertModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyAlertModel() when $default != null:
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
    TResult Function(_SafetyAlertModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyAlertModel():
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
    TResult? Function(_SafetyAlertModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyAlertModel() when $default != null:
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
            DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyAlertModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.type,
            _that.status,
            _that.message,
            _that.location,
            _that.notifiedContactIds,
            _that.acknowledgedByContactIds,
            _that.triggeredAt,
            _that.firstAcknowledgedAt,
            _that.resolvedAt,
            _that.cancelledAt,
            _that.batteryLevel,
            _that.checkInId,
            _that.tripId,
            _that.metadata,
            _that.createdAt,
            _that.updatedAt);
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
            DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyAlertModel():
        return $default(
            _that.id,
            _that.userId,
            _that.type,
            _that.status,
            _that.message,
            _that.location,
            _that.notifiedContactIds,
            _that.acknowledgedByContactIds,
            _that.triggeredAt,
            _that.firstAcknowledgedAt,
            _that.resolvedAt,
            _that.cancelledAt,
            _that.batteryLevel,
            _that.checkInId,
            _that.tripId,
            _that.metadata,
            _that.createdAt,
            _that.updatedAt);
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
            DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyAlertModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.type,
            _that.status,
            _that.message,
            _that.location,
            _that.notifiedContactIds,
            _that.acknowledgedByContactIds,
            _that.triggeredAt,
            _that.firstAcknowledgedAt,
            _that.resolvedAt,
            _that.cancelledAt,
            _that.batteryLevel,
            _that.checkInId,
            _that.tripId,
            _that.metadata,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SafetyAlertModel extends SafetyAlertModel {
  const _SafetyAlertModel(
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
  factory _SafetyAlertModel.fromJson(Map<String, dynamic> json) =>
      _$SafetyAlertModelFromJson(json);

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

  /// Create a copy of SafetyAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SafetyAlertModelCopyWith<_SafetyAlertModel> get copyWith =>
      __$SafetyAlertModelCopyWithImpl<_SafetyAlertModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SafetyAlertModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SafetyAlertModel &&
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

  @override
  String toString() {
    return 'SafetyAlertModel(id: $id, userId: $userId, type: $type, status: $status, message: $message, location: $location, notifiedContactIds: $notifiedContactIds, acknowledgedByContactIds: $acknowledgedByContactIds, triggeredAt: $triggeredAt, firstAcknowledgedAt: $firstAcknowledgedAt, resolvedAt: $resolvedAt, cancelledAt: $cancelledAt, batteryLevel: $batteryLevel, checkInId: $checkInId, tripId: $tripId, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$SafetyAlertModelCopyWith<$Res>
    implements $SafetyAlertModelCopyWith<$Res> {
  factory _$SafetyAlertModelCopyWith(
          _SafetyAlertModel value, $Res Function(_SafetyAlertModel) _then) =
      __$SafetyAlertModelCopyWithImpl;
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
class __$SafetyAlertModelCopyWithImpl<$Res>
    implements _$SafetyAlertModelCopyWith<$Res> {
  __$SafetyAlertModelCopyWithImpl(this._self, this._then);

  final _SafetyAlertModel _self;
  final $Res Function(_SafetyAlertModel) _then;

  /// Create a copy of SafetyAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_SafetyAlertModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as SafetyAlertType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SafetyAlertStatus,
      message: freezed == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as SafetyAlertLocation?,
      notifiedContactIds: null == notifiedContactIds
          ? _self._notifiedContactIds
          : notifiedContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      acknowledgedByContactIds: null == acknowledgedByContactIds
          ? _self._acknowledgedByContactIds
          : acknowledgedByContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      triggeredAt: null == triggeredAt
          ? _self.triggeredAt
          : triggeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      firstAcknowledgedAt: freezed == firstAcknowledgedAt
          ? _self.firstAcknowledgedAt
          : firstAcknowledgedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _self.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _self.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      batteryLevel: freezed == batteryLevel
          ? _self.batteryLevel
          : batteryLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      checkInId: freezed == checkInId
          ? _self.checkInId
          : checkInId // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }

  /// Create a copy of SafetyAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SafetyAlertLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
      return null;
    }

    return $SafetyAlertLocationCopyWith<$Res>(_self.location!, (value) {
      return _then(_self.copyWith(location: value));
    });
  }
}

// dart format on
