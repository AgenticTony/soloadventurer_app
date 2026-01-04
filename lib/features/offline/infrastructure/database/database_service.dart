import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';

/// Service for initializing and managing the database lifecycle
///
/// This service provides:
/// - Lazy initialization of the database
/// - Error recovery from corrupted databases
/// - Lifecycle management (initialize, close, reset)
/// - Database health checks
/// - Migration support
///
/// Example usage:
/// ```dart
/// final dbService = DatabaseService();
/// await dbService.initialize();
/// final db = dbService.database;
/// ```
class DatabaseService {
  AppDatabase? _database;
  bool _isInitialized = false;
  bool _isInitializing = false;

  /// Gets the database instance
  ///
  /// Throws [StateError] if the database has not been initialized.
  /// Call [initialize()] before accessing the database.
  AppDatabase get database {
    if (_database == null) {
      throw StateError(
        'Database is not initialized. Call initialize() first.',
      );
    }
    return _database!;
  }

  /// Checks if the database has been initialized
  bool get isInitialized => _isInitialized;

  /// Checks if the database is currently being initialized
  bool get isInitializing => _isInitializing;

  /// Initializes the database
  ///
  /// This method:
  /// 1. Creates the database file in the app's documents directory
  /// 2. Runs any necessary migrations
  /// 3. Verifies database integrity
  /// 4. Recovers from corrupted databases if needed
  ///
  /// Returns [true] if initialization was successful, [false] otherwise.
  ///
  /// Throws [Exception] if initialization fails after recovery attempts.
  Future<bool> initialize() async {
    // Prevent concurrent initialization
    if (_isInitializing) {
      debugPrint('Database initialization already in progress');
      return false;
    }

    if (_isInitialized && _database != null) {
      debugPrint('Database already initialized');
      return true;
    }

    _isInitializing = true;

    try {
      debugPrint('Initializing database...');

      // Try to create/open the database
      _database = await _tryCreateDatabase();

      // Verify database integrity
      final isValid = await _validateDatabase();
      if (!isValid) {
        debugPrint('Database validation failed, attempting recovery...');
        await _recoverFromCorruption();
        _database = await _tryCreateDatabase();
      }

      _isInitialized = true;
      _isInitializing = false;
      debugPrint('Database initialized successfully');
      return true;
    } catch (e, stackTrace) {
      _isInitializing = false;
      _isInitialized = false;
      _database = null;

      debugPrint('Database initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');

      // Try to recover from corruption
      try {
        debugPrint('Attempting database recovery...');
        await _recoverFromCorruption();
        _database = await _tryCreateDatabase();
        _isInitialized = true;
        debugPrint('Database recovery successful');
        return true;
      } catch (recoveryError) {
        debugPrint('Database recovery failed: $recoveryError');
        rethrow;
      }
    }
  }

  /// Closes the database connection
  ///
  /// This should be called when the app is shutting down or when
  /// the database needs to be closed for migration purposes.
  Future<void> close() async {
    if (_database != null) {
      debugPrint('Closing database...');
      await _database!.close();
      _database = null;
      _isInitialized = false;
      debugPrint('Database closed');
    }
  }

  /// Resets the database by deleting all data
  ///
  /// **WARNING**: This is a destructive operation and cannot be undone.
  /// This is primarily used for testing or user-initiated data clearing.
  ///
  /// Returns [true] if the reset was successful, [false] otherwise.
  Future<bool> reset() async {
    try {
      debugPrint('Resetting database...');

      if (_database != null) {
        await _database!.clearAllTables();
        debugPrint('Database reset complete');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Database reset failed: $e');
      return false;
    }
  }

  /// Deletes the database file completely
  ///
  /// **WARNING**: This is a destructive operation and cannot be undone.
  /// The database will be recreated on next initialization.
  ///
  /// Returns [true] if the deletion was successful, [false] otherwise.
  Future<bool> delete() async {
    try {
      debugPrint('Deleting database file...');

      // Close the database first
      await close();

      // Delete the database file
      await AppDatabase.deleteDatabaseFile();

      debugPrint('Database file deleted');
      return true;
    } catch (e) {
      debugPrint('Database deletion failed: $e');
      return false;
    }
  }

  /// Gets database information for debugging
  ///
  /// Returns a map containing:
  /// - 'path': Full path to the database file
  /// - 'size': File size in bytes
  /// - 'exists': Whether the file exists
  /// - 'isInitialized': Whether the database service is initialized
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final info = await AppDatabase.getDatabaseInfoStatic();
    return {
      ...info,
      'isInitialized': _isInitialized,
      'isInitializing': _isInitializing,
    };
  }

  /// Validates database integrity
  ///
  /// Returns [true] if the database is valid, [false] otherwise.
  Future<bool> _validateDatabase() async {
    if (_database == null) return false;

    try {
      // Try to execute a simple query to verify the database is working
      await _database!.customSelect('SELECT COUNT(*) FROM sqlite_master').get();
      return true;
    } catch (e) {
      debugPrint('Database validation failed: $e');
      return false;
    }
  }

  /// Attempts to create a database instance
  ///
  /// Returns the [AppDatabase] instance if successful.
  /// Throws [Exception] if creation fails.
  Future<AppDatabase> _tryCreateDatabase() async {
    try {
      return AppDatabase();
    } catch (e) {
      debugPrint('Failed to create database: $e');
      rethrow;
    }
  }

  /// Recovers from a corrupted database
  ///
  /// This method:
  /// 1. Backs up the corrupted database (if possible)
  /// 2. Deletes the corrupted database file
  /// 3. Prepares for a fresh database creation
  ///
  /// Throws [Exception] if recovery fails.
  Future<void> _recoverFromCorruption() async {
    try {
      debugPrint('Starting database recovery...');

      // Try to backup the corrupted database
      await _backupCorruptedDatabase();

      // Delete the corrupted database
      await delete();

      debugPrint('Database recovery complete');
    } catch (e) {
      debugPrint('Database recovery error: $e');
      rethrow;
    }
  }

  /// Backs up a corrupted database for debugging purposes
  ///
  /// The backup file will be named with a timestamp to prevent overwriting
  /// previous backups.
  Future<void> _backupCorruptedDatabase() async {
    try {
      final dbDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbDir.path, AppDatabase.dbNameStatic);
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        debugPrint('No database file to backup');
        return;
      }

      // Create backup filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = p.join(dbDir.path, 'soloadventurer_backup_$timestamp.db');

      // Copy the database file
      await dbFile.copy(backupPath);
      debugPrint('Corrupted database backed up to: $backupPath');
    } catch (e) {
      debugPrint('Failed to backup corrupted database: $e');
      // Don't throw - backup failure shouldn't prevent recovery
    }
  }

  /// Performs a health check on the database
  ///
  /// Returns [true] if the database is healthy, [false] otherwise.
  Future<bool> healthCheck() async {
    if (!_isInitialized || _database == null) {
      return false;
    }

    try {
      // Try to query each table to verify integrity
      final tables = [
        'trips',
        'journals',
        'users',
        'sync_queue',
        'sync_metadata',
      ];

      for (final table in tables) {
        await _database!.customSelect(
          'SELECT COUNT(*) FROM $table',
        ).get();
      }

      return true;
    } catch (e) {
      debugPrint('Database health check failed: $e');
      return false;
    }
  }

  /// Gets the database size in bytes
  ///
  /// Returns the size of the database file, or 0 if the database
  /// doesn't exist or an error occurs.
  Future<int> getDatabaseSize() async {
    try {
      final info = await getDatabaseInfo();
      return info['size'] as int? ?? 0;
    } catch (e) {
      debugPrint('Failed to get database size: $e');
      return 0;
    }
  }
}

/// Extension to add static methods to AppDatabase
extension AppDatabaseExtension on AppDatabase {
  /// Gets database file information without an instance
  static Future<Map<String, dynamic>> getDatabaseInfoStatic() async {
    try {
      final dbDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbDir.path, AppDatabase.dbNameStatic);
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

  /// Deletes the database file without an instance
  static Future<void> deleteDatabaseFile() async {
    try {
      final dbDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbDir.path, AppDatabase.dbNameStatic);
      final dbFile = File(dbPath);

      if (await dbFile.exists()) {
        await dbFile.delete();
      }
    } catch (e) {
      // Ignore errors during deletion
    }
  }

  /// Gets the database name
  static String get dbNameStatic => AppDatabase.dbName;
}
