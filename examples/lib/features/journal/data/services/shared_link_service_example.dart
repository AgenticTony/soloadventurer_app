import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';
import 'package:soloadventurer/features/journal/presentation/providers/shared_link_providers.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/shared_link_creator.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/shared_link_manager.dart' hide SharedLinkCreator;
import 'package:soloadventurer/features/journal/presentation/widgets/public_trip_viewer.dart';

/// Examples demonstrating the Shared Links feature
///
/// This file contains comprehensive examples of:
/// - Creating shared links with various configurations
/// - Validating access to shared links
/// - Managing shared links
/// - UI integration patterns
/// - Error handling

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: SharedLinksExamplesMenu(),
      ),
    ),
  );
}

/// Main menu for all shared links examples
class SharedLinksExamplesMenu extends StatelessWidget {
  const SharedLinksExamplesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Links Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Shared Links Feature Examples',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comprehensive examples of creating, managing, and using shared links',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Creation Examples
          const Text(
            'Creation Examples',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _ExampleCard(
            title: '1. Public Link (No Password)',
            description: 'Create a shareable link with no password protection',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const Example1_PublicLink(),
              ),
            ),
          ),
          _ExampleCard(
            title: '2. Password Protected Link',
            description: 'Create a link with password protection',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const Example2_PasswordProtectedLink(),
              ),
            ),
          ),
          _ExampleCard(
            title: '3. Link with Expiration',
            description: 'Create a link that expires after a set date',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const Example3_ExpiringLink(),
              ),
            ),
          ),
          _ExampleCard(
            title: '4. Full Options Link',
            description: 'Password + Expiration + Custom Settings',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const Example4_FullOptionsLink(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Validation Examples
          const Text(
            'Access & Validation Examples',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _ExampleCard(
            title: '5. View Public Link',
            description: 'Access a shared link without password',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const Example5_ViewPublicLink(),
              ),
            ),
          ),
          _ExampleCard(
            title: '6. View Protected Link',
            description: 'Access a password-protected shared link',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const Example6_ViewProtectedLink(),
              ),
            ),
          ),
          _ExampleCard(
            title: '7. View Expired Link',
            description: 'Handle expired shared links',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const Example7_ViewExpiredLink(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Management Examples
          const Text(
            'Management Examples',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _ExampleCard(
            title: '8. Link Manager',
            description: 'View and manage all shared links for a trip',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const Example8_LinkManager(),
              ),
            ),
          ),
          _ExampleCard(
            title: '9. Link Statistics',
            description: 'View detailed statistics for a shared link',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const Example9_LinkStatistics(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Advanced Examples
          const Text(
            'Advanced Examples',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _ExampleCard(
            title: '10. State Management',
            description: 'Monitor link creation and validation state',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const Example10_StateManagement(),
              ),
            ),
          ),
          _ExampleCard(
            title: '11. Error Handling',
            description: 'Handle various error scenarios',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const Example11_ErrorHandling(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 1: Public Link (No Password)
// ============================================================================

class Example1_PublicLink extends ConsumerWidget {
  const Example1_PublicLink({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 1: Public Link')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Create a Public Link',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'This will create a shareable link with no password protection. '
                'Anyone with the link can view the trip.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SharedLinkCreator(
                      tripId: 'demo-trip-1',
                      tripName: 'Summer Vacation 2024',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Public Link'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Code Example:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('''
final config = CreateSharedLinkConfig(
  tripId: 'trip-123',
);

final link = await service.createSharedLink(config);
print('Share URL: \${link.shareUrl}');'''),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 2: Password Protected Link
// ============================================================================

class Example2_PasswordProtectedLink extends ConsumerStatefulWidget {
  const Example2_PasswordProtectedLink({super.key});

  @override
  ConsumerState<Example2_PasswordProtectedLink> createState() =>
      _Example2_PasswordProtectedLinkState();
}

class _Example2_PasswordProtectedLinkState
    extends ConsumerState<Example2_PasswordProtectedLink> {
  final _passwordController = TextEditingController();
  SharedLink? _createdLink;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createProtectedLink() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _error = 'Please enter a password');
      return;
    }

    try {
      final service = ref.read(sharedLinkServiceProvider);
      final config = CreateSharedLinkConfig(
        tripId: 'demo-trip-2',
        password: _passwordController.text,
      );

      final link = await service.createSharedLink(config);
      setState(() {
        _createdLink = link;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 2: Password Protected')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Create Password Protected Link',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Only users with the correct password can access this link.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _createProtectedLink,
              icon: const Icon(Icons.add),
              label: const Text('Create Protected Link'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (_createdLink != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Link Created!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text('URL: ${_createdLink!.shareUrl}'),
              Text('Has Password: ${_createdLink!.hasPassword}'),
            ],
            const SizedBox(height: 32),
            const Text(
              'Code Example:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('''
final config = CreateSharedLinkConfig(
  tripId: 'trip-123',
  password: 'mySecretPassword',
);

final link = await service.createSharedLink(config);
print('Has Password: \${link.hasPassword}');'''),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 3: Link with Expiration
// ============================================================================

class Example3_ExpiringLink extends ConsumerStatefulWidget {
  const Example3_ExpiringLink({super.key});

  @override
  ConsumerState<Example3_ExpiringLink> createState() =>
      _Example3_ExpiringLinkState();
}

class _Example3_ExpiringLinkState extends ConsumerState<Example3_ExpiringLink> {
  DateTime? _expirationDate;
  SharedLink? _createdLink;

  Future<void> _selectExpiration() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null) {
      setState(() => _expirationDate = selected);
    }
  }

  Future<void> _createExpiringLink() async {
    if (_expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an expiration date')),
      );
      return;
    }

    final service = ref.read(sharedLinkServiceProvider);
    final config = CreateSharedLinkConfig(
      tripId: 'demo-trip-3',
      expiresAt: _expirationDate,
    );

    final link = await service.createSharedLink(config);
    setState(() => _createdLink = link);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 3: Expiring Link')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.timer, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Create Link with Expiration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _selectExpiration,
              icon: const Icon(Icons.calendar_today),
              label: Text(_expirationDate == null
                  ? 'Select Expiration Date'
                  : 'Expires: ${DateFormat('MMM dd, yyyy').format(_expirationDate!)}'),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _createExpiringLink,
              icon: const Icon(Icons.add),
              label: const Text('Create Expiring Link'),
            ),
            if (_createdLink != null) ...[
              const SizedBox(height: 24),
              Text('Expires: ${_createdLink!.expiresAt}'),
              Text('Is Expired: ${_createdLink!.isExpired}'),
            ],
            const SizedBox(height: 32),
            const Text(
              'Code Example:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('''
final config = CreateSharedLinkConfig(
  tripId: 'trip-123',
  expiresAt: DateTime(2024, 12, 31),
);

final link = await service.createSharedLink(config);
print('Expires: \${link.expiresAt}');'''),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 4: Full Options Link
// ============================================================================

class Example4_FullOptionsLink extends ConsumerWidget {
  const Example4_FullOptionsLink({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 4: Full Options')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.settings, size: 64),
              const SizedBox(height: 24),
              const Text(
                'Create Link with All Options',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SharedLinkCreator(
                        tripId: 'demo-trip-4',
                        tripName: 'Adventure Trip',
                      ),
                    ),
                  );
                },
                child: const Text('Open Link Creator'),
              ),
              const SizedBox(height: 32),
              const Text(
                'Code Example:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('''
final config = CreateSharedLinkConfig(
  tripId: 'trip-123',
  password: 'securePassword123',
  expiresAt: DateTime.now().add(Duration(days: 30)),
);

final link = await service.createSharedLink(config);
print('URL: \${link.shareUrl}');
print('Password Protected: \${link.hasPassword}');
print('Expires: \${link.expiresAt}');'''),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 5: View Public Link
// ============================================================================

class Example5_ViewPublicLink extends StatelessWidget {
  const Example5_ViewPublicLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 5: View Public Link')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.public, size: 64),
            const SizedBox(height: 24),
            const Text(
              'View Public Trip',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Access a shared trip without password',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PublicTripViewer(
                      slug: 'example-public-slug',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View Public Trip'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Code Example:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('''
final result = await service.validateAccess(
  slug: 'public-slug',
);

if (result.isAccessible) {
  await service.recordView('public-slug');
  // Load and display trip
}'''),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 6: View Protected Link
// ============================================================================

class Example6_ViewProtectedLink extends StatelessWidget {
  const Example6_ViewProtectedLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 6: View Protected Link')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 24),
            const Text(
              'View Protected Trip',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Password required to access this trip',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PublicTripViewer(
                      slug: 'example-protected-slug',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.lock_open),
              label: const Text('View Protected Trip'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Code Example:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('''
// First attempt without password
var result = await service.validateAccess(
  slug: 'protected-slug',
);

if (result.requiresPassword) {
  // Show password prompt, user enters password
  result = await service.validateAccess(
    slug: 'protected-slug',
    password: 'userInput',
  );
}

if (result.isAccessible) {
  await service.recordView('protected-slug');
  // Load trip
}'''),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 7: View Expired Link
// ============================================================================

class Example7_ViewExpiredLink extends StatelessWidget {
  const Example7_ViewExpiredLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 7: Expired Link')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_off, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Expired Link Handling',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Handle expired links gracefully',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PublicTripViewer(
                      slug: 'example-expired-slug',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.error),
              label: const Text('View Expired Link'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Code Example:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('''
final result = await service.validateAccess(
  slug: 'expired-slug',
);

if (result.isExpired) {
  // Show expired message
  showDialog(
    context: context,
    builder: (_) => ExpiredDialog(),
  );
} else if (result.isAccessible) {
  // Load trip
}'''),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 8: Link Manager
// ============================================================================

class Example8_LinkManager extends StatelessWidget {
  const Example8_LinkManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 8: Link Manager')),
      body: const SharedLinkManager(
        tripId: 'demo-trip-manager',
        tripName: 'European Adventure',
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 9: Link Statistics
// ============================================================================

class Example9_LinkStatistics extends ConsumerWidget {
  const Example9_LinkStatistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(sharedLinkStatisticsProvider('demo-link-id'));

    return Scaffold(
      appBar: AppBar(title: const Text('Example 9: Link Statistics')),
      body: statsAsync.when(
        data: (stats) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bar_chart, size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Shared Link Statistics',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                _StatRow('Total Views', stats.totalViews.toString()),
                _StatRow(
                  'Last Viewed',
                  stats.lastViewedAt != null
                      ? DateFormat('MMM dd, yyyy - HH:mm')
                          .format(stats.lastViewedAt!)
                      : 'Never',
                ),
                _StatRow('Days Active', stats.daysSinceCreation.toString()),
                _StatRow(
                  'Avg Views/Day',
                  stats.averageViewsPerDay.toStringAsFixed(1),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 10: State Management
// ============================================================================

class Example10_StateManagement extends ConsumerWidget {
  const Example10_StateManagement({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createState = ref.watch(createSharedLinkNotifierProvider);
    final validateState = ref.watch(validateLinkNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Example 10: State Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Link Creation State',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _StateCard('Is Creating', createState.isCreating.toString()),
            _StateCard('Error', createState.errorMessage ?? 'None'),
            _StateCard(
              'Created Link',
              createState.createdLink?.shareUrl ?? 'None',
            ),
            const SizedBox(height: 32),
            const Text(
              'Validation State',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _StateCard('Is Validating', validateState.isValidating.toString()),
            _StateCard('Error', validateState.errorMessage ?? 'None'),
            _StateCard(
              'Is Accessible',
              validateState.result?.isAccessible.toString() ?? 'N/A',
            ),
            _StateCard(
              'Requires Password',
              validateState.result?.requiresPassword.toString() ?? 'N/A',
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                final notifier =
                    ref.read(createSharedLinkNotifierProvider.notifier);
                notifier.createLink(
                  const CreateSharedLinkConfig(tripId: 'demo-state-trip'),
                );
              },
              child: const Text('Create Link (Watch State Changes)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final String label;
  final String value;

  const _StateCard(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 11: Error Handling
// ============================================================================

class Example11_ErrorHandling extends ConsumerWidget {
  const Example11_ErrorHandling({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 11: Error Handling')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Error Handling Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _handleNotFoundError(context),
              icon: const Icon(Icons.link_off),
              label: const Text('Handle Not Found'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _handleExpiredError(context),
              icon: const Icon(Icons.timer_off),
              label: const Text('Handle Expired'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _handleInvalidPassword(context),
              icon: const Icon(Icons.lock),
              label: const Text('Handle Invalid Password'),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('''
try {
  final result = await service.validateAccess(
    slug: slug,
    password: password,
  );

  if (result.isAccessible) {
    // Success
  } else if (result.isExpired) {
    // Show expired message
  } else if (result.requiresPassword) {
    // Show password prompt
  }
} on SharedLinkException catch (e) {
  // Handle specific errors
  switch (e.code) {
    case 'not_found':
      // Show not found UI
      break;
    case 'expired':
      // Show expired UI
      break;
    case 'invalid_password':
      // Show invalid password message
      break;
    default:
      // Show generic error
  }
}'''),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotFoundError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shared link not found or deactivated')),
    );
  }

  void _handleExpiredError(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Link Expired'),
        content: const Text('This shared link has expired.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleInvalidPassword(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid password. Please try again.')),
    );
  }
}
