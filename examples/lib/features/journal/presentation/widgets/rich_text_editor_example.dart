import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/rich_text_editor.dart';

/// Example screen demonstrating the RichTextEditor usage
///
/// This is a reference implementation showing how to integrate
/// the rich text editor into a journal entry creation or editing screen.
class RichTextEditorExampleScreen extends ConsumerStatefulWidget {
  const RichTextEditorExampleScreen({super.key});

  @override
  ConsumerState<RichTextEditorExampleScreen> createState() =>
      _RichTextEditorExampleScreenState();
}

class _RichTextEditorExampleScreenState
    extends ConsumerState<RichTextEditorExampleScreen> {
  final _editorKey = GlobalKey<RichTextEditorState>();
  String _content = '';
  String _title = '';

  @override
  void initState() {
    super.initState();
    // Load existing content if editing
    _loadExistingContent();
  }

  void _loadExistingContent() {
    // Example: Load content from database or navigation arguments
    // final args = ModalRoute.of(context)!.settings.arguments;
    // if (args != null && args is JournalEntry) {
    //   _title = args.title;
    //   _content = args.content;
    // }
  }

  void _saveEntry() {
    if (_title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for your journal entry'),
        ),
      );
      return;
    }

    if (_content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content to your journal entry'),
        ),
      );
      return;
    }

    // Save to database
    // Example:
    // final navigator = Navigator.of(context);
    // ref.read(journalEntryProvider.notifier).createEntry(
    //       title: _title,
    //       content: _content,
    //       date: DateTime.now(),
    //     );
    // navigator.pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Journal entry saved!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Journal Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              if (_content.isNotEmpty || _title.isNotEmpty) {
                _showDiscardDialog();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Entry Title',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              onChanged: (value) => setState(() => _title = value),
            ),
          ),

          // Date/metadata row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(DateTime.now()),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Future: Add location picker, mood picker here
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Rich text editor
          Expanded(
            child: RichTextEditor(
              initialContent: _content.isNotEmpty ? _content : null,
              placeholder: 'What adventures did you have today?',
              onContentChanged: (content) {
                setState(() => _content = content);
              },
              minHeight: 300,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Entry?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard this entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close screen
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}

/// Example showing how to use separate toolbar and editor
class SeparateToolbarExampleScreen extends ConsumerWidget {
  const SeparateToolbarExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor with Separate Toolbar'),
      ),
      body: const Column(
        children: [
          // Custom toolbar area
          // EditorToolbar(
          //   controller: controller,
          // ),

          // Editor area
          // Expanded(
          //   child: QuillEditor(
          //     controller: controller,
          //     scrollController: ScrollController(),
          //     configurations: QuillEditorConfigurations(
          //       placeholder: 'Start writing...',
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

/// Example showing compact toolbar for mobile
class CompactEditorExampleScreen extends ConsumerWidget {
  const CompactEditorExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Note'),
      ),
      body: const Column(
        children: [
          // Use compact toolbar for simpler interface
          // CompactEditorToolbar(
          //   controller: controller,
          // ),

          // Expanded editor
          // Expanded(
          //   child: QuillEditor.basic(
          //     controller: controller,
          //   ),
          // ),
        ],
      ),
    );
  }
}
