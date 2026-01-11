import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/widgets/offline_indicator.dart';

/// Example screen demonstrating the use of OfflineIndicator widgets
///
/// This file shows different ways to integrate offline indicators into your app:
/// 1. Compact indicator in AppBar
/// 2. Detailed indicator as standalone widget
/// 3. Offline banner at the top of the screen
class OfflineIndicatorExampleScreen extends ConsumerWidget {
  const OfflineIndicatorExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Indicator Example'),
        // Example 1: Compact indicator in app bar actions
        actions: const [
          OfflineIndicator(
            config: OfflineIndicatorConfig.compact(),
            onTap: _showOfflineInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Example 2: Offline banner at the top
          const OfflineBanner(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 16),
                Text(
                  'Offline Indicators',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),

                // Example 3: Detailed indicator
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detailed Indicator',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        const OfflineIndicator(
                          config: OfflineIndicatorConfig.detailed(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Example 4: Customized indicator
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customized Indicator',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        const OfflineIndicator(
                          config: OfflineIndicatorConfig.detailed(
                            offlineLabel: 'No Connection',
                            onlineLabel: 'Connected',
                            showLastSyncTime: true,
                            offlineIcon: Icons.wifi_off,
                            onlineIcon: Icons.wifi,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Example 5: Compact with custom configuration
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compact Indicator (Customized)',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OfflineIndicator(
                              config: OfflineIndicatorConfig.compact(
                                offlineIcon: Icons.signal_wifi_off,
                                onlineIcon: Icons.signal_wifi_4_bar,
                                showTooltip: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Text(
                  'Usage Tips:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  '• Use compact mode in AppBar actions for minimal intrusion\n'
                  '• Use detailed mode in settings or info sections\n'
                  '• Use banner mode for important offline notifications\n'
                  '• Customize icons and labels to match your app theme\n'
                  '• Add onTap callback to show more offline info\n'
                  '• The indicator automatically updates when connectivity changes',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOfflineInfo() {
    // Handle tap on offline indicator
    // Could show a dialog with more detailed offline information
  }
}

/// Example of integrating OfflineIndicator in a typical app screen
///
/// This shows how to add the indicator to an existing screen's AppBar
class TypicalAppScreen extends ConsumerWidget {
  const TypicalAppScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
        actions: const [
          // Add offline indicator to app bar
          OfflineIndicator(
            config: OfflineIndicatorConfig.compact(),
          ),
          // Other app bar actions...
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: null,
          ),
        ],
      ),
      body: const Center(
        child: Text('App Content'),
      ),
    );
  }
}

/// Example of using offline indicator in a floating UI
class FloatingOfflineIndicator extends ConsumerWidget {
  const FloatingOfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Main app content
        const Scaffold(
          body: Center(
            child: Text('App Content'),
          ),
        ),

        // Floating offline indicator (positioned)
        Positioned(
          top: 16,
          right: 16,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: const OfflineIndicator(
              config: OfflineIndicatorConfig.compact(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Example of integrating with offline banner in main app
class AppWithOfflineBanner extends ConsumerWidget {
  const AppWithOfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          // Offline banner at the top (shows only when offline)
          const OfflineBanner(),

          // App content
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: const Center(
                child: Text('App Content'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
