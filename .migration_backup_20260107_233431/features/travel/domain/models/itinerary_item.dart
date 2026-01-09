import 'package:freezed_annotation/freezed_annotation.dart';

part 'itinerary_item.freezed.dart';
part 'itinerary_item.g.dart';

/// A single item within a travel itinerary
///
/// Uses a sealed class pattern to represent different types of
/// itinerary activities such as flights, hotel stays, meals, and activities.
/// Each type has its own specific fields while sharing common properties.
@freezed
sealed class ItineraryItem with _$ItineraryItem {
  const ItineraryItem._();

  /// Flight arrival at the destination
  ///
  /// Used on the first day of the trip to track when the user lands.
  const factory ItineraryItem.flightArrival({
    /// Unique identifier for this item
    required String id,

    /// Scheduled time of arrival
    required DateTime time,

    /// Flight number
    String? flightNumber,

    /// Airport code
    String? airportCode,

    /// Additional notes
    String? note,

    /// Whether this item is completed
    @Default(false) bool isCompleted,
  }) = ItineraryItemFlightArrival;

  /// Flight departure from the destination
  ///
  /// Used on the last day of the trip to track when the user leaves.
  const factory ItineraryItem.flightDeparture({
    /// Unique identifier for this item
    required String id,

    /// Scheduled time of departure
    required DateTime time,

    /// Flight number
    String? flightNumber,

    /// Airport code
    String? airportCode,

    /// Additional notes
    String? note,

    /// Whether this item is completed
    @Default(false) bool isCompleted,
  }) = ItineraryItemFlightDeparture;

  /// Hotel check-in
  ///
  /// Records when and where the user checks into their accommodation.
  const factory ItineraryItem.hotelCheckIn({
    /// Unique identifier for this item
    required String id,

    /// Scheduled check-in time
    required DateTime time,

    /// Hotel/accommodation name
    String? hotelName,

    /// Address of the accommodation
    String? address,

    /// Confirmation number
    String? confirmationNumber,

    /// Additional notes
    String? note,

    /// Whether this item is completed
    @Default(false) bool isCompleted,
  }) = ItineraryItemHotelCheckIn;

  /// Hotel check-out
  ///
  /// Records when the user checks out of their accommodation.
  const factory ItineraryItem.hotelCheckOut({
    /// Unique identifier for this item
    required String id,

    /// Scheduled check-out time
    required DateTime time,

    /// Hotel/accommodation name
    String? hotelName,

    /// Additional notes
    String? note,

    /// Whether this item is completed
    @Default(false) bool isCompleted,
  }) = ItineraryItemHotelCheckOut;

  /// Generic activity or attraction
  ///
  /// Can include museums, tours, sightseeing, cultural experiences, etc.
  const factory ItineraryItem.activity({
    /// Unique identifier for this item
    required String id,

    /// Start time of the activity
    required DateTime time,

    /// Activity name/title
    required String name,

    /// Activity description
    String? description,

    /// Location/address
    String? location,

    /// Estimated duration in hours
    int? durationHours,

    /// Estimated cost in local currency
    double? cost,

    /// Booking URL if advance booking required
    String? bookingUrl,

    /// Additional notes
    String? note,

    /// Whether this item is completed
    @Default(false) bool isCompleted,
  }) = ItineraryItemActivity;

  /// Lunch meal
  ///
  /// Restaurant or meal recommendation for lunch.
  const factory ItineraryItem.lunch({
    /// Unique identifier for this item
    required String id,

    /// Scheduled lunch time
    required DateTime time,

    /// Restaurant name
    required String name,

    /// Cuisine type
    String? cuisine,

    /// Location/address
    String? location,

    /// Average price range ($, $$, $$$)
    String? priceRange,

    /// Additional notes
    String? note,

    /// Whether this item is completed
    @Default(false) bool isCompleted,
  }) = ItineraryItemLunch;

  /// Dinner meal
  ///
  /// Restaurant or meal recommendation for dinner.
  const factory ItineraryItem.dinner({
    /// Unique identifier for this item
    required String id,

    /// Scheduled dinner time
    required DateTime time,

    /// Restaurant name
    required String name,

    /// Cuisine type
    String? cuisine,

    /// Location/address
    String? location,

    /// Average price range ($, $$, $$$)
    String? priceRange,

    /// Additional notes
    String? note,

    /// Whether this item is completed
    @Default(false) bool isCompleted,
  }) = ItineraryItemDinner;

  /// Creates an ItineraryItem from JSON
  factory ItineraryItem.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemFromJson(json);

  /// Returns the unique identifier for this item
  @override
  String get id => map(
    flightArrival: (item) => item.id,
    flightDeparture: (item) => item.id,
    hotelCheckIn: (item) => item.id,
    hotelCheckOut: (item) => item.id,
    activity: (item) => item.id,
    lunch: (item) => item.id,
    dinner: (item) => item.id,
  );

  /// Returns a display-friendly name for this item
  String get displayName => map(
    flightArrival: (item) => 'Flight Arrival ${item.flightNumber ?? ''}',
    flightDeparture: (item) => 'Flight Departure ${item.flightNumber ?? ''}',
    hotelCheckIn: (item) => 'Check-in at ${item.hotelName ?? 'Hotel'}',
    hotelCheckOut: (item) => 'Check-out from ${item.hotelName ?? 'Hotel'}',
    activity: (item) => item.name,
    lunch: (item) => 'Lunch at ${item.name}',
    dinner: (item) => 'Dinner at ${item.name}',
  );

  /// Alias for displayName - used by widgets
  String get name => displayName;

  /// Returns the location/address for this item (if any)
  String? get location => mapOrNull(
    flightArrival: (item) => item.airportCode,
    flightDeparture: (item) => item.airportCode,
    hotelCheckIn: (item) => item.address,
    hotelCheckOut: (_) => null,
    activity: (item) => item.location,
    lunch: (item) => item.location,
    dinner: (item) => item.location,
  );

  /// Returns the note for this item (if any)
  @override
  String? get note => mapOrNull(
    flightArrival: (item) => item.note,
    flightDeparture: (item) => item.note,
    hotelCheckIn: (item) => item.note,
    hotelCheckOut: (item) => item.note,
    activity: (item) => item.note,
    lunch: (item) => item.note,
    dinner: (item) => item.note,
  );

  /// Returns the scheduled time for this item
  @override
  DateTime get time => when(
    flightArrival: (id, time, flightNumber, airportCode, note, isCompleted) => time,
    flightDeparture: (id, time, flightNumber, airportCode, note, isCompleted) => time,
    hotelCheckIn: (id, time, hotelName, address, confirmationNumber, note, isCompleted) => time,
    hotelCheckOut: (id, time, hotelName, note, isCompleted) => time,
    activity: (id, time, name, description, location, durationHours, cost, bookingUrl, note, isCompleted) => time,
    lunch: (id, time, name, cuisine, location, priceRange, note, isCompleted) => time,
    dinner: (id, time, name, cuisine, location, priceRange, note, isCompleted) => time,
  );

  /// Returns the completion status for this item
  @override
  bool get isCompleted => when(
    flightArrival: (id, time, flightNumber, airportCode, note, isCompleted) => isCompleted,
    flightDeparture: (id, time, flightNumber, airportCode, note, isCompleted) => isCompleted,
    hotelCheckIn: (id, time, hotelName, address, confirmationNumber, note, isCompleted) => isCompleted,
    hotelCheckOut: (id, time, hotelName, note, isCompleted) => isCompleted,
    activity: (id, time, name, description, location, durationHours, cost, bookingUrl, note, isCompleted) => isCompleted,
    lunch: (id, time, name, cuisine, location, priceRange, note, isCompleted) => isCompleted,
    dinner: (id, time, name, cuisine, location, priceRange, note, isCompleted) => isCompleted,
  );
}
