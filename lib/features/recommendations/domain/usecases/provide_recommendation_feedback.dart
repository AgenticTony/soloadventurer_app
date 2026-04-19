import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation_request.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/recommendation_repository.dart';

/// Use case for providing feedback on a recommendation
///
/// Records user feedback which is used to improve future recommendations
/// through machine learning and preference refinement.
class ProvideRecommendationFeedback {
  final RecommendationRepository _repository;

  ProvideRecommendationFeedback(this._repository);

  /// Executes the use case
  ///
  /// [recommendationId] The ID of the recommendation
  /// [feedback] The user's feedback
  ///
  /// Returns [Right] unit on success
  /// Returns [Left] with failure if feedback cannot be recorded
  Future<Either<Failure, Unit>> call({
    required String recommendationId,
    required RecommendationFeedback feedback,
  }) async {
    return await _repository.recordFeedback(
      recommendationId,
      feedback,
    );
  }
}
