import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_list_provider.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/journal_entry_card.dart';

/// Screen displaying all journal entries organized by trip or date
class JournalListScreen extends ConsumerStatefulWidget {
  const JournalListScreen({super.key});

  @override
  ConsumerState<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends ConsumerState<JournalListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final mode = _tabController.index == 0
          ? JournalListOrganization.byDate
          : JournalListOrganization.byTrip;
      ref.read(journalListProvider.notifier).setOrganizationMode(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(journalListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'By Date',
              icon: Icon(Icons.calendar_today),
              child: Semantics(
                label: 'By Date',
                selected: true,
                child: Text('By Date'),
              ),
            ),
            Tab(
              text: 'By Trip',
              icon: Icon(Icons.flight_takeoff),
              child: Semantics(
                label: 'By Trip',
                child: Text('By Trip'),
              ),
            ),
          ],
        ),
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/journal/search');
            },
            tooltip: 'Search entries',
            label: 'Search entries',
          ),
        ],
      ),
      body: listState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : listState.error != null
              ? _buildError(context, listState.error!)
              : !listState.hasEntries
                  ? _buildEmptyState(context)
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildByDateView(context, listState),
                        _buildByTripView(context, listState),
                      ],
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/journal/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
        tooltip: 'Create a new journal entry',
      ),
    );
  }

  /// Build error state
  Widget _buildError(BuildContext context, String error) {
    return Semantics(
      label: 'Error loading journal entries',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Error icon',
              child:
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Journal',
              style: Theme.of(context).textTheme.titleLarge,
              semanticsLabel: 'Error Loading Journal',
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              semanticsLabel: 'Error message: $error',
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(journalListProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Semantics(
      label: 'No journal entries yet',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Empty journal icon',
              child: Icon(
                Icons.book_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Journal Entries Yet',
              style: Theme.of(context).textTheme.titleLarge,
              semanticsLabel: 'No Journal Entries Yet',
            ),
            const SizedBox(height: 8),
            const Text(
              'Start documenting your travel adventures',
              semanticsLabel: 'Start documenting your travel adventures',
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/journal/create');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create First Entry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build view organized by date
  Widget _buildByDateView(BuildContext context, JournalListState state) {
    final groupedEntries = state.entriesByDate;

    if (groupedEntries.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(journalListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedEntries.keys.length,
        itemBuilder: (context, index) {
          final dateKey = groupedEntries.keys.elementAt(index);
          final entries = groupedEntries[dateKey]!;

          return _DateGroup(
            dateKey: dateKey,
            entries: entries,
          );
        },
      ),
    );
  }

  /// Build view organized by trip
  Widget _buildByTripView(BuildContext context, JournalListState state) {
    final groupedEntries = state.entriesByTrip;

    if (groupedEntries.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(journalListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedEntries.keys.length,
        itemBuilder: (context, index) {
          final tripId = groupedEntries.keys.elementAt(index);
          final entries = groupedEntries[tripId]!;

          return _TripGroup(
            tripId: tripId,
            entries: entries,
          );
        },
      ),
    );
  }
}

/// Widget for displaying a group of entries by date
class _DateGroup extends StatelessWidget {
  final String dateKey;
  final List entries;

  const _DateGroup({
    required this.dateKey,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      headingLevel: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    dateKey,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    semanticsLabel: 'Date: $dateKey',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.secondaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    semanticsLabel:
                        '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'} in this date',
                  ),
                ),
              ],
            ),
          ),

          // Entries for this date
          ...entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: JournalEntryCard(
                  entry: entry,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/journal/entry/${entry.id}',
                    );
                  },
                ),
              )),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Widget for displaying a group of entries by trip
class _TripGroup extends StatelessWidget {
  final String? tripId;
  final List entries;

  const _TripGroup({
    required this.tripId,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // For entries without a trip, show "Uncategorized"
    final tripName = tripId ?? 'Uncategorized Entries';

    return Semantics(
      headingLevel: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tripId == null
                            ? Icons.folder_outlined
                            : Icons.flight_takeoff,
                        size: 18,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tripName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                        semanticsLabel: 'Trip: $tripName',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.secondaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    semanticsLabel:
                        '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'} in this trip',
                  ),
                ),
              ],
            ),
          ),

          // Entries for this trip
          ...entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: JournalEntryCard(
                  entry: entry,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/journal/entry/${entry.id}',
                    );
                  },
                ),
              )),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
