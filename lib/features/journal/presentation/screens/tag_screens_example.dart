import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/domain/entities/tag.dart';
import 'package:soloadventurer/features/journal/presentation/screens/tag_list_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/create_tag_screen.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/tag_picker.dart';

/// Examples demonstrating tag management screens and widgets
class TagScreensExample extends StatelessWidget {
  const TagScreensExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tag Screens Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TagScreensMenu(),
    );
  }
}

class TagScreensMenu extends StatelessWidget {
  const TagScreensMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag Management Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tag Screens',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _ExampleTile(
            title: 'Tag List Screen',
            description: 'View and manage all tags',
            icon: Icons.list,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TagListScreen(),
              ),
            ),
          ),
          _ExampleTile(
            title: 'Create Tag Screen',
            description: 'Create a new tag',
            icon: Icons.add,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateTagScreen(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tag Picker Widget',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _ExampleTile(
            title: 'Tag Picker Example',
            description: 'Using TagPicker in a form',
            icon: Icons.label,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TagPickerExample(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Repository Usage',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _ExampleTile(
            title: 'Repository Operations',
            description: 'Direct repository usage examples',
            icon: Icons.code,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TagRepositoryExample(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ExampleTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Example of using TagPicker in a journal entry creation form
class TagPickerExample extends ConsumerStatefulWidget {
  const TagPickerExample({super.key});

  @override
  ConsumerState<TagPickerExample> createState() => _TagPickerExampleState();
}

class _TagPickerExampleState extends ConsumerState<TagPickerExample> {
  final List<String> _selectedTagIds = [];
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry with Tags'),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entry title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Entry Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Tag picker integration
            TagPicker(
              selectedTagIds: _selectedTagIds,
              onTagsChanged: (tagIds) {
                setState(() {
                  _selectedTagIds.clear();
                  _selectedTagIds.addAll(tagIds);
                });
              },
            ),
            const SizedBox(height: 24),

            // Display selected tags
            if (_selectedTagIds.isNotEmpty) ...[
              Text(
                'Selected Tags: ${_selectedTagIds.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Tag IDs: ${_selectedTagIds.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveEntry() {
    // In a real app, you would:
    // 1. Create the journal entry
    // 2. Get the entry ID
    // 3. Call updateTagsForEntry with _selectedTagIds

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Would save ${_selectedTagIds.length} tags to entry'),
      ),
    );
  }
}

/// Example of direct repository usage
class TagRepositoryExample extends ConsumerWidget {
  const TagRepositoryExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repository Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _RepositoryExampleCard(
            title: 'Create Tag',
            description: 'Create a new tag with custom properties',
            code: '''
final tag = Tag(
  id: '',
  userId: '',
  name: 'Adventure',
  color: '#FF6B6B',
  icon: '🏔️',
  usageCount: 0,
  createdAt: DateTime.now(),
);

final result = await repository.createTag(tag);
result.fold(
  (failure) => print('Error: \${failure.message}'),
  (createdTag) => print('Created: \${createdTag.name}'),
);
''',
            onTap: () => _createSampleTag(context, ref),
          ),
          const SizedBox(height: 16),
          _RepositoryExampleCard(
            title: 'Get All Tags',
            description: 'Retrieve all tags for the current user',
            code: '''
final result = await repository.getTags();
result.fold(
  (failure) => print('Error'),
  (tags) => tags.forEach((tag) => print(tag.name)),
);
''',
            onTap: () => _getAllTags(context, ref),
          ),
          const SizedBox(height: 16),
          _RepositoryExampleCard(
            title: 'Search Tags',
            description: 'Search for tags by name',
            code: '''
final result = await repository.searchTags('beach');
result.fold(
  (failure) => print('Error'),
  (tags) => print('Found \${tags.length} tags'),
);
''',
            onTap: () => _searchTags(context, ref),
          ),
          const SizedBox(height: 16),
          _RepositoryExampleCard(
            title: 'Get Popular Tags',
            description: 'Get most used tags',
            code: '''
final result = await repository.getPopularTags(limit: 10);
result.fold(
  (failure) => print('Error'),
  (tags) => tags.forEach((tag) {
    print('\${tag.name}: \${tag.usageCount} entries');
  }),
);
''',
            onTap: () => _getPopularTags(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _createSampleTag(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(tagRepositoryProvider);

    final tag = Tag(
      id: '',
      userId: '',
      name: 'Sample Tag',
      color: '#4D96FF',
      icon: '📷',
      usageCount: 0,
      createdAt: DateTime.now(),
    );

    final result = await repository.createTag(tag);

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
      },
      (createdTag) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Created tag: ${createdTag.name}')),
        );
        ref.invalidate(tagListProvider);
      },
    );
  }

  Future<void> _getAllTags(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(tagRepositoryProvider);
    final result = await repository.getTags();

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
      },
      (tags) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Found ${tags.length} tags')),
        );
      },
    );
  }

  Future<void> _searchTags(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(tagRepositoryProvider);
    final result = await repository.searchTags('tag');

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
      },
      (tags) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Found ${tags.length} tags containing "tag"')),
        );
      },
    );
  }

  Future<void> _getPopularTags(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(tagRepositoryProvider);
    final result = await repository.getPopularTags(limit: 5);

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
      },
      (tags) {
        final message = tags
            .map((t) => '${t.name} (${t.usageCount})')
            .join(', ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Top tags: $message')),
        );
      },
    );
  }
}

class _RepositoryExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final String code;
  final VoidCallback onTap;

  const _RepositoryExampleCard({
    required this.title,
    required this.description,
    required this.code,
    required this.onTap,
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
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onTap,
              child: const Text('Run Example'),
            ),
          ],
        ),
      ),
    );
  }
}
