import 'package:soloadventurer/features/matching/data/datasources/matching_local_data_source.dart';
import 'package:soloadventurer/features/matching/data/models/trip_model.dart';
import 'package:soloadventurer/features/matching/data/models/connection_model.dart';
import 'package:soloadventurer/features/matching/data/models/activity_model.dart';

/// In-memory implementation of [MatchingLocalDataSource]
///
/// Provides temporary local caching for matching data. For MVP, this uses
/// in-memory storage. A Drift-backed implementation should replace this
/// when full offline support is needed (see offline feature's database service).
class MatchingLocalDataSourceImpl implements MatchingLocalDataSource {
  final List<TripModel> _trips = [];
  final List<ConnectionModel> _matches = [];
  final List<ActivityModel> _activities = [];
  final List<ActivityModel> _userActivities = [];
  DateTime? _lastSyncTimestamp;
  int? _nearbyTravelersCount;

  // ============================================================
  // TRIPS
  // ============================================================

  @override
  Future<TripModel> createTrip(TripModel trip) async {
    _trips.add(trip);
    return trip;
  }

  @override
  Future<List<TripModel>> getUserTrips() async => List.unmodifiable(_trips);

  @override
  Future<TripModel?> getTrip(String tripId) async {
    try {
      return _trips.firstWhere((t) => t.id == tripId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<TripModel> updateTrip(TripModel trip) async {
    final index = _trips.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      _trips[index] = trip;
    }
    return trip;
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    _trips.removeWhere((t) => t.id == tripId);
  }

  @override
  Future<void> archiveExpiredTrips() async {
    final now = DateTime.now();
    _trips.removeWhere((t) => t.endDate.isBefore(now));
  }

  @override
  Future<void> clearTrips() async {
    _trips.clear();
  }

  // ============================================================
  // MATCHES / CONNECTIONS
  // ============================================================

  @override
  Future<void> cacheMatches(List<ConnectionModel> matches) async {
    _matches
      ..clear()
      ..addAll(matches);
  }

  @override
  Future<List<ConnectionModel>> getMatches() async =>
      List.unmodifiable(_matches);

  @override
  Future<ConnectionModel?> getConnection(String connectionId) async {
    try {
      return _matches.firstWhere((m) => m.id == connectionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> hideConnection(String connectionId) async {
    _matches.removeWhere((m) => m.id == connectionId);
  }

  @override
  Future<void> clearMatches() async {
    _matches.clear();
  }

  @override
  Future<int?> getNearbyTravelersCount() async => _nearbyTravelersCount;

  @override
  Future<void> cacheNearbyTravelersCount(int count) async {
    _nearbyTravelersCount = count;
  }

  // ============================================================
  // ACTIVITIES
  // ============================================================

  @override
  Future<void> cacheActivities(List<ActivityModel> activities) async {
    _activities
      ..clear()
      ..addAll(activities);
  }

  @override
  Future<List<ActivityModel>> getActivities() async =>
      List.unmodifiable(_activities);

  @override
  Future<List<ActivityModel>> getUserActivities() async =>
      List.unmodifiable(_userActivities);

  @override
  Future<void> cacheUserActivities(List<ActivityModel> activities) async {
    _userActivities
      ..clear()
      ..addAll(activities);
  }

  @override
  Future<void> addUserActivity(String activityId) async {
    // Activity will be refreshed from server on next sync
  }

  @override
  Future<void> removeUserActivity(String activityId) async {
    _userActivities.removeWhere((a) => a.id == activityId);
  }

  @override
  Future<void> clearActivities() async {
    _activities.clear();
    _userActivities.clear();
  }

  // ============================================================
  // SYNC METADATA
  // ============================================================

  @override
  Future<DateTime?> getLastSyncTimestamp() async => _lastSyncTimestamp;

  @override
  Future<void> setLastSyncTimestamp(DateTime timestamp) async {
    _lastSyncTimestamp = timestamp;
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingChanges() async => [];

  @override
  Future<void> markChangeAsSynced(String changeId) async {}

  @override
  Future<void> clearPendingChanges() async {}

  @override
  Future<void> saveSyncQueue(List<Map<String, dynamic>> queue) async {}

  @override
  Future<List<Map<String, dynamic>>> getSyncQueue() async => [];

  // ============================================================
  // DATABASE MANAGEMENT
  // ============================================================

  @override
  Future<void> clearAllData() async {
    _trips.clear();
    _matches.clear();
    _activities.clear();
    _userActivities.clear();
    _lastSyncTimestamp = null;
    _nearbyTravelersCount = null;
  }

  @override
  Future<void> initializeDatabase() async {
  }

  @override
  Future<bool> isDatabaseHealthy() async => true;
}
