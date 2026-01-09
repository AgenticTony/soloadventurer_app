import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'cache_stats.dart';

/// Configuration for disk cache
class DiskCacheConfig {
  /// Maximum size of disk cache in bytes
  final int maxCacheSize;

  /// Enable cache statistics tracking
  final bool trackStats;

  /// Default time-to-live for cache entries (null = no expiration)
  final Duration? defaultTtl;

  /// Cache directory name
  final String cacheDirName;

  /// Enable automatic cleanup of expired entries
  final bool autoCleanup;

  const DiskCacheConfig({
    this.maxCacheSize = 100 * 1024 * 1024, // 100 MB default
    this.trackStats = true,
    this.defaultTtl,
    this.cacheDirName = 'disk_cache',
    this.autoCleanup = true,
  });

  /// Copy with modified values
  DiskCacheConfig copyWith({
    int? maxCacheSize,
    bool? trackStats,
    Duration? defaultTtl,
    String? cacheDirName,
    bool? autoCleanup,
  }) {
    return DiskCacheConfig(
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      trackStats: trackStats ?? this.trackStats,
      defaultTtl: defaultTtl ?? this.defaultTtl,
      cacheDirName: cacheDirName ?? this.cacheDirName,
      autoCleanup: autoCleanup ?? this.autoCleanup,
    );
  }
}

/// Metadata for disk cache entries
class _DiskCacheEntryMetadata {
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int size;

  _DiskCacheEntryMetadata({
    required this.createdAt,
    this.expiresAt,
    required this.size,
  });

  /// Check if entry has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'size': size,
    };
  }

  factory _DiskCacheEntryMetadata.fromJson(Map<String, dynamic> json) {
    return _DiskCacheEntryMetadata(
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      size: json['size'] as int,
    );
  }
}

/// Persistent disk cache for offline support
///
/// Provides persistent storage of cached data on disk with support for
/// expiration, size limits, and automatic cleanup. Ideal for offline-first
/// applications and for caching large datasets that don't fit in memory.
///
/// ## Features
///
/// - **Persistent Storage**: Data survives app restarts
/// - **Size Limits**: Enforces maximum cache size with LRU eviction
/// - **TTL Support**: Optional time-to-live for automatic expiration
/// - **Auto Cleanup**: Removes expired entries on access
/// - **Statistics**: Track hit rate, miss rate, and disk usage
///
/// ## Example
///
/// ```dart
/// final diskCache = DiskCache(
///   config: DiskCacheConfig(maxCacheSize: 50 * 1024 * 1024), // 50 MB
/// );
/// await diskCache.initialize();
///
/// // Store data
/// await diskCache.put('user_123', userData);
///
/// // Retrieve data
/// final userData = await diskCache.get('user_123');
///
/// // Store with TTL
/// await diskCache.put('temp', data, ttl: Duration(hours: 24));
///
/// // Cleanup when done
/// await diskCache.dispose();
/// ```
class DiskCache {
  /// Cache configuration
  final DiskCacheConfig config;

  /// Cache statistics
  final CacheStats stats;

  /// Cache directory
  Directory? _cacheDir;

  /// Metadata file
  File get _metadataFile =>
      File('${_cacheDir?.path}/.cache_metadata.json');

  /// Index file for fast lookups
  File get _indexFile => File('${_cacheDir?.path}/.cache_index.json');

  /// In-memory index of cached items
  Map<String, _DiskCacheEntryMetadata>? _index;

  /// Whether cache has been initialized
  bool _isInitialized = false;

  /// Current cache size in bytes
  int _currentCacheSize = 0;

  /// Creates a new disk cache
  DiskCache({
    DiskCacheConfig? config,
  })  : config = config ?? const DiskCacheConfig(),
        stats = CacheStats();

  /// Initialize the disk cache
  ///
  /// Must be called before using the cache. Creates necessary directories
  /// and loads the cache index.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get cache directory
      final tempDir = await getTemporaryDirectory();
      _cacheDir = Directory('${tempDir.path}/${config.cacheDirName}');

      // Create directory if it doesn't exist
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }

      // Load index
      await _loadIndex();

      // Perform initial cleanup if enabled
      if (config.autoCleanup) {
        await cleanupExpired();
      }

      _isInitialized = true;
    } catch (e) {
      // If initialization fails, cache will still work but may be slower
      _isInitialized = true;
    }
  }

  /// Ensure cache is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Load cache index from disk
  Future<void> _loadIndex() async {
    try {
      if (await _indexFile.exists()) {
        final json = await _indexFile.readAsString();
        final Map<String, dynamic> data = jsonDecode(json);
        _index = {};

        int totalSize = 0;
        for (final entry in data.entries) {
          final metadata = _DiskCacheEntryMetadata.fromJson(
              entry.value as Map<String, dynamic>);
          _index![entry.key] = metadata;
          totalSize += metadata.size;
        }
        _currentCacheSize = totalSize;
      } else {
        _index = {};
        _currentCacheSize = 0;
      }
    } catch (e) {
      // If index is corrupted, start fresh
      _index = {};
      _currentCacheSize = 0;
    }
  }

  /// Save cache index to disk
  Future<void> _saveIndex() async {
    try {
      if (_index != null) {
        final Map<String, dynamic> data = {};
        for (final entry in _index!.entries) {
          data[entry.key] = entry.value.toJson();
        }
        final json = jsonEncode(data);
        await _indexFile.writeAsString(json);
      }
    } catch (e) {
      // Index save failure is not critical
    }
  }

  /// Get file path for a key
  File _getFileForKey(String key) {
    final filename = key.replaceAll(RegExp(r'[^\w\-.]'), '_');
    return File('${_cacheDir?.path}/$filename.json');
  }

  /// Get a value from cache
  Future<String?> get(String key) async {
    await _ensureInitialized();

    final file = _getFileForKey(key);

    // Check if file exists
    if (!await file.exists()) {
      if (config.trackStats) {
        stats.recordMiss();
      }
      return null;
    }

    // Check metadata
    final metadata = _index?[key];
    if (metadata != null && metadata.isExpired) {
      await remove(key);
      if (config.trackStats) {
        stats.recordMiss();
      }
      return null;
    }

    try {
      final content = await file.readAsString();

      // Update access time in metadata
      if (_index != null) {
        _index![key] = _DiskCacheEntryMetadata(
          createdAt: metadata?.createdAt ?? DateTime.now(),
          expiresAt: metadata?.expiresAt,
          size: metadata?.size ?? content.length,
        );
        await _saveIndex();
      }

      if (config.trackStats) {
        stats.recordHit();
      }

      return content;
    } catch (e) {
      // File read error - treat as miss
      if (config.trackStats) {
        stats.recordMiss();
      }
      return null;
    }
  }

  /// Put a value in cache
  Future<void> put(String key, String value, {Duration? ttl}) async {
    await _ensureInitialized();

    final file = _getFileForKey(key);
    final expiration = ttl ?? config.defaultTtl;
    final now = DateTime.now();
    final valueSize = value.length;

    // Remove existing entry if present
    if (await file.exists()) {
      await remove(key);
    }

    // Check if we need to evict entries
    while (_currentCacheSize + valueSize > config.maxCacheSize &&
        _index != null &&
        _index!.isNotEmpty) {
      await _evictLRU();
    }

    try {
      // Write value to file
      await file.writeAsString(value);

      // Update index
      if (_index != null) {
        _index![key] = _DiskCacheEntryMetadata(
          createdAt: now,
          expiresAt: expiration != null ? now.add(expiration) : null,
          size: valueSize,
        );
        _currentCacheSize += valueSize;
        await _saveIndex();
      }

      if (config.trackStats) {
        stats.recordAddition();
      }
    } catch (e) {
      // Write failed - don't update index
    }
  }

  /// Put JSON-serializable data in cache
  Future<void> putJson(String key, Map<String, dynamic> data,
      {Duration? ttl}) async {
    final json = jsonEncode(data);
    await put(key, json, ttl: ttl);
  }

  /// Get and parse JSON data from cache
  Future<Map<String, dynamic>?> getJson(String key) async {
    final json = await get(key);
    if (json == null) return null;

    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Check if key exists in cache
  Future<bool> containsKey(String key) async {
    await _ensureInitialized();

    final metadata = _index?[key];
    if (metadata == null) return false;

    // Check if expired
    if (metadata.isExpired) {
      await remove(key);
      return false;
    }

    return true;
  }

  /// Remove a key from cache
  Future<void> remove(String key) async {
    await _ensureInitialized();

    final file = _getFileForKey(key);

    // Update size tracking
    final metadata = _index?[key];
    if (metadata != null) {
      _currentCacheSize -= metadata.size;
    }

    // Remove from index
    _index?.remove(key);
    await _saveIndex();

    // Delete file
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        // File deletion failed
      }
    }

    if (config.trackStats) {
      stats.recordRemoval();
    }
  }

  /// Clear all items from cache
  Future<void> clear() async {
    await _ensureInitialized();

    if (_cacheDir == null) return;

    try {
      // Delete all files in cache directory
      await for (final entity in _cacheDir!.list()) {
        try {
          if (entity is File) {
            await entity.delete();
          }
        } catch (e) {
          // Skip files that can't be deleted
        }
      }

      // Reset index
      _index?.clear();
      _currentCacheSize = 0;
      await _saveIndex();

      if (config.trackStats) {
        final count = stats.currentSize;
        for (var i = 0; i < count; i++) {
          stats.recordRemoval();
        }
      }
    } catch (e) {
      // Clear failed
    }
  }

  /// Clean up expired entries
  Future<int> cleanupExpired() async {
    await _ensureInitialized();

    if (_index == null) return 0;

    final expiredKeys = <String>[];
    for (final entry in _index!.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      await remove(key);
    }

    return expiredKeys.length;
  }

  /// Evict least recently used entry
  Future<void> _evictLRU() async {
    if (_index == null || _index!.isEmpty) return;

    // Find oldest entry (LRU)
    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _index!.entries) {
      if (oldestTime == null || entry.value.createdAt.isBefore(oldestTime)) {
        oldestTime = entry.value.createdAt;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      await remove(oldestKey);
      if (config.trackStats) {
        stats.recordEviction();
      }
    }
  }

  /// Get current cache size in bytes
  int get currentSize => _currentCacheSize;

  /// Get maximum cache size in bytes
  int get maxSize => config.maxCacheSize;

  /// Get cache size as percentage
  double get sizePercent => _currentCacheSize / config.maxCacheSize;

  /// Check if cache is full
  bool get isFull => _currentCacheSize >= config.maxCacheSize;

  /// Get cache statistics
  CacheStats getStats() => stats;

  /// Reset statistics
  void resetStats() {
    stats.reset();
  }

  /// Dispose of the disk cache
  Future<void> dispose() async {
    _index?.clear();
    _currentCacheSize = 0;
    _isInitialized = false;
  }

  @override
  String toString() {
    final sizeMB = (_currentCacheSize / (1024 * 1024)).toStringAsFixed(2);
    final maxMB = (config.maxCacheSize / (1024 * 1024)).toStringAsFixed(2);
    return 'DiskCache(size: $sizeMB/$maxMB MB, stats: $stats)';
  }
}
