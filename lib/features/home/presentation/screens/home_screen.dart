import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';

/// Home screen of the app
class HomeScreen extends ConsumerWidget {
  /// Creates a new [HomeScreen]
  const HomeScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SoloAdventurer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () =>
                ref.read(authNavigationProvider.notifier).navigateToProfile(),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              debugPrint('Logout button pressed');
              await ref.read(authNotifierProvider.notifier).signOut();
              debugPrint('Sign out completed');

              if (context.mounted) {
                ref.read(authNavigationProvider.notifier).navigateToLogin();
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to SoloAdventurer!',
          key: Key('home_screen_title'),
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
