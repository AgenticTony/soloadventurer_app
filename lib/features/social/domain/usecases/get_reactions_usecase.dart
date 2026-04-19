import '../entities/reaction.dart';
import '../entities/reaction_summary.dart';
import '../repositories/reaction_repository.dart';

/// Use case for fetching reaction summary for a target
class GetReactionsUseCase {
  final ReactionRepository _repository;

  const GetReactionsUseCase(this._repository);

  /// Execute: returns reaction summary for the given target
  Future<ReactionSummary> call({
    required String targetId,
    required ReactionTargetType targetType,
  }) =>
      _repository.getReactions(targetId, targetType);
}
