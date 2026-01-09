import 'package:dartz/dartz.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';
import 'package:soloadventurer/features/travel/domain/repositories/itinerary_repository.dart';

/// Use case for adding an item to an itinerary
///
/// This use case handles adding new items (activities, meals, flights, etc.)
/// to an existing itinerary. It validates the item and updates the itinerary.
///
/// Example Usage:
/// dart
/// final useCase = AddItineraryItem(repository);
/// final item = ItineraryItem.activity(
///   time: DateTime(, , , ),
///   name: 'Louvre Museum',
///   description: 'World-famous art museum',
/// );
///
/// final result = await useCase(
///   itineraryId: 'itinerary-',
///   item: item,
/// );
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (updated) => print('Item added. Total items: ${updated.items.length}'),
/// );
/// 
class AddItineraryItem {
  final ItineraryRepository _repository;

  /// Creates a new [AddItineraryItem] use case
  ///
  /// The [repository] parameter is the itinerary repository to use.
  AddItineraryItem(this._repository);

  /// Executes the use case
  ///
  /// The [itineraryId] parameter is the ID of the itinerary to add the item to.
  /// The [item] parameter is the item to add.
  ///
  /// Returns [Right(Itinerary)] with the updated itinerary.
  /// Returns [Left(Failure)] if the itinerary is not found or adding fails.
  Future<Either<Failure, Itinerary>> call({
    required String itineraryId,
    required ItineraryItem item,
  }) async {
    // Validate item has a valid time
    if (item.time.isBefore(DateTime.now())) {
      return left(Failure.validation(
        message: 'Item time must be a valid date',
      ));
    }

    return await _repository.addItem(itineraryId, item);
  }
}
