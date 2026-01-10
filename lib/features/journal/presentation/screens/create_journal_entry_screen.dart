import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/rich_text_editor.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/mood_picker.dart';

/// Screen for creating a new journal entry
class CreateJournalEntryScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/journal/create';

  /// Trip ID if creating entry for a specific trip
  final String? tripId;

  /// Creates a new [CreateJournalEntryScreen]
  const CreateJournalEntryScreen({
    super.key,
    this.tripId,
  });

  @override
  ConsumerState<CreateJournalEntryScreen> createState() =>
      _CreateJournalEntryScreenState();
}

class _CreateJournalEntryScreenState
    extends ConsumerState<CreateJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    // Initialize with trip ID if provided
    if (widget.tripId != null) {
      ref
          .read(journalEntryCreationProvider.notifier)
          .updateTripId(widget.tripId);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a title';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.trim().length > 200) {
      return 'Title must be less than 200 characters';
    }
    return null;
  }

  Future<void> _selectDate() async {
    final currentDate = ref.read(journalEntryCreationProvider).entryDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'Select entry date',
      confirmText: 'Set',
      cancelText: 'Cancel',
    );

    if (picked != null && mounted) {
      ref
          .read(journalEntryCreationProvider.notifier)
          .updateEntryDate(picked);
    }
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate content
      final creationState = ref.read(journalEntryCreationProvider);
      if (creationState.content.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add some content to your entry'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final success = await ref
          .read(journalEntryCreationProvider.notifier)
          .saveEntry();

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal entry saved!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Navigate back
        Navigator.of(context).pop(true);
      }
    }
  }

  void _cancel() {
    // Check if there's unsaved content
    final creationState = ref.read(journalEntryCreationProvider);
    final hasUnsavedChanges =
        creationState.title.isNotEmpty || creationState.content.isNotEmpty;

    if (hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
              'You have unsaved changes. Are you sure you want to go back?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep Editing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Discard',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(journalEntryCreationProvider);
    final saveButtonState = ref.watch(journalEntrySaveButtonProvider);
    final theme = Theme.of(context);

    // Listen for errors
    ref.listen<JournalEntryCreationState>(journalEntryCreationProvider,
        (previous, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Clear error after showing
        ref.read(journalEntryCreationProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Journal Entry'),
        actions: [
          // Cancel button
          TextButton(
            onPressed: creationState.isSaving ? null : _cancel,
            child: const Text('Cancel'),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: saveButtonState.enabled ? _saveEntry : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: saveButtonState.isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: Semantics(
        label: 'Create new journal entry form',
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date picker
              Semantics(
                label: 'Entry date',
                hint: 'Tap to change the entry date',
                button: true,
                value: DateFormat('EEEE, MMMM d, y').format(
                  creationState.entryDate,
                ),
                child: ExcludeSemantics(
                  child: InkWell(
                    onTap: creationState.isSaving ? null : _selectDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('EEEE, MMMM d, y').format(
                              creationState.entryDate,
                            ),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
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
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title field
              Semantics(
                label: 'Title',
                hint: 'Enter a title for your journal entry, at least 3 characters',
                textField: true,
                child: TextFormField(
                  controller: _titleController,
                  initialValue: creationState.title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Give your entry a title...',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: _validateTitle,
                  onChanged: (value) {
                    ref
                        .read(journalEntryCreationProvider.notifier)
                        .updateTitle(value);
                  },
                  enabled: !creationState.isSaving,
                ),
              ),

              const SizedBox(height: 24),

              // Content label
              Semantics(
                headingLevel: 2,
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Content',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Rich text editor
              Semantics(
                label: 'Journal entry content',
                hint: 'Write the main content of your journal entry',
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: creationState.content.trim().isEmpty
                          ? theme.colorScheme.error.withOpacity(0.5)
                          : theme.dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: RichTextEditor(
                    initialContent: creationState.content,
                    onContentChanged: (content) {
                      ref
                          .read(journalEntryCreationProvider.notifier)
                          .updateContent(content);
                      _contentController.value = content;
                    },
                    placeholder: 'Start writing your journal entry...',
                    enabled: !creationState.isSaving,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info text
              Text(
                'Tip: Use the toolbar above to format your text with bold, italics, headings, and more.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 24),

              // Favorite toggle
              Semantics(
                label: 'Mark as favorite',
                hint: creationState.isFavorite
                    ? 'Entry is marked as favorite, tap to remove'
                    : 'Mark this entry as favorite',
                button: true,
                child: MergeSemantics(
                  child: InkWell(
                    onTap: creationState.isSaving
                        ? null
                        : () {
                            ref
                                .read(journalEntryCreationProvider.notifier)
                                .toggleFavorite();
                          },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            creationState.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: creationState.isFavorite
                                ? Colors.red
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Mark as favorite',
                            style: theme.textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Switch(
                            value: creationState.isFavorite,
                            onChanged: creationState.isSaving
                                ? null
                                : (value) {
                                    ref
                                        .read(journalEntryCreationProvider.notifier)
                                        .toggleFavorite();
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Mood picker
              Semantics(
                headingLevel: 2,
                child: const MoodPicker(),
              ),

              const SizedBox(height: 32),

              // Additional options hint
              Semantics(
                container: true,
                child: Card(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Coming Soon',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Add photos and videos to your entries\n'
                          '• Tag your location on a map\n'
                          '• Organize entries by trips',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
