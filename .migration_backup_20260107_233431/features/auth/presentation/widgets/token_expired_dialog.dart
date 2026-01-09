import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_manager.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';

class TokenExpiredDialog extends ConsumerWidget {
  const TokenExpiredDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Session Expired'),
      content: const Text(
        'Your session has expired. Please sign in again to continue.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Clear the session and navigate to login
            ref.read(tokenManagerProvider.notifier).clearSession();
            ref.read(authNavigationProvider.notifier).navigateToLogin();
          },
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}
