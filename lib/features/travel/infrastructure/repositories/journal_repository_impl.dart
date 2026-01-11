import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/core/infrastructure/api/dio_api_service.dart';
import 'package:soloadventurer/features/core/infrastructure/graphql/graphql_queries.dart';
import 'package:soloadventurer/features/offline/data/models/local_journal_model.dart';
import 'package:soloadventurer/features/offline/data/repositories/offline_aware_repository.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/journal_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/travel/domain/models/journal.dart';
import 'package:soloadventurer/features/travel/domain/repositories/journal_repository.dart';

/// Offline-aware implementation of [JournalRepository]
///
/// This repository extends [OfflineAwareRepository] to provide offline-first
/// journal data management. It handles:
/// - Reading from local database first
/// - Writing to local database immediately
/// - Queueing mutations for sync when offline
/// - Syncing with server when online
///
/// Type parameters:
/// - Entity: Journal (domain entity)
/// - Model: LocalJournalModel (local database model)
/// - CreateModel: LocalJournalModel (same as Model for create operations)
/// - UpdateModel: LocalJournalModel (same as Model for update operations)
class JournalRepositoryImpl extends OfflineAwareRepository<
    Journal,
    LocalJournalModel,
    LocalJournalModel,
    LocalJournalModel> implements JournalRepository {
  /// Data Access Object for local journal database operations
  final JournalDao _journalDao;

  /// API service for remote GraphQL operations
  final DioApiService _apiService;

  /// Creates a new [JournalRepositoryImpl]
  ///
  /// Dependencies are injected via constructor parameters.
  JournalRepositoryImpl({
    required JournalDao journalDao,
    required DioApiService apiService,
    required super.connectivityService,
    required super.syncQueueService,
    super.config,
  })  : _journalDao = journalDao,
        _apiService = apiService;

  // ==============================================================================
  // OFFLINE-AWARE BASE REPOSITORY ABSTRACT METHODS
  // ==============================================================================

  @override
  String get entityType => 'journal';

  @override
  LocalJournalModel entityToModel(Journal entity) {
    return LocalJournalModel(
      id: entity.id,
      tripId: entity.tripId,
      userId: entity.userId,
      title: entity.title,
      content: entity.content,
      entryDate: entity.entryDate,
      mood: entity.mood,
      location: entity.location,
      imageUrls: entity.imageUrls,
      tags: entity.tags,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: false, // New entities are not synced yet
      hasPendingChanges: false,
      version: 1,
      isDeleted: false,
      lastSyncedAt: null,
    );
  }

  @override
  Journal modelToEntity(LocalJournalModel model) {
    return Journal(
      id: model.id,
      tripId: model.tripId,
      userId: model.userId,
      title: model.title,
      content: model.content,
      entryDate: model.entryDate,
      mood: model.mood,
      location: model.location,
      imageUrls: model.imageUrls,
      tags: model.tags,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  @override
  String getEntityId(Journal entity) {
    return entity.id;
  }

  @override
  String getModelId(LocalJournalModel model) {
    return model.id;
  }

  @override
  Future<LocalJournalModel?> readFromLocal(String id) async {
    try {
      final localJournal = await _journalDao.getJournalById(id);
      return localJournal != null
          ? LocalJournalModel.fromDatabase(localJournal)
          : null;
    } catch (e) {
      debugPrint('❌ journal: Error reading from local: ${e.toString()}');
      throw const CacheException(
          message: 'Failed to read journal from local cache');
    }
  }

  @override
  Future<LocalJournalModel> writeToLocal(LocalJournalModel model) async {
    try {
      // Convert model to LocalJournal database entity
      final localJournal = _modelToLocalJournal(model);

      // Check if journal exists
      final existing = await _journalDao.getJournalById(model.id);

      if (existing != null) {
        // Update existing journal
        await _journalDao.updateJournal(localJournal);
        debugPrint('📝 journal: Updated in local database: ${model.id}');
      } else {
        // Insert new journal
        final companion = _localJournalToCompanion(localJournal);
        await _journalDao.insertJournal(companion);
        debugPrint('📝 journal: Inserted in local database: ${model.id}');
      }

      return model;
    } catch (e) {
      debugPrint('❌ journal: Error writing to local: ${e.toString()}');
      throw const CacheException(
          message: 'Failed to write journal to local cache');
    }
  }

  @override
  Future<void> deleteFromLocal(String id) async {
    try {
      // Soft delete the journal
      await _journalDao.softDeleteJournalById(id);
      debugPrint('📝 journal: Soft deleted in local database: $id');
    } catch (e) {
      debugPrint('❌ journal: Error deleting from local: ${e.toString()}');
      throw const CacheException(
          message: 'Failed to delete journal from local cache');
    }
  }

  @override
  Future<List<LocalJournalModel>> readAllFromLocal({String? userId}) async {
    try {
      // For journals, we filter by tripId, not userId directly
      // If userId is provided, we get journals for that user
      // If not provided, we get all journals (not recommended)
      if (userId != null) {
        final journals = await _journalDao.getJournalsByUserId(userId);
        return journals.map((j) => LocalJournalModel.fromDatabase(j)).toList();
      } else {
        final journals = await _journalDao.getAllJournals();
        return journals.map((j) => LocalJournalModel.fromDatabase(j)).toList();
      }
    } catch (e) {
      debugPrint('❌ journal: Error reading all from local: ${e.toString()}');
      throw const CacheException(
          message: 'Failed to read journals from local cache');
    }
  }

  @override
  Future<Journal> executeRemoteCreate(LocalJournalModel model) async {
    try {
      final journalData = _journalToJsonData(model);
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.createJournal,
          'variables': journalData,
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final journalDataResponse = response.data['data']['createJournal'];
      return Journal.fromJson(journalDataResponse);
    } catch (e) {
      debugPrint('❌ journal: Error in remote create: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(
          message: 'Failed to create journal on server');
    }
  }

  @override
  Future<Journal> executeRemoteUpdate(
    String id,
    LocalJournalModel model,
  ) async {
    try {
      final journalData = _journalToJsonData(model);
      final variables = {...journalData, 'id': id};

      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.updateJournal,
          'variables': variables,
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final journalDataResponse = response.data['data']['updateJournal'];
      return Journal.fromJson(journalDataResponse);
    } catch (e) {
      debugPrint('❌ journal: Error in remote update: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(
          message: 'Failed to update journal on server');
    }
  }

  @override
  Future<void> executeRemoteDelete(String id) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.deleteJournal,
          'variables': {'id': id},
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final result = response.data['data']['deleteJournal'];
      if (result['success'] != true) {
        throw const ServerException(
          message: 'Failed to delete journal on server',
        );
      }

      debugPrint('🌐 journal: Deleted on remote API: $id');
    } catch (e) {
      debugPrint('❌ journal: Error in remote delete: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(
          message: 'Failed to delete journal on server');
    }
  }

  @override
  Future<Journal> executeRemoteFetch(String id) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.getJournal,
          'variables': {'id': id},
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final journalData = response.data['data']['getJournal'];
      return Journal.fromJson(journalData);
    } catch (e) {
      debugPrint('❌ journal: Error in remote fetch: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(
          message: 'Failed to fetch journal from server');
    }
  }

  @override
  Future<List<Journal>> executeRemoteFetchAll({String? userId}) async {
    // Journals are organized by trip, not directly by user.
    // The base class OfflineAwareRepository expects a fetchAll(userId) method,
    // but for journals, we need to fetch by tripId.
    // This method should not be called directly - use getJournals(tripId) instead.
    debugPrint(
      '⚠️ journal: executeRemoteFetchAll called, but journals require tripId. '
      'Use getJournals(tripId) method instead.',
    );
    return const [];
  }

  // ==============================================================================
  // JOURNAL REPOSITORY INTERFACE METHODS
  // ==============================================================================

  @override
  Future<Journal> getJournalById(String id) {
    return getById(id);
  }

  @override
  Future<List<Journal>> getJournals({required String tripId}) async {
    try {
      // For journals, we need to get them by tripId
      // Try local database first
      final localJournals = await _journalDao.getJournalsByTripId(tripId);

      if (localJournals.isNotEmpty) {
        final journals = localJournals
            .map((j) => LocalJournalModel.fromDatabase(j))
            .map(modelToEntity)
            .toList();
        debugPrint('📦 journal: Retrieved ${journals.length} from local cache');
        return journals;
      }

      // Local data not available, check connectivity
      final online = await isOnline;

      if (!online) {
        if (config.enableOfflineMode) {
          throw const CacheException(
            message: 'journal data not available offline',
          );
        } else {
          throw const NetworkConnectivityException(
            message: 'No network connection and offline mode disabled',
          );
        }
      }

      // Fetch from remote API
      debugPrint('🌐 journal: Fetching all from remote API for trip: $tripId');
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.getJournals,
          'variables': {'tripId': tripId},
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final journalsData = response.data['data']['getJournals'] as List;
      final journals =
          journalsData.map((json) => Journal.fromJson(json)).toList();

      // Cache the fetched journals locally
      for (final entity in journals) {
        final model = entityToModel(entity);
        try {
          await writeToLocal(model);
        } catch (e) {
          debugPrint('⚠️ journal: Failed to cache journal: $e');
        }
      }

      return journals;
    } on AppException catch (e) {
      debugPrint('❌ journal: Error in getJournals: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ journal: Unexpected error in getJournals: ${e.toString()}');
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<RepositoryOperationResult<Journal>> createJournal(Journal journal) {
    final journalModel = entityToModel(journal);
    return create(journalModel);
  }

  @override
  Future<RepositoryOperationResult<Journal>> updateJournal(
    String id,
    Journal journal,
  ) {
    final journalModel = entityToModel(journal);
    return update(id, journalModel);
  }

  @override
  Future<RepositoryOperationResult<void>> deleteJournal(String id) {
    return delete(id);
  }

  @override
  Future<List<Journal>> getJournalsByMood(String mood, {String? userId}) async {
    try {
      // For now, we only support local queries
      // Remote sync will happen automatically when needed
      final journals =
          await _journalDao.getJournalsByMood(mood, userId: userId);
      return journals
          .map((j) => LocalJournalModel.fromDatabase(j))
          .map(modelToEntity)
          .toList();
    } catch (e) {
      debugPrint('❌ journal: Error getting journals by mood: ${e.toString()}');
      throw const CacheException(message: 'Failed to get journals by mood');
    }
  }

  @override
  Future<List<Journal>> getJournalsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? tripId,
  }) async {
    try {
      // For now, we only support local queries
      // Remote sync will happen automatically when needed
      final journals = await _journalDao.getJournalsByDateRange(
        startDate,
        endDate,
        tripId: tripId,
      );
      return journals
          .map((j) => LocalJournalModel.fromDatabase(j))
          .map(modelToEntity)
          .toList();
    } catch (e) {
      debugPrint(
          '❌ journal: Error getting journals by date range: ${e.toString()}');
      throw const CacheException(
          message: 'Failed to get journals by date range');
    }
  }

  @override
  Future<List<Journal>> getJournalsByLocation(String location,
      {String? userId}) async {
    try {
      // For now, we only support local queries
      // Remote sync will happen automatically when needed
      final journals =
          await _journalDao.getJournalsByLocation(location, userId: userId);
      return journals
          .map((j) => LocalJournalModel.fromDatabase(j))
          .map(modelToEntity)
          .toList();
    } catch (e) {
      debugPrint(
          '❌ journal: Error getting journals by location: ${e.toString()}');
      throw const CacheException(message: 'Failed to get journals by location');
    }
  }

  @override
  Future<List<Journal>> searchJournals(String searchTerm,
      {String? userId}) async {
    try {
      // For now, we only support local queries
      // Remote sync will happen automatically when needed
      final journals =
          await _journalDao.searchJournals(searchTerm, userId: userId);
      return journals
          .map((j) => LocalJournalModel.fromDatabase(j))
          .map(modelToEntity)
          .toList();
    } catch (e) {
      debugPrint('❌ journal: Error searching journals: ${e.toString()}');
      throw const CacheException(message: 'Failed to search journals');
    }
  }

  @override
  Future<List<Journal>> getJournalsPaginated({
    int limit = 20,
    int offset = 0,
    String? tripId,
  }) async {
    try {
      // For now, we only support local queries
      // Remote sync will happen automatically when needed
      final journals = await _journalDao.getJournalsPaginated(
        limit: limit,
        offset: offset,
        tripId: tripId,
      );
      return journals
          .map((j) => LocalJournalModel.fromDatabase(j))
          .map(modelToEntity)
          .toList();
    } catch (e) {
      debugPrint(
          '❌ journal: Error getting paginated journals: ${e.toString()}');
      throw const CacheException(message: 'Failed to get paginated journals');
    }
  }

  // ==============================================================================
  // HELPER METHODS - Local database conversion
  // ==============================================================================

  /// Convert [LocalJournalModel] to [LocalJournal] database entity
  LocalJournal _modelToLocalJournal(LocalJournalModel model) {
    return LocalJournal(
      id: model.id,
      tripId: model.tripId,
      userId: model.userId,
      title: model.title,
      content: model.content,
      entryDate: model.entryDate,
      mood: model.mood,
      location: model.location,
      imageUrls: model.imageUrlsToJson(),
      tags: model.tagsToJson(),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isSynced: model.isSynced,
      hasPendingChanges: model.hasPendingChanges,
      version: model.version,
      isDeleted: model.isDeleted,
      lastSyncedAt: model.lastSyncedAt,
    );
  }

  /// Convert [LocalJournal] to [JournalsCompanion] for database operations
  JournalsCompanion _localJournalToCompanion(LocalJournal journal) {
    return JournalsCompanion(
      id: Value(journal.id),
      tripId: Value(journal.tripId),
      userId: Value(journal.userId),
      title: Value(journal.title),
      content: Value(journal.content),
      entryDate: Value(journal.entryDate),
      mood: Value(journal.mood),
      location: Value(journal.location),
      imageUrls: journal.imageUrls != null
          ? Value(journal.imageUrls!)
          : const Value.absent(),
      tags: journal.tags != null ? Value(journal.tags!) : const Value.absent(),
      createdAt: Value(journal.createdAt),
      updatedAt: Value(journal.updatedAt),
      isSynced: Value(journal.isSynced),
      hasPendingChanges: Value(journal.hasPendingChanges),
      version: Value(journal.version),
      isDeleted: Value(journal.isDeleted),
      lastSyncedAt: Value(journal.lastSyncedAt),
    );
  }

  /// Convert domain entity or model to JSON for GraphQL mutations
  Map<String, dynamic> _journalToJsonData(dynamic journalOrModel) {
    final data = journalOrModel is Journal
        ? {
            'tripId': journalOrModel.tripId,
            'userId': journalOrModel.userId,
            'title': journalOrModel.title,
            'content': journalOrModel.content,
            'entryDate': journalOrModel.entryDate?.toIso8601String(),
            'mood': journalOrModel.mood,
            'location': journalOrModel.location,
            'imageUrls': journalOrModel.imageUrls,
            'tags': journalOrModel.tags,
          }
        : {
            'tripId': journalOrModel.tripId,
            'userId': journalOrModel.userId,
            'title': journalOrModel.title,
            'content': journalOrModel.content,
            'entryDate': journalOrModel.entryDate?.toIso8601String(),
            'mood': journalOrModel.mood,
            'location': journalOrModel.location,
            'imageUrls': journalOrModel.imageUrls,
            'tags': journalOrModel.tags,
          };
    return data;
  }

  // Note: _modelToJson is not used in this implementation
  // The _journalToJsonData helper method handles JSON conversion
  // Map<String, dynamic> _modelToJson(LocalJournalModel model) {
  //   return model.toJson();
  // }
}
