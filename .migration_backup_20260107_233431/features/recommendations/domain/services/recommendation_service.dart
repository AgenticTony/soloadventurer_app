import 'package:dartz/dartz.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation_request.dart';

/// Service for generating personalized recommendations
///
/// This service is the core of the recommendation engine, taking user
/// preferences, trip context, and real-time conditions to generate
/// highly relevant suggestions.
abstract class RecommendationService {
  /// Gets personalized recommendations for a trip
  ///
  /// [request] Complete recommendation request with context
  ///
  /// Returns [Right] with list of personalized recommendations sorted by relevance
  /// Returns [Left] with failure if recommendations cannot be generated
  Future<Either<Failure, List<PersonalizedRecommendation>>>
      getPersonalizedRecommendations(RecommendationRequest request);

  /// Gets recommendations optimized for a specific date
  ///
  /// [request] Complete recommendation request with context
  /// [specificDate] The date to optimize for
  ///
  /// Returns [Right] with recommendations for that date
  /// Returns [Left] with failure if recommendations cannot be generated
  Future<Either<Failure, List<PersonalizedRecommendation>>>
      getRecommendationsForDate(
    RecommendationRequest request,
    DateTime specificDate,
  );

  /// Gets collaborative filtering recommendations
  ///
  /// Finds recommendations based on what similar travelers enjoyed
  /// at the same destination.
  ///
  /// [userId] Current user's ID
  /// [destination] Destination to get recommendations for
  /// [limit] Maximum number of recommendations
  ///
  /// Returns [Right] with collaborative recommendations
  /// Returns [Left] with failure if unavailable
  Future<Either<Failure, List<PersonalizedRecommendation>>>
      getCollaborativeRecommendations({
    required String userId,
    required String destination,
    required int limit,
  });

  /// Gets trending recommendations at a destination
  ///
  /// Returns activities and places that are currently popular
  /// with travelers.
  ///
  /// [destination] Destination to get trends for
  /// [limit] Maximum number of recommendations
  ///
  /// Returns [Right] with trending recommendations
  /// Returns [Left] with failure if unavailable
  Future<Either<Failure, List<PersonalizedRecommendation>>>
      getTrendingRecommendations({
    required String destination,
    required int limit,
  });
}
