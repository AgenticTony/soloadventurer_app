import 'package:soloadventurer/features/journal/domain/entities/trip.dart';

/// Repository interface for trip operations
abstract class TripRepository {
  /// Creates a new trip
  ///
  /// Returns the created trip with server-generated ID
  /// Throws [AppException] if creation fails
  Future<Trip> createTrip(Trip trip);

  /// Gets a trip by ID
  ///
  /// Throws [AppException] if trip not found or retrieval fails
  Future<Trip> getTrip(String tripId);

  /// Gets all trips for the current user
  ///
  /// Throws [AppException] if retrieval fails
  Future<List<Trip>> getTrips();

  /// Gets trips within a date range
  ///
  /// Throws [AppException] if retrieval fails
  Future<List<Trip>> getTripsByDateRange(DateTime startDate, DateTime endDate);

  /// Gets ongoing trips (where end_date is null or in the future)
  ///
  /// Throws [AppException] if retrieval fails
  Future<List<Trip>> getOngoingTrips();

  /// Updates an existing trip
  ///
  /// Returns the updated trip
  /// Throws [AppException] if update fails
  Future<Trip> updateTrip(Trip trip);

  /// Deletes a trip
  ///
  /// Throws [AppException] if deletion fails
  Future<void> deleteTrip(String tripId);

  /// Gets the number of entries in a trip
  ///
  /// Throws [AppException] if retrieval fails
  Future<int> getEntryCountForTrip(String tripId);
}
