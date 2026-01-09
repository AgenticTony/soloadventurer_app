import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/screens/journal_search_screen.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_search_provider.dart';

/// Example demonstrating JournalSearchScreen integration
///
/// This example shows:
/// 1. How to navigate to the search screen
/// 2. How to watch search state
/// 3. How to programmatically apply filters
/// 4. How to create custom search UI components
class JournalSearchExampleScreen extends ConsumerWidget {
  const JournalSearchExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Search Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example 1: Basic Navigation
          _ExampleCard(
            title: 'Example 1: Basic Search Screen',
            description: 'Navigate to the search screen with a button',
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JournalSearchScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Open Search'),
            ),
          ),
          const SizedBox(height: 16),

          // Example 2: Programmatic Search
          _ProgrammaticSearchExample(),
          const SizedBox(height: 16),

          // Example 3: Watch Search State
          _WatchStateExample(),
          const SizedBox(height: 16),

          // Example 4: Custom Filter UI
          _CustomFilterExample(),
        ],
      ),
    );
  }
}

/// Example 1: Basic Navigation to Search Screen
///
/// Use this pattern when you want to open the full search screen.
class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}

/// Example 2: Programmatic Search
///
/// Shows how to trigger searches programmatically with filters.
class _ProgrammaticSearchExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Example 2: Programmatic Search',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Trigger searches with predefined filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Search by text
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(journalSearchProvider.notifier).updateQuery('beach');
                    ref.read(journalSearchProvider.notifier).search();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Searching for "beach"...')),
                    );
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Search: Beach'),
                ),
                // Search by location
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(journalSearchProvider.notifier)
                        .updateLocationFilter('Paris');
                    ref.read(journalSearchProvider.notifier).search();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filtering by location: Paris')),
                    );
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text('Location: Paris'),
                ),
                // Search by date range
                ElevatedButton.icon(
                  onPressed: () {
                    final now = DateTime.now();
                    ref.read(journalSearchProvider.notifier).updateDateRangeFilter(
                          now.subtract(const Duration(days: 30)),
                          now,
                        );
                    ref.read(journalSearchProvider.notifier).search();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filtering: Last 30 days')),
                    );
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Last 30 Days'),
                ),
                // Search by mood
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(journalSearchProvider.notifier).updateMoodFilter('happy');
                    ref.read(journalSearchProvider.notifier).search();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filtering by mood: happy')),
                    );
                  },
                  icon: const Icon(Icons.emoji_emotions),
                  label: const Text('Mood: Happy'),
                ),
                // Search favorites
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(journalSearchProvider.notifier).updateFavoriteFilter(true);
                    ref.read(journalSearchProvider.notifier).search();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Showing favorites only')),
                    );
                  },
                  icon: const Icon(Icons.star),
                  label: const Text('Favorites'),
                ),
                // Clear filters
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(journalSearchProvider.notifier).clearAll();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filters cleared')),
                    );
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 3: Watch Search State
///
/// Shows how to watch and react to search state changes.
class _WatchStateExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(journalSearchProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Example 3: Watch Search State',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'React to search state changes in real-time',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            _StateDisplay(searchState: searchState),
          ],
        ),
      ),
    );
  }
}

class _StateDisplay extends StatelessWidget {
  final dynamic searchState;

  const _StateDisplay({required this.searchState});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Query
        _StatRow(
          label: 'Query:',
          value: searchState.filters.query.isEmpty
              ? '(empty)'
              : searchState.filters.query,
        ),
        // Active filters
        _StatRow(
          label: 'Active Filters:',
          value: '${searchState.filters.activeFilterCount}',
        ),
        // Result count
        _StatRow(
          label: 'Results:',
          value: '${searchState.resultCount}',
        ),
        // Loading state
        _StatRow(
          label: 'Searching:',
          value: searchState.isSearching ? 'Yes' : 'No',
        ),
        // Error state
        if (searchState.error != null)
          _StatRow(
            label: 'Error:',
            value: searchState.error ?? '',
            valueColor: Theme.of(context).colorScheme.error,
          ),
        // Initial state
        if (searchState.isInitial)
          _StatRow(
            label: 'State:',
            value: 'Initial (no search)',
            valueColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 4: Custom Filter UI
///
/// Shows how to create a custom UI for filtering entries.
class _CustomFilterExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(
      journalSearchProvider.select((state) => state.filters),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Example 4: Custom Filter UI',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Build custom filter interfaces for your needs',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // Quick filter buttons
            Text(
              'Quick Filters:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Today's entries
                FilterChip(
                  label: const Text('Today'),
                  selected: _isTodayFilterActive(filters),
                  onSelected: (selected) {
                    if (selected) {
                      final now = DateTime.now();
                      final start = DateTime(now.year, now.month, now.day);
                      final end = start.add(const Duration(days: 1));
                      ref.read(journalSearchProvider.notifier).updateDateRangeFilter(start, end);
                    } else {
                      ref.read(journalSearchProvider.notifier).updateDateRangeFilter(null, null);
                    }
                    ref.read(journalSearchProvider.notifier).search();
                  },
                ),
                // This week
                FilterChip(
                  label: const Text('This Week'),
                  selected: _isThisWeekFilterActive(filters),
                  onSelected: (selected) {
                    if (selected) {
                      final now = DateTime.now();
                      final start = now.subtract(Duration(days: now.weekday - 1));
                      final end = start.add(const Duration(days: 7));
                      ref.read(journalSearchProvider.notifier).updateDateRangeFilter(start, end);
                    } else {
                      ref.read(journalSearchProvider.notifier).updateDateRangeFilter(null, null);
                    }
                    ref.read(journalSearchProvider.notifier).search();
                  },
                ),
                // This month
                FilterChip(
                  label: const Text('This Month'),
                  selected: _isThisMonthFilterActive(filters),
                  onSelected: (selected) {
                    if (selected) {
                      final now = DateTime.now();
                      final start = DateTime(now.year, now.month, 1);
                      final end = DateTime(now.year, now.month + 1, 1);
                      ref.read(journalSearchProvider.notifier).updateDateRangeFilter(start, end);
                    } else {
                      ref.read(journalSearchProvider.notifier).updateDateRangeFilter(null, null);
                    }
                    ref.read(journalSearchProvider.notifier).search();
                  },
                ),
                // With photos (placeholder)
                FilterChip(
                  label: const Text('With Photos'),
                  selected: false,
                  onSelected: (selected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isTodayFilterActive(dynamic filters) {
    if (filters.startDate == null || filters.endDate == null) return false;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return filters.startDate!.isAtSameMomentAs(start) &&
        filters.endDate!.isAtSameMomentAs(end);
  }

  bool _isThisWeekFilterActive(dynamic filters) {
    if (filters.startDate == null || filters.endDate == null) return false;
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 7));
    return filters.startDate!.isAtSameMomentAs(start) &&
        filters.endDate!.isAtSameMomentAs(end);
  }

  bool _isThisMonthFilterActive(dynamic filters) {
    if (filters.startDate == null || filters.endDate == null) return false;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return filters.startDate!.isAtSameMomentAs(start) &&
        filters.endDate!.isAtSameMomentAs(end);
  }
}

/// Menu screen with navigation to all examples
class JournalSearchExampleMenu extends StatelessWidget {
  const JournalSearchExampleMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Search Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuCard(
            title: 'Full Search Screen',
            description: 'Complete search screen with all features',
            icon: Icons.search,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JournalSearchScreen(),
                ),
              );
            },
          ),
          _MenuCard(
            title: 'Search Examples',
            description: 'Various usage examples and patterns',
            icon: Icons.code,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JournalSearchExampleScreen(),
                ),
              );
            },
          ),
          _MenuCard(
            title: 'Custom Filter UI',
            description: 'Build custom filter interfaces',
            icon: Icons.filter_list,
            onTap: () {
              // Show custom filter example inline
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('See Search Examples for custom UI')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

// Usage in main app:
//
// MaterialApp(
//   routes: {
//     '/search': (context) => const JournalSearchScreen(),
//     '/search-examples': (context) => const JournalSearchExampleMenu(),
//   },
// )
