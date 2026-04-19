import 'package:equatable/equatable.dart';
import 'reaction.dart';

/// Aggregated reaction counts for a target (journal or comment)
class ReactionSummary extends Equatable {
  const ReactionSummary({
    required this.targetId,
    required this.targetType,
    required this.counts,
    this.userReaction,
  });

  /// The target ID (journal or comment)
  final String targetId;

  /// Whether this is a journal or comment reaction
  final ReactionTargetType targetType;

  /// Count per reaction type
  final Map<ReactionType, int> counts;

  /// The current user's reaction, if any
  final ReactionType? userReaction;

  /// Total count across all reaction types
  int get total => counts.values.fold(0, (sum, count) => sum + count);

  @override
  List<Object?> get props => [targetId, targetType, counts, userReaction];

  ReactionSummary copyWith({
    String? targetId,
    ReactionTargetType? targetType,
    Map<ReactionType, int>? counts,
    ReactionType? userReaction,
  }) {
    return ReactionSummary(
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      counts: counts ?? this.counts,
      userReaction: userReaction ?? this.userReaction,
    );
  }
}
