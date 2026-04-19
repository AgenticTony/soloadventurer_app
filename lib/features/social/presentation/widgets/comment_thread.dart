import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/comment.dart';
import '../../providers/comment_providers.dart';
import 'comment_input.dart';
import 'comment_tile.dart';

/// Displays a threaded comment list with input field for a journal entry.
///
/// Shows comment count header, loading/error/empty states, and the
/// [CommentInput] pinned at the bottom. Handles reply context so
/// tapping "Reply" on a [CommentTile] sets the reply target.
class CommentThread extends ConsumerStatefulWidget {
  const CommentThread({
    super.key,
    required this.journalId,
    required this.currentUserId,
  });

  final String journalId;
  final String? currentUserId;

  @override
  ConsumerState<CommentThread> createState() => _CommentThreadState();
}

class _CommentThreadState extends ConsumerState<CommentThread> {
  Comment? _replyTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final commentsAsync = ref.watch(commentsProvider(widget.journalId));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Comment input at top
        CommentInput(
          journalId: widget.journalId,
          replyTarget: _replyTarget,
          onCancelReply: _clearReplyTarget,
        ),
        // Comment list
        Flexible(
          child: commentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: SizedBox(
                  width: 120,
                  height: 2,
                  child: LinearProgressIndicator(),
                ),
              ),
            ),
            error: (err, _) => _buildErrorState(context, colorScheme, err),
            data: (comments) {
              if (comments.isEmpty) {
                return _buildEmptyState(context, colorScheme);
              }
              return _buildCommentList(context, comments);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommentList(BuildContext context, List<Comment> comments) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Count header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '${comments.length} Comment${comments.length == 1 ? '' : 's'}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Divider(height: 1),
        // Comments
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: comments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final comment = comments[index];
              return CommentTile(
                key: ValueKey(comment.id),
                comment: comment,
                journalId: widget.journalId,
                currentUserId: widget.currentUserId,
                onReply: () => _setReplyTarget(comment),
                depth: 0,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: colorScheme.onSurfaceVariant.withAlpha(100),
            ),
            const SizedBox(height: 12),
            Text(
              'No comments yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withAlpha(180),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Be the first to share your thoughts!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withAlpha(140),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, ColorScheme colorScheme, Object error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: colorScheme.error.withAlpha(180),
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load comments',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () =>
                  ref.invalidate(commentsProvider(widget.journalId)),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _setReplyTarget(Comment comment) {
    setState(() => _replyTarget = comment);
  }

  void _clearReplyTarget() {
    setState(() => _replyTarget = null);
  }
}
