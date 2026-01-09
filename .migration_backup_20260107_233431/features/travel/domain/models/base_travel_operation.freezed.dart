// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_travel_operation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BaseTravelOperation {
  String get id;
  String get type;
  DateTime get timestamp;
  @OperationPriorityConverter()
  OperationPriority get priority;
  bool get requiresNetwork;
  Map<String, dynamic> get data;

  /// Create a copy of BaseTravelOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BaseTravelOperationCopyWith<BaseTravelOperation> get copyWith =>
      _$BaseTravelOperationCopyWithImpl<BaseTravelOperation>(
          this as BaseTravelOperation, _$identity);

  /// Serializes this BaseTravelOperation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BaseTravelOperation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.requiresNetwork, requiresNetwork) ||
                other.requiresNetwork == requiresNetwork) &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, timestamp, priority,
      requiresNetwork, const DeepCollectionEquality().hash(data));

  @override
  String toString() {
    return 'BaseTravelOperation(id: $id, type: $type, timestamp: $timestamp, priority: $priority, requiresNetwork: $requiresNetwork, data: $data)';
  }
}

/// @nodoc
abstract mixin class $BaseTravelOperationCopyWith<$Res> {
  factory $BaseTravelOperationCopyWith(
          BaseTravelOperation value, $Res Function(BaseTravelOperation) _then) =
      _$BaseTravelOperationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String type,
      DateTime timestamp,
      @OperationPriorityConverter() OperationPriority priority,
      bool requiresNetwork,
      Map<String, dynamic> data});
}

/// @nodoc
class _$BaseTravelOperationCopyWithImpl<$Res>
    implements $BaseTravelOperationCopyWith<$Res> {
  _$BaseTravelOperationCopyWithImpl(this._self, this._then);

  final BaseTravelOperation _self;
  final $Res Function(BaseTravelOperation) _then;

  /// Create a copy of BaseTravelOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? timestamp = null,
    Object? priority = null,
    Object? requiresNetwork = null,
    Object? data = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as OperationPriority,
      requiresNetwork: null == requiresNetwork
          ? _self.requiresNetwork
          : requiresNetwork // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// Adds pattern-matching-related methods to [BaseTravelOperation].
extension BaseTravelOperationPatterns on BaseTravelOperation {
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
    TResult Function(_BaseTravelOperation value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BaseTravelOperation() when $default != null:
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
    TResult Function(_BaseTravelOperation value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BaseTravelOperation():
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
    TResult? Function(_BaseTravelOperation value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BaseTravelOperation() when $default != null:
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
            String type,
            DateTime timestamp,
            @OperationPriorityConverter() OperationPriority priority,
            bool requiresNetwork,
            Map<String, dynamic> data)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BaseTravelOperation() when $default != null:
        return $default(_that.id, _that.type, _that.timestamp, _that.priority,
            _that.requiresNetwork, _that.data);
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
            String type,
            DateTime timestamp,
            @OperationPriorityConverter() OperationPriority priority,
            bool requiresNetwork,
            Map<String, dynamic> data)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BaseTravelOperation():
        return $default(_that.id, _that.type, _that.timestamp, _that.priority,
            _that.requiresNetwork, _that.data);
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
            String type,
            DateTime timestamp,
            @OperationPriorityConverter() OperationPriority priority,
            bool requiresNetwork,
            Map<String, dynamic> data)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BaseTravelOperation() when $default != null:
        return $default(_that.id, _that.type, _that.timestamp, _that.priority,
            _that.requiresNetwork, _that.data);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _BaseTravelOperation implements BaseTravelOperation {
  const _BaseTravelOperation(
      {required this.id,
      required this.type,
      required this.timestamp,
      @OperationPriorityConverter() this.priority = OperationPriority.low,
      this.requiresNetwork = true,
      final Map<String, dynamic> data = const {}})
      : _data = data;
  factory _BaseTravelOperation.fromJson(Map<String, dynamic> json) =>
      _$BaseTravelOperationFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  @OperationPriorityConverter()
  final OperationPriority priority;
  @override
  @JsonKey()
  final bool requiresNetwork;
  final Map<String, dynamic> _data;
  @override
  @JsonKey()
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  /// Create a copy of BaseTravelOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BaseTravelOperationCopyWith<_BaseTravelOperation> get copyWith =>
      __$BaseTravelOperationCopyWithImpl<_BaseTravelOperation>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BaseTravelOperationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BaseTravelOperation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.requiresNetwork, requiresNetwork) ||
                other.requiresNetwork == requiresNetwork) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, timestamp, priority,
      requiresNetwork, const DeepCollectionEquality().hash(_data));

  @override
  String toString() {
    return 'BaseTravelOperation(id: $id, type: $type, timestamp: $timestamp, priority: $priority, requiresNetwork: $requiresNetwork, data: $data)';
  }
}

/// @nodoc
abstract mixin class _$BaseTravelOperationCopyWith<$Res>
    implements $BaseTravelOperationCopyWith<$Res> {
  factory _$BaseTravelOperationCopyWith(_BaseTravelOperation value,
          $Res Function(_BaseTravelOperation) _then) =
      __$BaseTravelOperationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      DateTime timestamp,
      @OperationPriorityConverter() OperationPriority priority,
      bool requiresNetwork,
      Map<String, dynamic> data});
}

/// @nodoc
class __$BaseTravelOperationCopyWithImpl<$Res>
    implements _$BaseTravelOperationCopyWith<$Res> {
  __$BaseTravelOperationCopyWithImpl(this._self, this._then);

  final _BaseTravelOperation _self;
  final $Res Function(_BaseTravelOperation) _then;

  /// Create a copy of BaseTravelOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? timestamp = null,
    Object? priority = null,
    Object? requiresNetwork = null,
    Object? data = null,
  }) {
    return _then(_BaseTravelOperation(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as OperationPriority,
      requiresNetwork: null == requiresNetwork
          ? _self.requiresNetwork
          : requiresNetwork // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _self._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

// dart format on
