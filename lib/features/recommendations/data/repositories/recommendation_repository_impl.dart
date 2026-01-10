import 'package:fpdart/fpdart.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/recommendation_local_data_source.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation_request.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/recommendation_repository.dart';

/// Implementation of recommendation repository
///
/// Handles persistence, retrieval, and user interactions with
/// recommendations (save, dismiss, feedback).
class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationLocalDataSource _localDataSource;

  RecommendationRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, PersonalizedRecommendation>> saveRecommendation(
    String userId,
    PersonalizedRecommendation recommendation,
  ) async {
    try {
      final saved = await _localDataSource.saveRecommendation(
        userId,
        recommendation,
      );
      return right(saved);
    } on RepositoryException catch (e) {
      return left(Failure.cache(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PersonalizedRecommendation>>>
      getSavedRecommendations(String userId) async {
    try {
      final saved = await _localDataSource.getSavedRecommendations(userId);
      return right(saved);
    } on RepositoryException catch (e) {
      return left(Failure.cache(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> dismissRecommendation(
    String userId,
    String recommendationId,
  ) async {
    try {
      await _localDataSource.dismissRecommendation(userId, recommendationId);
      return right(unit);
    } on RepositoryException catch (e) {
      return left(Failure.cache(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> recordFeedback(
    String recommendationId,
    RecommendationFeedback feedback,
  ) async {
    try {
      await _localDataSource.recordFeedback(recommendationId, feedback);
      return right(unit);
    } on RepositoryException catch (e) {
      return left(Failure.cache(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> getDismissedRecommendations(
    String userId,
  ) async {
    try {
      final dismissed =
          await _localDataSource.getDismissedRecommendations(userId);
      return right(dismissed);
    } on RepositoryException catch (e) {
      return left(Failure.cache(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> clearOldDismissals({
    required String userId,
    required Duration olderThan,
  }) async {
    try {
      final count = await _localDataSource.clearOldDismissals(
        userId: userId,
        olderThan: olderThan,
      );
      return right(count);
    } on RepositoryException catch (e) {
      return left(Failure.cache(message: e.message));
    } catch (e) {
      return left(Failure.unknown(message: e.toString()));
    }
  }
}
