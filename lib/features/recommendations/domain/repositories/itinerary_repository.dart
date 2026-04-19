import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';

/// Repository for managing itinerary items
///
/// Used by the recommendations feature to add recommendations
/// to the user's itinerary.
abstract class ItineraryRepository {
  /// Adds an item to an itinerary
  ///
  /// [itineraryId] The ID of the itinerary
  /// [item] The item to add
  ///
  /// Returns [Right] with the added item
  /// Returns [Left] with failure if add fails
  Future<Either<Failure, ItineraryItem>> addItem(
    String itineraryId,
    ItineraryItem item,
  );

  /// Gets an itinerary
  ///
  /// [itineraryId] The ID of the itinerary
  ///
  /// Returns [Right] with the itinerary
  /// Returns [Left] with failure if not found
  Future<Either<Failure, dynamic>> getItinerary(String itineraryId);
}
