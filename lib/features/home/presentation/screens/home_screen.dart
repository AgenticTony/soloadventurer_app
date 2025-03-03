import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier.dart';
import 'package:soloadventurer/features/profile/presentation/screens/profile_screen.dart';
import 'package:soloadventurer/features/profile/presentation/providers/profile_providers.dart';

/// The home screen of the app
class HomeScreen extends ConsumerWidget {
  /// Creates a new [HomeScreen]
  const HomeScreen({super.key});

  /// The route name for this screen
  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);
    final user = authState.user;

    print('HomeScreen build - authState: $authState');
    print('HomeScreen build - user: $user');
    print('HomeScreen build - isAuthenticated: ${authState.isAuthenticated}');
    print('HomeScreen build - isLoading: ${authState.isLoading}');
    print('HomeScreen build - error: ${authState.error}');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          key: Key('home_screen_title'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(authProvider.notifier).refreshToken();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Welcome, ${profileState.profile?.displayName ?? user?.username ?? 'User'}!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, ProfileScreen.routeName);
              },
              child: const Text('View Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
