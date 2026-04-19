import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:soloadventurer/core/errors/exceptions.dart';

/// Result of video compression operation
class CompressedVideoResult {
  /// Compressed video file path
  final File file;

  /// Original file size in bytes
  final int originalSize;

  /// Compressed file size in bytes
  final int compressedSize;

  /// Video width in pixels
  final int width;

  /// Video height in pixels
  final int height;

  /// Video duration in seconds
  final double duration;

  /// Video format (e.g., 'mp4', 'mov')
  final String format;

  /// Compression quality (0-100)
  final int quality;

  /// Creates a new [CompressedVideoResult]
  const CompressedVideoResult({
    required this.file,
    required this.originalSize,
    required this.compressedSize,
    required this.width,
    required this.height,
    required this.duration,
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
      'CompressedVideoResult(format: $format, quality: $quality%, '
      'originalSize: ${_formatBytes(originalSize)}, '
      'compressedSize: ${_formatBytes(compressedSize)}, '
      'reduction: $sizeReductionPercent%, '
      'dimensions: ${width}x$height, '
      'duration: ${duration.toStringAsFixed(1)}s)';

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Configuration for video compression
class VideoCompressionConfig {
  /// Maximum width in pixels (null = no limit)
  final int? maxWidth;

  /// Maximum height in pixels (null = no limit)
  final int? maxHeight;

  /// Video quality (0-100, higher = better quality)
  final int quality;

  /// Target frame rate (null = keep original)
  final int? frameRate;

  /// Maintain aspect ratio when resizing
  final bool maintainAspect;

  /// Whether to include audio
  final bool includeAudio;

  /// Audio bitrate in kbps (null = default)
  final int? audioBitrate;

  /// Default configuration optimized for travel videos
  static const optimizedForTravel = VideoCompressionConfig(
    maxWidth: 1280,
    maxHeight: 720,
    quality: 80,
    frameRate: 30,
    maintainAspect: true,
    includeAudio: true,
    audioBitrate: 128,
  );

  /// High quality configuration for minimal compression
  static const highQuality = VideoCompressionConfig(
    maxWidth: 1920,
    maxHeight: 1080,
    quality: 90,
    frameRate: 60,
    maintainAspect: true,
    includeAudio: true,
    audioBitrate: 192,
  );

  /// Aggressive compression for slow networks
  static const aggressive = VideoCompressionConfig(
    maxWidth: 854,
    maxHeight: 480,
    quality: 70,
    frameRate: 24,
    maintainAspect: true,
    includeAudio: true,
    audioBitrate: 96,
  );

  /// Creates a new [VideoCompressionConfig]
  const VideoCompressionConfig({
    this.maxWidth,
    this.maxHeight,
    this.quality = 80,
    this.frameRate,
    this.maintainAspect = true,
    this.includeAudio = true,
    this.audioBitrate,
  });

  /// Validates the configuration
  void validate() {
    if (quality < 0 || quality > 100) {
      throw const InvalidVideoException(
        message: 'Quality must be between 0 and 100',
        code: 'invalid_quality',
      );
    }
    if (maxWidth != null && maxWidth! < 1) {
      throw const InvalidVideoException(
        message: 'Max width must be greater than 0',
        code: 'invalid_max_width',
      );
    }
    if (maxHeight != null && maxHeight! < 1) {
      throw const InvalidVideoException(
        message: 'Max height must be greater than 0',
        code: 'invalid_max_height',
      );
    }
    if (frameRate != null && (frameRate! < 1 || frameRate! > 120)) {
      throw const InvalidVideoException(
        message: 'Frame rate must be between 1 and 120',
        code: 'invalid_frame_rate',
      );
    }
    if (audioBitrate != null && (audioBitrate! < 32 || audioBitrate! > 320)) {
      throw const InvalidVideoException(
        message: 'Audio bitrate must be between 32 and 320 kbps',
        code: 'invalid_audio_bitrate',
      );
    }
  }

  /// Creates a copy with modified fields
  VideoCompressionConfig copyWith({
    int? maxWidth,
    int? maxHeight,
    int? quality,
    int? frameRate,
    bool? maintainAspect,
    bool? includeAudio,
    int? audioBitrate,
  }) {
    return VideoCompressionConfig(
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      quality: quality ?? this.quality,
      frameRate: frameRate ?? this.frameRate,
      maintainAspect: maintainAspect ?? this.maintainAspect,
      includeAudio: includeAudio ?? this.includeAudio,
      audioBitrate: audioBitrate ?? this.audioBitrate,
    );
  }
}

/// Progress information during video compression
class VideoCompressionProgress {
  /// Current progress (0.0 to 1.0)
  final double progress;

  /// Current status message
  final String status;

  /// Creates a new [VideoCompressionProgress]
  const VideoCompressionProgress({
    required this.progress,
    required this.status,
  });

  @override
  String toString() =>
      'VideoCompressionProgress: ${(progress * 100).toStringAsFixed(0)}% - $status';
}

/// Utility for compressing videos before upload
///
/// This utility provides video compression functionality to reduce file sizes
/// while maintaining acceptable quality for travel journal videos. It supports
/// common video formats with configurable quality and resizing options.
///
/// Example usage:
/// ```dart
/// final compressor = VideoCompression();
///
/// // Compress with default settings
/// final result = await compressor.compressVideo(file);
///
/// // Compress with custom settings
/// final config = VideoCompressionConfig(
///   maxWidth: 1280,
///   maxHeight: 720,
///   quality: 80,
/// );
/// final result = await compressor.compressVideo(file, config: config);
///
/// // Compress with progress callback
/// final result = await compressor.compressVideo(
///   file,
///   config: config,
///   onProgress: (progress) {
///     print('Progress: ${(progress.progress * 100).toInt()}%');
///   },
/// );
/// ```
class VideoCompression {
  /// Maximum file size to attempt compression (500 MB)
  static const int maxFileSize = 500 * 1024 * 1024;

  /// Minimum quality to avoid excessive compression
  static const int minQuality = 50;

  /// Minimum duration (in seconds) to consider compression
  static const double minDuration = 1.0;

  /// Creates a new [VideoCompression] instance
  const VideoCompression();

  /// Compresses a video file with the given configuration
  ///
  /// [file] - The video file to compress
  /// [config] - Compression configuration (defaults to optimizedForTravel)
  /// [onProgress] - Optional callback for compression progress updates
  ///
  /// Returns [CompressedVideoResult] with compressed video file and metadata
  ///
  /// Throws [MediaCompressionException] if compression fails
  /// Throws [InvalidVideoException] if the file is invalid
  /// Throws [UnsupportedVideoFormatException] if the format is not supported
  Future<CompressedVideoResult> compressVideo(
    File file, {
    VideoCompressionConfig? config,
    void Function(VideoCompressionProgress)? onProgress,
  }) async {
    // Validate input
    _validateFile(file);

    // Use default config if none provided
    final compressionConfig =
        config ?? VideoCompressionConfig.optimizedForTravel;
    compressionConfig.validate();

    try {
      // Get original file size
      final originalSize = await file.length();

      // Notify start
      onProgress?.call(const VideoCompressionProgress(
        progress: 0.0,
        status: 'Starting compression...',
      ));

      // Get video metadata
      final metadata = await _getVideoMetadata(file);
      if (metadata == null) {
        throw const MediaCompressionException(
          message: 'Failed to read video metadata',
          code: 'metadata_read_failed',
        );
      }

      // Check if video is too short
      if (metadata['duration'] < minDuration) {
        throw InvalidVideoException(
          message: 'Video is too short (${metadata['duration']}s). '
              'Minimum duration is ${minDuration}s',
          code: 'video_too_short',
        );
      }

      // Notify progress
      onProgress?.call(const VideoCompressionProgress(
        progress: 0.1,
        status: 'Preparing compression...',
      ));

      // Perform compression
      final result = await _performCompression(
        file,
        originalSize,
        metadata,
        compressionConfig,
        onProgress,
      );

      // Notify completion
      onProgress?.call(const VideoCompressionProgress(
        progress: 1.0,
        status: 'Compression complete',
      ));

      return result;
    } on MediaCompressionException {
      rethrow;
    } on InvalidVideoException {
      rethrow;
    } on UnsupportedVideoFormatException {
      rethrow;
    } catch (e) {
      throw MediaCompressionException(
        message: 'Failed to compress video: ${e.toString()}',
        code: 'compression_failed',
      );
    }
  }

  /// Validates that the file is a valid video
  void _validateFile(File file) {
    if (!file.existsSync()) {
      throw const InvalidVideoException(
        message: 'File does not exist',
        code: 'file_not_found',
      );
    }

    // Check file size
    try {
      final fileSize = file.lengthSync();
      if (fileSize > maxFileSize) {
        throw InvalidVideoException(
          message: 'File is too large (${_formatBytes(fileSize)}). '
              'Maximum size is ${_formatBytes(maxFileSize)}',
          code: 'file_too_large',
        );
      }
      if (fileSize == 0) {
        throw const InvalidVideoException(
          message: 'File is empty',
          code: 'file_empty',
        );
      }
    } on FileSystemException catch (e) {
      throw InvalidVideoException(
        message: 'Cannot read file: ${e.message}',
        code: 'file_read_error',
      );
    }

    final extension = path.extension(file.path).toLowerCase();
    if (!['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(extension)) {
      throw UnsupportedVideoFormatException(
        message: 'Unsupported video format: $extension. '
            'Supported formats: mp4, mov, avi, mkv, webm',
        code: 'unsupported_format',
      );
    }
  }

  /// Gets video metadata (dimensions, duration, format)
  Future<Map<String, dynamic>?> _getVideoMetadata(File file) async {
    // This is a placeholder implementation
    // In a real implementation, you would use video_compress or ffmpeg_kit_flutter
    // to extract actual metadata from the video file
    // For now, we return default values

    try {
      // TODO: Implement actual metadata extraction using video_compress package
      // Once the package is integrated:
      // final metadata = await VideoCompress.getMediaInfo(file.path);
      // return {
      //   'width': metadata.width,
      //   'height': metadata.height,
      //   'duration': metadata.duration! / 1000, // Convert ms to seconds
      //   'frameRate': metadata.framerate,
      //   'bitrate': metadata.bitrate,
      // };

      // Placeholder values
      return {
        'width': 1920,
        'height': 1080,
        'duration': 30.0,
        'frameRate': 30,
        'bitrate': 5000000,
      };
    } catch (e) {
      return null;
    }
  }

  /// Performs the actual video compression
  Future<CompressedVideoResult> _performCompression(
    File file,
    int originalSize,
    Map<String, dynamic> metadata,
    VideoCompressionConfig config,
    void Function(VideoCompressionProgress)? onProgress,
  ) async {
    // This is a placeholder implementation
    // In a real implementation, you would use video_compress or ffmpeg_kit_flutter
    // to perform actual compression

    try {
      // TODO: Implement actual compression using video_compress package
      // Once the package is integrated:
      // final info = await VideoCompress.getMediaInfo(file.path);
      // await VideoCompress.setCompressionQuality(config.quality / 100);
      //
      // if (config.maxWidth != null || config.maxHeight != null) {
      //   await VideoCompress.resizeVideo(
      //     width: config.maxWidth,
      //     height: config.maxHeight,
      //     keepAspectRatio: config.maintainAspect,
      //   );
      // }
      //
      // final result = await VideoCompress.compressVideo(
      //   file.path,
      //   quality: config.quality,
      //   deleteOrigin: false,
      //   includeAudio: config.includeAudio,
      //   frameRate: config.frameRate,
      // );
      //
      // if (result == null) {
      //   throw const MediaCompressionException(...);
      // }

      // Notify progress
      onProgress?.call(const VideoCompressionProgress(
        progress: 0.3,
        status: 'Compressing video...',
      ));

      // Simulate compression delay
      await Future.delayed(const Duration(milliseconds: 100));

      // For now, just return the original file as a placeholder
      // In production, this would be the compressed file
      final extension = path.extension(file.path);
      final compressedFile = File('${file.path}.compressed$extension');

      // Copy the file as a placeholder
      await file.copy(compressedFile.path);

      onProgress?.call(const VideoCompressionProgress(
        progress: 0.9,
        status: 'Finalizing...',
      ));

      // Return placeholder result
      return CompressedVideoResult(
        file: compressedFile,
        originalSize: originalSize,
        compressedSize: await compressedFile.length(),
        width: metadata['width'] as int,
        height: metadata['height'] as int,
        duration: metadata['duration'] as double,
        format: path.extension(file.path).replaceFirst('.', ''),
        quality: config.quality,
      );
    } catch (e) {
      if (e is MediaCompressionException) rethrow;
      throw MediaCompressionException(
        message: 'Video compression failed: ${e.toString()}',
        code: 'video_compression_failed',
      );
    }
  }

  /// Formats bytes to human-readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Estimates compressed file size before actual compression
  ///
  /// This is a rough estimate based on video properties and quality
  /// Useful for showing UI previews
  static int estimateCompressedSize(
    int width,
    int height,
    double duration,
    int quality, {
    int frameRate = 30,
    String format = 'mp4',
  }) {
    final pixelCount = width * height;
    final totalFrames = (duration * frameRate).round();

    // Rough estimation formula for H.264 video
    // Base bitrate: 0.07 bits per pixel per frame at quality 100
    const baseBitsPerPixel = 0.07;
    final qualityFactor = quality / 100;
    final estimatedBitrate = pixelCount * baseBitsPerPixel * qualityFactor;

    // Calculate total size in bits
    final totalBits = estimatedBitrate * totalFrames;

    // Convert to bytes (divide by 8) and add 20% for audio and overhead
    return ((totalBits / 8) * 1.2).round();
  }

  /// Determines if a video needs compression based on file size
  static bool needsCompression(File file, {int threshold = 50 * 1024 * 1024}) {
    // Default threshold: 50 MB
    try {
      final fileSize = file.lengthSync();
      return fileSize > threshold;
    } catch (e) {
      return false;
    }
  }

  /// Gets recommended compression settings based on video properties
  static VideoCompressionConfig getRecommendedConfig({
    required int fileSize,
    required int width,
    required int height,
    required double duration,
    bool slowNetwork = false,
  }) {
    final resolution = width * height;
    final megapixels = resolution / 1000000;

    // Large videos or slow networks
    if (megapixels > 2.0 || slowNetwork) {
      return VideoCompressionConfig.aggressive;
    }

    // Medium-sized videos (1080p)
    if (megapixels > 1.0) {
      return VideoCompressionConfig.optimizedForTravel;
    }

    // Small videos - use high quality
    return VideoCompressionConfig.highQuality;
  }

  /// Cleans up temporary compressed files
  Future<void> cleanup(File compressedFile) async {
    try {
      if (await compressedFile.exists()) {
        await compressedFile.delete();
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }
}
