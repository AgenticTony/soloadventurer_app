import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/itinerary_repository.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';

/// Use case for adding a recommendation to the user's itinerary
///
/// Converts a recommendation into an itinerary item and adds it
/// to the user's trip plan.
class AddRecommendationToItinerary {
  final ItineraryRepository _itineraryRepo;

  AddRecommendationToItinerary(this._itineraryRepo);

  /// Executes the use case
  ///
  /// [itineraryId] The ID of the itinerary to add to
  /// [recommendation] The recommendation to add
  /// [scheduledAt] When to schedule this activity
  ///
  /// Returns [Right] with the created itinerary item
  /// Returns [Left] with failure if the item cannot be added
  Future<Either<Failure, ItineraryItem>> call({
    required String itineraryId,
    required PersonalizedRecommendation recommendation,
    required DateTime scheduledAt,
  }) async {
    // Convert recommendation to itinerary item
    final item = _convertToItineraryItem(recommendation, scheduledAt);

    // Add to itinerary
    return await _itineraryRepo.addItem(itineraryId, item);
  }

  /// Converts a recommendation to an itinerary item
  ItineraryItem _convertToItineraryItem(
    PersonalizedRecommendation recommendation,
    DateTime scheduledAt,
  ) {
    final activity = recommendation.activity;
    final metadata = recommendation.metadata;

    return ItineraryItem.activity(
      time: metadata.suggestedTime.toDateTime(scheduledAt),
      name: activity.name,
      description: activity.description,
      location: activity.location,
      durationHours: metadata.estimatedDuration.inHours.clamp(1, 24),
      cost: metadata.estimatedCost?.amount,
      bookingUrl: metadata.bookingUrl ?? activity.bookingUrl,
      note: 'Recommended because: ${recommendation.reasoning}',
    );
  }
}
