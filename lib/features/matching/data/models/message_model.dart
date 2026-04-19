import 'package:soloadventurer/features/matching/domain/entities/message.dart';

/// Data model for Message with serialization support
class MessageModel extends Message {
  /// Creates a new [MessageModel]
  const MessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.content,
    super.status,
    required super.createdAt,
    super.syncedAt,
    super.serverId,
  });

  /// Creates a MessageModel from a JSON map
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      chatId: json['chat_id'] as String? ?? json['conversationId'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? json['senderId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : json['syncedAt'] != null
              ? DateTime.parse(json['syncedAt'] as String)
              : null,
      serverId: json['server_id'] as String? ?? json['serverId'] as String?,
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'server_id': serverId,
    };
  }

  /// Creates a MessageModel from a Message entity
  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      chatId: message.chatId,
      senderId: message.senderId,
      content: message.content,
      status: message.status,
      createdAt: message.createdAt,
      syncedAt: message.syncedAt,
      serverId: message.serverId,
    );
  }

  /// Creates a copy with updated status
  MessageModel withStatus(MessageStatus newStatus, {String? serverId}) {
    return MessageModel(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: content,
      status: newStatus,
      createdAt: createdAt,
      syncedAt: DateTime.now(),
      serverId: serverId ?? this.serverId,
    );
  }

  /// Creates a pending message (for optimistic UI)
  factory MessageModel.pending({
    required String id,
    required String chatId,
    required String senderId,
    required String content,
  }) {
    return MessageModel(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: content,
      status: MessageStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  static MessageStatus _parseStatus(String? status) {
    if (status == null) return MessageStatus.pending;
    
    switch (status.toLowerCase()) {
      case 'pending':
        return MessageStatus.pending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.pending;
    }
  }
}

/// Chat model with serialization support
class ChatModel {
  final String id;
  final String connectionId;
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatarUrl;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const ChatModel({
    required this.id,
    required this.connectionId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String? ?? '',
      connectionId: json['connection_id'] as String? ?? json['connectionId'] as String? ?? '',
      currentUserId: json['current_user_id'] as String? ?? json['currentUserId'] as String? ?? '',
      otherUserId: json['other_user_id'] as String? ?? json['otherUserId'] as String? ?? '',
      otherUserName: json['other_user_name'] as String? ?? json['otherUserName'] as String? ?? '',
      otherUserAvatarUrl: json['other_user_avatar_url'] as String? ?? 
                          json['otherUserAvatarUrl'] as String?,
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'] as Map<String, dynamic>)
          : json['lastMessage'] != null
              ? MessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>)
              : null,
      unreadCount: json['unread_count'] as int? ?? json['unreadCount'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'connection_id': connectionId,
      'current_user_id': currentUserId,
      'other_user_id': otherUserId,
      'other_user_name': otherUserName,
      'other_user_avatar_url': otherUserAvatarUrl,
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}
