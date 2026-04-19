import '../entities/reaction.dart';
import '../repositories/reaction_repository.dart';

/// Use case for toggling a reaction on a target
class ToggleReactionUseCase {
  final ReactionRepository _repository;

  const ToggleReactionUseCase(this._repository);

  /// Execute: adds or removes the reaction
  Future<void> call({
    required String targetId,
    required ReactionTargetType targetType,
    required ReactionType reaction,
  }) =>
      _repository.toggleReaction(
        targetId: targetId,
        targetType: targetType,
        reaction: reaction,
      );
}
