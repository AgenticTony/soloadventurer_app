// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItineraryItemFlightArrivalImpl _$$ItineraryItemFlightArrivalImplFromJson(
        Map<String, dynamic> json) =>
    _$ItineraryItemFlightArrivalImpl(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      flightNumber: json['flightNumber'] as String?,
      airportCode: json['airportCode'] as String?,
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ItineraryItemFlightArrivalImplToJson(
        _$ItineraryItemFlightArrivalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time.toIso8601String(),
      'flightNumber': instance.flightNumber,
      'airportCode': instance.airportCode,
      'note': instance.note,
      'isCompleted': instance.isCompleted,
      'runtimeType': instance.$type,
    };

_$ItineraryItemFlightDepartureImpl _$$ItineraryItemFlightDepartureImplFromJson(
        Map<String, dynamic> json) =>
    _$ItineraryItemFlightDepartureImpl(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      flightNumber: json['flightNumber'] as String?,
      airportCode: json['airportCode'] as String?,
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ItineraryItemFlightDepartureImplToJson(
        _$ItineraryItemFlightDepartureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time.toIso8601String(),
      'flightNumber': instance.flightNumber,
      'airportCode': instance.airportCode,
      'note': instance.note,
      'isCompleted': instance.isCompleted,
      'runtimeType': instance.$type,
    };

_$ItineraryItemHotelCheckInImpl _$$ItineraryItemHotelCheckInImplFromJson(
        Map<String, dynamic> json) =>
    _$ItineraryItemHotelCheckInImpl(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      hotelName: json['hotelName'] as String?,
      address: json['address'] as String?,
      confirmationNumber: json['confirmationNumber'] as String?,
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ItineraryItemHotelCheckInImplToJson(
        _$ItineraryItemHotelCheckInImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time.toIso8601String(),
      'hotelName': instance.hotelName,
      'address': instance.address,
      'confirmationNumber': instance.confirmationNumber,
      'note': instance.note,
      'isCompleted': instance.isCompleted,
      'runtimeType': instance.$type,
    };

_$ItineraryItemHotelCheckOutImpl _$$ItineraryItemHotelCheckOutImplFromJson(
        Map<String, dynamic> json) =>
    _$ItineraryItemHotelCheckOutImpl(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      hotelName: json['hotelName'] as String?,
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ItineraryItemHotelCheckOutImplToJson(
        _$ItineraryItemHotelCheckOutImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time.toIso8601String(),
      'hotelName': instance.hotelName,
      'note': instance.note,
      'isCompleted': instance.isCompleted,
      'runtimeType': instance.$type,
    };

_$ItineraryItemActivityImpl _$$ItineraryItemActivityImplFromJson(
        Map<String, dynamic> json) =>
    _$ItineraryItemActivityImpl(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      name: json['name'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      durationHours: (json['durationHours'] as num?)?.toInt(),
      cost: (json['cost'] as num?)?.toDouble(),
      bookingUrl: json['bookingUrl'] as String?,
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ItineraryItemActivityImplToJson(
        _$ItineraryItemActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time.toIso8601String(),
      'name': instance.name,
      'description': instance.description,
      'location': instance.location,
      'durationHours': instance.durationHours,
      'cost': instance.cost,
      'bookingUrl': instance.bookingUrl,
      'note': instance.note,
      'isCompleted': instance.isCompleted,
      'runtimeType': instance.$type,
    };

_$ItineraryItemLunchImpl _$$ItineraryItemLunchImplFromJson(
        Map<String, dynamic> json) =>
    _$ItineraryItemLunchImpl(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      name: json['name'] as String,
      cuisine: json['cuisine'] as String?,
      location: json['location'] as String?,
      priceRange: json['priceRange'] as String?,
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ItineraryItemLunchImplToJson(
        _$ItineraryItemLunchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time.toIso8601String(),
      'name': instance.name,
      'cuisine': instance.cuisine,
      'location': instance.location,
      'priceRange': instance.priceRange,
      'note': instance.note,
      'isCompleted': instance.isCompleted,
      'runtimeType': instance.$type,
    };

_$ItineraryItemDinnerImpl _$$ItineraryItemDinnerImplFromJson(
        Map<String, dynamic> json) =>
    _$ItineraryItemDinnerImpl(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      name: json['name'] as String,
      cuisine: json['cuisine'] as String?,
      location: json['location'] as String?,
      priceRange: json['priceRange'] as String?,
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ItineraryItemDinnerImplToJson(
        _$ItineraryItemDinnerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time.toIso8601String(),
      'name': instance.name,
      'cuisine': instance.cuisine,
      'location': instance.location,
      'priceRange': instance.priceRange,
      'note': instance.note,
      'isCompleted': instance.isCompleted,
      'runtimeType': instance.$type,
    };
