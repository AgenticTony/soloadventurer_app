import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/core/infrastructure/api/dio_api_service.dart';
import 'package:soloadventurer/features/core/infrastructure/graphql/graphql_queries.dart';
import 'package:soloadventurer/features/offline/data/models/local_trip_model.dart';
import 'package:soloadventurer/features/offline/data/models/sync_operation_model.dart';
import 'package:soloadventurer/features/offline/data/repositories/offline_aware_repository.dart';
import 'package:soloadventurer/features/offline/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/trip_dao.dart';
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
class TripRepositoryImpl extends OfflineAwareRepository<Trip, LocalTripModel,
    Map<String, dynamic>, Map<String, dynamic>> implements TripRepository {
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
    required ConnectivityService connectivityService,
    required SyncQueueService syncQueueService,
    super.config,
  })  : _tripDao = tripDao,
        _apiService = apiService,
        super(
          connectivityService: connectivityService,
          syncQueueService: syncQueueService,
        );

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
      throw CacheException(message: 'Failed to read trip from local cache');
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
      throw CacheException(message: 'Failed to write trip to local cache');
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
      throw CacheException(message: 'Failed to delete trip from local cache');
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
      throw CacheException(message: 'Failed to read trips from local cache');
    }
  }

  @override
  Future<Trip> executeRemoteCreate(Map<String, dynamic> model) async {
    try {
      final response = await _apiService.dio.post(
        '/graphql',
        data: {
          'query': GraphQLQueries.createTrip,
          'variables': model,
        },
      );

      if (response.data['errors'] != null) {
        throw ServerException(
          message: response.data['errors'][0]['message'],
        );
      }

      final tripData = response.data['data']['createTrip'];
      return Trip.fromJson(tripData);
    } catch (e) {
      debugPrint('❌ trip: Error in remote create: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: 'Failed to create trip on server');
    }
  }

  @override
  Future<Trip> executeRemoteUpdate(String id, Map<String, dynamic> model) async {
    try {
      final variables = {...model, 'id': id};

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

      final tripData = response.data['data']['updateTrip'];
      return Trip.fromJson(tripData);
    } catch (e) {
      debugPrint('❌ trip: Error in remote update: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: 'Failed to update trip on server');
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
        throw ServerException(
          message: 'Failed to delete trip on server',
        );
      }

      debugPrint('🌐 trip: Deleted on remote API: $id');
    } catch (e) {
      debugPrint('❌ trip: Error in remote delete: ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: 'Failed to delete trip on server');
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
      throw ServerException(message: 'Failed to fetch trip from server');
    }
  }

  @override
  Future<List<Trip>> executeRemoteFetchAll({String? userId}) async {
    try {
      if (userId == null) {
        throw ServerException(
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
      throw ServerException(message: 'Failed to fetch trips from server');
    }
  }

  // ==============================================================================
  // TRIP REPOSITORY INTERFACE METHODS
  // ==============================================================================

  @override
  Future<Trip> getTripById(String id) {
    return getById(id);
  }

  @override
  Future<List<Trip>> getTrips({String? userId}) {
    return getAll(userId: userId);
  }

  @override
  Future<RepositoryOperationResult<Trip>> createTrip(Trip trip) {
    final tripData = _tripToJson(trip);
    return create(tripData);
  }

  @override
  Future<RepositoryOperationResult<Trip>> updateTrip(String id, Trip trip) {
    final tripData = _tripToJson(trip);
    return update(id, tripData);
  }

  @override
  Future<RepositoryOperationResult<void>> deleteTrip(String id) {
    return delete(id);
  }

  @override
  Future<List<Trip>> getTripsByStatus(String status, {String? userId}) async {
    try {
      // For now, we only support local queries
      // Remote sync will happen automatically when needed
      final trips = await _tripDao.getTripsByStatus(status, userId: userId);
      return trips.map((t) => LocalTripModel.fromDatabase(t).toDomainEntity()).toList();
    } catch (e) {
      debugPrint('❌ trip: Error getting trips by status: ${e.toString()}');
      throw CacheException(message: 'Failed to get trips by status');
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
      return trips.map((t) => LocalTripModel.fromDatabase(t).toDomainEntity()).toList();
    } catch (e) {
      debugPrint('❌ trip: Error getting trips by date range: ${e.toString()}');
      throw CacheException(message: 'Failed to get trips by date range');
    }
  }

  @override
  Future<List<Trip>> searchTrips(String searchTerm, {String? userId}) async {
    try {
      // For now, we only support local queries
      // Remote sync will happen automatically when needed
      final trips = await _tripDao.searchTrips(searchTerm, userId: userId);
      return trips.map((t) => LocalTripModel.fromDatabase(t).toDomainEntity()).toList();
    } catch (e) {
      debugPrint('❌ trip: Error searching trips: ${e.toString()}');
      throw CacheException(message: 'Failed to search trips');
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
      travelCompanionIds: model.travelCompanionIds,
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
      travelCompanionIds: Value(trip.travelCompanionIds),
      createdAt: Value(trip.createdAt),
      updatedAt: Value(trip.updatedAt),
      isSynced: Value(trip.isSynced),
      hasPendingChanges: Value(trip.hasPendingChanges),
      version: Value(trip.version),
      isDeleted: Value(trip.isDeleted),
      lastSyncedAt: Value(trip.lastSyncedAt),
    );
  }

  /// Convert [Trip] domain entity to JSON for GraphQL mutations
  Map<String, dynamic> _tripToJson(Trip trip) {
    return {
      'userId': trip.userId,
      'title': trip.title,
      'description': trip.description,
      'startDate': trip.startDate.toIso8601String(),
      'endDate': trip.endDate.toIso8601String(),
      'destination': trip.destination,
      'latitude': trip.latitude,
      'longitude': trip.longitude,
      'status': trip.status,
      'budget': trip.budget,
      'coverImageUrl': trip.coverImageUrl,
      'travelCompanionIds': trip.travelCompanionIds,
    };
  }

  @override
  Map<String, dynamic> _modelToJson(LocalTripModel model) {
    return model.toJson();
  }
}
