import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/repositories/journal_repository.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_list_provider.dart';
import 'package:soloadventurer/features/journal/presentation/screens/journal_list_screen.dart';

/// Example implementation showing how to integrate the JournalListScreen
///
/// This example demonstrates:
/// 1. Basic navigation to the journal list screen
/// 2. Provider setup and dependency injection
/// 3. State monitoring and observation
/// 4. Custom navigation patterns
void main() {
  runApp(
    const ProviderScope(
      child: JournalListExampleApp(),
    ),
  );
}

class JournalListExampleApp extends StatelessWidget {
  const JournalListExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journal List Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const JournalListExampleMenu(),
      onGenerateRoute: (settings) {
        // Handle routes
        if (settings.name == '/journal') {
          return MaterialPageRoute(
            builder: (context) => const JournalListScreen(),
          );
        }
        return null;
      },
    );
  }
}

/// Main menu for journal list examples
class JournalListExampleMenu extends StatelessWidget {
  const JournalListExampleMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal List Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Journal List Screen Examples',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Basic Navigation',
            description: 'Navigate to the journal list screen with default settings',
            icon: Icons.list,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Example1_BasicNavigation(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'State Monitoring',
            description: 'Monitor journal list state changes in real-time',
            icon: Icons.analytics,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Example2_StateMonitoring(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'Custom Navigation',
            description: 'Integrate with bottom navigation and custom routing',
            icon: Icons.navigation,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Example3_CustomNavigation(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'Provider Setup',
            description: 'Complete provider setup and dependency injection',
            icon: Icons.settings,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Example4_ProviderSetup(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Reusable example card widget
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================================
// Example 1: Basic Navigation
// ============================================================================

/// Example 1: Basic navigation to JournalListScreen
///
/// This demonstrates the simplest way to use the journal list screen
class Example1_BasicNavigation extends StatelessWidget {
  const Example1_BasicNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Navigation Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Journal List Screen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Tap the button below to navigate'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JournalListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Open Journal List'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 2: State Monitoring
// ============================================================================

/// Example 2: Monitor journal list state changes
///
/// This demonstrates how to observe and react to state changes
class Example2_StateMonitoring extends ConsumerWidget {
  const Example2_StateMonitoring({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(journalListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('State Monitoring Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Journal List State',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _StateRow('Loading', listState.isLoading.toString()),
            _StateRow('Has Entries', listState.hasEntries.toString()),
            _StateRow('Total Entries', '${listState.entries.length}'),
            _StateRow('Organization Mode', listState.organizationMode.toString()),
            _StateRow('Group Count', '${listState.groupCount}'),
            if (listState.error != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error: ${listState.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Entries by Date Groups',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${listState.entriesByDate.keys.length} date groups',
              style: const TextStyle(color: Colors.blue),
            ),
            const SizedBox(height: 24),
            const Text(
              'Entries by Trip Groups',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${listState.entriesByTrip.keys.length} trip groups',
              style: const TextStyle(color: Colors.blue),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(journalListProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}

// ============================================================================
// Example 3: Custom Navigation
// ============================================================================

/// Example 3: Custom navigation with bottom navigation bar
///
/// This demonstrates integration with app navigation patterns
class Example3_CustomNavigation extends ConsumerStatefulWidget {
  const Example3_CustomNavigation({super.key});

  @override
  ConsumerState<Example3_CustomNavigation> createState() =>
      _Example3_CustomNavigationState();
}

class _Example3_CustomNavigationState
    extends ConsumerState<Example3_CustomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeScreen(),
    const JournalListScreen(),
    const _ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.home, size: 64),
          const SizedBox(height: 16),
          const Text('Home Screen', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          const Text('Navigate to Journal tab to see entries'),
        ],
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 64),
          const SizedBox(height: 16),
          const Text('Profile Screen', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

// ============================================================================
// Example 4: Provider Setup
// ============================================================================

/// Example 4: Complete provider setup with mock data
///
/// This demonstrates how to set up providers with mock data for testing
class Example4_ProviderSetup extends ConsumerWidget {
  const Example4_ProviderSetup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Setup Example'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Provider Configuration',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'The JournalListScreen requires the following providers to be set up:',
          ),
          const SizedBox(height: 16),
          _CodeBlock('''
// 1. Journal Repository Provider (in journal_entry_providers.dart)
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  // Return your repository implementation
  return JournalRepositoryImpl(
    remoteDataSource: ref.watch(journalRemoteDataSourceProvider),
    localDataSource: ref.watch(journalLocalDataSourceProvider),
  );
});

// 2. Journal List Provider (auto-created in journal_list_provider.dart)
final journalListProvider = StateNotifierProvider<JournalListNotifier, JournalListState>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return JournalListNotifier(repository);
});

// Usage in ProviderScope:
ProviderScope(
  overrides: [
    journalRepositoryProvider.overrideWithValue(mockRepository),
  ],
  child: const JournalListScreen(),
)
          '''),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JournalListScreen(),
                ),
              );
            },
            icon: const Icon(Icons.visibility),
            label: const Text('View Journal List Screen'),
          ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String code;

  const _CodeBlock(this.code);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}
