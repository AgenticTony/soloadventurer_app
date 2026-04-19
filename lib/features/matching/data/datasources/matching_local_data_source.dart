import 'package:soloadventurer/features/matching/data/models/trip_model.dart';
import 'package:soloadventurer/features/matching/data/models/connection_model.dart';
import 'package:soloadventurer/features/matching/data/models/activity_model.dart';

/// Local data source for matching operations (Drift/SQLite)
///
/// Provides offline-first data persistence following the patterns
/// established in the offline-first spike (docs/matching/spike-offline-first/SPIKE_REPORT.md)
abstract class MatchingLocalDataSource {
  // ============================================================
  // TRIPS
  // ============================================================

  /// Create a new trip locally
  Future<TripModel> createTrip(TripModel trip);

  /// Get all trips from local database
  Future<List<TripModel>> getUserTrips();

  /// Get a specific trip by ID from local database
  Future<TripModel?> getTrip(String tripId);

  /// Update an existing trip locally
  Future<TripModel> updateTrip(TripModel trip);

  /// Delete a trip from local database
  Future<void> deleteTrip(String tripId);

  /// Archive expired trips locally
  Future<void> archiveExpiredTrips();

  /// Clear all local trips
  Future<void> clearTrips();

  // ============================================================
  // MATCHES / CONNECTIONS
  // ============================================================

  /// Cache matches locally
  Future<void> cacheMatches(List<ConnectionModel> matches);

  /// Get cached matches from local database
  Future<List<ConnectionModel>> getMatches();

  /// Get a specific connection by ID
  Future<ConnectionModel?> getConnection(String connectionId);

  /// Hide a connection locally
  Future<void> hideConnection(String connectionId);

  /// Clear all cached matches
  Future<void> clearMatches();

  /// Get nearby travelers count from cache
  Future<int?> getNearbyTravelersCount();

  /// Cache nearby travelers count
  Future<void> cacheNearbyTravelersCount(int count);

  // ============================================================
  // ACTIVITIES
  // ============================================================

  /// Cache activities list locally
  Future<void> cacheActivities(List<ActivityModel> activities);

  /// Get cached activities
  Future<List<ActivityModel>> getActivities();

  /// Get user's selected activities
  Future<List<ActivityModel>> getUserActivities();

  /// Cache user's selected activities
  Future<void> cacheUserActivities(List<ActivityModel> activities);

  /// Add a user activity locally
  Future<void> addUserActivity(String activityId);

  /// Remove a user activity locally
  Future<void> removeUserActivity(String activityId);

  /// Clear all cached activities
  Future<void> clearActivities();

  // ============================================================
  // SYNC METADATA
  // ============================================================

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTimestamp();

  /// Set last sync timestamp
  Future<void> setLastSyncTimestamp(DateTime timestamp);

  /// Get list of pending changes to sync
  Future<List<Map<String, dynamic>>> getPendingChanges();

  /// Mark a change as synced
  Future<void> markChangeAsSynced(String changeId);

  /// Clear all pending changes
  Future<void> clearPendingChanges();

  /// Save sync queue to local storage
  Future<void> saveSyncQueue(List<Map<String, dynamic>> queue);

  /// Get sync queue from local storage
  Future<List<Map<String, dynamic>>> getSyncQueue();

  // ============================================================
  // DATABASE MANAGEMENT
  // ============================================================

  /// Clear all local data
  Future<void> clearAllData();

  /// Initialize database tables
  Future<void> initializeDatabase();

  /// Check database health
  Future<bool> isDatabaseHealthy();
}
