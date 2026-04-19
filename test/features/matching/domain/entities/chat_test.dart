import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/matching/domain/entities/chat.dart';
import 'package:soloadventurer/features/matching/domain/entities/message.dart';

void main() {
  group('Chat', () {
    test('should create a chat with all required fields', () {
      final chat = Chat(
        id: 'chat_123',
        connectionId: 'conn_456',
        currentUserId: 'user_789',
        otherUserId: 'user_012',
        otherUserName: 'Alice',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(chat.id, 'chat_123');
      expect(chat.connectionId, 'conn_456');
      expect(chat.currentUserId, 'user_789');
      expect(chat.otherUserId, 'user_012');
      expect(chat.otherUserName, 'Alice');
    });

    test('should create an empty chat', () {
      final chat = Chat.empty();

      expect(chat.isEmpty, true);
      expect(chat.isNotEmpty, false);
      expect(chat.id, '');
    });

    test('should identify unread messages', () {
      final chatWithUnread = Chat(
        id: 'chat_123',
        connectionId: 'conn_456',
        currentUserId: 'user_789',
        otherUserId: 'user_012',
        otherUserName: 'Alice',
        unreadCount: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final chatNoUnread = Chat(
        id: 'chat_456',
        connectionId: 'conn_789',
        currentUserId: 'user_789',
        otherUserId: 'user_012',
        otherUserName: 'Bob',
        unreadCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(chatWithUnread.hasUnread, true);
      expect(chatNoUnread.hasUnread, false);
    });

    test('should generate last message preview', () {
      final shortMessage = Message(
        id: 'msg_123',
        chatId: 'chat_456',
        senderId: 'user_789',
        content: 'Hi!',
        createdAt: DateTime.now(),
      );

      final longMessage = Message(
        id: 'msg_456',
        chatId: 'chat_456',
        senderId: 'user_789',
        content: 'This is a very long message that should be truncated in the preview because it exceeds fifty characters',
        createdAt: DateTime.now(),
      );

      final chatWithShortMessage = Chat(
        id: 'chat_123',
        connectionId: 'conn_456',
        currentUserId: 'user_789',
        otherUserId: 'user_012',
        otherUserName: 'Alice',
        lastMessage: shortMessage,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final chatWithLongMessage = Chat(
        id: 'chat_456',
        connectionId: 'conn_789',
        currentUserId: 'user_789',
        otherUserId: 'user_012',
        otherUserName: 'Bob',
        lastMessage: longMessage,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final chatWithNoMessage = Chat(
        id: 'chat_789',
        connectionId: 'conn_012',
        currentUserId: 'user_789',
        otherUserId: 'user_012',
        otherUserName: 'Charlie',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(chatWithShortMessage.lastMessagePreview, 'Hi!');
      expect(chatWithLongMessage.lastMessagePreview.length, lessThanOrEqualTo(53)); // 50 chars + '...'
      expect(chatWithLongMessage.lastMessagePreview.endsWith('...'), true);
      expect(chatWithNoMessage.lastMessagePreview, '');
    });

    test('should copy with new values', () {
      final chat = Chat(
        id: 'chat_123',
        connectionId: 'conn_456',
        currentUserId: 'user_789',
        otherUserId: 'user_012',
        otherUserName: 'Alice',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedChat = chat.copyWith(
        otherUserName: 'Bob',
        unreadCount: 3,
      );

      expect(updatedChat.otherUserName, 'Bob');
      expect(updatedChat.unreadCount, 3);
      expect(updatedChat.id, chat.id);
      expect(updatedChat.connectionId, chat.connectionId);
    });
  });
}
