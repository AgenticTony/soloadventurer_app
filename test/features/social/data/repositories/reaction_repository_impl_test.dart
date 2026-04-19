import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/data/datasources/reaction_remote_data_source.dart';
import 'package:soloadventurer/features/social/data/models/reaction_model.dart';
import 'package:soloadventurer/features/social/data/repositories/reaction_repository_impl.dart';
import 'package:soloadventurer/features/social/domain/entities/reaction.dart';

/// Fake implementation of [ReactionRemoteDataSource] for testing
class FakeReactionRemoteDataSource implements ReactionRemoteDataSource {
  /// Reactions stored in memory
  final List<ReactionModel> storedReactions = [];

  /// Tracks whether removeReaction was called
  bool removeReactionCalled = false;

  /// Tracks whether addReaction was called
  bool addReactionCalled = false;

  @override
  Future<List<ReactionModel>> getReactions(
    String targetId,
    ReactionTargetType targetType,
  ) async {
    return storedReactions
        .where((r) => r.targetId == targetId && r.targetType == targetType)
        .toList();
  }

  @override
  Future<ReactionModel> addReaction({
    required String userId,
    required String targetId,
    required ReactionTargetType targetType,
    required ReactionType reaction,
  }) async {
    addReactionCalled = true;
    final model = ReactionModel(
      id: 'reaction-${storedReactions.length}',
      userId: userId,
      targetId: targetId,
      targetType: targetType,
      reaction: reaction,
      createdAt: DateTime(2026, 1, 1),
    );
    storedReactions.add(model);
    return model;
  }

  @override
  Future<void> removeReaction({
    required String userId,
    required String targetId,
    required ReactionTargetType targetType,
  }) async {
    removeReactionCalled = true;
    storedReactions.removeWhere(
      (r) =>
          r.userId == userId &&
          r.targetId == targetId &&
          r.targetType == targetType,
    );
  }

  @override
  Future<ReactionModel?> getUserReaction({
    required String userId,
    required String targetId,
    required ReactionTargetType targetType,
  }) async {
    try {
      return storedReactions.firstWhere(
        (r) =>
            r.userId == userId &&
            r.targetId == targetId &&
            r.targetType == targetType,
      );
    } catch (_) {
      return null;
    }
  }
}

void main() {
  late FakeReactionRemoteDataSource fakeDataSource;
  late ReactionRepositoryImpl repository;

  setUp(() {
    fakeDataSource = FakeReactionRemoteDataSource();
    repository = ReactionRepositoryImpl(
      remoteDataSource: fakeDataSource,
    );
  });

  group('ReactionRepositoryImpl', () {
    group('getReactionCounts', () {
      test('returns empty map when no reactions exist', () async {
        // getReactionCounts does not call _requireCurrentUserId, so it is safe
        final counts = await repository.getReactionCounts(
          'journal-1',
          ReactionTargetType.journal,
        );

        expect(counts, isEmpty);
      });

      test('counts reactions by type correctly', () async {
        // Seed data directly into the fake data source
        await fakeDataSource.addReaction(
          userId: 'user-a',
          targetId: 'journal-1',
          targetType: ReactionTargetType.journal,
          reaction: ReactionType.like,
        );
        await fakeDataSource.addReaction(
          userId: 'user-b',
          targetId: 'journal-1',
          targetType: ReactionTargetType.journal,
          reaction: ReactionType.like,
        );
        await fakeDataSource.addReaction(
          userId: 'user-c',
          targetId: 'journal-1',
          targetType: ReactionTargetType.journal,
          reaction: ReactionType.love,
        );

        final counts = await repository.getReactionCounts(
          'journal-1',
          ReactionTargetType.journal,
        );

        expect(counts[ReactionType.like], 2);
        expect(counts[ReactionType.love], 1);
        expect(counts.containsKey(ReactionType.inspire), isFalse);
      });

      test('separates counts by target type', () async {
        await fakeDataSource.addReaction(
          userId: 'user-a',
          targetId: 'target-1',
          targetType: ReactionTargetType.journal,
          reaction: ReactionType.like,
        );
        await fakeDataSource.addReaction(
          userId: 'user-b',
          targetId: 'target-1',
          targetType: ReactionTargetType.comment,
          reaction: ReactionType.inspire,
        );

        final journalCounts = await repository.getReactionCounts(
          'target-1',
          ReactionTargetType.journal,
        );
        final commentCounts = await repository.getReactionCounts(
          'target-1',
          ReactionTargetType.comment,
        );

        expect(journalCounts[ReactionType.like], 1);
        expect(journalCounts.containsKey(ReactionType.inspire), isFalse);
        expect(commentCounts[ReactionType.inspire], 1);
        expect(commentCounts.containsKey(ReactionType.like), isFalse);
      });

      test('counts all four reaction types', () async {
        for (final reaction in ReactionType.values) {
          await fakeDataSource.addReaction(
            userId: 'user-${reaction.name}',
            targetId: 'target-all',
            targetType: ReactionTargetType.journal,
            reaction: reaction,
          );
        }

        final counts = await repository.getReactionCounts(
          'target-all',
          ReactionTargetType.journal,
        );

        expect(counts.length, 4);
        for (final reaction in ReactionType.values) {
          expect(counts[reaction], 1);
        }
      });
    });

    group('data source delegation', () {
      test('getReactionCounts delegates to remote data source getReactions',
          () async {
        await fakeDataSource.addReaction(
          userId: 'user-a',
          targetId: 'journal-1',
          targetType: ReactionTargetType.journal,
          reaction: ReactionType.helpful,
        );

        // Calling getReactionCounts should read from the data source
        final counts = await repository.getReactionCounts(
          'journal-1',
          ReactionTargetType.journal,
        );
        expect(counts[ReactionType.helpful], 1);
      });
    });
  });
}
