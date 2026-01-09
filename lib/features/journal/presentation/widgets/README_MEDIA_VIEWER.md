# MediaViewer Widget

A comprehensive fullscreen modal viewer for displaying photos and videos with zoom, playback controls, and swipe navigation.

## Features

✅ **Fullscreen Display**: Immersive viewing experience with customizable background
✅ **Photo Viewing**: Display photos with zoom and pan gestures
✅ **Video Playback**: Full video player with play/pause controls
✅ **Swipe Navigation**: Easy navigation between multiple media items
✅ **Captions Support**: Display media captions at the bottom
✅ **Metadata Display**: Show file information (dimensions, duration, filename)
✅ **Navigation Arrows**: Quick access buttons for previous/next media
✅ **Index Indicator**: Visual indicator of current position in gallery
✅ **Configurable**: Extensive configuration options for different use cases
✅ **Material Design 3**: Full theme integration with modern styling

## Installation

This widget is part of the travel journal feature. Required dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  video_player: ^2.8.0
```

Add to `pubspec.yaml`:
```yaml
dependencies:
  video_player: ^2.8.0
```

## Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/media_viewer.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';

// Open fullscreen viewer
Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MediaViewer(
      mediaItems: myMediaItems,
      initialIndex: 0,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
);
```

### With Configuration

```dart
Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MediaViewer(
      mediaItems: myMediaItems,
      initialIndex: 0,
      config: MediaViewerConfig(
        showCaption: true,
        showMetadata: true,
        allowZoom: true,
        showNavigation: true,
        backgroundColor: Colors.black,
        autoplayVideos: false,
      ),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
);
```

### Integration with MediaGallery

```dart
// In your gallery widget
onTap: (media, index) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MediaViewer(
        mediaItems: mediaItems,
        initialIndex: index, // Start from tapped item
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
},
```

## Configuration Options

### MediaViewerConfig

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `showCaption` | bool | true | Show media captions at bottom |
| `showMetadata` | bool | true | Show file information (size, duration, etc.) |
| `allowZoom` | bool | true | Enable zoom/pan gestures for photos |
| `showNavigation` | bool | true | Show previous/next navigation arrows |
| `backgroundColor` | Color | Colors.black | Background color of the viewer |
| `autoplayVideos` | bool | false | Automatically start playing videos |

### Predefined Configurations

```dart
// Default configuration with all features
MediaViewerConfig.defaultConfig

// Minimal UI - no captions or navigation
MediaViewerConfig.minimal

// Immersive - autoplay videos, hide metadata
MediaViewerConfig.immersive
```

## Widget Components

### Main MediaViewer Widget

The primary fullscreen viewer widget.

```dart
MediaViewer(
  mediaItems: items,
  initialIndex: 0,
  config: MediaViewerConfig.defaultConfig,
  onPageChanged: (index) {
    print('Now viewing: ${index}');
  },
)
```

**Properties:**
- `mediaItems` (List<MediaItem>, required): List of media to display
- `initialIndex` (int, default: 0): Starting position
- `config` (MediaViewerConfig, default: defaultConfig): Viewer configuration
- `onPageChanged` (PageChangedCallback?): Callback when user changes media

### BuildPhotoView Widget

Internal widget for photo display with zoom and pan.

## Usage Examples

### Example 1: Basic Photo Viewer

```dart
final photoItems = [
  MediaItem(
    id: '1',
    userId: 'user1',
    journalEntryId: 'entry1',
    mediaType: MediaType.photo,
    storagePath: 'photos/sunset.jpg',
    width: 1920,
    height: 1080,
    caption: 'Beautiful sunset',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];

Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MediaViewer(
      mediaItems: photoItems,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
);
```

### Example 2: Video Gallery

```dart
final videoItems = [
  MediaItem(
    id: '1',
    userId: 'user1',
    journalEntryId: 'entry1',
    mediaType: MediaType.video,
    storagePath: 'videos/beach.mp4',
    width: 1920,
    height: 1080,
    duration: 120,
    caption: 'Beach waves',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];

Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MediaViewer(
      mediaItems: videoItems,
      config: MediaViewerConfig(
        autoplayVideos: true,
        showMetadata: true,
      ),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
);
```

### Example 3: Mixed Media Gallery

```dart
final mixedMedia = [
  photo1,
  video1,
  photo2,
  video2,
];

Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MediaViewer(
      mediaItems: mixedMedia,
      initialIndex: 0,
      onPageChanged: (index) {
        // Track which media is being viewed
        analytics.logViewMedia(mixedMedia[index].id);
      },
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
);
```

### Example 4: Immersive Photo Viewer

```dart
Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MediaViewer(
      mediaItems: photos,
      config: MediaViewerConfig(
        showCaption: true,
        showMetadata: false, // Hide technical details
        allowZoom: true,
        showNavigation: true,
        backgroundColor: Colors.black,
      ),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
);
```

### Example 5: Integration with Journal Entry Detail

```dart
// In JournalEntryDetailScreen
Widget _buildMediaSection(List<MediaItem> mediaItems) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Media (${mediaItems.length})',
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: mediaItems.length,
        itemBuilder: (context, index) {
          final media = mediaItems[index];
          return GestureDetector(
            onTap: () => _openFullscreenViewer(context, mediaItems, index),
            child: _buildMediaThumbnail(media),
          );
        },
      ),
    ],
  );
}

void _openFullscreenViewer(
  BuildContext context,
  List<MediaItem> mediaItems,
  int initialIndex,
) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MediaViewer(
        mediaItems: mediaItems,
        initialIndex: initialIndex,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}
```

## Customization

### Custom Transition Animations

```dart
// Fade transition
Navigator.of(context).push(
  PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => MediaViewer(
      mediaItems: items,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
);

// Scale transition
Navigator.of(context).push(
  PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => MediaViewer(
      mediaItems: items,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
        ),
        child: child,
      );
    },
  ),
);
```

### Custom Background Colors

```dart
MediaViewer(
  mediaItems: items,
  config: MediaViewerConfig(
    backgroundColor: Colors.white, // Light theme
  ),
)

// Or with theme
MediaViewer(
  mediaItems: items,
  config: MediaViewerConfig(
    backgroundColor: theme.colorScheme.surface,
  ),
)
```

### Showing/Hiding UI Elements

```dart
// Show only captions, no metadata or navigation
MediaViewer(
  mediaItems: items,
  config: MediaViewerConfig(
    showCaption: true,
    showMetadata: false,
    showNavigation: false,
    allowZoom: true,
  ),
)

// Disable zoom for read-only viewing
MediaViewer(
  mediaItems: items,
  config: MediaViewerConfig(
    allowZoom: false,
  ),
)
```

## UI States

The MediaViewer handles several states:

1. **Loading**: Shows progress indicator while media loads
2. **Photo Display**: Shows image with zoom/pan if enabled
3. **Video Player**: Shows video with play/pause controls
4. **Error**: Displays error message if media fails to load
5. **Empty**: Shows message if no media items provided

## Error Handling

The widget includes built-in error handling:
- Failed image loads display an error icon and message
- Video initialization errors are handled gracefully
- Loading states show progress indicators

## Performance Considerations

1. **Video Initialization**: Videos are initialized only when their page is displayed
2. **Resource Management**: Video controllers are properly disposed when changing pages
3. **Signed URLs**: Uses Supabase signed URLs with 60-minute expiry
4. **Lazy Loading**: Only current and adjacent pages are kept in memory by PageView

## Accessibility

- Close button is positioned for easy access
- Navigation arrows have large touch targets (48x48)
- Index indicator provides context for position in gallery
- High contrast UI elements on dark background
- Video controls use standard play/pause icons

## Platform Support

- **Android**: Full support including video playback
- **iOS**: Full support including video playback
- **Web**: Photo viewing supported (video playback may vary)

## Best Practices

1. **Always use PageRouteBuilder**: For smooth fade transitions when opening the viewer
2. **Provide meaningful initialIndex**: Start from the tapped item in galleries
3. **Handle large lists**: The widget efficiently handles any number of items
4. **Consider autoplay**: For video-heavy galleries, enable autoplayVideos in config
5. **Test video playback**: Ensure video URLs are accessible and properly signed
6. **Memory management**: The widget properly disposes of resources automatically

## Integration with Existing Components

### With MediaGallery

```dart
MediaGallery(
  mediaItems: items,
  config: MediaGalleryConfig.forTripOverview,
  onTap: (media, index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MediaViewer(
          mediaItems: items,
          initialIndex: index,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  },
)
```

### With TripOverviewScreen

```dart
// In media gallery section
GestureDetector(
  onTap: () {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MediaViewer(
          mediaItems: state.mediaItems,
          initialIndex: index,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  },
  child: _buildMediaThumbnail(media),
)
```

### With JournalEntryDetailScreen

```dart
// In media section
if (entry.hasMedia)
  GestureDetector(
    onTap: () => _openMediaViewer(context, entry.mediaItems, 0),
    child: _buildMediaPreview(entry.mediaItems),
  )
```

## Troubleshooting

### Videos not playing
- Ensure video_player dependency is added to pubspec.yaml
- Check that video URLs are accessible and signed URLs haven't expired
- Verify video format is supported (MP4 recommended)

### Images not loading
- Check Supabase storage permissions
- Verify signed URLs are being generated correctly
- Ensure storagePath is correct

### Zoom gestures not working
- Ensure `allowZoom` is true in MediaViewerConfig
- Check that BuildPhotoView is being used for image display

### Navigation arrows not showing
- Ensure `showNavigation` is true in config
- Verify that there are multiple media items (arrows hidden for single item)

## Future Enhancements

Potential improvements for future versions:
- Double-tap to zoom
- Landscape mode support
- Video scrubber/progress bar
- Fullscreen toggle
- Share button from viewer
- Delete button from viewer
- Edit caption from viewer
- Thumbnail strip for quick navigation
- Transition animations between media items
- Support for GIFs and live photos
- Panorama viewer mode

## Related Components

- **MediaGallery**: Grid display of media items
- **MediaPicker**: For selecting photos/videos
- **MediaUploadProgressIndicator**: For tracking upload progress
- **TripOverviewScreen**: Shows all media for a trip
- **JournalEntryDetailScreen**: Shows media for an entry

## Contributing

When contributing to the MediaViewer widget:
1. Follow existing code style and patterns
2. Add examples for new features
3. Update this README with changes
4. Test on both Android and iOS
5. Ensure video playback works properly
6. Test with various image sizes and formats
