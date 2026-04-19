import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/comment.dart';
import '../../providers/comment_providers.dart';

/// Text input with send button for adding comments.
///
/// Shows reply context ("Replying to @username") when replying to a
/// specific comment. Cancel button clears the reply target.
class CommentInput extends ConsumerStatefulWidget {
  const CommentInput({
    super.key,
    required this.journalId,
    this.replyTarget,
    this.onCancelReply,
  });

  final String journalId;
  final Comment? replyTarget;
  final VoidCallback? onCancelReply;

  @override
  ConsumerState<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    // Auto-focus when replying
    if (widget.replyTarget != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isReplying = widget.replyTarget != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reply context bar
        if (isReplying) _buildReplyContext(context),
        // Input row
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !_isSending,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmit(),
                  decoration: InputDecoration(
                    hintText: isReplying
                        ? 'Write a reply...'
                        : 'Add a comment...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withAlpha(160),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send button
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _controller.text.trim().isNotEmpty && !_isSending
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _controller.text.trim().isNotEmpty && !_isSending
                      ? _handleSubmit
                      : null,
                  icon: _isSending
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: _controller.text.trim().isNotEmpty
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant.withAlpha(120),
                        ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReplyContext(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.primary.withAlpha(60),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply_rounded,
            size: 14,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'Replying to ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              '@${widget.replyTarget!.authorName ?? "unknown"}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onCancelReply,
            icon: Icon(
              Icons.close_rounded,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            visualDensity: VisualDensity.compact,
            tooltip: 'Cancel reply',
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await ref
          .read(commentsProvider(widget.journalId).notifier)
          .addComment(
            text,
            parentId: widget.replyTarget?.id,
          );

      _controller.clear();
      widget.onCancelReply?.call();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
}
