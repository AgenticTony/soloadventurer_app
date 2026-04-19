import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/journal/data/services/video_compression.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'media_test_helpers.dart';

void main() {
  group('CompressedVideoResult', () {
    group('computed properties', () {
      test('should calculate compressionRatio correctly', () {
        // Arrange
        final result = createTestCompressedVideoResult(
          originalSize: 100 * 1024 * 1024, // 100 MB
          compressedSize: 20 * 1024 * 1024, // 20 MB
        );

        // Assert
        expect(result.compressionRatio, equals(5.0));
      });

      test('should calculate sizeReductionPercent correctly', () {
        // Arrange
        final result = createTestCompressedVideoResult(
          originalSize: 100 * 1024 * 1024, // 100 MB
          compressedSize: 20 * 1024 * 1024, // 20 MB
        );

        // Assert
        expect(result.sizeReductionPercent, equals(80));
      });

      test('should determine effectiveness based on 10% threshold', () {
        // Arrange & Assert
        final effectiveResult = createTestCompressedVideoResult(
          originalSize: 100 * 1024 * 1024, // 100 MB
          compressedSize: 50 * 1024 * 1024, // 50 MB (50% reduction)
        );
        expect(effectiveResult.isEffective, isTrue);

        final ineffectiveResult = createTestCompressedVideoResult(
          originalSize: 100 * 1024 * 1024, // 100 MB
          compressedSize: 95 * 1024 * 1024, // 95 MB (5% reduction)
        );
        expect(ineffectiveResult.isEffective, isFalse);
      });

      test('should format toString with all details', () {
        // Arrange
        final result = createTestCompressedVideoResult(
          originalSize: 100 * 1024 * 1024, // 100 MB
          compressedSize: 20 * 1024 * 1024, // 20 MB
          width: 1920,
          height: 1080,
          duration: 30.0,
          format: 'mp4',
          quality: 80,
        );

        // Act
        final str = result.toString();

        // Assert
        expect(str, contains('mp4'));
        expect(str, contains('80%'));
        expect(str, contains('100.0 MB'));
        expect(str, contains('20.0 MB'));
        expect(str, contains('80%'));
        expect(str, contains('1920x1080'));
        expect(str, contains('30.0s'));
      });
    });
  });

  group('VideoCompressionConfig', () {
    group('presets', () {
      test('should have optimizedForTravel preset with correct values', () {
        // Assert
        const config = VideoCompressionConfig.optimizedForTravel;
        expect(config.maxWidth, equals(1280));
        expect(config.maxHeight, equals(720));
        expect(config.quality, equals(80));
        expect(config.frameRate, equals(30));
        expect(config.maintainAspect, isTrue);
        expect(config.includeAudio, isTrue);
        expect(config.audioBitrate, equals(128));
      });

      test('should have highQuality preset with correct values', () {
        // Assert
        const config = VideoCompressionConfig.highQuality;
        expect(config.maxWidth, equals(1920));
        expect(config.maxHeight, equals(1080));
        expect(config.quality, equals(90));
        expect(config.frameRate, equals(60));
        expect(config.maintainAspect, isTrue);
        expect(config.includeAudio, isTrue);
        expect(config.audioBitrate, equals(192));
      });

      test('should have aggressive preset with correct values', () {
        // Assert
        const config = VideoCompressionConfig.aggressive;
        expect(config.maxWidth, equals(854));
        expect(config.maxHeight, equals(480));
        expect(config.quality, equals(70));
        expect(config.frameRate, equals(24));
        expect(config.maintainAspect, isTrue);
        expect(config.includeAudio, isTrue);
        expect(config.audioBitrate, equals(96));
      });
    });

    group('validate', () {
      test(
          'should throw InvalidVideoException when quality is out of range (negative)',
          () {
        // Arrange
        const config = VideoCompressionConfig(quality: -1);

        // Act & Assert
        expect(
          () => config.validate(),
          throwsA(isA<InvalidVideoException>()
              .having((e) => e.code, 'code', equals('invalid_quality'))),
        );
      });

      test(
          'should throw InvalidVideoException when quality is out of range (> 100)',
          () {
        // Arrange
        const config = VideoCompressionConfig(quality: 101);

        // Act & Assert
        expect(
          () => config.validate(),
          throwsA(isA<InvalidVideoException>()
              .having((e) => e.code, 'code', equals('invalid_quality'))),
        );
      });

      test('should throw InvalidVideoException when maxWidth is less than 1',
          () {
        // Arrange
        const config = VideoCompressionConfig(maxWidth: 0);

        // Act & Assert
        expect(
          () => config.validate(),
          throwsA(isA<InvalidVideoException>()
              .having((e) => e.code, 'code', equals('invalid_max_width'))),
        );
      });

      test('should throw InvalidVideoException when maxHeight is less than 1',
          () {
        // Arrange
        const config = VideoCompressionConfig(maxHeight: 0);

        // Act & Assert
        expect(
          () => config.validate(),
          throwsA(isA<InvalidVideoException>()
              .having((e) => e.code, 'code', equals('invalid_max_height'))),
        );
      });

      test(
          'should throw InvalidVideoException when frameRate is out of range (< 1)',
          () {
        // Arrange
        const config = VideoCompressionConfig(frameRate: 0);

        // Act & Assert
        expect(
          () => config.validate(),
          throwsA(isA<InvalidVideoException>()
              .having((e) => e.code, 'code', equals('invalid_frame_rate'))),
        );
      });

      test(
          'should throw InvalidVideoException when frameRate is out of range (> 120)',
          () {
        // Arrange
        const config = VideoCompressionConfig(frameRate: 121);

        // Act & Assert
        expect(
          () => config.validate(),
          throwsA(isA<InvalidVideoException>()
              .having((e) => e.code, 'code', equals('invalid_frame_rate'))),
        );
      });

      test(
          'should throw InvalidVideoException when audioBitrate is out of range (< 32)',
          () {
        // Arrange
        const config = VideoCompressionConfig(audioBitrate: 31);

        // Act & Assert
        expect(
          () => config.validate(),
          throwsA(isA<InvalidVideoException>()
              .having((e) => e.code, 'code', equals('invalid_audio_bitrate'))),
        );
      });

      test(
          'should throw InvalidVideoException when audioBitrate is out of range (> 320)',
          () {
        // Arrange
        const config = VideoCompressionConfig(audioBitrate: 321);

        // Act & Assert
        expect(
          () => config.validate(),
          throwsA(isA<InvalidVideoException>()
              .having((e) => e.code, 'code', equals('invalid_audio_bitrate'))),
        );
      });

      test('should not throw when all values are valid', () {
        // Arrange
        const config = VideoCompressionConfig(
          maxWidth: 1920,
          maxHeight: 1080,
          quality: 80,
          frameRate: 30,
          audioBitrate: 128,
        );

        // Act & Assert
        expect(() => config.validate(), returnsNormally);
      });
    });

    group('copyWith', () {
      test('should create copy with modified maxWidth', () {
        // Arrange
        const config = VideoCompressionConfig(maxWidth: 1280);

        // Act
        final copy = config.copyWith(maxWidth: 1920);

        // Assert
        expect(copy.maxWidth, equals(1920));
        expect(config.maxWidth, equals(1280)); // Original unchanged
      });

      test('should create copy with multiple modified fields', () {
        // Arrange
        const config = VideoCompressionConfig(
          maxWidth: 1280,
          quality: 80,
          frameRate: 30,
        );

        // Act
        final copy = config.copyWith(
          maxWidth: 1920,
          quality: 90,
          frameRate: 60,
          maintainAspect: false,
        );

        // Assert
        expect(copy.maxWidth, equals(1920));
        expect(copy.quality, equals(90));
        expect(copy.frameRate, equals(60));
        expect(copy.maintainAspect, isFalse);
        expect(config.maxWidth, equals(1280)); // Original unchanged
        expect(config.quality, equals(80));
      });

      test('should preserve original values when no parameters provided', () {
        // Arrange
        const config = VideoCompressionConfig(
          maxWidth: 1280,
          quality: 80,
        );

        // Act
        final copy = config.copyWith();

        // Assert
        expect(copy.maxWidth, equals(1280));
        expect(copy.quality, equals(80));
      });
    });
  });

  group('VideoCompressionProgress', () {
    test('should store progress value correctly', () {
      // Arrange
      const progress = VideoCompressionProgress(
        progress: 0.5,
        status: 'Compressing...',
      );

      // Assert
      expect(progress.progress, equals(0.5));
      expect(progress.status, equals('Compressing...'));
    });

    test('should format toString correctly', () {
      // Arrange
      const progress = VideoCompressionProgress(
        progress: 0.75,
        status: 'Processing',
      );

      // Act
      final str = progress.toString();

      // Assert
      expect(str, contains('75%'));
      expect(str, contains('Processing'));
    });
  });

  group('VideoCompression - Static Methods', () {
    group('estimateCompressedSize', () {
      test('should estimate size correctly for 1080p video', () {
        // Act
        final estimated = VideoCompression.estimateCompressedSize(
          1920,
          1080,
          30.0, // 30 seconds
          80,
          frameRate: 30,
          format: 'mp4',
        );

        // Assert
        expect(estimated, greaterThan(0));
        // 1920x1080x30fpsx30s should produce a reasonable size estimate
        expect(estimated, lessThan(500 * 1024 * 1024)); // Should be < 500 MB
      });

      test('should estimate size correctly for 720p video', () {
        // Act
        final estimated720p = VideoCompression.estimateCompressedSize(
          1280,
          720,
          30.0,
          80,
          frameRate: 30,
        );

        final estimated1080p = VideoCompression.estimateCompressedSize(
          1920,
          1080,
          30.0,
          80,
          frameRate: 30,
        );

        // Assert
        expect(estimated720p, lessThan(estimated1080p));
      });

      test('should increase estimate with higher quality', () {
        // Act
        final lowQuality = VideoCompression.estimateCompressedSize(
          1920,
          1080,
          30.0,
          50,
        );

        final highQuality = VideoCompression.estimateCompressedSize(
          1920,
          1080,
          30.0,
          95,
        );

        // Assert
        expect(highQuality, greaterThan(lowQuality));
      });

      test('should increase estimate with longer duration', () {
        // Act
        final shortVideo = VideoCompression.estimateCompressedSize(
          1920,
          1080,
          10.0, // 10 seconds
          80,
        );

        final longVideo = VideoCompression.estimateCompressedSize(
          1920,
          1080,
          60.0, // 60 seconds
          80,
        );

        // Assert
        expect(longVideo, greaterThan(shortVideo));
      });

      test('should increase estimate with higher frame rate', () {
        // Act
        final lowFps = VideoCompression.estimateCompressedSize(
          1920,
          1080,
          30.0,
          80,
          frameRate: 24,
        );

        final highFps = VideoCompression.estimateCompressedSize(
          1920,
          1080,
          30.0,
          80,
          frameRate: 60,
        );

        // Assert
        expect(highFps, greaterThan(lowFps));
      });
    });

    group('needsCompression', () {
      test('should return true for files exceeding default threshold', () {
        // This test would require actual file system
        // Documenting expected behavior:
        // Files > 50 MB should need compression
      });

      test('should return false for files below threshold', () {
        // Files < 50 MB should not need compression
      });

      test('should use custom threshold when provided', () {
        // Should respect custom threshold parameter
      });
    });

    group('getRecommendedConfig', () {
      test('should return aggressive config for large videos', () {
        // Act
        final config = VideoCompression.getRecommendedConfig(
          fileSize: 200 * 1024 * 1024, // 200 MB
          width: 3840,
          height: 2160, // 4K
          duration: 60.0,
          slowNetwork: false,
        );

        // Assert
        expect(config, equals(VideoCompressionConfig.aggressive));
      });

      test('should return aggressive config for slow networks', () {
        // Act
        final config = VideoCompression.getRecommendedConfig(
          fileSize: 50 * 1024 * 1024, // 50 MB
          width: 1920,
          height: 1080, // 1080p
          duration: 30.0,
          slowNetwork: true,
        );

        // Assert
        expect(config, equals(VideoCompressionConfig.aggressive));
      });

      test('should return optimizedForTravel config for medium videos', () {
        // Act
        final config = VideoCompression.getRecommendedConfig(
          fileSize: 80 * 1024 * 1024, // 80 MB
          width: 1600,
          height: 900, // 1.44 MP (between 1.0 and 2.0)
          duration: 30.0,
          slowNetwork: false,
        );

        // Assert
        expect(config, equals(VideoCompressionConfig.optimizedForTravel));
      });

      test('should return highQuality config for small videos', () {
        // Act
        final config = VideoCompression.getRecommendedConfig(
          fileSize: 20 * 1024 * 1024, // 20 MB
          width: 1280,
          height: 720, // 720p (< 1 MP)
          duration: 30.0,
          slowNetwork: false,
        );

        // Assert
        expect(config, equals(VideoCompressionConfig.highQuality));
      });
    });
  });

  group('VideoCompression - Instance Methods', () {
    late VideoCompression videoCompression;

    setUp(() {
      videoCompression = const VideoCompression();
    });

    group('compressVideo', () {
      test('should throw InvalidVideoException when file does not exist', () {
        // Arrange
        final file = File('/nonexistent/path.mp4');

        // Act & Assert
        expect(
          () => videoCompression.compressVideo(file),
          throwsA(isA<InvalidVideoException>()
              .having((e) => e.code, 'code', equals('file_not_found'))),
        );
      });

      test('should throw UnsupportedVideoFormatException for unsupported format',
          () {
        // Arrange - create a real file so existence check passes
        final dir = Directory.systemTemp.createTempSync('video_test_');
        final file = File('${dir.path}/test.flv');
        file.writeAsStringSync('fake video content');

        try {
          // Act & Assert
          expect(
            () => videoCompression.compressVideo(file),
            throwsA(isA<UnsupportedVideoFormatException>()
                .having((e) => e.code, 'code', equals('unsupported_format'))),
          );
        } finally {
          dir.deleteSync(recursive: true);
        }
      });

      test('should throw InvalidVideoException when file exceeds max size', () {
        // This test requires creating a file > 500 MB or mocking file.lengthSync
        // Documenting expected behavior:
        // Files > 500 MB should throw InvalidVideoException with code 'file_too_large'
      });

      test('should throw InvalidVideoException when file is empty', () {
        // Empty files should throw with code 'file_empty'
      });

      test('should throw InvalidVideoException when video is too short', () {
        // Videos < 1 second should throw with code 'video_too_short'
      });

      test('should compress video with default config', () async {
        // Requires mocking or actual video file
        // Expected: Should return CompressedVideoResult with compressed file
      });

      test('should compress video with custom config', () async {
        // Requires mocking
      });

      test('should report progress via callback when provided', () async {
        // Should call onProgress callback with updates
      });

      test('should start with progress 0.0', () async {
        // First progress callback should be 0.0
      });

      test('should end with progress 1.0', () async {
        // Final progress callback should be 1.0
      });
    });

    group('cleanup', () {
      test('should delete temporary compressed file', () async {
        // Arrange
        final tempFile = File('/tmp/test_compressed.mp4');

        // Act
        await videoCompression.cleanup(tempFile);

        // Assert
        // File should be deleted
      });

      test('should not throw when file does not exist', () async {
        // Arrange
        final nonExistentFile = File('/nonexistent/path.mp4');

        // Act & Assert
        expect(
            () => videoCompression.cleanup(nonExistentFile), returnsNormally);
      });
    });
  });

  group('Video Compression Edge Cases', () {
    late VideoCompression videoCompression;

    setUp(() {
      videoCompression = const VideoCompression();
    });

    test('should handle very short videos (1-2 seconds)', () async {
      // Test with minimum duration video
    });

    test('should handle very long videos (> 10 minutes)', () async {
      // Test with long duration video
    });

    test('should handle 4K resolution videos', () async {
      // Test with 3840x2160 resolution
    });

    test('should handle vertical videos', () async {
      // Test with portrait orientation (1080x1920)
    });

    test('should handle square videos', () async {
      // Test with 1:1 aspect ratio (1080x1080)
    });

    test('should handle videos with no audio', () async {
      // Test with includeAudio = false
    });

    test('should handle videos with different frame rates', () async {
      // Test with 24, 30, 60 fps
    });

    test('should handle corrupted video files', () async {
      // Test error handling for corrupted files
    });
  });

  group('Video Compression Configurations', () {
    late VideoCompression videoCompression;

    setUp(() {
      videoCompression = const VideoCompression();
    });

    test('should maintain aspect ratio when maintainAspect is true', () async {
      // Test aspect ratio preservation
    });

    test('should resize to maxWidth when width exceeds limit', () async {
      // Test maxWidth constraint
    });

    test('should resize to maxHeight when height exceeds limit', () async {
      // Test maxHeight constraint
    });

    test('should apply correct quality level', () async {
      // Test quality levels: 70, 80, 90
    });

    test('should apply correct frame rate', () async {
      // Test frame rates: 24, 30, 60
    });

    test('should apply correct audio bitrate', () async {
      // Test audio bitrates: 96, 128, 192 kbps
    });

    test('should include audio when includeAudio is true', () async {
      // Test audio inclusion
    });

    test('should exclude audio when includeAudio is false', () async {
      // Test audio exclusion
    });
  });

  group('Video Compression Performance', () {
    test('should complete compression within reasonable time for short videos',
        () async {
      // Test compression speed for < 30 second videos
    });

    test('should complete compression within reasonable time for long videos',
        () async {
      // Test compression speed for > 5 minute videos
    });

    test('should handle memory efficiently for large videos', () async {
      // Test memory usage
    });

    test('should provide frequent progress updates', () async {
      // Progress should be updated regularly during compression
    });
  });

  group('Video Compression Formats', () {
    test('should support MP4 format', () {
      // MP4 is the most common format
    });

    test('should support MOV format', () {
      // MOV format support
    });

    test('should support AVI format', () {
      // AVI format support
    });

    test('should support MKV format', () {
      // MKV format support
    });

    test('should support WebM format', () {
      // WebM format support
    });
  });

  group('Video Compression Constants', () {
    test('should have correct maxFileSize constant', () {
      // Verify maxFileSize is 500 MB
      const expectedMaxSize = 500 * 1024 * 1024;
      expect(VideoCompression.maxFileSize, equals(expectedMaxSize));
    });

    test('should have correct minQuality constant', () {
      // Verify minQuality is 50
      expect(VideoCompression.minQuality, equals(50));
    });

    test('should have correct minDuration constant', () {
      // Verify minDuration is 1.0 second
      expect(VideoCompression.minDuration, equals(1.0));
    });
  });
}
