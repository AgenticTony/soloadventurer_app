import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/repositories/itinerary_repository.dart';

/// Use case for creating a new itinerary
///
/// This use case encapsulates the business logic for creating a new itinerary.
/// It handles validation, persistence, and returns the created itinerary
/// with any server-generated fields (like ID).
///
/// Example Usage:
/// dart
/// final useCase = CreateItinerary(repository);
/// final newItinerary = Itinerary(
///   id: '', // Will be generated
///   name: 'Paris Trip ',
///   destination: destination,
///   dateRange: dateRange,
///   items: [],
///   isStarter: false,
///   createdAt: DateTime.now(),
/// );
///
/// final result = await useCase(newItinerary);
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (created) => print('Created with ID: ${created.id}'),
/// );
///
class CreateItinerary {
  final ItineraryRepository _repository;

  /// Creates a new [CreateItinerary] use case
  ///
  /// The [repository] parameter is the itinerary repository to use.
  CreateItinerary(this._repository);

  /// Executes the use case
  ///
  /// The [itinerary] parameter is the itinerary to create.
  /// The ID field may be empty - the repository will generate it.
  ///
  /// Returns [Right(Itinerary)] with the created itinerary (including server-generated ID).
  /// Returns [Left(Failure)] if validation fails or creation fails.
  Future<Either<Failure, Itinerary>> call(Itinerary itinerary) async {
    // Validate itinerary before creating
    if (!itinerary.isValid) {
      return left(Failure.validation(
        message:
            'Itinerary must have a name, valid destination, date range, and at least one item',
      ));
    }

    return await _repository.createItinerary(itinerary);
  }
}
