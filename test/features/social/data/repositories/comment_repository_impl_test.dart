import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/data/datasources/comment_remote_data_source.dart';
import 'package:soloadventurer/features/social/data/models/comment_model.dart';
import 'package:soloadventurer/features/social/data/repositories/comment_repository_impl.dart';
import 'package:soloadventurer/features/social/domain/entities/comment.dart';

/// Fake implementation of [CommentRemoteDataSource] for testing
class FakeCommentRemoteDataSource implements CommentRemoteDataSource {
  /// Stored comment models
  final List<CommentModel> storedComments = [];

  int _nextId = 1;

  @override
  Future<List<CommentModel>> getComments(String journalId) async {
    return storedComments
        .where((c) => c.journalId == journalId && c.deletedAt == null)
        .toList();
  }

  @override
  Future<CommentModel> addComment({
    required String journalId,
    required String authorId,
    required String body,
    String? parentId,
  }) async {
    final now = DateTime(2026, 1, 15, 12, 0, 0);
    final model = CommentModel(
      id: 'comment-${_nextId++}',
      journalId: journalId,
      authorId: authorId,
      body: body,
      createdAt: now,
      updatedAt: now,
      parentId: parentId,
      authorName: 'Test Author',
      authorAvatarUrl: null,
    );
    storedComments.add(model);
    return model;
  }

  @override
  Future<void> deleteComment(String commentId) async {
    final index = storedComments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      final existing = storedComments[index];
      storedComments[index] = CommentModel(
        id: existing.id,
        journalId: existing.journalId,
        authorId: existing.authorId,
        body: existing.body,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        parentId: existing.parentId,
        authorName: existing.authorName,
        authorAvatarUrl: existing.authorAvatarUrl,
        deletedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<int> getCommentCount(String journalId) async {
    return storedComments
        .where((c) => c.journalId == journalId && c.deletedAt == null)
        .length;
  }
}

void main() {
  late FakeCommentRemoteDataSource fakeDataSource;
  late CommentRepositoryImpl repository;
  const testJournalId = 'journal-789';

  setUp(() {
    fakeDataSource = FakeCommentRemoteDataSource();
    repository = CommentRepositoryImpl(
      remoteDataSource: fakeDataSource,
    );
  });

  group('CommentRepositoryImpl', () {
    group('getComments', () {
      test('returns empty list when no comments exist', () async {
        // getComments does not call _requireCurrentUserId
        final comments = await repository.getComments(testJournalId);

        expect(comments, isEmpty);
      });

      test('maps models to domain entities correctly', () async {
        // Seed a comment through the data source
        await fakeDataSource.addComment(
          journalId: testJournalId,
          authorId: 'author-1',
          body: 'Great journal entry!',
        );

        final comments = await repository.getComments(testJournalId);

        expect(comments, hasLength(1));
        final comment = comments.first;
        expect(comment, isA<Comment>());
        expect(comment.journalId, testJournalId);
        expect(comment.authorId, 'author-1');
        expect(comment.body, 'Great journal entry!');
        expect(comment.authorName, 'Test Author');
      });

      test('returns multiple comments in order', () async {
        await fakeDataSource.addComment(
          journalId: testJournalId,
          authorId: 'author-1',
          body: 'First comment',
        );
        await fakeDataSource.addComment(
          journalId: testJournalId,
          authorId: 'author-2',
          body: 'Second comment',
        );

        final comments = await repository.getComments(testJournalId);

        expect(comments, hasLength(2));
        expect(comments[0].body, 'First comment');
        expect(comments[1].body, 'Second comment');
      });

      test('excludes soft-deleted comments', () async {
        final model = await fakeDataSource.addComment(
          journalId: testJournalId,
          authorId: 'author-1',
          body: 'Will be deleted',
        );
        await fakeDataSource.deleteComment(model.id);
        await fakeDataSource.addComment(
          journalId: testJournalId,
          authorId: 'author-2',
          body: 'Still active',
        );

        final comments = await repository.getComments(testJournalId);

        expect(comments, hasLength(1));
        expect(comments.first.body, 'Still active');
      });
    });

    group('getCommentCount', () {
      test('returns zero when no comments exist', () async {
        // getCommentCount delegates directly to data source, no auth required
        final count = await repository.getCommentCount(testJournalId);
        expect(count, 0);
      });

      test('returns count of non-deleted comments', () async {
        await fakeDataSource.addComment(
          journalId: testJournalId,
          authorId: 'author-1',
          body: 'Comment 1',
        );
        final deleted = await fakeDataSource.addComment(
          journalId: testJournalId,
          authorId: 'author-2',
          body: 'Comment 2',
        );
        await fakeDataSource.addComment(
          journalId: testJournalId,
          authorId: 'author-3',
          body: 'Comment 3',
        );

        await fakeDataSource.deleteComment(deleted.id);

        final count = await repository.getCommentCount(testJournalId);
        expect(count, 2);
      });

      test('returns count only for the specified journal', () async {
        await fakeDataSource.addComment(
          journalId: testJournalId,
          authorId: 'author-1',
          body: 'For target journal',
        );
        await fakeDataSource.addComment(
          journalId: 'other-journal',
          authorId: 'author-2',
          body: 'For different journal',
        );

        final count = await repository.getCommentCount(testJournalId);
        expect(count, 1);
      });
    });
  });
}
