import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'schema.dart';

/// Part file for Drift database generated code
part 'database.g.dart';

/// AppDatabase - Main Drift database for offline-first architecture
///
/// This database manages all local data storage for the SoloAdventurer app,
/// including trips, journals, users, and synchronization queue.
///
/// The database follows these principles:
/// - **Type Safety**: Uses Drift's compile-time checked queries
/// - **Offline-First**: All data is stored locally and synced with the server
/// - **Sync Tracking**: Every data table includes fields for sync state
/// - **Conflict Resolution**: Version tracking enables conflict detection
///
/// **Database Version**: 1
/// **Tables**: Trips, Journals, Users, SyncQueue, SyncMetadata
///
/// Example usage:
/// ```dart
/// final db = AppDatabase();
/// final trips = await db.getAllTrips();
/// await db.insertTrip(trip);
/// ```
@DriftDatabase(tables: [
  Trips,
  Journals,
  Users,
  SyncQueue,
  SyncMetadataTable,
])
class AppDatabase extends _$AppDatabase {
  /// Current database schema version
  ///
  /// Increment this value when making breaking changes to the schema.
  /// Migration logic will be required to upgrade from older versions.
  static const int schemaVersion = 1;

  /// Database filename
  static const String _dbName = 'soloadventurer.db';

  /// Creates a new AppDatabase instance
  ///
  /// The [executor] parameter is optional and primarily used for testing.
  /// In production, the database is stored in the app's documents directory.
  AppDatabase({QueryExecutor? executor})
      : super(executor ?? _openDatabase());

  /// Opens the database in the app's documents directory
  ///
  /// This method:
  /// 1. Gets the app's documents directory
  /// 2. Creates the database file path
  /// 3. Creates a NativeQueryExecutor with the database file
  ///
  /// Returns a [QueryExecutor] configured for the app database.
  static QueryExecutor _openDatabase() {
    return LazyDatabase(() async {
      final dbDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbDir.path, _dbName);

      // Log database path for debugging (remove in production)
      // debugPrint('Database path: $dbPath');

      return NativeDatabase.createInBackground(
        File(dbPath),
        logStatements: true, // Enable SQL logging in debug mode
      );
    });
  }

  /// Database schema version
  ///
  /// This must match the @DriftDatabase annotation version.
  @override
  int get schemaVersion => schemaVersion;

  /// Migration strategy for database schema changes
  ///
  /// This method is called when the database version on disk
  /// differs from [schemaVersion]. Use this to handle schema migrations.
  ///
  /// Example:
  /// ```dart
  /// if (fromVersion == 1 && toVersion == 2) {
  ///   // Add new column
  ///   migration(createTable(tableName)..
  ///       addColumn(columnName));
  /// }
  /// ```
  ///
  /// **Current Status**: No migrations yet (version 1)
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        // Create all tables when database is first created
        // Drift automatically creates tables based on the @DriftDatabase annotation
        // This callback is optional but can be used for custom initialization
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle schema migrations when upgrading between versions
        // This will be implemented when schemaVersion > 1

        // Example migration patterns (for future reference):
        // if (from == 1 && to == 2) {
        //   // Add a new column to Trips table
        //   m.addColumn(trips, trips.newColumn);
        // }
        //
        // if (from == 2 && to == 3) {
        //   // Create a new table
        //   m.createTable(newTable);
        // }
      },
      beforeOpen: (OpeningDetails details) async {
        // Custom logic before database is opened
        // Useful for data validation, custom indexes, etc.

        // Example: Enable foreign key constraints (optional)
        // await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ==============================================================================
  // CONVENIENCE METHODS
  // ==============================================================================

  /// Clears all data from all tables
  ///
  /// **WARNING**: This is a destructive operation and cannot be undone.
  /// Primarily used for testing or user-initiated data clearing.
  ///
  /// Returns a [Future] that completes when all tables are cleared.
  Future<void> clearAllTables() async {
    // Delete in correct order to respect foreign key constraints
    // (Child tables first, then parent tables)
    await delete(syncQueue).go();
    await delete(syncMetadataTable).go();
    await delete(journals).go();
    await delete(trips).go();
    await delete(users).go();
  }

  /// Gets database file information for debugging
  ///
  /// Returns a map containing:
  /// - 'path': Full path to the database file
  /// - 'size': File size in bytes
  /// - 'exists': Whether the file exists
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final dbDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbDir.path, _dbName);
      final dbFile = File(dbPath);

      return {
        'path': dbPath,
        'size': dbFile.existsSync() ? await dbFile.length() : 0,
        'exists': dbFile.existsSync(),
      };
    } catch (e) {
      return {
        'path': 'unknown',
        'size': 0,
        'exists': false,
        'error': e.toString(),
      };
    }
  }

  /// Deletes the database file
  ///
  /// **WARNING**: This is a destructive operation and cannot be undone.
  /// The database will be recreated on next app launch.
  ///
  /// Returns a [Future] that completes when the database is deleted.
  Future<void> deleteDatabaseFile() async {
    try {
      final dbDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbDir.path, _dbName);
      final dbFile = File(dbPath);

      if (await dbFile.exists()) {
        await dbFile.delete();
      }
    } catch (e) {
      // Ignore errors during deletion
      // File might not exist or permissions might prevent deletion
    }
  }
}
