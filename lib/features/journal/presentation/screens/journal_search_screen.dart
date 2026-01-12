import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_search_provider.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/journal_search_filter_sheet.dart';

/// Screen for searching and filtering journal entries
class JournalSearchScreen extends ConsumerStatefulWidget {
  const JournalSearchScreen({super.key});

  @override
  ConsumerState<JournalSearchScreen> createState() =>
      _JournalSearchScreenState();
}

class _JournalSearchScreenState extends ConsumerState<JournalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debouncer.run(() {
      ref
          .read(journalSearchProvider.notifier)
          .updateQuery(_searchController.text);
      ref.read(journalSearchProvider.notifier).search();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Journal'),
        actions: [
          // Filter button
          Consumer(
            builder: (context, ref, child) {
              final filterCount = ref.watch(
                journalSearchProvider
                    .select((state) => state.filters.activeFilterCount),
              );

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilterSheet(context),
                  ),
                  if (filterCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          filterCount.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onError,
                                fontSize: 10,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Clear filters button
          Consumer(
            builder: (context, ref, child) {
              final hasFilters = ref.watch(
                journalSearchProvider
                    .select((state) => state.filters.hasActiveFilters),
              );

              if (!hasFilters) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.filter_list_off),
                onPressed: () {
                  ref.read(journalSearchProvider.notifier).clearFilters();
                  _searchController.clear();
                },
                tooltip: 'Clear filters',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer(
              builder: (context, ref, child) {
                final query = ref.watch(
                  journalSearchProvider.select((state) => state.filters.query),
                );

                return SearchBar(
                  controller: _searchController,
                  hintText: 'Search journal entries...',
                  leading: const Icon(Icons.search),
                  trailing: query.isNotEmpty
                      ? [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          ),
                        ]
                      : null,
                );
              },
            ),
          ),

          // Active filters chips
          Consumer(
            builder: (context, ref, child) {
              final filters = ref.watch(
                journalSearchProvider.select((state) => state.filters),
              );

              if (!filters.hasActiveFilters) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (filters.locationName != null)
                      _FilterChip(
                        label: filters.locationName!,
                        icon: Icons.location_on,
                        onDeleted: () {
                          ref
                              .read(journalSearchProvider.notifier)
                              .updateLocationFilter(null);
                          ref.read(journalSearchProvider.notifier).search();
                        },
                      ),
                    if (filters.startDate != null || filters.endDate != null)
                      _FilterChip(
                        label: _formatDateRange(
                            filters.startDate, filters.endDate),
                        icon: Icons.calendar_today,
                        onDeleted: () {
                          ref
                              .read(journalSearchProvider.notifier)
                              .updateDateRangeFilter(null, null);
                          ref.read(journalSearchProvider.notifier).search();
                        },
                      ),
                    if (filters.mood != null)
                      _FilterChip(
                        label: filters.mood!,
                        icon: Icons.emoji_emotions,
                        onDeleted: () {
                          ref
                              .read(journalSearchProvider.notifier)
                              .updateMoodFilter(null);
                          ref.read(journalSearchProvider.notifier).search();
                        },
                      ),
                    if (filters.favoriteOnly == true)
                      _FilterChip(
                        label: 'Favorites',
                        icon: Icons.star,
                        onDeleted: () {
                          ref
                              .read(journalSearchProvider.notifier)
                              .updateFavoriteFilter(null);
                          ref.read(journalSearchProvider.notifier).search();
                        },
                      ),
                  ],
                ),
              );
            },
          ),

          // Search results
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final searchState = ref.watch(journalSearchProvider);

                if (searchState.isSearching) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (searchState.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchState.error!,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(journalSearchProvider.notifier)
                                .clearError();
                            ref.read(journalSearchProvider.notifier).search();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (searchState.isInitial) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search your journal',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter keywords or use filters to find entries',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  );
                }

                if (!searchState.hasResults) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No entries found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(journalSearchProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: searchState.results.length,
                    itemBuilder: (context, index) {
                      final entry = searchState.results[index];
                      return _SearchResultCard(
                        entry: entry,
                        onTap: () {
                          context.push('/journal/entry/${entry.id}');
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const JournalSearchFilterSheet(),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    } else if (start != null) {
      return 'After ${_formatDate(start)}';
    } else if (end != null) {
      return 'Before ${_formatDate(end)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Filter chip widget for displaying active filters
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onDeleted;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onDeleted: onDeleted,
        deleteIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Search result card widget
class _SearchResultCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with favorite
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (entry.isFavorite)
                    Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.amber[700],
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Date and location
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(entry.entryDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (entry.locationName != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entry.locationName!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Mood
              if (entry.mood != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.emoji_emotions,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.mood!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Content preview
              Text(
                _stripHtmlTags(entry.content),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _stripHtmlTags(String html) {
    // Simple HTML tag removal
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}

/// Debouncer utility for search input
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer(this.delay);

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
