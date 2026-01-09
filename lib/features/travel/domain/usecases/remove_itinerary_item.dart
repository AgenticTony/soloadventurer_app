import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/repositories/itinerary_repository.dart';

/// Use case for removing an item from an itinerary
///
/// This use case handles removing items from an itinerary.
/// The item is deleted and the itinerary is updated.
///
/// Example Usage:
/// dart
/// final useCase = RemoveItineraryItem(repository);
/// final result = await useCase(
///   itineraryId: 'itinerary-',
///   itemId: 'item-',
/// );
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (updated) => print('Item removed. Remaining: ${updated.items.length}'),
/// );
///
class RemoveItineraryItem {
  final ItineraryRepository _repository;

  /// Creates a new [RemoveItineraryItem] use case
  ///
  /// The [repository] parameter is the itinerary repository to use.
  RemoveItineraryItem(this._repository);

  /// Executes the use case
  ///
  /// The [itineraryId] parameter is the ID of the itinerary containing the item.
  /// The [itemId] parameter is the ID of the item to remove.
  ///
  /// Returns [Right(Itinerary)] with the updated itinerary.
  /// Returns [Left(Failure)] if the itinerary or item is not found.
  Future<Either<Failure, Itinerary>> call({
    required String itineraryId,
    required String itemId,
  }) async {
    return await _repository.removeItem(itineraryId, itemId);
  }
}
