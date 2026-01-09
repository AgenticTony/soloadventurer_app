import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/core/presentation/widgets/queue_status_indicator.dart';
import 'package:soloadventurer/features/offline/presentation/widgets/connectivity_indicator.dart';
import 'package:soloadventurer/features/offline/presentation/widgets/sync_status_banner.dart';
import 'package:soloadventurer/features/offline/presentation/widgets/offline_banner.dart';
import 'package:soloadventurer/features/offline/presentation/routes/offline_routes.dart';
import 'package:soloadventurer/features/safety/presentation/widgets/sos_button_widget.dart';
import 'package:soloadventurer/features/home/presentation/widgets/quick_sos_button.dart';

/// Home screen of the app
class HomeScreen extends ConsumerWidget {
  /// Creates a new [HomeScreen]
  const HomeScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);

    return authAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(authNotifierProvider);
                },
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(authNavigationProvider.notifier)
                      .navigateToLogin(null);
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
      data: (authState) {
        // Redirect to login if not authenticated
        if (!authState.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(authNavigationProvider.notifier).navigateToLogin(null);
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _buildHomeContent(context, ref, authState);
      },
    );
  }

  Widget _buildHomeContent(
      BuildContext context, WidgetRef ref, AuthState authState) {
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
                  Text(
                    'Welcome, ${authState.user?.username ?? 'Adventurer'}!',
                    key: const Key('home_screen_title'),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
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
                      onTap: () => ref
                          .read(authNavigationProvider.notifier)
                          .navigateToSafetyHub(),
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
                                      size: 32,
                                      color: Theme.of(context).primaryColor),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Check In',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
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
          ),
        ],
      ),
    );
  }
}
