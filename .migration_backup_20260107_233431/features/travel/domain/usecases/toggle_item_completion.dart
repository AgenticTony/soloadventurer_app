import 'package:dartz/dartz.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/repositories/itinerary_repository.dart';

/// Use case for toggling the completion status of an itinerary item
///
/// This use case handles marking items as complete/incomplete.
/// Useful for tracking progress during a trip.
///
/// Example Usage:
/// dart
/// final useCase = ToggleItemCompletion(repository);
/// final result = await useCase(
///   itineraryId: 'itinerary-',
///   itemId: 'item-',
/// );
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (updated) => print('Item toggled. Progress: ${updated.completionPercentage}%'),
/// );
/// 
class ToggleItemCompletion {
  final ItineraryRepository _repository;

  /// Creates a new [ToggleItemCompletion] use case
  ///
  /// The [repository] parameter is the itinerary repository to use.
  ToggleItemCompletion(this._repository);

  /// Executes the use case
  ///
  /// The [itineraryId] parameter is the ID of the itinerary containing the item.
  /// The [itemId] parameter is the ID of the item to toggle.
  ///
  /// Returns [Right(Itinerary)] with the updated itinerary.
  /// Returns [Left(Failure)] if the itinerary or item is not found.
  Future<Either<Failure, Itinerary>> call({
    required String itineraryId,
    required String itemId,
  }) async {
    return await _repository.toggleItemCompletion(itineraryId, itemId);
  }
}
