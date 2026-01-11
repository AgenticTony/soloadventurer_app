import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/models/paginated_data.dart';
import 'package:soloadventurer/core/repositories/paginated_repository_mixin.dart';
import 'package:soloadventurer/features/core/infrastructure/api/dio_api_service.dart';
import 'package:soloadventurer/features/core/infrastructure/graphql/graphql_queries.dart';
import 'package:soloadventurer/features/offline/data/models/local_trip_model.dart';
import 'package:soloadventurer/features/offline/data/repositories/offline_aware_repository.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/trip_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';
import 'package:soloadventurer/features/travel/domain/repositories/trip_repository.dart';

/// Offline-aware implementation of [TripRepository]
///
/// This repository extends [OfflineAwareRepository] to provide offline-first
/// trip data management. It handles:
/// - Reading from local database first
/// - Writing to local database immediately
/// - Queueing mutations for sync when offline
/// - Syncing with server when online
///
/// Type parameters:
/// - Entity: Trip (domain entity)
/// - Model: LocalTripModel (local database model)
/// - CreateModel: LocalTripModel (same as Model for create operations)
/// - UpdateModel: LocalTripModel (same as Model for update operations)
class TripRepositoryImpl extends OfflineAwareRepository<Trip, LocalTripModel,
    LocalTripModel, LocalTripModel> implements TripRepository {
  /// Data Access Object for local trip database operations
  final TripDao _tripDao;

  /// API service for remote GraphQL operations
  final DioApiService _apiService;

  /// Creates a new [TripRepositoryImpl]
  ///
  /// Dependencies are injected via constructor parameters.
  TripRepositoryImpl({
    required TripDao tripDao,
    required DioApiService apiService,
    required super.connectivityService,
    required super.syncQueueService,
    super.config,
  })  : _tripDao = tripDao,
        _apiService = apiService;

  // ==============================================================================
  // OFFLINE-AWARE BASE REPOSITORY ABSTRACT METHODS
  // ==============================================================================

  @override
  String get entityType => 'trip';

  @override
  LocalTripModel entityToModel(Trip entity) {
    return LocalTripModel.fromDomainEntity(entity);
  }

  @override
  Trip modelToEntity(LocalTripModel model) {
    return model.toDomainEntity();
  }

  @override
  String getEntityId(Trip entity) {
    return entity.id;
  }

  @override
  String getModelId(LocalTripModel model) {
    return model.id;
  }

  @override
  Future<LocalTripModel?> readFromLocal(String id) async {
    try {
      final localTrip = await _tripDao.getTripById(id);
      return localTrip != null ? LocalTripModel.fromDatabase(localTrip) : null;
    } catch (e) {
      debugPrint('❌ trip: Error reading from local: ${e.toString()}');
      throw const CacheException(
          message: 'Failed to read trip from local cache');
    }
  }

  @override
  Future<LocalTripModel> writeToLocal(LocalTripModel model) async {
    try {
      // Convert model to LocalTrip database entity
      final localTrip = _modelToLocalTrip(model);

      // Check if trip exists
      final existing = await _tripDao.getTripById(model.id);

      if (existing != null) {
        // Update existing trip
        await _tripDao.updateTrip(localTrip);
        debugPrint('📝 trip: Updated in local database: ${model.id}');
      } else {
        // Insert new trip
        final companion = _localTripToCompanion(localTrip);
        await _tripDao.insertTrip(companion);
        debugPrint('📝 trip: Inserted in local database: ${model.id}');
      }

      return model;
    } catch (e) {
      debugPrint('❌ trip: Error writing to local: ${e.toString()}');
      throw const CacheException(
          message: 'Failed to write trip to local cache');
    }
  }

  @override
  Future<void> deleteFromLocal(String id) async {
    try {
      // Soft delete the trip
      await _tripDao.softDeleteTripById(id);
      debugPrint('📝 trip: Soft deleted in local database: $id');
    } catch (e) {
      debugPrint('❌ trip: Error deleting from local: ${e.toString()}');
      throw const CacheException(
          message: 'Failed to delete trip from local cache');
    }
  }

  @override
  Future<List<LocalTripModel>> readAllFromLocal({String? userId}) async {
    try {
      if (userId != null) {
        final trips = await _tripDao.getTripsByUserId(userId);
        return trips.map((t) => LocalTripModel.fromDatabase(t)).toList();
      } else {
        final trips = await _tripDao.getAllTrips();
        return trips.map((t) => LocalTripModel.fromDatabase(t)).toList();
      }
    } catch (e) {
      debugPrint('❌ trip: Error reading all from local: ${e.toString()}');
      throw const CacheException(
          message: 'Failed to read trips from local cache');
    }
  }

  @override
  Future<Trip> executeRemoteCreate(LocalTripModel model) async {
    try {
      final tripData = _tripToJsonData(model);
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.createTrip,
          'variables': tripData,
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final tripDataResponse = response.data['data']['createTrip'];
      return Trip.fromJson(tripDataResponse);
    } catch (e) {
      debugPrint('❌ trip: Error in remote create: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to create trip on server');
    }
  }

  @override
  Future<Trip> executeRemoteUpdate(String id, LocalTripModel model) async {
    try {
      final tripData = _tripToJsonData(model);
      final variables = {...tripData, 'id': id};

      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.updateTrip,
          'variables': variables,
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final tripDataResponse = response.data['data']['updateTrip'];
      return Trip.fromJson(tripDataResponse);
    } catch (e) {
      debugPrint('❌ trip: Error in remote update: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to update trip on server');
    }
  }

  @override
  Future<void> executeRemoteDelete(String id) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.deleteTrip,
          'variables': {'id': id},
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final result = response.data['data']['deleteTrip'];
      if (result['success'] != true) {
        throw const ServerException(
          message: 'Failed to delete trip on server',
        );
      }

      debugPrint('🌐 trip: Deleted on remote API: $id');
    } catch (e) {
      debugPrint('❌ trip: Error in remote delete: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to delete trip on server');
    }
  }

  @override
  Future<Trip> executeRemoteFetch(String id) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.getTrip,
          'variables': {'id': id},
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final tripData = response.data['data']['getTrip'];
      return Trip.fromJson(tripData);
    } catch (e) {
      debugPrint('❌ trip: Error in remote fetch: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to fetch trip from server');
    }
  }

  @override
  Future<List<Trip>> executeRemoteFetchAll({String? userId}) async {
    try {
      if (userId == null) {
        throw const ServerException(
          message: 'userId is required for fetching trips',
        );
      }

      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.getTrips,
          'variables': {'userId': userId},
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final tripsData = response.data['data']['getTrips'] as List;
      return tripsData.map((json) => Trip.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ trip: Error in remote fetch all: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw const ServerException(message: 'Failed to fetch trips from server');
    }
  }

  // ==============================================================================
  // TRIP REPOSITORY INTERFACE METHODS
  // ==============================================================================

  @override
  Future<Trip?> getTripById({required String tripId}) async {
    final result = await getById(tripId);
    return result;
  }

  @override
  Future<List<Trip>> getTrips({String? userId}) {
    return getAll(userId: userId);
  }

  @override
  Future<Trip> createTrip({required Trip trip}) async {
    final tripModel = entityToModel(trip);
    final result = await create(tripModel);
    return result.data;
  }

  @override
  Future<Trip> updateTrip({required String tripId, required Trip updates}) async {
    final tripModel = entityToModel(updates);
    final result = await update(tripId, tripModel);
    return result.data;
  }

  @override
  Future<bool> deleteTrip({required String tripId}) async {
    try {
      await delete(tripId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Trip>> getTripsByStatus(String status, {String? userId}) async {
    try {
      // For now, we only support local queries
      // Remote sync will happen automatically when needed
      final trips = await _tripDao.getTripsByStatus(status, userId: userId);
      return trips
          .map((t) => LocalTripModel.fromDatabase(t).toDomainEntity())
          .toList();
    } catch (e) {
      debugPrint('❌ trip: Error getting trips by status: ${e.toString()}');
      throw const CacheException(message: 'Failed to get trips by status');
    }
  }

  @override
  Future<List<Trip>> getTripsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
  }) async {
    try {
      // For now, we only support local queries
      // Remote sync will happen automatically when needed
      final trips = await _tripDao.getTripsByDateRange(
        startDate,
        endDate,
        userId: userId,
      );
      return trips
          .map((t) => LocalTripModel.fromDatabase(t).toDomainEntity())
          .toList();
    } catch (e) {
      debugPrint('❌ trip: Error getting trips by date range: ${e.toString()}');
      throw const CacheException(message: 'Failed to get trips by date range');
    }
  }

  @override
  Future<PaginatedData<Trip>> getTripsCursor({
    required String userId,
    String? cursor,
    int pageSize = 20,
    String sortBy = 'createdAt',
    SortOrder sortOrder = SortOrder.descending,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // For now, we only support local queries
      // TODO: Implement cursor-based pagination with remote sync
      final trips = await _tripDao.getTripsByUserId(userId);
      final entities = trips
          .map((t) => LocalTripModel.fromDatabase(t).toDomainEntity())
          .toList();

      return PaginatedData<Trip>(
        items: entities,
        pageInfo: PageInfo(
          currentPage: 1,
          itemsPerPage: entities.length,
          totalItems: entities.length,
          hasNextPage: false,
          hasPreviousPage: false,
        ),
      );
    } catch (e) {
      debugPrint('❌ trip: Error getting trips cursor: ${e.toString()}');
      throw const CacheException(message: 'Failed to get trips cursor');
    }
  }

  @override
  Future<PaginatedData<Trip>> getTripsOffset({
    required String userId,
    int page = 1,
    int pageSize = 20,
    String sortBy = 'createdAt',
    SortOrder sortOrder = SortOrder.descending,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // For now, we only support local queries
      // TODO: Implement offset-based pagination with remote sync
      final trips = await _tripDao.getTripsByUserId(userId);
      final entities = trips
          .map((t) => LocalTripModel.fromDatabase(t).toDomainEntity())
          .toList();

      // Apply offset and limit
      final startIndex = (page - 1) * pageSize;
      final endIndex = startIndex + pageSize;
      final paginatedItems = startIndex < entities.length
          ? entities.sublist(startIndex, endIndex.clamp(0, entities.length))
          : <Trip>[];

      return PaginatedData<Trip>(
        items: paginatedItems,
        pageInfo: PageInfo(
          currentPage: page,
          itemsPerPage: pageSize,
          totalItems: entities.length,
          hasNextPage: endIndex < entities.length,
          hasPreviousPage: page > 1,
        ),
      );
    } catch (e) {
      debugPrint('❌ trip: Error getting trips offset: ${e.toString()}');
      throw const CacheException(message: 'Failed to get trips offset');
    }
  }

  @override
  Future<PaginatedData<TripMetadata>> getTripsMetadata({
    required String userId,
    String? cursor,
    int pageSize = 50,
  }) async {
    try {
      // For now, we only support local queries
      // TODO: Implement cursor-based pagination for metadata
      final trips = await _tripDao.getTripsByUserId(userId);
      final metadata = trips.map((t) => TripMetadata.fromTrip(
        LocalTripModel.fromDatabase(t).toDomainEntity()
      )).toList();

      return PaginatedData<TripMetadata>(
        items: metadata,
        pageInfo: PageInfo(
          currentPage: 1,
          itemsPerPage: metadata.length,
          totalItems: metadata.length,
          hasNextPage: false,
          hasPreviousPage: false,
        ),
      );
    } catch (e) {
      debugPrint('❌ trip: Error getting trips metadata: ${e.toString()}');
      throw const CacheException(message: 'Failed to get trips metadata');
    }
  }

  @override
  Future<List<Trip>> getTripsByIds({required List<String> tripIds}) async {
    try {
      // Batch query from local database
      final results = <Trip>[];
      for (final tripId in tripIds) {
        final localTrip = await _tripDao.getTripById(tripId);
        if (localTrip != null) {
          results.add(LocalTripModel.fromDatabase(localTrip).toDomainEntity());
        }
      }
      return results;
    } catch (e) {
      debugPrint('❌ trip: Error getting trips by ids: ${e.toString()}');
      throw const CacheException(message: 'Failed to get trips by ids');
    }
  }

  @override
  Future<PaginatedData<Trip>> searchTrips({
    required String userId,
    required String query,
    String? cursor,
    int? page,
    int pageSize = 20,
  }) async {
    try {
      // For now, we only support local queries
      final trips = await _tripDao.searchTrips(query, userId: userId);
      final entities = trips
          .map((t) => LocalTripModel.fromDatabase(t).toDomainEntity())
          .toList();

      return PaginatedData<Trip>(
        items: entities,
        pageInfo: PageInfo(
          currentPage: 1,
          itemsPerPage: entities.length,
          totalItems: entities.length,
          hasNextPage: false,
          hasPreviousPage: false,
        ),
      );
    } catch (e) {
      debugPrint('❌ trip: Error searching trips: ${e.toString()}');
      throw const CacheException(message: 'Failed to search trips');
    }
  }

  @override
  Future<int> countTrips({
    required String userId,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final trips = await _tripDao.getTripsByUserId(userId);
      return trips.length;
    } catch (e) {
      debugPrint('❌ trip: Error counting trips: ${e.toString()}');
      throw const CacheException(message: 'Failed to count trips');
    }
  }

  @override
  Future<PaginatedData<Trip>> getTripsInDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? cursor,
    int pageSize = 20,
  }) async {
    try {
      // Use the existing date range method
      final trips = await _tripDao.getTripsByDateRange(
        startDate,
        endDate,
        userId: userId,
      );
      final entities = trips
          .map((t) => LocalTripModel.fromDatabase(t).toDomainEntity())
          .toList();

      return PaginatedData<Trip>(
        items: entities,
        pageInfo: PageInfo(
          currentPage: 1,
          itemsPerPage: entities.length,
          totalItems: entities.length,
          hasNextPage: false,
          hasPreviousPage: false,
        ),
      );
    } catch (e) {
      debugPrint('❌ trip: Error getting trips in date range: ${e.toString()}');
      throw const CacheException(message: 'Failed to get trips in date range');
    }
  }

  // ==============================================================================
  // HELPER METHODS - Local database conversion
  // ==============================================================================

  /// Convert [LocalTripModel] to [LocalTrip] database entity
  LocalTrip _modelToLocalTrip(LocalTripModel model) {
    return LocalTrip(
      id: model.id,
      userId: model.userId,
      title: model.title,
      description: model.description,
      startDate: model.startDate,
      endDate: model.endDate,
      destination: model.destination,
      latitude: model.latitude,
      longitude: model.longitude,
      status: model.status,
      budget: model.budget,
      coverImageUrl: model.coverImageUrl,
      travelCompanionIds: model.travelCompanionIdsToJson(),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isSynced: model.isSynced,
      hasPendingChanges: model.hasPendingChanges,
      version: model.version,
      isDeleted: model.isDeleted,
      lastSyncedAt: model.lastSyncedAt,
    );
  }

  /// Convert [LocalTrip] to [TripsCompanion] for database operations
  TripsCompanion _localTripToCompanion(LocalTrip trip) {
    return TripsCompanion(
      id: Value(trip.id),
      userId: Value(trip.userId),
      title: Value(trip.title),
      description: Value(trip.description),
      startDate: Value(trip.startDate),
      endDate: Value(trip.endDate),
      destination: Value(trip.destination),
      latitude: Value(trip.latitude),
      longitude: Value(trip.longitude),
      status: Value(trip.status),
      budget: Value(trip.budget),
      coverImageUrl: Value(trip.coverImageUrl),
      travelCompanionIds: trip.travelCompanionIds != null
          ? Value(trip.travelCompanionIds!)
          : const Value.absent(),
      createdAt: Value(trip.createdAt),
      updatedAt: Value(trip.updatedAt),
      isSynced: Value(trip.isSynced),
      hasPendingChanges: Value(trip.hasPendingChanges),
      version: Value(trip.version),
      isDeleted: Value(trip.isDeleted),
      lastSyncedAt: Value(trip.lastSyncedAt),
    );
  }

  /// Convert domain entity or model to JSON for GraphQL mutations
  Map<String, dynamic> _tripToJsonData(dynamic tripOrModel) {
    final data = tripOrModel is Trip
        ? {
            'userId': tripOrModel.userId,
            'title': tripOrModel.title,
            'description': tripOrModel.description,
            'startDate': tripOrModel.startDate.toIso8601String(),
            'endDate': tripOrModel.endDate.toIso8601String(),
            'destination': tripOrModel.destination,
            'latitude': tripOrModel.latitude,
            'longitude': tripOrModel.longitude,
            'status': tripOrModel.status,
            'budget': tripOrModel.budget,
            'coverImageUrl': tripOrModel.coverImageUrl,
            'travelCompanionIds': tripOrModel.travelCompanionIds,
          }
        : {
            'userId': tripOrModel.userId,
            'title': tripOrModel.title,
            'description': tripOrModel.description,
            'startDate': tripOrModel.startDate.toIso8601String(),
            'endDate': tripOrModel.endDate.toIso8601String(),
            'destination': tripOrModel.destination,
            'latitude': tripOrModel.latitude,
            'longitude': tripOrModel.longitude,
            'status': tripOrModel.status,
            'budget': tripOrModel.budget,
            'coverImageUrl': tripOrModel.coverImageUrl,
            'travelCompanionIds': tripOrModel.travelCompanionIds,
          };
    return data;
  }

  @override
  Map<String, dynamic> _modelToJson(LocalTripModel model) {
    return model.toJson();
  }
}
