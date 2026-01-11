import 'dart:math';
import 'dart:typed_data';

/// Generates photo-related test data for performance testing.
///
/// Usage:
/// ```dart
/// final bytes = PhotoDataGenerator.generateImageBytes(size: 1024);
/// final metadata = PhotoDataGenerator.generatePhotoMetadata();
/// ```
class PhotoDataGenerator {
  PhotoDataGenerator._();

  static final _random = Random();

  /// Generate random bytes simulating image data
  static Uint8List generateImageBytes({int size = 1024}) {
    return Uint8List.fromList(
      List.generate(size, (_) => _random.nextInt(256)),
    );
  }

  /// Generate a mock photo file path
  static String generatePhotoPath({String extension = 'jpg'}) {
    final id = _random.nextInt(999999);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '/test/photos/photo_${timestamp}_$id.$extension';
  }

  /// Generate photo metadata
  static Map<String, dynamic> generatePhotoMetadata() {
    final resolutions = [
      (1920, 1080),
      (2048, 1536),
      (3840, 2160),
      (4096, 2304),
    ];
    final res = resolutions[_random.nextInt(resolutions.length)];

    return {
      'id':
          'photo-${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(999999)}',
      'path': generatePhotoPath(),
      'width': res.$1,
      'height': res.$2,
      'format': ['jpeg', 'png', 'webp', 'heic'][_random.nextInt(4)],
      'size': _random.nextInt(10000000) + 100000, // 100KB - 10MB
      'createdAt': DateTime.now()
          .subtract(Duration(days: _random.nextInt(365)))
          .toIso8601String(),
      'location': {
        'latitude': -90 + _random.nextDouble() * 180,
        'longitude': -180 + _random.nextDouble() * 360,
      },
      'exif': generateExifData(),
    };
  }

  /// Generate mock EXIF data
  static Map<String, dynamic> generateExifData() {
    final cameras = [
      'iPhone 15 Pro',
      'iPhone 14',
      'Pixel 8 Pro',
      'Samsung S24 Ultra',
      'Canon EOS R5',
      'Sony A7 IV',
    ];
    final apertures = ['f/1.8', 'f/2.0', 'f/2.8', 'f/4.0', 'f/5.6'];
    final isoValues = [100, 200, 400, 800, 1600, 3200];
    final shutterSpeeds = [
      '1/60',
      '1/125',
      '1/250',
      '1/500',
      '1/1000',
      '1/2000'
    ];

    return {
      'camera': cameras[_random.nextInt(cameras.length)],
      'aperture': apertures[_random.nextInt(apertures.length)],
      'iso': isoValues[_random.nextInt(isoValues.length)],
      'shutterSpeed': shutterSpeeds[_random.nextInt(shutterSpeeds.length)],
      'focalLength': '${[24, 35, 50, 85, 100, 200][_random.nextInt(6)]}mm',
      'flash': _random.nextBool(),
    };
  }

  /// Generate a batch of photo metadata
  static List<Map<String, dynamic>> generatePhotoBatch(int count) {
    return List.generate(count, (_) => generatePhotoMetadata());
  }

  /// Generate thumbnail data (smaller than full image)
  static Uint8List generateThumbnail({int width = 150, int height = 150}) {
    return generateImageBytes(size: (width * height * 3) ~/ 10);
  }
}
