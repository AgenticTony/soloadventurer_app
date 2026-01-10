// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationModel {
  String get id;
  NotificationType get type;
  NotificationCategory get category;
  String get title;
  String get body;
  DateTime get scheduledAt;
  DateTime? get deliveredAt;
  DateTime? get readAt;
  DateTime? get dismissedAt;
  NotificationPriority get priority;
  Map<String, dynamic>? get data;
  bool get isActionable;
  List<NotificationAction>? get actions;
  String? get imageUrl;
  bool get isOngoing;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotificationModelCopyWith<NotificationModel> get copyWith =>
      _$NotificationModelCopyWithImpl<NotificationModel>(
          this as NotificationModel, _$identity);

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NotificationModel &&
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
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.isActionable, isActionable) ||
                other.isActionable == isActionable) &&
            const DeepCollectionEquality().equals(other.actions, actions) &&
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
      const DeepCollectionEquality().hash(data),
      isActionable,
      const DeepCollectionEquality().hash(actions),
      imageUrl,
      isOngoing);

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: $type, category: $category, title: $title, body: $body, scheduledAt: $scheduledAt, deliveredAt: $deliveredAt, readAt: $readAt, dismissedAt: $dismissedAt, priority: $priority, data: $data, isActionable: $isActionable, actions: $actions, imageUrl: $imageUrl, isOngoing: $isOngoing)';
  }
}

/// @nodoc
abstract mixin class $NotificationModelCopyWith<$Res> {
  factory $NotificationModelCopyWith(
          NotificationModel value, $Res Function(NotificationModel) _then) =
      _$NotificationModelCopyWithImpl;
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
class _$NotificationModelCopyWithImpl<$Res>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._self, this._then);

  final NotificationModel _self;
  final $Res Function(NotificationModel) _then;

  /// Create a copy of NotificationModel
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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _self.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveredAt: freezed == deliveredAt
          ? _self.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      readAt: freezed == readAt
          ? _self.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dismissedAt: freezed == dismissedAt
          ? _self.dismissedAt
          : dismissedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isActionable: null == isActionable
          ? _self.isActionable
          : isActionable // ignore: cast_nullable_to_non_nullable
              as bool,
      actions: freezed == actions
          ? _self.actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<NotificationAction>?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isOngoing: null == isOngoing
          ? _self.isOngoing
          : isOngoing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [NotificationModel].
extension NotificationModelPatterns on NotificationModel {
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
    TResult Function(_NotificationModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotificationModel() when $default != null:
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
    TResult Function(_NotificationModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationModel():
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
    TResult? Function(_NotificationModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationModel() when $default != null:
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
            bool isOngoing)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotificationModel() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.category,
            _that.title,
            _that.body,
            _that.scheduledAt,
            _that.deliveredAt,
            _that.readAt,
            _that.dismissedAt,
            _that.priority,
            _that.data,
            _that.isActionable,
            _that.actions,
            _that.imageUrl,
            _that.isOngoing);
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
            bool isOngoing)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationModel():
        return $default(
            _that.id,
            _that.type,
            _that.category,
            _that.title,
            _that.body,
            _that.scheduledAt,
            _that.deliveredAt,
            _that.readAt,
            _that.dismissedAt,
            _that.priority,
            _that.data,
            _that.isActionable,
            _that.actions,
            _that.imageUrl,
            _that.isOngoing);
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
            bool isOngoing)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationModel() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.category,
            _that.title,
            _that.body,
            _that.scheduledAt,
            _that.deliveredAt,
            _that.readAt,
            _that.dismissedAt,
            _that.priority,
            _that.data,
            _that.isActionable,
            _that.actions,
            _that.imageUrl,
            _that.isOngoing);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _NotificationModel implements NotificationModel {
  const _NotificationModel(
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
        _actions = actions;
  factory _NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

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

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NotificationModelCopyWith<_NotificationModel> get copyWith =>
      __$NotificationModelCopyWithImpl<_NotificationModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NotificationModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NotificationModel &&
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

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: $type, category: $category, title: $title, body: $body, scheduledAt: $scheduledAt, deliveredAt: $deliveredAt, readAt: $readAt, dismissedAt: $dismissedAt, priority: $priority, data: $data, isActionable: $isActionable, actions: $actions, imageUrl: $imageUrl, isOngoing: $isOngoing)';
  }
}

/// @nodoc
abstract mixin class _$NotificationModelCopyWith<$Res>
    implements $NotificationModelCopyWith<$Res> {
  factory _$NotificationModelCopyWith(
          _NotificationModel value, $Res Function(_NotificationModel) _then) =
      __$NotificationModelCopyWithImpl;
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
class __$NotificationModelCopyWithImpl<$Res>
    implements _$NotificationModelCopyWith<$Res> {
  __$NotificationModelCopyWithImpl(this._self, this._then);

  final _NotificationModel _self;
  final $Res Function(_NotificationModel) _then;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_NotificationModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _self.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveredAt: freezed == deliveredAt
          ? _self.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      readAt: freezed == readAt
          ? _self.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dismissedAt: freezed == dismissedAt
          ? _self.dismissedAt
          : dismissedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      data: freezed == data
          ? _self._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isActionable: null == isActionable
          ? _self.isActionable
          : isActionable // ignore: cast_nullable_to_non_nullable
              as bool,
      actions: freezed == actions
          ? _self._actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<NotificationAction>?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isOngoing: null == isOngoing
          ? _self.isOngoing
          : isOngoing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
