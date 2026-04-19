import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/comment.dart';

void main() {
  final tCreatedAt = DateTime(2026, 1, 10);
  final tUpdatedAt = DateTime(2026, 1, 11);
  final tDeletedAt = DateTime(2026, 1, 12);

  Comment createComment({
    String id = 'comment-1',
    String journalId = 'journal-1',
    String authorId = 'user-1',
    String body = 'Great post!',
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentId,
    String? authorName,
    String? authorAvatarUrl,
    DateTime? deletedAt,
    List<Comment> replies = const [],
  }) {
    return Comment(
      id: id,
      journalId: journalId,
      authorId: authorId,
      body: body,
      createdAt: createdAt ?? tCreatedAt,
      updatedAt: updatedAt ?? tUpdatedAt,
      parentId: parentId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      deletedAt: deletedAt,
      replies: replies,
    );
  }

  group('Comment', () {
    test('constructs with required fields', () {
      final comment = createComment();

      expect(comment.id, 'comment-1');
      expect(comment.journalId, 'journal-1');
      expect(comment.authorId, 'user-1');
      expect(comment.body, 'Great post!');
      expect(comment.createdAt, tCreatedAt);
      expect(comment.updatedAt, tUpdatedAt);
    });

    test('optional fields default to null or empty list', () {
      final comment = createComment();

      expect(comment.parentId, isNull);
      expect(comment.authorName, isNull);
      expect(comment.authorAvatarUrl, isNull);
      expect(comment.deletedAt, isNull);
      expect(comment.replies, isEmpty);
    });

    test('constructs with all optional fields', () {
      final reply = createComment(id: 'reply-1', parentId: 'comment-1');
      final comment = createComment(
        parentId: 'parent-1',
        authorName: 'Jane Doe',
        authorAvatarUrl: 'https://example.com/avatar.jpg',
        deletedAt: tDeletedAt,
        replies: [reply],
      );

      expect(comment.parentId, 'parent-1');
      expect(comment.authorName, 'Jane Doe');
      expect(comment.authorAvatarUrl, 'https://example.com/avatar.jpg');
      expect(comment.deletedAt, tDeletedAt);
      expect(comment.replies, hasLength(1));
    });

    group('isDeleted', () {
      test('returns true when deletedAt is set', () {
        final comment = createComment(deletedAt: tDeletedAt);
        expect(comment.isDeleted, isTrue);
      });

      test('returns false when deletedAt is null', () {
        final comment = createComment();
        expect(comment.isDeleted, isFalse);
      });
    });

    group('isReply', () {
      test('returns true when parentId is set', () {
        final comment = createComment(parentId: 'parent-1');
        expect(comment.isReply, isTrue);
      });

      test('returns false when parentId is null', () {
        final comment = createComment();
        expect(comment.isReply, isFalse);
      });
    });

    group('copyWith', () {
      test('copies all fields when specified', () {
        final original = createComment();
        final copied = original.copyWith(
          id: 'comment-2',
          journalId: 'journal-2',
          authorId: 'user-2',
          body: 'Updated body',
          parentId: 'parent-2',
          authorName: 'New Name',
          authorAvatarUrl: 'https://example.com/new.jpg',
          deletedAt: tDeletedAt,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
          replies: [],
        );

        expect(copied.id, 'comment-2');
        expect(copied.journalId, 'journal-2');
        expect(copied.authorId, 'user-2');
        expect(copied.body, 'Updated body');
        expect(copied.parentId, 'parent-2');
        expect(copied.authorName, 'New Name');
        expect(copied.authorAvatarUrl, 'https://example.com/new.jpg');
        expect(copied.deletedAt, tDeletedAt);
      });

      test('retains original values when no arguments given', () {
        final original = createComment(
          authorName: 'Jane',
          parentId: 'parent-1',
        );
        final copied = original.copyWith();

        expect(copied.id, original.id);
        expect(copied.journalId, original.journalId);
        expect(copied.authorId, original.authorId);
        expect(copied.body, original.body);
        expect(copied.parentId, original.parentId);
        expect(copied.authorName, original.authorName);
        expect(copied.replies, original.replies);
      });
    });

    group('equality', () {
      test('equal when all props match', () {
        final a = createComment();
        final b = createComment();
        expect(a, equals(b));
      });

      test('not equal when id differs', () {
        final a = createComment(id: 'a');
        final b = createComment(id: 'b');
        expect(a, isNot(equals(b)));
      });

      test('not equal when body differs', () {
        final a = createComment(body: 'first');
        final b = createComment(body: 'second');
        expect(a, isNot(equals(b)));
      });

      test('not equal when replies differ', () {
        final a = createComment(replies: []);
        final b = createComment(
          replies: [createComment(id: 'reply-1')],
        );
        expect(a, isNot(equals(b)));
      });

      test('not equal when deletedAt differs', () {
        final a = createComment();
        final b = createComment(deletedAt: tDeletedAt);
        expect(a, isNot(equals(b)));
      });
    });
  });
}
