import 'package:equatable/equatable.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';
import 'message.dart';

/// Chat entity representing a conversation between matched travelers
class Chat extends Equatable {
  /// Unique identifier for the chat
  final String id;

  /// ID of the connection/match this chat is associated with
  final String connectionId;

  /// ID of the current user
  final String currentUserId;

  /// ID of the other participant
  final String otherUserId;

  /// Display name of the other participant
  final String otherUserName;

  /// Avatar URL of the other participant (optional)
  final String? otherUserAvatarUrl;

  /// Verification tier of the other participant
  final VerificationTier otherUserVerificationTier;

  /// Last message in the chat (for preview)
  final Message? lastMessage;

  /// Number of unread messages
  final int unreadCount;

  /// When the chat was created
  final DateTime createdAt;

  /// When the chat was last updated
  final DateTime updatedAt;

  /// Whether the chat is active (not archived/deleted)
  final bool isActive;

  /// Creates a new [Chat] instance
  const Chat({
    required this.id,
    required this.connectionId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
    this.otherUserVerificationTier = VerificationTier.unverified,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        connectionId,
        currentUserId,
        otherUserId,
        otherUserName,
        otherUserAvatarUrl,
        otherUserVerificationTier,
        lastMessage,
        unreadCount,
        createdAt,
        updatedAt,
        isActive,
      ];

  /// Creates a copy of this chat with the given fields replaced
  Chat copyWith({
    String? id,
    String? connectionId,
    String? currentUserId,
    String? otherUserId,
    String? otherUserName,
    String? otherUserAvatarUrl,
    VerificationTier? otherUserVerificationTier,
    Message? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Chat(
      id: id ?? this.id,
      connectionId: connectionId ?? this.connectionId,
      currentUserId: currentUserId ?? this.currentUserId,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatarUrl: otherUserAvatarUrl ?? this.otherUserAvatarUrl,
      otherUserVerificationTier: otherUserVerificationTier ?? this.otherUserVerificationTier,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Creates an empty chat
  factory Chat.empty() {
    final now = DateTime.now();
    return Chat(
      id: '',
      connectionId: '',
      currentUserId: '',
      otherUserId: '',
      otherUserName: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Whether this chat is empty
  bool get isEmpty => id.isEmpty;

  /// Whether this chat is not empty
  bool get isNotEmpty => !isEmpty;

  /// Whether there are unread messages
  bool get hasUnread => unreadCount > 0;

  /// Preview text for the last message
  String get lastMessagePreview {
    if (lastMessage == null) return '';
    if (lastMessage!.content.length > 50) {
      return '${lastMessage!.content.substring(0, 50)}...';
    }
    return lastMessage!.content;
  }

  @override
  String toString() {
    return 'Chat{id: $id, with: $otherUserName, unread: $unreadCount}';
  }
}
