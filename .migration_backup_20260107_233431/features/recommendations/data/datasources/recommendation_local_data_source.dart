import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation_request.dart';

/// Local data source for recommendations
///
/// Handles persistence of saved recommendations, dismissed items,
/// and user feedback.
abstract class RecommendationLocalDataSource {
  /// Saves a recommendation for later
  Future<PersonalizedRecommendation> saveRecommendation(
    String userId,
    PersonalizedRecommendation recommendation,
  );

  /// Gets all saved recommendations for a user
  Future<List<PersonalizedRecommendation>> getSavedRecommendations(
    String userId,
  );

  /// Dismisses a recommendation
  Future<void> dismissRecommendation(
    String userId,
    String recommendationId,
  );

  /// Records user feedback on a recommendation
  Future<void> recordFeedback(
    String recommendationId,
    RecommendationFeedback feedback,
  );

  /// Gets dismissed recommendation IDs for a user
  Future<Set<String>> getDismissedRecommendations(String userId);

  /// Clears old dismissed recommendations
  Future<int> clearOldDismissals({
    required String userId,
    required Duration olderThan,
  });
}

/// Implementation using in-memory storage
///
/// In production, this would use SQLite or Hive for persistence.
class RecommendationLocalDataSourceImpl implements RecommendationLocalDataSource {
  // In-memory storage - keyed by userId for proper user isolation
  final Map<String, Map<String, PersonalizedRecommendation>> _saved = {};
  final Map<String, Set<String>> _dismissed = {};
  final Map<String, RecommendationFeedback> _feedback = {};

  @override
  Future<PersonalizedRecommendation> saveRecommendation(
    String userId,
    PersonalizedRecommendation recommendation,
  ) async {
    _saved.putIfAbsent(userId, () => {});
    _saved[userId]![recommendation.id] = recommendation;
    return recommendation;
  }

  @override
  Future<List<PersonalizedRecommendation>> getSavedRecommendations(
    String userId,
  ) async {
    return _saved[userId]?.values.toList() ?? [];
  }

  @override
  Future<void> dismissRecommendation(
    String userId,
    String recommendationId,
  ) async {
    // Add to dismissed list for this specific user
    _dismissed.putIfAbsent(userId, () => <String>{});
    _dismissed[userId]!.add(recommendationId);

    // Remove from saved for this user
    _saved[userId]?.remove(recommendationId);
  }

  @override
  Future<void> recordFeedback(
    String recommendationId,
    RecommendationFeedback feedback,
  ) async {
    _feedback[recommendationId] = feedback;
  }

  @override
  Future<Set<String>> getDismissedRecommendations(String userId) async {
    return _dismissed[userId] ?? {};
  }

  @override
  Future<int> clearOldDismissals({
    required String userId,
    required Duration olderThan,
  }) async {
    final dismissedSet = _dismissed[userId];
    if (dismissedSet == null) return 0;

    // In a real implementation, would track timestamps for dismissals
    // For now, just clear all
    final count = dismissedSet.length;
    dismissedSet.clear();
    return count;
  }

  /// Checks if a recommendation is dismissed
  bool isDismissed(String userId, String recommendationId) {
    return _dismissed[userId]?.contains(recommendationId) ?? false;
  }

  /// Gets feedback for a recommendation
  RecommendationFeedback? getFeedback(String recommendationId) {
    return _feedback[recommendationId];
  }
}
