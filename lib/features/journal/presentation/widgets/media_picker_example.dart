import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/media_picker.dart';

/// Example screen demonstrating MediaPicker usage
class MediaPickerExampleScreen extends ConsumerStatefulWidget {
  const MediaPickerExampleScreen({super.key});

  static const routeName = '/examples/media-picker';

  @override
  ConsumerState<MediaPickerExampleScreen> createState() =>
      _MediaPickerExampleScreenState();
}

class _MediaPickerExampleScreenState extends ConsumerState<MediaPickerExampleScreen> {
  final List<PickedMediaFile> _selectedMedia = [];
  MediaQuality _selectedQuality = MediaQuality.optimized;

  MediaPickerConfig get _config {
    switch (_selectedQuality) {
      case MediaQuality.optimized:
        return MediaPickerConfig.forTravelJournal();
      case MediaQuality.high:
        return MediaPickerConfig.highQuality();
      case MediaQuality.aggressive:
        return MediaPickerConfig.aggressive();
    }
  }

  void _onMediaPicked(List<PickedMediaFile> media) {
    setState(() {
      _selectedMedia.addAll(media);
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${media.length} media file(s)'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _selectedMedia.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Picker Example'),
        actions: [
          if (_selectedMedia.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Quality selector
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quality Preset',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<MediaQuality>(
                  segments: const [
                    ButtonSegment(
                      value: MediaQuality.optimized,
                      label: Text('Optimized'),
                      icon: Icon(Icons.balance),
                    ),
                    ButtonSegment(
                      value: MediaQuality.high,
                      label: Text('High'),
                      icon: Icon(Icons.high_quality),
                    ),
                    ButtonSegment(
                      value: MediaQuality.aggressive,
                      label: Text('Small'),
                      icon: Icon(Icons.compress),
                    ),
                  ],
                  selected: {_selectedQuality},
                  onSelectionChanged: (Set<MediaQuality> newSelection) {
                    setState(() {
                      _selectedQuality = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _getQualityDescription(_selectedQuality),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Media picker button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MediaPicker(
              config: _config,
              onMediaPicked: _onMediaPicked,
              buttonText: 'Add Photos & Videos',
              buttonIcon: Icons.add_circle,
              buttonStyle: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const Divider(height: 1),

          // Selected media list
          Expanded(
            child: _selectedMedia.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No media selected',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the button above to add photos or videos',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _selectedMedia.length,
                    itemBuilder: (context, index) {
                      final media = _selectedMedia[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            media.isVideo
                                ? Icons.videocam
                                : Icons.image,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            media.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${media.formattedFileSize} • '
                            '${media.isVideo ? 'Video' : 'Photo'}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeMedia(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Summary footer
          if (_selectedMedia.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_selectedMedia.length} file(s) selected • '
                      '${_formatTotalSize()}',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle upload/save
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Media ready for upload!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getQualityDescription(MediaQuality quality) {
    switch (quality) {
      case MediaQuality.optimized:
        return 'Good balance between quality and file size. Recommended for travel journals.';
      case MediaQuality.high:
        return 'Maximum quality with minimal compression. Larger file sizes.';
      case MediaQuality.aggressive:
        return 'Maximum compression for smallest file sizes. Good for limited storage.';
    }
  }

  String _formatTotalSize() {
    final totalBytes =
        _selectedMedia.fold<int>(0, (sum, media) => sum + media.fileSize);

    if (totalBytes < 1024) return '$totalBytes B';
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalBytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}

/// Example 2: Inline Media Picker
///
/// This example shows how to use the MediaPicker in inline mode
/// (showAsButton: false) for more control over the UI layout.
class InlineMediaPickerExample extends ConsumerWidget {
  const InlineMediaPickerExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inline Media Picker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Media',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            const MediaPicker(
              showAsButton: false,
              config: MediaPickerConfig.forTravelJournal(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 3: Media Picker in Create Journal Entry
///
/// This example shows how to integrate MediaPicker into journal entry creation.
class JournalEntryWithMediaExample extends ConsumerStatefulWidget {
  const JournalEntryWithMediaExample({super.key});

  @override
  ConsumerState<JournalEntryWithMediaExample> createState() =>
      _JournalEntryWithMediaExampleState();
}

class _JournalEntryWithMediaExampleState
    extends ConsumerState<JournalEntryWithMediaExample> {
  final List<PickedMediaFile> _mediaFiles = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onMediaPicked(List<PickedMediaFile> media) {
    setState(() {
      _mediaFiles.addAll(media);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Journal Entry'),
        actions: [
          TextButton(
            onPressed: _mediaFiles.isEmpty
                ? null
                : () {
                    // Handle save
                    Navigator.of(context).pop();
                  },
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter title...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Content field
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Write your entry...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Media picker
            MediaPicker(
              config: MediaPickerConfig.forTravelJournal(),
              onMediaPicked: _onMediaPicked,
              buttonText: 'Add Photos & Videos',
              buttonStyle: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),

            // Media preview
            if (_mediaFiles.isNotEmpty) ...[
              Text(
                'Attached Media (${_mediaFiles.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _mediaFiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final media = entry.value;
                  return Chip(
                    avatar: Icon(
                      media.isVideo ? Icons.videocam : Icons.image,
                      size: 18,
                    ),
                    label: Text(media.formattedFileSize),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _mediaFiles.removeAt(index);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
