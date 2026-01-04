# Video Compression Utility

## Overview

The `VideoCompression` utility provides video compression functionality to reduce file sizes while maintaining acceptable quality for travel journal videos. It supports common video formats (MP4, MOV, AVI, MKV, WebM) with configurable quality, resolution, and audio settings.

## Features

- ✅ **Automatic compression** with smart defaults for travel videos
- ✅ **Configurable quality** (0-100) to balance file size and video quality
- ✅ **Video resizing** with aspect ratio preservation
- ✅ **Multiple format support** (MP4, MOV, AVI, MKV, WebM)
- ✅ **Frame rate control** to reduce file size
- ✅ **Audio compression** with configurable bitrate
- ✅ **Progress tracking** with real-time status updates
- ✅ **Comprehensive error handling** with custom exceptions
- ✅ **Metadata extraction** (dimensions, duration, file size reduction)

## Installation

The utility requires a video compression package. The recommended package is `video_compress: ^3.1.1` or `ffmpeg_kit_flutter: ^6.0.3`.

Add to `pubspec.yaml`:

```yaml
dependencies:
  video_compress: ^3.1.1
  # OR
  ffmpeg_kit_flutter: ^6.0.3
```

Then run:

```bash
flutter pub get
```

> **Note**: The current implementation includes placeholder methods. To enable actual compression, integrate one of the packages above and update the `_performCompression` and `_getVideoMetadata` methods.

## Basic Usage

### 1. Simple Compression

```dart
import 'package:soloadventurer/utils/video_compression.dart';
import 'dart:io';

final compressor = VideoCompression();

// Compress a video file
final file = File('/path/to/video.mp4');
final result = await compressor.compressVideo(file);

print('Original: ${result.originalSize} bytes');
print('Compressed: ${result.compressedSize} bytes');
print('Reduction: ${result.sizeReductionPercent}%');
print('Dimensions: ${result.width}x${result.height}');
print('Duration: ${result.duration}s');

// Don't forget to clean up the compressed file when done
await compressor.cleanup(result.file);
```

### 2. Custom Configuration

```dart
// Create custom compression config
final config = VideoCompressionConfig(
  maxWidth: 1280,
  maxHeight: 720,
  quality: 80,
  frameRate: 30,
  maintainAspect: true,
  includeAudio: true,
  audioBitrate: 128,
);

final result = await compressor.compressVideo(file, config: config);
```

### 3. Predefined Configurations

```dart
// Optimized for travel videos (recommended - 720p)
final result = await compressor.compressVideo(
  file,
  config: VideoCompressionConfig.optimizedForTravel,
);

// High quality (1080p, minimal compression)
final result = await compressor.compressVideo(
  file,
  config: VideoCompressionConfig.highQuality,
);

// Aggressive compression (480p, for slow networks)
final result = await compressor.compressVideo(
  file,
  config: VideoCompressionConfig.aggressive,
);
```

### 4. Compression with Progress Tracking

```dart
final result = await compressor.compressVideo(
  file,
  config: VideoCompressionConfig.optimizedForTravel,
  onProgress: (progress) {
    final percentage = (progress.progress * 100).toInt();
    print('Progress: $percentage% - ${progress.status}');

    // Update UI progress bar
    // progressBarController.value = progress.progress;
  },
);
```

### 5. Check if Compression Needed

```dart
// Check if a video needs compression (default threshold: 50MB)
if (VideoCompression.needsCompression(file)) {
  final result = await compressor.compressVideo(file);
  // Use compressed video
}

// Custom threshold (e.g., 20MB)
if (VideoCompression.needsCompression(file, threshold: 20 * 1024 * 1024)) {
  final result = await compressor.compressVideo(file);
}
```

### 6. Get Recommended Settings

```dart
// Get recommended config based on video properties
final metadata = await compressor._getVideoMetadata(file);
final config = VideoCompression.getRecommendedConfig(
  fileSize: fileSize,
  width: metadata['width'],
  height: metadata['height'],
  duration: metadata['duration'],
  slowNetwork: false, // Set to true for slow connections
);

final result = await compressor.compressVideo(file, config: config);
```

## Configuration Options

### VideoCompressionConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `maxWidth` | int? | null | Maximum width in pixels (null = no limit) |
| `maxHeight` | int? | null | Maximum height in pixels (null = no limit) |
| `quality` | int | 80 | Video quality (0-100, higher = better) |
| `frameRate` | int? | null | Target frame rate (null = keep original) |
| `maintainAspect` | bool | true | Maintain aspect ratio when resizing |
| `includeAudio` | bool | true | Whether to include audio track |
| `audioBitrate` | int? | null | Audio bitrate in kbps (null = default) |

### Predefined Configurations

#### optimizedForTravel
```dart
maxWidth: 1280,
maxHeight: 720,
quality: 80,
frameRate: 30,
audioBitrate: 128,
```
Best for most travel videos. 720p resolution with balanced quality.

#### highQuality
```dart
maxWidth: 1920,
maxHeight: 1080,
quality: 90,
frameRate: 60,
audioBitrate: 192,
```
1080p resolution with minimal compression. Best for important moments.

#### aggressive
```dart
maxWidth: 854,
maxHeight: 480,
quality: 70,
frameRate: 24,
audioBitrate: 96,
```
480p resolution with maximum compression. Best for slow connections.

## CompressedVideoResult

The result object contains:

- **file** (`File`): Compressed video file ready for upload
- **originalSize** (`int`): Original file size in bytes
- **compressedSize** (`int`): Compressed file size in bytes
- **width** (`int`): Video width in pixels
- **height** (`int`): Video height in pixels
- **duration** (`double`): Video duration in seconds
- **format** (`String`): Video format ('mp4', 'mov', etc.)
- **quality** (`int`): Quality used for compression

### Helper Properties

```dart
// Compression ratio (e.g., 3.5 means compressed to 1/3.5th)
result.compressionRatio;

// Size reduction percentage (e.g., 72 means 72% smaller)
result.sizeReductionPercent;

// Whether compression was effective (at least 10% reduction)
result.isEffective;
```

## Error Handling

The utility throws specific exceptions for different error scenarios:

### MediaCompressionException
Thrown when compression fails for technical reasons.

```dart
try {
  final result = await compressor.compressVideo(file);
} on MediaCompressionException catch (e) {
  // Handle compression failure
  print('Compression failed: ${e.message}');
}
```

### InvalidVideoException
Thrown when the file is invalid, corrupted, too large, or too short.

```dart
try {
  final result = await compressor.compressVideo(file);
} on InvalidVideoException catch (e) {
  // Handle invalid video
  print('Invalid video: ${e.message}');
}
```

### UnsupportedVideoFormatException
Thrown when the video format is not supported.

```dart
try {
  final result = await compressor.compressVideo(file);
} on UnsupportedVideoFormatException catch (e) {
  // Handle unsupported format
  print('Unsupported format: ${e.message}');
}
```

## Integration with Journal Entries

### Example: Upload Compressed Video to Journal Entry

```dart
import 'package:image_picker/image_picker.dart';
import 'package:soloadventurer/utils/video_compression.dart';
import 'package:soloadventurer/features/journal/data/repositories/journal_repository_impl.dart';

Future<void> addVideoToJournalEntry(
  String entryId,
  File videoFile,
  JournalRepository repository,
) async {
  final compressor = VideoCompression();

  try {
    // Compress the video
    final result = await compressor.compressVideo(
      videoFile,
      config: VideoCompressionConfig.optimizedForTravel,
      onProgress: (progress) {
        print('Compressing: ${(progress.progress * 100).toInt()}%');
      },
    );

    // Read compressed video bytes
    final bytes = await result.file.readAsBytes();

    // Upload compressed video
    await repository.addMedia(
      entryId,
      bytes,
      mimeType: 'video/mp4',
      width: result.width,
      height: result.height,
      fileSize: result.compressedSize,
      duration: result.duration,
    );

    print('Video uploaded successfully!');
    print('Size reduced by ${result.sizeReductionPercent}%');

    // Clean up temporary compressed file
    await compressor.cleanup(result.file);
  } on MediaCompressionException catch (e) {
    // Handle compression error
    print('Failed to compress video: $e');
  } catch (e) {
    // Handle other errors
    print('Failed to upload video: $e');
  }
}
```

### Example: Multiple Video Upload

```dart
Future<void> uploadMultipleVideos(
  String entryId,
  List<File> videos,
  JournalRepository repository,
) async {
  final compressor = VideoCompression();
  int successCount = 0;
  int failureCount = 0;

  for (final video in videos) {
    try {
      final result = await compressor.compressVideo(video);
      final bytes = await result.file.readAsBytes();

      await repository.addMedia(
        entryId,
        bytes,
        mimeType: 'video/mp4',
        width: result.width,
        height: result.height,
        fileSize: result.compressedSize,
        duration: result.duration,
      );

      successCount++;

      // Clean up
      await compressor.cleanup(result.file);
    } catch (e) {
      failureCount++;
      print('Failed to process video: $e');
    }
  }

  print('Uploaded $successCount videos, $failureCount failed');
}
```

### Example: Upload with Progress UI

```dart
class VideoUploadWidget extends StatefulWidget {
  final File videoFile;
  final String entryId;

  @override
  _VideoUploadWidgetState createState() => _VideoUploadWidgetState();
}

class _VideoUploadWidgetState extends State<VideoUploadWidget> {
  double _uploadProgress = 0.0;
  String _uploadStatus = 'Preparing...';

  Future<void> _uploadVideo() async {
    final compressor = VideoCompression();

    try {
      final result = await compressor.compressVideo(
        widget.videoFile,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress.progress * 0.7; // 70% for compression
            _uploadStatus = progress.status;
          });
        },
      );

      setState(() {
        _uploadStatus = 'Uploading...';
      });

      // Upload compressed video (simulated)
      // await repository.addMedia(...);

      setState(() {
        _uploadProgress = 1.0;
        _uploadStatus = 'Complete!';
      });

      await compressor.cleanup(result.file);
    } catch (e) {
      setState(() {
        _uploadStatus = 'Failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(value: _uploadProgress),
        Text(_uploadStatus),
        ElevatedButton(
          onPressed: _uploadVideo,
          child: Text('Upload Video'),
        ),
      ],
    );
  }
}
```

## Best Practices

### 1. Choose the Right Configuration

```dart
// For travel videos with good internet
config: VideoCompressionConfig.optimizedForTravel  // 720p

// For slow connections
config: VideoCompressionConfig.aggressive  // 480p

// For important videos where quality matters
config: VideoCompressionConfig.highQuality  // 1080p
```

### 2. Check Before Compressing

```dart
// Avoid unnecessary compression
if (VideoCompression.needsCompression(file)) {
  final result = await compressor.compressVideo(file);
  return result.file;
} else {
  return file;
}
```

### 3. Always Clean Up

```dart
try {
  final result = await compressor.compressVideo(file);
  // Use the compressed video
} finally {
  // Always clean up temporary files
  await compressor.cleanup(result.file);
}
```

### 4. Show Progress to Users

```dart
await compressor.compressVideo(
  file,
  onProgress: (progress) {
    // Update UI
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Compressing Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: progress.progress),
            SizedBox(height: 16),
            Text(progress.status),
            SizedBox(height: 8),
            Text('${(progress.progress * 100).toInt()}%'),
          ],
        ),
      ),
    );
  },
);
```

### 5. Handle Different Video Types

```dart
// Get video properties first
final metadata = await compressor._getVideoMetadata(file);

// Choose config based on video properties
final config = VideoCompression.getRecommendedConfig(
  fileSize: file.lengthSync(),
  width: metadata['width'],
  height: metadata['height'],
  duration: metadata['duration'],
  slowNetwork: isSlowNetwork(),
);

final result = await compressor.compressVideo(file, config: config);
```

## Performance Considerations

- **Compression time**: Varies based on video length and resolution. Typically 5-30 seconds per minute of video.
- **CPU usage**: High during compression. Consider using Isolates (not yet implemented).
- **Memory usage**: Can be significant for large videos. Monitor memory on low-end devices.
- **Battery impact**: Compression is CPU-intensive and can drain battery quickly.
- **Recommendation**: Show progress indicators and allow cancellation.

## Platform Support

- ✅ Android (Excellent)
- ✅ iOS (Excellent)
- ✅ macOS (Good, with limitations)
- ⚠️ Windows (Limited, requires FFmpeg setup)
- ⚠️ Linux (Limited, requires FFmpeg setup)

## Limitations

1. **File size**: Maximum 500MB per video
2. **Duration**: Minimum 1 second required
3. **Formats**: Limited to common formats (MP4, MOV, AVI, MKV, WebM)
4. **Compression ratio**: Cannot guarantee specific file sizes (unlike images)
5. **Processing time**: Longer than image compression
6. **Hardware acceleration**: Not yet implemented

## Troubleshooting

### Issue: Compression fails with "metadata read failed"

**Cause**: Video file is corrupted or format is not truly supported

**Solution**:
```dart
try {
  final result = await compressor.compressVideo(file);
} on MediaCompressionException catch (e) {
  if (e.code == 'metadata_read_failed') {
    // Show error to user
    showError('Unable to read video file. Please try a different video.');
  }
}
```

### Issue: Compressed size is larger than original

**Cause**: Video already compressed or very low quality

**Solution**:
```dart
if (result.compressedSize > result.originalSize) {
  // Use original video
  await compressor.cleanup(result.file);
  return file;
}
```

### Issue: Out of memory on large videos

**Cause**: Video too large for available memory

**Solution**:
```dart
// Use aggressive settings for large videos
final config = VideoCompressionConfig(
  maxWidth: 640,
  maxHeight: 480,
  quality: 70,
  frameRate: 24,
);
```

### Issue: Compression is too slow

**Cause**: High resolution or long video

**Solution**:
```dart
// Reduce resolution and frame rate
final config = VideoCompressionConfig(
  maxWidth: 854,
  maxHeight: 480,
  quality: 75,
  frameRate: 24,
);
```

## Future Enhancements

- [ ] **Hardware acceleration** using platform APIs (VideoToolbox on iOS, MediaCodec on Android)
- [ ] **Background compression** using Isolates to avoid blocking UI
- [ ] **H.265/HEVC encoding** for better compression ratios
- [ ] **Thumbnail generation** for video previews
- [ ] **Trim and cut** functionality to remove unwanted sections
- [ ] **Batch processing** for multiple videos
- [ ] **Automatic quality adjustment** based on network speed
- [ ] **Preserve original metadata** (location, date, etc.)
- [ ] **Progressive streaming** support

## Testing

```dart
// Test with sample videos
void main() async {
  final compressor = VideoCompression();
  final testVideo = File('test/videos/sample.mp4');

  final result = await compressor.compressVideo(
    testVideo,
    config: VideoCompressionConfig.optimizedForTravel,
  );

  assert(await result.file.exists());
  assert(result.compressedSize < result.originalSize);
  assert(result.sizeReductionPercent > 0);
  assert(result.duration > 0);

  print('Test passed: ${result.sizeReductionPercent}% reduction');

  // Clean up
  await compressor.cleanup(result.file);
}
```

## Integration Checklist

To fully integrate video compression into your app:

- [ ] Add `video_compress` or `ffmpeg_kit_flutter` to `pubspec.yaml`
- [ ] Update `_getVideoMetadata()` to extract real metadata
- [ ] Update `_performCompression()` to perform real compression
- [ ] Add progress UI components
- [ ] Test on Android and iOS
- [ ] Verify compressed video quality
- [ ] Handle edge cases (corrupted files, unsupported formats)
- [ ] Add error reporting/analytics
- [ ] Document acceptable video formats for users
- [ ] Add file size/length limits in UI

## See Also

- [Video Compress package](https://pub.dev/packages/video_compress)
- [FFmpeg Kit Flutter package](https://pub.dev/packages/ffmpeg_kit_flutter)
- [Image picker documentation](https://pub.dev/packages/image_picker)
- [Journal repository implementation](../features/journal/data/repositories/journal_repository_impl.dart)
- [Image compression utility](./media_compression.dart)
