import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloadventurer/l10n/app_localizations.dart';
import 'package:soloadventurer/app/providers/analytics_provider.dart';
import 'package:soloadventurer/core/services/analytics_service.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/chat_moderation/domain/enums/moderation_enums.dart';
import 'package:soloadventurer/features/chat_moderation/presentation/providers/report_providers.dart';
import 'package:soloadventurer/features/matching/domain/entities/message.dart';
import 'package:soloadventurer/features/matching/presentation/providers/chat_provider.dart';
import 'package:soloadventurer/features/verification/presentation/widgets/verification_badge.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';

/// Chat screen for messaging between matched travelers
class ChatScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/chat';

  /// Chat ID
  final String chatId;

  /// Connection ID (for creating new chat if needed)
  final String? connectionId;

  /// Creates a new [ChatScreen]
  const ChatScreen({
    super.key,
    required this.chatId,
    this.connectionId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late String _chatId;

  @override
  void initState() {
    super.initState();
    _chatId = widget.chatId;

    // Mark messages as read when opening chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).markAsRead(_chatId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messagesAsync = ref.watch(messagesProvider(_chatId));
    final pendingCountAsync = ref.watch(pendingMessagesCountProvider);
    final authAsync = ref.watch(authProvider);
    final currentUserId = authAsync.value?.user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            if (widget.connectionId != null) {
              final chatAsync =
                  ref.read(chatForConnectionProvider(widget.connectionId!));
              final otherUserId = chatAsync.value?.otherUserId;
              if (otherUserId != null && otherUserId.isNotEmpty) {
                context.push('/user/$otherUserId');
              }
            }
          },
          child: _buildTitle(),
        ),
        actions: [
          // Pending messages indicator
          pendingCountAsync.when(
            data: (count) {
              if (count > 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$count pending',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesAsync.when(
              data: (allMessages) {
                // Hide messages the user has reported this session.
                final reported = ref.watch(reportedMessagesProvider);
                final messages = allMessages
                    .where((m) => !reported.contains(m.serverId ?? m.id))
                    .toList();
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start the conversation!',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Auto-scroll when new messages arrive
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message.senderId == currentUserId;

                    return _MessageBubble(
                      message: message,
                      isCurrentUser: isCurrentUser,
                      // Only the other user's messages are reportable.
                      onLongPress: isCurrentUser || currentUserId.isEmpty
                          ? null
                          : () => _showReportSheet(message, currentUserId),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),

          // Message input
          _buildMessageInput(context, l10n),
        ],
      ),
    );
  }

  /// Bottom sheet offering report categories for [message].
  ///
  /// Reports land in the `reports` table (`target_type = 'message'`) and the
  /// outcome is surfaced honestly — the previous implementation swallowed
  /// errors while writing to a table that did not exist (Story 0.7).
  void _showReportSheet(Message message, String reporterId) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Report this message',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            for (final category in ModerationCategory.values)
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(category.label),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _submitReport(message, reporterId, category);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport(
    Message message,
    String reporterId,
    ModerationCategory category,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(reportedMessagesProvider.notifier).report(
            messageId: message.serverId ?? message.id,
            reporterId: reporterId,
            category: category,
          );
      messenger.showSnackBar(
        const SnackBar(content: Text('Message reported. Thank you.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Report failed — please try again.'),
        ),
      );
    }
  }

  Widget _buildTitle() {
    if (widget.connectionId != null) {
      final chatAsync = ref.watch(
        chatForConnectionProvider(widget.connectionId!),
      );
      return chatAsync.when(
        data: (chat) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                child:
                    Text(chat.otherUserName, overflow: TextOverflow.ellipsis)),
            if (chat.otherUserVerificationTier !=
                VerificationTier.unverified) ...[
              const SizedBox(width: 6),
              VerificationBadge(
                tier: chat.otherUserVerificationTier,
                size: 16,
                showBackground: false,
              ),
            ],
          ],
        ),
        loading: () => const Text('Chat'),
        error: (_, __) => const Text('Chat'),
      );
    }
    return const Text('Chat');
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    ref.read(analyticsServiceProvider).track(
      AnalyticsEvents.sendMessage,
      properties: {'chatId': _chatId, 'contentLength': content.length},
    );

    ref
        .read(chatProvider.notifier)
        .sendMessage(
          chatId: _chatId,
          recipientId: widget.connectionId ?? '',
          content: content,
        )
        .then((_) {
      _scrollToBottom();
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $error')),
        );
      }
    });
  }

  Widget _buildMessageInput(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

/// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;

  /// Long-press action (report). Null for the user's own messages.
  final VoidCallback? onLongPress;

  const _MessageBubble({
    required this.message,
    required this.isCurrentUser,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: isCurrentUser
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrentUser
                          ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(message.status),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status) {
    IconData icon;
    double size = 12;

    switch (status) {
      case MessageStatus.pending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        );
      case MessageStatus.sent:
        icon = Icons.check;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        size = 14; // Slightly larger for read status
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        break;
    }

    return Icon(icon, size: size);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
