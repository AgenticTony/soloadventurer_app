import 'package:soloadventurer/core/errors/app_exception.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/trip_model.dart';
import 'package:soloadventurer/features/journal/domain/entities/trip.dart';
import 'package:soloadventurer/features/journal/domain/repositories/trip_repository.dart';

/// Implementation of [TripRepository]
class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource _remoteDataSource;

  TripRepositoryImpl({
    required TripRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Trip> createTrip(Trip trip) async {
    try {
      final model = TripModel.fromEntity(trip);
      final createdTrip = await _remoteDataSource.createTrip(model);
      return createdTrip.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to create trip: $e');
    }
  }

  @override
  Future<Trip> getTrip(String tripId) async {
    try {
      final model = await _remoteDataSource.getTrip(tripId);
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get trip: $e');
    }
  }

  @override
  Future<List<Trip>> getTrips() async {
    try {
      final models = await _remoteDataSource.getTrips();
      return models.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get trips: $e');
    }
  }

  @override
  Future<List<Trip>> getTripsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final models = await _remoteDataSource.getTripsByDateRange(
        startDate,
        endDate,
      );
      return models.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get trips by date range: $e');
    }
  }

  @override
  Future<List<Trip>> getOngoingTrips() async {
    try {
      final models = await _remoteDataSource.getOngoingTrips();
      return models.map((model) => model.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get ongoing trips: $e');
    }
  }

  @override
  Future<Trip> updateTrip(Trip trip) async {
    try {
      final model = TripModel.fromEntity(trip);
      final updatedTrip = await _remoteDataSource.updateTrip(model);
      return updatedTrip.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to update trip: $e');
    }
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    try {
      await _remoteDataSource.deleteTrip(tripId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to delete trip: $e');
    }
  }

  @override
  Future<int> getEntryCountForTrip(String tripId) async {
    try {
      return await _remoteDataSource.getEntryCountForTrip(tripId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to get entry count: $e');
    }
  }
}
