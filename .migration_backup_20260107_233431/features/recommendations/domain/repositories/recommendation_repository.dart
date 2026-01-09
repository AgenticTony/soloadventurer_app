import 'package:dartz/dartz.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation_request.dart';

/// Repository for managing recommendations
///
/// Handles persistence, retrieval, and user interactions with
/// recommendations (save, dismiss, feedback).
abstract class RecommendationRepository {
  /// Saves a recommendation for later viewing
  ///
  /// [userId] The user's ID
  /// [recommendation] The recommendation to save
  ///
  /// Returns [Right] with the saved recommendation
  /// Returns [Left] with failure if save fails
  Future<Either<Failure, PersonalizedRecommendation>> saveRecommendation(
    String userId,
    PersonalizedRecommendation recommendation,
  );

  /// Gets all saved recommendations for a user
  ///
  /// [userId] The user's ID
  ///
  /// Returns [Right] with list of saved recommendations
  /// Returns [Left] with failure if retrieval fails
  Future<Either<Failure, List<PersonalizedRecommendation>>>
      getSavedRecommendations(String userId);

  /// Dismisses a recommendation
  ///
  /// Removes the recommendation from view and records dismissal
  /// to improve future recommendations.
  ///
  /// [userId] The user's ID
  /// [recommendationId] The ID of the recommendation to dismiss
  ///
  /// Returns [Right] unit on success
  /// Returns [Left] with failure if dismiss fails
  Future<Either<Failure, Unit>> dismissRecommendation(
    String userId,
    String recommendationId,
  );

  /// Records user feedback on a recommendation
  ///
  /// [recommendationId] The ID of the recommendation
  /// [feedback] The user's feedback
  ///
  /// Returns [Right] unit on success
  /// Returns [Left] with failure if recording fails
  Future<Either<Failure, Unit>> recordFeedback(
    String recommendationId,
    RecommendationFeedback feedback,
  );

  /// Gets dismissed recommendations for filtering
  ///
  /// [userId] The user's ID
  ///
  /// Returns [Right] with set of dismissed recommendation IDs
  /// Returns [Left] with failure if retrieval fails
  Future<Either<Failure, Set<String>>> getDismissedRecommendations(
    String userId,
  );

  /// Clears old dismissed recommendations
  ///
  /// Removes dismissed recommendations older than the specified duration.
  ///
  /// [userId] The user's ID
  /// [olderThan] Only clear dismissals older than this
  ///
  /// Returns [Right] with count of cleared items
  /// Returns [Left] with failure if clear fails
  Future<Either<Failure, int>> clearOldDismissals({
    required String userId,
    required Duration olderThan,
  });
}
