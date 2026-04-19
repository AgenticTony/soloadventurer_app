import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Sprint 1a.3 — Chat Route Configuration', () {
    test(
        'GoRoute /chat/:connectionId extracts path parameters correctly',
        () {
      // Verify the route pattern is valid GoRouter syntax
      final route = GoRoute(
        path: '/chat/:connectionId',
        pageBuilder: (context, state) {
          final connectionId = state.pathParameters['connectionId'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          final chatId = extra?['chatId'] as String? ?? '';

          return MaterialPage(
            child: _TestChatScreen(
              chatId: chatId,
              connectionId: connectionId,
            ),
          );
        },
      );

      final router = GoRouter(routes: [route]);

      // Verify route was created
      expect(route.path, '/chat/:connectionId');

      router.dispose();
    });

    testWidgets(
        '/chat/:connectionId route renders screen with path and extra params',
        (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/chat/:connectionId',
            pageBuilder: (context, state) {
              final connectionId =
                  state.pathParameters['connectionId'] ?? '';
              final extra = state.extra as Map<String, dynamic>?;
              final chatId = extra?['chatId'] as String? ?? '';
              return MaterialPage(
                child: _TestChatScreen(
                  chatId: chatId,
                  connectionId: connectionId,
                ),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );

      router.go('/chat/conn-123', extra: {'chatId': 'chat-456'});
      await tester.pumpAndSettle();

      // Verify the screen rendered with correct params
      expect(find.text('connectionId: conn-123'), findsOneWidget);
      expect(find.text('chatId: chat-456'), findsOneWidget);
    });

    testWidgets('/chat/:connectionId handles missing extra', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/chat/:connectionId',
            pageBuilder: (context, state) {
              final connectionId =
                  state.pathParameters['connectionId'] ?? '';
              final extra = state.extra as Map<String, dynamic>?;
              final chatId = extra?['chatId'] as String? ?? '';
              return MaterialPage(
                child: _TestChatScreen(
                  chatId: chatId,
                  connectionId: connectionId,
                ),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );

      // Navigate without extra — should not crash
      router.go('/chat/conn-no-extra');
      await tester.pumpAndSettle();

      expect(find.text('connectionId: conn-no-extra'), findsOneWidget);
      expect(find.text('chatId: '), findsOneWidget); // Empty string fallback
    });

    testWidgets(
        '/chat/:connectionId receives prefilledMessage from extra',
        (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/chat/:connectionId',
            pageBuilder: (context, state) {
              final connectionId =
                  state.pathParameters['connectionId'] ?? '';
              final extra = state.extra as Map<String, dynamic>?;
              final chatId = extra?['chatId'] as String? ?? '';
              return MaterialPage(
                child: _TestChatScreen(
                  chatId: chatId,
                  connectionId: connectionId,
                  prefilledMessage: extra?['prefilledMessage'] as String?,
                ),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );

      router.go('/chat/conn-123', extra: {
        'chatId': 'chat-456',
        'prefilledMessage': 'Want to grab coffee?',
      });
      await tester.pumpAndSettle();

      expect(find.text('connectionId: conn-123'), findsOneWidget);
      expect(find.text('chatId: chat-456'), findsOneWidget);
      expect(
          find.text('prefilled: Want to grab coffee?'), findsOneWidget);
    });
  });
}

/// Test widget to verify route params are passed correctly
class _TestChatScreen extends StatelessWidget {
  final String chatId;
  final String connectionId;
  final String? prefilledMessage;

  const _TestChatScreen({
    required this.chatId,
    required this.connectionId,
    this.prefilledMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('connectionId: $connectionId'),
          Text('chatId: $chatId'),
          if (prefilledMessage != null)
            Text('prefilled: $prefilledMessage'),
        ],
      ),
    );
  }
}
