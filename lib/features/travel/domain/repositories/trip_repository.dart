import 'package:soloadventurer/features/offline/data/repositories/offline_aware_repository.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';

/// Repository interface for Trip data management
///
/// This repository provides offline-first data access for trips.
/// All operations return [RepositoryOperationResult] to indicate
/// whether the operation was executed immediately or queued for sync.
abstract class TripRepository {
  /// Get a trip by ID
  ///
  /// Returns the trip from local cache or fetches from remote if not available.
  /// Throws [CacheException] if offline and trip not in local cache.
  Future<Trip> getTripById(String id);

  /// Get all trips for a user
  ///
  /// Returns trips from local cache or fetches from remote if not available.
  /// Throws [CacheException] if offline and no trips in local cache.
  Future<List<Trip>> getTrips({String? userId});

  /// Create a new trip
  ///
  /// Returns [RepositoryOperationResult] indicating whether the operation
  /// was executed immediately (online) or queued for sync (offline).
  Future<RepositoryOperationResult<Trip>> createTrip(Trip trip);

  /// Update an existing trip
  ///
  /// Returns [RepositoryOperationResult] indicating whether the operation
  /// was executed immediately (online) or queued for sync (offline).
  Future<RepositoryOperationResult<Trip>> updateTrip(String id, Trip trip);

  /// Delete a trip
  ///
  /// Returns [RepositoryOperationResult] indicating whether the operation
  /// was executed immediately (online) or queued for sync (offline).
  Future<RepositoryOperationResult<void>> deleteTrip(String id);

  /// Get trips by status
  ///
  /// Returns trips matching the specified status from local cache.
  Future<List<Trip>> getTripsByStatus(String status, {String? userId});

  /// Get trips by date range
  ///
  /// Returns trips that fall within the specified date range from local cache.
  Future<List<Trip>> getTripsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
  });

  /// Search trips by title or destination
  ///
  /// Returns trips matching the search term from local cache.
  Future<List<Trip>> searchTrips(String searchTerm, {String? userId});
}
