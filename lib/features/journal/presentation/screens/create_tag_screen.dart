import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/providers/tag_providers.dart';

/// Screen for creating or editing a tag
class CreateTagScreen extends ConsumerStatefulWidget {
  final String? tagId;

  const CreateTagScreen({super.key, this.tagId});

  @override
  ConsumerState<CreateTagScreen> createState() => _CreateTagScreenState();
}

class _CreateTagScreenState extends ConsumerState<CreateTagScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.tagId != null) {
      _loadTag();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadTag() async {
    await ref.read(tagFormProvider.notifier).loadTag(widget.tagId!);
    final formState = ref.read(tagFormProvider);
    _nameController.text = formState.name;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<TagFormState>(
      tagFormProvider,
      (previous, next) {
        if (next.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.error!)),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tagId == null ? 'Create Tag' : 'Edit Tag'),
        actions: [
          TextButton(
            onPressed: _saveTag,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final formState = ref.watch(tagFormProvider);

          if (formState.isLoading && formState.tag == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tag Name',
                      hintText: 'e.g., Adventure, Food, Beach',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a tag name';
                      }
                      if (value.trim().length < 2) {
                        return 'Tag name must be at least 2 characters';
                      }
                      if (value.trim().length > 50) {
                        return 'Tag name must be less than 50 characters';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      ref.read(tagFormProvider.notifier).updateName(value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Color',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _ColorPicker(
                    selectedColor: formState.color,
                    onColorSelected: (color) {
                      ref.read(tagFormProvider.notifier).updateColor(color);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Icon (Optional)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _IconPicker(
                    selectedIcon: formState.icon,
                    onIconSelected: (icon) {
                      ref.read(tagFormProvider.notifier).updateIcon(icon);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveTag() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(tagFormProvider.notifier).saveTag();

    if (success && mounted) {
      ref.read(tagListProvider.notifier).loadTags();
      Navigator.of(context).pop(true);
    }
  }
}

class _ColorPicker extends StatelessWidget {
  final String? selectedColor;
  final ValueChanged<String> onColorSelected;

  const _ColorPicker({
    required this.selectedColor,
    required this.onColorSelected,
  });

  static const List<String> _colors = [
    '#FF6B6B', // Red
    '#FFA06B', // Orange
    '#FFD93D', // Yellow
    '#6BCB77', // Green
    '#4D96FF', // Blue
    '#6BCBFF', // Light Blue
    '#9B59B6', // Purple
    '#FF69B4', // Pink
    '#95A5A6', // Gray
    '#34495E', // Dark Gray
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _colors.map((color) {
        final isSelected = selectedColor == color;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 48,
            height: 48,
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
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Color _parseColor(String colorString) {
    return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
  }
}

class _IconPicker extends StatelessWidget {
  final String? selectedIcon;
  final ValueChanged<String?> onIconSelected;

  const _IconPicker({
    required this.selectedIcon,
    required this.onIconSelected,
  });

  static const List<String> _icons = [
    '✈️', // Airplane
    '🏖️', // Beach
    '🏔️', // Mountain
    '🍜', // Food
    '🎉', // Party
    '❤️', // Heart
    '⭐', // Star
    '📷', // Camera
    '🎒', // Backpack
    '🏨', // Hotel
    '🚗', // Car
    '🚂', // Train
    '🛫', // Flight
    '🌍', // Globe
    '🌲', // Tree
    '🏛️', // Museum
    '🎭', // Arts
    '🛍️', // Shopping
    '🍺', // Bar
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _icons.map((icon) {
            final isSelected = selectedIcon == icon;
            return GestureDetector(
              onTap: () => onIconSelected(icon),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (selectedIcon != null)
          TextButton.icon(
            onPressed: () => onIconSelected(null),
            icon: const Icon(Icons.clear),
            label: const Text('Clear Icon'),
          ),
      ],
    );
  }
}
