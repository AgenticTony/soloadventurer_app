import 'package:flutter/material.dart';
import 'package:soloadventurer/features/journal/presentation/screens/journal_entry_detail_screen.dart';

/// Example demonstrating how to use [JournalEntryDetailScreen]
///
/// This example shows:
/// 1. How to navigate to the detail screen
/// 2. How to handle the result (e.g., after edit/delete)
/// 3. How to integrate with your app's navigation
class JournalEntryDetailScreenExample extends StatelessWidget {
  const JournalEntryDetailScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry Detail Example'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Journal Entry Detail Screen Examples',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Example 1: Basic navigation
          _buildExampleCard(
            context,
            title: 'View Entry',
            description: 'Navigate to view a journal entry by ID',
            icon: Icons.visibility,
            onTap: () {
              _navigateToEntry(context, 'example-entry-id-1');
            },
          ),

          const SizedBox(height: 16),

          // Example 2: Navigation with result handling
          _buildExampleCard(
            context,
            title: 'View with Result',
            description: 'Navigate and handle edit/delete results',
            icon: Icons.edit_note,
            onTap: () {
              _navigateToEntryWithResult(context, 'example-entry-id-2');
            },
          ),

          const SizedBox(height: 16),

          // Example 3: From a list
          _buildExampleCard(
            context,
            title: 'From List',
            description: 'Example of navigating from a list of entries',
            icon: Icons.list_alt,
            onTap: () {
              _showListExample(context);
            },
          ),

          const SizedBox(height: 24),

          // Usage documentation
          _buildUsageDocumentation(context),
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
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildUsageDocumentation(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.code,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Usage Documentation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCodeBlock(
              context,
              '''// Basic navigation
Navigator.pushNamed(
  context,
  JournalEntryDetailScreen.routeName,
  arguments: 'entry-id-here',
);

// With result handling (for edit/delete)
final result = await Navigator.pushNamed(
  context,
  JournalEntryDetailScreen.routeName,
  arguments: 'entry-id-here',
);

if (result == true) {
  // Entry was deleted, refresh list
  _refreshEntries();
}''',
            ),
            const SizedBox(height: 16),
            const Text(
              'Features:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildFeatureBullet(
              'Display full journal entry with rich text content',
            ),
            _buildFeatureBullet(
              'Show date, location, and mood information',
            ),
            _buildFeatureBullet(
              'Favorite toggle functionality',
            ),
            _buildFeatureBullet(
              'Edit and delete actions',
            ),
            _buildFeatureBullet(
              'Sync status indicator for offline support',
            ),
            _buildFeatureBullet(
              'Media gallery support (Phase 3)',
            ),
            _buildFeatureBullet(
              'Trip information display (Phase 5)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeBlock(BuildContext context, String code) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildFeatureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _navigateToEntry(BuildContext context, String entryId) {
    Navigator.pushNamed(
      context,
      JournalEntryDetailScreen.routeName,
      arguments: entryId,
    );
  }

  Future<void> _navigateToEntryWithResult(
    BuildContext context,
    String entryId,
  ) async {
    final result = await Navigator.pushNamed(
      context,
      JournalEntryDetailScreen.routeName,
      arguments: entryId,
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry was deleted'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showListExample(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Example Entry List'),
        content: const Text(
          'In a real app, this would show a list of journal entries. '
          'Tapping an entry would navigate to the detail screen:\n\n'
          'ListView.builder(\n'
          '  itemCount: entries.length,\n'
          '  itemBuilder: (context, index) {\n'
          '    final entry = entries[index];\n'
          '    return ListTile(\n'
          '      title: Text(entry.title),\n'
          '      onTap: () {\n'
          '        Navigator.pushNamed(\n'
          '          context,\n'
          '          JournalEntryDetailScreen.routeName,\n'
          '          arguments: entry.id,\n'
          '        );\n'
          '      },\n'
          '    );\n'
          '  },\n'
          ')',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Example integration in your app's router:
///
/// ```dart
/// // In your route configuration
/// routes: {
///   JournalEntryDetailScreen.routeName: (context) {
///     final entryId = JournalEntryDetailScreen.extractEntryId(context);
///     return JournalEntryDetailScreen(entryId: entryId);
///   },
/// },
/// ```
///
/// Or using onGenerateRoute:
///
/// ```dart
/// case JournalEntryDetailScreen.routeName:
///   final entryId = settings.arguments as String;
///   return MaterialPageRoute(
///     builder: (context) => JournalEntryDetailScreen(entryId: entryId),
///   );
/// ```
