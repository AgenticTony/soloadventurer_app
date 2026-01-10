// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_travel_operation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BaseTravelOperation _$BaseTravelOperationFromJson(Map<String, dynamic> json) {
  return _BaseTravelOperation.fromJson(json);
}

/// @nodoc
mixin _$BaseTravelOperation {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  bool get requiresNetwork => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;

  /// Serializes this BaseTravelOperation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BaseTravelOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaseTravelOperationCopyWith<BaseTravelOperation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaseTravelOperationCopyWith<$Res> {
  factory $BaseTravelOperationCopyWith(
          BaseTravelOperation value, $Res Function(BaseTravelOperation) then) =
      _$BaseTravelOperationCopyWithImpl<$Res, BaseTravelOperation>;
  @useResult
  $Res call(
      {String id,
      String type,
      DateTime timestamp,
      int priority,
      bool requiresNetwork,
      Map<String, dynamic> data});
}

/// @nodoc
class _$BaseTravelOperationCopyWithImpl<$Res, $Val extends BaseTravelOperation>
    implements $BaseTravelOperationCopyWith<$Res> {
  _$BaseTravelOperationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      requiresNetwork: null == requiresNetwork
          ? _value.requiresNetwork
          : requiresNetwork // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BaseTravelOperationImplCopyWith<$Res>
    implements $BaseTravelOperationCopyWith<$Res> {
  factory _$$BaseTravelOperationImplCopyWith(_$BaseTravelOperationImpl value,
          $Res Function(_$BaseTravelOperationImpl) then) =
      __$$BaseTravelOperationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      DateTime timestamp,
      int priority,
      bool requiresNetwork,
      Map<String, dynamic> data});
}

/// @nodoc
class __$$BaseTravelOperationImplCopyWithImpl<$Res>
    extends _$BaseTravelOperationCopyWithImpl<$Res, _$BaseTravelOperationImpl>
    implements _$$BaseTravelOperationImplCopyWith<$Res> {
  __$$BaseTravelOperationImplCopyWithImpl(_$BaseTravelOperationImpl _value,
      $Res Function(_$BaseTravelOperationImpl) _then)
      : super(_value, _then);

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
    return _then(_$BaseTravelOperationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      requiresNetwork: null == requiresNetwork
          ? _value.requiresNetwork
          : requiresNetwork // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BaseTravelOperationImpl implements _BaseTravelOperation {
  const _$BaseTravelOperationImpl(
      {required this.id,
      required this.type,
      required this.timestamp,
      this.priority = 1,
      this.requiresNetwork = true,
      final Map<String, dynamic> data = const {}})
      : _data = data;

  factory _$BaseTravelOperationImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaseTravelOperationImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final int priority;
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

  @override
  String toString() {
    return 'BaseTravelOperation(id: $id, type: $type, timestamp: $timestamp, priority: $priority, requiresNetwork: $requiresNetwork, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseTravelOperationImpl &&
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

  /// Create a copy of BaseTravelOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseTravelOperationImplCopyWith<_$BaseTravelOperationImpl> get copyWith =>
      __$$BaseTravelOperationImplCopyWithImpl<_$BaseTravelOperationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BaseTravelOperationImplToJson(
      this,
    );
  }
}

abstract class _BaseTravelOperation implements BaseTravelOperation {
  const factory _BaseTravelOperation(
      {required final String id,
      required final String type,
      required final DateTime timestamp,
      final int priority,
      final bool requiresNetwork,
      final Map<String, dynamic> data}) = _$BaseTravelOperationImpl;

  factory _BaseTravelOperation.fromJson(Map<String, dynamic> json) =
      _$BaseTravelOperationImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  DateTime get timestamp;
  @override
  int get priority;
  @override
  bool get requiresNetwork;
  @override
  Map<String, dynamic> get data;

  /// Create a copy of BaseTravelOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseTravelOperationImplCopyWith<_$BaseTravelOperationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
