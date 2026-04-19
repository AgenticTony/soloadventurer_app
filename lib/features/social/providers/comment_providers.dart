import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/comment_remote_data_source.dart';
import '../data/repositories/comment_repository_impl.dart';
import '../domain/entities/comment.dart';
import '../domain/repositories/comment_repository.dart';
import '../domain/usecases/add_comment_usecase.dart';
import '../domain/usecases/delete_comment_usecase.dart';
import '../domain/usecases/get_comments_usecase.dart';

part 'comment_providers.g.dart';

// ============================================================
// Data Source
// ============================================================

@Riverpod(keepAlive: true)
CommentRemoteDataSource commentRemoteDataSource(Ref ref) {
  return CommentRemoteDataSourceImpl(client: Supabase.instance.client);
}

// ============================================================
// Repository
// ============================================================

@Riverpod(keepAlive: true)
CommentRepository commentRepository(Ref ref) {
  return CommentRepositoryImpl(
    remoteDataSource: ref.read(commentRemoteDataSourceProvider),
  );
}

// ============================================================
// Use Cases
// ============================================================

@riverpod
GetCommentsUseCase getCommentsUseCase(Ref ref) =>
    GetCommentsUseCase(ref.read(commentRepositoryProvider));

@riverpod
AddCommentUseCase addCommentUseCase(Ref ref) =>
    AddCommentUseCase(ref.read(commentRepositoryProvider));

@riverpod
DeleteCommentUseCase deleteCommentUseCase(Ref ref) =>
    DeleteCommentUseCase(ref.read(commentRepositoryProvider));

// ============================================================
// Comments Notifier — per journal
// ============================================================

@riverpod
class CommentsNotifier extends _$CommentsNotifier {
  late String _journalId;

  @override
  Future<List<Comment>> build(String journalId) async {
    _journalId = journalId;
    final useCase = ref.read(getCommentsUseCaseProvider);
    final comments = await useCase(journalId);
    return _buildCommentTree(comments);
  }

  /// Add a new comment
  Future<void> addComment(String body, {String? parentId}) async {
    final useCase = ref.read(addCommentUseCaseProvider);
    final comment = await useCase(
      journalId: _journalId,
      body: body,
      parentId: parentId,
    );
    final current = state.value ?? [];
    state = AsyncValue.data([...current, comment]);
  }

  /// Delete a comment (soft delete)
  Future<void> deleteComment(String commentId) async {
    final useCase = ref.read(deleteCommentUseCaseProvider);
    await useCase(commentId);
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.where((c) => c.id != commentId).toList(),
    );
  }

  /// Refresh comments from server
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  List<Comment> _buildCommentTree(List<Comment> flat) {
    final byParent = <String?, List<Comment>>{};
    for (final comment in flat) {
      byParent.putIfAbsent(comment.parentId, () => []);
      byParent[comment.parentId]!.add(comment);
    }

    return flat
        .where((c) => c.parentId == null)
        .map((c) => c.copyWith(replies: byParent[c.id] ?? []))
        .toList();
  }
}
