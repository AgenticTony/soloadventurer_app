import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_search_provider.dart';

/// Modal bottom sheet for configuring search filters
class JournalSearchFilterSheet extends ConsumerStatefulWidget {
  const JournalSearchFilterSheet({super.key});

  @override
  ConsumerState<JournalSearchFilterSheet> createState() =>
      _JournalSearchFilterSheetState();
}

class _JournalSearchFilterSheetState
    extends ConsumerState<JournalSearchFilterSheet> {
  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(
      journalSearchProvider.select((state) => state.filters),
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    if (filters.hasActiveFilters)
                      TextButton(
                        onPressed: () {
                          ref.read(journalSearchProvider.notifier).clearFilters();
                        },
                        child: const Text('Clear'),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filters content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date range filter
                  _DateRangeFilter(
                    startDate: filters.startDate,
                    endDate: filters.endDate,
                    onDateRangeChanged: (start, end) {
                      ref.read(journalSearchProvider.notifier).updateDateRangeFilter(start, end);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Location filter
                  _LocationFilter(
                    locationName: filters.locationName,
                    onLocationChanged: (location) {
                      ref.read(journalSearchProvider.notifier).updateLocationFilter(location);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Mood filter
                  _MoodFilter(
                    selectedMood: filters.mood,
                    onMoodChanged: (mood) {
                      ref.read(journalSearchProvider.notifier).updateMoodFilter(mood);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Favorite filter
                  _FavoriteFilter(
                    favoriteOnly: filters.favoriteOnly,
                    onFavoriteChanged: (favorite) {
                      ref.read(journalSearchProvider.notifier).updateFavoriteFilter(favorite);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Trip filter (placeholder for future)
                  // TODO: Implement when trip management is integrated
                  // const _TripFilter(),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(journalSearchProvider.notifier).search();
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Date range filter widget
class _DateRangeFilter extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onDateRangeChanged;

  const _DateRangeFilter({
    required this.startDate,
    required this.endDate,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 8),
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DateButton(
                label: 'From',
                date: startDate,
                onTap: () => _selectStartDate(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateButton(
                label: 'To',
                date: endDate,
                onTap: () => _selectEndDate(context),
              ),
            ),
          ],
        ),
        if (startDate != null || endDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () => onDateRangeChanged(null, null),
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear date range'),
            ),
          ),
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onDateRangeChanged(picked, endDate);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onDateRangeChanged(startDate, picked);
    }
  }
}

/// Date button widget
class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (date != null)
            Text(
              '${date!.day}/${date!.month}/${date!.year}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            )
          else
            Text(
              'Select date',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }
}

/// Location filter widget
class _LocationFilter extends StatefulWidget {
  final String? locationName;
  final Function(String?) onLocationChanged;

  const _LocationFilter({
    required this.locationName,
    required this.onLocationChanged,
  });

  @override
  State<_LocationFilter> createState() => _LocationFilterState();
}

class _LocationFilterState extends State<_LocationFilter> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.locationName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, size: 20),
            const SizedBox(width: 8),
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Enter location name...',
            border: const OutlineInputBorder(),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      widget.onLocationChanged(null);
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            widget.onLocationChanged(value.isEmpty ? null : value);
          },
        ),
      ],
    );
  }
}

/// Mood filter widget
class _MoodFilter extends StatelessWidget {
  final String? selectedMood;
  final Function(String?) onMoodChanged;

  static const List<String> moods = [
    'happy',
    'adventurous',
    'tired',
    'sad',
    'calm',
    'surprised',
    'grateful',
  ];

  static const Map<String, String> moodEmojis = {
    'happy': '😊',
    'adventurous': '🌟',
    'tired': '😴',
    'sad': '😢',
    'calm': '😌',
    'surprised': '😲',
    'grateful': '🙏',
  };

  const _MoodFilter({
    required this.selectedMood,
    required this.onMoodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_emotions, size: 20),
            const SizedBox(width: 8),
            Text(
              'Mood',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            if (selectedMood != null)
              TextButton.icon(
                onPressed: () => onMoodChanged(null),
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: moods.map((mood) {
            final isSelected = selectedMood == mood;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(moodEmojis[mood]!),
                  const SizedBox(width: 4),
                  Text(mood.capitalize()),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                onMoodChanged(selected ? mood : null);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Favorite filter widget
class _FavoriteFilter extends StatelessWidget {
  final bool? favoriteOnly;
  final Function(bool?) onFavoriteChanged;

  const _FavoriteFilter({
    required this.favoriteOnly,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Row(
        children: [
          const Icon(Icons.star, size: 20),
          const SizedBox(width: 8),
          Text(
            'Favorites only',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
      subtitle: Text(
        'Show only favorite entries',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      value: favoriteOnly ?? false,
      onChanged: (value) {
        onFavoriteChanged(value!);
      },
    );
  }
}

/// Extension on String to capitalize first letter
extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
