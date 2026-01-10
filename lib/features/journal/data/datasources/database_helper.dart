import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:soloadventurer/core/errors/exceptions.dart' as app_exceptions;

/// Helper class for managing SQLite database operations
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// Database name
  static const String _databaseName = 'soloadventurer_journal.db';

  /// Database version
  static const int _databaseVersion = 1;

  /// Table names
  static const String tableJournalEntries = 'journal_entries';
  static const String tableMediaItems = 'media_items';
  static const String tableTrips = 'trips';
  static const String tableTags = 'tags';
  static const String tableEntryTags = 'entry_tags'; // Junction table

  /// Column names for journal_entries table
  static const String colId = 'id';
  static const String colUserId = 'user_id';
  static const String colTripId = 'trip_id';
  static const String colTitle = 'title';
  static const String colContent = 'content';
  static const String colMood = 'mood';
  static const String colLocationName = 'location_name';
  static const String colLatitude = 'latitude';
  static const String colLongitude = 'longitude';
  static const String colLocationAccuracy = 'location_accuracy';
  static const String colEntryDate = 'entry_date';
  static const String colWeatherData = 'weather_data';
  static const String colIsFavorite = 'is_favorite';
  static const String colSyncStatus = 'sync_status';
  static const String colLastSyncedAt = 'last_synced_at';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  /// Column names for media_items table
  static const String colJournalEntryId = 'journal_entry_id';
  static const String colMediaType = 'media_type';
  static const String colStoragePath = 'storage_path';
  static const String colOriginalFilename = 'original_filename';
  static const String colFileSize = 'file_size';
  static const String colMimeType = 'mime_type';
  static const String colWidth = 'width';
  static const String colHeight = 'height';
  static const String colDuration = 'duration';
  static const String colThumbnailPath = 'thumbnail_path';
  static const String colCaption = 'caption';
  static const String colUploadStatus = 'upload_status';
  static const String colUploadProgress = 'upload_progress';
  static const String colExifData = 'exif_data';
  static const String colIsCover = 'is_cover';
  static const String colOrderIndex = 'order_index';

  /// Column names for trips table
  static const String colName = 'name';
  static const String colDescription = 'description';
  static const String colCoverImageUrl = 'cover_image_url';
  static const String colStartDate = 'start_date';
  static const String colEndDate = 'end_date';
  static const String colDestination = 'destination';
  static const String colIsPublic = 'is_public';

  /// Column names for tags table
  static const String colTagColor = 'color';
  static const String colTagIcon = 'icon';
  static const String colUsageCount = 'usage_count';

  /// Column names for entry_tags junction table
  static const String colTagId = 'tag_id';

  /// Returns the database instance, initializing it if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database and creates tables
  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _databaseName);

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw const DatabaseException(
        message: 'Failed to initialize database',
      );
    }
  }

  /// Creates all database tables
  Future<void> _onCreate(Database db, int version) async {
    try {
      // Create journal_entries table
      await db.execute('''
        CREATE TABLE $tableJournalEntries (
          $colId TEXT PRIMARY KEY,
          $colUserId TEXT NOT NULL,
          $colTripId TEXT,
          $colTitle TEXT NOT NULL,
          $colContent TEXT NOT NULL,
          $colMood TEXT,
          $colLocationName TEXT,
          $colLatitude REAL,
          $colLongitude REAL,
          $colLocationAccuracy REAL,
          $colEntryDate TEXT NOT NULL,
          $colWeatherData TEXT,
          $colIsFavorite INTEGER NOT NULL DEFAULT 0,
          $colSyncStatus TEXT NOT NULL DEFAULT 'synced',
          $colLastSyncedAt TEXT,
          $colCreatedAt TEXT NOT NULL,
          $colUpdatedAt TEXT NOT NULL
        )
      ''');

      // Create media_items table
      await db.execute('''
        CREATE TABLE $tableMediaItems (
          $colId TEXT PRIMARY KEY,
          $colUserId TEXT NOT NULL,
          $colJournalEntryId TEXT NOT NULL,
          $colMediaType TEXT NOT NULL,
          $colStoragePath TEXT NOT NULL,
          $colOriginalFilename TEXT,
          $colFileSize INTEGER,
          $colMimeType TEXT,
          $colWidth INTEGER,
          $colHeight INTEGER,
          $colDuration INTEGER,
          $colThumbnailPath TEXT,
          $colCaption TEXT,
          $colUploadStatus TEXT NOT NULL DEFAULT 'pending',
          $colUploadProgress INTEGER NOT NULL DEFAULT 0,
          $colExifData TEXT,
          $colIsCover INTEGER NOT NULL DEFAULT 0,
          $colOrderIndex INTEGER NOT NULL DEFAULT 0,
          $colSyncStatus TEXT NOT NULL DEFAULT 'synced',
          $colLastSyncedAt TEXT,
          $colCreatedAt TEXT NOT NULL,
          $colUpdatedAt TEXT NOT NULL,
          FOREIGN KEY ($colJournalEntryId) REFERENCES $tableJournalEntries ($colId) ON DELETE CASCADE
        )
      ''');

      // Create trips table
      await db.execute('''
        CREATE TABLE $tableTrips (
          $colId TEXT PRIMARY KEY,
          $colUserId TEXT NOT NULL,
          $colName TEXT NOT NULL,
          $colDescription TEXT,
          $colCoverImageUrl TEXT,
          $colStartDate TEXT NOT NULL,
          $colEndDate TEXT,
          $colDestination TEXT,
          $colIsPublic INTEGER NOT NULL DEFAULT 0,
          $colSyncStatus TEXT NOT NULL DEFAULT 'synced',
          $colLastSyncedAt TEXT,
          $colCreatedAt TEXT NOT NULL,
          $colUpdatedAt TEXT NOT NULL
        )
      ''');

      // Create tags table
      await db.execute('''
        CREATE TABLE $tableTags (
          $colId TEXT PRIMARY KEY,
          $colUserId TEXT NOT NULL,
          $colName TEXT NOT NULL,
          $colTagColor TEXT,
          $colTagIcon TEXT,
          $colUsageCount INTEGER NOT NULL DEFAULT 0,
          $colCreatedAt TEXT NOT NULL
        )
      ''');

      // Create entry_tags junction table
      await db.execute('''
        CREATE TABLE $tableEntryTags (
          $colId TEXT PRIMARY KEY,
          $colJournalEntryId TEXT NOT NULL,
          $colTagId TEXT NOT NULL,
          $colCreatedAt TEXT NOT NULL,
          FOREIGN KEY ($colJournalEntryId) REFERENCES $tableJournalEntries ($colId) ON DELETE CASCADE,
          FOREIGN KEY ($colTagId) REFERENCES $tableTags ($colId) ON DELETE CASCADE,
          UNIQUE($colJournalEntryId, $colTagId)
        )
      ''');

      // Create indexes for better query performance
      await _createIndexes(db);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to create database tables: $e',
      );
    }
  }

  /// Creates indexes for better query performance
  Future<void> _createIndexes(Database db) async {
    try {
      // Indexes for journal_entries
      await db.execute('''
        CREATE INDEX idx_journal_entries_user_id ON $tableJournalEntries($colUserId)
      ''');
      await db.execute('''
        CREATE INDEX idx_journal_entries_trip_id ON $tableJournalEntries($colTripId)
      ''');
      await db.execute('''
        CREATE INDEX idx_journal_entries_entry_date ON $tableJournalEntries($colEntryDate)
      ''');
      await db.execute('''
        CREATE INDEX idx_journal_entries_sync_status ON $tableJournalEntries($colSyncStatus)
      ''');

      // Indexes for media_items
      await db.execute('''
        CREATE INDEX idx_media_items_entry_id ON $tableMediaItems($colJournalEntryId)
      ''');
      await db.execute('''
        CREATE INDEX idx_media_items_user_id ON $tableMediaItems($colUserId)
      ''');

      // Indexes for trips
      await db.execute('''
        CREATE INDEX idx_trips_user_id ON $tableTrips($colUserId)
      ''');

      // Indexes for tags
      await db.execute('''
        CREATE INDEX idx_tags_user_id ON $tableTags($colUserId)
      ''');

      // Indexes for entry_tags
      await db.execute('''
        CREATE INDEX idx_entry_tags_entry_id ON $tableEntryTags($colJournalEntryId)
      ''');
      await db.execute('''
        CREATE INDEX idx_entry_tags_tag_id ON $tableEntryTags($colTagId)
      ''');
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to create database indexes: $e',
      );
    }
  }

  /// Handles database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations here
    if (oldVersion < 2) {
      // Example migration for version 2
      // await db.execute('ALTER TABLE ...');
    }
  }

  /// Closes the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Clears all data from all tables (useful for testing or logout)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete(tableEntryTags);
      await db.delete(tableMediaItems);
      await db.delete(tableJournalEntries);
      await db.delete(tableTags);
      await db.delete(tableTrips);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to clear database: $e',
      );
    }
  }

  /// Deletes the database file
  Future<void> deleteDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _databaseName);
      await databaseFactory.deleteDatabase(path);
      _database = null;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to delete database: $e',
      );
    }
  }
}
