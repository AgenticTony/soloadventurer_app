import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/itinerary_local_data_source.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/itinerary_repository.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';

/// Implementation of itinerary repository for recommendations feature
///
/// Provides access to itinerary data for adding recommendations.
class ItineraryRepositoryImpl implements ItineraryRepository {
  final ItineraryLocalDataSource _localDataSource;

  ItineraryRepositoryImpl(this._localDataSource);

  /// Adds an item to an itinerary
  @override
  Future<Either<Failure, ItineraryItem>> addItem(
    String itineraryId,
    ItineraryItem item,
  ) async {
    try {
      final addedItem = await _localDataSource.addItem(itineraryId, item);
      return right(addedItem);
    } on CacheException catch (e) {
      return left(Failure.cache(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  /// Gets an itinerary
  @override
  Future<Either<Failure, dynamic>> getItinerary(String itineraryId) async {
    try {
      final itinerary = await _localDataSource.getItinerary(itineraryId);
      return right(itinerary);
    } on CacheException catch (e) {
      return left(Failure.cache(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }
}
