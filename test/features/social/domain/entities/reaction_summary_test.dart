import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/reaction.dart';
import 'package:soloadventurer/features/social/domain/entities/reaction_summary.dart';

void main() {
  final tDateTime = DateTime(2026, 1, 15);

  group('ReactionSummary', () {
    test('constructs with required fields', () {
      final summary = ReactionSummary(
        targetId: 'target-1',
        targetType: ReactionTargetType.journal,
        counts: {ReactionType.like: 5, ReactionType.love: 3},
        userReaction: ReactionType.like,
      );

      expect(summary.targetId, 'target-1');
      expect(summary.targetType, ReactionTargetType.journal);
      expect(summary.counts, {ReactionType.like: 5, ReactionType.love: 3});
      expect(summary.userReaction, ReactionType.like);
    });

    test('constructs with null userReaction', () {
      final summary = ReactionSummary(
        targetId: 'target-1',
        targetType: ReactionTargetType.comment,
        counts: {},
      );

      expect(summary.userReaction, isNull);
    });

    test('total getter sums all counts', () {
      final summary = ReactionSummary(
        targetId: 'target-1',
        targetType: ReactionTargetType.journal,
        counts: {ReactionType.like: 5, ReactionType.love: 3, ReactionType.inspire: 2},
      );

      expect(summary.total, 10);
    });

    test('total getter returns 0 for empty counts', () {
      final summary = ReactionSummary(
        targetId: 'target-1',
        targetType: ReactionTargetType.journal,
        counts: {},
      );

      expect(summary.total, 0);
    });

    group('copyWith', () {
      final original = ReactionSummary(
        targetId: 'target-1',
        targetType: ReactionTargetType.journal,
        counts: {ReactionType.like: 5},
        userReaction: ReactionType.like,
      );

      test('copies all fields when specified', () {
        final copied = original.copyWith(
          targetId: 'target-2',
          targetType: ReactionTargetType.comment,
          counts: {ReactionType.love: 10},
          userReaction: ReactionType.love,
        );

        expect(copied.targetId, 'target-2');
        expect(copied.targetType, ReactionTargetType.comment);
        expect(copied.counts, {ReactionType.love: 10});
        expect(copied.userReaction, ReactionType.love);
      });

      test('retains original values when no arguments given', () {
        final copied = original.copyWith();

        expect(copied.targetId, original.targetId);
        expect(copied.targetType, original.targetType);
        expect(copied.counts, original.counts);
        expect(copied.userReaction, original.userReaction);
      });
    });

    group('equality', () {
      final summaryA = ReactionSummary(
        targetId: 'target-1',
        targetType: ReactionTargetType.journal,
        counts: {ReactionType.like: 5},
        userReaction: ReactionType.like,
      );

      test('equal when all fields match', () {
        final summaryB = ReactionSummary(
          targetId: 'target-1',
          targetType: ReactionTargetType.journal,
          counts: {ReactionType.like: 5},
          userReaction: ReactionType.like,
        );

        expect(summaryA, equals(summaryB));
      });

      test('not equal when targetId differs', () {
        final summaryB = ReactionSummary(
          targetId: 'target-2',
          targetType: ReactionTargetType.journal,
          counts: {ReactionType.like: 5},
          userReaction: ReactionType.like,
        );

        expect(summaryA, isNot(equals(summaryB)));
      });

      test('not equal when counts differ', () {
        final summaryB = ReactionSummary(
          targetId: 'target-1',
          targetType: ReactionTargetType.journal,
          counts: {ReactionType.like: 10},
          userReaction: ReactionType.like,
        );

        expect(summaryA, isNot(equals(summaryB)));
      });

      test('not equal when userReaction differs', () {
        final summaryB = ReactionSummary(
          targetId: 'target-1',
          targetType: ReactionTargetType.journal,
          counts: {ReactionType.like: 5},
          userReaction: ReactionType.love,
        );

        expect(summaryA, isNot(equals(summaryB)));
      });
    });
  });
}
