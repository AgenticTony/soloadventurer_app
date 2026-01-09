# ImageCompressionService

Service for compressing images before upload or caching to reduce storage and bandwidth usage.

## Overview

`ImageCompressionService` provides utilities for compressing images to reduce file sizes while maintaining acceptable quality. This is particularly useful for:

- Compressing photos before uploading to server
- Reducing storage requirements
- Faster uploads and downloads
- Better app performance (less I/O)

## Features

- **JPEG Compression**: Configurable quality (10-100)
- **Image Resizing**: Automatic resizing if dimensions exceed limits
- **Format Conversion**: PNG to JPEG, WebP support
- **Batch Processing**: Compress multiple images efficiently
- **Use Case Presets**: Optimized settings for common scenarios
- **Compression Statistics**: Track savings percentages

## Performance Benefits

- **File Size Reduction**: 70-90% (1 MB → 100-300 KB)
- **Network Savings**: Faster uploads (less data to transfer)
- **Storage Efficiency**: Reduced local storage usage
- **Better Performance**: Less I/O and CPU usage

## Usage

### Basic Compression

Compress an image file:

```dart
import 'package:soloadventurer/core/services/services.dart';

final result = await ImageCompressionService.compressFile(
  file: File('/path/to/image.jpg'),
  quality: 85,
  maxWidth: 1920,
);

if (result.success) {
  debugPrint('Compressed to: ${result.compressedFile.path}');
  debugPrint('Saved ${result.savingsPercentage}%');
  // Upload result.compressedFile to server
}
```

### Compress from Bytes

Compress image bytes (e.g., from image picker):

```dart
final bytes = await imagePicker.getImageBytes();

final result = await ImageCompressionService.compressBytes(
  bytes: bytes,
  quality: 85,
  maxWidth: 1920,
  maxHeight: 1920,
);

// Write compressed bytes to file
final compressedFile = File('/path/to/output.jpg')
  ..writeAsBytesSync(result.compressedBytes);

// Or upload directly
await uploadToServer(result.compressedBytes);
```

### Batch Compression

Compress multiple images at once:

```dart
final imageFiles = [
  File('/path/to/image1.jpg'),
  File('/path/to/image2.jpg'),
  File('/path/to/image3.jpg'),
];

final results = await ImageCompressionService.compressBatch(
  files: imageFiles,
  quality: 85,
  maxWidth: 1920,
);

// Calculate total savings
final totalOriginal = results.fold<int>(
  0,
  (sum, r) => sum + r.originalSize,
);
final totalCompressed = results.fold<int>(
  0,
  (sum, r) => sum + r.compressedSize,
);
final totalSavings = totalOriginal - totalCompressed;

debugPrint('Total savings: ${totalSavings / 1024 / 1024} MB');
```

### Use Case Presets

Use optimized settings for specific scenarios:

```dart
// Profile photo (85% quality, 800x800 max)
final quality = ImageCompressionService.getQualityForUseCase(
  ImageUseCase.profilePhoto,
); // Returns 85

final dimensions = ImageCompressionService.getDimensionsForUseCase(
  ImageUseCase.profilePhoto,
); // Returns (800, 800)

final result = await ImageCompressionService.compressFile(
  file: photoFile,
  quality: quality,
  maxWidth: dimensions.width,
  maxHeight: dimensions.height,
);
```

### Format Conversion

Convert PNG to JPEG for better compression:

```dart
final result = await ImageCompressionService.compressFile(
  file: File('/path/to/image.png'),
  quality: 85,
  targetFormat: ImageFormat.jpeg, // Convert to JPEG
);

// Use WebP for even better compression
final webpResult = await ImageCompressionService.compressFile(
  file: File('/path/to/image.jpg'),
  quality: 85,
  targetFormat: ImageFormat.webp,
);
```

## API Reference

### compressFile

Compress an image file.

```dart
static Future<CompressionResult> compressFile(
  File file, {
  int quality = 85,
  int? maxWidth,
  int? maxHeight,
  ImageFormat targetFormat = ImageFormat.jpeg,
  String? outputPath,
})
```

**Parameters:**
- `file`: The image file to compress
- `quality`: JPEG compression quality (10-100, default: 85)
- `maxWidth`: Maximum width in pixels (default: 1920)
- `maxHeight`: Maximum height in pixels (default: 1920)
- `targetFormat`: Target format (JPEG, PNG, WebP)
- `outputPath`: Optional custom output path

**Returns:** `CompressionResult` with compressed file and statistics

### compressBytes

Compress image bytes directly.

```dart
static Future<ImageCompressionData> compressBytes(
  Uint8List bytes, {
  int quality = 85,
  int? maxWidth,
  int? maxHeight,
  ImageFormat targetFormat = ImageFormat.jpeg,
})
```

**Returns:** `ImageCompressionData` with compressed bytes and dimensions

### compressBatch

Compress multiple images efficiently.

```dart
static Future<List<CompressionResult>> compressBatch(
  List<File> files, {
  int quality = 85,
  int? maxWidth,
  int? maxHeight,
})
```

**Returns:** List of `CompressionResult` objects

### getQualityForUseCase

Get recommended quality for a use case.

```dart
static int getQualityForUseCase(ImageUseCase useCase)
```

**Use Cases:**
- `ImageUseCase.highQuality`: 95% (archival, professional photos)
- `ImageUseCase.profilePhoto`: 85% (profile photos, avatars)
- `ImageUseCase.photoGallery`: 85% (photo galleries, albums)
- `ImageUseCase.sharedPhoto`: 80% (shared photos, messages)
- `ImageUseCase.thumbnail`: 75% (thumbnails, list items)
- `ImageUseCase.avatar`: 70% (small avatars, icons)

### getDimensionsForUseCase

Get recommended dimensions for a use case.

```dart
static ImageDimensions getDimensionsForUseCase(ImageUseCase useCase)
```

**Returns:**
- `highQuality`: 2048x2048
- `profilePhoto`: 800x800
- `photoGallery`: 1920x1920
- `sharedPhoto`: 1200x1200
- `thumbnail`: 200x200
- `avatar`: 150x150

## Result Models

### CompressionResult

```dart
class CompressionResult {
  final File originalFile;        // Original file
  final File compressedFile;      // Compressed file
  final int originalSize;         // Original size in bytes
  final int compressedSize;       // Compressed size in bytes
  final int originalWidth;        // Original width
  final int originalHeight;       // Original height
  final int compressedWidth;      // Compressed width
  final int compressedHeight;     // Compressed height
  final int quality;              // Quality used
  final ImageFormat format;       // Output format
  final bool success;             // Success status

  int get savings;                // Bytes saved
  double get savingsPercentage;   // Savings percentage (0-100)
}
```

### ImageCompressionData

```dart
class ImageCompressionData {
  final Uint8List compressedBytes;  // Compressed bytes
  final int originalWidth;          // Original width
  final int originalHeight;         // Original height
  final int compressedWidth;        // Compressed width
  final int compressedHeight;       // Compressed height
}
```

## Quality Guidelines

### Recommended Quality Levels

| Use Case | Quality | Max Dimensions | Description |
|----------|---------|----------------|-------------|
| High Quality | 95% | 2048x2048 | Professional photos, archival |
| Profile Photo | 85% | 800x800 | Profile photos, avatars |
| Photo Gallery | 85% | 1920x1920 | Photo galleries, albums |
| Shared Photo | 80% | 1200x1200 | Shared photos, messages |
| Thumbnail | 75% | 200x200 | Thumbnails, list items |
| Avatar | 70% | 150x150 | Small avatars, icons |

### Quality vs File Size

- **90-100%**: Minimal compression, largest files
- **80-90%**: Good quality, reasonable compression (recommended)
- **70-80%**: Acceptable quality, good compression
- **60-70%**: Lower quality, high compression (thumbnails)
- **< 60%**: Poor quality, avoid for photos

## Format Comparison

### JPEG
- **Best for**: Photos, complex images
- **Compression**: Lossy
- **Quality**: 10-100
- **File Size**: Small to medium
- **Browser Support**: Universal

### PNG
- **Best for**: Graphics, logos, transparency
- **Compression**: Lossless
- **Quality**: No quality parameter
- **File Size**: Large
- **Browser Support**: Universal

### WebP
- **Best for**: Modern web, mixed content
- **Compression**: Lossy or lossless
- **Quality**: 0-100
- **File Size**: Smallest
- **Browser Support**: Modern browsers

## Integration Examples

### Image Picker Integration

```dart
final ImagePicker picker = ImagePicker();

// Pick image
final XFile? image = await picker.pickImage(source: ImageSource.gallery);
if (image == null) return;

// Read bytes
final bytes = await image.readAsBytes();

// Compress with profile photo settings
final result = await ImageCompressionService.compressBytes(
  bytes: bytes,
  quality: ImageCompressionService.getQualityForUseCase(
    ImageUseCase.profilePhoto,
  ),
  maxWidth: 800,
  maxHeight: 800,
);

// Upload compressed bytes
await uploadProfilePhoto(result.compressedBytes);
```

### Camera Integration

```dart
final ImagePicker picker = ImagePicker();

// Take photo
final XFile? photo = await picker.pickImage(source: ImageSource.camera);
if (photo == null) return;

// Compress camera photo
final result = await ImageCompressionService.compressFile(
  file: File(photo.path),
  quality: 85,
  maxWidth: 1920,
  maxHeight: 1920,
);

// Upload or save
await savePhoto(result.compressedFile);
```

### Gallery Upload

```dart
// Select multiple photos
final List<XFile> images = await picker.pickMultiImage();

// Convert to File list
final files = images.map((xfile) => File(xfile.path)).toList();

// Compress batch
final results = await ImageCompressionService.compressBatch(
  files: files,
  quality: 85,
  maxWidth: 1920,
);

// Upload all compressed photos
for (final result in results) {
  await uploadPhoto(result.compressedFile);
}
```

## Performance Considerations

### Memory Usage
- Batch processing is limited to 5 images at a time to avoid memory issues
- Large images (> 10 MB) are decoded and compressed efficiently
- Memory usage scales with image dimensions, not file size

### CPU Usage
- Compression is CPU-intensive
- Consider doing compression in background isolate for UI responsiveness
- Use quality < 90% for faster compression

### Best Practices

1. **Compress before upload**: Always compress images before uploading
2. **Use appropriate quality**: 85% is good for most photos
3. **Resize large images**: Set maxWidth/maxHeight to prevent huge files
4. **Batch smartly**: Use batch compression for multiple images
5. **Handle errors**: Always wrap in try-catch for production
6. **Clean up**: Delete temporary compressed files after upload

## Error Handling

```dart
try {
  final result = await ImageCompressionService.compressFile(
    file: imageFile,
    quality: 85,
  );

  if (result.success) {
    await uploadToServer(result.compressedFile);
  }
} on CompressionException catch (e) {
  debugPrint('Compression failed: ${e.message}');
  // Show error to user
} catch (e) {
  debugPrint('Unexpected error: $e');
  // Handle other errors
}
```

## Troubleshooting

### Compression not working
- Check if image file exists
- Verify quality is between 10-100
- Ensure image format is supported (JPEG, PNG, WebP)

### Compressed image too large
- Reduce quality (try 70-80)
- Reduce maxWidth/maxHeight
- Try WebP format for better compression

### Out of memory errors
- Reduce batch size
- Process images one at a time
- Use smaller dimensions

### Poor image quality
- Increase quality (85-95)
- Use higher maxWidth/maxHeight
- Avoid JPEG for graphics (use PNG)

## Testing

```dart
test('compress image reduces file size', () async {
  final file = File('test/assets/test_image.jpg');
  final originalSize = await file.length();

  final result = await ImageCompressionService.compressFile(
    file: file,
    quality: 85,
  );

  expect(result.success, true);
  expect(result.compressedSize, lessThan(originalSize));
  expect(result.savingsPercentage, greaterThan(0));
});
```

## See Also

- [ThumbnailService](./thumbnail_service.dart) - Generate thumbnails for photos
- [ImageCacheConfig](../config/image_cache_config.dart) - Configure image caching
- [LazyLoadImage](../widgets/lazy_load_image.dart) - Lazy load images in UI
