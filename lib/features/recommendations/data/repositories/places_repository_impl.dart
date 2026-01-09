import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/error/exceptions.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/places_remote_data_source.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/places_repository.dart';

/// Implementation of places repository
///
/// Handles data retrieval from remote data sources and maps
/// to domain entities.
class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource _remoteDataSource;

  PlacesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<PlaceActivity>>> findPlacesByInterest({
    required Destination destination,
    required TravelInterest interest,
    Set<RecommendationCategory>? categories,
    int limit = 20,
  }) async {
    try {
      final places = await _remoteDataSource.findPlacesByInterest(
        destination: destination,
        interest: interest,
        categories: categories,
        limit: limit,
      );

      return right(places);
    } on ServerException catch (e) {
      return left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on RepositoryException catch (e) {
      return left(Failure.cache(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlaceActivity>>> searchPlaces({
    required Destination destination,
    required String query,
    int limit = 20,
  }) async {
    try {
      final places = await _remoteDataSource.searchPlaces(
        destination: destination,
        query: query,
        limit: limit,
      );

      return right(places);
    } on ServerException catch (e) {
      return left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on RepositoryException catch (e) {
      return left(Failure.cache(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlaceActivity>> getPlaceDetails(
    String placeId,
  ) async {
    try {
      final place = await _remoteDataSource.getPlaceDetails(placeId);
      return right(place);
    } on ServerException catch (e) {
      return left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on RepositoryException catch (e) {
      return left(Failure.cache(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlaceActivity>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    Set<RecommendationCategory>? categories,
    int limit = 20,
  }) async {
    try {
      final places = await _remoteDataSource.getNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        categories: categories,
        limit: limit,
      );

      return right(places);
    } on ServerException catch (e) {
      return left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on RepositoryException catch (e) {
      return left(Failure.cache(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlaceActivity>>> getPopularPlaces({
    required Destination destination,
    int limit = 20,
  }) async {
    try {
      final places = await _remoteDataSource.getPopularPlaces(
        destination: destination,
        limit: limit,
      );

      return right(places);
    } on ServerException catch (e) {
      return left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on RepositoryException catch (e) {
      return left(Failure.cache(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }
}
