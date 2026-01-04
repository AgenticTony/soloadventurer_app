import 'dart:io';
import 'package:flutter/material.dart';
import 'video_compression.dart';

/// Example 1: Basic video compression with default settings
Future<void> example1_BasicCompression() async {
  print('=== Example 1: Basic Compression ===\n');

  final compressor = VideoCompression();
  final videoFile = File('/path/to/video.mp4');

  try {
    final result = await compressor.compressVideo(videoFile);

    print('✓ Compression successful!');
    print('  Original: ${result.originalSize} bytes');
    print('  Compressed: ${result.compressedSize} bytes');
    print('  Reduction: ${result.sizeReductionPercent}%');
    print('  Dimensions: ${result.width}x${result.height}');
    print('  Duration: ${result.duration}s');

    // Don't forget to clean up
    await compressor.cleanup(result.file);
  } catch (e) {
    print('✗ Compression failed: $e');
  }
}

/// Example 2: Custom compression configuration
Future<void> example2_CustomConfiguration() async {
  print('=== Example 2: Custom Configuration ===\n');

  final compressor = VideoCompression();
  final videoFile = File('/path/to/video.mp4');

  // Create custom configuration
  final config = VideoCompressionConfig(
    maxWidth: 1280,
    maxHeight: 720,
    quality: 80,
    frameRate: 30,
    maintainAspect: true,
    includeAudio: true,
    audioBitrate: 128,
  );

  try {
    final result = await compressor.compressVideo(
      videoFile,
      config: config,
    );

    print('✓ Compression with custom config successful!');
    print('  Resolution: ${result.width}x${result.height}');
    print('  Quality: ${result.quality}%');

    await compressor.cleanup(result.file);
  } catch (e) {
    print('✗ Compression failed: $e');
  }
}

/// Example 3: Using predefined configurations
Future<void> example3_PredefinedConfigurations() async {
  print('=== Example 3: Predefined Configurations ===\n');

  final compressor = VideoCompression();
  final videoFile = File('/path/to/video.mp4');

  // Try different predefined configs
  final configs = {
    'Optimized for Travel': VideoCompressionConfig.optimizedForTravel,
    'High Quality': VideoCompressionConfig.highQuality,
    'Aggressive': VideoCompressionConfig.aggressive,
  };

  for (final entry in configs.entries) {
    try {
      print('Testing: ${entry.key}');
      final result = await compressor.compressVideo(
        videoFile,
        config: entry.value,
      );

      print('  ✓ ${result.sizeReductionPercent}% reduction');
      print('    Resolution: ${result.width}x${result.height}');
      print('    Size: ${(result.compressedSize / (1024 * 1024)).toStringAsFixed(2)} MB');

      await compressor.cleanup(result.file);
    } catch (e) {
      print('  ✗ Failed: $e');
    }
  }
}

/// Example 4: Compression with progress tracking
Future<void> example4_WithProgressTracking() async {
  print('=== Example 4: Progress Tracking ===\n');

  final compressor = VideoCompression();
  final videoFile = File('/path/to/video.mp4');

  try {
    final result = await compressor.compressVideo(
      videoFile,
      onProgress: (progress) {
        final percentage = (progress.progress * 100).toInt();
        print('  Progress: $percentage% - ${progress.status}');
      },
    );

    print('\n✓ Compression complete!');
    print('  Final size: ${(result.compressedSize / (1024 * 1024)).toStringAsFixed(2)} MB');

    await compressor.cleanup(result.file);
  } catch (e) {
    print('✗ Compression failed: $e');
  }
}

/// Example 5: Conditional compression based on file size
Future<void> example5_ConditionalCompression() async {
  print('=== Example 5: Conditional Compression ===\n');

  final compressor = VideoCompression();
  final videoFile = File('/path/to/video.mp4');

  try {
    // Check if compression is needed (default threshold: 50MB)
    if (VideoCompression.needsCompression(videoFile)) {
      print('Video is large, compressing...');

      final result = await compressor.compressVideo(videoFile);
      print('✓ Compressed: ${result.sizeReductionPercent}% reduction');

      await compressor.cleanup(result.file);
    } else {
      print('Video is already small enough, skipping compression');
    }

    // Custom threshold (20MB)
    if (VideoCompression.needsCompression(
      videoFile,
      threshold: 20 * 1024 * 1024,
    )) {
      print('Video is larger than 20MB threshold');
    }
  } catch (e) {
    print('✗ Operation failed: $e');
  }
}

/// Example 6: Getting recommended settings
Future<void> example6_RecommendedSettings() async {
  print('=== Example 6: Recommended Settings ===\n');

  final videoFile = File('/path/to/video.mp4');

  // Simulate getting video metadata
  final fileSize = await videoFile.length();
  final width = 1920;
  final height = 1080;
  final duration = 30.0;

  // Get recommended config for normal network
  final config = VideoCompression.getRecommendedConfig(
    fileSize: fileSize,
    width: width,
    height: height,
    duration: duration,
    slowNetwork: false,
  );

  print('Recommended config (normal network):');
  print('  Max dimensions: ${config.maxWidth}x${config.maxHeight}');
  print('  Quality: ${config.quality}%');
  print('  Frame rate: ${config.frameRate} fps');

  // Get recommended config for slow network
  final slowConfig = VideoCompression.getRecommendedConfig(
    fileSize: fileSize,
    width: width,
    height: height,
    duration: duration,
    slowNetwork: true,
  );

  print('\nRecommended config (slow network):');
  print('  Max dimensions: ${slowConfig.maxWidth}x${slowConfig.maxHeight}');
  print('  Quality: ${slowConfig.quality}%');
  print('  Frame rate: ${slowConfig.frameRate} fps');
}

/// Example 7: Estimating compressed size before compression
Future<void> example7_EstimateCompressedSize() async {
  print('=== Example 7: Estimate Compressed Size ===\n');

  final width = 1920;
  final height = 1080;
  final duration = 30.0;
  final quality = 80;

  // Estimate size before compression
  final estimatedSize = VideoCompression.estimateCompressedSize(
    width,
    height,
    duration,
    quality,
  );

  print('Estimated compressed size:');
  print('  Original: ${(1920 * 1080 * 30 * 0.5 / (1024 * 1024)).toStringAsFixed(2)} MB (rough estimate)');
  print('  Compressed: ${(estimatedSize / (1024 * 1024)).toStringAsFixed(2)} MB');
  print('  Quality: $quality%');
}

/// Example 8: Error handling
Future<void> example8_ErrorHandling() async {
  print('=== Example 8: Error Handling ===\n');

  final compressor = VideoCompression();
  final invalidFile = File('/path/to/invalid.txt');

  try {
    await compressor.compressVideo(invalidFile);
  } on UnsupportedVideoFormatException catch (e) {
    print('✗ Unsupported format: ${e.message}');
  } on InvalidVideoException catch (e) {
    print('✗ Invalid video: ${e.message}');
  } on MediaCompressionException catch (e) {
    print('✗ Compression error: ${e.message}');
  } catch (e) {
    print('✗ Unexpected error: $e');
  }
}

/// Example 9: Processing multiple videos
Future<void> example9_BatchProcessing() async {
  print('=== Example 9: Batch Processing ===\n');

  final compressor = VideoCompression();
  final videos = [
    File('/path/to/video1.mp4'),
    File('/path/to/video2.mp4'),
    File('/path/to/video3.mp4'),
  ];

  int successCount = 0;
  int failureCount = 0;
  int totalReduction = 0;

  for (final video in videos) {
    try {
      final result = await compressor.compressVideo(
        video,
        config: VideoCompressionConfig.optimizedForTravel,
      );

      successCount++;
      totalReduction += result.sizeReductionPercent;

      print('✓ Processed ${video.path}');
      print('  Reduction: ${result.sizeReductionPercent}%');

      // Clean up temporary file
      await compressor.cleanup(result.file);
    } catch (e) {
      failureCount++;
      print('✗ Failed to process ${video.path}: $e');
    }
  }

  print('\nSummary:');
  print('  Successful: $successCount');
  print('  Failed: $failureCount');
  print('  Average reduction: ${totalReduction / (successCount > 0 ? successCount : 1)}%');
}

/// Example 10: Integration with journal entry upload
Future<void> example10_JournalIntegration() async {
  print('=== Example 10: Journal Integration ===\n');

  final compressor = VideoCompression();
  final videoFile = File('/path/to/video.mp4');

  try {
    // Compress with progress
    final result = await compressor.compressVideo(
      videoFile,
      config: VideoCompressionConfig.optimizedForTravel,
      onProgress: (progress) {
        final percentage = (progress.progress * 100).toInt();
        print('  Compressing: $percentage% - ${progress.status}');
      },
    );

    print('\n✓ Compression complete!');
    print('  Size: ${(result.compressedSize / (1024 * 1024)).toStringAsFixed(2)} MB');
    print('  Reduction: ${result.sizeReductionPercent}%');
    print('  Duration: ${result.duration}s');

    // Here you would upload to journal:
    // final bytes = await result.file.readAsBytes();
    // await journalRepository.addMedia(
    //   entryId,
    //   bytes,
    //   mimeType: 'video/mp4',
    //   width: result.width,
    //   height: result.height,
    //   fileSize: result.compressedSize,
    //   duration: result.duration,
    // );

    print('\n✓ Ready to upload to journal entry');

    // Clean up after upload
    await compressor.cleanup(result.file);
  } catch (e) {
    print('✗ Failed: $e');
  }
}

/// Example 11: Flutter widget with progress dialog
class Example11_ProgressDialog extends StatefulWidget {
  const Example11_ProgressDialog({super.key});

  @override
  State<Example11_ProgressDialog> createState() => _Example11_ProgressDialogState();
}

class _Example11_ProgressDialogState extends State<Example11_ProgressDialog> {
  bool _isCompressing = false;
  double _progress = 0.0;
  String _status = '';
  String? _errorMessage;

  Future<void> _compressVideo() async {
    setState(() {
      _isCompressing = true;
      _progress = 0.0;
      _status = 'Starting...';
      _errorMessage = null;
    });

    final compressor = VideoCompression();
    final videoFile = File('/path/to/video.mp4');

    try {
      final result = await compressor.compressVideo(
        videoFile,
        config: VideoCompressionConfig.optimizedForTravel,
        onProgress: (progress) {
          setState(() {
            _progress = progress.progress;
            _status = progress.status;
          });
        },
      );

      setState(() {
        _status = 'Complete! ${(result.compressedSize / (1024 * 1024)).toStringAsFixed(2)} MB';
      });

      await compressor.cleanup(result.file);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isCompressing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Compression Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $_errorMessage'),
                ),
              ),
            if (_isCompressing) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(value: _progress),
                      const SizedBox(height: 16),
                      Text(_status),
                      const SizedBox(height: 8),
                      Text('${(_progress * 100).toInt()}%'),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isCompressing ? null : _compressVideo,
              child: Text(_isCompressing ? 'Compressing...' : 'Compress Video'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main function to run all examples
Future<void> main() async {
  print('Video Compression Examples\n');

  // Run console examples
  await example1_BasicCompression();
  print('\n' + '-' * 50 + '\n');

  await example2_CustomConfiguration();
  print('\n' + '-' * 50 + '\n');

  await example3_PredefinedConfigurations();
  print('\n' + '-' * 50 + '\n');

  await example4_WithProgressTracking();
  print('\n' + '-' * 50 + '\n');

  await example5_ConditionalCompression();
  print('\n' + '-' * 50 + '\n');

  await example6_RecommendedSettings();
  print('\n' + '-' * 50 + '\n');

  await example7_EstimateCompressedSize();
  print('\n' + '-' * 50 + '\n');

  await example8_ErrorHandling();
  print('\n' + '-' * 50 + '\n');

  await example9_BatchProcessing();
  print('\n' + '-' * 50 + '\n');

  await example10_JournalIntegration();

  // For Flutter widget example, run the app:
  // runApp(const MaterialApp(home: Example11_ProgressDialog()));
}
