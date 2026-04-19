import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/reaction_remote_data_source.dart';
import '../data/repositories/reaction_repository_impl.dart';
import '../domain/entities/reaction.dart';
import '../domain/entities/reaction_summary.dart';
import '../domain/repositories/reaction_repository.dart';
import '../domain/usecases/get_reactions_usecase.dart';
import '../domain/usecases/toggle_reaction_usecase.dart';

part 'reaction_providers.g.dart';

// ============================================================
// Data Source
// ============================================================

@Riverpod(keepAlive: true)
ReactionRemoteDataSource reactionRemoteDataSource(Ref ref) {
  return ReactionRemoteDataSourceImpl(client: Supabase.instance.client);
}

// ============================================================
// Repository
// ============================================================

@Riverpod(keepAlive: true)
ReactionRepository reactionRepository(Ref ref) {
  return ReactionRepositoryImpl(
    remoteDataSource: ref.read(reactionRemoteDataSourceProvider),
  );
}

// ============================================================
// Use Cases
// ============================================================

@riverpod
ToggleReactionUseCase toggleReactionUseCase(Ref ref) =>
    ToggleReactionUseCase(ref.read(reactionRepositoryProvider));

@riverpod
GetReactionsUseCase getReactionsUseCase(Ref ref) =>
    GetReactionsUseCase(ref.read(reactionRepositoryProvider));

// ============================================================
// Reaction Summary Notifier — per target
// ============================================================

@riverpod
class ReactionSummaryNotifier extends _$ReactionSummaryNotifier {
  late String _targetId;
  late ReactionTargetType _targetType;

  @override
  Future<ReactionSummary> build(
    String targetId,
    ReactionTargetType targetType,
  ) async {
    _targetId = targetId;
    _targetType = targetType;
    final useCase = ref.read(getReactionsUseCaseProvider);
    return useCase(targetId: targetId, targetType: targetType);
  }

  /// Toggle a reaction on this target
  Future<void> toggleReaction(ReactionType reaction) async {
    final useCase = ref.read(toggleReactionUseCaseProvider);
    final current = state.value;

    await useCase(
      targetId: _targetId,
      targetType: _targetType,
      reaction: reaction,
    );

    if (current != null && current.userReaction == reaction) {
      // Removing reaction
      final newCounts = Map<ReactionType, int>.from(current.counts);
      final count = (newCounts[reaction] ?? 1) - 1;
      if (count <= 0) {
        newCounts.remove(reaction);
      } else {
        newCounts[reaction] = count;
      }
      state = AsyncValue.data(current.copyWith(
        counts: newCounts,
        userReaction: null,
      ));
    } else {
      // Adding or switching reaction
      final newCounts = Map<ReactionType, int>.from(
        current?.counts ?? <ReactionType, int>{},
      );
      final oldReaction = current?.userReaction;
      if (oldReaction != null && oldReaction != reaction) {
        final oldCount = (newCounts[oldReaction] ?? 1) - 1;
        if (oldCount <= 0) {
          newCounts.remove(oldReaction);
        } else {
          newCounts[oldReaction] = oldCount;
        }
      }
      newCounts[reaction] = (newCounts[reaction] ?? 0) + 1;
      state = AsyncValue.data(ReactionSummary(
        targetId: _targetId,
        targetType: _targetType,
        counts: newCounts,
        userReaction: reaction,
      ));
    }
  }
}
