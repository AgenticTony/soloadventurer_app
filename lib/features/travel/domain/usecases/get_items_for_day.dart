import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';
import 'package:soloadventurer/features/travel/domain/repositories/itinerary_repository.dart';

/// Use case for getting items for a specific day in an itinerary
///
/// This use case retrieves all items scheduled for a particular day.
/// Useful for displaying a day-by-day view of the itinerary.
///
/// Example Usage:
/// ```dart
/// final useCase = GetItemsForDay(repository);
/// final result = await useCase(
///   itineraryId: 'itinerary-123',
///   dayNumber: 2, // Second day
/// );
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (items) => print('Day 2 has ${items.length} activities'),
/// );
/// ```
class GetItemsForDay {
  final ItineraryRepository _repository;

  /// Creates a new [GetItemsForDay] use case
  ///
  /// The [repository] parameter is the itinerary repository to use.
  GetItemsForDay(this._repository);

  /// Executes the use case
  ///
  /// The [itineraryId] parameter is the ID of the itinerary.
  /// The [dayNumber] parameter is the day number (1-based).
  ///
  /// Returns [Right(List<ItineraryItem>)] with the list of items for that day.
  /// Returns [Left(Failure)] if the itinerary is not found.
  Future<Either<Failure, List<ItineraryItem>>> call({
    required String itineraryId,
    required int dayNumber,
  }) async {
    // Validate day number
    if (dayNumber < 1) {
      return left(Failure.validation(
        message: 'Day number must be >= 1',
      ));
    }

    return await _repository.getItemsForDay(itineraryId, dayNumber);
  }
}
