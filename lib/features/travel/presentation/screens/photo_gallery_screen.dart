import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';
import 'package:soloadventurer/core/models/paginated_data.dart';
import 'package:soloadventurer/features/travel/domain/models/photo.dart';

/// Screen displaying a photo gallery with infinite scroll pagination
///
/// This screen demonstrates the use of [InfiniteScrollGridView] for efficiently
/// loading and rendering large photo galleries (500+ items) in a grid layout
/// with automatic pagination as the user scrolls.
class PhotoGalleryScreen extends ConsumerWidget {
  /// Creates a new [PhotoGalleryScreen]
  const PhotoGalleryScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/trips/photos';

  /// Fetches paginated photo data
  ///
  /// In a real implementation, this would call a repository method:
  /// ```dart
  /// return await ref.read(photoRepositoryProvider).getPhotosCursor(
  ///   tripId: tripId,
  ///   cursor: cursor,
  ///   pageSize: 20,
  /// );
  /// ```
  Future<PaginatedData<Photo>> _fetchPhotos(String? cursor) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Parse cursor (page number)
    final page = cursor == null ? 1 : int.parse(cursor);
    final itemsPerPage = 20;

    // Generate mock photos with varied aspect ratios
    final photos = List.generate(
      page == 5 ? 10 : itemsPerPage, // Last page has fewer items
      (i) {
        // Create varied aspect ratios to demonstrate the feature
        // 0: portrait (3:4), 1: landscape (16:9), 2: square (1:1)
        final aspectRatioType = i % 3;
        int width, height;

        switch (aspectRatioType) {
          case 0: // Portrait
            width = 300;
            height = 400;
            break;
          case 1: // Landscape
            width = 400;
            height = 225;
            break;
          case 2: // Square
          default:
            width = 300;
            height = 300;
            break;
        }

        return Photo(
          id: '${page}_$i',
          imageUrl: 'https://picsum.photos/$width/$height?random=${page}_$i',
          thumbnailUrl: 'https://picsum.photos/150/${(height * 150 / width).toInt()}?random=${page}_$i',
          caption: i % 3 == 0 ? 'Photo caption ${(page - 1) * itemsPerPage + i + 1}' : null,
          tripId: 'trip123',
          location: i % 2 == 0 ? 'Location ${(page - 1) * itemsPerPage + i + 1}' : null,
          latitude: i % 2 == 0 ? 40.7128 + (i * 0.01) : null,
          longitude: i % 2 == 0 ? -74.0060 + (i * 0.01) : null,
          takenAt: DateTime.now().subtract(Duration(days: i)),
          width: width,
          height: height,
          sizeInBytes: 1024 * 100, // 100KB
          createdAt: DateTime.now().subtract(Duration(days: i)),
        );
      },
    );

    return PaginatedData(
      items: photos,
      pageInfo: PageInfo(
        currentPage: page,
        itemsPerPage: itemsPerPage,
        totalItems: 90,
        totalPages: 5,
        hasNextPage: page < 5,
        hasPreviousPage: page > 1,
        nextCursor: page < 5 ? '$page' : null,
        previousCursor: page > 1 ? '${page - 2}' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: InfiniteScrollGridView<Photo>(
        fetchData: _fetchPhotos,
        itemBuilder: (context, photo) => _PhotoGridItem(
          key: ValueKey(photo.id),
          photo: photo,
          onTap: () {
            // Navigate to full-screen photo viewer
          },
        ),
        crossAxisCount: _getCrossAxisCount(context),
        // Use per-item aspect ratio for correct photo proportions
        itemAspectRatioBuilder: (context, index, photo) {
          // Return the cached aspect ratio from the photo metadata
          // The Photo model has a pre-calculated aspectRatio getter
          return photo.aspectRatio;
        },
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        padding: const EdgeInsets.all(4.0),
        // Custom empty state
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
        // Custom error state
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
                  // Retry is handled automatically by InfiniteScrollGridView
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        // Load next page 300px before reaching end for faster perceived speed
        preloadThreshold: 300.0,
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
