import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/reaction.dart';
import 'package:soloadventurer/features/social/domain/entities/reaction_summary.dart';
import 'package:soloadventurer/features/social/domain/repositories/reaction_repository.dart';
import 'package:soloadventurer/features/social/domain/usecases/toggle_reaction_usecase.dart';

/// Fake implementation of [ReactionRepository] for testing
class FakeReactionRepository implements ReactionRepository {
  /// Tracks whether toggleReaction was called
  bool toggleReactionCalled = false;

  /// Captured parameters from toggleReaction
  ({
    String targetId,
    ReactionTargetType targetType,
    ReactionType reaction,
  })? toggleParams;

  @override
  Future<void> toggleReaction({
    required String targetId,
    required ReactionTargetType targetType,
    required ReactionType reaction,
  }) async {
    toggleReactionCalled = true;
    toggleParams = (
      targetId: targetId,
      targetType: targetType,
      reaction: reaction,
    );
  }

  @override
  Future<ReactionSummary> getReactions(
    String targetId,
    ReactionTargetType targetType,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<ReactionType?> getUserReaction({
    required String targetId,
    required ReactionTargetType targetType,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<ReactionType, int>> getReactionCounts(
    String targetId,
    ReactionTargetType targetType,
  ) async {
    throw UnimplementedError();
  }
}

void main() {
  late FakeReactionRepository fakeRepository;
  late ToggleReactionUseCase useCase;

  setUp(() {
    fakeRepository = FakeReactionRepository();
    useCase = ToggleReactionUseCase(fakeRepository);
  });

  group('ToggleReactionUseCase', () {
    test('calls repository toggleReaction with correct parameters', () async {
      await useCase(
        targetId: 'journal-1',
        targetType: ReactionTargetType.journal,
        reaction: ReactionType.like,
      );

      expect(fakeRepository.toggleReactionCalled, isTrue);
      expect(fakeRepository.toggleParams, isNotNull);
      expect(fakeRepository.toggleParams!.targetId, 'journal-1');
      expect(
        fakeRepository.toggleParams!.targetType,
        ReactionTargetType.journal,
      );
      expect(fakeRepository.toggleParams!.reaction, ReactionType.like);
    });

    test('passes different reaction types correctly', () async {
      await useCase(
        targetId: 'comment-2',
        targetType: ReactionTargetType.comment,
        reaction: ReactionType.love,
      );

      expect(fakeRepository.toggleParams!.targetId, 'comment-2');
      expect(
        fakeRepository.toggleParams!.targetType,
        ReactionTargetType.comment,
      );
      expect(fakeRepository.toggleParams!.reaction, ReactionType.love);
    });

    test('passes inspire reaction type', () async {
      await useCase(
        targetId: 'journal-3',
        targetType: ReactionTargetType.journal,
        reaction: ReactionType.inspire,
      );

      expect(fakeRepository.toggleParams!.reaction, ReactionType.inspire);
    });

    test('passes helpful reaction type', () async {
      await useCase(
        targetId: 'journal-4',
        targetType: ReactionTargetType.journal,
        reaction: ReactionType.helpful,
      );

      expect(fakeRepository.toggleParams!.reaction, ReactionType.helpful);
    });
  });
}
