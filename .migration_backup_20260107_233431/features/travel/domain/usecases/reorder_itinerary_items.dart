import 'package:dartz/dartz.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/repositories/itinerary_repository.dart';

/// Use case for reordering items within an itinerary
///
/// This use case handles changing the order of items in an itinerary.
/// Useful for drag-and-drop reordering UI or automatic optimization.
///
/// Example Usage:
/// dart
/// final useCase = ReorderItineraryItems(repository);
/// final result = await useCase(
///   itineraryId: 'itinerary-',
///   itemIdsInNewOrder: ['item-', 'item-', 'item-'],
/// );
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (updated) => print('Items reordered'),
/// );
/// 
class ReorderItineraryItems {
  final ItineraryRepository _repository;

  /// Creates a new [ReorderItineraryItems] use case
  ///
  /// The [repository] parameter is the itinerary repository to use.
  ReorderItineraryItems(this._repository);

  /// Executes the use case
  ///
  /// The [itineraryId] parameter is the ID of the itinerary to reorder items in.
  /// The [itemIdsInNewOrder] parameter is the list of item IDs in the desired order.
  /// All items must exist in the itinerary.
  ///
  /// Returns [Right(Itinerary)] with the updated itinerary.
  /// Returns [Left(Failure)] if the itinerary is not found or reordering fails.
  Future<Either<Failure, Itinerary>> call({
    required String itineraryId,
    required List<String> itemIdsInNewOrder,
  }) async {
    // Validate that we have items to reorder
    if (itemIdsInNewOrder.isEmpty) {
      return left(Failure.validation(
        message: 'Cannot reorder with empty item list',
      ));
    }

    return await _repository.reorderItems(itineraryId, itemIdsInNewOrder);
  }
}
