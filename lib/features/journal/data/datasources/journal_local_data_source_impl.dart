import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart'; // For SyncStatus enum
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:soloadventurer/core/errors/exceptions.dart' as app_exceptions;
import 'package:soloadventurer/features/journal/data/datasources/database_helper.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_local_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/journal_entry_model.dart';
import 'package:soloadventurer/features/journal/data/models/media_item_model.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart'; // For UploadStatus and MediaType

/// SQLite implementation of [JournalLocalDataSource]
class JournalLocalDataSourceImpl implements JournalLocalDataSource {
  final DatabaseHelper _databaseHelper;

  JournalLocalDataSourceImpl({
    required DatabaseHelper databaseHelper,
  }) : _databaseHelper = databaseHelper;

  // Journal Entry Operations

  @override
  Future<JournalEntryModel> createEntry(JournalEntryModel entry) async {
    try {
      final db = await _databaseHelper.database;

      await db.insert(
        DatabaseHelper.tableJournalEntries,
        _entryToMap(entry),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return entry;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to create journal entry: $e',
      );
    }
  }

  @override
  Future<JournalEntryModel> updateEntry(JournalEntryModel entry) async {
    try {
      final db = await _databaseHelper.database;

      final count = await db.update(
        DatabaseHelper.tableJournalEntries,
        _entryToMap(entry),
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [entry.id],
      );

      if (count == 0) {
        throw const app_exceptions.NotFoundException(
          message: 'Journal entry not found',
        );
      }

      return entry;
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to update journal entry: $e',
      );
    }
  }

  @override
  Future<JournalEntryModel?> getEntry(String entryId) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableJournalEntries,
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [entryId],
      );

      if (maps.isEmpty) return null;

      return _mapToEntry(maps.first);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get journal entry: $e',
      );
    }
  }

  @override
  Future<List<JournalEntryModel>> getEntries() async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableJournalEntries,
        orderBy: '${DatabaseHelper.colEntryDate} DESC',
      );

      return maps.map(_mapToEntry).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get journal entries: $e',
      );
    }
  }

  @override
  Future<List<JournalEntryModel>> getEntriesByTrip(String tripId) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableJournalEntries,
        where: '${DatabaseHelper.colTripId} = ?',
        whereArgs: [tripId],
        orderBy: '${DatabaseHelper.colEntryDate} DESC',
      );

      return maps.map(_mapToEntry).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get entries for trip: $e',
      );
    }
  }

  @override
  Future<List<JournalEntryModel>> getEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableJournalEntries,
        where:
            '${DatabaseHelper.colEntryDate} >= ? AND ${DatabaseHelper.colEntryDate} <= ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: '${DatabaseHelper.colEntryDate} DESC',
      );

      return maps.map(_mapToEntry).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get entries by date range: $e',
      );
    }
  }

  @override
  Future<List<JournalEntryModel>> searchEntries(String query) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableJournalEntries,
        where:
            '${DatabaseHelper.colTitle} LIKE ? OR ${DatabaseHelper.colContent} LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: '${DatabaseHelper.colEntryDate} DESC',
      );

      return maps.map(_mapToEntry).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to search entries: $e',
      );
    }
  }

  @override
  Future<List<JournalEntryModel>> getFavoriteEntries() async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableJournalEntries,
        where: '${DatabaseHelper.colIsFavorite} = ?',
        whereArgs: [1],
        orderBy: '${DatabaseHelper.colEntryDate} DESC',
      );

      return maps.map(_mapToEntry).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get favorite entries: $e',
      );
    }
  }

  @override
  Future<List<JournalEntryModel>> getEntriesWithLocation() async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableJournalEntries,
        where:
            '${DatabaseHelper.colLatitude} IS NOT NULL AND ${DatabaseHelper.colLongitude} IS NOT NULL',
        orderBy: '${DatabaseHelper.colEntryDate} DESC',
      );

      return maps.map(_mapToEntry).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get entries with location: $e',
      );
    }
  }

  @override
  Future<List<JournalEntryModel>> getEntriesNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final db = await _databaseHelper.database;

      // Simple bounding box query (for more accurate results, use Haversine formula)
      final latDelta = radiusKm / 111.0; // Approximate km per degree latitude
      final lonDelta = radiusKm / (111.0 * (latitude / 57.2958).abs().cos());

      final maps = await db.query(
        DatabaseHelper.tableJournalEntries,
        where:
            '${DatabaseHelper.colLatitude} BETWEEN ? AND ? AND ${DatabaseHelper.colLongitude} BETWEEN ? AND ?',
        whereArgs: [
          latitude - latDelta,
          latitude + latDelta,
          longitude - lonDelta,
          longitude + lonDelta,
        ],
        orderBy: '${DatabaseHelper.colEntryDate} DESC',
      );

      return maps.map(_mapToEntry).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get entries near location: $e',
      );
    }
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    try {
      final db = await _databaseHelper.database;

      await db.delete(
        DatabaseHelper.tableJournalEntries,
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [entryId],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to delete journal entry: $e',
      );
    }
  }

  @override
  Future<JournalEntryModel> toggleFavorite(String entryId) async {
    try {
      final entry = await getEntry(entryId);
      if (entry == null) {
        throw const app_exceptions.NotFoundException(
          message: 'Journal entry not found',
        );
      }

      final updatedEntry = entry.copyWith(
        isFavorite: !entry.isFavorite,
      );

      return await updateEntry(updatedEntry);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to toggle favorite: $e',
      );
    }
  }

  @override
  Future<List<JournalEntryModel>> getEntriesBySyncStatus(
      String syncStatus) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableJournalEntries,
        where: '${DatabaseHelper.colSyncStatus} = ?',
        whereArgs: [syncStatus],
        orderBy: '${DatabaseHelper.colEntryDate} DESC',
      );

      return maps.map(_mapToEntry).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get entries by sync status: $e',
      );
    }
  }

  @override
  Future<JournalEntryModel> updateSyncStatus(
    String entryId,
    String syncStatus,
  ) async {
    try {
      final entry = await getEntry(entryId);
      if (entry == null) {
        throw const app_exceptions.NotFoundException(
          message: 'Journal entry not found',
        );
      }

      final updatedEntry = entry.copyWith(
        syncStatus: SyncStatusExtension.fromString(syncStatus),
        lastSyncedAt: DateTime.now(),
      );

      return await updateEntry(updatedEntry);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to update sync status: $e',
      );
    }
  }

  // Media Operations

  @override
  Future<MediaItemModel> addMedia(MediaItemModel media) async {
    try {
      final db = await _databaseHelper.database;

      await db.insert(
        DatabaseHelper.tableMediaItems,
        _mediaToMap(media),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return media;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to add media: $e',
      );
    }
  }

  @override
  Future<MediaItemModel> updateMedia(MediaItemModel media) async {
    try {
      final db = await _databaseHelper.database;

      final count = await db.update(
        DatabaseHelper.tableMediaItems,
        _mediaToMap(media),
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [media.id],
      );

      if (count == 0) {
        throw const app_exceptions.NotFoundException(
          message: 'Media item not found',
        );
      }

      return media;
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to update media: $e',
      );
    }
  }

  @override
  Future<List<MediaItemModel>> getMediaForEntry(String entryId) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableMediaItems,
        where: '${DatabaseHelper.colJournalEntryId} = ?',
        whereArgs: [entryId],
        orderBy: '${DatabaseHelper.colOrderIndex} ASC',
      );

      return maps.map(_mapToMedia).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get media for entry: $e',
      );
    }
  }

  @override
  Future<void> deleteMedia(String mediaId) async {
    try {
      final db = await _databaseHelper.database;

      await db.delete(
        DatabaseHelper.tableMediaItems,
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [mediaId],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to delete media: $e',
      );
    }
  }

  @override
  Future<MediaItemModel> updateMediaUploadProgress(
    String mediaId,
    int progress,
  ) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableMediaItems,
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [mediaId],
      );

      if (maps.isEmpty) {
        throw const app_exceptions.NotFoundException(
          message: 'Media item not found',
        );
      }

      final media = _mapToMedia(maps.first);
      final updatedMedia = media.copyWith(
        uploadProgress: progress,
        uploadStatus:
            progress == 100 ? UploadStatus.completed : UploadStatus.uploading,
      );

      return await updateMedia(updatedMedia);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to update upload progress: $e',
      );
    }
  }

  @override
  Future<MediaItemModel> completeMediaUpload(
    String mediaId,
    String storagePath,
  ) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableMediaItems,
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [mediaId],
      );

      if (maps.isEmpty) {
        throw const app_exceptions.NotFoundException(
          message: 'Media item not found',
        );
      }

      final media = _mapToMedia(maps.first);
      final updatedMedia = media.copyWith(
        storagePath: storagePath,
        uploadStatus: UploadStatus.completed,
        uploadProgress: 100,
      );

      return await updateMedia(updatedMedia);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to complete upload: $e',
      );
    }
  }

  @override
  Future<MediaItemModel> failMediaUpload(
    String mediaId,
    String error,
  ) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableMediaItems,
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [mediaId],
      );

      if (maps.isEmpty) {
        throw const app_exceptions.NotFoundException(
          message: 'Media item not found',
        );
      }

      final media = _mapToMedia(maps.first);
      final updatedMedia = media.copyWith(
        uploadStatus: UploadStatus.failed,
      );

      return await updateMedia(updatedMedia);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to mark upload as failed: $e',
      );
    }
  }

  @override
  Future<List<MediaItemModel>> getMediaBySyncStatus(String syncStatus) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableMediaItems,
        where: '${DatabaseHelper.colSyncStatus} = ?',
        whereArgs: [syncStatus],
      );

      return maps.map(_mapToMedia).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get media by sync status: $e',
      );
    }
  }

  @override
  Future<MediaItemModel> updateMediaSyncStatus(
    String mediaId,
    String syncStatus,
  ) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        DatabaseHelper.tableMediaItems,
        where: '${DatabaseHelper.colId} = ?',
        whereArgs: [mediaId],
      );

      if (maps.isEmpty) {
        throw const app_exceptions.NotFoundException(
          message: 'Media item not found',
        );
      }

      final media = _mapToMedia(maps.first);
      final updatedMedia = media.copyWith(
        syncStatus: SyncStatusExtension.fromString(syncStatus),
        lastSyncedAt: DateTime.now(),
      );

      return await updateMedia(updatedMedia);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to update media sync status: $e',
      );
    }
  }

  // Tag Operations

  @override
  Future<List<String>> getTagsForEntry(String entryId) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.rawQuery('''
        SELECT ${DatabaseHelper.colTagId}
        FROM ${DatabaseHelper.tableEntryTags}
        WHERE ${DatabaseHelper.colJournalEntryId} = ?
      ''', [entryId]);

      return maps.map((map) => map[DatabaseHelper.colTagId] as String).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get tags for entry: $e',
      );
    }
  }

  @override
  Future<void> addTagToEntry(String entryId, String tagId) async {
    try {
      final db = await _databaseHelper.database;

      await db.insert(
        DatabaseHelper.tableEntryTags,
        {
          DatabaseHelper.colId:
              DateTime.now().millisecondsSinceEpoch.toString(),
          DatabaseHelper.colJournalEntryId: entryId,
          DatabaseHelper.colTagId: tagId,
          DatabaseHelper.colCreatedAt: DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to add tag to entry: $e',
      );
    }
  }

  @override
  Future<void> removeTagFromEntry(String entryId, String tagId) async {
    try {
      final db = await _databaseHelper.database;

      await db.delete(
        DatabaseHelper.tableEntryTags,
        where:
            '${DatabaseHelper.colJournalEntryId} = ? AND ${DatabaseHelper.colTagId} = ?',
        whereArgs: [entryId, tagId],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to remove tag from entry: $e',
      );
    }
  }

  @override
  Future<void> updateTagsForEntry(String entryId, List<String> tagIds) async {
    try {
      final db = await _databaseHelper.database;

      // Delete existing tags
      await db.delete(
        DatabaseHelper.tableEntryTags,
        where: '${DatabaseHelper.colJournalEntryId} = ?',
        whereArgs: [entryId],
      );

      // Add new tags
      final batch = db.batch();
      for (final tagId in tagIds) {
        batch.insert(
          DatabaseHelper.tableEntryTags,
          {
            DatabaseHelper.colId:
                DateTime.now().millisecondsSinceEpoch.toString() + tagId,
            DatabaseHelper.colJournalEntryId: entryId,
            DatabaseHelper.colTagId: tagId,
            DatabaseHelper.colCreatedAt: DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to update tags for entry: $e',
      );
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _databaseHelper.clearAllData();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to clear all data: $e',
      );
    }
  }

  // Helper Methods

  /// Converts a [JournalEntryModel] to a map for database storage
  Map<String, dynamic> _entryToMap(JournalEntryModel entry) {
    return {
      DatabaseHelper.colId: entry.id,
      DatabaseHelper.colUserId: entry.userId,
      DatabaseHelper.colTripId: entry.tripId,
      DatabaseHelper.colTitle: entry.title,
      DatabaseHelper.colContent: entry.content,
      DatabaseHelper.colMood: entry.mood,
      DatabaseHelper.colLocationName: entry.locationName,
      DatabaseHelper.colLatitude: entry.latitude,
      DatabaseHelper.colLongitude: entry.longitude,
      DatabaseHelper.colLocationAccuracy: entry.locationAccuracy,
      DatabaseHelper.colEntryDate: entry.entryDate.toIso8601String(),
      DatabaseHelper.colWeatherData:
          entry.weatherData != null ? jsonEncode(entry.weatherData) : null,
      DatabaseHelper.colIsFavorite: entry.isFavorite ? 1 : 0,
      DatabaseHelper.colSyncStatus: entry.syncStatus.value,
      DatabaseHelper.colLastSyncedAt: entry.lastSyncedAt?.toIso8601String(),
      DatabaseHelper.colCreatedAt: entry.createdAt.toIso8601String(),
      DatabaseHelper.colUpdatedAt: entry.updatedAt.toIso8601String(),
    };
  }

  /// Converts a database map to a [JournalEntryModel]
  JournalEntryModel _mapToEntry(Map<String, dynamic> map) {
    return JournalEntryModel(
      id: map[DatabaseHelper.colId] as String,
      userId: map[DatabaseHelper.colUserId] as String,
      tripId: map[DatabaseHelper.colTripId] as String?,
      title: map[DatabaseHelper.colTitle] as String,
      content: map[DatabaseHelper.colContent] as String,
      mood: map[DatabaseHelper.colMood] as String?,
      locationName: map[DatabaseHelper.colLocationName] as String?,
      latitude: (map[DatabaseHelper.colLatitude] as num?)?.toDouble(),
      longitude: (map[DatabaseHelper.colLongitude] as num?)?.toDouble(),
      locationAccuracy:
          (map[DatabaseHelper.colLocationAccuracy] as num?)?.toDouble(),
      entryDate: DateTime.parse(map[DatabaseHelper.colEntryDate] as String),
      weatherData: map[DatabaseHelper.colWeatherData] != null
          ? jsonDecode(map[DatabaseHelper.colWeatherData] as String)
          : null,
      isFavorite: (map[DatabaseHelper.colIsFavorite] as int) == 1,
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

  /// Converts a [MediaItemModel] to a map for database storage
  Map<String, dynamic> _mediaToMap(MediaItemModel media) {
    return {
      DatabaseHelper.colId: media.id,
      DatabaseHelper.colUserId: media.userId,
      DatabaseHelper.colJournalEntryId: media.journalEntryId,
      DatabaseHelper.colMediaType: media.mediaType.value,
      DatabaseHelper.colStoragePath: media.storagePath,
      DatabaseHelper.colOriginalFilename: media.originalFilename,
      DatabaseHelper.colFileSize: media.fileSize,
      DatabaseHelper.colMimeType: media.mimeType,
      DatabaseHelper.colWidth: media.width,
      DatabaseHelper.colHeight: media.height,
      DatabaseHelper.colDuration: media.duration,
      DatabaseHelper.colThumbnailPath: media.thumbnailPath,
      DatabaseHelper.colCaption: media.caption,
      DatabaseHelper.colUploadStatus: media.uploadStatus.value,
      DatabaseHelper.colUploadProgress: media.uploadProgress,
      DatabaseHelper.colExifData:
          media.exifData != null ? jsonEncode(media.exifData) : null,
      DatabaseHelper.colIsCover: media.isCover ? 1 : 0,
      DatabaseHelper.colOrderIndex: media.orderIndex,
      DatabaseHelper.colSyncStatus: media.syncStatus.value,
      DatabaseHelper.colLastSyncedAt: media.lastSyncedAt?.toIso8601String(),
      DatabaseHelper.colCreatedAt: media.createdAt.toIso8601String(),
      DatabaseHelper.colUpdatedAt: media.updatedAt.toIso8601String(),
    };
  }

  /// Converts a database map to a [MediaItemModel]
  MediaItemModel _mapToMedia(Map<String, dynamic> map) {
    return MediaItemModel(
      id: map[DatabaseHelper.colId] as String,
      userId: map[DatabaseHelper.colUserId] as String,
      journalEntryId: map[DatabaseHelper.colJournalEntryId] as String,
      mediaType: MediaTypeExtension.fromString(
        map[DatabaseHelper.colMediaType] as String,
      ),
      storagePath: map[DatabaseHelper.colStoragePath] as String,
      originalFilename: map[DatabaseHelper.colOriginalFilename] as String?,
      fileSize: map[DatabaseHelper.colFileSize] as int?,
      mimeType: map[DatabaseHelper.colMimeType] as String?,
      width: map[DatabaseHelper.colWidth] as int?,
      height: map[DatabaseHelper.colHeight] as int?,
      duration: map[DatabaseHelper.colDuration] as int?,
      thumbnailPath: map[DatabaseHelper.colThumbnailPath] as String?,
      caption: map[DatabaseHelper.colCaption] as String?,
      uploadStatus: UploadStatusExtension.fromString(
        map[DatabaseHelper.colUploadStatus] as String,
      ),
      uploadProgress: map[DatabaseHelper.colUploadProgress] as int,
      exifData: map[DatabaseHelper.colExifData] != null
          ? jsonDecode(map[DatabaseHelper.colExifData] as String)
          : null,
      isCover: (map[DatabaseHelper.colIsCover] as int) == 1,
      orderIndex: map[DatabaseHelper.colOrderIndex] as int,
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

/// Extension on double to calculate cosine
extension DoubleExtension on double {
  double cos() {
    return _cos(this);
  }
}

double _cos(double radians) {
  // Taylor series approximation for cosine
  double result = 1.0;
  double term = 1.0;
  for (int i = 1; i <= 10; i++) {
    term *= -radians * radians / ((2 * i - 1) * (2 * i));
    result += term;
  }
  return result;
}
