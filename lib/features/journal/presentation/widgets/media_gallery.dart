import 'package:flutter/material.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/utils/performance/image_cache_manager.dart';

/// Configuration for media gallery display and behavior
class MediaGalleryConfig {
  /// Number of columns in the grid (default: 3)
  final int crossAxisCount;

  /// Spacing between columns (default: 8)
  final double crossAxisSpacing;

  /// Spacing between rows (default: 8)
  final double mainAxisSpacing;

  /// Aspect ratio for each grid item (default: 1.0 for square)
  final double childAspectRatio;

  /// Whether to show upload status overlays (default: true)
  final bool showUploadStatus;

  /// Whether to show video indicators (default: true)
  final bool showVideoIndicator;

  /// Whether to show captions (default: false)
  final bool showCaption;

  /// Maximum number of items to display (null = show all)
  final int? maxItems;

  /// Whether to enable selection mode (default: false)
  final bool enableSelection;

  /// Maximum number of items that can be selected (null = unlimited)
  final int? maxSelection;

  /// Whether to show empty state (default: true)
  final bool showEmptyState;

  const MediaGalleryConfig({
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.childAspectRatio = 1.0,
    this.showUploadStatus = true,
    this.showVideoIndicator = true,
    this.showCaption = false,
    this.maxItems,
    this.enableSelection = false,
    this.maxSelection,
    this.showEmptyState = true,
  });

  /// Predefined configurations
  static const forTripOverview = MediaGalleryConfig(
    crossAxisCount: 3,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 1.0,
  );

  static const forEntryDetail = MediaGalleryConfig(
    crossAxisCount: 2,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 1.0,
  );

  static const forFullscreen = MediaGalleryConfig(
    crossAxisCount: 1,
    crossAxisSpacing: 0,
    mainAxisSpacing: 0,
    childAspectRatio: 16 / 9,
  );

  static const compact = MediaGalleryConfig(
    crossAxisCount: 4,
    crossAxisSpacing: 4,
    mainAxisSpacing: 4,
    childAspectRatio: 1.0,
  );
}

/// Callback when media item is tapped
typedef MediaItemTapCallback = void Function(MediaItem media, int index);

/// Callback when media item is long-pressed
typedef MediaItemLongPressCallback = void Function(MediaItem media, int index);

/// Callback when selection changes
typedef MediaSelectionCallback = void Function(Set<String> selectedIds);

/// A reusable grid gallery widget for displaying photos and videos
///
/// This widget displays a collection of media items (photos and videos) in a
/// configurable grid layout with support for:
/// - Video indicators
/// - Upload status overlays
/// - Selection mode
/// - Empty and loading states
/// - Tap and long-press callbacks
/// - Customizable grid layout
///
/// Example usage:
/// ```dart
/// MediaGallery(
///   mediaItems: mediaList,
///   config: MediaGalleryConfig.forTripOverview,
///   onMediaTap: (media, index) {
///     // Handle tap - open fullscreen viewer
///   },
/// )
/// ```
class MediaGallery extends StatefulWidget {
  /// List of media items to display
  final List<MediaItem> mediaItems;

  /// Configuration for gallery display
  final MediaGalleryConfig config;

  /// Callback when a media item is tapped
  final MediaItemTapCallback? onMediaTap;

  /// Callback when a media item is long-pressed
  final MediaItemLongPressCallback? onMediaLongPress;

  /// Callback when selection changes (only used if enableSelection is true)
  final MediaSelectionCallback? onSelectionChanged;

  /// Whether to show loading state
  final bool isLoading;

  /// Error message to display
  final String? error;

  /// Widget to show when media list is empty
  final Widget? emptyStateWidget;

  /// Widget to show when loading
  final Widget? loadingWidget;

  /// Widget to show when there's an error
  final Widget? errorWidget;

  const MediaGallery({
    super.key,
    required this.mediaItems,
    this.config = MediaGalleryConfig.forTripOverview,
    this.onMediaTap,
    this.onMediaLongPress,
    this.onSelectionChanged,
    this.isLoading = false,
    this.error,
    this.emptyStateWidget,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<MediaGallery> createState() => _MediaGalleryState();
}

class _MediaGalleryState extends State<MediaGallery> {
  final Set<String> _selectedIds = {};

  void _toggleSelection(String mediaId) {
    setState(() {
      if (_selectedIds.contains(mediaId)) {
        _selectedIds.remove(mediaId);
      } else {
        if (widget.config.maxSelection == null ||
            _selectedIds.length < widget.config.maxSelection!) {
          _selectedIds.add(mediaId);
        }
      }
      widget.onSelectionChanged?.call(_selectedIds);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      widget.onSelectionChanged?.call(_selectedIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show loading state
    if (widget.isLoading) {
      return widget.loadingWidget ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
    }

    // Show error state
    if (widget.error != null) {
      return widget.errorWidget ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.error!,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
    }

    // Filter items based on maxItems
    final displayItems = widget.config.maxItems != null
        ? widget.mediaItems.take(widget.config.maxItems!).toList()
        : widget.mediaItems;

    // Show empty state
    if (displayItems.isEmpty && widget.config.showEmptyState) {
      return widget.emptyStateWidget ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No media yet',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Photos and videos will appear here',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    // Show empty state silently if showEmptyState is false
    if (displayItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Build grid
    return GridView.builder(
      shrinkWrap: true,
      physics: widget.config.crossAxisCount == 1
          ? const NeverScrollableScrollPhysics()
          : null,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.config.crossAxisCount,
        crossAxisSpacing: widget.config.crossAxisSpacing,
        mainAxisSpacing: widget.config.mainAxisSpacing,
        childAspectRatio: widget.config.childAspectRatio,
      ),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        final media = displayItems[index];
        final isSelected = _selectedIds.contains(media.id);

        return _MediaGridItem(
          media: media,
          config: widget.config,
          isSelected: isSelected,
          onTap: () {
            if (widget.config.enableSelection) {
              _toggleSelection(media.id);
            } else {
              widget.onMediaTap?.call(media, index);
            }
          },
          onLongPress: () {
            if (widget.config.enableSelection) {
              _toggleSelection(media.id);
            } else {
              widget.onMediaLongPress?.call(media, index);
            }
          },
        );
      },
    );
  }
}

/// Individual grid item widget for displaying a single media item
class _MediaGridItem extends StatelessWidget {
  final MediaItem media;
  final MediaGalleryConfig config;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ImageCacheConfig? imageConfig;

  const _MediaGridItem({
    required this.media,
    required this.config,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    this.imageConfig,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageManager = ImageCacheManager.instance;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media thumbnail or placeholder using optimized caching
            if (media.storagePath.isNotEmpty)
              imageManager.buildThumbnail(
                media.storagePath,
                placeholder: _buildLoadingPlaceholder(context),
                errorWidget: _buildPlaceholder(context),
                fit: BoxFit.cover,
              )
            else
              _buildPlaceholder(context),

            // Selection indicator
            if (isSelected)
              Positioned.fill(
                child: Container(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ),
              ),

            // Video indicator
            if (config.showVideoIndicator && media.isVideo)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

            // Upload status overlay
            if (config.showUploadStatus &&
                media.uploadStatus != UploadStatus.completed)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: _buildUploadStatusIcon(media.uploadStatus),
                  ),
                ),
              ),

            // Caption overlay
            if (config.showCaption && media.caption != null && media.caption!.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    media.caption!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          media.isVideo
              ? Icons.videocam_outlined
              : Icons.image_outlined,
          size: 32,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildUploadStatusIcon(UploadStatus status) {
    switch (status) {
      case UploadStatus.pending:
      case UploadStatus.uploading:
        return const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        );
      case UploadStatus.failed:
        return const Icon(Icons.error, color: Colors.red, size: 32);
      case UploadStatus.completed:
        return const SizedBox.shrink();
    }
  }
}

/// A compact variant of MediaGallery that fits in small spaces
class MediaGalleryCompact extends StatelessWidget {
  final List<MediaItem> mediaItems;
  final MediaItemTapCallback? onMediaTap;
  final int maxItems;

  const MediaGalleryCompact({
    super.key,
    required this.mediaItems,
    this.onMediaTap,
    this.maxItems = 4,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = mediaItems.take(maxItems).toList();

    if (displayItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return MediaGallery(
      mediaItems: displayItems,
      config: MediaGalleryConfig.compact,
      onMediaTap: onMediaTap,
    );
  }
}

/// A full-screen media gallery with selection support
class MediaGalleryWithSelection extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final MediaItemTapCallback? onMediaTap;
  final MediaSelectionCallback? onSelectionChanged;
  final int? maxSelection;
  final String title;

  const MediaGalleryWithSelection({
    super.key,
    required this.mediaItems,
    this.onMediaTap,
    this.onSelectionChanged,
    this.maxSelection,
    this.title = 'Select Media',
  });

  @override
  State<MediaGalleryWithSelection> createState() => _MediaGalleryWithSelectionState();
}

class _MediaGalleryWithSelectionState extends State<MediaGalleryWithSelection> {
  final Set<String> _selectedIds = {};

  void _handleSelectionChanged(Set<String> selectedIds) {
    setState(() {
      _selectedIds.clear();
      _selectedIds.addAll(selectedIds);
    });
    widget.onSelectionChanged?.call(selectedIds);
  }

  void _handleClearSelection() {
    setState(() {
      _selectedIds.clear();
    });
    widget.onSelectionChanged?.call(_selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_selectedIds.isNotEmpty)
            TextButton.icon(
              onPressed: _handleClearSelection,
              icon: const Icon(Icons.clear),
              label: Text('Clear (${_selectedIds.length})'),
            ),
          if (_selectedIds.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop(_selectedIds);
              },
              icon: const Icon(Icons.check),
              label: const Text('Done'),
            ),
        ],
      ),
      body: MediaGallery(
        mediaItems: widget.mediaItems,
        config: MediaGalleryConfig(
          enableSelection: true,
          maxSelection: widget.maxSelection,
          crossAxisCount: 3,
        ),
        onSelectionChanged: _handleSelectionChanged,
        onMediaTap: widget.onMediaTap,
      ),
    );
  }
}
