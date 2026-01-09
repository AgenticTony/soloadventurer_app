// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItineraryItemFlightArrival _$ItineraryItemFlightArrivalFromJson(
        Map<String, dynamic> json) =>
    ItineraryItemFlightArrival(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      flightNumber: json['flightNumber'] as String?,
      airportCode: json['airportCode'] as String?,
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ItineraryItemFlightArrivalToJson(
        ItineraryItemFlightArrival instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time.toIso8601String(),
      'flightNumber': instance.flightNumber,
      'airportCode': instance.airportCode,
      'note': instance.note,
      'isCompleted': instance.isCompleted,
      'runtimeType': instance.$type,
    };

ItineraryItemFlightDeparture _$ItineraryItemFlightDepartureFromJson(
        Map<String, dynamic> json) =>
    ItineraryItemFlightDeparture(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      flightNumber: json['flightNumber'] as String?,
      airportCode: json['airportCode'] as String?,
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ItineraryItemFlightDepartureToJson(
        ItineraryItemFlightDeparture instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time.toIso8601String(),
      'flightNumber': instance.flightNumber,
      'airportCode': instance.airportCode,
      'note': instance.note,
      'isCompleted': instance.isCompleted,
      'runtimeType': instance.$type,
    };

ItineraryItemHotelCheckIn _$ItineraryItemHotelCheckInFromJson(
        Map<String, dynamic> json) =>
    ItineraryItemHotelCheckIn(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      hotelName: json['hotelName'] as String?,
      address: json['address'] as String?,
      confirmationNumber: json['confirmationNumber'] as String?,
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ItineraryItemHotelCheckInToJson(
        ItineraryItemHotelCheckIn instance) =>
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

ItineraryItemHotelCheckOut _$ItineraryItemHotelCheckOutFromJson(
        Map<String, dynamic> json) =>
    ItineraryItemHotelCheckOut(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      hotelName: json['hotelName'] as String?,
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ItineraryItemHotelCheckOutToJson(
        ItineraryItemHotelCheckOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time.toIso8601String(),
      'hotelName': instance.hotelName,
      'note': instance.note,
      'isCompleted': instance.isCompleted,
      'runtimeType': instance.$type,
    };

ItineraryItemActivity _$ItineraryItemActivityFromJson(
        Map<String, dynamic> json) =>
    ItineraryItemActivity(
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

Map<String, dynamic> _$ItineraryItemActivityToJson(
        ItineraryItemActivity instance) =>
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

ItineraryItemLunch _$ItineraryItemLunchFromJson(Map<String, dynamic> json) =>
    ItineraryItemLunch(
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

Map<String, dynamic> _$ItineraryItemLunchToJson(ItineraryItemLunch instance) =>
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

ItineraryItemDinner _$ItineraryItemDinnerFromJson(Map<String, dynamic> json) =>
    ItineraryItemDinner(
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

Map<String, dynamic> _$ItineraryItemDinnerToJson(
        ItineraryItemDinner instance) =>
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
