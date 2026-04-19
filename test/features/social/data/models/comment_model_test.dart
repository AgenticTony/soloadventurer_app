import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/data/models/comment_model.dart';

void main() {
  const tId = 'comment-123';
  const tJournalId = 'journal-456';
  const tAuthorId = 'user-abc';
  const tBody = 'Great adventure!';
  const tCreatedAt = '2026-04-01T12:00:00.000Z';
  const tUpdatedAt = '2026-04-01T12:30:00.000Z';

  group('CommentModel', () {
    group('fromJson', () {
      test('parses a standard comment with all optional fields', () {
        final json = {
          'id': tId,
          'journal_id': tJournalId,
          'author_id': tAuthorId,
          'body': tBody,
          'created_at': tCreatedAt,
          'updated_at': tUpdatedAt,
          'parent_id': 'parent-789',
          'author_name': 'Jane Doe',
          'author_avatar_url': 'https://example.com/avatar.jpg',
          'deleted_at': null,
        };

        final model = CommentModel.fromJson(json);

        expect(model.id, tId);
        expect(model.journalId, tJournalId);
        expect(model.authorId, tAuthorId);
        expect(model.body, tBody);
        expect(model.createdAt, DateTime.parse(tCreatedAt));
        expect(model.updatedAt, DateTime.parse(tUpdatedAt));
        expect(model.parentId, 'parent-789');
        expect(model.authorName, 'Jane Doe');
        expect(model.authorAvatarUrl, 'https://example.com/avatar.jpg');
        expect(model.deletedAt, isNull);
      });

      test('parses a comment with null optional fields', () {
        final json = {
          'id': tId,
          'journal_id': tJournalId,
          'author_id': tAuthorId,
          'body': tBody,
          'created_at': tCreatedAt,
          'updated_at': tUpdatedAt,
        };

        final model = CommentModel.fromJson(json);

        expect(model.parentId, isNull);
        expect(model.authorName, isNull);
        expect(model.authorAvatarUrl, isNull);
        expect(model.deletedAt, isNull);
      });

      test('substitutes [deleted] when body is null', () {
        final json = {
          'id': tId,
          'journal_id': tJournalId,
          'author_id': tAuthorId,
          'body': null,
          'created_at': tCreatedAt,
          'updated_at': tUpdatedAt,
        };

        final model = CommentModel.fromJson(json);

        expect(model.body, '[deleted]');
      });

      test('parses deleted_at timestamp when present', () {
        const deletedAt = '2026-04-02T10:00:00.000Z';
        final json = {
          'id': tId,
          'journal_id': tJournalId,
          'author_id': tAuthorId,
          'body': tBody,
          'created_at': tCreatedAt,
          'updated_at': tUpdatedAt,
          'deleted_at': deletedAt,
        };

        final model = CommentModel.fromJson(json);

        expect(model.deletedAt, DateTime.parse(deletedAt));
      });
    });

    group('toEntity', () {
      test('converts to Comment entity with matching fields', () {
        final model = CommentModel(
          id: tId,
          journalId: tJournalId,
          authorId: tAuthorId,
          body: tBody,
          createdAt: DateTime.parse(tCreatedAt),
          updatedAt: DateTime.parse(tUpdatedAt),
          parentId: 'parent-789',
          authorName: 'Jane Doe',
          authorAvatarUrl: 'https://example.com/avatar.jpg',
        );

        final entity = model.toEntity();

        expect(entity.id, tId);
        expect(entity.journalId, tJournalId);
        expect(entity.authorId, tAuthorId);
        expect(entity.body, tBody);
        expect(entity.createdAt, DateTime.parse(tCreatedAt));
        expect(entity.updatedAt, DateTime.parse(tUpdatedAt));
        expect(entity.parentId, 'parent-789');
        expect(entity.authorName, 'Jane Doe');
        expect(entity.authorAvatarUrl, 'https://example.com/avatar.jpg');
        expect(entity.deletedAt, isNull);
        expect(entity.replies, isEmpty);
      });

      test('replaces body with [deleted] when deletedAt is set', () {
        final deletedAt = DateTime.parse('2026-04-02T10:00:00.000Z');
        final model = CommentModel(
          id: tId,
          journalId: tJournalId,
          authorId: tAuthorId,
          body: 'Original body text',
          createdAt: DateTime.parse(tCreatedAt),
          updatedAt: DateTime.parse(tUpdatedAt),
          deletedAt: deletedAt,
        );

        final entity = model.toEntity();

        expect(entity.body, '[deleted]');
        expect(entity.deletedAt, deletedAt);
        expect(entity.isDeleted, isTrue);
      });

      test('preserves body when deletedAt is null', () {
        final model = CommentModel(
          id: tId,
          journalId: tJournalId,
          authorId: tAuthorId,
          body: tBody,
          createdAt: DateTime.parse(tCreatedAt),
          updatedAt: DateTime.parse(tUpdatedAt),
        );

        final entity = model.toEntity();

        expect(entity.body, tBody);
        expect(entity.isDeleted, isFalse);
      });

      test('isReply returns true when parentId is set', () {
        final model = CommentModel(
          id: tId,
          journalId: tJournalId,
          authorId: tAuthorId,
          body: tBody,
          createdAt: DateTime.parse(tCreatedAt),
          updatedAt: DateTime.parse(tUpdatedAt),
          parentId: 'parent-789',
        );

        final entity = model.toEntity();

        expect(entity.isReply, isTrue);
      });
    });
  });
}
