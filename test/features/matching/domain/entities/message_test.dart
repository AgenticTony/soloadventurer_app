import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/matching/domain/entities/message.dart';

void main() {
  group('Message', () {
    test('should create a message with all required fields', () {
      final message = Message(
        id: 'msg_123',
        chatId: 'chat_456',
        senderId: 'user_789',
        content: 'Hello!',
        status: MessageStatus.pending,
        createdAt: DateTime(2024, 1, 1, 12, 0),
      );

      expect(message.id, 'msg_123');
      expect(message.chatId, 'chat_456');
      expect(message.senderId, 'user_789');
      expect(message.content, 'Hello!');
      expect(message.status, MessageStatus.pending);
      expect(message.createdAt, DateTime(2024, 1, 1, 12, 0));
    });

    test('should create an empty message', () {
      final message = Message.empty();

      expect(message.isEmpty, true);
      expect(message.isNotEmpty, false);
      expect(message.id, '');
    });

    test('should correctly identify if sent by user', () {
      final message = Message(
        id: 'msg_123',
        chatId: 'chat_456',
        senderId: 'user_789',
        content: 'Hello!',
        createdAt: DateTime.now(),
      );

      expect(message.isSentBy('user_789'), true);
      expect(message.isSentBy('other_user'), false);
    });

    test('should identify pending messages', () {
      final pendingMessage = Message(
        id: 'msg_123',
        chatId: 'chat_456',
        senderId: 'user_789',
        content: 'Hello!',
        status: MessageStatus.pending,
        createdAt: DateTime.now(),
      );

      final sentMessage = Message(
        id: 'msg_456',
        chatId: 'chat_456',
        senderId: 'user_789',
        content: 'Hello!',
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
      );

      expect(pendingMessage.isPending, true);
      expect(sentMessage.isPending, false);
    });

    test('should identify failed messages', () {
      final failedMessage = Message(
        id: 'msg_123',
        chatId: 'chat_456',
        senderId: 'user_789',
        content: 'Hello!',
        status: MessageStatus.failed,
        createdAt: DateTime.now(),
      );

      expect(failedMessage.isFailed, true);
    });

    test('should copy with new values', () {
      final message = Message(
        id: 'msg_123',
        chatId: 'chat_456',
        senderId: 'user_789',
        content: 'Hello!',
        status: MessageStatus.pending,
        createdAt: DateTime.now(),
      );

      final updatedMessage = message.copyWith(
        status: MessageStatus.sent,
        serverId: 'server_msg_123',
      );

      expect(updatedMessage.status, MessageStatus.sent);
      expect(updatedMessage.serverId, 'server_msg_123');
      expect(updatedMessage.id, message.id);
      expect(updatedMessage.content, message.content);
    });
  });
}
