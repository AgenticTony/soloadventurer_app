// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'itinerary_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
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
  String get id;

  /// Scheduled time of arrival
  DateTime get time;

  /// Additional notes
  String? get note;

  /// Whether this item is completed
  bool get isCompleted;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ItineraryItemCopyWith<ItineraryItem> get copyWith =>
      _$ItineraryItemCopyWithImpl<ItineraryItem>(
          this as ItineraryItem, _$identity);

  /// Serializes this ItineraryItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ItineraryItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, time, note, isCompleted);

  @override
  String toString() {
    return 'ItineraryItem(id: $id, time: $time, note: $note, isCompleted: $isCompleted)';
  }
}

/// @nodoc
abstract mixin class $ItineraryItemCopyWith<$Res> {
  factory $ItineraryItemCopyWith(
          ItineraryItem value, $Res Function(ItineraryItem) _then) =
      _$ItineraryItemCopyWithImpl;
  @useResult
  $Res call({String id, DateTime time, String? note, bool isCompleted});
}

/// @nodoc
class _$ItineraryItemCopyWithImpl<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  _$ItineraryItemCopyWithImpl(this._self, this._then);

  final ItineraryItem _self;
  final $Res Function(ItineraryItem) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [ItineraryItem].
extension ItineraryItemPatterns on ItineraryItem {
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
    final _that = this;
    switch (_that) {
      case ItineraryItemFlightArrival() when flightArrival != null:
        return flightArrival(_that);
      case ItineraryItemFlightDeparture() when flightDeparture != null:
        return flightDeparture(_that);
      case ItineraryItemHotelCheckIn() when hotelCheckIn != null:
        return hotelCheckIn(_that);
      case ItineraryItemHotelCheckOut() when hotelCheckOut != null:
        return hotelCheckOut(_that);
      case ItineraryItemActivity() when activity != null:
        return activity(_that);
      case ItineraryItemLunch() when lunch != null:
        return lunch(_that);
      case ItineraryItemDinner() when dinner != null:
        return dinner(_that);
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
    final _that = this;
    switch (_that) {
      case ItineraryItemFlightArrival():
        return flightArrival(_that);
      case ItineraryItemFlightDeparture():
        return flightDeparture(_that);
      case ItineraryItemHotelCheckIn():
        return hotelCheckIn(_that);
      case ItineraryItemHotelCheckOut():
        return hotelCheckOut(_that);
      case ItineraryItemActivity():
        return activity(_that);
      case ItineraryItemLunch():
        return lunch(_that);
      case ItineraryItemDinner():
        return dinner(_that);
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
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ItineraryItemFlightArrival value)? flightArrival,
    TResult? Function(ItineraryItemFlightDeparture value)? flightDeparture,
    TResult? Function(ItineraryItemHotelCheckIn value)? hotelCheckIn,
    TResult? Function(ItineraryItemHotelCheckOut value)? hotelCheckOut,
    TResult? Function(ItineraryItemActivity value)? activity,
    TResult? Function(ItineraryItemLunch value)? lunch,
    TResult? Function(ItineraryItemDinner value)? dinner,
  }) {
    final _that = this;
    switch (_that) {
      case ItineraryItemFlightArrival() when flightArrival != null:
        return flightArrival(_that);
      case ItineraryItemFlightDeparture() when flightDeparture != null:
        return flightDeparture(_that);
      case ItineraryItemHotelCheckIn() when hotelCheckIn != null:
        return hotelCheckIn(_that);
      case ItineraryItemHotelCheckOut() when hotelCheckOut != null:
        return hotelCheckOut(_that);
      case ItineraryItemActivity() when activity != null:
        return activity(_that);
      case ItineraryItemLunch() when lunch != null:
        return lunch(_that);
      case ItineraryItemDinner() when dinner != null:
        return dinner(_that);
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
    final _that = this;
    switch (_that) {
      case ItineraryItemFlightArrival() when flightArrival != null:
        return flightArrival(_that.id, _that.time, _that.flightNumber,
            _that.airportCode, _that.note, _that.isCompleted);
      case ItineraryItemFlightDeparture() when flightDeparture != null:
        return flightDeparture(_that.id, _that.time, _that.flightNumber,
            _that.airportCode, _that.note, _that.isCompleted);
      case ItineraryItemHotelCheckIn() when hotelCheckIn != null:
        return hotelCheckIn(
            _that.id,
            _that.time,
            _that.hotelName,
            _that.address,
            _that.confirmationNumber,
            _that.note,
            _that.isCompleted);
      case ItineraryItemHotelCheckOut() when hotelCheckOut != null:
        return hotelCheckOut(_that.id, _that.time, _that.hotelName, _that.note,
            _that.isCompleted);
      case ItineraryItemActivity() when activity != null:
        return activity(
            _that.id,
            _that.time,
            _that.name,
            _that.description,
            _that.location,
            _that.durationHours,
            _that.cost,
            _that.bookingUrl,
            _that.note,
            _that.isCompleted);
      case ItineraryItemLunch() when lunch != null:
        return lunch(_that.id, _that.time, _that.name, _that.cuisine,
            _that.location, _that.priceRange, _that.note, _that.isCompleted);
      case ItineraryItemDinner() when dinner != null:
        return dinner(_that.id, _that.time, _that.name, _that.cuisine,
            _that.location, _that.priceRange, _that.note, _that.isCompleted);
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
    final _that = this;
    switch (_that) {
      case ItineraryItemFlightArrival():
        return flightArrival(_that.id, _that.time, _that.flightNumber,
            _that.airportCode, _that.note, _that.isCompleted);
      case ItineraryItemFlightDeparture():
        return flightDeparture(_that.id, _that.time, _that.flightNumber,
            _that.airportCode, _that.note, _that.isCompleted);
      case ItineraryItemHotelCheckIn():
        return hotelCheckIn(
            _that.id,
            _that.time,
            _that.hotelName,
            _that.address,
            _that.confirmationNumber,
            _that.note,
            _that.isCompleted);
      case ItineraryItemHotelCheckOut():
        return hotelCheckOut(_that.id, _that.time, _that.hotelName, _that.note,
            _that.isCompleted);
      case ItineraryItemActivity():
        return activity(
            _that.id,
            _that.time,
            _that.name,
            _that.description,
            _that.location,
            _that.durationHours,
            _that.cost,
            _that.bookingUrl,
            _that.note,
            _that.isCompleted);
      case ItineraryItemLunch():
        return lunch(_that.id, _that.time, _that.name, _that.cuisine,
            _that.location, _that.priceRange, _that.note, _that.isCompleted);
      case ItineraryItemDinner():
        return dinner(_that.id, _that.time, _that.name, _that.cuisine,
            _that.location, _that.priceRange, _that.note, _that.isCompleted);
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
    final _that = this;
    switch (_that) {
      case ItineraryItemFlightArrival() when flightArrival != null:
        return flightArrival(_that.id, _that.time, _that.flightNumber,
            _that.airportCode, _that.note, _that.isCompleted);
      case ItineraryItemFlightDeparture() when flightDeparture != null:
        return flightDeparture(_that.id, _that.time, _that.flightNumber,
            _that.airportCode, _that.note, _that.isCompleted);
      case ItineraryItemHotelCheckIn() when hotelCheckIn != null:
        return hotelCheckIn(
            _that.id,
            _that.time,
            _that.hotelName,
            _that.address,
            _that.confirmationNumber,
            _that.note,
            _that.isCompleted);
      case ItineraryItemHotelCheckOut() when hotelCheckOut != null:
        return hotelCheckOut(_that.id, _that.time, _that.hotelName, _that.note,
            _that.isCompleted);
      case ItineraryItemActivity() when activity != null:
        return activity(
            _that.id,
            _that.time,
            _that.name,
            _that.description,
            _that.location,
            _that.durationHours,
            _that.cost,
            _that.bookingUrl,
            _that.note,
            _that.isCompleted);
      case ItineraryItemLunch() when lunch != null:
        return lunch(_that.id, _that.time, _that.name, _that.cuisine,
            _that.location, _that.priceRange, _that.note, _that.isCompleted);
      case ItineraryItemDinner() when dinner != null:
        return dinner(_that.id, _that.time, _that.name, _that.cuisine,
            _that.location, _that.priceRange, _that.note, _that.isCompleted);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class ItineraryItemFlightArrival extends ItineraryItem {
  const ItineraryItemFlightArrival(
      {required this.id,
      required this.time,
      this.flightNumber,
      this.airportCode,
      this.note,
      this.isCompleted = false,
      final String? $type})
      : $type = $type ?? 'flightArrival',
        super._();
  factory ItineraryItemFlightArrival.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemFlightArrivalFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Scheduled time of arrival
  @override
  final DateTime time;

  /// Flight number
  final String? flightNumber;

  /// Airport code
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

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ItineraryItemFlightArrivalCopyWith<ItineraryItemFlightArrival>
      get copyWith =>
          _$ItineraryItemFlightArrivalCopyWithImpl<ItineraryItemFlightArrival>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ItineraryItemFlightArrivalToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ItineraryItemFlightArrival &&
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

  @override
  String toString() {
    return 'ItineraryItem.flightArrival(id: $id, time: $time, flightNumber: $flightNumber, airportCode: $airportCode, note: $note, isCompleted: $isCompleted)';
  }
}

/// @nodoc
abstract mixin class $ItineraryItemFlightArrivalCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory $ItineraryItemFlightArrivalCopyWith(ItineraryItemFlightArrival value,
          $Res Function(ItineraryItemFlightArrival) _then) =
      _$ItineraryItemFlightArrivalCopyWithImpl;
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
class _$ItineraryItemFlightArrivalCopyWithImpl<$Res>
    implements $ItineraryItemFlightArrivalCopyWith<$Res> {
  _$ItineraryItemFlightArrivalCopyWithImpl(this._self, this._then);

  final ItineraryItemFlightArrival _self;
  final $Res Function(ItineraryItemFlightArrival) _then;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? flightNumber = freezed,
    Object? airportCode = freezed,
    Object? note = freezed,
    Object? isCompleted = null,
  }) {
    return _then(ItineraryItemFlightArrival(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      flightNumber: freezed == flightNumber
          ? _self.flightNumber
          : flightNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      airportCode: freezed == airportCode
          ? _self.airportCode
          : airportCode // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class ItineraryItemFlightDeparture extends ItineraryItem {
  const ItineraryItemFlightDeparture(
      {required this.id,
      required this.time,
      this.flightNumber,
      this.airportCode,
      this.note,
      this.isCompleted = false,
      final String? $type})
      : $type = $type ?? 'flightDeparture',
        super._();
  factory ItineraryItemFlightDeparture.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemFlightDepartureFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Scheduled time of departure
  @override
  final DateTime time;

  /// Flight number
  final String? flightNumber;

  /// Airport code
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

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ItineraryItemFlightDepartureCopyWith<ItineraryItemFlightDeparture>
      get copyWith => _$ItineraryItemFlightDepartureCopyWithImpl<
          ItineraryItemFlightDeparture>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ItineraryItemFlightDepartureToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ItineraryItemFlightDeparture &&
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

  @override
  String toString() {
    return 'ItineraryItem.flightDeparture(id: $id, time: $time, flightNumber: $flightNumber, airportCode: $airportCode, note: $note, isCompleted: $isCompleted)';
  }
}

/// @nodoc
abstract mixin class $ItineraryItemFlightDepartureCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory $ItineraryItemFlightDepartureCopyWith(
          ItineraryItemFlightDeparture value,
          $Res Function(ItineraryItemFlightDeparture) _then) =
      _$ItineraryItemFlightDepartureCopyWithImpl;
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
class _$ItineraryItemFlightDepartureCopyWithImpl<$Res>
    implements $ItineraryItemFlightDepartureCopyWith<$Res> {
  _$ItineraryItemFlightDepartureCopyWithImpl(this._self, this._then);

  final ItineraryItemFlightDeparture _self;
  final $Res Function(ItineraryItemFlightDeparture) _then;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? flightNumber = freezed,
    Object? airportCode = freezed,
    Object? note = freezed,
    Object? isCompleted = null,
  }) {
    return _then(ItineraryItemFlightDeparture(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      flightNumber: freezed == flightNumber
          ? _self.flightNumber
          : flightNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      airportCode: freezed == airportCode
          ? _self.airportCode
          : airportCode // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class ItineraryItemHotelCheckIn extends ItineraryItem {
  const ItineraryItemHotelCheckIn(
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
  factory ItineraryItemHotelCheckIn.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemHotelCheckInFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Scheduled check-in time
  @override
  final DateTime time;

  /// Hotel/accommodation name
  final String? hotelName;

  /// Address of the accommodation
  final String? address;

  /// Confirmation number
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

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ItineraryItemHotelCheckInCopyWith<ItineraryItemHotelCheckIn> get copyWith =>
      _$ItineraryItemHotelCheckInCopyWithImpl<ItineraryItemHotelCheckIn>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ItineraryItemHotelCheckInToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ItineraryItemHotelCheckIn &&
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

  @override
  String toString() {
    return 'ItineraryItem.hotelCheckIn(id: $id, time: $time, hotelName: $hotelName, address: $address, confirmationNumber: $confirmationNumber, note: $note, isCompleted: $isCompleted)';
  }
}

/// @nodoc
abstract mixin class $ItineraryItemHotelCheckInCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory $ItineraryItemHotelCheckInCopyWith(ItineraryItemHotelCheckIn value,
          $Res Function(ItineraryItemHotelCheckIn) _then) =
      _$ItineraryItemHotelCheckInCopyWithImpl;
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
class _$ItineraryItemHotelCheckInCopyWithImpl<$Res>
    implements $ItineraryItemHotelCheckInCopyWith<$Res> {
  _$ItineraryItemHotelCheckInCopyWithImpl(this._self, this._then);

  final ItineraryItemHotelCheckIn _self;
  final $Res Function(ItineraryItemHotelCheckIn) _then;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? hotelName = freezed,
    Object? address = freezed,
    Object? confirmationNumber = freezed,
    Object? note = freezed,
    Object? isCompleted = null,
  }) {
    return _then(ItineraryItemHotelCheckIn(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hotelName: freezed == hotelName
          ? _self.hotelName
          : hotelName // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      confirmationNumber: freezed == confirmationNumber
          ? _self.confirmationNumber
          : confirmationNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class ItineraryItemHotelCheckOut extends ItineraryItem {
  const ItineraryItemHotelCheckOut(
      {required this.id,
      required this.time,
      this.hotelName,
      this.note,
      this.isCompleted = false,
      final String? $type})
      : $type = $type ?? 'hotelCheckOut',
        super._();
  factory ItineraryItemHotelCheckOut.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemHotelCheckOutFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Scheduled check-out time
  @override
  final DateTime time;

  /// Hotel/accommodation name
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

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ItineraryItemHotelCheckOutCopyWith<ItineraryItemHotelCheckOut>
      get copyWith =>
          _$ItineraryItemHotelCheckOutCopyWithImpl<ItineraryItemHotelCheckOut>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ItineraryItemHotelCheckOutToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ItineraryItemHotelCheckOut &&
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

  @override
  String toString() {
    return 'ItineraryItem.hotelCheckOut(id: $id, time: $time, hotelName: $hotelName, note: $note, isCompleted: $isCompleted)';
  }
}

/// @nodoc
abstract mixin class $ItineraryItemHotelCheckOutCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory $ItineraryItemHotelCheckOutCopyWith(ItineraryItemHotelCheckOut value,
          $Res Function(ItineraryItemHotelCheckOut) _then) =
      _$ItineraryItemHotelCheckOutCopyWithImpl;
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
class _$ItineraryItemHotelCheckOutCopyWithImpl<$Res>
    implements $ItineraryItemHotelCheckOutCopyWith<$Res> {
  _$ItineraryItemHotelCheckOutCopyWithImpl(this._self, this._then);

  final ItineraryItemHotelCheckOut _self;
  final $Res Function(ItineraryItemHotelCheckOut) _then;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? hotelName = freezed,
    Object? note = freezed,
    Object? isCompleted = null,
  }) {
    return _then(ItineraryItemHotelCheckOut(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hotelName: freezed == hotelName
          ? _self.hotelName
          : hotelName // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class ItineraryItemActivity extends ItineraryItem {
  const ItineraryItemActivity(
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
  factory ItineraryItemActivity.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemActivityFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Start time of the activity
  @override
  final DateTime time;

  /// Activity name/title
  final String name;

  /// Activity description
  final String? description;

  /// Location/address
  final String? location;

  /// Estimated duration in hours
  final int? durationHours;

  /// Estimated cost in local currency
  final double? cost;

  /// Booking URL if advance booking required
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

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ItineraryItemActivityCopyWith<ItineraryItemActivity> get copyWith =>
      _$ItineraryItemActivityCopyWithImpl<ItineraryItemActivity>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ItineraryItemActivityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ItineraryItemActivity &&
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

  @override
  String toString() {
    return 'ItineraryItem.activity(id: $id, time: $time, name: $name, description: $description, location: $location, durationHours: $durationHours, cost: $cost, bookingUrl: $bookingUrl, note: $note, isCompleted: $isCompleted)';
  }
}

/// @nodoc
abstract mixin class $ItineraryItemActivityCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory $ItineraryItemActivityCopyWith(ItineraryItemActivity value,
          $Res Function(ItineraryItemActivity) _then) =
      _$ItineraryItemActivityCopyWithImpl;
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
class _$ItineraryItemActivityCopyWithImpl<$Res>
    implements $ItineraryItemActivityCopyWith<$Res> {
  _$ItineraryItemActivityCopyWithImpl(this._self, this._then);

  final ItineraryItemActivity _self;
  final $Res Function(ItineraryItemActivity) _then;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(ItineraryItemActivity(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      durationHours: freezed == durationHours
          ? _self.durationHours
          : durationHours // ignore: cast_nullable_to_non_nullable
              as int?,
      cost: freezed == cost
          ? _self.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      bookingUrl: freezed == bookingUrl
          ? _self.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class ItineraryItemLunch extends ItineraryItem {
  const ItineraryItemLunch(
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
  factory ItineraryItemLunch.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemLunchFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Scheduled lunch time
  @override
  final DateTime time;

  /// Restaurant name
  final String name;

  /// Cuisine type
  final String? cuisine;

  /// Location/address
  final String? location;

  /// Average price range ($, $$, $$$)
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

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ItineraryItemLunchCopyWith<ItineraryItemLunch> get copyWith =>
      _$ItineraryItemLunchCopyWithImpl<ItineraryItemLunch>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ItineraryItemLunchToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ItineraryItemLunch &&
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

  @override
  String toString() {
    return 'ItineraryItem.lunch(id: $id, time: $time, name: $name, cuisine: $cuisine, location: $location, priceRange: $priceRange, note: $note, isCompleted: $isCompleted)';
  }
}

/// @nodoc
abstract mixin class $ItineraryItemLunchCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory $ItineraryItemLunchCopyWith(
          ItineraryItemLunch value, $Res Function(ItineraryItemLunch) _then) =
      _$ItineraryItemLunchCopyWithImpl;
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
class _$ItineraryItemLunchCopyWithImpl<$Res>
    implements $ItineraryItemLunchCopyWith<$Res> {
  _$ItineraryItemLunchCopyWithImpl(this._self, this._then);

  final ItineraryItemLunch _self;
  final $Res Function(ItineraryItemLunch) _then;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(ItineraryItemLunch(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      cuisine: freezed == cuisine
          ? _self.cuisine
          : cuisine // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      priceRange: freezed == priceRange
          ? _self.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class ItineraryItemDinner extends ItineraryItem {
  const ItineraryItemDinner(
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
  factory ItineraryItemDinner.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemDinnerFromJson(json);

  /// Unique identifier for this item
  @override
  final String id;

  /// Scheduled dinner time
  @override
  final DateTime time;

  /// Restaurant name
  final String name;

  /// Cuisine type
  final String? cuisine;

  /// Location/address
  final String? location;

  /// Average price range ($, $$, $$$)
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

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ItineraryItemDinnerCopyWith<ItineraryItemDinner> get copyWith =>
      _$ItineraryItemDinnerCopyWithImpl<ItineraryItemDinner>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ItineraryItemDinnerToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ItineraryItemDinner &&
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

  @override
  String toString() {
    return 'ItineraryItem.dinner(id: $id, time: $time, name: $name, cuisine: $cuisine, location: $location, priceRange: $priceRange, note: $note, isCompleted: $isCompleted)';
  }
}

/// @nodoc
abstract mixin class $ItineraryItemDinnerCopyWith<$Res>
    implements $ItineraryItemCopyWith<$Res> {
  factory $ItineraryItemDinnerCopyWith(
          ItineraryItemDinner value, $Res Function(ItineraryItemDinner) _then) =
      _$ItineraryItemDinnerCopyWithImpl;
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
class _$ItineraryItemDinnerCopyWithImpl<$Res>
    implements $ItineraryItemDinnerCopyWith<$Res> {
  _$ItineraryItemDinnerCopyWithImpl(this._self, this._then);

  final ItineraryItemDinner _self;
  final $Res Function(ItineraryItemDinner) _then;

  /// Create a copy of ItineraryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(ItineraryItemDinner(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      cuisine: freezed == cuisine
          ? _self.cuisine
          : cuisine // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      priceRange: freezed == priceRange
          ? _self.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
