import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soloadventurer/core/services/services.dart';

/// Example implementations demonstrating ImageCompressionService usage.
///
/// This file contains complete, working examples that can be used as
/// reference for implementing image compression in your app.
///
/// Run examples:
/// ```bash
/// flutter run lib/core/services/example_image_compression_service.dart
/// ```
void main() {
  runApp(const ExampleApp());
}

/// Example app with navigation to all compression examples.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Compression Service Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExampleListScreen(),
    );
  }
}

/// Screen showing list of all examples.
class ExampleListScreen extends StatelessWidget {
  const ExampleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Compression Examples'),
      ),
      body: ListView(
        children: [
          _buildExampleItem(
            context,
            title: '1. Basic Compression',
            subtitle: 'Compress a single image file',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BasicCompressionExample(),
              ),
            ),
          ),
          _buildExampleItem(
            context,
            title: '2. Compress from Bytes',
            subtitle: 'Compress image bytes (e.g., from image picker)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CompressBytesExample(),
              ),
            ),
          ),
          _buildExampleItem(
            context,
            title: '3. Batch Compression',
            subtitle: 'Compress multiple images at once',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BatchCompressionExample(),
              ),
            ),
          ),
          _buildExampleItem(
            context,
            title: '4. Use Case Presets',
            subtitle: 'Use optimized settings for specific scenarios',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UseCasePresetsExample(),
              ),
            ),
          ),
          _buildExampleItem(
            context,
            title: '5. Format Conversion',
            subtitle: 'Convert PNG to JPEG or WebP',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FormatConversionExample(),
              ),
            ),
          ),
          _buildExampleItem(
            context,
            title: '6. Custom Quality & Dimensions',
            subtitle: 'Fine-tune compression parameters',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CustomParametersExample(),
              ),
            ),
          ),
          _buildExampleItem(
            context,
            title: '7. Error Handling',
            subtitle: 'Proper error handling for production',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ErrorHandlingExample(),
              ),
            ),
          ),
          _buildExampleItem(
            context,
            title: '8. Compression Statistics',
            subtitle: 'Track and display compression metrics',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CompressionStatsExample(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}

/// Example 1: Basic file compression.
class BasicCompressionExample extends StatefulWidget {
  const BasicCompressionExample({super.key});

  @override
  State<BasicCompressionExample> createState() =>
      _BasicCompressionExampleState();
}

class _BasicCompressionExampleState extends State<BasicCompressionExample> {
  String _result = 'No image compressed yet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Compression'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Compress a single image file with default settings (85% quality, 1920x1920 max).',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _compressImage,
              child: const Text('Compress Image'),
            ),
            const SizedBox(height: 20),
            const Text('Result:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_result),
          ],
        ),
      ),
    );
  }

  Future<void> _compressImage() async {
    try {
      // For demo purposes, using a mock file path
      // In real app, use actual image file from image picker or camera
      final file = File('/path/to/image.jpg');

      // Compress with default settings
      final result = await ImageCompressionService.compressFile(
        file: file,
        quality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      setState(() {
        _result = '''
Success!
Original: ${result.formattedOriginalSize}
Compressed: ${result.formattedCompressedSize}
Savings: ${result.savingsPercentage.toStringAsFixed(1)}%
Dimensions: ${result.originalWidth}x${result.originalHeight} → ${result.compressedWidth}x${result.compressedHeight}
Output: ${result.compressedFile.path}
''';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }
}

/// Example 2: Compress image bytes.
class CompressBytesExample extends StatefulWidget {
  const CompressBytesExample({super.key});

  @override
  State<CompressBytesExample> createState() => _CompressBytesExampleState();
}

class _CompressBytesExampleState extends State<CompressBytesExample> {
  String _result = 'No bytes compressed yet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compress from Bytes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Compress image bytes directly (useful for image picker integration).',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _compressBytes,
              child: const Text('Compress Bytes'),
            ),
            const SizedBox(height: 20),
            const Text('Result:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_result),
          ],
        ),
      ),
    );
  }

  Future<void> _compressBytes() async {
    try {
      // For demo, create mock image bytes
      // In real app, get bytes from image picker or camera
      final bytes = Uint8List.fromList([/* image bytes */]);

      // Compress bytes
      final result = await ImageCompressionService.compressBytes(
        bytes: bytes,
        quality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      // Write to file or upload directly
      final compressedFile = File('/path/to/output.jpg');
      await compressedFile.writeAsBytes(result.compressedBytes);

      setState(() {
        _result = '''
Success!
Original size: ${bytes.length} bytes
Compressed size: ${result.compressedBytes.length} bytes
Dimensions: ${result.originalWidth}x${result.originalHeight} → ${result.compressedWidth}x${result.compressedHeight}
Output file: ${compressedFile.path}
''';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }
}

/// Example 3: Batch compression.
class BatchCompressionExample extends StatefulWidget {
  const BatchCompressionExample({super.key});

  @override
  State<BatchCompressionExample> createState() =>
      _BatchCompressionExampleState();
}

class _BatchCompressionExampleState extends State<BatchCompressionExample> {
  String _result = 'No batch compressed yet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Compression'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Compress multiple images efficiently in batches.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _compressBatch,
              child: const Text('Compress Batch'),
            ),
            const SizedBox(height: 20),
            const Text('Result:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_result),
          ],
        ),
      ),
    );
  }

  Future<void> _compressBatch() async {
    try {
      // Mock list of image files
      final files = [
        File('/path/to/image1.jpg'),
        File('/path/to/image2.jpg'),
        File('/path/to/image3.jpg'),
      ];

      // Compress batch
      final results = await ImageCompressionService.compressBatch(
        files: files,
        quality: 85,
        maxWidth: 1920,
      );

      // Calculate totals
      final totalOriginal = results.fold<int>(
        0,
        (sum, r) => sum + r.originalSize,
      );
      final totalCompressed = results.fold<int>(
        0,
        (sum, r) => sum + r.compressedSize,
      );
      final totalSavings = totalOriginal - totalCompressed;

      setState(() {
        _result = '''
Batch complete!
Images: ${results.length}
Total original: ${_formatBytes(totalOriginal)}
Total compressed: ${_formatBytes(totalCompressed)}
Total savings: ${_formatBytes(totalSavings)} (${((1 - totalCompressed / totalOriginal) * 100).toStringAsFixed(1)}%)
''';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Example 4: Use case presets.
class UseCasePresetsExample extends StatefulWidget {
  const UseCasePresetsExample({super.key});

  @override
  State<UseCasePresetsExample> createState() => _UseCasePresetsExampleState();
}

class _UseCasePresetsExampleState extends State<UseCasePresetsExample> {
  String _result = 'Select a use case';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Use Case Presets'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Use optimized settings for different use cases.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _compressForUseCase(ImageUseCase.profilePhoto),
              child: const Text('Profile Photo (85%, 800x800)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _compressForUseCase(ImageUseCase.photoGallery),
              child: const Text('Photo Gallery (85%, 1920x1920)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _compressForUseCase(ImageUseCase.thumbnail),
              child: const Text('Thumbnail (75%, 200x200)'),
            ),
            const SizedBox(height: 20),
            const Text('Result:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_result),
          ],
        ),
      ),
    );
  }

  Future<void> _compressForUseCase(ImageUseCase useCase) async {
    try {
      final file = File('/path/to/image.jpg');

      // Get recommended settings
      final quality = ImageCompressionService.getQualityForUseCase(useCase);
      final dimensions =
          ImageCompressionService.getDimensionsForUseCase(useCase);

      // Compress with use case settings
      final result = await ImageCompressionService.compressFile(
        file: file,
        quality: quality,
        maxWidth: dimensions.width,
        maxHeight: dimensions.height,
      );

      setState(() {
        _result = '''
Use Case: ${useCase.name}
Quality: $quality%
Dimensions: ${dimensions.width}x${dimensions.height}
Savings: ${result.savingsPercentage.toStringAsFixed(1)}%
''';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }
}

/// Example 5: Format conversion.
class FormatConversionExample extends StatefulWidget {
  const FormatConversionExample({super.key});

  @override
  State<FormatConversionExample> createState() =>
      _FormatConversionExampleState();
}

class _FormatConversionExampleState extends State<FormatConversionExample> {
  String _result = 'Select a format';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Format Conversion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Convert between image formats for better compression.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _convertFormat(ImageFormat.jpeg),
              child: const Text('Convert to JPEG'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _convertFormat(ImageFormat.png),
              child: const Text('Convert to PNG'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _convertFormat(ImageFormat.webp),
              child: const Text('Convert to WebP'),
            ),
            const SizedBox(height: 20),
            const Text('Result:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_result),
          ],
        ),
      ),
    );
  }

  Future<void> _convertFormat(ImageFormat format) async {
    try {
      final file = File('/path/to/image.png');

      // Compress with target format
      final result = await ImageCompressionService.compressFile(
        file: file,
        quality: 85,
        targetFormat: format,
      );

      setState(() {
        _result = '''
Format: ${format.name.toUpperCase()}
Original: ${result.formattedOriginalSize}
Compressed: ${result.formattedCompressedSize}
Savings: ${result.savingsPercentage.toStringAsFixed(1)}%
Output: ${result.compressedFile.path}
''';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }
}

/// Example 6: Custom parameters.
class CustomParametersExample extends StatefulWidget {
  const CustomParametersExample({super.key});

  @override
  State<CustomParametersExample> createState() =>
      _CustomParametersExampleState();
}

class _CustomParametersExampleState extends State<CustomParametersExample> {
  double _quality = 85.0;
  double _maxWidth = 1920.0;
  double _maxHeight = 1920.0;
  String _result = 'Adjust parameters and compress';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Parameters'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Fine-tune compression parameters.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text('Quality: ${_quality.toInt()}%'),
            Slider(
              value: _quality,
              min: 10,
              max: 100,
              divisions: 90,
              onChanged: (value) => setState(() => _quality = value),
            ),
            const SizedBox(height: 10),
            Text('Max Width: ${_maxWidth.toInt()}px'),
            Slider(
              value: _maxWidth,
              min: 100,
              max: 4096,
              divisions: 39,
              onChanged: (value) => setState(() => _maxWidth = value),
            ),
            const SizedBox(height: 10),
            Text('Max Height: ${_maxHeight.toInt()}px'),
            Slider(
              value: _maxHeight,
              min: 100,
              max: 4096,
              divisions: 39,
              onChanged: (value) => setState(() => _maxHeight = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _compressWithCustomParams,
              child: const Text('Compress'),
            ),
            const SizedBox(height: 20),
            const Text('Result:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_result),
          ],
        ),
      ),
    );
  }

  Future<void> _compressWithCustomParams() async {
    try {
      final file = File('/path/to/image.jpg');

      final result = await ImageCompressionService.compressFile(
        file: file,
        quality: _quality.toInt(),
        maxWidth: _maxWidth.toInt(),
        maxHeight: _maxHeight.toInt(),
      );

      setState(() {
        _result = '''
Quality: ${result.quality}%
Max Dimensions: ${_maxWidth.toInt()}x${_maxHeight.toInt()}
Actual Dimensions: ${result.compressedWidth}x${result.compressedHeight}
Savings: ${result.savingsPercentage.toStringAsFixed(1)}%
''';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }
}

/// Example 7: Error handling.
class ErrorHandlingExample extends StatefulWidget {
  const ErrorHandlingExample({super.key});

  @override
  State<ErrorHandlingExample> createState() => _ErrorHandlingExampleState();
}

class _ErrorHandlingExampleState extends State<ErrorHandlingExample> {
  String _result = 'Press button to simulate error';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Handling'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Proper error handling for production apps.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _demonstrateErrorHandling,
              child: const Text('Demonstrate Error Handling'),
            ),
            const SizedBox(height: 20),
            const Text('Result:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_result),
          ],
        ),
      ),
    );
  }

  Future<void> _demonstrateErrorHandling() async {
    try {
      // Try to compress non-existent file
      final file = File('/path/to/nonexistent.jpg');

      final result = await ImageCompressionService.compressFile(
        file: file,
        quality: 85,
      );

      setState(() {
        _result = 'Success: ${result.compressedFile.path}';
      });
    } on CompressionException catch (e) {
      // Handle compression-specific errors
      setState(() {
        _result = 'Compression Error: ${e.message}\n\n'
            'Action: Show error to user, allow retry with different file';
      });
    } on FileSystemException catch (e) {
      // Handle file system errors
      setState(() {
        _result = 'File System Error: ${e.message}\n\n'
            'Action: Check file permissions, ensure file exists';
      });
    } catch (e) {
      // Handle unexpected errors
      setState(() {
        _result = 'Unexpected Error: $e\n\n'
            'Action: Log error, show generic error message';
      });
    }
  }
}

/// Example 8: Compression statistics.
class CompressionStatsExample extends StatefulWidget {
  const CompressionStatsExample({super.key});

  @override
  State<CompressionStatsExample> createState() =>
      _CompressionStatsExampleState();
}

class _CompressionStatsExampleState extends State<CompressionStatsExample> {
  String _result = 'Compress multiple images to see statistics';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compression Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Track and display compression metrics across multiple images.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showStatistics,
              child: const Text('Compress & Show Statistics'),
            ),
            const SizedBox(height: 20),
            const Text('Statistics:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_result),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStatistics() async {
    try {
      // Mock multiple image files
      final files = List.generate(
        10,
        (i) => File('/path/to/image$i.jpg'),
      );

      // Compress batch
      final results = await ImageCompressionService.compressBatch(
        files: files,
        quality: 85,
      );

      // Calculate statistics
      final totalOriginal = results.fold<int>(
        0,
        (sum, r) => sum + r.originalSize,
      );
      final totalCompressed = results.fold<int>(
        0,
        (sum, r) => sum + r.compressedSize,
      );
      final avgSavings = results.fold<double>(
            0,
            (sum, r) => sum + r.savingsPercentage,
          ) /
          results.length;
      final maxSavings = results
          .map((r) => r.savingsPercentage)
          .reduce((a, b) => a > b ? a : b);
      final minSavings = results
          .map((r) => r.savingsPercentage)
          .reduce((a, b) => a < b ? a : b);

      setState(() {
        _result = '''
=== Compression Statistics ===

Images Compressed: ${results.length}

Total Original Size: ${_formatBytes(totalOriginal)}
Total Compressed Size: ${_formatBytes(totalCompressed)}
Total Savings: ${_formatBytes(totalOriginal - totalCompressed)}

Average Savings: ${avgSavings.toStringAsFixed(1)}%
Best Savings: ${maxSavings.toStringAsFixed(1)}%
Worst Savings: ${minSavings.toStringAsFixed(1)}%

Compression Ratio: ${(totalCompressed / totalOriginal).toStringAsFixed(2)}x

Detailed Results:
${results.asMap().entries.map((entry) {
          final i = entry.key;
          final r = entry.value;
          return 'Image ${i + 1}: ${r.formattedOriginalSize} → ${r.formattedCompressedSize} (${r.savingsPercentage.toStringAsFixed(1)}%)';
        }).join('\n')}
''';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
