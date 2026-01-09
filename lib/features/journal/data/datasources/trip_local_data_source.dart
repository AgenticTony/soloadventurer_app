import 'package:soloadventurer/features/journal/data/models/trip_model.dart';

/// Local data source interface for trips using SQLite
abstract class TripLocalDataSource {
  /// Creates a new trip in local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<TripModel> createTrip(TripModel trip);

  /// Updates an existing trip in local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<TripModel> updateTrip(TripModel trip);

  /// Retrieves a trip by ID from local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  /// Returns null if the trip is not found
  Future<TripModel?> getTrip(String tripId);

  /// Retrieves all trips from local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<TripModel>> getTrips();

  /// Retrieves trips with a specific sync status
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<TripModel>> getTripsBySyncStatus(String syncStatus);

  /// Updates the sync status of a trip
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<TripModel> updateSyncStatus(String tripId, String syncStatus);

  /// Deletes a trip from local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<void> deleteTrip(String tripId);

  /// Clears all trip data from local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<void> clearAll();
}
