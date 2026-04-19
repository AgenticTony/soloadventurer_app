import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/repositories/itinerary_repository.dart';

/// Use case for getting a single itinerary by ID
///
/// This use case encapsulates the business logic for retrieving an itinerary
/// from the repository. It handles error cases and returns a type-safe result.
///
/// Example Usage:
/// dart
/// final useCase = GetItinerary(repository);
/// final result = await useCase('itinerary-');
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (itinerary) => print('Found: ${itinerary.name}'),
/// );
///
class GetItinerary {
  final ItineraryRepository _repository;

  /// Creates a new [GetItinerary] use case
  ///
  /// The [repository] parameter is the itinerary repository to use.
  GetItinerary(this._repository);

  /// Executes the use case
  ///
  /// The [id] parameter is the unique identifier of the itinerary to retrieve.
  ///
  /// Returns [Right(Itinerary)] if the itinerary is found.
  /// Returns [Left(Failure)] if an error occurs (not found, network error, etc.).
  Future<Either<Failure, Itinerary>> call(String id) async {
    return await _repository.getItinerary(id);
  }
}
