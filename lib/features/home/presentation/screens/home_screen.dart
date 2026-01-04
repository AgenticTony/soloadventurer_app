import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';
import 'package:soloadventurer/features/core/presentation/widgets/queue_status_indicator.dart';
import 'package:soloadventurer/features/offline/presentation/widgets/connectivity_indicator.dart';
import 'package:soloadventurer/features/offline/presentation/widgets/sync_status_banner.dart';
import 'package:soloadventurer/features/offline/presentation/widgets/offline_banner.dart';
import 'package:soloadventurer/features/offline/presentation/routes/offline_routes.dart';

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
          const QueueStatusIndicator(),
          const ConnectivityIndicator(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, OfflineRoutes.syncSettings);
            },
            tooltip: 'Settings',
          ),
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
                ref
                    .read(authNavigationProvider.notifier)
                    .navigateToLogin(context);
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline mode banner (shows when offline)
          const OfflineBanner(),

          // Sync status banner (shows during sync, errors, or pending operations)
          const SyncStatusBanner(),

          // Main content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to SoloAdventurer!',
                    key: Key('home_screen_title'),
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AuthRoutes.cloudWatchTest);
                    },
                    child: const Text('Test CloudWatch Logging'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
