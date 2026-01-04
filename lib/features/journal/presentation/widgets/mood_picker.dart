import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';

/// Predefined mood options with emoji and label
class MoodOption {
  /// Unique identifier for the mood
  final String id;

  /// Display label for the mood
  final String label;

  /// Emoji representing the mood
  final String emoji;

  const MoodOption({
    required this.id,
    required this.label,
    required this.emoji,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodOption && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// List of predefined mood options for journal entries
///
/// These moods cover a range of emotions travelers might experience
class MoodOptions {
  /// Happy and joyful
  static const happy = MoodOption(id: 'happy', label: 'Happy', emoji: '😊');

  /// Adventurous and excited
  static const adventurous =
      MoodOption(id: 'adventurous', label: 'Adventurous', emoji: '🤩');

  /// Tired and exhausted
  static const tired = MoodOption(id: 'tired', label: 'Tired', emoji: '😴');

  /// Sad and down
  static const sad = MoodOption(id: 'sad', label: 'Sad', emoji: '😢');

  /// Calm and peaceful
  static const calm = MoodOption(id: 'calm', label: 'Calm', emoji: '😌');

  /// Surprised and amazed
  static const surprised =
      MoodOption(id: 'surprised', label: 'Surprised', emoji: '😲');

  /// Grateful and loving
  static const grateful =
      MoodOption(id: 'grateful', label: 'Grateful', emoji: '🥰');

  /// All available mood options
  static const List<MoodOption> all = [
    happy,
    adventurous,
    tired,
    sad,
    calm,
    surprised,
    grateful,
  ];

  /// Find mood option by ID
  static MoodOption? findById(String id) {
    for (final mood in all) {
      if (mood.id == id) {
        return mood;
      }
    }
    return null;
  }

  /// Find mood option by label (case-insensitive)
  static MoodOption? findByLabel(String label) {
    final lowerLabel = label.toLowerCase();
    for (final mood in all) {
      if (mood.label.toLowerCase() == lowerLabel) {
        return mood;
      }
    }
    return null;
  }
}

/// Widget for selecting mood for journal entries
///
/// Features:
/// - Grid of predefined moods with emoji and label
/// - Visual selection indicator
/// - Clear mood option
/// - Compact button variant for inline usage
/// - Full integration with journal entry creation provider
class MoodPicker extends ConsumerWidget {
  /// Currently selected mood ID
  final String? selectedMoodId;

  /// Custom padding for the widget
  final EdgeInsetsGeometry? padding;

  /// Whether to show in compact mode (button only)
  final bool isCompact;

  const MoodPicker({
    super.key,
    this.selectedMoodId,
    this.padding,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (isCompact) {
      return MoodPickerButton(
        selectedMoodId: selectedMoodId,
      );
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: selectedMoodId != null
              ? theme.colorScheme.primary.withOpacity(0.5)
              : theme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.sentiment_satisfied_alt,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'How are you feeling?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (selectedMoodId != null)
                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(journalEntryCreationProvider.notifier)
                        .updateMood(null);
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Mood grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: MoodOptions.all.length,
            itemBuilder: (context, index) {
              final mood = MoodOptions.all[index];
              final isSelected = mood.id == selectedMoodId;

              return _MoodTile(
                mood: mood,
                isSelected: isSelected,
                onTap: () {
                  ref
                      .read(journalEntryCreationProvider.notifier)
                      .updateMood(mood.id);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Individual mood tile widget
class _MoodTile extends StatelessWidget {
  final MoodOption mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodTile({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mood.emoji,
              style: const TextStyle(
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mood.label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact button variant that shows a bottom sheet with mood options
class MoodPickerButton extends ConsumerWidget {
  /// Currently selected mood ID
  final String? selectedMoodId;

  /// Custom button padding
  final EdgeInsetsGeometry? padding;

  const MoodPickerButton({
    super.key,
    this.selectedMoodId,
    this.padding,
  });

  void _showMoodBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title
                Row(
                  children: [
                    Icon(
                      Icons.sentiment_satisfied_alt,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'How are you feeling?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Mood grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: MoodOptions.all.length,
                  itemBuilder: (context, index) {
                    final mood = MoodOptions.all[index];
                    return _MoodTileForBottomSheet(
                      mood: mood,
                      isSelected: mood.id == selectedMoodId,
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Clear button
                if (selectedMoodId != null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Access the provider through the context
                        // This will be handled by the parent widget
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Mood'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedMood = selectedMoodId != null
        ? MoodOptions.findById(selectedMoodId!)
        : null;

    return InkWell(
      onTap: () => _showMoodBottomSheet(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedMood != null
                ? theme.colorScheme.primary
                : theme.dividerColor,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              selectedMood != null ? Icons.sentiment_satisfied_alt : Icons.add,
              color: selectedMood != null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              selectedMood != null
                  ? '${selectedMood!.emoji} ${selectedMood.label}'
                  : 'Add mood',
              style: theme.textTheme.titleMedium?.copyWith(
                color: selectedMood != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mood tile for bottom sheet (consumer version)
class _MoodTileForBottomSheet extends ConsumerWidget {
  final MoodOption mood;
  final bool isSelected;

  const _MoodTileForBottomSheet({
    required this.mood,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        ref
            .read(journalEntryCreationProvider.notifier)
            .updateMood(mood.id);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mood.emoji,
              style: const TextStyle(
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mood.label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension for string capitalization
extension StringCapitalization on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : this;
}
