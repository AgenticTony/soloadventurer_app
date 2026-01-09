import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation_request.dart';
import 'package:soloadventurer/features/recommendations/domain/services/recommendation_service.dart';

/// Use case for getting recommendations for a specific date
///
/// This provides recommendations filtered and optimized for a particular
/// day of the trip, considering weather, scheduling, and proximity.
class GetRecommendationsForDate {
  final RecommendationService _service;

  GetRecommendationsForDate(this._service);

  /// Executes the use case
  ///
  /// [request] The recommendation request with all context
  /// [specificDate] The specific date to get recommendations for
  ///
  /// Returns [Right] with list of recommendations for that date
  /// Returns [Left] with failure if recommendations cannot be generated
  Future<Either<Failure, List<PersonalizedRecommendation>>> call({
    required RecommendationRequest request,
    required DateTime specificDate,
  }) async {
    // Validate date is within trip range
    if (specificDate.isBefore(request.tripDates.start) ||
        specificDate.isAfter(request.tripDates.end)) {
      return left(Failure.validation(
        message: 'Requested date is outside the trip date range',
      ));
    }

    // Get date-specific recommendations
    return await _service.getRecommendationsForDate(request, specificDate);
  }
}
