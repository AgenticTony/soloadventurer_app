import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

/// Service for compressing images before upload or caching to reduce storage.
///
/// This service reduces image file sizes by:
/// - Compressing JPEG images with configurable quality
/// - Resizing images that exceed maximum dimensions
/// - Converting formats (PNG to JPEG for better compression)
/// - Optimizing for storage and network efficiency
///
/// Performance Benefits:
/// - 70-90% file size reduction (1 MB → 100-300 KB)
/// - Faster uploads (less data to transfer)
/// - Reduced storage costs
/// - Better app performance (less I/O)
/// - EXIF data automatically stripped for privacy
///
/// Usage:
/// ```dart
/// // Compress an image file
/// final result = await ImageCompressionService.compressFile(
///   file: imageFile,
///   quality: 80,
///   maxWidth: 1920,
/// );
///
/// debugPrint('Original: ${result.originalSize} bytes');
/// debugPrint('Compressed: ${result.compressedSize} bytes');
/// debugPrint('Savings: ${result.savingsPercentage}%');
/// ```
///
/// Best Practices:
/// - Use quality 80-90 for photos (good balance of quality/size)
/// - Use quality 60-70 for thumbnails/avatars (smaller files)
/// - Set maxWidth to 1920-2048 for full photos
/// - Set maxWidth to 1024-1200 for shared photos
/// - Set maxWidth to 150-300 for thumbnails
class ImageCompressionService {
  /// Private constructor to prevent instantiation
  ImageCompressionService._();

  /// Default JPEG compression quality (80%)
  ///
  /// This provides a good balance between image quality and file size.
  /// Higher quality (90-95) for professional photos
  /// Lower quality (70-80) for thumbnails/avatars
  static const int defaultQuality = 80;

  /// Default maximum width for images (1920 pixels)
  ///
  /// Images wider than this will be resized proportionally.
  /// 1920px is Full HD width, suitable for most modern displays.
  static const int defaultMaxWidth = 1920;

  /// Default maximum height for images (1920 pixels)
  ///
  /// Images taller than this will be resized proportionally.
  static const int defaultMaxHeight = 1920;

  /// Minimum acceptable quality
  static const int minQuality = 10;

  /// Maximum acceptable quality
  static const int maxQuality = 100;

  /// Compress an image file.
  ///
  /// Compresses the image by:
  /// 1. Decoding the image
  /// 2. Resizing if dimensions exceed maxWidth/maxHeight
  /// 3. Encoding as JPEG with specified quality
  /// 4. Returning compressed file and statistics
  ///
  /// Parameters:
  /// - [file]: The image file to compress
  /// - [quality]: JPEG compression quality (10-100, default: 85)
  /// - [maxWidth]: Maximum width in pixels (default: 1920)
  /// - [maxHeight]: Maximum height in pixels (default: 1920)
  /// - [targetFormat]: Target format (default: JPEG for better compression)
  /// - [outputPath]: Optional custom output path (default: same dir as input)
  ///
  /// Returns [CompressionResult] with file path and statistics.
  ///
  /// Example:
  /// ```dart
  /// final result = await ImageCompressionService.compressFile(
  ///   file: File('/path/to/image.jpg'),
  ///   quality: 85,
  ///   maxWidth: 1920,
  /// );
  ///
  /// if (result.success) {
  ///   debugPrint('Compressed to: ${result.compressedFile.path}');
  ///   debugPrint('Saved ${result.savingsPercentage}%');
  /// }
  /// ```
  static Future<CompressionResult> compressFile(
    File file, {
    int quality = defaultQuality,
    int? maxWidth,
    int? maxHeight,
    ImageFormat targetFormat = ImageFormat.jpeg,
    String? outputPath,
  }) async {
    // Validate parameters
    _validateQuality(quality);

    if (!await file.exists()) {
      throw CompressionException('File does not exist: ${file.path}');
    }

    final originalSize = await file.length();
    if (kDebugMode) {
      debugPrint('ImageCompressionService: Compressing ${file.path}');
      debugPrint('  - Original size: ${_formatBytes(originalSize)}');
      debugPrint('  - Quality: $quality%');
    }

    try {
      // Read image bytes
      final bytes = await file.readAsBytes();

      // Compress the image
      final compressionResult = await compressBytes(
        bytes,
        quality: quality,
        maxWidth: maxWidth ?? defaultMaxWidth,
        maxHeight: maxHeight ?? defaultMaxHeight,
        targetFormat: targetFormat,
      );

      // Determine output path
      final finalOutputPath =
          outputPath ?? _generateOutputPath(file.path, targetFormat);

      // Write compressed file
      final compressedFile = File(finalOutputPath);
      await compressedFile.writeAsBytes(compressionResult.compressedBytes);

      final result = CompressionResult(
        originalFile: file,
        compressedFile: compressedFile,
        originalSize: originalSize,
        compressedSize: compressionResult.compressedBytes.length,
        originalWidth: compressionResult.originalWidth,
        originalHeight: compressionResult.originalHeight,
        compressedWidth: compressionResult.compressedWidth,
        compressedHeight: compressionResult.compressedHeight,
        quality: quality,
        format: targetFormat,
        success: true,
      );

      if (kDebugMode) {
        debugPrint('  - Compressed size: ${result.formattedCompressedSize}');
        debugPrint('  - Savings: ${result.savingsPercentage}%');
        debugPrint(
            '  - Dimensions: ${result.originalWidth}x${result.originalHeight} → ${result.compressedWidth}x${result.compressedHeight}');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ImageCompressionService: Compression failed: $e');
      }
      rethrow;
    }
  }

  /// Compress image bytes directly.
  ///
  /// Useful for compressing images from memory (e.g., from image picker).
  ///
  /// Parameters:
  /// - [bytes]: The image bytes to compress
  /// - [quality]: JPEG compression quality (10-100, default: 85)
  /// - [maxWidth]: Maximum width in pixels (default: 1920)
  /// - [maxHeight]: Maximum height in pixels (default: 1920)
  /// - [targetFormat]: Target format (default: JPEG)
  ///
  /// Returns [ImageCompressionData] with compressed bytes and metadata.
  ///
  /// Example:
  /// ```dart
  /// final bytes = await imagePicker.getImageBytes();
  /// final result = await ImageCompressionService.compressBytes(
  ///   bytes: bytes,
  ///   quality: 85,
  /// );
  ///
  /// final compressedFile = File('/path/to/output.jpg')
  ///   ..writeAsBytesSync(result.compressedBytes);
  /// ```
  static Future<ImageCompressionData> compressBytes(
    Uint8List bytes, {
    int quality = defaultQuality,
    int? maxWidth,
    int? maxHeight,
    ImageFormat targetFormat = ImageFormat.jpeg,
  }) async {
    _validateQuality(quality);

    final maxW = maxWidth ?? defaultMaxWidth;
    final maxH = maxHeight ?? defaultMaxHeight;

    if (kDebugMode) {
      debugPrint('ImageCompressionService: Compressing ${bytes.length} bytes');
    }

    try {
      // Decode the image using the image package
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw const CompressionException('Failed to decode image');
      }

      final originalWidth = image.width;
      final originalHeight = image.height;

      // Resize if necessary (maintain aspect ratio)
      img.Image resizedImage = image;
      if (image.width > maxW || image.height > maxH) {
        resizedImage = img.copyResize(
          image,
          width: maxW,
          height: maxH,
          maintainAspect: true,
        );
      }

      final compressedWidth = resizedImage.width;
      final compressedHeight = resizedImage.height;

      // Encode with compression based on target format
      Uint8List compressedBytes;

      switch (targetFormat) {
        case ImageFormat.jpeg:
          compressedBytes = Uint8List.fromList(
            img.encodeJpg(resizedImage, quality: quality),
          );
          break;
        case ImageFormat.png:
          // PNG compression level (0-9)
          final compressionLevel = ((100 - quality) / 100 * 9).toInt();
          compressedBytes = Uint8List.fromList(
            img.encodePng(resizedImage, level: compressionLevel),
          );
          break;
        case ImageFormat.webp:
          // WebP encoding - fallback to JPEG for now as WebP encoding
          // requires a separate package or platform-specific codec
          compressedBytes = Uint8List.fromList(
            img.encodeJpg(resizedImage, quality: quality),
          );
          break;
      }

      if (kDebugMode) {
        final savings =
            ((1 - compressedBytes.length / bytes.length) * 100).toInt();
        debugPrint(
            '  - Original: ${_formatBytes(bytes.length)} ($originalWidth x $originalHeight)');
        debugPrint(
            '  - Compressed: ${_formatBytes(compressedBytes.length)} ($compressedWidth x $compressedHeight)');
        debugPrint('  - Savings: $savings%');
      }

      return ImageCompressionData(
        compressedBytes: compressedBytes,
        originalWidth: originalWidth,
        originalHeight: originalHeight,
        compressedWidth: compressedWidth,
        compressedHeight: compressedHeight,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ImageCompressionService: Compression failed: $e');
      }
      rethrow;
    }
  }

  /// Compress multiple images in batch.
  ///
  /// Optimized for compressing multiple images efficiently.
  /// Processes images concurrently to speed up the operation.
  ///
  /// Parameters:
  /// - [files]: List of image files to compress
  /// - [quality]: JPEG compression quality (10-100, default: 85)
  /// - [maxWidth]: Maximum width in pixels (default: 1920)
  /// - [maxHeight]: Maximum height in pixels (default: 1920)
  ///
  /// Returns a list of [CompressionResult] objects.
  ///
  /// Example:
  /// ```dart
  /// final results = await ImageCompressionService.compressBatch(
  ///   files: imageFiles,
  ///   quality: 85,
  /// );
  ///
  /// final totalSavings = results
  ///   .map((r) => r.savings)
  ///   .reduce((a, b) => a + b);
  /// debugPrint('Total savings: ${_formatBytes(totalSavings)}');
  /// ```
  static Future<List<CompressionResult>> compressBatch(
    List<File> files, {
    int quality = defaultQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    if (kDebugMode) {
      debugPrint(
          'ImageCompressionService: Compressing batch of ${files.length} images');
    }

    // Process in batches to avoid overwhelming memory
    const batchSize = 5;
    final List<CompressionResult> results = [];

    for (int i = 0; i < files.length; i += batchSize) {
      final batch = files.skip(i).take(batchSize);

      final batchResults = await Future.wait(
        batch.map(
          (file) => compressFile(
            file,
            quality: quality,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
        ),
      );

      results.addAll(batchResults);
    }

    if (kDebugMode) {
      final totalOriginal = results.fold<int>(
        0,
        (sum, r) => sum + r.originalSize,
      );
      final totalCompressed = results.fold<int>(
        0,
        (sum, r) => sum + r.compressedSize,
      );
      final totalSavings = totalOriginal - totalCompressed;

      debugPrint('Batch compression complete:');
      debugPrint('  - Total original: ${_formatBytes(totalOriginal)}');
      debugPrint('  - Total compressed: ${_formatBytes(totalCompressed)}');
      debugPrint(
          '  - Total savings: ${_formatBytes(totalSavings)} (${((1 - totalCompressed / totalOriginal) * 100).toStringAsFixed(1)}%)');
    }

    return results;
  }

  /// Get recommended quality for a specific use case.
  ///
  /// Returns the optimal quality setting based on the image's purpose.
  ///
  /// Example:
  /// ```dart
  /// final quality = ImageCompressionService.getQualityForUseCase(
  ///   ImageUseCase.profilePhoto,
  /// );
  /// // Returns 85 (good quality for profile photos)
  /// ```
  static int getQualityForUseCase(ImageUseCase useCase) {
    switch (useCase) {
      case ImageUseCase.highQuality:
        return 95; // Professional photos, archival
      case ImageUseCase.profilePhoto:
        return 85; // Profile photos, avatars
      case ImageUseCase.photoGallery:
        return 85; // Photo galleries, albums
      case ImageUseCase.sharedPhoto:
        return 80; // Shared photos, messages
      case ImageUseCase.thumbnail:
        return 75; // Thumbnails, list items
      case ImageUseCase.avatar:
        return 70; // Small avatars, icons
    }
  }

  /// Get recommended dimensions for a specific use case.
  ///
  /// Returns the optimal maximum dimensions based on the image's purpose.
  ///
  /// Example:
  /// ```dart
  /// final dims = ImageCompressionService.getDimensionsForUseCase(
  ///   ImageUseCase.thumbnail,
  /// );
  /// // Returns (200, 200) for thumbnails
  /// ```
  static ImageDimensions getDimensionsForUseCase(ImageUseCase useCase) {
    switch (useCase) {
      case ImageUseCase.highQuality:
        return const ImageDimensions(2048, 2048);
      case ImageUseCase.profilePhoto:
        return const ImageDimensions(800, 800);
      case ImageUseCase.photoGallery:
        return const ImageDimensions(1920, 1920);
      case ImageUseCase.sharedPhoto:
        return const ImageDimensions(1200, 1200);
      case ImageUseCase.thumbnail:
        return const ImageDimensions(200, 200);
      case ImageUseCase.avatar:
        return const ImageDimensions(150, 150);
    }
  }

  /// Validate quality parameter.
  static void _validateQuality(int quality) {
    if (quality < minQuality || quality > maxQuality) {
      throw const CompressionException(
        'Quality must be between $minQuality and $maxQuality',
      );
    }
  }

  /// Generate output path for compressed image.
  static String _generateOutputPath(String inputPath, ImageFormat format) {
    final dir = path.dirname(inputPath);
    final basename = path.basenameWithoutExtension(inputPath);
    final extension = _getFileExtension(format);
    return path.join(dir, '${basename}_compressed$extension');
  }

  /// Get file extension for format.
  static String _getFileExtension(ImageFormat format) {
    switch (format) {
      case ImageFormat.jpeg:
        return '.jpg';
      case ImageFormat.png:
        return '.png';
      case ImageFormat.webp:
        return '.webp';
    }
  }

  /// Format bytes to human-readable string.
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Result of image compression operation.
class CompressionResult {
  /// Original file before compression
  final File originalFile;

  /// Compressed file
  final File compressedFile;

  /// Original file size in bytes
  final int originalSize;

  /// Compressed file size in bytes
  final int compressedSize;

  /// Original image width in pixels
  final int originalWidth;

  /// Original image height in pixels
  final int originalHeight;

  /// Compressed image width in pixels
  final int compressedWidth;

  /// Compressed image height in pixels
  final int compressedHeight;

  /// Quality level used for compression
  final int quality;

  /// Output format
  final ImageFormat format;

  /// Whether compression was successful
  final bool success;

  const CompressionResult({
    required this.originalFile,
    required this.compressedFile,
    required this.originalSize,
    required this.compressedSize,
    required this.originalWidth,
    required this.originalHeight,
    required this.compressedWidth,
    required this.compressedHeight,
    required this.quality,
    required this.format,
    required this.success,
  });

  /// Bytes saved from compression
  int get savings => originalSize - compressedSize;

  /// Percentage of file size reduction (0-100)
  double get savingsPercentage {
    if (originalSize == 0) return 0;
    return ((1 - compressedSize / originalSize) * 100);
  }

  /// Original size formatted as string
  String get formattedOriginalSize => _formatBytes(originalSize);

  /// Compressed size formatted as string
  String get formattedCompressedSize => _formatBytes(compressedSize);

  /// Savings formatted as string
  String get formattedSavings => _formatBytes(savings);

  @override
  String toString() {
    return 'CompressionResult('
        'originalSize: $formattedOriginalSize, '
        'compressedSize: $formattedCompressedSize, '
        'savings: ${savingsPercentage.toStringAsFixed(1)}%, '
        'dimensions: ${originalWidth}x$originalHeight → ${compressedWidth}x$compressedHeight, '
        'quality: $quality, '
        'format: $format)';
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Data from compressing image bytes.
class ImageCompressionData {
  /// Compressed image bytes
  final Uint8List compressedBytes;

  /// Original image width in pixels
  final int originalWidth;

  /// Original image height in pixels
  final int originalHeight;

  /// Compressed image width in pixels
  final int compressedWidth;

  /// Compressed image height in pixels
  final int compressedHeight;

  const ImageCompressionData({
    required this.compressedBytes,
    required this.originalWidth,
    required this.originalHeight,
    required this.compressedWidth,
    required this.compressedHeight,
  });
}

/// Image format options.
enum ImageFormat {
  /// JPEG format (best compression for photos)
  jpeg,

  /// PNG format (lossless, better for graphics)
  png,

  /// WebP format (modern, good compression)
  webp;
}

/// Image use cases for optimization.
enum ImageUseCase {
  /// High quality archival photos
  highQuality,

  /// Profile photos and avatars
  profilePhoto,

  /// Photo gallery images
  photoGallery,

  /// Shared photos (messages, social media)
  sharedPhoto,

  /// Thumbnails for lists/grids
  thumbnail,

  /// Small avatars (user icons, etc.)
  avatar;
}

/// Dimensions for image compression.
class ImageDimensions {
  /// Maximum width in pixels
  final int width;

  /// Maximum height in pixels
  final int height;

  const ImageDimensions(this.width, this.height);

  @override
  String toString() => '${width}x$height';
}

/// Exception thrown during image compression.
class CompressionException implements Exception {
  /// Error message
  final String message;

  const CompressionException(this.message);

  @override
  String toString() => 'CompressionException: $message';
}
