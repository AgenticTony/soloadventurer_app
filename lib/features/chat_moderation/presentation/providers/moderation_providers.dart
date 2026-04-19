import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/moderation_flag.dart';
import '../../domain/enums/moderation_enums.dart';
import '../../domain/services/message_moderation_service.dart';
import '../../../../features/feature_flags/feature_flag_provider.dart';

/// Provider for the MessageModerationService
final messageModerationServiceProvider =
    Provider<MessageModerationService>((ref) {
  return MessageModerationService();
});

/// State for moderation flags in the current chat session.
///
/// Maps message IDs to their moderation results.
class ModerationState {
  /// Map of message ID to its moderation flag
  final Map<String, ModerationFlag> flags;

  /// Set of message IDs that the user has chosen to view
  final Set<String> revealedMessageIds;

  /// Set of message IDs that the user has deleted
  final Set<String> deletedMessageIds;

  const ModerationState({
    this.flags = const {},
    this.revealedMessageIds = const {},
    this.deletedMessageIds = const {},
  });

  /// Check if a message is flagged and should show overlay
  bool isFlagged(String messageId) {
    final flag = flags[messageId];
    return flag != null && flag.shouldShowOverlay;
  }

  /// Check if a message has been revealed by the user
  bool isRevealed(String messageId) => revealedMessageIds.contains(messageId);

  /// Check if a message has been deleted by the user
  bool isDeleted(String messageId) => deletedMessageIds.contains(messageId);

  ModerationState copyWith({
    Map<String, ModerationFlag>? flags,
    Set<String>? revealedMessageIds,
    Set<String>? deletedMessageIds,
  }) {
    return ModerationState(
      flags: flags ?? this.flags,
      revealedMessageIds: revealedMessageIds ?? this.revealedMessageIds,
      deletedMessageIds: deletedMessageIds ?? this.deletedMessageIds,
    );
  }
}

/// Notifier managing message moderation state.
///
/// Scans messages in the background after they're delivered.
/// Uses Riverpod 3.x Notifier pattern.
class ModerationNotifier extends Notifier<ModerationState> {
  @override
  ModerationState build() {
    return const ModerationState();
  }

  /// Scan a message for inappropriate content.
  ///
  /// This runs in the background and does NOT block message delivery.
  /// Results update the state when the scan completes.
  Future<void> scanMessage({
    required String messageId,
    required String content,
    required String senderId,
    required String chatId,
  }) async {
    // Check if moderation is active
    final flags = ref.read(featureFlagsProvider);
    if (!flags.aiModerationActive) return;

    final service = ref.read(messageModerationServiceProvider);
    final flag = await service.scanMessage(
      messageId: messageId,
      content: content,
      senderId: senderId,
      chatId: chatId,
    );

    // Only update state if still mounted and result is flagged
    if (flag.result == ModerationResult.flagged) {
      final currentFlags = Map<String, ModerationFlag>.from(state.flags);
      currentFlags[messageId] = flag;
      state = state.copyWith(flags: currentFlags);
    }
  }

  /// Mark a message as revealed (user chose "View Anyway")
  void revealMessage(String messageId) {
    final revealed = Set<String>.from(state.revealedMessageIds);
    revealed.add(messageId);
    state = state.copyWith(revealedMessageIds: revealed);
  }

  /// Mark a message as deleted (user chose "Delete")
  void deleteMessage(String messageId) {
    final deleted = Set<String>.from(state.deletedMessageIds);
    deleted.add(messageId);
    state = state.copyWith(deletedMessageIds: deleted);
  }

  /// Report a message and delete it
  Future<void> reportMessage({
    required String messageId,
    required String reporterId,
    String? reason,
    ModerationCategory? category,
  }) async {
    // Delete from user's view
    deleteMessage(messageId);

    // Submit report
    final service = ref.read(messageModerationServiceProvider);
    await service.reportMessage(
      messageId: messageId,
      reporterId: reporterId,
      reason: reason ?? 'User reported via flagged message overlay',
      category: category,
    );
  }

  /// Clear a specific flag (e.g., after the user dismisses it)
  void dismissFlag(String messageId) {
    final currentFlags = Map<String, ModerationFlag>.from(state.flags);
    currentFlags.remove(messageId);
    state = state.copyWith(flags: currentFlags);
  }
}

/// Provider for moderation state
final moderationProvider =
    NotifierProvider<ModerationNotifier, ModerationState>(
  ModerationNotifier.new,
);
