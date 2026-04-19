import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';
import 'package:soloadventurer/features/travel/domain/repositories/itinerary_repository.dart';

/// Use case for updating an item in an itinerary
///
/// This use case handles updating existing items in an itinerary.
/// It can modify item details like time, location, notes, etc.
///
/// Example Usage:
/// dart
/// final useCase = UpdateItineraryItem(repository);
/// final updatedItem = existingItem.copyWith(
///   time: DateTime(, , , ), // Reschedule to  PM
///   note: 'Book tickets in advance',
/// );
///
/// final result = await useCase(
///   itineraryId: 'itinerary-',
///   item: updatedItem,
/// );
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (updated) => print('Item updated'),
/// );
///
class UpdateItineraryItem {
  final ItineraryRepository _repository;

  /// Creates a new [UpdateItineraryItem] use case
  ///
  /// The [repository] parameter is the itinerary repository to use.
  UpdateItineraryItem(this._repository);

  /// Executes the use case
  ///
  /// The [itineraryId] parameter is the ID of the itinerary containing the item.
  /// The [item] parameter is the updated item data (must include valid ID).
  ///
  /// Returns [Right(Itinerary)] with the updated itinerary.
  /// Returns [Left(Failure)] if the itinerary or item is not found.
  Future<Either<Failure, Itinerary>> call({
    required String itineraryId,
    required ItineraryItem item,
  }) async {
    return await _repository.updateItem(itineraryId, item);
  }
}
