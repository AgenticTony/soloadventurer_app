import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:soloadventurer/features/matching/domain/entities/chat.dart';
import 'package:soloadventurer/features/matching/domain/entities/message.dart';
import 'package:soloadventurer/features/matching/presentation/providers/chat_provider.dart';
import 'package:soloadventurer/features/matching/presentation/screens/chat_list_screen.dart';

/// Fake chats for testing
final _testChats = [
  Chat(
    id: 'chat-1',
    connectionId: 'conn-1',
    currentUserId: 'user-1',
    otherUserId: 'user-2',
    otherUserName: 'Alice',
    otherUserAvatarUrl: null,
    lastMessage: Message(
      id: 'msg-1',
      chatId: 'chat-1',
      senderId: 'user-2',
      content: 'Hey, want to explore Paris together?',
      createdAt: DateTime(2024, 6, 15, 14, 30),
    ),
    unreadCount: 3,
    createdAt: DateTime(2024, 6, 14),
    updatedAt: DateTime(2024, 6, 15, 14, 30),
  ),
  Chat(
    id: 'chat-2',
    connectionId: 'conn-2',
    currentUserId: 'user-1',
    otherUserId: 'user-3',
    otherUserName: 'Bob',
    otherUserAvatarUrl: null,
    lastMessage: Message(
      id: 'msg-2',
      chatId: 'chat-2',
      senderId: 'user-1',
      content: 'Sure, let\'s meet at the museum!',
      createdAt: DateTime(2024, 6, 15, 10, 0),
    ),
    unreadCount: 0,
    createdAt: DateTime(2024, 6, 13),
    updatedAt: DateTime(2024, 6, 15, 10, 0),
  ),
];

/// GoRouter for testing navigation
GoRouter _testRouter(Widget child) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => child,
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:connectionId',
        builder: (context, state) {
          final connectionId = state.pathParameters['connectionId'] ?? '';
          return Scaffold(
            body: Text('Chat: $connectionId'),
          );
        },
      ),
    ],
  );
}

Widget createTestableWidget({
  required List<Chat> chats,
  bool loading = false,
  String? error,
}) {
  return ProviderScope(
    overrides: [
      chatsProvider.overrideWith((ref) async {
        if (error != null) throw Exception(error);
        return chats;
      }),
    ],
    child: MaterialApp(
      home: const ChatListScreen(),
    ),
  );
}

void main() {
  group('ChatListScreen - Sprint 2.1', () {
    testWidgets('renders chat tiles with correct data', (tester) async {
      await tester.pumpWidget(createTestableWidget(chats: _testChats));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(
        find.text('Hey, want to explore Paris together?'),
        findsOneWidget,
      );
    });

    testWidgets('shows unread badge count on chats with unread messages',
        (tester) async {
      await tester.pumpWidget(createTestableWidget(chats: _testChats));
      await tester.pumpAndSettle();

      // Alice has 3 unread
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows empty state when no chats', (tester) async {
      await tester.pumpWidget(createTestableWidget(chats: []));
      await tester.pumpAndSettle();

      expect(find.text('No conversations yet'), findsOneWidget);
      expect(find.text('Find travelers'), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(chats: [], error: 'Network error'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load conversations'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows Messages title in app bar', (tester) async {
      await tester.pumpWidget(createTestableWidget(chats: _testChats));
      await tester.pumpAndSettle();

      expect(find.text('Messages'), findsOneWidget);
    });

    testWidgets('shows back button in app bar', (tester) async {
      await tester.pumpWidget(createTestableWidget(chats: _testChats));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows chat bubble icon in empty state', (tester) async {
      await tester.pumpWidget(createTestableWidget(chats: []));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('shows avatar initials when no avatar URL', (tester) async {
      await tester.pumpWidget(createTestableWidget(chats: _testChats));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget); // Alice
      expect(find.text('B'), findsOneWidget); // Bob
    });

    testWidgets('tapping chat tile navigates to chat screen', (tester) async {
      final router = _testRouter(const SizedBox.shrink());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chatsProvider.overrideWith((ref) async => _testChats),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Navigate to chats screen
      router.push('/chats');
      await tester.pumpAndSettle();

      // Tap on Alice's chat
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      // Should show chat screen with connection ID
      expect(find.text('Chat: conn-1'), findsOneWidget);
    });

    testWidgets('chat tile shows time for today messages', (tester) async {
      final todayChat = Chat(
        id: 'chat-today',
        connectionId: 'conn-today',
        currentUserId: 'user-1',
        otherUserId: 'user-2',
        otherUserName: 'Today User',
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestableWidget(chats: [todayChat]));
      await tester.pumpAndSettle();

      // Should show time in HH:MM format
      final now = DateTime.now();
      final expected =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('Start the conversation shown when no last message',
        (tester) async {
      final emptyChat = Chat(
        id: 'chat-empty',
        connectionId: 'conn-empty',
        currentUserId: 'user-1',
        otherUserId: 'user-2',
        otherUserName: 'New Match',
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestableWidget(chats: [emptyChat]));
      await tester.pumpAndSettle();

      expect(find.text('Start the conversation!'), findsOneWidget);
    });
  });
}
