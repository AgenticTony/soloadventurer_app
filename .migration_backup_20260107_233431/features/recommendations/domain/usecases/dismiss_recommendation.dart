import 'package:dartz/dartz.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/recommendation_repository.dart';

/// Use case for dismissing a recommendation
///
/// Removes a recommendation from the user's list and records
/// that they're not interested, which helps improve future recommendations.
class DismissRecommendation {
  final RecommendationRepository _repository;

  DismissRecommendation(this._repository);

  /// Executes the use case
  ///
  /// [userId] The user's ID
  /// [recommendationId] The ID of the recommendation to dismiss
  ///
  /// Returns [Right] unit on success
  /// Returns [Left] with failure if cannot dismiss
  Future<Either<Failure, Unit>> call(
    String userId,
    String recommendationId,
  ) async {
    return await _repository.dismissRecommendation(userId, recommendationId);
  }
}
