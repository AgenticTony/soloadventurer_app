import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/data/repositories/journal_repository_impl.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source_impl.dart';
import 'package:soloadventurer/features/journal/presentation/providers/memory_timeline_provider.dart';
import 'package:soloadventurer/features/journal/presentation/screens/memory_timeline_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Example screen demonstrating MemoryTimelineScreen integration
class MemoryTimelineExampleScreen extends StatelessWidget {
  const MemoryTimelineExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // Inject the journal repository
        journalRepositoryProvider.overrideWithValue(
          JournalRepositoryImpl(
            JournalRemoteDataSourceImpl(Supabase.instance.client),
          ),
        ),
      ],
      child: const MemoryTimelineScreen(),
    );
  }
}

/// Example menu showing different ways to use MemoryTimelineScreen
class MemoryTimelineExampleMenu extends StatelessWidget {
  const MemoryTimelineExampleMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Timeline Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExampleCard(
            title: 'Basic Memory Timeline',
            description:
                'Full timeline with all journal entries grouped by time',
            icon: Icons.timeline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MemoryTimelineExampleScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Timeline with ProviderScope',
            description: 'Manual provider injection example',
            icon: Icons.code,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _ProviderScopeExample(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Watch Timeline State',
            description: 'Monitor timeline state changes',
            icon: Icons.visibility,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _StateMonitoringExample(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Navigation from Home',
            description: 'Example of navigating from home screen',
            icon: Icons.home,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _NavigationExample(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Example card for menu items
class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example 1: Manual ProviderScope injection
class _ProviderScopeExample extends ConsumerWidget {
  const _ProviderScopeExample();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProviderScope Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text('MemoryTimelineScreen is displayed'),
            const SizedBox(height: 8),
            Text(
              'with ProviderScope injection',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 2: State monitoring
class _StateMonitoringExample extends ConsumerWidget {
  const _StateMonitoringExample();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineState = ref.watch(memoryTimelineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('State Monitoring'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timeline State',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _StateRow('Loading', timelineState.isLoading.toString()),
                    _StateRow(
                        'Has Error', (timelineState.error != null).toString()),
                    _StateRow('Error', timelineState.error ?? 'None'),
                    const SizedBox(height: 8),
                    _StateRow(
                        'Entry Count', timelineState.entryCount.toString()),
                    _StateRow(
                        'Group Count', timelineState.groupCount.toString()),
                    _StateRow(
                        'Has Content', timelineState.hasContent.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (timelineState.hasContent)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Groups',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      ...timelineState.groups.map((group) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Text(
                                  '${group.entryCount} entries',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateRow extends StatelessWidget {
  final String label;
  final String value;

  const _StateRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 3: Navigation from home
class _NavigationExample extends StatelessWidget {
  const _NavigationExample();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                'Navigate to Memory Timeline',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Example code for navigating from home screen or dashboard',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '// Code Example',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '''Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) =>
        const MemoryTimelineScreen(),
  ),
);''',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MemoryTimelineExampleScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Navigate Now'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
