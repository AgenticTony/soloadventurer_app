import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/utils/media_compression.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

/// Example demonstrating how to use the MediaCompression utility
///
/// This file contains practical examples for compressing images
/// before uploading to the travel journal.
class MediaCompressionExample {
  final MediaCompression _compressor = const MediaCompression();

  /// Example 1: Basic compression with default settings
  Future<void> example1_BasicCompression() async {
    debugPrint('=== Example 1: Basic Compression ===');

    try {
      // Assume we picked an image using image_picker
      final imageFile = File('/path/to/image.jpg');

      // Compress with default settings (optimizedForTravel)
      final result = await _compressor.compressImage(imageFile);

      debugPrint('Original size: ${result.originalSize} bytes');
      debugPrint('Compressed size: ${result.compressedSize} bytes');
      debugPrint('Size reduction: ${result.sizeReductionPercent}%');
      debugPrint('Dimensions: ${result.width}x${result.height}');
      debugPrint('Format: ${result.format}');
      debugPrint('Compression ratio: ${result.compressionRatio.toStringAsFixed(2)}x');

      // Use compressed bytes for upload
      final compressedBytes = result.bytes;
      // ... upload to Supabase Storage
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  /// Example 2: Compression with custom configuration
  Future<void> example2_CustomConfiguration() async {
    debugPrint('\n=== Example 2: Custom Configuration ===');

    try {
      final imageFile = File('/path/to/large-photo.jpg');

      // Create custom configuration for large photos
      final config = ImageCompressionConfig(
        maxWidth: 2560, // Limit to 2560px width
        maxHeight: 2560, // Limit to 2560px height
        quality: 90, // Higher quality for important photos
        maintainAspect: true, // Keep aspect ratio
        autoCorrectionAngle: true, // Fix orientation from EXIF
      );

      final result = await _compressor.compressImage(
        imageFile,
        config: config,
      );

      debugPrint('Compressed with 90% quality');
      debugPrint('Result: ${result.compressedSize} bytes');
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  /// Example 3: Using predefined configurations
  Future<void> example3_PredefinedConfigurations() async {
    debugPrint('\n=== Example 3: Predefined Configurations ===');

    final imageFile = File('/path/to/image.jpg');

    // Option 1: Optimized for travel (recommended)
    final travelResult = await _compressor.compressImage(
      imageFile,
      config: ImageCompressionConfig.optimizedForTravel,
    );
    debugPrint('Travel optimized: ${travelResult.compressedSize} bytes');

    // Option 2: High quality (minimal compression)
    final qualityResult = await _compressor.compressImage(
      imageFile,
      config: ImageCompressionConfig.highQuality,
    );
    debugPrint('High quality: ${qualityResult.compressedSize} bytes');

    // Option 3: Aggressive (for slow networks)
    final aggressiveResult = await _compressor.compressImage(
      imageFile,
      config: ImageCompressionConfig.aggressive,
    );
    debugPrint('Aggressive: ${aggressiveResult.compressedSize} bytes');
  }

  /// Example 4: Conditional compression based on file size
  Future<Uint8List> example4_ConditionalCompression(File imageFile) async {
    debugPrint('\n=== Example 4: Conditional Compression ===');

    // Check if image needs compression (threshold: 1MB)
    if (MediaCompression.needsCompression(imageFile)) {
      debugPrint('Image needs compression');

      final result = await _compressor.compressImage(imageFile);
      debugPrint('Compressed to ${result.compressedSize} bytes');

      return result.bytes;
    } else {
      debugPrint('Image is small enough, using original');
      return await imageFile.readAsBytes();
    }
  }

  /// Example 5: Compressing from bytes
  Future<void> example5_CompressFromBytes() async {
    debugPrint('\n=== Example 5: Compress From Bytes ===');

    try {
      // Assume we have image bytes from memory or network
      final imageBytes = Uint8List.fromList([/* image data */]);

      // Compress the bytes
      final result = await _compressor.compressBytes(
        imageBytes,
        'jpg', // Specify format
        originalSize: imageBytes.length,
      );

      debugPrint('Original bytes: ${result.originalSize}');
      debugPrint('Compressed bytes: ${result.compressedSize}');
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  /// Example 6: Error handling with fallback
  Future<Uint8List?> example6_ErrorHandlingWithFallback(File imageFile) async {
    debugPrint('\n=== Example 6: Error Handling with Fallback ===');

    try {
      // Try with standard configuration
      final result = await _compressor.compressImage(imageFile);
      return result.bytes;
    } on InvalidImageException catch (e) {
      debugPrint('Invalid image: ${e.message}');
      return null;
    } on UnsupportedImageFormatException catch (e) {
      debugPrint('Unsupported format: ${e.message}');
      // Try converting to JPEG first
      return null;
    } on MediaCompressionException catch (e) {
      debugPrint('Compression failed: ${e.message}');
      // Try with lower quality
      try {
        final fallbackConfig = ImageCompressionConfig(
          quality: 70, // Lower quality
          maxWidth: 1280,
          maxHeight: 1280,
        );
        final result = await _compressor.compressImage(
          imageFile,
          config: fallbackConfig,
        );
        debugPrint('Fallback compression successful');
        return result.bytes;
      } catch (e) {
        debugPrint('Fallback also failed: $e');
        return null;
      }
    }
  }

  /// Example 7: Multiple image batch processing
  Future<void> example7_BatchProcessing(List<File> images) async {
    debugPrint('\n=== Example 7: Batch Processing ===');

    int successCount = 0;
    int failureCount = 0;
    int totalOriginalSize = 0;
    int totalCompressedSize = 0;

    for (final image in images) {
      try {
        final originalSize = await image.length();
        totalOriginalSize += originalSize;

        final result = await _compressor.compressImage(image);
        totalCompressedSize += result.compressedSize;

        successCount++;
        debugPrint('✓ Image ${successCount + failureCount}: '
            '${result.sizeReductionPercent}% reduction');
      } catch (e) {
        failureCount++;
        debugPrint('✗ Image ${successCount + failureCount} failed: $e');
      }
    }

    final totalReduction =
        ((totalOriginalSize - totalCompressedSize) / totalOriginalSize * 100)
            .round();

    debugPrint('\nBatch Summary:');
    debugPrint('Success: $successCount, Failed: $failureCount');
    debugPrint('Total original: $totalOriginalSize bytes');
    debugPrint('Total compressed: $totalCompressedSize bytes');
    debugPrint('Total reduction: $totalReduction%');
  }

  /// Example 8: Get recommended settings
  Future<void> example8_RecommendedSettings() async {
    debugPrint('\n=== Example 8: Recommended Settings ===');

    // Scenario 1: Large photo (12 MP) on good network
    final config1 = MediaCompression.getRecommendedConfig(
      fileSize: 5 * 1024 * 1024, // 5 MB
      width: 4000,
      height: 3000,
      slowNetwork: false,
    );
    debugPrint('Large photo, good network: $config1');

    // Scenario 2: Medium photo (8 MP) on slow network
    final config2 = MediaCompression.getRecommendedConfig(
      fileSize: 3 * 1024 * 1024, // 3 MB
      width: 3200,
      height: 2400,
      slowNetwork: true,
    );
    debugPrint('Medium photo, slow network: $config2');

    // Scenario 3: Small photo (2 MP)
    final config3 = MediaCompression.getRecommendedConfig(
      fileSize: 500 * 1024, // 500 KB
      width: 1600,
      height: 1200,
      slowNetwork: false,
    );
    debugPrint('Small photo: $config3');
  }

  /// Example 9: Integration with journal entry upload
  Future<bool> example9_JournalUpload(
    File imageFile,
    String entryId,
  ) async {
    debugPrint('\n=== Example 9: Journal Upload Integration ===');

    try {
      // Step 1: Check if compression needed
      if (!MediaCompression.needsCompression(imageFile)) {
        debugPrint('Image small enough, skipping compression');
        // Upload original
        // ... upload logic
        return true;
      }

      // Step 2: Compress image
      final result = await _compressor.compressImage(
        imageFile,
        config: ImageCompressionConfig.optimizedForTravel,
      );

      debugPrint('Compressed image:');
      debugPrint('- Size: ${result.compressedSize} bytes');
      debugPrint('- Dimensions: ${result.width}x${result.height}');
      debugPrint('- Reduction: ${result.sizeReductionPercent}%');

      // Step 3: Upload compressed bytes
      // Pseudocode for actual upload:
      // await journalRepository.addMedia(
      //   entryId,
      //   result.bytes,
      //   mimeType: 'image/jpeg',
      //   width: result.width,
      //   height: result.height,
      //   fileSize: result.compressedSize,
      // );

      debugPrint('Upload successful!');
      return true;
    } catch (e) {
      debugPrint('Upload failed: $e');
      return false;
    }
  }

  /// Example 10: Estimate compressed size before compression
  void example10_EstimateSize() {
    debugPrint('\n=== Example 10: Estimate Compressed Size ===');

    // Estimate based on dimensions
    final estimatedSize = MediaCompression.estimateCompressedSize(
      4000, // width
      3000, // height
      85, // quality
      format: 'jpeg',
    );

    debugPrint('Estimated compressed size: $estimatedSize bytes');
    debugPrint('This is useful for showing previews before compression');
  }

  /// Run all examples
  Future<void> runAllExamples() async {
    debugPrint('╔════════════════════════════════════════════╗');
    debugPrint('║  Media Compression Utility Examples        ║');
    debugPrint('╚════════════════════════════════════════════╝');

    // Note: These examples won't actually run without real image files
    // They demonstrate the API and usage patterns

    debugPrint('\nNote: These examples demonstrate the API.');
    debugPrint('Replace file paths with actual image files to run.');

    // Uncomment to run with actual files:
    // await example1_BasicCompression();
    // await example2_CustomConfiguration();
    // await example3_PredefinedConfigurations();
    // await example5_CompressFromBytes();
    // await example8_RecommendedSettings();
    // await example10_EstimateSize();
  }
}

/// Function to run the examples
Future<void> main() async {
  final examples = MediaCompressionExample();
  await examples.runAllExamples();
}
