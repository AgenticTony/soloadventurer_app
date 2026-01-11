import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/domain/entities/tag.dart';
import 'package:soloadventurer/features/journal/presentation/providers/tag_providers.dart';
import 'package:soloadventurer/features/journal/presentation/screens/create_tag_screen.dart';

/// Screen for displaying and managing all tags
class TagListScreen extends ConsumerStatefulWidget {
  const TagListScreen({super.key});

  @override
  ConsumerState<TagListScreen> createState() => _TagListScreenState();
}

class _TagListScreenState extends ConsumerState<TagListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final tagListState = ref.watch(tagListProvider);

          if (tagListState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tagListState.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tagListState.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(tagListProvider.notifier).loadTags(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (tagListState.tags.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.label_outline,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tags yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create tags to organize your journal entries',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(tagListProvider.notifier).loadTags();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tagListState.tags.length,
              itemBuilder: (context, index) {
                final tag = tagListState.tags[index];
                return _TagTile(
                  tag: tag,
                  onTap: () => _editTag(context, tag),
                  onDelete: () => _confirmDeleteTag(context, tag),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createTag(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final controller = TextEditingController();
    showSearch(
      context: context,
      delegate: _TagSearchDelegate(ref, controller),
    );
  }

  void _createTag(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateTagScreen(),
      ),
    );
  }

  void _editTag(BuildContext context, Tag tag) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateTagScreen(tagId: tag.id),
      ),
    );
  }

  void _confirmDeleteTag(BuildContext context, Tag tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text(
          'Are you sure you want to delete "${tag.name}"? '
          'This will remove the tag from all journal entries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final repository = ref.read(tagRepositoryProvider);
              final result = await repository.deleteTag(tag.id);

              result.fold(
                (failure) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(failure.message)),
                  );
                },
                (_) {
                  ref.read(tagListProvider.notifier).loadTags();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tag deleted')),
                  );
                },
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TagTile extends StatelessWidget {
  final Tag tag;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TagTile({
    required this.tag,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        tag.hasColor ? _tryParseColor(tag.color!) : theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha:0.2),
          child: tag.hasIcon
              ? Text(
                  tag.icon!,
                  style: TextStyle(color: color),
                )
              : Icon(
                  Icons.label,
                  color: color,
                  size: 20,
                ),
        ),
        title: Text(
          tag.name,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${tag.usageCount} entries'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onTap,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color? _tryParseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }
}

class _TagSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;
  final TextEditingController controller;

  _TagSearchDelegate(this.ref, this.controller);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          controller.clear();
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    ref.read(tagListProvider.notifier).searchTags(query);

    return Consumer(
      builder: (context, ref, child) {
        final tagListState = ref.watch(tagListProvider);

        if (tagListState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (tagListState.tags.isEmpty) {
          return const Center(
            child: Text('No tags found'),
          );
        }

        return ListView.builder(
          itemCount: tagListState.tags.length,
          itemBuilder: (context, index) {
            final tag = tagListState.tags[index];
            return _TagTile(
              tag: tag,
              onTap: () {
                Navigator.of(context).pop();
                // Navigate to edit screen
              },
              onDelete: () {
                Navigator.of(context).pop();
                // Show delete confirmation
              },
            );
          },
        );
      },
    );
  }
}
