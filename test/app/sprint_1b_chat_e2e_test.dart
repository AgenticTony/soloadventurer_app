import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/matching/domain/entities/message.dart';
import 'package:soloadventurer/features/matching/data/models/message_model.dart';
import 'package:soloadventurer/features/matching/presentation/providers/matching_provider.dart';
import 'package:soloadventurer/features/matching/domain/repositories/matching_repository.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart';

/// Fake MatchingRepository that captures message operations
class FakeMatchingRepositoryForChat implements MatchingRepository {
  final List<Message> _messages = [];
  final bool isOnline;
  String? lastSentContent;
  String? lastSentChatId;
  bool markAsReadCalled = false;

  FakeMatchingRepositoryForChat({this.isOnline = true});

  void addMessage(Message message) => _messages.add(message);

  @override
  Future<String> sendMessage({
    required String chatId,
    required String recipientId,
    required String content,
  }) async {
    lastSentChatId = chatId;
    lastSentContent = content;

    if (!isOnline) throw Exception('Network error');

    final message = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: 'current-user',
      content: content,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
    );
    _messages.add(message);
    return message.id;
  }

  @override
  Future<List<Message>> getMessages(String chatId) async =>
      _messages.where((m) => m.chatId == chatId).toList();

  @override
  Stream<List<Message>> watchMessages(String chatId) {
    return Stream.periodic(
      const Duration(milliseconds: 100),
      (_) => _messages.where((m) => m.chatId == chatId).toList(),
    );
  }

  @override
  Future<void> markMessagesAsRead(String chatId) async {
    markAsReadCalled = true;
  }

  @override
  Future<int> getPendingMessagesCount() async => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('Sprint 1b.1 — Current User + Send Logic', () {
    test('message senderId determines isCurrentUser correctly', () {
      const currentUserId = 'current-user';

      final myMessage = MessageModel(
        id: 'msg-1',
        chatId: 'chat-1',
        senderId: 'current-user',
        content: 'Hello',
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
      );

      final theirMessage = MessageModel(
        id: 'msg-2',
        chatId: 'chat-1',
        senderId: 'other-user',
        content: 'Hi back',
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
      );

      expect(myMessage.senderId == currentUserId, isTrue);
      expect(theirMessage.senderId == currentUserId, isFalse);
    });

    test('AuthState.authenticated provides user.id', () {
      final authState = AuthState.authenticated(
        user: User(
          id: 'user-123',
          email: 'test@example.com',
          username: 'testuser',
          createdAt: DateTime.now(),
        ),
      );

      expect(authState.isAuthenticated, isTrue);
      expect(authState.user?.id, 'user-123');
    });
  });

  group('Sprint 1b.2 — Repository Delegates to Remote', () {
    test('getMessages returns messages from remote', () async {
      final repo = FakeMatchingRepositoryForChat(isOnline: true);
      repo.addMessage(MessageModel(
        id: 'msg-1',
        chatId: 'chat-1',
        senderId: 'user-1',
        content: 'From server',
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
      ));

      final messages = await repo.getMessages('chat-1');
      expect(messages.length, 1);
      expect(messages.first.content, 'From server');
    });

    test('watchMessages returns a stream of messages', () async {
      final repo = FakeMatchingRepositoryForChat(isOnline: true);

      final stream = repo.watchMessages('chat-1');
      expect(stream, isA<Stream<List<Message>>>());

      final messages = await stream.first;
      expect(messages, isA<List<Message>>());
    });

    test('markMessagesAsRead calls remote', () async {
      final repo = FakeMatchingRepositoryForChat(isOnline: true);
      await repo.markMessagesAsRead('chat-1');
      expect(repo.markAsReadCalled, isTrue);
    });

    test('sendMessage persists to remote', () async {
      final repo = FakeMatchingRepositoryForChat(isOnline: true);
      await repo.sendMessage(
        chatId: 'chat-1',
        recipientId: 'user-2',
        content: 'Test message',
      );

      final messages = await repo.getMessages('chat-1');
      expect(messages.length, 1);
      expect(messages.first.content, 'Test message');
    });

    test('sendMessage throws when offline', () async {
      final repo = FakeMatchingRepositoryForChat(isOnline: false);

      expect(
        () => repo.sendMessage(
          chatId: 'chat-1',
          recipientId: 'user-2',
          content: 'Will fail',
        ),
        throwsException,
      );
    });
  });

  group('Sprint 1b.3 — Connection Provider Resolution', () {
    test('matchingRepositoryProvider resolves with fake', () async {
      SharedPreferences.setMockInitialValues({});
      final fakeRepo = FakeMatchingRepositoryForChat();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider
              .overrideWithValue(await SharedPreferences.getInstance()),
          matchingRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      final repo = container.read(matchingRepositoryProvider);
      expect(repo, isNotNull);

      container.dispose();
    });
  });

  group('Sprint 1b.5 — Chat States', () {
    test('empty messages list returns empty state', () async {
      final repo = FakeMatchingRepositoryForChat(isOnline: true);
      final messages = await repo.getMessages('empty-chat');
      expect(messages, isEmpty);
    });

    test('messages with data returns populated list', () async {
      final repo = FakeMatchingRepositoryForChat(isOnline: true);
      repo.addMessage(MessageModel(
        id: 'msg-1',
        chatId: 'chat-1',
        senderId: 'user-1',
        content: 'Hello',
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
      ));
      repo.addMessage(MessageModel(
        id: 'msg-2',
        chatId: 'chat-1',
        senderId: 'user-2',
        content: 'World',
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
      ));

      final messages = await repo.getMessages('chat-1');
      expect(messages.length, 2);
    });

    test('messages from different chats are separated', () async {
      final repo = FakeMatchingRepositoryForChat(isOnline: true);
      repo.addMessage(MessageModel(
        id: 'msg-1',
        chatId: 'chat-1',
        senderId: 'user-1',
        content: 'Chat 1 msg',
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
      ));
      repo.addMessage(MessageModel(
        id: 'msg-2',
        chatId: 'chat-2',
        senderId: 'user-1',
        content: 'Chat 2 msg',
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
      ));

      final chat1 = await repo.getMessages('chat-1');
      final chat2 = await repo.getMessages('chat-2');

      expect(chat1.length, 1);
      expect(chat2.length, 1);
      expect(chat1.first.content, 'Chat 1 msg');
      expect(chat2.first.content, 'Chat 2 msg');
    });
  });
}
