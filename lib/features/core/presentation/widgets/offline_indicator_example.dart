import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/core/presentation/widgets/offline_indicator.dart';

/// Example screen demonstrating all offline indicator modes
class OfflineIndicatorExampleScreen extends ConsumerStatefulWidget {
  const OfflineIndicatorExampleScreen({super.key});

  @override
  ConsumerState<OfflineIndicatorExampleScreen> createState() =>
      _OfflineIndicatorExampleScreenState();
}

class _OfflineIndicatorExampleScreenState
    extends ConsumerState<OfflineIndicatorExampleScreen> {
  int _selectedExample = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Indicator Examples'),
      ),
      body: Column(
        children: [
          // Example selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Banner'),
                  icon: Icon(Icons.vertical_align_top),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Status Bar'),
                  icon: Icon(Icons.vertical_align_center),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text('Badge'),
                  icon: Icon(Icons.circle),
                ),
                ButtonSegment(
                  value: 3,
                  label: Text('Snackbar'),
                  icon: Icon(Icons.message),
                ),
              ],
              selected: {_selectedExample},
              onSelectionChanged: (Set<int> selected) {
                setState(() => _selectedExample = selected.first);
              },
            ),
          ),
          const Divider(),
          // Example content
          Expanded(
            child: _buildExample(_selectedExample),
          ),
        ],
      ),
    );
  }

  Widget _buildExample(int index) {
    switch (index) {
      case 0:
        return _BannerExample();
      case 1:
        return _StatusBarExample();
      case 2:
        return _BadgeExample();
      case 3:
        return _SnackbarExample();
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Example 1: Banner Mode
///
/// The banner mode shows a full-width indicator at the top of the screen.
/// This is useful for persistent offline indication across the app.
class _BannerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 80,
                    color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Banner Mode',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Toggle your device\'s connection to see the banner indicator '
                    'appear at the top of the screen.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Turn off WiFi/Mobile to see the indicator',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('How to Test'),
                  ),
                ],
              ),
            ),
          ),
          // Offline indicator (banner mode)
          const OfflineIndicator.banner(
            message: 'You\'re offline. Some features may be limited.',
          ),
        ],
      ),
    );
  }
}

/// Example 2: Status Bar Mode
///
/// The status bar mode shows a thin, less intrusive indicator at the top.
/// This is useful when you want to show offline status without blocking content.
class _StatusBarExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          ListView.builder(
            padding: const EdgeInsets.only(top: 40),
            itemCount: 20,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text('Item ${index + 1}'),
                subtitle: Text('Description for item ${index + 1}'),
              );
            },
          ),
          // Offline indicator (status bar mode)
          const OfflineIndicator.statusBar(
            message: 'No connection',
          ),
        ],
      ),
    );
  }
}

/// Example 3: Badge Mode
///
/// The badge mode shows a small indicator in the corner of the screen.
/// This is useful for subtle offline indication.
class _BadgeExample extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BadgeExample> createState() => _BadgeExampleState();
}

class _BadgeExampleState extends ConsumerState<_BadgeExample> {
  OfflineIndicatorPosition _position = OfflineIndicatorPosition.topRight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Badge Mode'),
        actions: [
          PopupMenuButton<OfflineIndicatorPosition>(
            icon: const Icon(Icons.more_vert),
            onSelected: (position) {
              setState(() => _position = position);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: OfflineIndicatorPosition.topLeft,
                child: Text('Top Left'),
              ),
              const PopupMenuItem(
                value: OfflineIndicatorPosition.topRight,
                child: Text('Top Right'),
              ),
              const PopupMenuItem(
                value: OfflineIndicatorPosition.bottomLeft,
                child: Text('Bottom Left'),
              ),
              const PopupMenuItem(
                value: OfflineIndicatorPosition.bottomRight,
                child: Text('Bottom Right'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 80),
                const SizedBox(height: 16),
                Text(
                  'Badge Position: ${_position.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text('Tap the menu to change position'),
              ],
            ),
          ),
          // Offline indicator (badge mode)
          OfflineIndicator.badge(
            position: _position,
            offset: const Offset(16, 16),
          ),
        ],
      ),
    );
  }
}

/// Example 4: Snackbar Mode
///
/// The snackbar mode shows a floating notification that can be dismissed.
/// This is useful for temporary offline notifications.
class _SnackbarExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 80,
                    color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Snackbar Mode',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Shows a dismissible notification when offline.\n'
                    'Tap X to dismiss the indicator.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Offline indicator (snackbar mode)
          const OfflineIndicator.snackbar(
            message: 'You\'re offline. Some features may be limited.',
            autoDismissDuration: Duration(seconds: 10),
          ),
        ],
      ),
    );
  }
}

/// Example 5: Integration with App Scaffold
///
/// This shows how to integrate the offline indicator into your app's
/// main scaffold structure.
class OfflineIndicatorAppExample extends ConsumerWidget {
  const OfflineIndicatorAppExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: Stack(
        children: [
          // Your app's main content
          const _AppContent(),

          // Offline indicator overlay
          const OfflineIndicator.banner(
            message: 'You\'re offline. Some features may be limited.',
          ),
        ],
      ),
    );
  }
}

class _AppContent extends StatelessWidget {
  const _AppContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'My App Content',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const Text('Toggle connection to see the offline indicator'),
        ],
      ),
    );
  }
}

/// Example 6: Custom Configuration
///
/// This shows how to create a custom offline indicator configuration
class CustomOfflineIndicatorExample extends StatelessWidget {
  const CustomOfflineIndicatorExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const Center(
            child: Text('Custom Config Example'),
          ),
          OfflineIndicator(
            config: OfflineIndicatorConfig(
              showIcon: true,
              showMessage: true,
              message: 'No Internet Connection',
              mode: OfflineIndicatorMode.banner,
              backgroundColor: theme.colorScheme.surface,
              textColor: theme.colorScheme.onSurface,
              icon: Icons.signal_wifi_off,
              borderRadius: 12,
              animate: true,
              animationDuration: const Duration(milliseconds: 500),
              showDismissButton: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 7: Global Offline Indicator
///
/// This shows how to add a global offline indicator that appears
/// across all screens in your app.
///
/// Add this to your app's root widget or main scaffold:
/// ```dart
/// Widget build(BuildContext context) {
///   return Stack(
///     children: [
///       // Your app's navigation and content
///       Navigator(...),
///
///       // Global offline indicator
///       const OfflineIndicator.banner(),
///     ],
///   );
/// }
/// ```

/// Example 8: With Callbacks
///
/// This shows how to use callbacks to track when the indicator
/// is shown and hidden.
class OfflineIndicatorWithCallbacksExample extends ConsumerStatefulWidget {
  const OfflineIndicatorWithCallbacksExample({super.key});

  @override
  ConsumerState<OfflineIndicatorWithCallbacksExample> createState() =>
      _OfflineIndicatorWithCallbacksExampleState();
}

class _OfflineIndicatorWithCallbacksExampleState
    extends ConsumerState<OfflineIndicatorWithCallbacksExample> {
  String _lastEvent = 'None';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 80),
                const SizedBox(height: 24),
                Text(
                  'Last Event: $_lastEvent',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text('Toggle connection to see events'),
              ],
            ),
          ),
          OfflineIndicator(
            config: const OfflineIndicatorConfig.badge(),
            position: OfflineIndicatorPosition.topRight,
            onShow: () {
              setState(() => _lastEvent = 'Shown at ${DateTime.now()}');
              // You can trigger actions here like:
              // - Pausing data sync
              // - Showing a toast
              // - Logging analytics
            },
            onHide: () {
              setState(() => _lastEvent = 'Hidden at ${DateTime.now()}');
              // You can trigger actions here like:
              // - Resuming data sync
              // - Clearing cache
              // - Showing "back online" message
            },
          ),
        ],
      ),
    );
  }
}

/// Main menu for all examples
class OfflineIndicatorExampleMenu extends StatelessWidget {
  const OfflineIndicatorExampleMenu({super.key});

  static const List<Map<String, dynamic>> _examples = [
    {
      'title': 'Banner Mode',
      'description': 'Full-width indicator at top of screen',
      'icon': Icons.vertical_align_top,
      'widget': OfflineIndicatorExampleScreen(),
    },
    {
      'title': 'Status Bar Mode',
      'description': 'Thin, subtle status bar indicator',
      'icon': Icons.vertical_align_center,
      'widget': OfflineIndicatorExampleScreen(),
    },
    {
      'title': 'Badge Mode',
      'description': 'Small badge in corner',
      'icon': Icons.circle,
      'widget': OfflineIndicatorExampleScreen(),
    },
    {
      'title': 'Snackbar Mode',
      'description': 'Floating notification with dismiss button',
      'icon': Icons.message,
      'widget': OfflineIndicatorExampleScreen(),
    },
    {
      'title': 'App Integration',
      'description': 'Integration with app scaffold',
      'icon': Icons.integration_instructions,
      'widget': OfflineIndicatorAppExample(),
    },
    {
      'title': 'Custom Config',
      'description': 'Custom styling and behavior',
      'icon': Icons.palette,
      'widget': CustomOfflineIndicatorExample(),
    },
    {
      'title': 'With Callbacks',
      'description': 'Track show/hide events',
      'icon': Icons.event,
      'widget': OfflineIndicatorWithCallbacksExample(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Indicator Examples'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _examples.length,
        itemBuilder: (context, index) {
          final example = _examples[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(example['icon']),
              title: Text(example['title']),
              subtitle: Text(example['description']),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => example['widget'],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
