import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import '../core/errors/exceptions.dart';

/// Result of image compression operation
class CompressedImageResult {
  /// Compressed image data
  final Uint8List bytes;

  /// Original file size in bytes
  final int originalSize;

  /// Compressed file size in bytes
  final int compressedSize;

  /// Image width in pixels
  final int width;

  /// Image height in pixels
  /// Compression format (jpeg, png)
  final String format;

  /// Compression quality (0-100)
  final int quality;

  /// Creates a new [CompressedImageResult]
  const CompressedImageResult({
    required this.bytes,
    required this.originalSize,
    required this.compressedSize,
    required this.width,
    required this.height,
    required this.format,
    required this.quality,
  });

  /// Compression ratio (original size / compressed size)
  double get compressionRatio => originalSize / compressedSize;

  /// Size reduction percentage
  int get sizeReductionPercent =>
      ((originalSize - compressedSize) / originalSize * 100).round();

  /// Whether the compression was effective (reduced size by at least 10%)
  bool get isEffective => sizeReductionPercent >= 10;

  @override
  String toString() =>
      'CompressedImageResult(format: $format, quality: $quality%, '
      'originalSize: ${_formatBytes(originalSize)}, '
      'compressedSize: ${_formatBytes(compressedSize)}, '
      'reduction: $sizeReductionPercent%, '
      'dimensions: ${width}x$height)';

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Configuration for image compression
class ImageCompressionConfig {
  /// Maximum width in pixels (null = no limit)
  final int? maxWidth;

  /// Maximum height in pixels (null = no limit)
  final int? maxHeight;

  /// JPEG quality (0-100, higher = better quality)
  final int quality;

  /// Target file size in bytes (null = no target)
  final int? targetSize;

  /// Maintain aspect ratio when resizing
  final bool maintainAspect;

  /// Whether to rotate image according to EXIF data
  final bool autoCorrectionAngle;

  /// Default configuration optimized for travel photos
  static const optimizedForTravel = ImageCompressionConfig(
    maxWidth: 1920,
    maxHeight: 1920,
    quality: 85,
    maintainAspect: true,
    autoCorrectionAngle: true,
  );

  /// High quality configuration for minimal compression
  static const highQuality = ImageCompressionConfig(
    maxWidth: 2560,
    maxHeight: 2560,
    quality: 95,
    maintainAspect: true,
    autoCorrectionAngle: true,
  );

  /// Aggressive compression for slow networks
  static const aggressive = ImageCompressionConfig(
    maxWidth: 1280,
    maxHeight: 1280,
    quality: 70,
    maintainAspect: true,
    autoCorrectionAngle: true,
  );

  /// Creates a new [ImageCompressionConfig]
  const ImageCompressionConfig({
    this.maxWidth,
    this.maxHeight,
    this.quality = 85,
    this.targetSize,
    this.maintainAspect = true,
    this.autoCorrectionAngle = true,
  });

  /// Validates the configuration
  void validate() {
    if (quality < 0 || quality > 100) {
      throw const InvalidImageException(
        message: 'Quality must be between 0 and 100',
        code: 'invalid_quality',
      );
    }
    if (maxWidth != null && maxWidth! < 1) {
      throw const InvalidImageException(
        message: 'Max width must be greater than 0',
        code: 'invalid_max_width',
      );
    }
    if (maxHeight != null && maxHeight! < 1) {
      throw const InvalidImageException(
        message: 'Max height must be greater than 0',
        code: 'invalid_max_height',
      );
    }
    if (targetSize != null && targetSize! < 1) {
      throw const InvalidImageException(
        message: 'Target size must be greater than 0',
        code: 'invalid_target_size',
      );
    }
  }

  /// Creates a copy with modified fields
  ImageCompressionConfig copyWith({
    int? maxWidth,
    int? maxHeight,
    int? quality,
    int? targetSize,
    bool? maintainAspect,
    bool? autoCorrectionAngle,
  }) {
    return ImageCompressionConfig(
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      quality: quality ?? this.quality,
      targetSize: targetSize ?? this.targetSize,
      maintainAspect: maintainAspect ?? this.maintainAspect,
      autoCorrectionAngle: autoCorrectionAngle ?? this.autoCorrectionAngle,
    );
  }
}

/// Utility for compressing images before upload
///
/// This utility provides image compression functionality to reduce file sizes
/// while maintaining acceptable quality for travel journal photos. It supports
/// JPEG and PNG formats with configurable quality and resizing options.
///
/// Example usage:
/// ```dart
/// final compressor = MediaCompression();
///
/// // Compress with default settings
/// final result = await compressor.compressImage(file);
///
/// // Compress with custom settings
/// final config = ImageCompressionConfig(
///   maxWidth: 1920,
///   maxHeight: 1920,
///   quality: 85,
/// );
/// final result = await compressor.compressImage(file, config: config);
///
/// // Get compressed bytes
/// final bytes = result.bytes;
/// final fileSize = result.compressedSize;
/// ```
class MediaCompression {
  /// Maximum file size to attempt compression (10 MB)
  static const int maxFileSize = 10 * 1024 * 1024;

  /// Minimum quality to avoid excessive compression
  static const int minQuality = 50;

  /// Creates a new [MediaCompression] instance
  const MediaCompression();

  /// Compresses an image file with the given configuration
  ///
  /// [file] - The image file to compress
  /// [config] - Compression configuration (defaults to optimizedForTravel)
  ///
  /// Returns [CompressedImageResult] with compressed image data and metadata
  ///
  /// Throws [MediaCompressionException] if compression fails
  /// Throws [InvalidImageException] if the file is invalid
  /// Throws [UnsupportedImageFormatException] if the format is not supported
  Future<CompressedImageResult> compressImage(
    File file, {
    ImageCompressionConfig? config,
  }) async {
    // Validate input
    _validateFile(file);

    // Use default config if none provided
    final compressionConfig = config ?? ImageCompressionConfig.optimizedForTravel;
    compressionConfig.validate();

    try {
      // Get original file size
      final originalSize = await file.length();

      // Get file extension
      final extension = path.extension(file.path).toLowerCase();

      // Compress based on format
      final result = await _compressByFormat(
        file,
        extension,
        originalSize,
        compressionConfig,
      );

      return result;
    } on MediaCompressionException {
      rethrow;
    } on InvalidImageException {
      rethrow;
    } on UnsupportedImageFormatException {
      rethrow;
    } catch (e, stackTrace) {
      throw MediaCompressionException(
        message: 'Failed to compress image: ${e.toString()}',
        code: 'compression_failed',
      );
    }
  }

  /// Compresses image from bytes with the given configuration
  ///
  /// [bytes] - The image bytes to compress
  /// [format] - Image format (e.g., 'jpg', 'png')
  /// [originalSize] - Original file size in bytes
  /// [config] - Compression configuration
  ///
  /// Returns [CompressedImageResult] with compressed image data and metadata
  Future<CompressedImageResult> compressBytes(
    Uint8List bytes,
    String format, {
    int? originalSize,
    ImageCompressionConfig? config,
  }) async {
    // Validate input
    if (bytes.isEmpty) {
      throw const InvalidImageException(
        message: 'Image bytes cannot be empty',
        code: 'empty_bytes',
      );
    }

    final compressionConfig = config ?? ImageCompressionConfig.optimizedForTravel;
    compressionConfig.validate();

    try {
      final size = originalSize ?? bytes.length;
      final extension = '.$format';

      final result = await _compressByFormat(
        bytes,
        extension,
        size,
        compressionConfig,
      );

      return result;
    } on MediaCompressionException {
      rethrow;
    } on InvalidImageException {
      rethrow;
    } on UnsupportedImageFormatException {
      rethrow;
    } catch (e, stackTrace) {
      throw MediaCompressionException(
        message: 'Failed to compress image bytes: ${e.toString()}',
        code: 'compression_failed',
      );
    }
  }

  /// Validates that the file is a valid image
  void _validateFile(File file) {
    if (!file.existsSync()) {
      throw const InvalidImageException(
        message: 'File does not exist',
        code: 'file_not_found',
      );
    }

    final extension = path.extension(file.path).toLowerCase();
    if (!['.jpg', '.jpeg', '.png'].contains(extension)) {
      throw UnsupportedImageFormatException(
        message: 'Unsupported image format: $extension. '
            'Supported formats: jpg, jpeg, png',
        code: 'unsupported_format',
      );
    }
  }

  /// Compresses image based on format
  Future<CompressedImageResult> _compressByFormat(
    dynamic source, // File or Uint8List
    String extension,
    int originalSize,
    ImageCompressionConfig config,
  ) async {
    if (extension == '.png') {
      return await _compressPng(source, originalSize, config);
    } else {
      // Default to JPEG for .jpg and .jpeg
      return await _compressJpeg(source, originalSize, config);
    }
  }

  /// Compresses JPEG image
  Future<CompressedImageResult> _compressJpeg(
    dynamic source,
    int originalSize,
    ImageCompressionConfig config,
  ) async {
    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        source is File ? source.path : null,
        bytes: source is Uint8List ? source : null,
        minWidth: null,
        minHeight: null,
        maxWidth: config.maxWidth,
        maxHeight: config.maxHeight,
        quality: config.quality,
        format: CompressFormat.jpeg,
        keepExif: false,
        autoCorrectionAngle: config.autoCorrectionAngle,
      );

      if (compressed == null) {
        throw const MediaCompressionException(
          message: 'JPEG compression returned null result',
          code: 'compression_null_result',
        );
      }

      // Get image dimensions
      final image = await FlutterImageCompress.compressWithFile(
        source is File ? source.path : null,
        bytes: source is Uint8List ? source : null,
        minWidth: null,
        minHeight: null,
        maxWidth: config.maxWidth,
        maxHeight: config.maxHeight,
        quality: config.quality,
        format: CompressFormat.jpeg,
        keepExif: false,
        autoCorrectionAngle: config.autoCorrectionAngle,
      );

      // If target size is specified, adjust quality if needed
      if (config.targetSize != null && compressed.length > config.targetSize!) {
        return await _adjustQualityForTargetSize(
          source,
          originalSize,
          config,
          compressed.length,
        );
      }

      // Get dimensions from compressed image
      final dimensions = await _getImageDimensions(compressed);

      return CompressedImageResult(
        bytes: compressed,
        originalSize: originalSize,
        compressedSize: compressed.length,
        width: dimensions.$1,
        height: dimensions.$2,
        format: 'jpeg',
        quality: config.quality,
      );
    } catch (e) {
      if (e is MediaCompressionException) rethrow;
      throw MediaCompressionException(
        message: 'JPEG compression failed: ${e.toString()}',
        code: 'jpeg_compression_failed',
      );
    }
  }

  /// Compresses PNG image
  Future<CompressedImageResult> _compressPng(
    dynamic source,
    int originalSize,
    ImageCompressionConfig config,
  ) async {
    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        source is File ? source.path : null,
        bytes: source is Uint8List ? source : null,
        minWidth: null,
        minHeight: null,
        maxWidth: config.maxWidth,
        maxHeight: config.maxHeight,
        quality: config.quality,
        format: CompressFormat.png,
        keepExif: false,
        autoCorrectionAngle: config.autoCorrectionAngle,
      );

      if (compressed == null) {
        throw const MediaCompressionException(
          message: 'PNG compression returned null result',
          code: 'compression_null_result',
        );
      }

      // Get dimensions from compressed image
      final dimensions = await _getImageDimensions(compressed);

      return CompressedImageResult(
        bytes: compressed,
        originalSize: originalSize,
        compressedSize: compressed.length,
        width: dimensions.$1,
        height: dimensions.$2,
        format: 'png',
        quality: config.quality,
      );
    } catch (e) {
      if (e is MediaCompressionException) rethrow;
      throw MediaCompressionException(
        message: 'PNG compression failed: ${e.toString()}',
        code: 'png_compression_failed',
      );
    }
  }

  /// Adjusts quality to meet target file size
  Future<CompressedImageResult> _adjustQualityForTargetSize(
    dynamic source,
    int originalSize,
    ImageCompressionConfig config,
    int currentSize,
  ) async {
    final targetSize = config.targetSize!;
    var quality = config.quality;
    var compressed = await FlutterImageCompress.compressWithFile(
      source is File ? source.path : null,
      bytes: source is Uint8List ? source : null,
      maxWidth: config.maxWidth,
      maxHeight: config.maxHeight,
      quality: quality,
      format: CompressFormat.jpeg,
      keepExif: false,
      autoCorrectionAngle: config.autoCorrectionAngle,
    );

    // Binary search for optimal quality
    var minQ = MediaCompression.minQuality;
    var maxQ = config.quality;

    while (compressed != null && compressed.length > targetSize && quality > minQ) {
      quality = ((minQ + maxQ) / 2).round();
      compressed = await FlutterImageCompress.compressWithFile(
        source is File ? source.path : null,
        bytes: source is Uint8List ? source : null,
        maxWidth: config.maxWidth,
        maxHeight: config.maxHeight,
        quality: quality,
        format: CompressFormat.jpeg,
        keepExif: false,
        autoCorrectionAngle: config.autoCorrectionAngle,
      );

      if (compressed != null && compressed.length > targetSize) {
        maxQ = quality;
      } else {
        minQ = quality;
      }
    }

    if (compressed == null) {
      throw const MediaCompressionException(
        message: 'Failed to achieve target file size',
        code: 'target_size_not_achievable',
      );
    }

    final dimensions = await _getImageDimensions(compressed);

    return CompressedImageResult(
      bytes: compressed,
      originalSize: originalSize,
      compressedSize: compressed.length,
      width: dimensions.$1,
      height: dimensions.$2,
      format: 'jpeg',
      quality: quality,
    );
  }

  /// Gets image dimensions from compressed bytes
  Future<(int, int)> _getImageDimensions(Uint8List bytes) async {
    // This is a simplified implementation
    // In a production app, you'd want to use a proper image decoder
    // For now, we'll return default dimensions
    // TODO: Implement proper dimension extraction using image package
    return (1920, 1080);
  }

  /// Estimates compressed file size before actual compression
  ///
  /// This is a rough estimate based on image dimensions and quality
  /// Useful for showing UI previews
  static int estimateCompressedSize(
    int width,
    int height,
    int quality, {
    String format = 'jpeg',
  }) {
    final pixelCount = width * height;

    // Rough estimation formulas based on format
    if (format == 'png') {
      // PNG: ~3-4 bytes per pixel depending on complexity
      return (pixelCount * 3.5).round();
    } else {
      // JPEG: varies significantly by quality and content
      // This is a very rough estimate
      final baseBytesPerPixel = 0.15;
      final qualityFactor = quality / 100;
      return (pixelCount * baseBytesPerPixel * qualityFactor).round();
    }
  }

  /// Determines if an image needs compression based on file size
  static bool needsCompression(File file, {int threshold = 1024 * 1024}) {
    // Default threshold: 1 MB
    try {
      final fileSize = file.lengthSync();
      return fileSize > threshold;
    } catch (e) {
      return false;
    }
  }

  /// Gets recommended compression settings based on image properties
  static ImageCompressionConfig getRecommendedConfig({
    required int fileSize,
    required int width,
    required int height,
    bool slowNetwork = false,
  }) {
    final megapixels = (width * height) / (1000000);

    // Large images or slow networks
    if (megapixels > 8 || slowNetwork) {
      return ImageCompressionConfig.aggressive;
    }

    // Medium-sized images
    if (megapixels > 4) {
      return ImageCompressionConfig.optimizedForTravel;
    }

    // Small images - use high quality
    return ImageCompressionConfig.highQuality;
  }
}
