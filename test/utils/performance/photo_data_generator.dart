/// Photo and image test data generator for performance testing
///
/// This utility generates realistic photo URLs and metadata for testing
/// image loading, caching, and gallery rendering performance.
class PhotoDataGenerator {
  /// Generates a list of photo URLs for testing gallery performance
  ///
  /// [count] - Number of photo URLs to generate (default: 500)
  /// [useHttps] - Whether to use HTTPS URLs (default: true)
  ///
  /// Returns a list of URLs that can be used to test image loading
  /// and caching performance. Uses placeholder image services.
  static List<String> generatePhotoUrls({
    int count = 500,
    bool useHttps = true,
  }) {
    final protocol = useHttps ? 'https' : 'http';
    return List.generate(
      count,
      (index) => '$protocol://picsum.photos/800/600?random=$index',
    );
  }

  /// Generates photo URLs with different sizes for testing responsive loading
  ///
  /// [count] - Number of photo URLs to generate
  ///
  /// Returns URLs with varying dimensions to test adaptive image loading
  /// and thumbnail generation performance.
  static List<String> generateVariableSizePhotoUrls({
    int count = 500,
  }) {
    final sizes = [
      [400, 300],
      [800, 600],
      [1200, 900],
      [1600, 1200],
      [1920, 1080],
    ];

    return List.generate(
      count,
      (index) {
        final size = sizes[index % sizes.length];
        final width = size[0];
        final height = size[1];
        return 'https://picsum.photos/$width/$height?random=$index';
      },
    );
  }

  /// Generates photo metadata for testing list rendering
  ///
  /// [count] - Number of photo metadata objects to generate
  ///
  /// Returns a list of maps containing photo metadata (URL, title, date, etc.)
  /// for testing list view performance with complex items.
  static List<Map<String, dynamic>> generatePhotoMetadata({
    int count = 500,
  }) {
    final locations = [
      'Paris',
      'Tokyo',
      'New York',
      'London',
      'Sydney',
      'Rome',
      'Barcelona',
      'Dubai',
    ];

    final categories = [
      'Landscape',
      'Portrait',
      'Architecture',
      'Food',
      'Nature',
      'Urban',
      'Beach',
      'Mountain',
    ];

    final random = _RandomSeeded(index: 0);

    return List.generate(
      count,
      (index) {
        final location = locations[random.nextInt(locations.length)];
        final category = categories[random.nextInt(categories.length)];

        return {
          'id': 'photo-$index',
          'url': 'https://picsum.photos/800/600?random=$index',
          'thumbnailUrl': 'https://picsum.photos/200/150?random=$index',
          'title': '$category in $location',
          'description':
              'A beautiful $category photo taken in $location during our travels.',
          'location': location,
          'category': category,
          'width': 800,
          'height': 600,
          'sizeBytes': 512000 + random.nextInt(2048000),
          'capturedAt': DateTime.now()
              .subtract(Duration(days: random.nextInt(365)))
              .toIso8601String(),
          'uploadedAt': DateTime.now()
              .subtract(Duration(days: random.nextInt(30)))
              .toIso8601String(),
          'isFavorite': random.nextInt(5) == 0,
          'tags': _generateTags(random, category, location),
        };
      },
    );
  }

  /// Generates photo URLs for a specific trip
  ///
  /// [tripId] - Trip ID to associate photos with
  /// [photoCount] - Number of photos to generate for this trip
  ///
  /// Returns photo URLs with trip-specific identifiers for testing
  /// trip photo gallery performance.
  static List<String> generateTripPhotoUrls({
    required String tripId,
    int photoCount = 100,
  }) {
    return List.generate(
      photoCount,
      (index) =>
          'https://picsum.photos/800/600?random=${tripId}-$index',
    );
  }

  /// Generates corrupted/invalid photo URLs for error handling tests
  ///
  /// [count] - Number of invalid URLs to generate
  ///
  /// Returns a mix of invalid URLs for testing error states and
  /// fallback behavior in image loading.
  static List<String> generateInvalidPhotoUrls({
    int count = 20,
  }) {
    return [
      ...List.generate(
        count ~/ 2,
        (index) => 'https://invalid-domain-$index.com/photo.jpg',
      ),
      ...List.generate(
        count ~/ 2,
        (index) => 'https://example.com/404-photo-$index.jpg',
      ),
    ];
  }

  /// Calculates estimated memory usage for photo list
  ///
  /// [photoCount] - Number of photos
  /// [averagePhotoSizeBytes] - Average photo size in bytes (default: 1MB)
  ///
  /// Returns estimated memory usage in bytes for caching the photos.
  static int estimateMemoryUsage({
    required int photoCount,
    int averagePhotoSizeBytes = 1024 * 1024,
  }) {
    return photoCount * averagePhotoSizeBytes;
  }

  /// Generates photo URLs with cache-busting parameters
  ///
  /// [baseUrls] - List of base URLs to add cache-busting to
  ///
  /// Returns URLs with cache-busting parameters for testing
  /// cache invalidation and reload performance.
  static List<String> generateCacheBustingUrls({
    required List<String> baseUrls,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return baseUrls.map((url) {
      final separator = url.contains('?') ? '&' : '?';
      return '$separator''v=$timestamp';
    }).toList();
  }

  // Private helper methods

  static List<String> _generateTags(
    _RandomSeeded random,
    String category,
    String location,
  ) {
    final baseTags = [category.toLowerCase(), location.toLowerCase()];

    final extraTags = [
      'travel',
      'vacation',
      'adventure',
      'solo-travel',
      'exploration',
      'wanderlust',
    ];

    final tagCount = 1 + random.nextInt(3);
    final tags = [...baseTags];

    for (int i = 0; i < tagCount; i++) {
      final tag = extraTags[random.nextInt(extraTags.length)];
      if (!tags.contains(tag)) {
        tags.add(tag);
      }
    }

    return tags;
  }
}

/// A simple seeded random number generator for reproducible test data
class _RandomSeeded {
  late int _seed;

  _RandomSeeded({required int index}) {
    _seed = index * 1337 + 42;
  }

  int nextInt(int max) {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed % max;
  }

  bool nextBool() {
    return nextInt(2) == 1;
  }
}
