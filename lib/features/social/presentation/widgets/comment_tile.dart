import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/comment.dart';
import '../../providers/comment_providers.dart';

/// Displays a single comment with author info, body, timestamp,
/// reply button, and optional delete button for the comment author.
///
/// Nested replies are indented with a colored left border accent.
class CommentTile extends ConsumerWidget {
  const CommentTile({
    super.key,
    required this.comment,
    required this.journalId,
    required this.currentUserId,
    required this.onReply,
    this.depth = 0,
  });

  final Comment comment;
  final String journalId;
  final String? currentUserId;
  final VoidCallback onReply;
  final int depth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (comment.isDeleted) {
      return _buildDeletedTile(context);
    }

    return Padding(
      padding: EdgeInsets.only(
        left: depth > 0 ? 32.0 + (depth - 1) * 16.0 : 0,
        top: 8,
        bottom: 8,
        right: 4,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thread connector for replies
            if (depth > 0)
              Container(
                width: 3,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, ref),
                  const SizedBox(height: 4),
                  _buildBody(context),
                  const SizedBox(height: 6),
                  _buildActions(context),
                  // Nested replies
                  if (comment.replies.isNotEmpty)
                    ...comment.replies.map(
                      (reply) => CommentTile(
                        key: ValueKey(reply.id),
                        comment: reply,
                        journalId: journalId,
                        currentUserId: currentUserId,
                        onReply: onReply,
                        depth: depth + 1,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedTile(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: depth > 0 ? 32.0 + (depth - 1) * 16.0 : 0,
        top: 8,
        bottom: 8,
        right: 4,
      ),
      child: Row(
        children: [
          if (depth > 0)
            Container(
              width: 3,
              height: 24,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withAlpha(40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Text(
            '[deleted]',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final timeAgo = _formatTimeAgo(comment.createdAt);

    return Row(
      children: [
        // Avatar
        _buildAvatar(context, 32),
        const SizedBox(width: 8),
        // Name + time
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.authorName ?? 'Unknown',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                timeAgo,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // Delete button (only for author)
        if (currentUserId == comment.authorId && !comment.isDeleted)
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 16,
              color: theme.colorScheme.outline,
            ),
            onPressed: () => _handleDelete(ref),
            tooltip: 'Delete comment',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, double size) {
    final theme = Theme.of(context);
    final avatarUrl = comment.authorAvatarUrl;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      );
    }

    // Default avatar — initials
    final initials = (comment.authorName?.isNotEmpty == true)
        ? comment.authorName!.substring(0, 1).toUpperCase()
        : '?';

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Text(
        comment.body,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: InkWell(
        onTap: onReply,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text(
            'Reply',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }

  void _handleDelete(WidgetRef ref) {
    ref
        .read(commentsProvider(journalId).notifier)
        .deleteComment(comment.id);
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
    return '${(diff.inDays / 365).floor()}y';
  }
}
