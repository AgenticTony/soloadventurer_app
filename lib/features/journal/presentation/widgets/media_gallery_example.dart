import 'package:flutter/material.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/media_gallery.dart';

/// Example 1: Basic media gallery usage
class BasicMediaGalleryExample extends StatelessWidget {
  BasicMediaGalleryExample({super.key});

  // Sample media items
  final List<MediaItem> _sampleMedia = [
    MediaItem(
      id: '1',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: MediaType.photo,
      storagePath: 'https://picsum.photos/seed/photo1/400/400',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MediaItem(
      id: '2',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: MediaType.photo,
      storagePath: 'https://picsum.photos/seed/photo2/400/400',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MediaItem(
      id: '3',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: MediaType.video,
      storagePath: 'https://picsum.photos/seed/video1/400/400',
      thumbnailPath: 'https://picsum.photos/seed/video1/400/400',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MediaItem(
      id: '4',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: MediaType.photo,
      storagePath: 'https://picsum.photos/seed/photo3/400/400',
      uploadStatus: UploadStatus.uploading,
      uploadProgress: 65,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MediaItem(
      id: '5',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: MediaType.photo,
      storagePath: 'https://picsum.photos/seed/photo4/400/400',
      caption: 'Beautiful sunset at the beach',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Media Gallery')),
      body: MediaGallery(
        mediaItems: _sampleMedia,
        config: MediaGalleryConfig.forTripOverview,
        onMediaTap: (media, index) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped: ${media.mediaType} at index $index'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        onMediaLongPress: (media, index) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Long-pressed: ${media.mediaType}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}

/// Example 2: Different grid configurations
class MediaGalleryConfigExample extends StatelessWidget {
  MediaGalleryConfigExample({super.key});

  final List<MediaItem> _sampleMedia = List.generate(
    12,
    (index) => MediaItem(
      id: 'media_$index',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: index % 3 == 0 ? MediaType.video : MediaType.photo,
      storagePath: 'https://picsum.photos/seed/$index/400/400',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery Configurations')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trip Overview config
          const Text('Trip Overview (3 columns)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: MediaGallery(
              mediaItems: _sampleMedia,
              config: MediaGalleryConfig.forTripOverview,
            ),
          ),
          const SizedBox(height: 24),

          // Entry Detail config
          const Text('Entry Detail (2 columns)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: MediaGallery(
              mediaItems: _sampleMedia,
              config: MediaGalleryConfig.forEntryDetail,
            ),
          ),
          const SizedBox(height: 24),

          // Compact config
          const Text('Compact (4 columns)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: MediaGallery(
              mediaItems: _sampleMedia,
              config: MediaGalleryConfig.compact,
            ),
          ),
          const SizedBox(height: 24),

          // Custom config
          const Text('Custom (5 columns, square)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: MediaGallery(
              mediaItems: _sampleMedia,
              config: const MediaGalleryConfig(
                crossAxisCount: 5,
                childAspectRatio: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 3: Loading, error, and empty states
class MediaGalleryStatesExample extends StatefulWidget {
  const MediaGalleryStatesExample({super.key});

  @override
  State<MediaGalleryStatesExample> createState() => _MediaGalleryStatesExampleState();
}

class _MediaGalleryStatesExampleState extends State<MediaGalleryStatesExample> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _showEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery States')),
      body: Column(
        children: [
          // Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = null;
                      _showEmpty = false;
                    });
                  },
                  child: const Text('Show Content'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                      _showEmpty = false;
                    });
                  },
                  child: const Text('Show Loading'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = 'Failed to load media';
                      _showEmpty = false;
                    });
                  },
                  child: const Text('Show Error'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = null;
                      _showEmpty = true;
                    });
                  },
                  child: const Text('Show Empty'),
                ),
              ],
            ),
          ),
          // Gallery
          Expanded(
            child: MediaGallery(
              mediaItems: _showEmpty ? [] : _generateSampleMedia(),
              isLoading: _isLoading,
              error: _errorMessage,
              onMediaTap: (media, index) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tapped: $index')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<MediaItem> _generateSampleMedia() {
    return List.generate(
      6,
      (index) => MediaItem(
        id: 'media_$index',
        userId: 'user1',
        journalEntryId: 'entry1',
        mediaType: MediaType.photo,
        storagePath: 'https://picsum.photos/seed/$index/400/400',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }
}

/// Example 4: Selection mode
class MediaGallerySelectionExample extends StatelessWidget {
  MediaGallerySelectionExample({super.key});

  final List<MediaItem> _sampleMedia = List.generate(
    15,
    (index) => MediaItem(
      id: 'media_$index',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: index % 3 == 0 ? MediaType.video : MediaType.photo,
      storagePath: 'https://picsum.photos/seed/$index/400/400',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selection Example')),
      body: MediaGallery(
        mediaItems: _sampleMedia,
        config: const MediaGalleryConfig(
          enableSelection: true,
          maxSelection: 5,
        ),
        onSelectionChanged: (selectedIds) {
          if (selectedIds.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${selectedIds.length} items selected'),
                duration: const Duration(milliseconds: 500),
              ),
            );
          }
        },
      ),
    );
  }
}

/// Example 5: Compact variant
class MediaGalleryCompactExample extends StatelessWidget {
  MediaGalleryCompactExample({super.key});

  final List<MediaItem> _sampleMedia = List.generate(
    10,
    (index) => MediaItem(
      id: 'media_$index',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: MediaType.photo,
      storagePath: 'https://picsum.photos/seed/$index/100/100',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compact Gallery')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Entry 1 with 2 photos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Morning Adventure',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Started our day with a hike'),
                  const SizedBox(height: 12),
                  MediaGalleryCompact(
                    mediaItems: _sampleMedia.take(2).toList(),
                    maxItems: 2,
                    onMediaTap: (media, index) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Photo ${index + 1}')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Entry 2 with 4 photos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Beach Day',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Relaxing by the ocean'),
                  const SizedBox(height: 12),
                  MediaGalleryCompact(
                    mediaItems: _sampleMedia.skip(2).take(4).toList(),
                    maxItems: 4,
                    onMediaTap: (media, index) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Photo ${index + 1}')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 6: Full-screen selection
class MediaGalleryFullscreenSelectionExample extends StatelessWidget {
  MediaGalleryFullscreenSelectionExample({super.key});

  final List<MediaItem> _sampleMedia = List.generate(
    20,
    (index) => MediaItem(
      id: 'media_$index',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: index % 3 == 0 ? MediaType.video : MediaType.photo,
      storagePath: 'https://picsum.photos/seed/$index/400/400',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fullscreen Selection Example')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MediaGalleryWithSelection(
                  mediaItems: _sampleMedia,
                  title: 'Select Photos',
                  maxSelection: 10,
                  onSelectionChanged: (selectedIds) {
                    debugPrint('Selected: ${selectedIds.length} items');
                  },
                  onMediaTap: (media, index) {
                    debugPrint('Tapped: ${media.id}');
                  },
                ),
              ),
            );
          },
          icon: const Icon(Icons.photo_library),
          label: const Text('Open Selection Gallery'),
        ),
      ),
    );
  }
}

/// Example 7: Gallery with captions
class MediaGalleryWithCaptionsExample extends StatelessWidget {
  MediaGalleryWithCaptionsExample({super.key});

  final List<MediaItem> _sampleMedia = [
    MediaItem(
      id: '1',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: MediaType.photo,
      storagePath: 'https://picsum.photos/seed/sunset/400/400',
      caption: 'Beautiful sunset at the beach',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MediaItem(
      id: '2',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: MediaType.photo,
      storagePath: 'https://picsum.photos/seed/mountain/400/400',
      caption: 'Mountain view from our hike',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MediaItem(
      id: '3',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: MediaType.photo,
      storagePath: 'https://picsum.photos/seed/food/400/400',
      caption: 'Local cuisine - amazing flavors!',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery with Captions')),
      body: MediaGallery(
        mediaItems: _sampleMedia,
        config: MediaGalleryConfig(
          forTripOverview.crossAxisCount,
          showCaption: true,
        ),
        onMediaTap: (media, index) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(media.caption ?? 'No caption')),
          );
        },
      ),
    );
  }
}

/// Example menu for navigating to all examples
class MediaGalleryExampleMenu extends StatelessWidget {
  const MediaGalleryExampleMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MediaGallery Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExampleCard(
            title: 'Basic Usage',
            description: 'Simple media gallery with tap handling',
            icon: Icons.photo_library,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BasicMediaGalleryExample(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'Configurations',
            description: 'Different grid layouts and styles',
            icon: Icons.grid_on,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MediaGalleryConfigExample(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'States',
            description: 'Loading, error, and empty states',
            icon: Icons.refresh,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MediaGalleryStatesExample(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'Selection Mode',
            description: 'Gallery with multi-select support',
            icon: Icons.check_circle,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MediaGallerySelectionExample(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'Compact Variant',
            description: 'Small gallery for tight spaces',
            icon: Icons.crop_square,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MediaGalleryCompactExample(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'Fullscreen Selection',
            description: 'Full-screen selection UI',
            icon: Icons.fullscreen,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MediaGalleryFullscreenSelectionExample(),
                ),
              );
            },
          ),
          _ExampleCard(
            title: 'With Captions',
            description: 'Gallery showing photo captions',
            icon: Icons.closed_caption,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MediaGalleryWithCaptionsExample(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
