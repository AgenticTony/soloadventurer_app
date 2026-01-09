import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';
import 'package:soloadventurer/features/performance/presentation/routes/performance_routes.dart';

/// Home screen of the app
class HomeScreen extends ConsumerWidget {
  /// Creates a new [HomeScreen]
  const HomeScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: const QuickSOSButton(
        size: SOSButtonSize.medium,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to SoloAdventurer!',
                    key: Key('home_screen_title'),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Safety Section
                  const Text(
                    'Safety',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  // Safety Hub Card
                  Card(
                    elevation: 2,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.shield, color: Colors.white),
                      ),
                      title: const Text('Safety Hub'),
                      subtitle: const Text(
                        'Trusted contacts, check-ins, and emergency features',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          ref.read(authNavigationProvider.notifier).navigateToSafetyHub(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Quick Actions Grid
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: InkWell(
                            onTap: () => ref
                                .read(authNavigationProvider.notifier)
                                .navigateToCheckInHome(),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Icon(Icons.check_circle,
                                      size: 32, color: Theme.of(context).primaryColor),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Check In',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: InkWell(
                            onTap: () => ref
                                .read(authNavigationProvider.notifier)
                                .navigateToEmergencySOS(),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Icon(Icons.emergency,
                                      size: 32, color: Colors.red.shade700),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Emergency',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Debug Section
                  const Text(
                    'Debug',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AuthRoutes.cloudWatchTest);
                    },
                    child: const Text('Test CloudWatch Logging'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AuthRoutes.cloudWatchTest);
              },
              child: const Text('Test CloudWatch Logging'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, PerformanceRoutes.benchmark);
              },
              child: const Text('Performance Benchmark'),
            ),
          ],
        ),
      ),
    );
  }
}
