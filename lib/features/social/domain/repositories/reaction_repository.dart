import '../entities/reaction.dart';
import '../entities/reaction_summary.dart';

/// Repository interface for reaction-related operations
abstract class ReactionRepository {
  /// Get reaction summary for a target (journal or comment)
  Future<ReactionSummary> getReactions(
    String targetId,
    ReactionTargetType targetType,
  );

  /// Toggle a reaction on a target (add if not present, remove if exists)
  Future<void> toggleReaction({
    required String targetId,
    required ReactionTargetType targetType,
    required ReactionType reaction,
  });

  /// Check if current user has reacted on a target
  Future<ReactionType?> getUserReaction({
    required String targetId,
    required ReactionTargetType targetType,
  });

  /// Get reaction counts grouped by type for a target
  Future<Map<ReactionType, int>> getReactionCounts(
    String targetId,
    ReactionTargetType targetType,
  );
}
