import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart'; // For SyncStatus enum
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/journal/data/datasources/database_helper.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/trip_model.dart';
import 'package:soloadventurer/features/journal/domain/entities/trip.dart';

/// SQLite implementation of [TripLocalDataSource]
class TripLocalDataSourceImpl implements TripLocalDataSource {
  final DatabaseHelper _databaseHelper;

  TripLocalDataSourceImpl({
    required DatabaseHelper databaseHelper,
  }) : _databaseHelper = databaseHelper;

  @override
  Future<TripModel> createTrip(TripModel trip) async {
    try {
      final db = await _databaseHelper.database;

      await db.insert(
        DatabaseHelper.tableTrips,
        _tripToMap(trip),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return trip;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to create trip: $e',
      );
    }
  }

  @override
  Future<TripModel> updateTrip(TripModel trip) async {
    try {
      final db = await _databaseHelper.database;

      final count = await db.update(
        DatabaseHelper.tableTrips,
        _tripToMap(trip),
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [trip.id],
      );

      if (count == 0) {
        throw const NotFoundException(
          message: 'Trip not found',
        );
      }

      return trip;
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update trip: $e',
      );
    }
  }

  @override
  Future<TripModel?> getTrip(String tripId) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableTrips,
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [tripId],
      );

      if (maps.isEmpty) return null;

      return _mapToTrip(maps.first);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get trip: $e',
      );
    }
  }

  @override
  Future<List<TripModel>> getTrips() async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableTrips,
        orderBy: '${DatabaseHelper.colStartDate} DESC',
      );

      return maps.map(_mapToTrip).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get trips: $e',
      );
    }
  }

  @override
  Future<List<TripModel>> getTripsBySyncStatus(String syncStatus) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableTrips,
        where: '${DatabaseHelper.colSyncStatus} = ?',
        whereArgs: [syncStatus],
        orderBy: '${DatabaseHelper.colStartDate} DESC',
      );

      return maps.map(_mapToTrip).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get trips by sync status: $e',
      );
    }
  }

  @override
  Future<TripModel> updateSyncStatus(String tripId, String syncStatus) async {
    try {
      final trip = await getTrip(tripId);
      if (trip == null) {
        throw const NotFoundException(
          message: 'Trip not found',
        );
      }

      final updatedTrip = trip.copyWith(
        syncStatus: SyncStatusExtension.fromString(syncStatus),
        lastSyncedAt: DateTime.now(),
      );

      return await updateTrip(updatedTrip);
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update sync status: $e',
      );
    }
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    try {
      final db = await _databaseHelper.database;

      await db.delete(
        DatabaseHelper.tableTrips,
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [tripId],
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete trip: $e',
      );
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(DatabaseHelper.tableTrips);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to clear all trips: $e',
      );
    }
  }

  /// Converts a [TripModel] to a map for database storage
  Map<String, dynamic> _tripToMap(TripModel trip) {
    return {
      DatabaseHelper.colId: trip.id,
      DatabaseHelper.colUserId: trip.userId,
      DatabaseHelper.colName: trip.name,
      DatabaseHelper.colDescription: trip.description,
      DatabaseHelper.colCoverImageUrl: trip.coverImageUrl,
      DatabaseHelper.colStartDate: trip.startDate.toIso8601String(),
      DatabaseHelper.colEndDate: trip.endDate?.toIso8601String(),
      DatabaseHelper.colDestination: trip.destination,
      DatabaseHelper.colIsPublic: trip.isPublic ? 1 : 0,
      DatabaseHelper.colSyncStatus: trip.syncStatus.value,
      DatabaseHelper.colLastSyncedAt: trip.lastSyncedAt?.toIso8601String(),
      DatabaseHelper.colCreatedAt: trip.createdAt.toIso8601String(),
      DatabaseHelper.colUpdatedAt: trip.updatedAt.toIso8601String(),
    };
  }

  /// Converts a database map to a [TripModel]
  TripModel _mapToTrip(Map<String, dynamic> map) {
    return TripModel(
      id: map[DatabaseHelper.colId] as String,
      userId: map[DatabaseHelper.colUserId] as String,
      name: map[DatabaseHelper.colName] as String,
      description: map[DatabaseHelper.colDescription] as String?,
      coverImageUrl: map[DatabaseHelper.colCoverImageUrl] as String?,
      startDate: DateTime.parse(map[DatabaseHelper.colStartDate] as String),
      endDate: map[DatabaseHelper.colEndDate] != null
          ? DateTime.parse(map[DatabaseHelper.colEndDate] as String)
          : null,
      destination: map[DatabaseHelper.colDestination] as String?,
      isPublic: (map[DatabaseHelper.colIsPublic] as int) == 1,
      syncStatus: SyncStatusExtension.fromString(
        map[DatabaseHelper.colSyncStatus] as String,
      ),
      lastSyncedAt: map[DatabaseHelper.colLastSyncedAt] != null
          ? DateTime.parse(map[DatabaseHelper.colLastSyncedAt] as String)
          : null,
      createdAt: DateTime.parse(map[DatabaseHelper.colCreatedAt] as String),
      updatedAt: DateTime.parse(map[DatabaseHelper.colUpdatedAt] as String),
    );
  }
}
