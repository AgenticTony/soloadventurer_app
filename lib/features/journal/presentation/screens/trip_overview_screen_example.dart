import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/data/repositories/journal_repository_impl.dart';
import 'package:soloadventurer/features/journal/data/repositories/trip_repository_impl.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source_impl.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_remote_data_source_impl.dart';
import 'package:soloadventurer/features/journal/presentation/screens/trip_overview_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/trip_list_screen.dart';
import 'package:soloadventurer/features/journal/presentation/providers/trip_overview_provider.dart';
import 'package:soloadventurer/features/journal/presentation/providers/trip_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Example demonstrating TripOverviewScreen usage
class TripOverviewExample extends ConsumerWidget {
  const TripOverviewExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        // Override the journal repository provider
        tripOverviewProvider.overrideWith((ref) {
          final repository = ref.watch(journalRepositoryProvider);
          final notifier = TripOverviewNotifier(repository);
          return notifier;
        }),
      ],
      child: MaterialApp(
        title: 'Trip Overview Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const TripOverviewMenu(),
      ),
    );
  }
}

/// Menu screen for different trip overview examples
class TripOverviewMenu extends StatelessWidget {
  const TripOverviewMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Overview Examples'),
      ),
      body: ListView(
        children: [
          _buildExampleCard(
            context,
            title: 'View Trip Overview',
            description: 'Navigate to a trip and view all entries and media',
            icon: Icons.map,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TripListExample(),
                ),
              );
            },
          ),
          _buildExampleCard(
            context,
            title: 'Direct Trip Overview',
            description: 'Open trip overview with a specific trip ID',
            icon: Icons.direct,
            onTap: () {
              // Replace with actual trip ID from your app
              const tripId = 'your-trip-id-here';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TripOverviewScreen(tripId: tripId),
                ),
              );
            },
          ),
          _buildExampleCard(
            context,
            title: 'Trip Overview with Provider',
            description: 'Manually create and use the trip overview provider',
            icon: Icons.code,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProviderScopeExample(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Example showing trip list with navigation to overview
class TripListExample extends ConsumerWidget {
  const TripListExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
      ),
      body: const TripListScreen(),
    );
  }
}

/// Example showing direct provider usage
class ProviderScopeExample extends ConsumerStatefulWidget {
  const ProviderScopeExample({super.key});

  @override
  ConsumerState<ProviderScopeExample> createState() => _ProviderScopeExampleState();
}

class _ProviderScopeExampleState extends ConsumerState<ProviderScopeExample> {
  String? selectedTripId;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final overviewState = selectedTripId != null
        ? ref.watch(tripOverviewProvider(selectedTripId!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Scope Example'),
      ),
      body: Column(
        children: [
          // Trip selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Trip',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'trip1', child: Text('Trip 1')),
                DropdownMenuItem(value: 'trip2', child: Text('Trip 2')),
                DropdownMenuItem(value: 'trip3', child: Text('Trip 3')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedTripId = value;
                });
              },
            ),
          ),

          // Overview state display
          if (overviewState != null) ...[
            if (overviewState.isLoading)
              const CircularProgressIndicator()
            else if (overviewState.error != null)
              Text('Error: ${overviewState.error}')
            else ...[
              Text('Entries: ${overviewState.entryCount}'),
              Text('Media: ${overviewState.mediaCount}'),
              Text('Has Content: ${overviewState.hasContent}'),
            ],
          ],

          // Navigate to full screen button
          if (selectedTripId != null)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripOverviewScreen(tripId: selectedTripId!),
                  ),
                );
              },
              child: const Text('Open Full Trip Overview'),
            ),
        ],
      ),
    );
  }
}

/// Example showing repository setup and initialization
class RepositorySetupExample extends StatelessWidget {
  const RepositorySetupExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // Setup Supabase client
        supabaseClientProvider.overrideWithValue(Supabase.instance.client),

        // Setup data sources
        tripRemoteDataSourceProvider.overrideWithValue(
          TripRemoteDataSourceImpl(client: Supabase.instance.client),
        ),
        journalRemoteDataSourceProvider.overrideWithValue(
          JournalRemoteDataSourceImpl(client: Supabase.instance.client),
        ),

        // Setup repositories
        tripRepositoryProvider.overrideWithValue(
          TripRepositoryImpl(
            remoteDataSource: TripRemoteDataSourceImpl(
              client: Supabase.instance.client,
            ),
          ),
        ),
        journalRepositoryProvider.overrideWithValue(
          JournalRepositoryImpl(
            remoteDataSource: JournalRemoteDataSourceImpl(
              client: Supabase.instance.client,
            ),
          ),
        ),

        // Setup trip overview provider
        tripOverviewProvider.overrideWith((ref) {
          final repository = ref.watch(journalRepositoryProvider);
          final notifier = TripOverviewNotifier(repository);
          return notifier;
        }),
      ],
      child: const TripOverviewExample(),
    );
  }
}

/// Example showing navigation from trip detail to trip overview
class NavigationExample extends ConsumerWidget {
  const NavigationExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assuming you have a trip object
    final tripId = 'example-trip-id';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.article),
              label: const Text('View Trip Entries & Media'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripOverviewScreen(tripId: tripId),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'This will navigate to the trip overview screen\nshowing all entries and media for the trip.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example showing state monitoring
class StateMonitoringExample extends ConsumerWidget {
  const StateMonitoringExample({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewState = ref.watch(tripOverviewProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('State Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(tripOverviewProvider(tripId).notifier).refresh();
            },
          ),
        ],
      ),
      body: overviewState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : overviewState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Error: ${overviewState.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(tripOverviewProvider(tripId).notifier).clearError();
                        },
                        child: const Text('Clear Error'),
                      ),
                    ],
                  ),
                )
              : overviewState.hasContent
                  ? ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Entries: ${overviewState.entryCount}\n'
                            'Media: ${overviewState.mediaCount}\n'
                            'Sorted Entries: ${overviewState.sortedEntries.length}\n'
                            'Sorted Media: ${overviewState.sortedMedia.length}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        // Display entries
                        ...overviewState.sortedEntries.map((entry) => ListTile(
                              title: Text(entry.title),
                              subtitle: Text(entry.entryDate.toString()),
                            )),
                      ],
                    )
                  : const Center(child: Text('No content yet')),
    );
  }
}

/// Main example entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'your-supabase-url',
    anonKey: 'your-supabase-anon-key',
  );

  runApp(
    const ProviderScope(
      child: TripOverviewExample(),
    ),
  );
}

// =============================================================================
// Usage Snippets
// =============================================================================

/// Snippet 1: Basic Navigation
void snippet1_BasicNavigation(BuildContext context, String tripId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TripOverviewScreen(tripId: tripId),
    ),
  );
}

/// Snippet 2: Watch Provider State
void snippet2_WatchState(BuildContext context, WidgetRef ref, String tripId) {
  final state = ref.watch(tripOverviewProvider(tripId));

  if (state.isLoading) {
    // Show loading indicator
  } else if (state.error != null) {
    // Show error
  } else {
    // Display entries and media
    print('Entries: ${state.entryCount}');
    print('Media: ${state.mediaCount}');
  }
}

/// Snippet 3: Manual Refresh
void snippet3_Refresh(WidgetRef ref, String tripId) {
  ref.read(tripOverviewProvider(tripId).notifier).refresh();
}

/// Snippet 4: Clear Error
void snippet4_ClearError(WidgetRef ref, String tripId) {
  ref.read(tripOverviewProvider(tripId).notifier).clearError();
}

/// Snippet 5: Access Sorted Data
void snippet5_SortedData(WidgetRef ref, String tripId) {
  final state = ref.read(tripOverviewProvider(tripId));

  // Access sorted entries (newest first)
  final newestEntries = state.sortedEntries;

  // Access sorted media (newest first)
  final newestMedia = state.sortedMedia;

  print('Newest entry: ${newestEntries.first.title}');
  print('Newest media: ${newestMedia.first.fileName}');
}

/// Snippet 6: Check for Content
void snippet6_HasContent(WidgetRef ref, String tripId) {
  final state = ref.read(tripOverviewProvider(tripId));

  if (state.hasContent) {
    print('Trip has entries or media');
  } else {
    print('Trip is empty');
  }
}

/// Snippet 7: Provider Override for Testing
void snippet7_ProviderOverride() {
  ProviderScope(
    overrides: [
      journalRepositoryProvider.overrideWithValue(mockRepository),
    ],
    child: const TripOverviewScreen(tripId: 'test-trip'),
  );
}
