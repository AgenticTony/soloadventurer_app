// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'itinerary_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ItineraryItem _$ItineraryItemFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'flightArrival':
      return ItineraryItemFlightArrival.fromJson(json);
    case 'flightDeparture':
      return ItineraryItemFlightDeparture.fromJson(json);
    case 'hotelCheckIn':
      return ItineraryItemHotelCheckIn.fromJson(json);
    case 'hotelCheckOut':
      return ItineraryItemHotelCheckOut.fromJson(json);
    case 'activity':
      return ItineraryItemActivity.fromJson(json);
    case 'lunch':
      return ItineraryItemLunch.fromJson(json);
    case 'dinner':
      return ItineraryItemDinner.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'ItineraryItem',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$ItineraryItem {
  /// Unique identifier for this item
  String get id => throw _privateConstructorUsedError;

  /// Scheduled time of arrival
  DateTime get time => throw _privateConstructorUsedError;

  /// Additional notes
  String? get note => throw _privateConstructorUsedError;

  /// Whether this item is completed
  bool get isCompleted => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightArrival,
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightDeparture,
    required TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)
        hotelCheckIn,
    required TResult Function(String id, DateTime time, String? hotelName,
            String? note, bool isCompleted)
        hotelCheckOut,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)
        activity,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        lunch,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        dinner,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult? Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult? Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ItineraryItemFlightArrival value) flightArrival,
    required TResult Function(ItineraryItemFlightDeparture value)
        flightDeparture,
    required TResult Function(ItineraryItemHotelCheckIn value) hotelCheckIn,
    required TResult Function(ItineraryItemHotelCheckOut value) hotelCheckOut,
    required TResult Function(ItineraryItemActivity value) activity,
    required TResult Function(ItineraryItemLunch value) lunch,
    required TResult Function(ItineraryItemDinner value) dinner,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult? Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult? Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult? Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult? Function(ItineraryItemActivity value)? activity,
    TResult? Function(ItineraryItemLunch value)? lunch,
    TResult? Function(ItineraryItemDinner value)? dinner,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult Function(ItineraryItemActivity value)? activity,
    TResult Function(ItineraryItemLunch value)? lunch,
    TResult Function(ItineraryItemDinner value)? dinner,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this ItineraryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItineraryItemCopyWith<ItineraryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItineraryItemCopyWith<$Res> {
  factory $ItineraryItemCopyWith(
          ItineraryItem value, $Res Function(ItineraryItem) then) =
      _$ItineraryItemCopyWithImpl<$Res, ItineraryItem>;
  @useResult
  $Res call({String id, DateTime time, String? note, bool isCompleted});
}

/// @nodoc
class _$ItineraryItemCopyWithImpl<$Res, $Val extends ItineraryItem>
    implements $ItineraryItemCopyWith<$Res> {
  _$ItineraryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? note = freezed,
    Object? isCompleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItineraryItemFlightArrivalImplCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory _$$ItineraryItemFlightArrivalImplCopyWith(
          _$ItineraryItemFlightArrivalImpl value,
          $Res Function(_$ItineraryItemFlightArrivalImpl) then) =
      __$$ItineraryItemFlightArrivalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime time,
      String? flightNumber,
      String? airportCode,
      String? note,
      bool isCompleted});
}

/// @nodoc
class __$$ItineraryItemFlightArrivalImplCopyWithImpl<$Res>
    extends _$ItineraryItemCopyWithImpl<$Res, _$ItineraryItemFlightArrivalImpl>
    implements _$$ItineraryItemFlightArrivalImplCopyWith<$Res> {
  __$$ItineraryItemFlightArrivalImplCopyWithImpl(
      _$ItineraryItemFlightArrivalImpl _value,
      $Res Function(_$ItineraryItemFlightArrivalImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? flightNumber = freezed,
    Object? airportCode = freezed,
    Object? note = freezed,
    Object? isCompleted = null,
  }) {
    return _then(_$ItineraryItemFlightArrivalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      flightNumber: freezed == flightNumber
          ? _value.flightNumber
          : flightNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      airportCode: freezed == airportCode
          ? _value.airportCode
          : airportCode // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItineraryItemFlightArrivalImpl extends ItineraryItemFlightArrival {
  const _$ItineraryItemFlightArrivalImpl(
      {required this.id,
      required this.time,
      this.flightNumber,
      this.airportCode,
      this.note,
      this.isCompleted = false,
      final String? $type})
      : $type = $type ?? 'flightArrival',
        super._();

  factory _$ItineraryItemFlightArrivalImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ItineraryItemFlightArrivalImplFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Scheduled time of arrival
  @override
  final DateTime time;

  /// Flight number
  @override
  final String? flightNumber;

  /// Airport code
  @override
  final String? airportCode;

  /// Additional notes
  @override
  final String? note;

  /// Whether this item is completed
  @override
  @JsonKey()
  final bool isCompleted;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ItineraryItem.flightArrival(id: $id, time: $time, flightNumber: $flightNumber, airportCode: $airportCode, note: $note, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItineraryItemFlightArrivalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.flightNumber, flightNumber) ||
                other.flightNumber == flightNumber) &&
            (identical(other.airportCode, airportCode) ||
                other.airportCode == airportCode) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, time, flightNumber, airportCode, note, isCompleted);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItineraryItemFlightArrivalImplCopyWith<_$ItineraryItemFlightArrivalImpl>
      get copyWith => __$$ItineraryItemFlightArrivalImplCopyWithImpl<
          _$ItineraryItemFlightArrivalImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightArrival,
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightDeparture,
    required TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)
        hotelCheckIn,
    required TResult Function(String id, DateTime time, String? hotelName,
            String? note, bool isCompleted)
        hotelCheckOut,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)
        activity,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        lunch,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        dinner,
  }) {
    return flightArrival(
        id, time, flightNumber, airportCode, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult? Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult? Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
  }) {
    return flightArrival?.call(
        id, time, flightNumber, airportCode, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
    required TResult orElse(),
  }) {
    if (flightArrival != null) {
      return flightArrival(
          id, time, flightNumber, airportCode, note, isCompleted);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ItineraryItemFlightArrival value) flightArrival,
    required TResult Function(ItineraryItemFlightDeparture value)
        flightDeparture,
    required TResult Function(ItineraryItemHotelCheckIn value) hotelCheckIn,
    required TResult Function(ItineraryItemHotelCheckOut value) hotelCheckOut,
    required TResult Function(ItineraryItemActivity value) activity,
    required TResult Function(ItineraryItemLunch value) lunch,
    required TResult Function(ItineraryItemDinner value) dinner,
  }) {
    return flightArrival(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult? Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult? Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult? Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult? Function(ItineraryItemActivity value)? activity,
    TResult? Function(ItineraryItemLunch value)? lunch,
    TResult? Function(ItineraryItemDinner value)? dinner,
  }) {
    return flightArrival?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult Function(ItineraryItemActivity value)? activity,
    TResult Function(ItineraryItemLunch value)? lunch,
    TResult Function(ItineraryItemDinner value)? dinner,
    required TResult orElse(),
  }) {
    if (flightArrival != null) {
      return flightArrival(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ItineraryItemFlightArrivalImplToJson(
      this,
    );
  }
}

abstract class ItineraryItemFlightArrival extends ItineraryItem {
  const factory ItineraryItemFlightArrival(
      {required final String id,
      required final DateTime time,
      final String? flightNumber,
      final String? airportCode,
      final String? note,
      final bool isCompleted}) = _$ItineraryItemFlightArrivalImpl;
  const ItineraryItemFlightArrival._() : super._();

  factory ItineraryItemFlightArrival.fromJson(Map<String, dynamic> json) =
      _$ItineraryItemFlightArrivalImpl.fromJson;

  /// Unique identifier for this item
  @override
  String get id;

  /// Scheduled time of arrival
  @override
  DateTime get time;

  /// Flight number
  String? get flightNumber;

  /// Airport code
  String? get airportCode;

  /// Additional notes
  @override
  String? get note;

  /// Whether this item is completed
  @override
  bool get isCompleted;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItineraryItemFlightArrivalImplCopyWith<_$ItineraryItemFlightArrivalImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ItineraryItemFlightDepartureImplCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory _$$ItineraryItemFlightDepartureImplCopyWith(
          _$ItineraryItemFlightDepartureImpl value,
          $Res Function(_$ItineraryItemFlightDepartureImpl) then) =
      __$$ItineraryItemFlightDepartureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime time,
      String? flightNumber,
      String? airportCode,
      String? note,
      bool isCompleted});
}

/// @nodoc
class __$$ItineraryItemFlightDepartureImplCopyWithImpl<$Res>
    extends _$ItineraryItemCopyWithImpl<$Res,
        _$ItineraryItemFlightDepartureImpl>
    implements _$$ItineraryItemFlightDepartureImplCopyWith<$Res> {
  __$$ItineraryItemFlightDepartureImplCopyWithImpl(
      _$ItineraryItemFlightDepartureImpl _value,
      $Res Function(_$ItineraryItemFlightDepartureImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? flightNumber = freezed,
    Object? airportCode = freezed,
    Object? note = freezed,
    Object? isCompleted = null,
  }) {
    return _then(_$ItineraryItemFlightDepartureImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      flightNumber: freezed == flightNumber
          ? _value.flightNumber
          : flightNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      airportCode: freezed == airportCode
          ? _value.airportCode
          : airportCode // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItineraryItemFlightDepartureImpl extends ItineraryItemFlightDeparture {
  const _$ItineraryItemFlightDepartureImpl(
      {required this.id,
      required this.time,
      this.flightNumber,
      this.airportCode,
      this.note,
      this.isCompleted = false,
      final String? $type})
      : $type = $type ?? 'flightDeparture',
        super._();

  factory _$ItineraryItemFlightDepartureImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ItineraryItemFlightDepartureImplFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Scheduled time of departure
  @override
  final DateTime time;

  /// Flight number
  @override
  final String? flightNumber;

  /// Airport code
  @override
  final String? airportCode;

  /// Additional notes
  @override
  final String? note;

  /// Whether this item is completed
  @override
  @JsonKey()
  final bool isCompleted;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ItineraryItem.flightDeparture(id: $id, time: $time, flightNumber: $flightNumber, airportCode: $airportCode, note: $note, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItineraryItemFlightDepartureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.flightNumber, flightNumber) ||
                other.flightNumber == flightNumber) &&
            (identical(other.airportCode, airportCode) ||
                other.airportCode == airportCode) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, time, flightNumber, airportCode, note, isCompleted);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItineraryItemFlightDepartureImplCopyWith<
          _$ItineraryItemFlightDepartureImpl>
      get copyWith => __$$ItineraryItemFlightDepartureImplCopyWithImpl<
          _$ItineraryItemFlightDepartureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightArrival,
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightDeparture,
    required TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)
        hotelCheckIn,
    required TResult Function(String id, DateTime time, String? hotelName,
            String? note, bool isCompleted)
        hotelCheckOut,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)
        activity,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        lunch,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        dinner,
  }) {
    return flightDeparture(
        id, time, flightNumber, airportCode, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult? Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult? Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
  }) {
    return flightDeparture?.call(
        id, time, flightNumber, airportCode, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
    required TResult orElse(),
  }) {
    if (flightDeparture != null) {
      return flightDeparture(
          id, time, flightNumber, airportCode, note, isCompleted);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ItineraryItemFlightArrival value) flightArrival,
    required TResult Function(ItineraryItemFlightDeparture value)
        flightDeparture,
    required TResult Function(ItineraryItemHotelCheckIn value) hotelCheckIn,
    required TResult Function(ItineraryItemHotelCheckOut value) hotelCheckOut,
    required TResult Function(ItineraryItemActivity value) activity,
    required TResult Function(ItineraryItemLunch value) lunch,
    required TResult Function(ItineraryItemDinner value) dinner,
  }) {
    return flightDeparture(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult? Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult? Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult? Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult? Function(ItineraryItemActivity value)? activity,
    TResult? Function(ItineraryItemLunch value)? lunch,
    TResult? Function(ItineraryItemDinner value)? dinner,
  }) {
    return flightDeparture?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult Function(ItineraryItemActivity value)? activity,
    TResult Function(ItineraryItemLunch value)? lunch,
    TResult Function(ItineraryItemDinner value)? dinner,
    required TResult orElse(),
  }) {
    if (flightDeparture != null) {
      return flightDeparture(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ItineraryItemFlightDepartureImplToJson(
      this,
    );
  }
}

abstract class ItineraryItemFlightDeparture extends ItineraryItem {
  const factory ItineraryItemFlightDeparture(
      {required final String id,
      required final DateTime time,
      final String? flightNumber,
      final String? airportCode,
      final String? note,
      final bool isCompleted}) = _$ItineraryItemFlightDepartureImpl;
  const ItineraryItemFlightDeparture._() : super._();

  factory ItineraryItemFlightDeparture.fromJson(Map<String, dynamic> json) =
      _$ItineraryItemFlightDepartureImpl.fromJson;

  /// Unique identifier for this item
  @override
  String get id;

  /// Scheduled time of departure
  @override
  DateTime get time;

  /// Flight number
  String? get flightNumber;

  /// Airport code
  String? get airportCode;

  /// Additional notes
  @override
  String? get note;

  /// Whether this item is completed
  @override
  bool get isCompleted;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItineraryItemFlightDepartureImplCopyWith<
          _$ItineraryItemFlightDepartureImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ItineraryItemHotelCheckInImplCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory _$$ItineraryItemHotelCheckInImplCopyWith(
          _$ItineraryItemHotelCheckInImpl value,
          $Res Function(_$ItineraryItemHotelCheckInImpl) then) =
      __$$ItineraryItemHotelCheckInImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime time,
      String? hotelName,
      String? address,
      String? confirmationNumber,
      String? note,
      bool isCompleted});
}

/// @nodoc
class __$$ItineraryItemHotelCheckInImplCopyWithImpl<$Res>
    extends _$ItineraryItemCopyWithImpl<$Res, _$ItineraryItemHotelCheckInImpl>
    implements _$$ItineraryItemHotelCheckInImplCopyWith<$Res> {
  __$$ItineraryItemHotelCheckInImplCopyWithImpl(
      _$ItineraryItemHotelCheckInImpl _value,
      $Res Function(_$ItineraryItemHotelCheckInImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? hotelName = freezed,
    Object? address = freezed,
    Object? confirmationNumber = freezed,
    Object? note = freezed,
    Object? isCompleted = null,
  }) {
    return _then(_$ItineraryItemHotelCheckInImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hotelName: freezed == hotelName
          ? _value.hotelName
          : hotelName // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      confirmationNumber: freezed == confirmationNumber
          ? _value.confirmationNumber
          : confirmationNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItineraryItemHotelCheckInImpl extends ItineraryItemHotelCheckIn {
  const _$ItineraryItemHotelCheckInImpl(
      {required this.id,
      required this.time,
      this.hotelName,
      this.address,
      this.confirmationNumber,
      this.note,
      this.isCompleted = false,
      final String? $type})
      : $type = $type ?? 'hotelCheckIn',
        super._();

  factory _$ItineraryItemHotelCheckInImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItineraryItemHotelCheckInImplFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Scheduled check-in time
  @override
  final DateTime time;

  /// Hotel/accommodation name
  @override
  final String? hotelName;

  /// Address of the accommodation
  @override
  final String? address;

  /// Confirmation number
  @override
  final String? confirmationNumber;

  /// Additional notes
  @override
  final String? note;

  /// Whether this item is completed
  @override
  @JsonKey()
  final bool isCompleted;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ItineraryItem.hotelCheckIn(id: $id, time: $time, hotelName: $hotelName, address: $address, confirmationNumber: $confirmationNumber, note: $note, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItineraryItemHotelCheckInImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.hotelName, hotelName) ||
                other.hotelName == hotelName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.confirmationNumber, confirmationNumber) ||
                other.confirmationNumber == confirmationNumber) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, time, hotelName, address,
      confirmationNumber, note, isCompleted);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItineraryItemHotelCheckInImplCopyWith<_$ItineraryItemHotelCheckInImpl>
      get copyWith => __$$ItineraryItemHotelCheckInImplCopyWithImpl<
          _$ItineraryItemHotelCheckInImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightArrival,
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightDeparture,
    required TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)
        hotelCheckIn,
    required TResult Function(String id, DateTime time, String? hotelName,
            String? note, bool isCompleted)
        hotelCheckOut,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)
        activity,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        lunch,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        dinner,
  }) {
    return hotelCheckIn(
        id, time, hotelName, address, confirmationNumber, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult? Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult? Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
  }) {
    return hotelCheckIn?.call(
        id, time, hotelName, address, confirmationNumber, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
    required TResult orElse(),
  }) {
    if (hotelCheckIn != null) {
      return hotelCheckIn(
          id, time, hotelName, address, confirmationNumber, note, isCompleted);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ItineraryItemFlightArrival value) flightArrival,
    required TResult Function(ItineraryItemFlightDeparture value)
        flightDeparture,
    required TResult Function(ItineraryItemHotelCheckIn value) hotelCheckIn,
    required TResult Function(ItineraryItemHotelCheckOut value) hotelCheckOut,
    required TResult Function(ItineraryItemActivity value) activity,
    required TResult Function(ItineraryItemLunch value) lunch,
    required TResult Function(ItineraryItemDinner value) dinner,
  }) {
    return hotelCheckIn(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult? Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult? Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult? Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult? Function(ItineraryItemActivity value)? activity,
    TResult? Function(ItineraryItemLunch value)? lunch,
    TResult? Function(ItineraryItemDinner value)? dinner,
  }) {
    return hotelCheckIn?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult Function(ItineraryItemActivity value)? activity,
    TResult Function(ItineraryItemLunch value)? lunch,
    TResult Function(ItineraryItemDinner value)? dinner,
    required TResult orElse(),
  }) {
    if (hotelCheckIn != null) {
      return hotelCheckIn(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ItineraryItemHotelCheckInImplToJson(
      this,
    );
  }
}

abstract class ItineraryItemHotelCheckIn extends ItineraryItem {
  const factory ItineraryItemHotelCheckIn(
      {required final String id,
      required final DateTime time,
      final String? hotelName,
      final String? address,
      final String? confirmationNumber,
      final String? note,
      final bool isCompleted}) = _$ItineraryItemHotelCheckInImpl;
  const ItineraryItemHotelCheckIn._() : super._();

  factory ItineraryItemHotelCheckIn.fromJson(Map<String, dynamic> json) =
      _$ItineraryItemHotelCheckInImpl.fromJson;

  /// Unique identifier for this item
  @override
  String get id;

  /// Scheduled check-in time
  @override
  DateTime get time;

  /// Hotel/accommodation name
  String? get hotelName;

  /// Address of the accommodation
  String? get address;

  /// Confirmation number
  String? get confirmationNumber;

  /// Additional notes
  @override
  String? get note;

  /// Whether this item is completed
  @override
  bool get isCompleted;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItineraryItemHotelCheckInImplCopyWith<_$ItineraryItemHotelCheckInImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ItineraryItemHotelCheckOutImplCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory _$$ItineraryItemHotelCheckOutImplCopyWith(
          _$ItineraryItemHotelCheckOutImpl value,
          $Res Function(_$ItineraryItemHotelCheckOutImpl) then) =
      __$$ItineraryItemHotelCheckOutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime time,
      String? hotelName,
      String? note,
      bool isCompleted});
}

/// @nodoc
class __$$ItineraryItemHotelCheckOutImplCopyWithImpl<$Res>
    extends _$ItineraryItemCopyWithImpl<$Res, _$ItineraryItemHotelCheckOutImpl>
    implements _$$ItineraryItemHotelCheckOutImplCopyWith<$Res> {
  __$$ItineraryItemHotelCheckOutImplCopyWithImpl(
      _$ItineraryItemHotelCheckOutImpl _value,
      $Res Function(_$ItineraryItemHotelCheckOutImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? hotelName = freezed,
    Object? note = freezed,
    Object? isCompleted = null,
  }) {
    return _then(_$ItineraryItemHotelCheckOutImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hotelName: freezed == hotelName
          ? _value.hotelName
          : hotelName // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItineraryItemHotelCheckOutImpl extends ItineraryItemHotelCheckOut {
  const _$ItineraryItemHotelCheckOutImpl(
      {required this.id,
      required this.time,
      this.hotelName,
      this.note,
      this.isCompleted = false,
      final String? $type})
      : $type = $type ?? 'hotelCheckOut',
        super._();

  factory _$ItineraryItemHotelCheckOutImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ItineraryItemHotelCheckOutImplFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Scheduled check-out time
  @override
  final DateTime time;

  /// Hotel/accommodation name
  @override
  final String? hotelName;

  /// Additional notes
  @override
  final String? note;

  /// Whether this item is completed
  @override
  @JsonKey()
  final bool isCompleted;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ItineraryItem.hotelCheckOut(id: $id, time: $time, hotelName: $hotelName, note: $note, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItineraryItemHotelCheckOutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.hotelName, hotelName) ||
                other.hotelName == hotelName) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, time, hotelName, note, isCompleted);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItineraryItemHotelCheckOutImplCopyWith<_$ItineraryItemHotelCheckOutImpl>
      get copyWith => __$$ItineraryItemHotelCheckOutImplCopyWithImpl<
          _$ItineraryItemHotelCheckOutImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightArrival,
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightDeparture,
    required TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)
        hotelCheckIn,
    required TResult Function(String id, DateTime time, String? hotelName,
            String? note, bool isCompleted)
        hotelCheckOut,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)
        activity,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        lunch,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        dinner,
  }) {
    return hotelCheckOut(id, time, hotelName, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult? Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult? Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
  }) {
    return hotelCheckOut?.call(id, time, hotelName, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
    required TResult orElse(),
  }) {
    if (hotelCheckOut != null) {
      return hotelCheckOut(id, time, hotelName, note, isCompleted);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ItineraryItemFlightArrival value) flightArrival,
    required TResult Function(ItineraryItemFlightDeparture value)
        flightDeparture,
    required TResult Function(ItineraryItemHotelCheckIn value) hotelCheckIn,
    required TResult Function(ItineraryItemHotelCheckOut value) hotelCheckOut,
    required TResult Function(ItineraryItemActivity value) activity,
    required TResult Function(ItineraryItemLunch value) lunch,
    required TResult Function(ItineraryItemDinner value) dinner,
  }) {
    return hotelCheckOut(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult? Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult? Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult? Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult? Function(ItineraryItemActivity value)? activity,
    TResult? Function(ItineraryItemLunch value)? lunch,
    TResult? Function(ItineraryItemDinner value)? dinner,
  }) {
    return hotelCheckOut?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult Function(ItineraryItemActivity value)? activity,
    TResult Function(ItineraryItemLunch value)? lunch,
    TResult Function(ItineraryItemDinner value)? dinner,
    required TResult orElse(),
  }) {
    if (hotelCheckOut != null) {
      return hotelCheckOut(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ItineraryItemHotelCheckOutImplToJson(
      this,
    );
  }
}

abstract class ItineraryItemHotelCheckOut extends ItineraryItem {
  const factory ItineraryItemHotelCheckOut(
      {required final String id,
      required final DateTime time,
      final String? hotelName,
      final String? note,
      final bool isCompleted}) = _$ItineraryItemHotelCheckOutImpl;
  const ItineraryItemHotelCheckOut._() : super._();

  factory ItineraryItemHotelCheckOut.fromJson(Map<String, dynamic> json) =
      _$ItineraryItemHotelCheckOutImpl.fromJson;

  /// Unique identifier for this item
  @override
  String get id;

  /// Scheduled check-out time
  @override
  DateTime get time;

  /// Hotel/accommodation name
  String? get hotelName;

  /// Additional notes
  @override
  String? get note;

  /// Whether this item is completed
  @override
  bool get isCompleted;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItineraryItemHotelCheckOutImplCopyWith<_$ItineraryItemHotelCheckOutImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ItineraryItemActivityImplCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory _$$ItineraryItemActivityImplCopyWith(
          _$ItineraryItemActivityImpl value,
          $Res Function(_$ItineraryItemActivityImpl) then) =
      __$$ItineraryItemActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime time,
      String name,
      String? description,
      String? location,
      int? durationHours,
      double? cost,
      String? bookingUrl,
      String? note,
      bool isCompleted});
}

/// @nodoc
class __$$ItineraryItemActivityImplCopyWithImpl<$Res>
    extends _$ItineraryItemCopyWithImpl<$Res, _$ItineraryItemActivityImpl>
    implements _$$ItineraryItemActivityImplCopyWith<$Res> {
  __$$ItineraryItemActivityImplCopyWithImpl(_$ItineraryItemActivityImpl _value,
      $Res Function(_$ItineraryItemActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? name = null,
    Object? description = freezed,
    Object? location = freezed,
    Object? durationHours = freezed,
    Object? cost = freezed,
    Object? bookingUrl = freezed,
    Object? note = freezed,
    Object? isCompleted = null,
  }) {
    return _then(_$ItineraryItemActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      durationHours: freezed == durationHours
          ? _value.durationHours
          : durationHours // ignore: cast_nullable_to_non_nullable
              as int?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      bookingUrl: freezed == bookingUrl
          ? _value.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItineraryItemActivityImpl extends ItineraryItemActivity {
  const _$ItineraryItemActivityImpl(
      {required this.id,
      required this.time,
      required this.name,
      this.description,
      this.location,
      this.durationHours,
      this.cost,
      this.bookingUrl,
      this.note,
      this.isCompleted = false,
      final String? $type})
      : $type = $type ?? 'activity',
        super._();

  factory _$ItineraryItemActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItineraryItemActivityImplFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Start time of the activity
  @override
  final DateTime time;

  /// Activity name/title
  @override
  final String name;

  /// Activity description
  @override
  final String? description;

  /// Location/address
  @override
  final String? location;

  /// Estimated duration in hours
  @override
  final int? durationHours;

  /// Estimated cost in local currency
  @override
  final double? cost;

  /// Booking URL if advance booking required
  @override
  final String? bookingUrl;

  /// Additional notes
  @override
  final String? note;

  /// Whether this item is completed
  @override
  @JsonKey()
  final bool isCompleted;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ItineraryItem.activity(id: $id, time: $time, name: $name, description: $description, location: $location, durationHours: $durationHours, cost: $cost, bookingUrl: $bookingUrl, note: $note, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItineraryItemActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.durationHours, durationHours) ||
                other.durationHours == durationHours) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.bookingUrl, bookingUrl) ||
                other.bookingUrl == bookingUrl) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, time, name, description,
      location, durationHours, cost, bookingUrl, note, isCompleted);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItineraryItemActivityImplCopyWith<_$ItineraryItemActivityImpl>
      get copyWith => __$$ItineraryItemActivityImplCopyWithImpl<
          _$ItineraryItemActivityImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightArrival,
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightDeparture,
    required TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)
        hotelCheckIn,
    required TResult Function(String id, DateTime time, String? hotelName,
            String? note, bool isCompleted)
        hotelCheckOut,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)
        activity,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        lunch,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        dinner,
  }) {
    return activity(id, time, name, description, location, durationHours, cost,
        bookingUrl, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult? Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult? Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
  }) {
    return activity?.call(id, time, name, description, location, durationHours,
        cost, bookingUrl, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
    required TResult orElse(),
  }) {
    if (activity != null) {
      return activity(id, time, name, description, location, durationHours,
          cost, bookingUrl, note, isCompleted);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ItineraryItemFlightArrival value) flightArrival,
    required TResult Function(ItineraryItemFlightDeparture value)
        flightDeparture,
    required TResult Function(ItineraryItemHotelCheckIn value) hotelCheckIn,
    required TResult Function(ItineraryItemHotelCheckOut value) hotelCheckOut,
    required TResult Function(ItineraryItemActivity value) activity,
    required TResult Function(ItineraryItemLunch value) lunch,
    required TResult Function(ItineraryItemDinner value) dinner,
  }) {
    return activity(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult? Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult? Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult? Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult? Function(ItineraryItemActivity value)? activity,
    TResult? Function(ItineraryItemLunch value)? lunch,
    TResult? Function(ItineraryItemDinner value)? dinner,
  }) {
    return activity?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult Function(ItineraryItemActivity value)? activity,
    TResult Function(ItineraryItemLunch value)? lunch,
    TResult Function(ItineraryItemDinner value)? dinner,
    required TResult orElse(),
  }) {
    if (activity != null) {
      return activity(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ItineraryItemActivityImplToJson(
      this,
    );
  }
}

abstract class ItineraryItemActivity extends ItineraryItem {
  const factory ItineraryItemActivity(
      {required final String id,
      required final DateTime time,
      required final String name,
      final String? description,
      final String? location,
      final int? durationHours,
      final double? cost,
      final String? bookingUrl,
      final String? note,
      final bool isCompleted}) = _$ItineraryItemActivityImpl;
  const ItineraryItemActivity._() : super._();

  factory ItineraryItemActivity.fromJson(Map<String, dynamic> json) =
      _$ItineraryItemActivityImpl.fromJson;

  /// Unique identifier for this item
  @override
  String get id;

  /// Start time of the activity
  @override
  DateTime get time;

  /// Activity name/title
  String get name;

  /// Activity description
  String? get description;

  /// Location/address
  String? get location;

  /// Estimated duration in hours
  int? get durationHours;

  /// Estimated cost in local currency
  double? get cost;

  /// Booking URL if advance booking required
  String? get bookingUrl;

  /// Additional notes
  @override
  String? get note;

  /// Whether this item is completed
  @override
  bool get isCompleted;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItineraryItemActivityImplCopyWith<_$ItineraryItemActivityImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ItineraryItemLunchImplCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory _$$ItineraryItemLunchImplCopyWith(_$ItineraryItemLunchImpl value,
          $Res Function(_$ItineraryItemLunchImpl) then) =
      __$$ItineraryItemLunchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime time,
      String name,
      String? cuisine,
      String? location,
      String? priceRange,
      String? note,
      bool isCompleted});
}

/// @nodoc
class __$$ItineraryItemLunchImplCopyWithImpl<$Res>
    extends _$ItineraryItemCopyWithImpl<$Res, _$ItineraryItemLunchImpl>
    implements _$$ItineraryItemLunchImplCopyWith<$Res> {
  __$$ItineraryItemLunchImplCopyWithImpl(_$ItineraryItemLunchImpl _value,
      $Res Function(_$ItineraryItemLunchImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? name = null,
    Object? cuisine = freezed,
    Object? location = freezed,
    Object? priceRange = freezed,
    Object? note = freezed,
    Object? isCompleted = null,
  }) {
    return _then(_$ItineraryItemLunchImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      cuisine: freezed == cuisine
          ? _value.cuisine
          : cuisine // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      priceRange: freezed == priceRange
          ? _value.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItineraryItemLunchImpl extends ItineraryItemLunch {
  const _$ItineraryItemLunchImpl(
      {required this.id,
      required this.time,
      required this.name,
      this.cuisine,
      this.location,
      this.priceRange,
      this.note,
      this.isCompleted = false,
      final String? $type})
      : $type = $type ?? 'lunch',
        super._();

  factory _$ItineraryItemLunchImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItineraryItemLunchImplFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Scheduled lunch time
  @override
  final DateTime time;

  /// Restaurant name
  @override
  final String name;

  /// Cuisine type
  @override
  final String? cuisine;

  /// Location/address
  @override
  final String? location;

  /// Average price range ($, $$, $$$)
  @override
  final String? priceRange;

  /// Additional notes
  @override
  final String? note;

  /// Whether this item is completed
  @override
  @JsonKey()
  final bool isCompleted;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ItineraryItem.lunch(id: $id, time: $time, name: $name, cuisine: $cuisine, location: $location, priceRange: $priceRange, note: $note, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItineraryItemLunchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.cuisine, cuisine) || other.cuisine == cuisine) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.priceRange, priceRange) ||
                other.priceRange == priceRange) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, time, name, cuisine,
      location, priceRange, note, isCompleted);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItineraryItemLunchImplCopyWith<_$ItineraryItemLunchImpl> get copyWith =>
      __$$ItineraryItemLunchImplCopyWithImpl<_$ItineraryItemLunchImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightArrival,
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightDeparture,
    required TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)
        hotelCheckIn,
    required TResult Function(String id, DateTime time, String? hotelName,
            String? note, bool isCompleted)
        hotelCheckOut,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)
        activity,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        lunch,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        dinner,
  }) {
    return lunch(
        id, time, name, cuisine, location, priceRange, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult? Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult? Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
  }) {
    return lunch?.call(
        id, time, name, cuisine, location, priceRange, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
    required TResult orElse(),
  }) {
    if (lunch != null) {
      return lunch(
          id, time, name, cuisine, location, priceRange, note, isCompleted);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ItineraryItemFlightArrival value) flightArrival,
    required TResult Function(ItineraryItemFlightDeparture value)
        flightDeparture,
    required TResult Function(ItineraryItemHotelCheckIn value) hotelCheckIn,
    required TResult Function(ItineraryItemHotelCheckOut value) hotelCheckOut,
    required TResult Function(ItineraryItemActivity value) activity,
    required TResult Function(ItineraryItemLunch value) lunch,
    required TResult Function(ItineraryItemDinner value) dinner,
  }) {
    return lunch(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult? Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult? Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult? Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult? Function(ItineraryItemActivity value)? activity,
    TResult? Function(ItineraryItemLunch value)? lunch,
    TResult? Function(ItineraryItemDinner value)? dinner,
  }) {
    return lunch?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult Function(ItineraryItemActivity value)? activity,
    TResult Function(ItineraryItemLunch value)? lunch,
    TResult Function(ItineraryItemDinner value)? dinner,
    required TResult orElse(),
  }) {
    if (lunch != null) {
      return lunch(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ItineraryItemLunchImplToJson(
      this,
    );
  }
}

abstract class ItineraryItemLunch extends ItineraryItem {
  const factory ItineraryItemLunch(
      {required final String id,
      required final DateTime time,
      required final String name,
      final String? cuisine,
      final String? location,
      final String? priceRange,
      final String? note,
      final bool isCompleted}) = _$ItineraryItemLunchImpl;
  const ItineraryItemLunch._() : super._();

  factory ItineraryItemLunch.fromJson(Map<String, dynamic> json) =
      _$ItineraryItemLunchImpl.fromJson;

  /// Unique identifier for this item
  @override
  String get id;

  /// Scheduled lunch time
  @override
  DateTime get time;

  /// Restaurant name
  String get name;

  /// Cuisine type
  String? get cuisine;

  /// Location/address
  String? get location;

  /// Average price range ($, $$, $$$)
  String? get priceRange;

  /// Additional notes
  @override
  String? get note;

  /// Whether this item is completed
  @override
  bool get isCompleted;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItineraryItemLunchImplCopyWith<_$ItineraryItemLunchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ItineraryItemDinnerImplCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory _$$ItineraryItemDinnerImplCopyWith(_$ItineraryItemDinnerImpl value,
          $Res Function(_$ItineraryItemDinnerImpl) then) =
      __$$ItineraryItemDinnerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime time,
      String name,
      String? cuisine,
      String? location,
      String? priceRange,
      String? note,
      bool isCompleted});
}

/// @nodoc
class __$$ItineraryItemDinnerImplCopyWithImpl<$Res>
    extends _$ItineraryItemCopyWithImpl<$Res, _$ItineraryItemDinnerImpl>
    implements _$$ItineraryItemDinnerImplCopyWith<$Res> {
  __$$ItineraryItemDinnerImplCopyWithImpl(_$ItineraryItemDinnerImpl _value,
      $Res Function(_$ItineraryItemDinnerImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? name = null,
    Object? cuisine = freezed,
    Object? location = freezed,
    Object? priceRange = freezed,
    Object? note = freezed,
    Object? isCompleted = null,
  }) {
    return _then(_$ItineraryItemDinnerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      cuisine: freezed == cuisine
          ? _value.cuisine
          : cuisine // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      priceRange: freezed == priceRange
          ? _value.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItineraryItemDinnerImpl extends ItineraryItemDinner {
  const _$ItineraryItemDinnerImpl(
      {required this.id,
      required this.time,
      required this.name,
      this.cuisine,
      this.location,
      this.priceRange,
      this.note,
      this.isCompleted = false,
      final String? $type})
      : $type = $type ?? 'dinner',
        super._();

  factory _$ItineraryItemDinnerImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItineraryItemDinnerImplFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Scheduled dinner time
  @override
  final DateTime time;

  /// Restaurant name
  @override
  final String name;

  /// Cuisine type
  @override
  final String? cuisine;

  /// Location/address
  @override
  final String? location;

  /// Average price range ($, $$, $$$)
  @override
  final String? priceRange;

  /// Additional notes
  @override
  final String? note;

  /// Whether this item is completed
  @override
  @JsonKey()
  final bool isCompleted;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ItineraryItem.dinner(id: $id, time: $time, name: $name, cuisine: $cuisine, location: $location, priceRange: $priceRange, note: $note, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItineraryItemDinnerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.cuisine, cuisine) || other.cuisine == cuisine) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.priceRange, priceRange) ||
                other.priceRange == priceRange) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, time, name, cuisine,
      location, priceRange, note, isCompleted);

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItineraryItemDinnerImplCopyWith<_$ItineraryItemDinnerImpl> get copyWith =>
      __$$ItineraryItemDinnerImplCopyWithImpl<_$ItineraryItemDinnerImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightArrival,
    required TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)
        flightDeparture,
    required TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)
        hotelCheckIn,
    required TResult Function(String id, DateTime time, String? hotelName,
            String? note, bool isCompleted)
        hotelCheckOut,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)
        activity,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        lunch,
    required TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)
        dinner,
  }) {
    return dinner(
        id, time, name, cuisine, location, priceRange, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult? Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult? Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult? Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult? Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
  }) {
    return dinner?.call(
        id, time, name, cuisine, location, priceRange, note, isCompleted);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightArrival,
    TResult Function(String id, DateTime time, String? flightNumber,
            String? airportCode, String? note, bool isCompleted)?
        flightDeparture,
    TResult Function(
            String id,
            DateTime time,
            String? hotelName,
            String? address,
            String? confirmationNumber,
            String? note,
            bool isCompleted)?
        hotelCheckIn,
    TResult Function(String id, DateTime time, String? hotelName, String? note,
            bool isCompleted)?
        hotelCheckOut,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? description,
            String? location,
            int? durationHours,
            double? cost,
            String? bookingUrl,
            String? note,
            bool isCompleted)?
        activity,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        lunch,
    TResult Function(
            String id,
            DateTime time,
            String name,
            String? cuisine,
            String? location,
            String? priceRange,
            String? note,
            bool isCompleted)?
        dinner,
    required TResult orElse(),
  }) {
    if (dinner != null) {
      return dinner(
          id, time, name, cuisine, location, priceRange, note, isCompleted);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ItineraryItemFlightArrival value) flightArrival,
    required TResult Function(ItineraryItemFlightDeparture value)
        flightDeparture,
    required TResult Function(ItineraryItemHotelCheckIn value) hotelCheckIn,
    required TResult Function(ItineraryItemHotelCheckOut value) hotelCheckOut,
    required TResult Function(ItineraryItemActivity value) activity,
    required TResult Function(ItineraryItemLunch value) lunch,
    required TResult Function(ItineraryItemDinner value) dinner,
  }) {
    return dinner(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult? Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult? Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult? Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult? Function(ItineraryItemActivity value)? activity,
    TResult? Function(ItineraryItemLunch value)? lunch,
    TResult? Function(ItineraryItemDinner value)? dinner,
  }) {
    return dinner?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult Function(ItineraryItemActivity value)? activity,
    TResult Function(ItineraryItemLunch value)? lunch,
    TResult Function(ItineraryItemDinner value)? dinner,
    required TResult orElse(),
  }) {
    if (dinner != null) {
      return dinner(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ItineraryItemDinnerImplToJson(
      this,
    );
  }
}

abstract class ItineraryItemDinner extends ItineraryItem {
  const factory ItineraryItemDinner(
      {required final String id,
      required final DateTime time,
      required final String name,
      final String? cuisine,
      final String? location,
      final String? priceRange,
      final String? note,
      final bool isCompleted}) = _$ItineraryItemDinnerImpl;
  const ItineraryItemDinner._() : super._();

  factory ItineraryItemDinner.fromJson(Map<String, dynamic> json) =
      _$ItineraryItemDinnerImpl.fromJson;

  /// Unique identifier for this item
  @override
  String get id;

  /// Scheduled dinner time
  @override
  DateTime get time;

  /// Restaurant name
  String get name;

  /// Cuisine type
  String? get cuisine;

  /// Location/address
  String? get location;

  /// Average price range ($, $$, $$$)
  String? get priceRange;

  /// Additional notes
  @override
  String? get note;

  /// Whether this item is completed
  @override
  bool get isCompleted;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItineraryItemDinnerImplCopyWith<_$ItineraryItemDinnerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
