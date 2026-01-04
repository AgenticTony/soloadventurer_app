# MediaGallery Widget

A comprehensive, reusable grid gallery widget for displaying photos and videos in Flutter applications with support for customizable layouts, selection mode, and various display states.

## Features

- **Configurable Grid Layout**: Flexible grid with customizable columns, spacing, and aspect ratios
- **Video Indicators**: Visual indicators to distinguish videos from photos
- **Upload Status**: Visual overlays for pending, uploading, and failed media
- **Selection Mode**: Multi-select support with customizable limits
- **State Handling**: Built-in loading, error, and empty states
- **Caption Support**: Optional caption display with gradient overlay
- **Material Design 3**: Full theme integration with modern styling
- **Tap & Long-Press**: Callbacks for user interactions
- **Compact Variants**: Predefined configurations for common use cases

## Installation

No additional dependencies required beyond Flutter and the journal feature dependencies.

Add to your widget imports:

```dart
import 'package:soloadventurer/features/journal/presentation/widgets/media_gallery.dart';
```

## Quick Start

### Basic Usage

```dart
MediaGallery(
  mediaItems: myMediaList,
  config: MediaGalleryConfig.forTripOverview,
  onMediaTap: (media, index) {
    // Navigate to fullscreen viewer
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MediaViewerScreen(mediaItem: media),
    ));
  },
)
```

### With Loading and Error States

```dart
MediaGallery(
  mediaItems: mediaItems,
  isLoading: _isLoading,
  error: _errorMessage,
  onMediaTap: (media, index) {
    // Handle tap
  },
)
```

### With Selection Mode

```dart
MediaGallery(
  mediaItems: mediaItems,
  config: const MediaGalleryConfig(
    enableSelection: true,
    maxSelection: 10,
  ),
  onSelectionChanged: (selectedIds) {
    print('Selected ${selectedIds.length} items');
  },
)
```

## Configuration Options

### MediaGalleryConfig

The `MediaGalleryConfig` class controls the gallery's appearance and behavior:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `crossAxisCount` | int | 3 | Number of columns in the grid |
| `crossAxisSpacing` | double | 8 | Horizontal spacing between items |
| `mainAxisSpacing` | double | 8 | Vertical spacing between items |
| `childAspectRatio` | double | 1.0 | Aspect ratio of grid items (width/height) |
| `showUploadStatus` | bool | true | Show upload progress/failed overlays |
| `showVideoIndicator` | bool | true | Show play icon on videos |
| `showCaption` | bool | false | Show media captions with overlay |
| `maxItems` | int? | null | Maximum items to display (null = all) |
| `enableSelection` | bool | false | Enable multi-select mode |
| `maxSelection` | int? | null | Max items selectable (null = unlimited) |
| `showEmptyState` | bool | true | Show empty state widget |

### Predefined Configurations

```dart
// 3-column grid for trip overview
MediaGalleryConfig.forTripOverview

// 2-column grid for entry detail
MediaGalleryConfig.forEntryDetail

// Single item fullscreen view
MediaGalleryConfig.forFullscreen

// 4-column compact grid
MediaGalleryConfig.compact
```

## Usage Patterns

### 1. Trip Overview Screen

Display all media from a trip in a 3-column grid:

```dart
class TripOverviewScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewState = ref.watch(tripOverviewProvider(tripId));

    return Scaffold(
      body: Column(
        children: [
          // Trip info section
          // ...

          // Media gallery section
          Expanded(
            child: MediaGallery(
              mediaItems: overviewState.mediaItems,
              isLoading: overviewState.isLoadingMedia,
              config: MediaGalleryConfig.forTripOverview,
              onMediaTap: (media, index) {
                // Open fullscreen media viewer
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => MediaViewerScreen(
                    mediaItems: overviewState.mediaItems,
                    initialIndex: index,
                  ),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. Journal Entry Detail Screen

Show media attached to a specific entry:

```dart
class JournalEntryDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(journalEntryDetailProvider(entryId));

    return Scaffold(
      body: ListView(
        children: [
          // Entry content
          // ...

          // Media gallery
          if (detailState.mediaItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: MediaGallery(
                mediaItems: detailState.mediaItems,
                config: MediaGalleryConfig.forEntryDetail,
                showCaption: true,
                onMediaTap: (media, index) {
                  // Handle tap
                },
              ),
            ),
        ],
      ),
    );
  }
}
```

### 3. Compact Gallery for Entry Cards

Show small preview of entry media:

```dart
Card(
  child: Column(
    children: [
      Text(entry.title),
      const SizedBox(height: 8),
      MediaGalleryCompact(
        mediaItems: entry.mediaItems,
        maxItems: 4,
        onMediaTap: (media, index) {
          // Navigate to detail or viewer
        },
      ),
    ],
  ),
)
```

### 4. Multi-Select for Batch Operations

Select multiple media for batch delete or share:

```dart
Set<String> _selectedIds = {};

MediaGallery(
  mediaItems: mediaItems,
  config: const MediaGalleryConfig(
    enableSelection: true,
    maxSelection: null, // Unlimited
  ),
  onSelectionChanged: (selectedIds) {
    setState(() {
      _selectedIds = selectedIds;
    });
  },
)

// Use selected IDs
FloatingActionButton(
  onPressed: _selectedIds.isEmpty ? null : () {
    // Perform batch operation
    _deleteSelectedMedia(_selectedIds);
  },
  child: const Icon(Icons.delete),
)
```

### 5. Full-Screen Selection UI

Use the prebuilt full-screen selection widget:

```dart
ElevatedButton(
  onPressed: () async {
    final selectedIds = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (context) => MediaGalleryWithSelection(
          mediaItems: allMediaItems,
          title: 'Select Photos to Share',
          maxSelection: 10,
          onSelectionChanged: (selectedIds) {
            debugPrint('Selected: ${selectedIds.length}');
          },
        ),
      ),
    );

    if (selectedIds != null) {
      // Handle selected media
      _shareSelectedMedia(selectedIds);
    }
  },
  child: const Text('Select Photos'),
)
```

### 6. Custom Configuration

Create your own grid layout:

```dart
MediaGallery(
  mediaItems: mediaItems,
  config: const MediaGalleryConfig(
    crossAxisCount: 5,           // 5 columns
    crossAxisSpacing: 4,         // Tight spacing
    mainAxisSpacing: 4,
    childAspectRatio: 0.8,       // Portrait aspect ratio
    showVideoIndicator: true,
    showCaption: false,
    maxItems: 20,                // Show max 20 items
  ),
)
```

## Widget Components

### MediaGallery

The main gallery widget with full configuration support.

**Parameters:**
- `mediaItems` (required): List of MediaItem to display
- `config`: Display configuration (defaults to forTripOverview)
- `onMediaTap`: Callback when item is tapped
- `onMediaLongPress`: Callback when item is long-pressed
- `onSelectionChanged`: Callback for selection changes (if enabled)
- `isLoading`: Show loading state
- `error`: Error message to display
- `emptyStateWidget`: Custom empty state widget
- `loadingWidget`: Custom loading widget
- `errorWidget`: Custom error widget

### MediaGalleryCompact

A compact variant for small spaces with preset 4-column grid.

**Parameters:**
- `mediaItems` (required): List of MediaItem
- `onMediaTap`: Tap callback
- `maxItems`: Maximum items to show (default: 4)

### MediaGalleryWithSelection

Full-screen gallery with selection support and AppBar controls.

**Parameters:**
- `mediaItems` (required): List of MediaItem
- `title`: AppBar title
- `maxSelection`: Maximum selectable items
- `onMediaTap`: Tap callback
- `onSelectionChanged`: Selection change callback

## Display States

### Loading State

```dart
MediaGallery(
  mediaItems: [],
  isLoading: true,
)
```

Shows a centered circular progress indicator. Customize with `loadingWidget`.

### Error State

```dart
MediaGallery(
  mediaItems: [],
  error: 'Failed to load media',
)
```

Shows an error icon with message. Customize with `errorWidget`.

### Empty State

```dart
MediaGallery(
  mediaItems: [],
)
```

Shows a "No media yet" message. Customize with `emptyStateWidget` or disable with `MediaGalleryConfig(showEmptyState: false)`.

## Customization

### Custom Empty State

```dart
MediaGallery(
  mediaItems: [],
  emptyStateWidget: Center(
    child: Column(
      children: [
        Icon(Icons.camera_alt, size: 64),
        SizedBox(height: 16),
        Text('Add your first photo'),
        ElevatedButton(
          onPressed: () => _pickMedia(),
          child: Text('Add Photo'),
        ),
      ],
    ),
  ),
)
```

### Custom Loading Widget

```dart
MediaGallery(
  mediaItems: [],
  isLoading: true,
  loadingWidget: Center(
    child: Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Loading your memories...'),
      ],
    ),
  ),
)
```

### Custom Error Widget

```dart
MediaGallery(
  mediaItems: [],
  error: 'Network error',
  errorWidget: Center(
    child: Column(
      children: [
        Icon(Icons.wifi_off, size: 64, color: Colors.orange),
        SizedBox(height: 16),
        Text('No internet connection'),
        ElevatedButton(
          onPressed: () => _retry(),
          child: Text('Retry'),
        ),
      ],
    ),
  ),
)
```

## Integration with Existing Components

### With MediaPicker

After picking media with MediaPicker:

```dart
void _handleMediaPicked(List<PickedMediaFile> pickedFiles) async {
  // Compress and upload media
  for (final file in pickedFiles) {
    await ref.read(mediaUploadProvider.notifier).enqueueUpload(
      filePath: file.file.path,
      mediaType: file.mediaType,
      journalEntryId: entryId,
    );
  }

  // Refresh gallery after uploads start
  ref.read(tripOverviewProvider(tripId).notifier).refresh();
}
```

### With MediaUploadProgressIndicator

Monitor upload progress in the gallery:

```dart
MediaGallery(
  mediaItems: mediaItems,
  config: const MediaGalleryConfig(
    showUploadStatus: true, // Shows progress overlays
  ),
)
```

### With TripOverviewProvider

Use in trip overview screen:

```dart
class TripOverviewScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewState = ref.watch(tripOverviewProvider(tripId));

    return MediaGallery(
      mediaItems: overviewState.mediaItems,
      isLoading: overviewState.isLoadingMedia,
      onMediaTap: (media, index) {
        // Navigate to viewer
      },
    );
  }
}
```

## Performance Considerations

1. **Limit Items**: Use `maxItems` for large lists to avoid rendering all items at once
2. **Image Caching**: The widget uses `Image.network` which Flutter caches automatically
3. **Lazy Loading**: For very large galleries (100+ items), consider pagination
4. **Thumbnails**: Use thumbnail URLs instead of full resolution when available

```dart
// Good: Limit displayed items
MediaGallery(
  mediaItems: allMediaItems,
  config: const MediaGalleryConfig(maxItems: 50),
)

// Better: Implement pagination for large datasets
```

## Accessibility

The widget includes:
- Semantic labels for screen readers (via Image widget)
- Tap targets are minimum 48x48 (Material Design guidelines)
- Video indicators use standard icons
- High contrast for upload status overlays

## Error Handling

The widget handles:
- Network image loading errors (shows placeholder)
- Invalid data (graceful fallbacks)
- Empty lists (shows empty state)
- Upload failures (shows error overlay)

## Testing

```dart
testWidgets('MediaGallery displays items', (tester) async {
  final mediaItems = [
    MediaItem(
      id: '1',
      userId: 'user1',
      journalEntryId: 'entry1',
      mediaType: MediaType.photo,
      storagePath: 'https://example.com/photo.jpg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  await tester.pumpWidget(
    MaterialApp(
      home: MediaGallery(mediaItems: mediaItems),
    ),
  );

  expect(find.byType(MediaGallery), findsOneWidget);
  expect(find.byType(Image), findsOneWidget);
});

testWidgets('MediaGallery shows loading state', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaGallery(
        mediaItems: [],
        isLoading: true,
      ),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Troubleshooting

### Images Not Loading

Ensure the `storagePath` contains a valid URL. Check network permissions.

### Grid Looks Squashed

Adjust `childAspectRatio` in config:
```dart
config: MediaGalleryConfig(
  childAspectRatio: 16 / 9, // Wider items
)
```

### Selection Not Working

Ensure `enableSelection: true` is set in config:
```dart
config: const MediaGalleryConfig(enableSelection: true)
```

### Too Many Items Causing Lag

Use `maxItems` or implement pagination:
```dart
config: const MediaGalleryConfig(maxItems: 100)
```

## Future Enhancements

Potential improvements for future versions:
- [ ] Built-in pagination support
- [ ] Drag-and-drop reordering
- [ ] Filter by media type (photos/videos only)
- [ ] Sort options (date, size, name)
- [ ] Animated transitions between layouts
- [ ] Zoom on double-tap
- [ ] Swipe-to-delete gestures
- [ ] Custom overlay widgets
- [ ] Masonry layout support
- [ ] Staggered grid animation

## Related Components

- **MediaPicker**: For selecting photos/videos from device
- **MediaUploadProgressIndicator**: For showing upload progress
- **MediaViewer** (upcoming): For fullscreen media viewing
- **TripOverviewScreen**: Uses MediaGallery for trip media
- **JournalEntryDetailScreen**: Shows entry media with captions

## License

This component is part of the SoloAdventurer travel journal application.

## Contributing

When modifying this widget:
1. Maintain backward compatibility with existing configs
2. Add examples for new features to media_gallery_example.dart
3. Update this README with new usage patterns
4. Test with various screen sizes and orientations
5. Ensure Material Design 3 compliance
