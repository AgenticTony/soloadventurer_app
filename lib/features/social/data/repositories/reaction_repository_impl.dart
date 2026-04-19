import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import '../../domain/entities/reaction.dart';
import '../../domain/entities/reaction_summary.dart';
import '../../domain/repositories/reaction_repository.dart';
import '../datasources/reaction_remote_data_source.dart';

/// Implementation of [ReactionRepository] using Supabase
class ReactionRepositoryImpl implements ReactionRepository {
  final ReactionRemoteDataSource _remoteDataSource;

  ReactionRepositoryImpl({required ReactionRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  String _requireCurrentUserId() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw const UnauthorizedException(
        message: 'User must be authenticated to react',
      );
    }
    return userId;
  }

  @override
  Future<ReactionSummary> getReactions(
    String targetId,
    ReactionTargetType targetType,
  ) async {
    final models = await _remoteDataSource.getReactions(targetId, targetType);
    final userId = _requireCurrentUserId();

    // Count reactions by type
    final counts = <ReactionType, int>{};
    for (final model in models) {
      counts[model.reaction] = (counts[model.reaction] ?? 0) + 1;
    }

    // Find user's reaction
    ReactionType? userReaction;
    try {
      final userModel = await _remoteDataSource.getUserReaction(
        userId: userId,
        targetId: targetId,
        targetType: targetType,
      );
      userReaction = userModel?.reaction;
    } catch (_) {
      userReaction = null;
    }

    return ReactionSummary(
      targetId: targetId,
      targetType: targetType,
      counts: counts,
      userReaction: userReaction,
    );
  }

  @override
  Future<void> toggleReaction({
    required String targetId,
    required ReactionTargetType targetType,
    required ReactionType reaction,
  }) async {
    final userId = _requireCurrentUserId();
    final existing = await _remoteDataSource.getUserReaction(
      userId: userId,
      targetId: targetId,
      targetType: targetType,
    );

    if (existing != null) {
      await _remoteDataSource.removeReaction(
        userId: userId,
        targetId: targetId,
        targetType: targetType,
      );
    } else {
      await _remoteDataSource.addReaction(
        userId: userId,
        targetId: targetId,
        targetType: targetType,
        reaction: reaction,
      );
    }
  }

  @override
  Future<ReactionType?> getUserReaction({
    required String targetId,
    required ReactionTargetType targetType,
  }) async {
    final userId = _requireCurrentUserId();
    final model = await _remoteDataSource.getUserReaction(
      userId: userId,
      targetId: targetId,
      targetType: targetType,
    );
    return model?.reaction;
  }

  @override
  Future<Map<ReactionType, int>> getReactionCounts(
    String targetId,
    ReactionTargetType targetType,
  ) async {
    final models = await _remoteDataSource.getReactions(targetId, targetType);
    final counts = <ReactionType, int>{};
    for (final model in models) {
      counts[model.reaction] = (counts[model.reaction] ?? 0) + 1;
    }
    return counts;
  }
}
