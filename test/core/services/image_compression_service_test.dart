import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:soloadventurer/core/services/image_compression_service.dart';

void main() {
  group('ImageCompressionService', () {
    group('compressFile', () {
      test('compresses image file and returns result', () async {
        // Create a test image
        final testImage = img.Image(width: 2000, height: 2000);
        final testBytes = Uint8List.fromList(img.encodeJpg(testImage));

        final tempDir = Directory.systemTemp;
        final testFile = File('${tempDir.path}/test_image.jpg');
        await testFile.writeAsBytes(testBytes);

        try {
          final result = await ImageCompressionService.compressFile(
            file: testFile,
            quality: 85,
            maxWidth: 1920,
            maxHeight: 1920,
          );

          expect(result.success, true);
          expect(result.compressedFile.existsSync(), true);
          expect(result.compressedSize, lessThan(result.originalSize));
          expect(result.savingsPercentage, greaterThan(0));
          expect(result.quality, equals(85));
          expect(result.originalWidth, equals(2000));
          expect(result.originalHeight, equals(2000));
        } finally {
          // Clean up
          if (await testFile.exists()) {
            await testFile.delete();
          }
        }
      });

      test('throws CompressionException for non-existent file', () async {
        final nonExistentFile = File('/path/to/nonexistent.jpg');

        expect(
          () => ImageCompressionService.compressFile(
            file: nonExistentFile,
            quality: 85,
          ),
          throwsA(isA<CompressionException>()),
        );
      });

      test('respects custom output path', () async {
        final testImage = img.Image(width: 1000, height: 1000);
        final testBytes = Uint8List.fromList(img.encodeJpg(testImage));

        final tempDir = Directory.systemTemp;
        final testFile = File('${tempDir.path}/test_input.jpg');
        await testFile.writeAsBytes(testBytes);

        final customOutput = File('${tempDir.path}/custom_output.jpg');

        try {
          final result = await ImageCompressionService.compressFile(
            file: testFile,
            quality: 85,
            outputPath: customOutput.path,
          );

          expect(result.compressedFile.path, equals(customOutput.path));
          expect(await customOutput.exists(), true);
        } finally {
          // Clean up
          if (await testFile.exists()) {
            await testFile.delete();
          }
          if (await customOutput.exists()) {
            await customOutput.delete();
          }
        }
      });

      test('converts PNG to JPEG', () async {
        final testImage = img.Image(width: 1000, height: 1000);
        final testBytes = Uint8List.fromList(img.encodePng(testImage));

        final tempDir = Directory.systemTemp;
        final testFile = File('${tempDir.path}/test_image.png');
        await testFile.writeAsBytes(testBytes);

        try {
          final result = await ImageCompressionService.compressFile(
            file: testFile,
            quality: 85,
            targetFormat: ImageFormat.jpeg,
          );

          expect(result.format, equals(ImageFormat.jpeg));
          expect(result.compressedFile.path.endsWith('.jpg'), true);
        } finally {
          // Clean up
          if (await testFile.exists()) {
            await testFile.delete();
          }
          final compressedFile =
              File('${tempDir.path}/test_image_compressed.jpg');
          if (await compressedFile.exists()) {
            await compressedFile.delete();
          }
        }
      });

      test('throws exception for invalid quality', () async {
        final testImage = img.Image(width: 1000, height: 1000);
        final testBytes = Uint8List.fromList(img.encodeJpg(testImage));

        final tempDir = Directory.systemTemp;
        final testFile = File('${tempDir.path}/test_image.jpg');
        await testFile.writeAsBytes(testBytes);

        try {
          expect(
            () => ImageCompressionService.compressFile(
              file: testFile,
              quality: 150, // Invalid quality
            ),
            throwsA(isA<CompressionException>()),
          );
        } finally {
          // Clean up
          if (await testFile.exists()) {
            await testFile.delete();
          }
        }
      });
    });

    group('compressBytes', () {
      test('compresses image bytes and returns data', () async {
        final testImage = img.Image(width: 2000, height: 2000);
        final testBytes =
            Uint8List.fromList(img.encodeJpg(testImage, quality: 95));

        final result = await ImageCompressionService.compressBytes(
          bytes: testBytes,
          quality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        );

        expect(result.compressedBytes.isNotEmpty, true);
        expect(result.compressedBytes.length, lessThan(testBytes.length));
        expect(result.originalWidth, equals(2000));
        expect(result.originalHeight, equals(2000));
        expect(result.compressedWidth, lessThanOrEqualTo(1920));
        expect(result.compressedHeight, lessThanOrEqualTo(1920));
      });

      test('resizes image if dimensions exceed max', () async {
        final testImage = img.Image(width: 3000, height: 3000);
        final testBytes = Uint8List.fromList(img.encodeJpg(testImage));

        final result = await ImageCompressionService.compressBytes(
          bytes: testBytes,
          quality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        );

        expect(result.compressedWidth, lessThanOrEqualTo(1920));
        expect(result.compressedHeight, lessThanOrEqualTo(1920));
      });

      test('maintains aspect ratio when resizing', () async {
        // Wide image
        final wideImage = img.Image(width: 4000, height: 1000);
        final wideBytes = Uint8List.fromList(img.encodeJpg(wideImage));

        final wideResult = await ImageCompressionService.compressBytes(
          bytes: wideBytes,
          quality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        );

        // Aspect ratio should be maintained (4:1)
        final aspectRatio =
            wideResult.compressedWidth / wideResult.compressedHeight;
        expect(aspectRatio, closeTo(4.0, 0.1));

        // Tall image
        final tallImage = img.Image(width: 1000, height: 4000);
        final tallBytes = Uint8List.fromList(img.encodeJpg(tallImage));

        final tallResult = await ImageCompressionService.compressBytes(
          bytes: tallBytes,
          quality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        );

        // Aspect ratio should be maintained (1:4)
        final tallAspectRatio =
            tallResult.compressedWidth / tallResult.compressedHeight;
        expect(tallAspectRatio, closeTo(0.25, 0.1));
      });

      test('supports WebP format', () async {
        final testImage = img.Image(width: 1000, height: 1000);
        final testBytes = Uint8List.fromList(img.encodeJpg(testImage));

        final result = await ImageCompressionService.compressBytes(
          bytes: testBytes,
          quality: 85,
          targetFormat: ImageFormat.webp,
        );

        expect(result.compressedBytes.isNotEmpty, true);
        // WebP typically has better compression than JPEG
        expect(result.compressedBytes.length, lessThan(testBytes.length));
      });

      test('throws exception for invalid quality', () {
        final testBytes = Uint8List.fromList([0, 1, 2, 3]);

        expect(
          () => ImageCompressionService.compressBytes(
            bytes: testBytes,
            quality: -10, // Invalid quality
          ),
          throwsA(isA<CompressionException>()),
        );
      });
    });

    group('compressBatch', () {
      test('compresses multiple images', () async {
        // Create test files
        final tempDir = Directory.systemTemp;
        final files = <File>[];

        for (int i = 0; i < 3; i++) {
          final testImage = img.Image(width: 1000, height: 1000);
          final testBytes = Uint8List.fromList(img.encodeJpg(testImage));
          final testFile = File('${tempDir.path}/test_image_$i.jpg');
          await testFile.writeAsBytes(testBytes);
          files.add(testFile);
        }

        try {
          final results = await ImageCompressionService.compressBatch(
            files: files,
            quality: 85,
          );

          expect(results.length, equals(3));
          for (final result in results) {
            expect(result.success, true);
            expect(result.savingsPercentage, greaterThan(0));
          }
        } finally {
          // Clean up
          for (final file in files) {
            if (await file.exists()) {
              await file.delete();
            }
          }
          // Clean up compressed files
          for (int i = 0; i < 3; i++) {
            final compressedFile =
                File('${tempDir.path}/test_image_${i}_compressed.jpg');
            if (await compressedFile.exists()) {
              await compressedFile.delete();
            }
          }
        }
      });

      test('calculates total savings correctly', () async {
        final tempDir = Directory.systemTemp;
        final files = <File>[];

        for (int i = 0; i < 2; i++) {
          final testImage = img.Image(width: 1000, height: 1000);
          final testBytes = Uint8List.fromList(img.encodeJpg(testImage));
          final testFile = File('${tempDir.path}/test_image_$i.jpg');
          await testFile.writeAsBytes(testBytes);
          files.add(testFile);
        }

        try {
          final results = await ImageCompressionService.compressBatch(
            files: files,
            quality: 85,
          );

          final totalOriginal = results.fold<int>(
            0,
            (sum, r) => sum + r.originalSize,
          );
          final totalCompressed = results.fold<int>(
            0,
            (sum, r) => sum + r.compressedSize,
          );

          expect(totalCompressed, lessThan(totalOriginal));
        } finally {
          // Clean up
          for (final file in files) {
            if (await file.exists()) {
              await file.delete();
            }
          }
        }
      });
    });

    group('getQualityForUseCase', () {
      test('returns correct quality for high quality use case', () {
        final quality = ImageCompressionService.getQualityForUseCase(
          ImageUseCase.highQuality,
        );
        expect(quality, equals(95));
      });

      test('returns correct quality for profile photo use case', () {
        final quality = ImageCompressionService.getQualityForUseCase(
          ImageUseCase.profilePhoto,
        );
        expect(quality, equals(85));
      });

      test('returns correct quality for photo gallery use case', () {
        final quality = ImageCompressionService.getQualityForUseCase(
          ImageUseCase.photoGallery,
        );
        expect(quality, equals(85));
      });

      test('returns correct quality for shared photo use case', () {
        final quality = ImageCompressionService.getQualityForUseCase(
          ImageUseCase.sharedPhoto,
        );
        expect(quality, equals(80));
      });

      test('returns correct quality for thumbnail use case', () {
        final quality = ImageCompressionService.getQualityForUseCase(
          ImageUseCase.thumbnail,
        );
        expect(quality, equals(75));
      });

      test('returns correct quality for avatar use case', () {
        final quality = ImageCompressionService.getQualityForUseCase(
          ImageUseCase.avatar,
        );
        expect(quality, equals(70));
      });
    });

    group('getDimensionsForUseCase', () {
      test('returns correct dimensions for high quality use case', () {
        final dimensions = ImageCompressionService.getDimensionsForUseCase(
          ImageUseCase.highQuality,
        );
        expect(dimensions.width, equals(2048));
        expect(dimensions.height, equals(2048));
      });

      test('returns correct dimensions for profile photo use case', () {
        final dimensions = ImageCompressionService.getDimensionsForUseCase(
          ImageUseCase.profilePhoto,
        );
        expect(dimensions.width, equals(800));
        expect(dimensions.height, equals(800));
      });

      test('returns correct dimensions for photo gallery use case', () {
        final dimensions = ImageCompressionService.getDimensionsForUseCase(
          ImageUseCase.photoGallery,
        );
        expect(dimensions.width, equals(1920));
        expect(dimensions.height, equals(1920));
      });

      test('returns correct dimensions for shared photo use case', () {
        final dimensions = ImageCompressionService.getDimensionsForUseCase(
          ImageUseCase.sharedPhoto,
        );
        expect(dimensions.width, equals(1200));
        expect(dimensions.height, equals(1200));
      });

      test('returns correct dimensions for thumbnail use case', () {
        final dimensions = ImageCompressionService.getDimensionsForUseCase(
          ImageUseCase.thumbnail,
        );
        expect(dimensions.width, equals(200));
        expect(dimensions.height, equals(200));
      });

      test('returns correct dimensions for avatar use case', () {
        final dimensions = ImageCompressionService.getDimensionsForUseCase(
          ImageUseCase.avatar,
        );
        expect(dimensions.width, equals(150));
        expect(dimensions.height, equals(150));
      });
    });

    group('CompressionResult', () {
      test('calculates savings correctly', () {
        const result = CompressionResult(
          originalFile: File('/path/to/original.jpg'),
          compressedFile: File('/path/to/compressed.jpg'),
          originalSize: 1000,
          compressedSize: 200,
          originalWidth: 2000,
          originalHeight: 2000,
          compressedWidth: 1920,
          compressedHeight: 1920,
          quality: 85,
          format: ImageFormat.jpeg,
          success: true,
        );

        expect(result.savings, equals(800));
        expect(result.savingsPercentage, closeTo(80.0, 0.1));
      });

      test('formats sizes correctly', () {
        const result = CompressionResult(
          originalFile: File('/path/to/original.jpg'),
          compressedFile: File('/path/to/compressed.jpg'),
          originalSize: 1024,
          compressedSize: 512,
          originalWidth: 2000,
          originalHeight: 2000,
          compressedWidth: 1920,
          compressedHeight: 1920,
          quality: 85,
          format: ImageFormat.jpeg,
          success: true,
        );

        expect(result.formattedOriginalSize, contains('KB'));
        expect(result.formattedCompressedSize, contains('KB'));
        expect(result.formattedSavings, contains('KB'));
      });

      test('handles zero original size', () {
        const result = CompressionResult(
          originalFile: File('/path/to/original.jpg'),
          compressedFile: File('/path/to/compressed.jpg'),
          originalSize: 0,
          compressedSize: 0,
          originalWidth: 2000,
          originalHeight: 2000,
          compressedWidth: 1920,
          compressedHeight: 1920,
          quality: 85,
          format: ImageFormat.jpeg,
          success: true,
        );

        expect(result.savingsPercentage, equals(0));
      });
    });

    group('ImageCompressionData', () {
      test('stores compression data correctly', () {
        final compressedBytes = Uint8List.fromList([1, 2, 3, 4]);
        const data = ImageCompressionData(
          compressedBytes: compressedBytes,
          originalWidth: 2000,
          originalHeight: 2000,
          compressedWidth: 1920,
          compressedHeight: 1920,
        );

        expect(data.compressedBytes, equals(compressedBytes));
        expect(data.originalWidth, equals(2000));
        expect(data.originalHeight, equals(2000));
        expect(data.compressedWidth, equals(1920));
        expect(data.compressedHeight, equals(1920));
      });
    });

    group('CompressionException', () {
      test('stores message correctly', () {
        const exception = CompressionException('Test error message');
        expect(exception.message, equals('Test error message'));
        expect(exception.toString(), contains('Test error message'));
      });
    });

    group('ImageDimensions', () {
      test('stores dimensions correctly', () {
        const dimensions = ImageDimensions(1920, 1080);
        expect(dimensions.width, equals(1920));
        expect(dimensions.height, equals(1080));
        expect(dimensions.toString(), equals('1920x1080'));
      });
    });
  });
}
