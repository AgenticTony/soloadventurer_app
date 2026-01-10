// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckInModel {
  String get id;
  String get userId;
  CheckInTriggerType get triggerType;
  CheckInStatus get status;
  DateTime? get scheduledTime;
  DateTime? get deadline;
  DateTime? get completedAt;
  CheckInLocation? get location;
  String? get statusMessage;
  String? get tripId;
  List<String> get notifyContactIds;
  bool get alertSent;
  DateTime? get alertSentAt;
  DateTime get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of CheckInModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CheckInModelCopyWith<CheckInModel> get copyWith =>
      _$CheckInModelCopyWithImpl<CheckInModel>(
          this as CheckInModel, _$identity);

  /// Serializes this CheckInModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CheckInModel &&
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
                .equals(other.notifyContactIds, notifyContactIds) &&
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
      const DeepCollectionEquality().hash(notifyContactIds),
      alertSent,
      alertSentAt,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'CheckInModel(id: $id, userId: $userId, triggerType: $triggerType, status: $status, scheduledTime: $scheduledTime, deadline: $deadline, completedAt: $completedAt, location: $location, statusMessage: $statusMessage, tripId: $tripId, notifyContactIds: $notifyContactIds, alertSent: $alertSent, alertSentAt: $alertSentAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $CheckInModelCopyWith<$Res> {
  factory $CheckInModelCopyWith(
          CheckInModel value, $Res Function(CheckInModel) _then) =
      _$CheckInModelCopyWithImpl;
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
class _$CheckInModelCopyWithImpl<$Res> implements $CheckInModelCopyWith<$Res> {
  _$CheckInModelCopyWithImpl(this._self, this._then);

  final CheckInModel _self;
  final $Res Function(CheckInModel) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      triggerType: null == triggerType
          ? _self.triggerType
          : triggerType // ignore: cast_nullable_to_non_nullable
              as CheckInTriggerType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CheckInStatus,
      scheduledTime: freezed == scheduledTime
          ? _self.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deadline: freezed == deadline
          ? _self.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as CheckInLocation?,
      statusMessage: freezed == statusMessage
          ? _self.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      notifyContactIds: null == notifyContactIds
          ? _self.notifyContactIds
          : notifyContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      alertSent: null == alertSent
          ? _self.alertSent
          : alertSent // ignore: cast_nullable_to_non_nullable
              as bool,
      alertSentAt: freezed == alertSentAt
          ? _self.alertSentAt
          : alertSentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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

  /// Create a copy of CheckInModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
      return null;
    }

    return $CheckInLocationCopyWith<$Res>(_self.location!, (value) {
      return _then(_self.copyWith(location: value));
    });
  }
}

/// Adds pattern-matching-related methods to [CheckInModel].
extension CheckInModelPatterns on CheckInModel {
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
    TResult Function(_CheckInModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckInModel() when $default != null:
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
    TResult Function(_CheckInModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInModel():
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
    TResult? Function(_CheckInModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInModel() when $default != null:
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
            DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckInModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.triggerType,
            _that.status,
            _that.scheduledTime,
            _that.deadline,
            _that.completedAt,
            _that.location,
            _that.statusMessage,
            _that.tripId,
            _that.notifyContactIds,
            _that.alertSent,
            _that.alertSentAt,
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
            DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInModel():
        return $default(
            _that.id,
            _that.userId,
            _that.triggerType,
            _that.status,
            _that.scheduledTime,
            _that.deadline,
            _that.completedAt,
            _that.location,
            _that.statusMessage,
            _that.tripId,
            _that.notifyContactIds,
            _that.alertSent,
            _that.alertSentAt,
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
            DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckInModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.triggerType,
            _that.status,
            _that.scheduledTime,
            _that.deadline,
            _that.completedAt,
            _that.location,
            _that.statusMessage,
            _that.tripId,
            _that.notifyContactIds,
            _that.alertSent,
            _that.alertSentAt,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CheckInModel implements CheckInModel {
  const _CheckInModel(
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
      : _notifyContactIds = notifyContactIds;
  factory _CheckInModel.fromJson(Map<String, dynamic> json) =>
      _$CheckInModelFromJson(json);

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

  /// Create a copy of CheckInModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CheckInModelCopyWith<_CheckInModel> get copyWith =>
      __$CheckInModelCopyWithImpl<_CheckInModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CheckInModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CheckInModel &&
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

  @override
  String toString() {
    return 'CheckInModel(id: $id, userId: $userId, triggerType: $triggerType, status: $status, scheduledTime: $scheduledTime, deadline: $deadline, completedAt: $completedAt, location: $location, statusMessage: $statusMessage, tripId: $tripId, notifyContactIds: $notifyContactIds, alertSent: $alertSent, alertSentAt: $alertSentAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$CheckInModelCopyWith<$Res>
    implements $CheckInModelCopyWith<$Res> {
  factory _$CheckInModelCopyWith(
          _CheckInModel value, $Res Function(_CheckInModel) _then) =
      __$CheckInModelCopyWithImpl;
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
class __$CheckInModelCopyWithImpl<$Res>
    implements _$CheckInModelCopyWith<$Res> {
  __$CheckInModelCopyWithImpl(this._self, this._then);

  final _CheckInModel _self;
  final $Res Function(_CheckInModel) _then;

  /// Create a copy of CheckInModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_CheckInModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      triggerType: null == triggerType
          ? _self.triggerType
          : triggerType // ignore: cast_nullable_to_non_nullable
              as CheckInTriggerType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CheckInStatus,
      scheduledTime: freezed == scheduledTime
          ? _self.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deadline: freezed == deadline
          ? _self.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as CheckInLocation?,
      statusMessage: freezed == statusMessage
          ? _self.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      tripId: freezed == tripId
          ? _self.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      notifyContactIds: null == notifyContactIds
          ? _self._notifyContactIds
          : notifyContactIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      alertSent: null == alertSent
          ? _self.alertSent
          : alertSent // ignore: cast_nullable_to_non_nullable
              as bool,
      alertSentAt: freezed == alertSentAt
          ? _self.alertSentAt
          : alertSentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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

  /// Create a copy of CheckInModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
      return null;
    }

    return $CheckInLocationCopyWith<$Res>(_self.location!, (value) {
      return _then(_self.copyWith(location: value));
    });
  }
}

// dart format on
