import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/reaction.dart';
import 'package:soloadventurer/features/social/domain/entities/reaction_summary.dart';
import 'package:soloadventurer/features/social/presentation/widgets/reaction_bar.dart';
import 'package:soloadventurer/features/social/providers/reaction_providers.dart';

/// Creates a [ReactionSummaryNotifier] that immediately resolves to [summary].
///
/// Overrides the generated provider so the widget tree receives deterministic
/// data without needing a real Supabase backend.
class _FakeReactionSummaryNotifier extends ReactionSummaryNotifier {
  _FakeReactionSummaryNotifier(this._summary);

  final ReactionSummary _summary;
  bool toggleCalled = false;
  ReactionType? toggledReaction;

  @override
  Future<ReactionSummary> build(
    String targetId,
    ReactionTargetType targetType,
  ) async {
    return _summary;
  }

  @override
  Future<void> toggleReaction(ReactionType reaction) async {
    toggleCalled = true;
    toggledReaction = reaction;
  }
}

/// A notifier whose [build] never completes, keeping the provider in loading.
class _LoadingReactionSummaryNotifier extends ReactionSummaryNotifier {
  @override
  Future<ReactionSummary> build(
    String targetId,
    ReactionTargetType targetType,
  ) {
    // Never complete — keeps AsyncValue in loading state.
    return Completer<ReactionSummary>().future;
  }
}

void main() {
  const targetId = 'journal-123';
  const targetType = ReactionTargetType.journal;

  /// Helper that wraps [ReactionBar] with the necessary providers.
  Widget _buildSubject({
    required ReactionSummary summary,
    List extraOverrides = const [],
  }) {
    final notifier = _FakeReactionSummaryNotifier(summary);

    return ProviderScope(
      overrides: [
        reactionSummaryProvider(targetId, targetType)
            .overrideWith(() => notifier),
        ...extraOverrides,
      ],
      child: MaterialApp(
        home: Scaffold(
          body: ReactionBar(
            targetId: targetId,
            targetType: targetType,
          ),
        ),
      ),
    );
  }

  group('ReactionBar', () {
    testWidgets('renders 4 reaction chips (Like, Love, Inspire, Helpful)',
        (tester) async {
      final summary = ReactionSummary(
        targetId: targetId,
        targetType: targetType,
        counts: {
          ReactionType.like: 5,
          ReactionType.love: 2,
          ReactionType.inspire: 0,
          ReactionType.helpful: 1,
        },
        userReaction: null,
      );

      await tester.pumpWidget(_buildSubject(summary: summary));
      await tester.pumpAndSettle();

      // Verify all 4 reaction labels are visible
      expect(find.text('Like'), findsNothing); // label is not rendered, only emoji
      // The chips render emoji text, so look for the emoji characters
      expect(find.textContaining('👍'), findsWidgets);
      expect(find.textContaining('❤️'), findsWidgets);
      expect(find.textContaining('✨'), findsWidgets);
      expect(find.textContaining('💡'), findsWidgets);

      // Verify counts are rendered for non-zero reactions
      expect(find.text('5'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('tapping a chip triggers toggleReaction on the notifier',
        (tester) async {
      final summary = ReactionSummary(
        targetId: targetId,
        targetType: targetType,
        counts: {ReactionType.like: 3},
        userReaction: null,
      );

      final notifier = _FakeReactionSummaryNotifier(summary);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reactionSummaryProvider(targetId, targetType)
                .overrideWith(() => notifier),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ReactionBar(
                targetId: targetId,
                targetType: targetType,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the like emoji chip
      await tester.tap(find.textContaining('👍'));
      await tester.pumpAndSettle();

      expect(notifier.toggleCalled, isTrue);
      expect(notifier.toggledReaction, ReactionType.like);
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      /// A notifier that never completes its build, keeping it in loading.
      final loadingNotifier = _LoadingReactionSummaryNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reactionSummaryProvider(targetId, targetType)
                .overrideWith(() => loadingNotifier),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ReactionBar(
                targetId: targetId,
                targetType: targetType,
              ),
            ),
          ),
        ),
      );
      // Only pump once so the AsyncValue is still loading
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
