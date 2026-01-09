import 'package:soloadventurer/core/error/exceptions.dart';
import 'package:soloadventurer/features/journal/data/models/trip_model.dart';

/// Remote data source interface for trip operations
abstract class TripRemoteDataSource {
  /// Creates a new trip
  ///
  /// Throws [ServerException] if creation fails
  Future<TripModel> createTrip(TripModel trip);

  /// Gets a trip by ID
  ///
  /// Throws [ServerException] if trip not found or retrieval fails
  Future<TripModel> getTrip(String tripId);

  /// Gets all trips for the current user
  ///
  /// Throws [ServerException] if retrieval fails
  Future<List<TripModel>> getTrips();

  /// Gets trips within a date range
  ///
  /// Throws [ServerException] if retrieval fails
  Future<List<TripModel>> getTripsByDateRange(DateTime startDate, DateTime endDate);

  /// Gets ongoing trips (where end_date is null or in the future)
  ///
  /// Throws [ServerException] if retrieval fails
  Future<List<TripModel>> getOngoingTrips();

  /// Updates an existing trip
  ///
  /// Throws [ServerException] if update fails
  Future<TripModel> updateTrip(TripModel trip);

  /// Deletes a trip
  ///
  /// Throws [ServerException] if deletion fails
  Future<void> deleteTrip(String tripId);

  /// Gets the number of entries in a trip
  ///
  /// Throws [ServerException] if retrieval fails
  Future<int> getEntryCountForTrip(String tripId);
}
