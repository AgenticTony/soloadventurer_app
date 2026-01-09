import 'package:dartz/dartz.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/repositories/itinerary_repository.dart';

/// Use case for getting all itineraries, optionally filtered by user
///
/// This use case retrieves itineraries from the repository with optional
/// user filtering. Useful for displaying a user's trip collection.
///
/// Example Usage:
/// dart
/// final useCase = GetItineraries(repository);
/// final result = await useCase(userId: 'user-');
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (itineraries) => print('Found ${itineraries.length} itineraries'),
/// );
/// 
class GetItineraries {
  final ItineraryRepository _repository;

  /// Creates a new [GetItineraries] use case
  ///
  /// The [repository] parameter is the itinerary repository to use.
  GetItineraries(this._repository);

  /// Executes the use case
  ///
  /// The [userId] parameter is optional - if provided, filters to that user's itineraries.
  /// If null, returns all itineraries (subject to repository behavior).
  ///
  /// Returns [Right(List<Itinerary>)] with the list of itineraries.
  /// Returns [Left(Failure)] if an error occurs.
  Future<Either<Failure, List<Itinerary>>> call({String? userId}) async {
    return await _repository.getItineraries(userId: userId);
  }
}
