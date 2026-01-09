# Media Compression Utility

## Overview

The `MediaCompression` utility provides image compression functionality to reduce file sizes while maintaining acceptable quality for travel journal photos. It supports JPEG and PNG formats with configurable quality and resizing options.

## Features

- ✅ **Automatic compression** with smart defaults for travel photos
- ✅ **Configurable quality** (0-100) to balance file size and image quality
- ✅ **Image resizing** with aspect ratio preservation
- ✅ **Multiple format support** (JPEG, PNG)
- ✅ **EXIF data handling** with automatic rotation correction
- ✅ **Target file size** support with automatic quality adjustment
- ✅ **Comprehensive error handling** with custom exceptions
- ✅ **Metadata extraction** (dimensions, file size, compression ratio)

## Installation

The utility requires `flutter_image_compress: ^2.3.0` which is already added to `pubspec.yaml`.

```bash
flutter pub get
```

## Basic Usage

### 1. Simple Compression

```dart
import 'package:soloadventurer/utils/media_compression.dart';
import 'dart:io';

final compressor = MediaCompression();

// Compress a file
final file = File('/path/to/image.jpg');
final result = await compressor.compressImage(file);

print('Original: ${result.originalSize} bytes');
print('Compressed: ${result.compressedSize} bytes');
print('Reduction: ${result.sizeReductionPercent}%');
print('Dimensions: ${result.width}x${result.height}');
```

### 2. Custom Configuration

```dart
// Create custom compression config
final config = ImageCompressionConfig(
  maxWidth: 1920,
  maxHeight: 1920,
  quality: 85,
  maintainAspect: true,
  autoCorrectionAngle: true,
);

final result = await compressor.compressImage(file, config: config);
```

### 3. Predefined Configurations

```dart
// Optimized for travel photos (recommended)
final result = await compressor.compressImage(
  file,
  config: ImageCompressionConfig.optimizedForTravel,
);

// High quality (minimal compression)
final result = await compressor.compressImage(
  file,
  config: ImageCompressionConfig.highQuality,
);

// Aggressive compression (for slow networks)
final result = await compressor.compressImage(
  file,
  config: ImageCompressionConfig.aggressive,
);
```

### 4. Compress from Bytes

```dart
// If you have image bytes instead of a file
final imageBytes = Uint8List.fromList([...]);

final result = await compressor.compressBytes(
  imageBytes,
  'jpg', // format
  originalSize: imageBytes.length,
);
```

### 5. Check if Compression Needed

```dart
// Check if an image needs compression (default threshold: 1MB)
if (MediaCompression.needsCompression(file)) {
  final result = await compressor.compressImage(file);
  // Use compressed image
}

// Custom threshold (e.g., 500KB)
if (MediaCompression.needsCompression(file, threshold: 500 * 1024)) {
  final result = await compressor.compressImage(file);
}
```

### 6. Get Recommended Settings

```dart
// Get recommended config based on image properties
final config = MediaCompression.getRecommendedConfig(
  fileSize: imageFileSize,
  width: imageWidth,
  height: imageHeight,
  slowNetwork: false, // Set to true for slow connections
);

final result = await compressor.compressImage(file, config: config);
```

## Configuration Options

### ImageCompressionConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `maxWidth` | int? | null | Maximum width in pixels (null = no limit) |
| `maxHeight` | int? | null | Maximum height in pixels (null = no limit) |
| `quality` | int | 85 | JPEG quality (0-100, higher = better quality) |
| `targetSize` | int? | null | Target file size in bytes (null = no target) |
| `maintainAspect` | bool | true | Maintain aspect ratio when resizing |
| `autoCorrectionAngle` | bool | true | Rotate image according to EXIF data |

### Predefined Configurations

#### optimizedForTravel
```dart
maxWidth: 1920,
maxHeight: 1920,
quality: 85,
```
Best for most travel photos. Balances quality and file size.

#### highQuality
```dart
maxWidth: 2560,
maxHeight: 2560,
quality: 95,
```
Minimal compression for high-quality images.

#### aggressive
```dart
maxWidth: 1280,
maxHeight: 1280,
quality: 70,
```
Maximum compression for slow networks or storage constraints.

## CompressedImageResult

The result object contains:

- **bytes** (`Uint8List`): Compressed image data ready for upload
- **originalSize** (`int`): Original file size in bytes
- **compressedSize** (`int`): Compressed file size in bytes
- **width** (`int`): Image width in pixels
- **height** (`int`): Image height in pixels
- **format** (`String`): Compression format ('jpeg' or 'png')
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
  final result = await compressor.compressImage(file);
} on MediaCompressionException catch (e) {
  // Handle compression failure
  print('Compression failed: ${e.message}');
}
```

### InvalidImageException
Thrown when the file is invalid, corrupted, or too large.

```dart
try {
  final result = await compressor.compressImage(file);
} on InvalidImageException catch (e) {
  // Handle invalid image
  print('Invalid image: ${e.message}');
}
```

### UnsupportedImageFormatException
Thrown when the image format is not supported.

```dart
try {
  final result = await compressor.compressImage(file);
} on UnsupportedImageFormatException catch (e) {
  // Handle unsupported format
  print('Unsupported format: ${e.message}');
}
```

## Integration with Journal Entries

### Example: Upload Compressed Image to Journal Entry

```dart
import 'package:image_picker/image_picker.dart';
import 'package:soloadventurer/utils/media_compression.dart';
import 'package:soloadventurer/features/journal/data/repositories/journal_repository_impl.dart';

Future<void> addMediaToJournalEntry(
  String entryId,
  File imageFile,
  JournalRepository repository,
) async {
  final compressor = MediaCompression();

  try {
    // Compress the image
    final result = await compressor.compressImage(
      imageFile,
      config: ImageCompressionConfig.optimizedForTravel,
    );

    // Upload compressed bytes
    await repository.addMedia(
      entryId,
      result.bytes,
      mimeType: 'image/jpeg',
      width: result.width,
      height: result.height,
      fileSize: result.compressedSize,
    );

    print('Image uploaded successfully!');
    print('Size reduced by ${result.sizeReductionPercent}%');
  } on MediaCompressionException catch (e) {
    // Handle compression error
    print('Failed to compress image: $e');
  } catch (e) {
    // Handle other errors
    print('Failed to upload image: $e');
  }
}
```

### Example: Multiple Image Upload

```dart
Future<void> uploadMultipleImages(
  String entryId,
  List<File> images,
  JournalRepository repository,
) async {
  final compressor = MediaCompression();
  int successCount = 0;
  int failureCount = 0;

  for (final image in images) {
    try {
      final result = await compressor.compressImage(image);

      await repository.addMedia(
        entryId,
        result.bytes,
        mimeType: 'image/jpeg',
        width: result.width,
        height: result.height,
        fileSize: result.compressedSize,
      );

      successCount++;
    } catch (e) {
      failureCount++;
      print('Failed to process image: $e');
    }
  }

  print('Uploaded $successCount images, $failureCount failed');
}
```

## Best Practices

### 1. Choose the Right Configuration

```dart
// For travel photos with good internet
config: ImageCompressionConfig.optimizedForTravel

// For slow connections
config: ImageCompressionConfig.aggressive

// For important photos where quality matters
config: ImageCompressionConfig.highQuality
```

### 2. Check Before Compressing

```dart
// Avoid unnecessary compression
if (MediaCompression.needsCompression(file)) {
  final result = await compressor.compressImage(file);
  return result.bytes;
} else {
  return await file.readAsBytes();
}
```

### 3. Handle Errors Gracefully

```dart
try {
  final result = await compressor.compressImage(file);
  // Use compressed image
} on MediaCompressionException catch (e) {
  // Try with lower quality
  final fallbackConfig = config.copyWith(quality: 70);
  final result = await compressor.compressImage(file, config: fallbackConfig);
}
```

### 4. Show Progress to Users

```dart
// Before compression
print('Compressing image...');

final result = await compressor.compressImage(file);

// After compression
print('✓ Compressed: ${result.originalSize} → ${result.compressedSize} '
      '(${result.sizeReductionPercent}% smaller)');
```

## Performance Considerations

- Compression is CPU-intensive and may take 1-3 seconds per image
- Use Isolate for compression to avoid blocking UI (not yet implemented)
- Consider caching compressed results for repeated uploads
- Batch uploads should be done in parallel (with rate limiting)

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ macOS (with limitations)
- ✅ Windows (with limitations)
- ✅ Linux (with limitations)

## Limitations

1. **Animated GIFs**: Not supported. Use first frame or specialized library
2. **HEIC format**: Requires conversion to JPEG before compression
3. **Very large images**: > 50MB may cause memory issues
4. **Dimension extraction**: Currently uses estimated dimensions

## Troubleshooting

### Issue: Compression returns null

**Cause**: Image format not supported or corrupted file

**Solution**:
```dart
try {
  final result = await compressor.compressImage(file);
} on UnsupportedImageFormatException {
  // Convert to supported format first
  // Or show error to user
}
```

### Issue: Compressed size is larger than original

**Cause**: Image already compressed or PNG with few colors

**Solution**:
```dart
if (result.compressedSize > result.originalSize) {
  // Use original image
  return await file.readAsBytes();
}
```

### Issue: Out of memory on large images

**Cause**: Image too large for available memory

**Solution**:
```dart
// Use aggressive settings
final config = ImageCompressionConfig(
  maxWidth: 1024,
  maxHeight: 1024,
  quality: 70,
);
```

## Future Enhancements

- [ ] WebP format support for better compression
- [ ] Progressive JPEG encoding
- [ ] Thumbnail generation
- [ ] Background compression using Isolate
- [ ] Compression presets for different use cases
- [ ] Automatic quality adjustment based on content
- [ ] Dimension extraction using image package

## Testing

```dart
// Test with sample images
void main() async {
  final compressor = MediaCompression();
  final testImage = File('test/images/sample.jpg');

  final result = await compressor.compressImage(
    testImage,
    config: ImageCompressionConfig.optimizedForTravel,
  );

  assert(result.bytes.isNotEmpty);
  assert(result.compressedSize < result.originalSize);
  assert(result.sizeReductionPercent > 0);

  print('Test passed: ${result.sizeReductionPercent}% reduction');
}
```

## See Also

- [flutter_image_compress package](https://pub.dev/packages/flutter_image_compress)
- [Image picker documentation](https://pub.dev/packages/image_picker)
- [Journal repository implementation](../features/journal/data/repositories/journal_repository_impl.dart)
