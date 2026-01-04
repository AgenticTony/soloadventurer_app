import 'package:flutter/material.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/media_viewer.dart';

/// Example showing how to use the MediaViewer widget
class MediaViewerExample extends StatelessWidget {
  const MediaViewerExample({super.key});

  static const List<MediaItem> sampleMediaItems = [
    MediaItem(
      id: '1',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: MediaType.photo,
      storagePath: 'photos/sample1.jpg',
      originalFilename: 'sample1.jpg',
      width: 1920,
      height: 1080,
      caption: 'Beautiful sunset at the beach',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    MediaItem(
      id: '2',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: MediaType.video,
      storagePath: 'videos/sample1.mp4',
      originalFilename: 'sample1.mp4',
      width: 1920,
      height: 1080,
      duration: 60,
      caption: 'Ocean waves video',
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Viewer Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExampleCard(
            title: 'Basic Media Viewer',
            description: 'Open fullscreen viewer with default settings',
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const MediaViewer(
                    mediaItems: sampleMediaItems,
                    initialIndex: 0,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Start at Specific Index',
            description: 'Open viewer starting at the second item',
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const MediaViewer(
                    mediaItems: sampleMediaItems,
                    initialIndex: 1,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Minimal Configuration',
            description: 'Viewer with no captions or navigation',
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MediaViewer(
                    mediaItems: sampleMediaItems,
                    initialIndex: 0,
                    config: MediaViewerConfig.minimal,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Immersive Mode',
            description: 'Autoplay videos, hide metadata',
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MediaViewer(
                    mediaItems: sampleMediaItems,
                    initialIndex: 0,
                    config: MediaViewerConfig.immersive,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'With Page Change Callback',
            description: 'Track when user changes media',
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MediaViewer(
                    mediaItems: sampleMediaItems,
                    initialIndex: 0,
                    onPageChanged: (index) {
                      debugPrint('Changed to media at index: $index');
                    },
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Custom Background Color',
            description: 'Use white background instead of black',
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MediaViewer(
                    mediaItems: sampleMediaItems,
                    initialIndex: 0,
                    config: const MediaViewerConfig(
                      backgroundColor: Colors.white,
                    ),
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Integration with MediaGallery',
            description: 'Open viewer from a gallery tap',
            onTap: () {
              // Simulating opening from a gallery
              final tappedIndex = 0;
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MediaViewer(
                    mediaItems: sampleMediaItems,
                    initialIndex: tappedIndex,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
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
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Open',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example of integrating MediaViewer with MediaGallery
///
/// This shows how to open the fullscreen viewer when a user taps on a media item
/// in a gallery:
class MediaGalleryIntegrationExample extends StatelessWidget {
  const MediaGalleryIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Integration'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: MediaViewerExample.sampleMediaItems.length,
        itemBuilder: (context, index) {
          final media = MediaViewerExample.sampleMediaItems[index];
          return GestureDetector(
            onTap: () {
              // Open fullscreen viewer when tapped
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MediaViewer(
                    mediaItems: MediaViewerExample.sampleMediaItems,
                    initialIndex: index,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
            child: Container(
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  media.isVideo ? 'Video' : 'Photo',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Example menu for all media viewer examples
class MediaViewerExampleMenu extends StatelessWidget {
  const MediaViewerExampleMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Viewer Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuCard(
            title: 'Basic Examples',
            description: 'View all basic usage examples',
            icon: Icons.photo_library,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MediaViewerExample(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _MenuCard(
            title: 'Gallery Integration',
            description: 'See how to integrate with MediaGallery',
            icon: Icons.grid_on,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MediaGalleryIntegrationExample(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
