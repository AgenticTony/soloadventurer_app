import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/comment.dart';
import 'package:soloadventurer/features/social/domain/repositories/comment_repository.dart';
import 'package:soloadventurer/features/social/domain/usecases/add_comment_usecase.dart';

/// Fake implementation of [CommentRepository] for testing
class FakeCommentRepository implements CommentRepository {
  /// Tracks whether addComment was called
  bool addCommentCalled = false;

  /// Captured parameters from addComment
  ({
    String journalId,
    String body,
    String? parentId,
  })? addParams;

  /// The comment to return from addComment
  Comment? returnComment;

  @override
  Future<Comment> addComment({
    required String journalId,
    required String body,
    String? parentId,
  }) async {
    addCommentCalled = true;
    addParams = (
      journalId: journalId,
      body: body,
      parentId: parentId,
    );
    return returnComment ??
        Comment(
          id: 'comment-1',
          journalId: journalId,
          authorId: 'author-1',
          body: body,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          parentId: parentId,
        );
  }

  @override
  Future<List<Comment>> getComments(String journalId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteComment(String commentId) async {
    throw UnimplementedError();
  }

  @override
  Future<int> getCommentCount(String journalId) async {
    throw UnimplementedError();
  }
}

void main() {
  late FakeCommentRepository fakeRepository;
  late AddCommentUseCase useCase;

  setUp(() {
    fakeRepository = FakeCommentRepository();
    useCase = AddCommentUseCase(fakeRepository);
  });

  group('AddCommentUseCase', () {
    test('calls repository addComment with correct parameters', () async {
      final comment = await useCase(
        journalId: 'journal-1',
        body: 'This is a test comment',
      );

      expect(fakeRepository.addCommentCalled, isTrue);
      expect(fakeRepository.addParams, isNotNull);
      expect(fakeRepository.addParams!.journalId, 'journal-1');
      expect(fakeRepository.addParams!.body, 'This is a test comment');
      expect(fakeRepository.addParams!.parentId, isNull);
      expect(comment, isA<Comment>());
    });

    test('passes parentId when provided', () async {
      await useCase(
        journalId: 'journal-2',
        body: 'A reply comment',
        parentId: 'parent-comment-1',
      );

      expect(fakeRepository.addParams!.parentId, 'parent-comment-1');
    });

    test('returns the comment entity from the repository', () async {
      final expectedComment = Comment(
        id: 'comment-99',
        journalId: 'journal-5',
        authorId: 'author-99',
        body: 'Expected body',
        createdAt: DateTime(2026, 3, 15),
        updatedAt: DateTime(2026, 3, 15),
      );
      fakeRepository.returnComment = expectedComment;

      final result = await useCase(
        journalId: 'journal-5',
        body: 'Expected body',
      );

      expect(result.id, 'comment-99');
      expect(result.body, 'Expected body');
      expect(result.authorId, 'author-99');
    });
  });
}
