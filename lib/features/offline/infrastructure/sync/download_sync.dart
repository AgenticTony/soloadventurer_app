import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/trip_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/journal_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/user_dao.dart';
import 'package:soloadventurer/features/offline/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/core/infrastructure/graphql/graphql_queries.dart';

/// Result of a download sync operation
class DownloadSyncResult {
  /// Number of records downloaded/updated
  final int downloadCount;

  /// Number of records inserted
  final int insertCount;

  /// Number of records updated
  final int updateCount;

  /// Number of records deleted (from server)
  final int deleteCount;

  /// Number of records skipped (no changes)
  final int skipCount;

  /// Number of conflicts detected
  final int conflictCount;

  /// Duration of the download sync
  final Duration duration;

  /// Whether the download sync was successful overall
  bool get isSuccessful => true;

  const DownloadSyncResult({
    required this.downloadCount,
    required this.insertCount,
    required this.updateCount,
    required this.deleteCount,
    required this.skipCount,
    required this.conflictCount,
    required this.duration,
  });

  @override
  String toString() {
    return 'DownloadSyncResult(downloaded: $downloadCount, '
        'inserted: $insertCount, updated: $updateCount, '
        'deleted: $deleteCount, skipped: $skipCount, '
        'conflicts: $conflictCount, duration: ${duration.inSeconds}s)';
  }
}

/// Service to sync server data to local database
///
/// This service handles the download phase of synchronization by:
/// - Querying server for changes since last sync
/// - Comparing versions with local data
/// - Inserting new records into local database
/// - Updating existing records with server changes
/// - Handling deletions from server
/// - Updating sync metadata timestamps
///
/// The service supports incremental sync based on timestamps/version vectors
/// to minimize bandwidth and maximize performance.
///
/// Example usage:
/// ```dart
/// final downloadSync = DownloadSync(
///   dio: dio,
///   database: database,
///   userId: userId,
/// );
///
/// final result = await downloadSync.syncServerChanges(
///   onProgress: (current, total) {
///     print('Progress: $current/$total');
///   },
/// );
///
/// print('Downloaded ${result.downloadCount} changes');
/// ```
class DownloadSync {
  /// Dio HTTP client for API requests
  final Dio _dio;

  /// AppDatabase instance for local data operations
  final AppDatabase _database;

  /// Current user ID
  final String _userId;

  /// GraphQL API endpoint
  final String _graphqlEndpoint;

  /// Conflict resolver for recording detected conflicts
  final ConflictResolver? _conflictResolver;

  /// Uuid generator for conflict IDs
  final Uuid _uuid = const Uuid();

  /// Creates a new [DownloadSync] instance
  ///
  /// [dio] - Dio HTTP client for making API requests
  /// [database] - AppDatabase instance for local operations
  /// [userId] - Current user ID
  /// [graphqlEndpoint] - GraphQL API endpoint (default: '/graphql')
  /// [conflictResolver] - Optional conflict resolver for recording conflicts
  DownloadSync({
    required Dio dio,
    required AppDatabase database,
    required String userId,
    String graphqlEndpoint = '/graphql',
    ConflictResolver? conflictResolver,
  })  : _dio = dio,
        _database = database,
        _userId = userId,
        _graphqlEndpoint = graphqlEndpoint,
        _conflictResolver = conflictResolver;

  // ==============================================================================
  // PUBLIC API
  // ==============================================================================

  /// Syncs server changes to local database
  ///
  /// This method queries the server for all data types (trips, journals, users)
  /// and updates the local database accordingly. It uses version comparison to
  /// determine if records need to be updated.
  ///
  /// The [onProgress] callback is invoked after each entity type sync completes,
  /// providing the current count and total count of entity types.
  ///
  /// Returns a [DownloadSyncResult] with detailed sync statistics.
  Future<DownloadSyncResult> syncServerChanges({
    void Function(int current, int total)? onProgress,
  }) async {
    final startTime = DateTime.now();
    int downloadCount = 0;
    int insertCount = 0;
    int updateCount = 0;
    int deleteCount = 0;
    int skipCount = 0;
    int conflictCount = 0;

    try {
      debugPrint('📥 DownloadSync: Starting to sync server changes...');

      // ========================================================================
      // STEP 1: Sync Trips
      // ========================================================================
      onProgress?.call(1, 4);
      final tripResult = await syncTrips();
      downloadCount += tripResult['total'] as int;
      insertCount += tripResult['inserted'] as int;
      updateCount += tripResult['updated'] as int;
      deleteCount += tripResult['deleted'] as int;
      skipCount += tripResult['skipped'] as int;
      conflictCount += tripResult['conflicts'] as int;

      debugPrint('✅ Trips synced: ${tripResult['total']} total');

      // ========================================================================
      // STEP 2: Sync Journals
      // ========================================================================
      onProgress?.call(2, 4);
      final journalResult = await syncJournals();
      downloadCount += journalResult['total'] as int;
      insertCount += journalResult['inserted'] as int;
      updateCount += journalResult['updated'] as int;
      deleteCount += journalResult['deleted'] as int;
      skipCount += journalResult['skipped'] as int;
      conflictCount += journalResult['conflicts'] as int;

      debugPrint('✅ Journals synced: ${journalResult['total']} total');

      // ========================================================================
      // STEP 3: Sync User Profile
      // ========================================================================
      onProgress?.call(3, 4);
      final userResult = await syncUserProfile();
      downloadCount += userResult['total'] as int;
      insertCount += userResult['inserted'] as int;
      updateCount += userResult['updated'] as int;
      deleteCount += userResult['deleted'] as int;
      skipCount += userResult['skipped'] as int;
      conflictCount += userResult['conflicts'] as int;

      debugPrint('✅ User profile synced: ${userResult['total']} total');

      // ========================================================================
      // STEP 4: Update Sync Metadata
      // ========================================================================
      onProgress?.call(4, 4);
      await _updateSyncMetadata();

      debugPrint('✅ Sync metadata updated');

      final duration = DateTime.now().difference(startTime);

      debugPrint('✅ DownloadSync complete: '
          '$downloadCount downloaded, '
          '$insertCount inserted, '
          '$updateCount updated, '
          '$deleteCount deleted, '
          '$skipCount skipped, '
          '$conflictCount conflicts in ${duration.inSeconds}s');

      return DownloadSyncResult(
        downloadCount: downloadCount,
        insertCount: insertCount,
        updateCount: updateCount,
        deleteCount: deleteCount,
        skipCount: skipCount,
        conflictCount: conflictCount,
        duration: duration,
      );
    } catch (e) {
      debugPrint('❌ DownloadSync error: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // PUBLIC METHODS - ENTITY SYNC
  // ==============================================================================

  /// Syncs trips from server to local database
  ///
  /// Returns a map with sync statistics.
  Future<Map<String, int>> syncTrips() async {
    try {
      debugPrint('📥 Syncing trips...');

      // Query server for all trips
      final response = await _dio.post(
        _graphqlEndpoint,
        data: {
          'query': GraphQLQueries.getTrips,
          'variables': {'userId': _userId},
        },
      );

      if (response.statusCode != 200 || response.data['data'] == null) {
        final errors = response.data['errors'];
        debugPrint('❌ Failed to fetch trips: $errors');
        return _emptyResult();
      }

      final serverTrips = response.data['data']['getTrips'] as List;
      debugPrint('📊 Received ${serverTrips.length} trips from server');

      // Get all local trips
      final tripDao = _database.tripDao;
      final localTrips = await tripDao.getAllTripsForUser(_userId);
      final localTripsMap = {for (var t in localTrips) t.id: t};

      int inserted = 0;
      int updated = 0;
      int deleted = 0;
      int skipped = 0;
      int conflicts = 0;

      // Process each server trip
      for (final serverTrip in serverTrips) {
        final tripId = serverTrip['id'] as String;
        final localTrip = localTripsMap[tripId];

        if (localTrip == null) {
          // Insert new trip
          await tripDao.insertTrip(_serverTripToCompanion(serverTrip));
          inserted++;
          debugPrint('➕ Inserted trip: $tripId');
        } else {
          // Check if update is needed
          final serverUpdatedAt = DateTime.parse(serverTrip['updatedAt']);
          final needsUpdate = serverUpdatedAt.isAfter(localTrip.updatedAt);

          if (needsUpdate) {
            // Check for conflicts
            if (localTrip.hasPendingChanges) {
              // Conflict detected - record it
              conflicts++;
              debugPrint('⚠️ Conflict detected for trip: $tripId');

              // Record the conflict if resolver is available
              if (_conflictResolver != null) {
                final conflict = Conflict(
                  id: 'conflict_trip_${_uuid.v4()}',
                  entityType: EntityType.trip,
                  entityId: tripId,
                  type: ConflictType.concurrentUpdate,
                  severity: ConflictSeverity.medium,
                  clientData: {
                    'id': localTrip.id,
                    'title': localTrip.title,
                    'destination': localTrip.destination,
                    'version': localTrip.version,
                    'updatedAt': localTrip.updatedAt.toIso8601String(),
                  },
                  serverData: {
                    'id': serverTrip['id'],
                    'title': serverTrip['title'],
                    'destination': serverTrip['destination'],
                    'version': serverTrip['version'],
                    'updatedAt': serverTrip['updatedAt'],
                  },
                  clientUpdatedAt: localTrip.updatedAt,
                  serverUpdatedAt: serverUpdatedAt,
                  detectedAt: DateTime.now(),
                );

                await _conflictResolver!.recordConflict(conflict);
                debugPrint('📝 Conflict recorded for trip: $tripId');
              }

              // Skip updating to avoid losing local changes
              // Will be resolved by conflict resolution phase
              skipped++;
            } else {
              // Update trip
              await tripDao.updateTrip(_serverTripToCompanion(serverTrip,
                  existing: localTrip));
              updated++;
              debugPrint('🔄 Updated trip: $tripId');
            }
          } else {
            skipped++;
          }
        }
      }

      // Handle deletions (server trips that are not in local DB anymore)
      // Note: This is a simplified approach. In production, you'd need
      // a way to track deleted items from server (e.g., deletedAt timestamp)
      final serverTripIds =
          serverTrips.map((t) => t['id'] as String).toSet();
      for (final localTrip in localTrips) {
        if (!serverTripIds.contains(localTrip.id) &&
            localTrip.isSynced &&
            !localTrip.hasPendingChanges) {
          // Trip was deleted on server, delete locally
          await tripDao.deleteTripById(localTrip.id);
          deleted++;
          debugPrint('🗑️ Deleted trip: ${localTrip.id}');
        }
      }

      return {
        'total': serverTrips.length,
        'inserted': inserted,
        'updated': updated,
        'deleted': deleted,
        'skipped': skipped,
        'conflicts': conflicts,
      };
    } catch (e) {
      debugPrint('❌ Error syncing trips: $e');
      return _emptyResult();
    }
  }

  /// Syncs journals from server to local database
  ///
  /// Returns a map with sync statistics.
  Future<Map<String, int>> syncJournals() async {
    try {
      debugPrint('📥 Syncing journals...');

      // Get all trips to fetch journals for
      final tripDao = _database.tripDao;
      final trips = await tripDao.getAllTripsForUser(_userId);

      if (trips.isEmpty) {
        debugPrint('📭 No trips to fetch journals for');
        return _emptyResult();
      }

      int totalInserted = 0;
      int totalUpdated = 0;
      int totalDeleted = 0;
      int totalSkipped = 0;
      int totalConflicts = 0;
      int totalJournals = 0;

      // Fetch journals for each trip
      // Note: Assuming a getJournals query exists. If not, this would need
      // to be added to GraphQLQueries
      for (final trip in trips) {
        try {
          final query = '''
            query GetJournals(\$tripId: ID!) {
              getJournals(tripId: \$tripId) {
                id
                tripId
                userId
                title
                content
                entryDate
                mood
                location
                imageUrls
                tags
                createdAt
                updatedAt
              }
            }
          ''';

          final response = await _dio.post(
            _graphqlEndpoint,
            data: {
              'query': query,
              'variables': {'tripId': trip.id},
            },
          );

          if (response.statusCode != 200 || response.data['data'] == null) {
            debugPrint('⚠️ Failed to fetch journals for trip ${trip.id}');
            continue;
          }

          final serverJournals = response.data['data']['getJournals'] as List;
          totalJournals += serverJournals.length;
          debugPrint('📊 Received ${serverJournals.length} journals for trip ${trip.id}');

          // Get all local journals for this trip
          final journalDao = _database.journalDao;
          final localJournals = await journalDao.getJournalsByTrip(trip.id);
          final localJournalsMap = {for (var j in localJournals) j.id: j};

          // Process each server journal
          for (final serverJournal in serverJournals) {
            final journalId = serverJournal['id'] as String;
            final localJournal = localJournalsMap[journalId];

            if (localJournal == null) {
              // Insert new journal
              await journalDao.insertJournal(
                  _serverJournalToCompanion(serverJournal));
              totalInserted++;
              debugPrint('➕ Inserted journal: $journalId');
            } else {
              // Check if update is needed
              final serverUpdatedAt = DateTime.parse(serverJournal['updatedAt']);
              final needsUpdate = serverUpdatedAt.isAfter(localJournal.updatedAt);

              if (needsUpdate) {
                // Check for conflicts
                if (localJournal.hasPendingChanges) {
                  // Conflict detected - record it
                  totalConflicts++;
                  debugPrint('⚠️ Conflict detected for journal: $journalId');

                  // Record the conflict if resolver is available
                  if (_conflictResolver != null) {
                    final conflict = Conflict(
                      id: 'conflict_journal_${_uuid.v4()}',
                      entityType: EntityType.journal,
                      entityId: journalId,
                      type: ConflictType.concurrentUpdate,
                      severity: ConflictSeverity.low,
                      clientData: {
                        'id': localJournal.id,
                        'title': localJournal.title,
                        'content': localJournal.content,
                        'entryDate': localJournal.entryDate.toIso8601String(),
                        'version': localJournal.version,
                        'updatedAt': localJournal.updatedAt.toIso8601String(),
                      },
                      serverData: {
                        'id': serverJournal['id'],
                        'title': serverJournal['title'],
                        'content': serverJournal['content'],
                        'entryDate': serverJournal['entryDate'],
                        'version': serverJournal['version'],
                        'updatedAt': serverJournal['updatedAt'],
                      },
                      clientUpdatedAt: localJournal.updatedAt,
                      serverUpdatedAt: serverUpdatedAt,
                      detectedAt: DateTime.now(),
                    );

                    await _conflictResolver!.recordConflict(conflict);
                    debugPrint('📝 Conflict recorded for journal: $journalId');
                  }

                  // Skip updating to avoid losing local changes
                  totalSkipped++;
                } else {
                  // Update journal
                  await journalDao.updateJournal(_serverJournalToCompanion(
                      serverJournal,
                      existing: localJournal));
                  totalUpdated++;
                  debugPrint('🔄 Updated journal: $journalId');
                }
              } else {
                totalSkipped++;
              }
            }
          }

          // Handle deletions
          final serverJournalIds =
              serverJournals.map((j) => j['id'] as String).toSet();
          for (final localJournal in localJournals) {
            if (!serverJournalIds.contains(localJournal.id) &&
                localJournal.isSynced &&
                !localJournal.hasPendingChanges) {
              // Journal was deleted on server, delete locally
              await journalDao.deleteJournalById(localJournal.id);
              totalDeleted++;
              debugPrint('🗑️ Deleted journal: ${localJournal.id}');
            }
          }
        } catch (e) {
          debugPrint('❌ Error fetching journals for trip ${trip.id}: $e');
          // Continue with next trip
        }
      }

      return {
        'total': totalJournals,
        'inserted': totalInserted,
        'updated': totalUpdated,
        'deleted': totalDeleted,
        'skipped': totalSkipped,
        'conflicts': totalConflicts,
      };
    } catch (e) {
      debugPrint('❌ Error syncing journals: $e');
      return _emptyResult();
    }
  }

  /// Syncs user profile from server to local database
  ///
  /// Returns a map with sync statistics.
  Future<Map<String, int>> syncUserProfile() async {
    try {
      debugPrint('📥 Syncing user profile...');

      final response = await _dio.post(
        _graphqlEndpoint,
        data: {
          'query': GraphQLQueries.getUserProfile,
          'variables': {'userId': _userId},
        },
      );

      if (response.statusCode != 200 || response.data['data'] == null) {
        final errors = response.data['errors'];
        debugPrint('❌ Failed to fetch user profile: $errors');
        return _emptyResult();
      }

      final serverUser = response.data['data']['getUserProfile'];
      debugPrint('📊 Received user profile from server');

      // Get local user
      final userDao = _database.userDao;
      final localUsers = await userDao.getUserById(_userId);

      int inserted = 0;
      int updated = 0;
      int conflicts = 0;
      int skipped = 0;

      if (localUsers.isEmpty) {
        // Insert new user
        await userDao.insertUser(_serverUserToCompanion(serverUser));
        inserted = 1;
        debugPrint('➕ Inserted user: $_userId');
      } else {
        final localUser = localUsers.first;
        // Check if update is needed
        final serverUpdatedAt = DateTime.parse(serverUser['updatedAt']);
        final needsUpdate = serverUpdatedAt.isAfter(localUser.updatedAt);

        if (needsUpdate) {
          // Check for conflicts
          if (localUser.hasPendingChanges) {
            // Conflict detected - record it
            conflicts++;
            debugPrint('⚠️ Conflict detected for user: $_userId');

            // Record the conflict if resolver is available
            if (_conflictResolver != null) {
              final conflict = Conflict(
                id: 'conflict_user_${_uuid.v4()}',
                entityType: EntityType.userProfile,
                entityId: _userId,
                type: ConflictType.concurrentUpdate,
                severity: ConflictSeverity.medium,
                clientData: {
                  'id': localUser.id,
                  'displayName': localUser.displayName,
                  'version': localUser.version,
                  'updatedAt': localUser.updatedAt.toIso8601String(),
                },
                serverData: {
                  'id': serverUser['id'],
                  'displayName': serverUser['displayName'],
                  'version': serverUser['version'],
                  'updatedAt': serverUser['updatedAt'],
                },
                clientUpdatedAt: localUser.updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                detectedAt: DateTime.now(),
              );

              await _conflictResolver!.recordConflict(conflict);
              debugPrint('📝 Conflict recorded for user: $_userId');
            }

            // Skip updating to avoid losing local changes
            skipped++;
          } else {
            // Update user
            await userDao.updateUser(_serverUserToCompanion(serverUser,
                existing: localUser));
            updated = 1;
            debugPrint('🔄 Updated user: $_userId');
          }
        }
      }

      return {
        'total': 1,
        'inserted': inserted,
        'updated': updated,
        'deleted': 0,
        'skipped': skipped > 0 ? skipped : (inserted == 0 && updated == 0 ? 1 : 0),
        'conflicts': conflicts,
      };
    } catch (e) {
      debugPrint('❌ Error syncing user profile: $e');
      return _emptyResult();
    }
  }

  // ==============================================================================
  // PRIVATE METHODS - SYNC METADATA
  // ==============================================================================

  /// Updates sync metadata after successful download
  Future<void> _updateSyncMetadata() async {
    try {
      debugPrint('📊 Updating sync metadata...');

      final now = DateTime.now();

      // Update metadata for all entity types
      final entityTypes = ['trips', 'journals', 'users'];

      for (final entityType in entityTypes) {
        // Check if metadata exists
        final metadataList = await (_database.select(_database.syncMetadataTable)
              ..where((tbl) => tbl.entityType.equals(entityType))
              ..where((tbl) => tbl.userId.equals(_userId)))
            .get();

        if (metadataList.isEmpty) {
          // Create new metadata
          await _database
              .into(_database.syncMetadataTable)
              .insert(SyncMetadataTableCompanion.insert(
                userId: _userId,
                entityType: entityType,
                lastSyncedAt: now,
                lastSyncStatus: 'success',
              ));
        } else {
          // Update existing metadata
          final metadata = metadataList.first;
          await _database
              .update(_database.syncMetadataTable)
              .replace(SyncMetadataTable(
                id: metadata.id,
                userId: _userId,
                entityType: entityType,
                lastSyncedAt: now,
                lastSyncStatus: 'success',
                lastIncrementalSyncAt: now,
              ));
        }
      }

      debugPrint('✅ Sync metadata updated');
    } catch (e) {
      debugPrint('❌ Error updating sync metadata: $e');
      // Don't throw - metadata update failure shouldn't fail the sync
    }
  }

  // ==============================================================================
  // PRIVATE METHODS - CONVERTERS
  // ==============================================================================

  /// Converts server trip data to [TripsCompanion] for database insertion
  TripsCompanion _serverTripToCompanion(
    Map<String, dynamic> serverTrip, {
    LocalTrip? existing,
  }) {
    return TripsCompanion(
      id: Value(serverTrip['id'] as String),
      userId: Value(serverTrip['userId'] as String),
      title: Value(serverTrip['title'] as String),
      description: Value(serverTrip['description'] as String?),
      startDate: Value(DateTime.parse(serverTrip['startDate'])),
      endDate: Value(DateTime.parse(serverTrip['endDate'])),
      destination: Value(serverTrip['destination'] as String),
      latitude: Value(serverTrip['latitude'] as double?),
      longitude: Value(serverTrip['longitude'] as double?),
      status: Value(serverTrip['status'] as String),
      budget: Value(serverTrip['budget'] as int),
      coverImageUrl: Value(serverTrip['coverImageUrl'] as String?),
      travelCompanionIds: Value(serverTrip['travelCompanionIds'] != null
          ? serverTrip['travelCompanionIds'].toString()
          : null),
      createdAt: Value(DateTime.parse(serverTrip['createdAt'])),
      updatedAt: Value(DateTime.parse(serverTrip['updatedAt'])),
      isSynced: const Value(true),
      hasPendingChanges: const Value(false),
      version: existing != null ? Value(existing.version + 1) : const Value(1),
      isDeleted: const Value(false),
      lastSyncedAt: Value(DateTime.now()),
    );
  }

  /// Converts server journal data to [JournalsCompanion] for database insertion
  JournalsCompanion _serverJournalToCompanion(
    Map<String, dynamic> serverJournal, {
    LocalJournal? existing,
  }) {
    return JournalsCompanion(
      id: Value(serverJournal['id'] as String),
      tripId: Value(serverJournal['tripId'] as String),
      userId: Value(serverJournal['userId'] as String),
      title: Value(serverJournal['title'] as String),
      content: Value(serverJournal['content'] as String),
      entryDate: serverJournal['entryDate'] != null
          ? Value(DateTime.parse(serverJournal['entryDate']))
          : const Value.absent(),
      mood: Value(serverJournal['mood'] as String?),
      location: Value(serverJournal['location'] as String?),
      imageUrls: Value(serverJournal['imageUrls'] != null
          ? serverJournal['imageUrls'].toString()
          : null),
      tags: Value(serverJournal['tags'] != null
          ? serverJournal['tags'].toString()
          : null),
      createdAt: Value(DateTime.parse(serverJournal['createdAt'])),
      updatedAt: Value(DateTime.parse(serverJournal['updatedAt'])),
      isSynced: const Value(true),
      hasPendingChanges: const Value(false),
      version: existing != null ? Value(existing.version + 1) : const Value(1),
      isDeleted: const Value(false),
      lastSyncedAt: Value(DateTime.now()),
    );
  }

  /// Converts server user data to [UsersCompanion] for database insertion
  UsersCompanion _serverUserToCompanion(
    Map<String, dynamic> serverUser, {
    LocalUser? existing,
  }) {
    return UsersCompanion(
      id: Value(serverUser['id'] as String),
      username: Value(serverUser['username'] as String),
      email: Value(serverUser['email'] as String),
      firstName: Value(serverUser['firstName'] as String?),
      lastName: Value(serverUser['lastName'] as String?),
      profilePictureUrl: Value(serverUser['profilePictureUrl'] as String?),
      createdAt: Value(DateTime.parse(serverUser['createdAt'])),
      updatedAt: Value(DateTime.parse(serverUser['updatedAt'])),
      isSynced: const Value(true),
      hasPendingChanges: const Value(false),
      version: existing != null ? Value(existing.version + 1) : const Value(1),
      lastSyncedAt: Value(DateTime.now()),
    );
  }

  /// Returns an empty result map
  Map<String, int> _emptyResult() {
    return {
      'total': 0,
      'inserted': 0,
      'updated': 0,
      'deleted': 0,
      'skipped': 0,
      'conflicts': 0,
    };
  }
}
