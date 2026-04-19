import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation_request.dart';
import 'package:soloadventurer/features/recommendations/domain/services/recommendation_service.dart';

/// Use case for getting personalized recommendations
///
/// This use case coordinates the recommendation service to provide
/// personalized suggestions based on user preferences, trip context,
/// and real-time conditions like weather.
class GetPersonalizedRecommendations {
  final RecommendationService _service;

  GetPersonalizedRecommendations(this._service);

  /// Executes the use case
  ///
  /// [request] The recommendation request with all context
  ///
  /// Returns [Right] with list of personalized recommendations
  /// Returns [Left] with failure if recommendations cannot be generated
  Future<Either<Failure, List<PersonalizedRecommendation>>> call(
    RecommendationRequest request,
  ) async {
    // Validate request
    if (!request.isValid) {
      return left(Failure.validation(
        message: 'Invalid recommendation request: missing required fields',
      ));
    }

    // Get recommendations from service
    return await _service.getPersonalizedRecommendations(request);
  }
}
