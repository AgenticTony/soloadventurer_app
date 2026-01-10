import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:video_player/video_player.dart';

/// Configuration for media viewer behavior
class MediaViewerConfig {
  /// Whether to show captions (default: true)
  final bool showCaption;

  /// Whether to show metadata (default: true)
  final bool showMetadata;

  /// Whether to allow zoom on images (default: true)
  final bool allowZoom;

  /// Whether to show navigation arrows (default: true)
  final bool showNavigation;

  /// Background color of the viewer (default: black)
  final Color backgroundColor;

  /// Whether to autoplay videos (default: false)
  final bool autoplayVideos;

  const MediaViewerConfig({
    this.showCaption = true,
    this.showMetadata = true,
    this.allowZoom = true,
    this.showNavigation = true,
    this.backgroundColor = Colors.black,
    this.autoplayVideos = false,
  });

  /// Predefined configurations
  static const defaultConfig = MediaViewerConfig();

  static const minimal = MediaViewerConfig(
    showCaption: false,
    showMetadata: false,
    allowZoom: false,
    showNavigation: false,
  );

  static const immersive = MediaViewerConfig(
    showCaption: true,
    showMetadata: false,
    allowZoom: true,
    showNavigation: true,
    backgroundColor: Colors.black,
    autoplayVideos: true,
  );
}

/// Callback when page is changed
typedef PageChangedCallback = void Function(int index);

/// A fullscreen modal viewer for displaying photos and videos
///
/// This widget provides an immersive fullscreen viewing experience with support for:
/// - Photo display with zoom and pan gestures
/// - Video playback with controls
/// - Swipe navigation between multiple media items
/// - Optional caption and metadata display
/// - Navigation arrows for quick access
/// - Material Design 3 styling
///
/// Example usage:
/// ```dart
/// Navigator.of(context).push(
///   PageRouteBuilder(
///     pageBuilder: (context, animation, secondaryAnimation) => MediaViewer(
///       mediaItems: items,
///       initialIndex: 0,
///     ),
///     transitionsBuilder: (context, animation, secondaryAnimation, child) {
///       return FadeTransition(opacity: animation, child: child);
///     },
///   ),
/// );
/// ```
class MediaViewer extends StatefulWidget {
  /// List of media items to display
  final List<MediaItem> mediaItems;

  /// Initial index to display (default: 0)
  final int initialIndex;

  /// Configuration for viewer behavior
  final MediaViewerConfig config;

  /// Callback when page is changed
  final PageChangedCallback? onPageChanged;

  const MediaViewer({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
    this.config = MediaViewerConfig.defaultConfig,
    this.onPageChanged,
  });

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  late PageController _pageController;
  late int _currentIndex;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void didUpdateWidget(MediaViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
      _pageController.jumpToPage(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo(String videoUrl) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    );

    try {
      await _videoController!.initialize();
      if (widget.config.autoplayVideos) {
        await _videoController!.play();
      }
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      // Handle video initialization error
      setState(() {
        _isVideoInitialized = false;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _isVideoInitialized = false;
    });
    widget.onPageChanged?.call(index);

    // Initialize video if current item is a video
    final currentItem = widget.mediaItems[index];
    if (currentItem.isVideo) {
      final signedUrl = Supabase.instance.client.storage
          .from('journal-videos')
          .createSignedUrl(currentItem.storagePath, expiryMinutes: 60);
      _initializeVideo(signedUrl);
    } else {
      _videoController?.dispose();
      _videoController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Initialize video on first build if needed
    if (_currentIndex < widget.mediaItems.length) {
      final currentItem = widget.mediaItems[_currentIndex];
      if (currentItem.isVideo && _videoController == null) {
        final signedUrl = Supabase.instance.client.storage
            .from('journal-videos')
            .createSignedUrl(currentItem.storagePath, expiryMinutes: 60);
        _initializeVideo(signedUrl);
      }
    }

    return Scaffold(
      backgroundColor: widget.config.backgroundColor,
      body: Stack(
        children: [
          // Main content
          _buildContent(),

          // Top bar
          _buildTopBar(theme),

          // Navigation arrows
          if (widget.config.showNavigation && widget.mediaItems.length > 1)
            _buildNavigationArrows(theme),

          // Bottom info
          if (widget.config.showCaption || widget.config.showMetadata)
            _buildBottomInfo(theme),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.mediaItems.isEmpty) {
      return const Center(
        child: Text(
          'No media to display',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: widget.mediaItems.length,
      itemBuilder: (context, index) {
        final media = widget.mediaItems[index];
        return _buildMediaItem(media);
      },
    );
  }

  Widget _buildMediaItem(MediaItem media) {
    if (media.isVideo) {
      return _buildVideoPlayer(media);
    } else {
      return _buildImageViewer(media);
    }
  }

  Widget _buildImageViewer(MediaItem media) {
    final signedUrl = Supabase.instance.client.storage
        .from('journal-photos')
        .createSignedUrl(media.storagePath, expiryMinutes: 60);

    if (widget.config.allowZoom) {
      return BuildPhotoView(
        imageUrl: signedUrl,
        backgroundColor: widget.config.backgroundColor,
      );
    } else {
      return Image.network(
        signedUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load image',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          );
        },
      );
    }
  }

  Widget _buildVideoPlayer(MediaItem media) {
    if (!_isVideoInitialized || _videoController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Close button
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),

              // Index indicator
              if (widget.mediaItems.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.mediaItems.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // Video controls (if video)
              if (_isVideoInitialized && _videoController != null)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                    ),
                  ],
                )
              else
                const SizedBox(width: 48), // Balance the close button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationArrows(ThemeData theme) {
    return Stack(
      children: [
        // Previous button
        if (_currentIndex > 0)
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
          ),

        // Next button
        if (_currentIndex < widget.mediaItems.length - 1)
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomInfo(ThemeData theme) {
    final media = widget.mediaItems[_currentIndex];
    final hasCaption = media.caption != null && media.caption!.isNotEmpty;
    final hasMetadata = widget.config.showMetadata &&
        (media.width != null ||
            media.height != null ||
            media.duration != null ||
            media.originalFilename != null);

    if (!hasCaption && !hasMetadata) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Caption
              if (hasCaption)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    media.caption!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),

              // Metadata
              if (hasMetadata)
                Row(
                  children: [
                    if (media.isPhoto &&
                        media.width != null &&
                        media.height != null)
                      _buildMetadataChip(
                        Icons.photo_size_select_large,
                        '${media.width} × ${media.height}',
                      ),
                    if (media.isVideo && media.duration != null)
                      _buildMetadataChip(
                        Icons.schedule,
                        _formatDuration(media.duration!),
                      ),
                    if (media.originalFilename != null)
                      _buildMetadataChip(
                        Icons.insert_drive_file,
                        media.originalFilename!,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

/// A photo viewer with zoom and pan capabilities
///
/// This widget uses a simple transformation approach for zoom and pan gestures
class BuildPhotoView extends StatefulWidget {
  final String imageUrl;
  final Color backgroundColor;

  const BuildPhotoView({
    super.key,
    required this.imageUrl,
    this.backgroundColor = Colors.black,
  });

  @override
  State<BuildPhotoView> createState() => _BuildPhotoViewState();
}

class _BuildPhotoViewState extends State<BuildPhotoView> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _previousScale = _scale;
        _previousOffset = _offset;
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = _previousScale * details.scale;
          _offset =
              _previousOffset + details.focalPoint - details.localFocalPoint;
        });
      },
      onScaleEnd: (details) {
        // Reset to initial if scale is close to 1
        if (_scale < 1.1) {
          setState(() {
            _scale = 1.0;
            _offset = Offset.zero;
          });
        }
      },
      child: Container(
        color: widget.backgroundColor,
        child: Center(
          child: Transform(
            transform: Matrix4.identity()
              ..translate(_offset.dx, _offset.dy)
              ..scale(_scale),
            alignment: Alignment.center,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load image',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
