import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';
import 'package:soloadventurer/features/travel/domain/models/photo.dart';

/// Provider for photos data
///
/// In a real implementation, this would fetch data from a repository
/// For demonstration purposes, we're using a simple provider
final photosProvider = Provider<List<Photo>>((ref) {
  // This would normally come from a repository
  return [];
});

/// Provider for loading state
final photosLoadingProvider = Provider<bool>((ref) => false);

/// Provider for error state
final photosErrorProvider = Provider<bool>((ref) => false);

/// Screen displaying a photo gallery with virtual scrolling grid
///
/// This screen demonstrates the use of [VirtualGridView] for efficiently
/// rendering large photo galleries (500+ items) in a grid layout.
class PhotoGalleryScreen extends ConsumerWidget {
  /// Creates a new [PhotoGalleryScreen]
  const PhotoGalleryScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/trips/photos';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photosProvider);
    final isLoading = ref.watch(photosLoadingProvider);
    final hasError = ref.watch(photosErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () {
              // Toggle between grid and list views
            },
            tooltip: 'Change view',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options (by date, location, etc.)
            },
            tooltip: 'Filter',
          ),
          PopupMenuButton<PhotoSortOption>(
            onSelected: (option) {
              // Handle sort option selection
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: PhotoSortOption.newest,
                child: Text('Newest first'),
              ),
              const PopupMenuItem(
                value: PhotoSortOption.oldest,
                child: Text('Oldest first'),
              ),
              const PopupMenuItem(
                value: PhotoSortOption.location,
                child: Text('By location'),
              ),
            ],
          ),
        ],
      ),
      body: VirtualGridView.photoGrid<Photo>(
        itemCount: photos.length,
        isLoading: isLoading,
        hasError: hasError,
        crossAxisCount: _getCrossAxisCount(context),
        padding: const EdgeInsets.all(4.0),
        loadingWidget: const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load photos'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Retry logic would go here
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        emptyWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No photos yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Add photos to your trip to see them here'),
            ],
          ),
        ),
        itemBuilder: (context, index) {
          final photo = photos[index];
          return _PhotoGridItem(
            key: ValueKey(photo.id),
            photo: photo,
            onTap: () {
              // Navigate to full-screen photo viewer
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new photo (camera or gallery picker)
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  /// Calculates the appropriate number of columns based on screen size
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 4; // Tablet
    } else if (width > 400) {
      return 3; // Large phone
    } else {
      return 2; // Small phone
    }
  }
}

/// Widget displaying a single photo in the grid
class _PhotoGridItem extends StatelessWidget {
  final Photo photo;
  final VoidCallback onTap;

  const _PhotoGridItem({
    super.key,
    required this.photo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GridTile(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _PhotoImage(photo: photo),
            if (photo.caption != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _PhotoCaption(caption: photo.caption!),
              ),
            if (photo.location != null)
              Positioned(
                top: 4,
                right: 4,
                child: _LocationIcon(location: photo.location!),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying the photo image with lazy loading
class _PhotoImage extends StatelessWidget {
  final Photo photo;

  const _PhotoImage({required this.photo});

  @override
  Widget build(BuildContext context) {
    // Use LazyLoadImage for visibility-based lazy loading
    return LazyLoadImage.photo(
      imageUrl: photo.displayUrl,
      thumbnailUrl: photo.thumbnailUrl,
      fit: BoxFit.cover,
      visibilityThreshold: 0.01,
      placeholder: (context, url) {
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
        );
      },
    );
  }
}

/// Widget for displaying photo caption overlay
class _PhotoCaption extends StatelessWidget {
  final String caption;

  const _PhotoCaption({required this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Text(
        caption,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Widget for displaying location icon
class _LocationIcon extends StatelessWidget {
  final String location;

  const _LocationIcon({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.location_on,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}

/// Sort options for photo gallery
enum PhotoSortOption {
  newest,
  oldest,
  location,
}
