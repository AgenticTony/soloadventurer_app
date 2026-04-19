import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/comment.dart';
import 'package:soloadventurer/features/social/presentation/widgets/comment_thread.dart';
import 'package:soloadventurer/features/social/providers/comment_providers.dart';

/// Fake notifier for controlling comments state in tests.
class _FakeCommentsNotifier extends CommentsNotifier {
  _FakeCommentsNotifier(this._comments);

  final List<Comment> _comments;

  @override
  Future<List<Comment>> build(String journalId) async {
    return _comments;
  }
}

void main() {
  const journalId = 'journal-thread-test';
  const currentUserId = 'user-1';

  Widget _buildSubject({
    required List<Comment> comments,
  }) {
    final notifier = _FakeCommentsNotifier(comments);
    return ProviderScope(
      overrides: [
        commentsProvider(journalId).overrideWith(() => notifier),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: CommentThread(
            journalId: journalId,
            currentUserId: currentUserId,
          ),
        ),
      ),
    );
  }

  Comment _createComment({
    String id = 'c1',
    String authorName = 'Alice',
    String body = 'First comment',
  }) {
    final now = DateTime.now();
    return Comment(
      id: id,
      journalId: journalId,
      authorId: 'user-2',
      authorName: authorName,
      body: body,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('CommentThread', () {
    testWidgets('shows comment count header with comments', (tester) async {
      final comments = [
        _createComment(id: 'c1', body: 'Comment one'),
        _createComment(id: 'c2', authorName: 'Bob', body: 'Comment two'),
      ];

      await tester.pumpWidget(_buildSubject(comments: comments));
      await tester.pumpAndSettle();

      // Should show "2 Comments" header
      expect(find.text('2 Comments'), findsOneWidget);
    });

    testWidgets('shows singular "Comment" for exactly one comment',
        (tester) async {
      final comments = [
        _createComment(id: 'c1', body: 'Solo comment'),
      ];

      await tester.pumpWidget(_buildSubject(comments: comments));
      await tester.pumpAndSettle();

      expect(find.text('1 Comment'), findsOneWidget);
    });

    testWidgets('shows empty state when no comments', (tester) async {
      await tester.pumpWidget(_buildSubject(comments: []));
      await tester.pumpAndSettle();

      // Should show empty state text
      expect(find.text('No comments yet'), findsOneWidget);
      expect(
          find.text('Be the first to share your thoughts!'), findsOneWidget);

      // Should NOT show comment count header
      expect(find.text('0 Comments'), findsNothing);
    });

    testWidgets('renders comments in the list', (tester) async {
      final comments = [
        _createComment(id: 'c1', authorName: 'Alice', body: 'Hello'),
        _createComment(id: 'c2', authorName: 'Bob', body: 'World'),
      ];

      await tester.pumpWidget(_buildSubject(comments: comments));
      await tester.pumpAndSettle();

      // Both comments should be visible
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('World'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows comment input field', (tester) async {
      await tester.pumpWidget(_buildSubject(comments: []));
      await tester.pumpAndSettle();

      // The input field with hint text should be present
      expect(find.text('Add a comment...'), findsOneWidget);
    });

    testWidgets('shows error state when provider has error', (tester) async {
      /// A notifier that always throws to simulate an error.
      final errorNotifier = _ErrorCommentsNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            commentsProvider(journalId).overrideWith(() => errorNotifier),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CommentThread(
                journalId: journalId,
                currentUserId: currentUserId,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load comments'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

/// Notifier that throws an error to simulate failure scenarios.
class _ErrorCommentsNotifier extends CommentsNotifier {
  @override
  Future<List<Comment>> build(String journalId) async {
    throw Exception('Network error');
  }
}
