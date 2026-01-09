import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/domain/entities/tag.dart';
import 'package:soloadventurer/features/journal/presentation/providers/tag_providers.dart';

/// Widget for picking tags to add to a journal entry
class TagPicker extends ConsumerWidget {
  final List<String> selectedTagIds;
  final ValueChanged<List<String>> onTagsChanged;

  const TagPicker({
    super.key,
    required this.selectedTagIds,
    required this.onTagsChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryTagsState = ref.watch(entryTagsProvider);

    // Load available tags if not loaded
    if (!entryTagsState.isLoading && entryTagsState.tags.isEmpty && entryTagsState.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(entryTagsProvider.notifier).loadAvailableTags();
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: () => _showTagManagementDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Manage Tags'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (entryTagsState.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (entryTagsState.tags.isEmpty)
          Card(
            child: InkWell(
              onTap: () => _showTagManagementDialog(context, ref),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.label_outline, size: 32),
                      SizedBox(height: 8),
                      Text('No tags yet. Create tags to organize entries.'),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          _TagsChips(
            tags: entryTagsState.tags,
            selectedTagIds: selectedTagIds,
            onTagToggled: (tagId) {
              final notifier = ref.read(entryTagsProvider.notifier);
              notifier.toggleTag(tagId);
              onTagsChanged(List.from(notifier.state.selectedTagIds));
            },
            onCreateNewTag: () => _showTagManagementDialog(context, ref),
          ),
      ],
    );
  }

  void _showTagManagementDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TagManagementSheet(
        entryTagsNotifier: ref.read(entryTagsProvider.notifier),
        onTagsChanged: onTagsChanged,
      ),
    );
  }
}

class _TagsChips extends StatelessWidget {
  final List<Tag> tags;
  final List<String> selectedTagIds;
  final ValueChanged<String> onTagToggled;
  final VoidCallback onCreateNewTag;

  const _TagsChips({
    required this.tags,
    required this.selectedTagIds,
    required this.onTagToggled,
    required this.onCreateNewTag,
  });

  @override
  Widget build(BuildContext context) {
    final selectedTags = tags.where((t) => selectedTagIds.contains(t.id)).toList();
    final availableTags = tags.where((t) => !selectedTagIds.contains(t.id)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Selected tags
            ...selectedTags.map((tag) => _TagChip(
                  tag: tag,
                  isSelected: true,
                  onToggle: () => onTagToggled(tag.id),
                )),
            // Available tags
            ...availableTags.take(5).map((tag) => _TagChip(
                  tag: tag,
                  isSelected: false,
                  onToggle: () => onTagToggled(tag.id),
                )),
            // Add new tag button
            if (availableTags.length > 5 || tags.isEmpty)
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('More'),
                onPressed: onCreateNewTag,
              ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final VoidCallback onToggle;

  const _TagChip({
    required this.tag,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = tag.hasColor
        ? _tryParseColor(tag.color!)
        : Theme.of(context).colorScheme.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag.hasIcon) ...[
            Text(tag.icon!),
            const SizedBox(width: 4),
          ],
          Text(tag.name),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onToggle(),
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? color : color.withOpacity(0.8),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: color.withOpacity(0.5),
        width: 1,
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

class _TagManagementSheet extends ConsumerStatefulWidget {
  final EntryTagsNotifier entryTagsNotifier;
  final ValueChanged<List<String>> onTagsChanged;

  const _TagManagementSheet({
    required this.entryTagsNotifier,
    required this.onTagsChanged,
  });

  @override
  ConsumerState<_TagManagementSheet> createState() =>
      _TagManagementSheetState();
}

class _TagManagementSheetState extends ConsumerState<_TagManagementSheet> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entryTagsState = ref.watch(entryTagsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Tags',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => _showCreateTagDialog(context, ref),
                    child: const Text('+ New Tag'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Tags list
            Expanded(
              child: entryTagsState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : entryTagsState.error != null
                      ? Center(child: Text(entryTagsState.error!))
                      : entryTagsState.tags.isEmpty
                          ? const Center(
                              child: Text('No tags available. Create one!'),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: entryTagsState.tags.length,
                              itemBuilder: (context, index) {
                                final tag = entryTagsState.tags[index];
                                final isSelected = entryTagsState.selectedTagIds
                                    .contains(tag.id);

                                return _TagListTile(
                                  tag: tag,
                                  isSelected: isSelected,
                                  onToggle: () {
                                    widget.entryTagsNotifier.toggleTag(tag.id);
                                    widget.onTagsChanged(
                                      List.from(widget
                                          .entryTagsNotifier.state.selectedTagIds),
                                    );
                                  },
                                );
                              },
                            ),
            ),
            // Apply button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Apply'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateTagDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _CreateTagDialog(
        nameController: _nameController,
        onTagCreated: () {
          ref.read(entryTagsProvider.notifier).loadAvailableTags();
        },
      ),
    );
  }
}

class _TagListTile extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final VoidCallback onToggle;

  const _TagListTile({
    required this.tag,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = tag.hasColor
        ? _tryParseColor(tag.color!)
        : Theme.of(context).colorScheme.primary;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
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
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('${tag.usageCount} entries'),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (_) => onToggle(),
      ),
      onTap: onToggle,
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

class _CreateTagDialog extends ConsumerStatefulWidget {
  final TextEditingController nameController;
  final VoidCallback onTagCreated;

  const _CreateTagDialog({
    required this.nameController,
    required this.onTagCreated,
  });

  @override
  ConsumerState<_CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends ConsumerState<_CreateTagDialog> {
  bool _isLoading = false;
  String? _selectedColor;
  String? _selectedIcon;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Tag'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.nameController,
              decoration: const InputDecoration(
                labelText: 'Tag Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            const Text('Color:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _CreateTagDialog._colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _parseColor(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _createTag,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createTag() async {
    if (widget.nameController.text.trim().isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    final tag = Tag(
      id: '',
      userId: '',
      name: widget.nameController.text.trim(),
      color: _selectedColor,
      icon: _selectedIcon,
      createdAt: DateTime.now(),
    );

    final repository = ref.read(tagRepositoryProvider);
    final result = await repository.createTag(tag);

    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        setState(() {
          _isLoading = false;
          widget.nameController.clear();
          _selectedColor = null;
          _selectedIcon = null;
        });
        widget.onTagCreated();
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tag created')),
        );
      },
    );
  }

  Color _parseColor(String colorString) {
    return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
  }

  static const List<String> _colors = [
    '#FF6B6B',
    '#FFA06B',
    '#FFD93D',
    '#6BCB77',
    '#4D96FF',
    '#6BCBFF',
    '#9B59B6',
    '#FF69B4',
  ];
}
