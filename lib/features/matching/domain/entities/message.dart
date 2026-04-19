import 'package:equatable/equatable.dart';

/// Message status for tracking delivery
enum MessageStatus {
  /// Message created locally, not yet sent to server
  pending,
  
  /// Message sent to server, awaiting delivery confirmation
  sent,
  
  /// Message confirmed delivered to recipient
  delivered,
  
  /// Message read by recipient
  read,
  
  /// Message failed to send after retries
  failed,
}

/// Message entity representing a single message in a chat
class Message extends Equatable {
  /// Unique identifier for the message
  final String id;

  /// ID of the chat/conversation this message belongs to
  final String chatId;

  /// ID of the user who sent the message
  final String senderId;

  /// Message content (text)
  final String content;

  /// Current status of the message
  final MessageStatus status;

  /// When the message was created
  final DateTime createdAt;

  /// When the message was synced to server (null if pending)
  final DateTime? syncedAt;

  /// Server-side message ID (set after successful sync)
  final String? serverId;

  /// Creates a new [Message] instance
  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.status = MessageStatus.pending,
    required this.createdAt,
    this.syncedAt,
    this.serverId,
  });

  @override
  List<Object?> get props => [
        id,
        chatId,
        senderId,
        content,
        status,
        createdAt,
        syncedAt,
        serverId,
      ];

  /// Creates a copy of this message with the given fields replaced
  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? syncedAt,
    String? serverId,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      serverId: serverId ?? this.serverId,
    );
  }

  /// Creates an empty message
  factory Message.empty() {
    return Message(
      id: '',
      chatId: '',
      senderId: '',
      content: '',
      createdAt: DateTime.now(),
    );
  }

  /// Whether this message is empty
  bool get isEmpty => id.isEmpty;

  /// Whether this message is not empty
  bool get isNotEmpty => !isEmpty;

  /// Whether this message was sent by the current user
  bool isSentBy(String userId) => senderId == userId;

  /// Whether this message is pending sync
  bool get isPending => status == MessageStatus.pending;

  /// Whether this message failed to send
  bool get isFailed => status == MessageStatus.failed;

  @override
  String toString() {
    return 'Message{id: $id, chatId: $chatId, status: $status, content: ${content.length > 20 ? '${content.substring(0, 20)}...' : content}}';
  }
}
