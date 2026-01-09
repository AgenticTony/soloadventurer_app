import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';

/// Extension to convert [LocalItinerary] to domain [Itinerary]
extension ItineraryModelExtension on LocalItinerary {
  /// Converts database entity to domain entity
  Itinerary toDomainEntity(List<LocalItineraryItem> items) {
    return Itinerary(
      id: id,
      name: name,
      destination: Destination(
        placeId: destinationPlaceId,
        name: destinationName,
        latitude: destinationLatitude,
        longitude: destinationLongitude,
        airportCode: destinationAirportCode,
      ),
      dateRange: DateRange(start: startDate, end: endDate),
      items: items
          .where((item) => !item.isDeleted)
          .map((item) => item.toDomainEntity())
          .toList(),
      isStarter: isStarter,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      coverImageUrl: coverImageUrl,
    );
  }
}

/// Extension to convert domain [Itinerary] to database [LocalItinerary]
extension ItineraryEntityExtension on Itinerary {
  /// Converts domain entity to database entity
  LocalItinerary toDatabaseEntity() {
    return LocalItinerary(
      id: id,
      userId: userId,
      name: name,
      destinationPlaceId: destination.placeId,
      destinationName: destination.name,
      destinationLatitude: destination.latitude,
      destinationLongitude: destination.longitude,
      destinationAirportCode: destination.airportCode,
      startDate: dateRange.start,
      endDate: dateRange.end,
      numberOfDays: dateRange.numberOfDays,
      isStarter: isStarter,
      coverImageUrl: coverImageUrl,
      itemsCount: items.length,
      completedItemsCount: items.where((i) => i.isCompleted).length,
      completionPercentage: completionPercentage.round(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: false, // Will be set by repository
      hasPendingChanges: false, // Will be set by repository
      version: 1,
      isDeleted: false,
      lastSyncedAt: null,
    );
  }
}

/// Extension to convert [LocalItineraryItem] to domain [ItineraryItem]
extension ItineraryItemModelExtension on LocalItineraryItem {
  /// Converts database entity to domain entity
  ItineraryItem toDomainEntity() {
    return switch (type) {
      'flight_arrival' => ItineraryItem.flightArrival(
          id: id,
          time: time,
          flightNumber: null, // Not stored in DB
          airportCode: null, // Not stored in DB
          note: note,
          isCompleted: isCompleted,
        ),
      'flight_departure' => ItineraryItem.flightDeparture(
          id: id,
          time: time,
          flightNumber: null,
          airportCode: null,
          note: note,
          isCompleted: isCompleted,
        ),
      'hotel_check_in' => ItineraryItem.hotelCheckIn(
          id: id,
          time: time,
          hotelName: name ?? 'Hotel',
          address: location,
          confirmationNumber: null, // Not stored in DB
          note: note,
          isCompleted: isCompleted,
        ),
      'hotel_check_out' => ItineraryItem.hotelCheckOut(
          id: id,
          time: time,
          hotelName: name ?? 'Hotel',
          note: note,
          isCompleted: isCompleted,
        ),
      'activity' => ItineraryItem.activity(
          id: id,
          time: time,
          name: name ?? 'Activity',
          description: note,
          location: location,
          durationHours: null, // Not stored in DB
          cost: null, // Not stored in DB
          bookingUrl: null, // Not stored in DB
          note: note,
          isCompleted: isCompleted,
        ),
      'lunch' => ItineraryItem.lunch(
          id: id,
          time: time,
          name: name ?? 'Lunch',
          cuisine: null, // Not stored in DB
          location: location,
          priceRange: null, // Not stored in DB
          note: note,
          isCompleted: isCompleted,
        ),
      'dinner' => ItineraryItem.dinner(
          id: id,
          time: time,
          name: name ?? 'Dinner',
          cuisine: null,
          location: location,
          priceRange: null,
          note: note,
          isCompleted: isCompleted,
        ),
      _ => ItineraryItem.activity(
          id: id,
          time: time,
          name: name ?? 'Unknown',
          description: note,
          location: location,
          isCompleted: isCompleted,
        ),
    };
  }
}

/// Extension to convert domain [ItineraryItem] to database [LocalItineraryItem]
extension ItineraryItemEntityExtension on ItineraryItem {
  /// Converts domain entity to database entity
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// The [dayNumber] parameter is the day number in the itinerary.
  /// The [sortOrder] parameter is the order within the day.
  LocalItineraryItem toDatabaseEntity({
    required String itineraryId,
    required int dayNumber,
    required int sortOrder,
  }) {
    final now = DateTime.now();

    return map(
      flightArrival: (item) => LocalItineraryItem(
            id: item.id,
            itineraryId: itineraryId,
            type: 'flight_arrival',
            time: item.time,
            isCompleted: item.isCompleted,
            name: 'Flight Arrival',
            note: item.note,
            location: null,
            latitude: null,
            longitude: null,
            dayNumber: dayNumber,
            sortOrder: sortOrder,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            hasPendingChanges: false,
            version: 1,
            isDeleted: false,
            lastSyncedAt: null,
          ),
      flightDeparture: (item) => LocalItineraryItem(
            id: item.id,
            itineraryId: itineraryId,
            type: 'flight_departure',
            time: item.time,
            isCompleted: item.isCompleted,
            name: 'Flight Departure',
            note: item.note,
            location: null,
            latitude: null,
            longitude: null,
            dayNumber: dayNumber,
            sortOrder: sortOrder,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            hasPendingChanges: false,
            version: 1,
            isDeleted: false,
            lastSyncedAt: null,
          ),
      hotelCheckIn: (item) => LocalItineraryItem(
            id: item.id,
            itineraryId: itineraryId,
            type: 'hotel_check_in',
            time: item.time,
            isCompleted: item.isCompleted,
            name: item.hotelName,
            note: item.note,
            location: item.address,
            latitude: null,
            longitude: null,
            dayNumber: dayNumber,
            sortOrder: sortOrder,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            hasPendingChanges: false,
            version: 1,
            isDeleted: false,
            lastSyncedAt: null,
          ),
      hotelCheckOut: (item) => LocalItineraryItem(
            id: item.id,
            itineraryId: itineraryId,
            type: 'hotel_check_out',
            time: item.time,
            isCompleted: item.isCompleted,
            name: item.hotelName,
            note: item.note,
            location: null,
            latitude: null,
            longitude: null,
            dayNumber: dayNumber,
            sortOrder: sortOrder,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            hasPendingChanges: false,
            version: 1,
            isDeleted: false,
            lastSyncedAt: null,
          ),
      activity: (item) => LocalItineraryItem(
            id: item.id,
            itineraryId: itineraryId,
            type: 'activity',
            time: item.time,
            isCompleted: item.isCompleted,
            name: item.name,
            note: item.note ?? item.description,
            location: item.location,
            latitude: null,
            longitude: null,
            dayNumber: dayNumber,
            sortOrder: sortOrder,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            hasPendingChanges: false,
            version: 1,
            isDeleted: false,
            lastSyncedAt: null,
          ),
      lunch: (item) => LocalItineraryItem(
            id: item.id,
            itineraryId: itineraryId,
            type: 'lunch',
            time: item.time,
            isCompleted: item.isCompleted,
            name: item.name,
            note: item.note,
            location: item.location,
            latitude: null,
            longitude: null,
            dayNumber: dayNumber,
            sortOrder: sortOrder,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            hasPendingChanges: false,
            version: 1,
            isDeleted: false,
            lastSyncedAt: null,
          ),
      dinner: (item) => LocalItineraryItem(
            id: item.id,
            itineraryId: itineraryId,
            type: 'dinner',
            time: item.time,
            isCompleted: item.isCompleted,
            name: item.name,
            note: item.note,
            location: item.location,
            latitude: null,
            longitude: null,
            dayNumber: dayNumber,
            sortOrder: sortOrder,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            hasPendingChanges: false,
            version: 1,
            isDeleted: false,
            lastSyncedAt: null,
          ),
    );
  }
}
