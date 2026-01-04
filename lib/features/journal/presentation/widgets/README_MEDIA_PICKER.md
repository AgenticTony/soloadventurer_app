# MediaPicker Widget

A comprehensive Flutter widget for selecting photos and videos from the device library with built-in compression and quality control.

## Features

- ✅ **Multiple Media Sources**
  - Pick photos from gallery
  - Take photos with camera
  - Pick videos from gallery
  - Record videos with camera

- ✅ **Flexible Configuration**
  - Multiple selection support
  - Maximum file size limits
  - Maximum item count limits
  - Quality presets (Optimized, High, Aggressive)

- ✅ **Automatic Compression**
  - Image compression using `flutter_image_compress`
  - Video compression framework ready
  - Configurable quality settings
  - Progress feedback

- ✅ **Two Display Modes**
  - Button mode (compact, shows bottom sheet)
  - Inline mode (full control over layout)

- ✅ **Type Safety**
  - Full TypeScript-like type safety with Dart
  - MediaType enum (photo, video)
  - Comprehensive metadata handling

## Installation

The widget uses the `image_picker` package which should already be in your `pubspec.yaml`:

```yaml
dependencies:
  image_picker: ^1.0.7
  flutter_image_compress: ^2.3.0  # For image compression
  flutter_riverpod: ^2.5.1        # For state management
```

### Platform Setup

#### iOS

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select photos for your journal entries.</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take photos for your journal entries.</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone to record videos for your journal entries.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need permission to save photos to your library.</string>
```

#### Android

Add the following to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

For Android 13+ (API 33+), also add:

```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

## Usage

### Basic Usage (Button Mode)

```dart
import 'package:soloadventurer/features/journal/presentation/widgets/media_picker.dart';

class MyScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  final List<PickedMediaFile> _selectedMedia = [];

  void _onMediaPicked(List<PickedMediaFile> media) {
    setState(() {
      _selectedMedia.addAll(media);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Media picker button
          MediaPicker(
            onMediaPicked: _onMediaPicked,
            buttonText: 'Add Photos & Videos',
          ),

          // Display selected media
          // ... your UI code
        ],
      ),
    );
  }
}
```

### Custom Configuration

```dart
MediaPicker(
  config: MediaPickerConfig(
    maxItems: 20,                          // Max 20 items
    maxFileSize: 100 * 1024 * 1024,        // 100 MB limit
    allowMultiple: true,                   // Allow multiple selection
    compressImages: true,                  // Compress images
    imageCompressionConfig: ImageCompressionConfig(
      maxWidth: 1920,
      maxHeight: 1920,
      quality: 85,
    ),
    compressVideos: true,                  // Compress videos
    quality: MediaQuality.optimized,       // Quality preset
  ),
  onMediaPicked: _onMediaPicked,
)
```

### Using Preset Configurations

```dart
// Optimized for travel (recommended)
MediaPicker(
  config: MediaPickerConfig.forTravelJournal(),
  onMediaPicked: _onMediaPicked,
)

// High quality
MediaPicker(
  config: MediaPickerConfig.highQuality(),
  onMediaPicked: _onMediaPicked,
)

// Aggressive compression (smallest files)
MediaPicker(
  config: MediaPickerConfig.aggressive(),
  onMediaPicked: _onMediaPicked,
)
```

### Inline Mode

```dart
MediaPicker(
  showAsButton: false,  // Show inline options instead of button
  config: MediaPickerConfig.forTravelJournal(),
  onMediaPicked: _onMediaPicked,
)
```

### Integration with Journal Entry Creation

```dart
class CreateJournalEntryScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreateJournalEntryScreen> createState() =>
      _CreateJournalEntryScreenState();
}

class _CreateJournalEntryScreenState
    extends ConsumerState<CreateJournalEntryScreen> {
  final List<PickedMediaFile> _mediaFiles = [];
  final TextEditingController _titleController = TextEditingController();

  void _onMediaPicked(List<PickedMediaFile> media) {
    setState(() {
      _mediaFiles.addAll(media);
    });
  }

  Future<void> _saveEntry() async {
    // Convert PickedMediaFile to MediaItem entities
    final mediaItems = _mediaFiles.map((file) {
      return MediaItem(
        id: uuid.v4(),
        userId: currentUser.id,
        journalEntryId: entryId,
        mediaType: file.mediaType,
        storagePath: '',  // Will be set after upload
        originalFilename: file.fileName,
        fileSize: file.fileSize,
        mimeType: file.mimeType,
        width: file.width,
        height: file.height,
        duration: file.duration,
        uploadStatus: UploadStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();

    // Upload media files to Supabase Storage
    // ... your upload logic

    // Create journal entry with media
    // ... your save logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),

            const SizedBox(height: 16),

            // Media picker
            MediaPicker(
              config: MediaPickerConfig.forTravelJournal(),
              onMediaPicked: _onMediaPicked,
            ),

            const SizedBox(height: 16),

            // Media preview
            if (_mediaFiles.isNotEmpty)
              Wrap(
                children: _mediaFiles.map((media) {
                  return Chip(
                    avatar: Icon(
                      media.isVideo ? Icons.videocam : Icons.image,
                    ),
                    label: Text(media.formattedFileSize),
                    onDeleted: () {
                      setState(() {
                        _mediaFiles.remove(media);
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
```

## API Reference

### MediaPicker Widget

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `onMediaPicked` | `ValueChanged<List<PickedMediaFile>>?` | `null` | Callback when media is selected |
| `config` | `MediaPickerConfig` | `MediaPickerConfig.forTravelJournal()` | Picker configuration |
| `showAsButton` | `bool` | `true` | Show as button (true) or inline (false) |
| `buttonText` | `String` | `'Add Media'` | Button text when showAsButton is true |
| `buttonIcon` | `IconData?` | `Icons.add_photo_alternate` | Button icon |
| `enabled` | `bool` | `true` | Whether the picker is enabled |
| `buttonStyle` | `ButtonStyle?` | `null` | Custom button style |

### MediaPickerConfig

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `maxItems` | `int?` | `null` | Maximum number of items to select |
| `maxFileSize` | `int?` | `100 MB` | Maximum file size in bytes |
| `allowMultiple` | `bool` | `true` | Allow multiple selection |
| `compressImages` | `bool` | `true` | Whether to compress images |
| `imageCompressionConfig` | `ImageCompressionConfig?` | `ImageCompressionConfig.optimizedForTravel` | Image compression settings |
| `compressVideos` | `bool` | `true` | Whether to compress videos |
| `videoCompressionConfig` | `VideoCompressionConfig?` | `VideoCompressionConfig.optimizedForTravel` | Video compression settings |
| `quality` | `MediaQuality` | `MediaQuality.optimized` | Quality preset |

### PickedMediaFile

| Property | Type | Description |
|----------|------|-------------|
| `file` | `File` | The picked file |
| `mediaType` | `MediaType` | Type of media (photo/video) |
| `fileName` | `String` | Original file name |
| `fileSize` | `int` | File size in bytes |
| `mimeType` | `String?` | MIME type |
| `width` | `int?` | Width in pixels |
| `height` | `int?` | Height in pixels |
| `duration` | `int?` | Duration in seconds (videos) |
| `formattedFileSize` | `String` | Formatted file size string (getter) |
| `isVideo` | `bool` | Whether file is a video (getter) |
| `isPhoto` | `bool` | Whether file is a photo (getter) |

## Error Handling

The widget automatically handles common errors:

- **Permission denied**: Shows permission error message
- **File too large**: Validates against maxFileSize and shows error
- **Too many items**: Validates against maxItems and shows error
- **Compression failure**: Falls back to original file with error message

Custom error handling:

```dart
MediaPicker(
  onMediaPicked: (media) {
    try {
      // Process media
      _handleMedia(media);
    } catch (e) {
      // Show custom error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process media: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
)
```

## Compression

The widget integrates with the existing compression utilities:

### Image Compression

Images are compressed using `MediaCompression.compressImage()` with configurable:
- Maximum dimensions (width/height)
- Quality (0-100)
- Target file size
- Format (JPEG/PNG)

### Video Compression

Videos are compressed using `VideoCompression.compressVideo()` with configurable:
- Resolution (720p, 1080p, 480p)
- Quality (0-100)
- Frame rate
- Audio bitrate

**Note**: Video compression requires a package implementation (video_compress or ffmpeg_kit_flutter). The framework is ready but needs the actual implementation.

## Quality Presets

### Optimized (Recommended)
- Max dimensions: 1920x1920
- Quality: 85%
- Good balance between quality and size
- Best for travel journals

### High Quality
- Max dimensions: 2560x2560
- Quality: 95%
- Minimal compression
- Larger file sizes

### Aggressive
- Max dimensions: 1280x1280
- Quality: 75%
- Maximum compression
- Smallest file sizes

## Styling

### Custom Button Style

```dart
MediaPicker(
  buttonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

### Theme Integration

The widget respects your app's theme:
- Uses `Theme.of(context).colorScheme.primary` for primary actions
- Uses `Theme.of(context).disabledColor` for disabled state
- Uses `Theme.of(context).dividerColor` for dividers

## Examples

See `media_picker_example.dart` for complete examples:
1. **MediaPickerExampleScreen**: Full-featured example with quality selector
2. **InlineMediaPickerExample**: Inline mode usage
3. **JournalEntryWithMediaExample**: Integration with journal creation

Run examples:
```bash
# Add to your routes
'/examples/media-picker': (context) => const MediaPickerExampleScreen(),
```

## Platform Support

| Platform | Photos | Videos | Camera | Compression |
|----------|--------|--------|--------|-------------|
| Android | ✅ | ✅ | ✅ | ✅ |
| iOS | ✅ | ✅ | ✅ | ✅ |
| Web | ⚠️ | ⚠️ | ⚠️ | Limited |

**Web Limitations**:
- Camera support limited by browser capabilities
- Compression options limited
- File system access restricted

## Troubleshooting

### Permissions Not Granted

If users deny permissions, the widget will show an error. Handle this gracefully:

```dart
// Check permissions before showing picker
// You can use the permission_handler package for this
```

### Compression Errors

If compression fails, the widget automatically falls back to the original file. Check console logs for details.

### Large Files

For very large files (>100MB), consider:
1. Showing a loading indicator
2. Implementing chunked uploads
3. Using background upload tasks (see Phase 3, subtask 3.4)

## Next Steps

After picking media:

1. **Upload to Supabase Storage** (Phase 3, subtask 3.4)
   - Use background upload service
   - Track upload progress
   - Handle retries

2. **Create MediaItem entities**
   - Convert PickedMediaFile to MediaItem
   - Extract EXIF data (Phase 4, subtask 4.3)
   - Generate thumbnails

3. **Display in UI**
   - Use MediaGallery (Phase 6, subtask 6.1)
   - Show upload progress (Phase 3, subtask 3.5)
   - Allow media management

## Related Components

- `MediaCompression`: Image compression utility
- `VideoCompression`: Video compression utility
- `MediaItem`: Entity for journal media
- `UploadProgressIndicator`: Upload progress display (Phase 3, subtask 3.5)
- `MediaGallery`: Grid view of media (Phase 6, subtask 6.1)

## Best Practices

1. **Always handle errors**: Check for errors in onMediaPicked callback
2. **Validate file sizes**: Set appropriate maxFileSize limits
3. **Use compression**: Enable compression for better performance
4. **Show feedback**: Display selected media to users
5. **Test on devices**: Test on real devices, not just simulators
6. **Handle permissions**: Request permissions before showing picker
7. **Clean up resources**: Delete temp files after upload
8. **Consider offline**: Handle offline scenarios (Phase 7)

## Contributing

When extending this widget:
1. Follow existing code patterns
2. Add comprehensive documentation
3. Include examples
4. Test on multiple platforms
5. Handle edge cases
6. Update this README

## License

Part of the SoloAdventurer project.
