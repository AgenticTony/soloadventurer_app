// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'travel_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationAction _$NotificationActionFromJson(Map<String, dynamic> json) {
  return _NotificationAction.fromJson(json);
}

/// @nodoc
mixin _$NotificationAction {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  NotificationActionType get type => throw _privateConstructorUsedError;
  String? get deepLink => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this NotificationAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationActionCopyWith<NotificationAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationActionCopyWith<$Res> {
  factory $NotificationActionCopyWith(
          NotificationAction value, $Res Function(NotificationAction) then) =
      _$NotificationActionCopyWithImpl<$Res, NotificationAction>;
  @useResult
  $Res call(
      {String id,
      String label,
      NotificationActionType type,
      String? deepLink,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$NotificationActionCopyWithImpl<$Res, $Val extends NotificationAction>
    implements $NotificationActionCopyWith<$Res> {
  _$NotificationActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? type = null,
    Object? deepLink = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationActionType,
      deepLink: freezed == deepLink
          ? _value.deepLink
          : deepLink // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationActionImplCopyWith<$Res>
    implements $NotificationActionCopyWith<$Res> {
  factory _$$NotificationActionImplCopyWith(_$NotificationActionImpl value,
          $Res Function(_$NotificationActionImpl) then) =
      __$$NotificationActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      NotificationActionType type,
      String? deepLink,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$NotificationActionImplCopyWithImpl<$Res>
    extends _$NotificationActionCopyWithImpl<$Res, _$NotificationActionImpl>
    implements _$$NotificationActionImplCopyWith<$Res> {
  __$$NotificationActionImplCopyWithImpl(_$NotificationActionImpl _value,
      $Res Function(_$NotificationActionImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? type = null,
    Object? deepLink = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$NotificationActionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationActionType,
      deepLink: freezed == deepLink
          ? _value.deepLink
          : deepLink // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationActionImpl implements _NotificationAction {
  const _$NotificationActionImpl(
      {required this.id,
      required this.label,
      required this.type,
      this.deepLink,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$NotificationActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationActionImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final NotificationActionType type;
  @override
  final String? deepLink;
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
  String toString() {
    return 'NotificationAction(id: $id, label: $label, type: $type, deepLink: $deepLink, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.deepLink, deepLink) ||
                other.deepLink == deepLink) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, label, type, deepLink,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationActionImplCopyWith<_$NotificationActionImpl> get copyWith =>
      __$$NotificationActionImplCopyWithImpl<_$NotificationActionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationActionImplToJson(
      this,
    );
  }
}

abstract class _NotificationAction implements NotificationAction {
  const factory _NotificationAction(
      {required final String id,
      required final String label,
      required final NotificationActionType type,
      final String? deepLink,
      final Map<String, dynamic>? metadata}) = _$NotificationActionImpl;

  factory _NotificationAction.fromJson(Map<String, dynamic> json) =
      _$NotificationActionImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  NotificationActionType get type;
  @override
  String? get deepLink;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationActionImplCopyWith<_$NotificationActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TravelNotification _$TravelNotificationFromJson(Map<String, dynamic> json) {
  return _TravelNotification.fromJson(json);
}

/// @nodoc
mixin _$TravelNotification {
  String get id => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  NotificationCategory get category => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime? get readAt => throw _privateConstructorUsedError;
  DateTime? get dismissedAt => throw _privateConstructorUsedError;
  NotificationPriority get priority => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;
  bool get isActionable => throw _privateConstructorUsedError;
  List<NotificationAction>? get actions => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  bool get isOngoing => throw _privateConstructorUsedError;

  /// Serializes this TravelNotification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TravelNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TravelNotificationCopyWith<TravelNotification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TravelNotificationCopyWith<$Res> {
  factory $TravelNotificationCopyWith(
          TravelNotification value, $Res Function(TravelNotification) then) =
      _$TravelNotificationCopyWithImpl<$Res, TravelNotification>;
  @useResult
  $Res call(
      {String id,
      NotificationType type,
      NotificationCategory category,
      String title,
      String body,
      DateTime scheduledAt,
      DateTime? deliveredAt,
      DateTime? readAt,
      DateTime? dismissedAt,
      NotificationPriority priority,
      Map<String, dynamic>? data,
      bool isActionable,
      List<NotificationAction>? actions,
      String? imageUrl,
      bool isOngoing});
}

/// @nodoc
class _$TravelNotificationCopyWithImpl<$Res, $Val extends TravelNotification>
    implements $TravelNotificationCopyWith<$Res> {
  _$TravelNotificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TravelNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? category = null,
    Object? title = null,
    Object? body = null,
    Object? scheduledAt = null,
    Object? deliveredAt = freezed,
    Object? readAt = freezed,
    Object? dismissedAt = freezed,
    Object? priority = null,
    Object? data = freezed,
    Object? isActionable = null,
    Object? actions = freezed,
    Object? imageUrl = freezed,
    Object? isOngoing = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dismissedAt: freezed == dismissedAt
          ? _value.dismissedAt
          : dismissedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isActionable: null == isActionable
          ? _value.isActionable
          : isActionable // ignore: cast_nullable_to_non_nullable
              as bool,
      actions: freezed == actions
          ? _value.actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<NotificationAction>?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isOngoing: null == isOngoing
          ? _value.isOngoing
          : isOngoing // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TravelNotificationImplCopyWith<$Res>
    implements $TravelNotificationCopyWith<$Res> {
  factory _$$TravelNotificationImplCopyWith(_$TravelNotificationImpl value,
          $Res Function(_$TravelNotificationImpl) then) =
      __$$TravelNotificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      NotificationType type,
      NotificationCategory category,
      String title,
      String body,
      DateTime scheduledAt,
      DateTime? deliveredAt,
      DateTime? readAt,
      DateTime? dismissedAt,
      NotificationPriority priority,
      Map<String, dynamic>? data,
      bool isActionable,
      List<NotificationAction>? actions,
      String? imageUrl,
      bool isOngoing});
}

/// @nodoc
class __$$TravelNotificationImplCopyWithImpl<$Res>
    extends _$TravelNotificationCopyWithImpl<$Res, _$TravelNotificationImpl>
    implements _$$TravelNotificationImplCopyWith<$Res> {
  __$$TravelNotificationImplCopyWithImpl(_$TravelNotificationImpl _value,
      $Res Function(_$TravelNotificationImpl) _then)
      : super(_value, _then);

  /// Create a copy of TravelNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? category = null,
    Object? title = null,
    Object? body = null,
    Object? scheduledAt = null,
    Object? deliveredAt = freezed,
    Object? readAt = freezed,
    Object? dismissedAt = freezed,
    Object? priority = null,
    Object? data = freezed,
    Object? isActionable = null,
    Object? actions = freezed,
    Object? imageUrl = freezed,
    Object? isOngoing = null,
  }) {
    return _then(_$TravelNotificationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dismissedAt: freezed == dismissedAt
          ? _value.dismissedAt
          : dismissedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isActionable: null == isActionable
          ? _value.isActionable
          : isActionable // ignore: cast_nullable_to_non_nullable
              as bool,
      actions: freezed == actions
          ? _value._actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<NotificationAction>?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isOngoing: null == isOngoing
          ? _value.isOngoing
          : isOngoing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TravelNotificationImpl extends _TravelNotification {
  const _$TravelNotificationImpl(
      {required this.id,
      required this.type,
      required this.category,
      required this.title,
      required this.body,
      required this.scheduledAt,
      this.deliveredAt,
      this.readAt,
      this.dismissedAt,
      this.priority = NotificationPriority.normal,
      final Map<String, dynamic>? data,
      this.isActionable = false,
      final List<NotificationAction>? actions,
      this.imageUrl,
      this.isOngoing = false})
      : _data = data,
        _actions = actions,
        super._();

  factory _$TravelNotificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$TravelNotificationImplFromJson(json);

  @override
  final String id;
  @override
  final NotificationType type;
  @override
  final NotificationCategory category;
  @override
  final String title;
  @override
  final String body;
  @override
  final DateTime scheduledAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime? readAt;
  @override
  final DateTime? dismissedAt;
  @override
  @JsonKey()
  final NotificationPriority priority;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final bool isActionable;
  final List<NotificationAction>? _actions;
  @override
  List<NotificationAction>? get actions {
    final value = _actions;
    if (value == null) return null;
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final bool isOngoing;

  @override
  String toString() {
    return 'TravelNotification(id: $id, type: $type, category: $category, title: $title, body: $body, scheduledAt: $scheduledAt, deliveredAt: $deliveredAt, readAt: $readAt, dismissedAt: $dismissedAt, priority: $priority, data: $data, isActionable: $isActionable, actions: $actions, imageUrl: $imageUrl, isOngoing: $isOngoing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TravelNotificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.dismissedAt, dismissedAt) ||
                other.dismissedAt == dismissedAt) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.isActionable, isActionable) ||
                other.isActionable == isActionable) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isOngoing, isOngoing) ||
                other.isOngoing == isOngoing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      category,
      title,
      body,
      scheduledAt,
      deliveredAt,
      readAt,
      dismissedAt,
      priority,
      const DeepCollectionEquality().hash(_data),
      isActionable,
      const DeepCollectionEquality().hash(_actions),
      imageUrl,
      isOngoing);

  /// Create a copy of TravelNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TravelNotificationImplCopyWith<_$TravelNotificationImpl> get copyWith =>
      __$$TravelNotificationImplCopyWithImpl<_$TravelNotificationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TravelNotificationImplToJson(
      this,
    );
  }
}

abstract class _TravelNotification extends TravelNotification {
  const factory _TravelNotification(
      {required final String id,
      required final NotificationType type,
      required final NotificationCategory category,
      required final String title,
      required final String body,
      required final DateTime scheduledAt,
      final DateTime? deliveredAt,
      final DateTime? readAt,
      final DateTime? dismissedAt,
      final NotificationPriority priority,
      final Map<String, dynamic>? data,
      final bool isActionable,
      final List<NotificationAction>? actions,
      final String? imageUrl,
      final bool isOngoing}) = _$TravelNotificationImpl;
  const _TravelNotification._() : super._();

  factory _TravelNotification.fromJson(Map<String, dynamic> json) =
      _$TravelNotificationImpl.fromJson;

  @override
  String get id;
  @override
  NotificationType get type;
  @override
  NotificationCategory get category;
  @override
  String get title;
  @override
  String get body;
  @override
  DateTime get scheduledAt;
  @override
  DateTime? get deliveredAt;
  @override
  DateTime? get readAt;
  @override
  DateTime? get dismissedAt;
  @override
  NotificationPriority get priority;
  @override
  Map<String, dynamic>? get data;
  @override
  bool get isActionable;
  @override
  List<NotificationAction>? get actions;
  @override
  String? get imageUrl;
  @override
  bool get isOngoing;

  /// Create a copy of TravelNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TravelNotificationImplCopyWith<_$TravelNotificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
