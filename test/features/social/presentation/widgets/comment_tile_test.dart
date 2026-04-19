import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/comment.dart';
import 'package:soloadventurer/features/social/presentation/widgets/comment_tile.dart';
import 'package:soloadventurer/features/social/providers/comment_providers.dart';

/// Fake notifier that records delete calls.
class _FakeCommentsNotifier extends CommentsNotifier {
  _FakeCommentsNotifier();

  final List<String> deletedIds = [];

  @override
  Future<List<Comment>> build(String journalId) async => [];

  @override
  Future<void> deleteComment(String commentId) async {
    deletedIds.add(commentId);
  }
}

void main() {
  const journalId = 'journal-xyz';
  const currentUserId = 'user-1';

  Widget _buildSubject({
    required Comment comment,
    String? currentUserId,
    VoidCallback? onReply,
  }) {
    final notifier = _FakeCommentsNotifier();
    return ProviderScope(
      overrides: [
        commentsProvider(journalId).overrideWith(() => notifier),
      ],
      child: MaterialApp(
        home: Material(
          child: SingleChildScrollView(
            child: CommentTile(
              comment: comment,
              journalId: journalId,
              currentUserId: currentUserId,
              onReply: onReply ?? () {},
              depth: 0,
            ),
          ),
        ),
      ),
    );
  }

  Comment _createComment({
    String id = 'comment-1',
    String authorId = 'user-1',
    String? authorName = 'Jane Doe',
    String body = 'This is a comment',
    DateTime? deletedAt,
  }) {
    final now = DateTime.now();
    return Comment(
      id: id,
      journalId: journalId,
      authorId: authorId,
      authorName: authorName,
      body: body,
      createdAt: now,
      updatedAt: now,
      deletedAt: deletedAt,
    );
  }

  group('CommentTile', () {
    testWidgets('renders author name, body, and timestamp', (tester) async {
      final comment = _createComment();

      await tester.pumpWidget(_buildSubject(comment: comment));
      await tester.pumpAndSettle();

      // Author name
      expect(find.text('Jane Doe'), findsOneWidget);

      // Comment body
      expect(find.text('This is a comment'), findsOneWidget);

      // Timestamp (should show 'just now' for a comment created at DateTime.now)
      expect(find.text('just now'), findsOneWidget);
    });

    testWidgets('shows reply button', (tester) async {
      final comment = _createComment();
      bool replyPressed = false;

      await tester.pumpWidget(_buildSubject(
        comment: comment,
        onReply: () => replyPressed = true,
      ));
      await tester.pumpAndSettle();

      // Find the reply text
      final replyFinder = find.text('Reply');
      expect(replyFinder, findsOneWidget);

      // Tap the reply button
      await tester.tap(replyFinder);
      await tester.pumpAndSettle();

      expect(replyPressed, isTrue);
    });

    testWidgets('shows "[deleted]" for soft-deleted comments', (tester) async {
      final comment = _createComment(
        deletedAt: DateTime.now(),
      );

      await tester.pumpWidget(_buildSubject(comment: comment));
      await tester.pumpAndSettle();

      // Should show [deleted] text
      expect(find.text('[deleted]'), findsOneWidget);

      // Should NOT show the original body text
      expect(find.text('This is a comment'), findsNothing);

      // Should NOT show the author name
      expect(find.text('Jane Doe'), findsNothing);
    });

    testWidgets('shows "Unknown" when authorName is null', (tester) async {
      final comment = _createComment(authorName: null);

      await tester.pumpWidget(_buildSubject(comment: comment));
      await tester.pumpAndSettle();

      expect(find.text('Unknown'), findsOneWidget);
    });

    testWidgets('shows delete button when current user is the author',
        (tester) async {
      final comment = _createComment(authorId: 'user-1');

      await tester.pumpWidget(_buildSubject(
        comment: comment,
        currentUserId: 'user-1',
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('hides delete button when current user is NOT the author',
        (tester) async {
      final comment = _createComment(authorId: 'user-2');

      await tester.pumpWidget(_buildSubject(
        comment: comment,
        currentUserId: 'user-1',
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });
  });
}
