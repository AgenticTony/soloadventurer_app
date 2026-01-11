import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/mood_picker.dart';

/// Example screen demonstrating the MoodPicker widget usage
///
/// This example shows:
/// - Full MoodPicker integration with journal entry creation
/// - Compact button variant usage
/// - Standalone usage with custom state management
class MoodPickerExampleScreen extends ConsumerStatefulWidget {
  const MoodPickerExampleScreen({super.key});

  @override
  ConsumerState<MoodPickerExampleScreen> createState() =>
      _MoodPickerExampleScreenState();
}

class _MoodPickerExampleScreenState
    extends ConsumerState<MoodPickerExampleScreen> {
  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(journalEntryCreationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Picker Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example 1: Full MoodPicker integrated with journal entry creation
          _buildSection(
            context,
            title: 'Example 1: Full Mood Picker',
            description:
                'Complete mood picker integrated with journal entry creation provider',
            child: const MoodPicker(),
          ),

          const SizedBox(height: 32),

          // Example 2: Compact button variant
          _buildSection(
            context,
            title: 'Example 2: Compact Button',
            description:
                'Compact button that opens bottom sheet with mood options',
            child: MoodPickerButton(
              selectedMoodId: creationState.mood,
            ),
          ),

          const SizedBox(height: 32),

          // Example 3: Display current selection
          _buildSection(
            context,
            title: 'Example 3: Current Selection Display',
            description: 'Shows how to access and display the selected mood',
            child: _CurrentMoodDisplay(moodId: creationState.mood),
          ),

          const SizedBox(height: 32),

          // Example 4: Standalone usage
          _buildSection(
            context,
            title: 'Example 4: Standalone Usage',
            description: 'Using MoodPicker with custom state management',
            child: const _StandaloneMoodPickerExample(),
          ),

          const SizedBox(height: 32),

          // Example 5: Mood utilities
          _buildSection(
            context,
            title: 'Example 5: Mood Utilities',
            description: 'Helper methods for working with moods',
            child: const _MoodUtilitiesExample(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// Widget to display the currently selected mood
class _CurrentMoodDisplay extends StatelessWidget {
  final String? moodId;

  const _CurrentMoodDisplay({required this.moodId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (moodId == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Text(
              'No mood selected',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    final mood = MoodOptions.findById(moodId!);
    if (mood == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mood.emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Mood',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
              Text(
                mood.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Example of standalone mood picker with custom state
class _StandaloneMoodPickerExample extends StatefulWidget {
  const _StandaloneMoodPickerExample();

  @override
  State<_StandaloneMoodPickerExample> createState() =>
      _StandaloneMoodPickerExampleState();
}

class _StandaloneMoodPickerExampleState
    extends State<_StandaloneMoodPickerExample> {
  String? _selectedMoodId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom mood picker using MoodOptions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedMoodId != null
                  ? theme.colorScheme.primary.withOpacity(0.5)
                  : theme.dividerColor,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sentiment_satisfied_alt,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select your mood',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedMoodId != null)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedMoodId = null;
                        });
                      },
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: MoodOptions.all.map((mood) {
                  final isSelected = mood.id == _selectedMoodId;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMoodId = mood.id;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            mood.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        if (_selectedMoodId != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.successContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.onSuccessContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mood saved: ${MoodOptions.findById(_selectedMoodId!)!.label}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSuccessContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Example of mood utility methods
class _MoodUtilitiesExample extends StatelessWidget {
  const _MoodUtilitiesExample();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Utilities Available:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildUtilityItem(
            context,
            title: 'MoodOptions.findById(id)',
            description: 'Find a mood by its ID',
            example: "MoodOptions.findById('happy')",
          ),
          const SizedBox(height: 8),
          _buildUtilityItem(
            context,
            title: 'MoodOptions.findByLabel(label)',
            description: 'Find a mood by its label (case-insensitive)',
            example: "MoodOptions.findByLabel('Happy')",
          ),
          const SizedBox(height: 8),
          _buildUtilityItem(
            context,
            title: 'MoodOptions.all',
            description: 'Get list of all available moods',
            example: 'MoodOptions.all.length returns ${MoodOptions.all.length}',
          ),
          const SizedBox(height: 8),
          _buildUtilityItem(
            context,
            title: 'MoodOption properties',
            description: 'Access mood data',
            example: 'id, label, emoji',
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityItem(
    BuildContext context, {
    required String title,
    required String description,
    required String example,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          example,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Example integration with journal entry creation screen
///
/// This shows how to integrate MoodPicker into the CreateJournalEntryScreen
class JournalEntryWithMoodExample extends StatelessWidget {
  const JournalEntryWithMoodExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Journal Entry'),
      ),
      body: const Column(
        children: [
          // ... other form fields ...

          // Mood picker
          Padding(
            padding: EdgeInsets.all(16.0),
            child: MoodPicker(),
          ),

          // ... rest of the form ...
        ],
      ),
    );
  }
}
