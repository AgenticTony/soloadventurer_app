// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SafetyAlert {
  /// Unique identifier for the safety alert
  String get id;

  /// User ID who triggered the alert
  String get userId;

  /// Type of safety alert
  SafetyAlertType get type;

  /// Current status of the alert
  SafetyAlertStatus get status;

  /// User's safety status message
  String? get message;

  /// Location data at time of alert
  SafetyAlertLocation? get location;

  /// IDs of trusted contacts who were notified
  List<String> get notifiedContactIds;

  /// IDs of trusted contacts who acknowledged the alert
  List<String> get acknowledgedByContactIds;

  /// When the alert was triggered
  DateTime get triggeredAt;

  /// When the alert was first acknowledged
  DateTime? get firstAcknowledgedAt;

  /// When the alert was resolved
  DateTime? get resolvedAt;

  /// When the alert was cancelled
  DateTime? get cancelledAt;

  /// Battery level at time of alert (0-100)
  int? get batteryLevel;

  /// Associated check-in ID (if alert is for missed check-in)
  String? get checkInId;

  /// Associated trip ID (if applicable)
  String? get tripId;

  /// Additional metadata
  Map<String, dynamic>? get metadata;

  /// When this safety alert was created
  DateTime get createdAt;

  /// When this safety alert was last updated
  DateTime? get updatedAt;

  /// Create a copy of SafetyAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SafetyAlertCopyWith<SafetyAlert> get copyWith =>
      _$SafetyAlertCopyWithImpl<SafetyAlert>(this as SafetyAlert, _$identity);

  /// Serializes this SafetyAlert to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SafetyAlert &&
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
    return 'SafetyAlert(id: $id, userId: $userId, type: $type, status: $status, message: $message, location: $location, notifiedContactIds: $notifiedContactIds, acknowledgedByContactIds: $acknowledgedByContactIds, triggeredAt: $triggeredAt, firstAcknowledgedAt: $firstAcknowledgedAt, resolvedAt: $resolvedAt, cancelledAt: $cancelledAt, batteryLevel: $batteryLevel, checkInId: $checkInId, tripId: $tripId, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $SafetyAlertCopyWith<$Res> {
  factory $SafetyAlertCopyWith(
          SafetyAlert value, $Res Function(SafetyAlert) _then) =
      _$SafetyAlertCopyWithImpl;
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
class _$SafetyAlertCopyWithImpl<$Res> implements $SafetyAlertCopyWith<$Res> {
  _$SafetyAlertCopyWithImpl(this._self, this._then);

  final SafetyAlert _self;
  final $Res Function(SafetyAlert) _then;

  /// Create a copy of SafetyAlert
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

  /// Create a copy of SafetyAlert
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

/// Adds pattern-matching-related methods to [SafetyAlert].
extension SafetyAlertPatterns on SafetyAlert {
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
    TResult Function(_SafetyAlert value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyAlert() when $default != null:
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
    TResult Function(_SafetyAlert value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyAlert():
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
    TResult? Function(_SafetyAlert value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyAlert() when $default != null:
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
      case _SafetyAlert() when $default != null:
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
      case _SafetyAlert():
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
      case _SafetyAlert() when $default != null:
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
class _SafetyAlert implements SafetyAlert {
  const _SafetyAlert(
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
        _metadata = metadata;
  factory _SafetyAlert.fromJson(Map<String, dynamic> json) =>
      _$SafetyAlertFromJson(json);

  /// Unique identifier for the safety alert
  @override
  final String id;

  /// User ID who triggered the alert
  @override
  final String userId;

  /// Type of safety alert
  @override
  final SafetyAlertType type;

  /// Current status of the alert
  @override
  final SafetyAlertStatus status;

  /// User's safety status message
  @override
  final String? message;

  /// Location data at time of alert
  @override
  final SafetyAlertLocation? location;

  /// IDs of trusted contacts who were notified
  final List<String> _notifiedContactIds;

  /// IDs of trusted contacts who were notified
  @override
  List<String> get notifiedContactIds {
    if (_notifiedContactIds is EqualUnmodifiableListView)
      return _notifiedContactIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifiedContactIds);
  }

  /// IDs of trusted contacts who acknowledged the alert
  final List<String> _acknowledgedByContactIds;

  /// IDs of trusted contacts who acknowledged the alert
  @override
  List<String> get acknowledgedByContactIds {
    if (_acknowledgedByContactIds is EqualUnmodifiableListView)
      return _acknowledgedByContactIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_acknowledgedByContactIds);
  }

  /// When the alert was triggered
  @override
  final DateTime triggeredAt;

  /// When the alert was first acknowledged
  @override
  final DateTime? firstAcknowledgedAt;

  /// When the alert was resolved
  @override
  final DateTime? resolvedAt;

  /// When the alert was cancelled
  @override
  final DateTime? cancelledAt;

  /// Battery level at time of alert (0-100)
  @override
  final int? batteryLevel;

  /// Associated check-in ID (if alert is for missed check-in)
  @override
  final String? checkInId;

  /// Associated trip ID (if applicable)
  @override
  final String? tripId;

  /// Additional metadata
  final Map<String, dynamic>? _metadata;

  /// Additional metadata
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// When this safety alert was created
  @override
  final DateTime createdAt;

  /// When this safety alert was last updated
  @override
  final DateTime? updatedAt;

  /// Create a copy of SafetyAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SafetyAlertCopyWith<_SafetyAlert> get copyWith =>
      __$SafetyAlertCopyWithImpl<_SafetyAlert>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SafetyAlertToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SafetyAlert &&
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
    return 'SafetyAlert(id: $id, userId: $userId, type: $type, status: $status, message: $message, location: $location, notifiedContactIds: $notifiedContactIds, acknowledgedByContactIds: $acknowledgedByContactIds, triggeredAt: $triggeredAt, firstAcknowledgedAt: $firstAcknowledgedAt, resolvedAt: $resolvedAt, cancelledAt: $cancelledAt, batteryLevel: $batteryLevel, checkInId: $checkInId, tripId: $tripId, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$SafetyAlertCopyWith<$Res>
    implements $SafetyAlertCopyWith<$Res> {
  factory _$SafetyAlertCopyWith(
          _SafetyAlert value, $Res Function(_SafetyAlert) _then) =
      __$SafetyAlertCopyWithImpl;
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
class __$SafetyAlertCopyWithImpl<$Res> implements _$SafetyAlertCopyWith<$Res> {
  __$SafetyAlertCopyWithImpl(this._self, this._then);

  final _SafetyAlert _self;
  final $Res Function(_SafetyAlert) _then;

  /// Create a copy of SafetyAlert
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
    return _then(_SafetyAlert(
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

  /// Create a copy of SafetyAlert
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

/// @nodoc
mixin _$SafetyAlertLocation {
  /// Latitude
  double get latitude;

  /// Longitude
  double get longitude;

  /// Accuracy of the location in meters
  double? get accuracy;

  /// Altitude in meters
  double? get altitude;

  /// Human-readable address
  String? get address;

  /// Place name (if applicable)
  String? get placeName;

  /// When this location was recorded
  DateTime get timestamp;

  /// Google Maps URL
  String? get mapsUrl;

  /// Create a copy of SafetyAlertLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SafetyAlertLocationCopyWith<SafetyAlertLocation> get copyWith =>
      _$SafetyAlertLocationCopyWithImpl<SafetyAlertLocation>(
          this as SafetyAlertLocation, _$identity);

  /// Serializes this SafetyAlertLocation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SafetyAlertLocation &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.altitude, altitude) ||
                other.altitude == altitude) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.mapsUrl, mapsUrl) || other.mapsUrl == mapsUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, accuracy,
      altitude, address, placeName, timestamp, mapsUrl);

  @override
  String toString() {
    return 'SafetyAlertLocation(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, address: $address, placeName: $placeName, timestamp: $timestamp, mapsUrl: $mapsUrl)';
  }
}

/// @nodoc
abstract mixin class $SafetyAlertLocationCopyWith<$Res> {
  factory $SafetyAlertLocationCopyWith(
          SafetyAlertLocation value, $Res Function(SafetyAlertLocation) _then) =
      _$SafetyAlertLocationCopyWithImpl;
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      double? accuracy,
      double? altitude,
      String? address,
      String? placeName,
      DateTime timestamp,
      String? mapsUrl});
}

/// @nodoc
class _$SafetyAlertLocationCopyWithImpl<$Res>
    implements $SafetyAlertLocationCopyWith<$Res> {
  _$SafetyAlertLocationCopyWithImpl(this._self, this._then);

  final SafetyAlertLocation _self;
  final $Res Function(SafetyAlertLocation) _then;

  /// Create a copy of SafetyAlertLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracy = freezed,
    Object? altitude = freezed,
    Object? address = freezed,
    Object? placeName = freezed,
    Object? timestamp = null,
    Object? mapsUrl = freezed,
  }) {
    return _then(_self.copyWith(
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      accuracy: freezed == accuracy
          ? _self.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as double?,
      altitude: freezed == altitude
          ? _self.altitude
          : altitude // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      placeName: freezed == placeName
          ? _self.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      mapsUrl: freezed == mapsUrl
          ? _self.mapsUrl
          : mapsUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [SafetyAlertLocation].
extension SafetyAlertLocationPatterns on SafetyAlertLocation {
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
    TResult Function(_SafetyAlertLocation value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyAlertLocation() when $default != null:
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
    TResult Function(_SafetyAlertLocation value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyAlertLocation():
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
    TResult? Function(_SafetyAlertLocation value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyAlertLocation() when $default != null:
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
            double latitude,
            double longitude,
            double? accuracy,
            double? altitude,
            String? address,
            String? placeName,
            DateTime timestamp,
            String? mapsUrl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SafetyAlertLocation() when $default != null:
        return $default(
            _that.latitude,
            _that.longitude,
            _that.accuracy,
            _that.altitude,
            _that.address,
            _that.placeName,
            _that.timestamp,
            _that.mapsUrl);
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
            double latitude,
            double longitude,
            double? accuracy,
            double? altitude,
            String? address,
            String? placeName,
            DateTime timestamp,
            String? mapsUrl)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyAlertLocation():
        return $default(
            _that.latitude,
            _that.longitude,
            _that.accuracy,
            _that.altitude,
            _that.address,
            _that.placeName,
            _that.timestamp,
            _that.mapsUrl);
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
            double latitude,
            double longitude,
            double? accuracy,
            double? altitude,
            String? address,
            String? placeName,
            DateTime timestamp,
            String? mapsUrl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SafetyAlertLocation() when $default != null:
        return $default(
            _that.latitude,
            _that.longitude,
            _that.accuracy,
            _that.altitude,
            _that.address,
            _that.placeName,
            _that.timestamp,
            _that.mapsUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SafetyAlertLocation implements SafetyAlertLocation {
  const _SafetyAlertLocation(
      {required this.latitude,
      required this.longitude,
      this.accuracy,
      this.altitude,
      this.address,
      this.placeName,
      required this.timestamp,
      this.mapsUrl});
  factory _SafetyAlertLocation.fromJson(Map<String, dynamic> json) =>
      _$SafetyAlertLocationFromJson(json);

  /// Latitude
  @override
  final double latitude;

  /// Longitude
  @override
  final double longitude;

  /// Accuracy of the location in meters
  @override
  final double? accuracy;

  /// Altitude in meters
  @override
  final double? altitude;

  /// Human-readable address
  @override
  final String? address;

  /// Place name (if applicable)
  @override
  final String? placeName;

  /// When this location was recorded
  @override
  final DateTime timestamp;

  /// Google Maps URL
  @override
  final String? mapsUrl;

  /// Create a copy of SafetyAlertLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SafetyAlertLocationCopyWith<_SafetyAlertLocation> get copyWith =>
      __$SafetyAlertLocationCopyWithImpl<_SafetyAlertLocation>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SafetyAlertLocationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SafetyAlertLocation &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.altitude, altitude) ||
                other.altitude == altitude) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.mapsUrl, mapsUrl) || other.mapsUrl == mapsUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, accuracy,
      altitude, address, placeName, timestamp, mapsUrl);

  @override
  String toString() {
    return 'SafetyAlertLocation(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, address: $address, placeName: $placeName, timestamp: $timestamp, mapsUrl: $mapsUrl)';
  }
}

/// @nodoc
abstract mixin class _$SafetyAlertLocationCopyWith<$Res>
    implements $SafetyAlertLocationCopyWith<$Res> {
  factory _$SafetyAlertLocationCopyWith(_SafetyAlertLocation value,
          $Res Function(_SafetyAlertLocation) _then) =
      __$SafetyAlertLocationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      double? accuracy,
      double? altitude,
      String? address,
      String? placeName,
      DateTime timestamp,
      String? mapsUrl});
}

/// @nodoc
class __$SafetyAlertLocationCopyWithImpl<$Res>
    implements _$SafetyAlertLocationCopyWith<$Res> {
  __$SafetyAlertLocationCopyWithImpl(this._self, this._then);

  final _SafetyAlertLocation _self;
  final $Res Function(_SafetyAlertLocation) _then;

  /// Create a copy of SafetyAlertLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracy = freezed,
    Object? altitude = freezed,
    Object? address = freezed,
    Object? placeName = freezed,
    Object? timestamp = null,
    Object? mapsUrl = freezed,
  }) {
    return _then(_SafetyAlertLocation(
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      accuracy: freezed == accuracy
          ? _self.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as double?,
      altitude: freezed == altitude
          ? _self.altitude
          : altitude // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      placeName: freezed == placeName
          ? _self.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      mapsUrl: freezed == mapsUrl
          ? _self.mapsUrl
          : mapsUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
