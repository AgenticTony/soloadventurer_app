import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/recommendation_repository.dart';

/// Use case for saving a recommendation for later
///
/// Allows users to bookmark recommendations they're interested in
/// but don't want to add to their itinerary yet.
class SaveRecommendation {
  final RecommendationRepository _repository;

  SaveRecommendation(this._repository);

  /// Executes the use case
  ///
  /// [userId] The user's ID
  /// [recommendation] The recommendation to save
  ///
  /// Returns [Right] with the saved recommendation (now marked as saved)
  /// Returns [Left] with failure if cannot save
  Future<Either<Failure, PersonalizedRecommendation>> call(
    String userId,
    PersonalizedRecommendation recommendation,
  ) async {
    // Mark as saved
    final saved = recommendation.copyWith(isSaved: true);

    // Persist
    return await _repository.saveRecommendation(userId, saved);
  }
}
