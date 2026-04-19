import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/comment.dart';
import 'package:soloadventurer/features/social/presentation/widgets/comment_input.dart';
import 'package:soloadventurer/features/social/providers/comment_providers.dart';

/// Fake notifier that records calls to [addComment] without hitting Supabase.
class _FakeCommentsNotifier extends CommentsNotifier {
  _FakeCommentsNotifier(List<Comment> initial)
      : _initialComments = initial;

  final List<Comment> _initialComments;
  final List<(String, String?)> addCommentCalls = [];

  @override
  Future<List<Comment>> build(String journalId) async {
    return _initialComments;
  }

  @override
  Future<void> addComment(String body, {String? parentId}) async {
    addCommentCalls.add((body, parentId));
  }
}

void main() {
  const journalId = 'journal-abc';

  /// Wraps [CommentInput] with providers and returns the fake notifier
  /// so tests can make assertions on it.
  (_FakeCommentsNotifier, Widget) _buildSubject({
    Comment? replyTarget,
    VoidCallback? onCancelReply,
    List<Comment> initialComments = const [],
  }) {
    final notifier = _FakeCommentsNotifier(initialComments);

    final widget = ProviderScope(
      overrides: [
        commentsProvider(journalId).overrideWith(() => notifier),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: CommentInput(
            journalId: journalId,
            replyTarget: replyTarget,
            onCancelReply: onCancelReply,
          ),
        ),
      ),
    );

    return (notifier, widget);
  }

  group('CommentInput', () {
    testWidgets('text field accepts input', (tester) async {
      final (_, widget) = _buildSubject();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Find the TextField
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Verify hint text for new comment (not reply)
      expect(find.text('Add a comment...'), findsOneWidget);

      // Enter text
      await tester.enterText(textField, 'Hello world');
      await tester.pump();

      // Verify text was entered
      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('submit calls addComment on the notifier', (tester) async {
      final (notifier, widget) = _buildSubject();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'Great post!');

      // Pump to let the widget rebuild with enabled send button
      await tester.pump();

      // Tap the send button (IconButton with send icon)
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      // Verify addComment was called
      expect(notifier.addCommentCalls, hasLength(1));
      expect(notifier.addCommentCalls.first.$1, 'Great post!');
      expect(notifier.addCommentCalls.first.$2, isNull);
    });

    testWidgets('submit with reply target passes parentId', (tester) async {
      final replyTarget = Comment(
        id: 'comment-1',
        journalId: journalId,
        authorId: 'user-2',
        authorName: 'Alice',
        body: 'Original comment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final (notifier, widget) = _buildSubject(replyTarget: replyTarget);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Verify reply context is shown
      expect(find.textContaining('Replying to'), findsOneWidget);
      expect(find.textContaining('@Alice'), findsOneWidget);

      // Enter text and submit
      await tester.enterText(find.byType(TextField), 'My reply');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      // Verify addComment was called with parentId
      expect(notifier.addCommentCalls, hasLength(1));
      expect(notifier.addCommentCalls.first.$1, 'My reply');
      expect(notifier.addCommentCalls.first.$2, 'comment-1');
    });

    testWidgets('send button is disabled when text is empty', (tester) async {
      final (notifier, widget) = _buildSubject();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Tap send button without entering text
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      // addComment should NOT have been called
      expect(notifier.addCommentCalls, isEmpty);
    });
  });
}
