import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'memory_monitor.dart';

/// Data priority level for unload decisions
///
/// Higher priority data is kept in memory longer during memory pressure.
/// Critical data should almost never be unloaded (e.g., user's current trip).
enum DataPriority {
  /// Critical data - should rarely be unloaded (user's current view, active trip)
  critical,

  /// High priority data - important but not immediately visible (nearby list items)
  high,

  /// Normal priority data - recently viewed but not currently visible
  normal,

  /// Low priority data - can be unloaded first (background data, old sessions)
  low,
}

/// Data entry that can be tracked and unloaded
class DataEntry {
  /// Unique identifier for this data entry
  final String id;

  /// Data type (e.g., 'trip', 'activity', 'photo', 'map_markers')
  final String dataType;

  /// Priority level for unload decisions
  final DataPriority priority;

  /// Estimated memory size in bytes (optional, for better unload decisions)
  final int? estimatedSizeBytes;

  /// Whether this data is currently visible on screen
  bool isVisible;

  /// Last time this data was accessed
  DateTime lastAccessTime;

  /// Optional callback to unload this data
  final Future<void> Function()? unloadCallback;

  /// Optional metadata
  final Map<String, dynamic>? metadata;

  DataEntry({
    required this.id,
    required this.dataType,
    required this.priority,
    this.estimatedSizeBytes,
    this.isVisible = false,
    DateTime? lastAccessTime,
    this.unloadCallback,
    this.metadata,
  }) : lastAccessTime = lastAccessTime ?? DateTime.now();

  /// Copy with modified values
  DataEntry copyWith({
    String? id,
    String? dataType,
    DataPriority? priority,
    int? estimatedSizeBytes,
    bool? isVisible,
    DateTime? lastAccessTime,
    Future<void> Function()? unloadCallback,
    Map<String, dynamic>? metadata,
  }) {
    return DataEntry(
      id: id ?? this.id,
      dataType: dataType ?? this.dataType,
      priority: priority ?? this.priority,
      estimatedSizeBytes: estimatedSizeBytes ?? this.estimatedSizeBytes,
      isVisible: isVisible ?? this.isVisible,
      lastAccessTime: lastAccessTime ?? this.lastAccessTime,
      unloadCallback: unloadCallback ?? this.unloadCallback,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Estimated size in MB
  double get estimatedSizeMB =>
      (estimatedSizeBytes ?? 0) / (1024 * 1024);

  @override
  String toString() {
    return 'DataEntry($dataType:$id, priority: ${priority.name}, '
        'visible: $isVisible, size: ${estimatedSizeMB.toStringAsFixed(2)} MB)';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dataType': dataType,
      'priority': priority.name,
      'estimatedSizeBytes': estimatedSizeBytes,
      'estimatedSizeMB': estimatedSizeMB,
      'isVisible': isVisible,
      'lastAccessTime': lastAccessTime.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Result of a data unload operation
class UnloadResult {
  /// Number of entries unloaded
  final int entriesUnloaded;

  /// Total memory freed in bytes
  final int memoryFreedBytes;

  /// Number of entries that failed to unload
  final int failedUnloads;

  /// List of errors that occurred during unload
  final List<String> errors;

  /// Duration of the unload operation
  final Duration duration;

  const UnloadResult({
    required this.entriesUnloaded,
    required this.memoryFreedBytes,
    this.failedUnloads = 0,
    this.errors = const [],
    required this.duration,
  });

  /// Memory freed in MB
  double get memoryFreedMB => memoryFreedBytes / (1024 * 1024);

  /// Success rate (0.0 - 1.0)
  double get successRate {
    final total = entriesUnloaded + failedUnloads;
    if (total == 0) return 1.0;
    return entriesUnloaded / total;
  }

  @override
  String toString() {
    return '''
UnloadResult:
- Entries unloaded: $entriesUnloaded
- Memory freed: ${memoryFreedMB.toStringAsFixed(2)} MB
- Failed unloads: $failedUnloads
- Success rate: ${(successRate * 100).toStringAsFixed(1)}%
- Duration: ${duration.inMilliseconds}ms
''';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'entriesUnloaded': entriesUnloaded,
      'memoryFreedBytes': memoryFreedBytes,
      'memoryFreedMB': memoryFreedMB,
      'failedUnloads': failedUnloads,
      'successRate': successRate,
      'errors': errors,
      'durationMs': duration.inMilliseconds,
    };
  }
}

/// Statistics for data unload operations
class UnloadStatistics {
  /// Total number of unload operations performed
  final int totalUnloads;

  /// Total entries unloaded across all operations
  final int totalEntriesUnloaded;

  /// Total memory freed across all operations
  final int totalMemoryFreedBytes;

  /// Total number of failed unloads
  final int totalFailedUnloads;

  /// Average duration per unload operation
  final Duration averageDuration;

  /// Last unload time
  final DateTime? lastUnloadTime;

  const UnloadStatistics({
    required this.totalUnloads,
    required this.totalEntriesUnloaded,
    required this.totalMemoryFreedBytes,
    this.totalFailedUnloads = 0,
    required this.averageDuration,
    this.lastUnloadTime,
  });

  /// Total memory freed in MB
  double get totalMemoryFreedMB =>
      totalMemoryFreedBytes / (1024 * 1024);

  /// Average memory freed per unload
  double get averageMemoryFreedMB {
    if (totalUnloads == 0) return 0.0;
    return totalMemoryFreedMB / totalUnloads;
  }

  @override
  String toString() {
    return '''
UnloadStatistics:
- Total unloads: $totalUnloads
- Total entries: $totalEntriesUnloaded
- Total memory freed: ${totalMemoryFreedMB.toStringAsFixed(2)} MB
- Average per unload: ${averageMemoryFreedMB.toStringAsFixed(2)} MB
- Failed unloads: $totalFailedUnloads
- Average duration: ${averageDuration.inMilliseconds}ms
- Last unload: ${lastUnloadTime?.toIso8601String() ?? 'Never'}
''';
  }
}

/// Configuration for data unload strategy
class DataUnloadConfig {
  /// Minimum memory pressure threshold to trigger automatic unload (warning level)
  final bool autoUnloadOnWarning;

  /// Minimum memory pressure threshold to trigger automatic unload (critical level)
  final bool autoUnloadOnCritical;

  /// Target memory to free during warning level (percentage of current usage)
  final double targetFreePercentageWarning;

  /// Target memory to free during critical level (percentage of current usage)
  final double targetFreePercentageCritical;

  /// Maximum time to spend on unload operation (avoid blocking UI)
  final Duration maxUnloadDuration;

  /// Whether to prefer unloading low priority data first
  final bool prioritizeByPriority;

  /// Whether to prefer unloading off-screen data first
  final bool prioritizeByVisibility;

  /// Enable detailed logging (debug mode only)
  final bool enableDebugLogging;

  const DataUnloadConfig({
    this.autoUnloadOnWarning = true,
    this.autoUnloadOnCritical = true,
    this.targetFreePercentageWarning = 0.1, // Free 10% of current usage
    this.targetFreePercentageCritical = 0.3, // Free 30% of current usage
    this.maxUnloadDuration = const Duration(milliseconds: 100),
    this.prioritizeByPriority = true,
    this.prioritizeByVisibility = true,
    this.enableDebugLogging = true,
  });

  /// Copy with modified values
  DataUnloadConfig copyWith({
    bool? autoUnloadOnWarning,
    bool? autoUnloadOnCritical,
    double? targetFreePercentageWarning,
    double? targetFreePercentageCritical,
    Duration? maxUnloadDuration,
    bool? prioritizeByPriority,
    bool? prioritizeByVisibility,
    bool? enableDebugLogging,
  }) {
    return DataUnloadConfig(
      autoUnloadOnWarning:
          autoUnloadOnWarning ?? this.autoUnloadOnWarning,
      autoUnloadOnCritical:
          autoUnloadOnCritical ?? this.autoUnloadOnCritical,
      targetFreePercentageWarning:
          targetFreePercentageWarning ?? this.targetFreePercentageWarning,
      targetFreePercentageCritical:
          targetFreePercentageCritical ?? this.targetFreePercentageCritical,
      maxUnloadDuration: maxUnloadDuration ?? this.maxUnloadDuration,
      prioritizeByPriority:
          prioritizeByPriority ?? this.prioritizeByPriority,
      prioritizeByVisibility:
          prioritizeByVisibility ?? this.prioritizeByVisibility,
      enableDebugLogging: enableDebugLogging ?? this.enableDebugLogging,
    );
  }
}

/// Data unload strategy service
///
/// This service automatically unloads off-screen data when memory pressure is high.
/// It tracks data entries, their visibility, and priority, then unloads them based
/// on configurable strategies.
///
/// ## Features
///
/// - **Automatic unloading**: Responds to memory alerts from MemoryMonitor
/// - **Priority-based**: Keeps critical data longer, unloads low priority first
/// - **Visibility-aware**: Prefers unloading off-screen data
/// - **Configurable**: Customize unload behavior per app needs
/// - **Statistics**: Track unload operations and memory freed
/// - **Manual control**: Trigger manual unloads when needed
///
/// ## Usage
///
/// ```dart
/// // Initialize (in bootstrap.dart)
/// await DataUnloadStrategy.initialize(
///   config: DataUnloadConfig(),
/// );
///
/// // Register data entry
/// DataUnloadStrategy.register(
///   DataEntry(
///     id: 'trip_123',
///     dataType: 'trip',
///     priority: DataPriority.high,
///     unloadCallback: () async {
///       // Clear trip data from cache
///       await tripRepository.clearFromCache('trip_123');
///     },
///   ),
/// );
///
/// // Mark data as visible
/// DataUnloadStrategy.markVisible('trip_123');
///
/// // Mark data as off-screen (automatic after delay)
/// DataUnloadStrategy.markOffScreen('trip_123');
///
/// // Manual unload
/// final result = await DataUnloadStrategy.unloadOffScreenData(
///   targetFreeBytes: 50 * 1024 * 1024, // 50 MB
/// );
/// ```
class DataUnloadStrategy {
  static DataUnloadStrategy? _instance;
  DataUnloadConfig _config;
  final Map<String, DataEntry> _entries = {};
  final List<UnloadResult> _unloadHistory = [];
  StreamSubscription<MemorySnapshot>? _memorySubscription;

  // Statistics
  int _totalUnloads = 0;
  int _totalEntriesUnloaded = 0;
  int _totalMemoryFreedBytes = 0;
  int _totalFailedUnloads = 0;
  DateTime? _lastUnloadTime;

  /// Private constructor
  DataUnloadStrategy._({required DataUnloadConfig config})
      : _config = config;

  /// Get the singleton instance
  static DataUnloadStrategy get instance {
    if (_instance == null) {
      throw StateError(
          'DataUnloadStrategy not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// Check if initialized
  static bool get isInitialized => _instance != null;

  /// Current configuration
  DataUnloadConfig get config => _config;

  /// Get all registered entries
  List<DataEntry> get entries => List.unmodifiable(_entries.values);

  /// Initialize the data unload strategy
  ///
  /// Automatically responds to memory alerts and unloads off-screen data.
  static Future<void> initialize({
    DataUnloadConfig? config,
  }) async {
    if (_instance != null) {
      throw StateError(
          'DataUnloadStrategy already initialized. Call dispose() first.');
    }

    final effectiveConfig = config ?? const DataUnloadConfig();

    _instance = DataUnloadStrategy._(config: effectiveConfig);

    // Listen to memory alerts
    if (MemoryMonitor.isInitialized) {
      _instance!._memorySubscription =
          MemoryMonitor.instance.memoryStream.listen((snapshot) {
        _instance!._onMemoryUpdate(snapshot);
      });
    }

    if (kDebugMode && effectiveConfig.enableDebugLogging) {
      debugPrint('DataUnloadStrategy initialized');
      debugPrint('  Auto-unload on warning: ${effectiveConfig.autoUnloadOnWarning}');
      debugPrint('  Auto-unload on critical: ${effectiveConfig.autoUnloadOnCritical}');
    }
  }

  /// Handle memory updates and trigger unloads if needed
  void _onMemoryUpdate(MemorySnapshot snapshot) {
    if (!MemoryMonitor.isInitialized) return;

    final alertLevel = MemoryMonitor.getCurrentAlertLevel();

    // Trigger auto-unload based on alert level
    if (alertLevel == MemoryAlertLevel.critical &&
        _config.autoUnloadOnCritical) {
      _autoUnload(MemoryAlertLevel.critical);
    } else if (alertLevel == MemoryAlertLevel.warning &&
        _config.autoUnloadOnWarning) {
      _autoUnload(MemoryAlertLevel.warning);
    }
  }

  /// Automatic unload based on memory alert level
  Future<void> _autoUnload(MemoryAlertLevel alertLevel) async {
    if (!MemoryMonitor.isInitialized) return;

    final currentUsage = await MemoryMonitor.getCurrentUsage();
    final targetPercentage = alertLevel == MemoryAlertLevel.critical
        ? _config.targetFreePercentageCritical
        : _config.targetFreePercentageWarning;

    final targetFreeBytes = (currentUsage * targetPercentage).round();

    if (kDebugMode && _config.enableDebugLogging) {
      debugPrint('🔄 Auto-unload triggered ($alertLevel)');
      debugPrint('  Current usage: ${(currentUsage / (1024 * 1024)).toStringAsFixed(2)} MB');
      debugPrint('  Target free: ${(targetFreePercentage * 100).toStringAsFixed(0)}% = ${(targetFreeBytes / (1024 * 1024)).toStringAsFixed(2)} MB');
    }

    await unloadOffScreenData(
      targetFreeBytes: targetFreeBytes,
      maxDuration: _config.maxUnloadDuration,
    );
  }

  /// Register a data entry for tracking
  ///
  /// Use this to register data that can be unloaded when memory pressure is high.
  /// The [unloadCallback] will be called when the data is selected for unloading.
  static void register(DataEntry entry) {
    if (_instance == null) {
      throw StateError('DataUnloadStrategy not initialized');
    }

    _instance!._entries[entry.id] = entry;

    if (kDebugMode && _instance!._config.enableDebugLogging) {
      debugPrint('📦 Registered data entry: $entry');
    }
  }

  /// Unregister a data entry
  ///
  /// Removes the entry from tracking. The data itself is not unloaded.
  static void unregister(String entryId) {
    if (_instance == null) {
      throw StateError('DataUnloadStrategy not initialized');
    }

    _instance!._entries.remove(entryId);

    if (kDebugMode && _instance!._config.enableDebugLogging) {
      debugPrint('📦 Unregistered data entry: $entryId');
    }
  }

  /// Mark a data entry as visible (on screen)
  ///
  /// Visible entries are less likely to be unloaded during memory pressure.
  static void markVisible(String entryId) {
    if (_instance == null) return;

    final entry = _instance!._entries[entryId];
    if (entry != null) {
      _instance!._entries[entryId] = entry.copyWith(
        isVisible: true,
        lastAccessTime: DateTime.now(),
      );
    }
  }

  /// Mark a data entry as off-screen
  ///
  /// Off-screen entries are priority candidates for unloading.
  static void markOffScreen(String entryId) {
    if (_instance == null) return;

    final entry = _instance!._entries[entryId];
    if (entry != null) {
      _instance!._entries[entryId] = entry.copyWith(
        isVisible: false,
        lastAccessTime: DateTime.now(),
      );
    }
  }

  /// Update access time for an entry (keeps it in memory longer)
  static void updateAccessTime(String entryId) {
    if (_instance == null) return;

    final entry = _instance!._entries[entryId];
    if (entry != null) {
      _instance!._entries[entryId] = entry.copyWith(
        lastAccessTime: DateTime.now(),
      );
    }
  }

  /// Unload off-screen data to free memory
  ///
  /// Parameters:
  /// - [targetFreeBytes]: Target memory to free in bytes (stops when reached)
  /// - [maxDuration]: Maximum time to spend on unloading (default: from config)
  /// - [onlyOffScreen]: Only unload off-screen data (default: true)
  /// - [maxPriority]: Maximum priority to unload (default: normal, won't unload critical)
  ///
  /// Returns [UnloadResult] with statistics about the operation.
  static Future<UnloadResult> unloadOffScreenData({
    required int targetFreeBytes,
    Duration? maxDuration,
    bool onlyOffScreen = true,
    DataPriority maxPriority = DataPriority.normal,
  }) async {
    if (_instance == null) {
      throw StateError('DataUnloadStrategy not initialized');
    }

    final startTime = DateTime.now();
    final effectiveMaxDuration = maxDuration ?? _instance!._config.maxUnloadDuration;

    int memoryFreed = 0;
    int entriesUnloaded = 0;
    int failedUnloads = 0;
    final errors = <String>[];

    if (kDebugMode && _instance!._config.enableDebugLogging) {
      debugPrint('🧹 Starting data unload...');
      debugPrint('  Target free: ${(targetFreeBytes / (1024 * 1024)).toStringAsFixed(2)} MB');
      debugPrint('  Max duration: ${effectiveMaxDuration.inMilliseconds}ms');
      debugPrint('  Only off-screen: $onlyOffScreen');
      debugPrint('  Max priority: ${maxPriority.name}');
    }

    // Build candidate list and sort by priority/visibility/access time
    final candidates = _instance!._entries.values.where((entry) {
      // Filter by priority
      if (entry.priority.index > maxPriority.index) return false;

      // Filter by visibility if onlyOffScreen is true
      if (onlyOffScreen && entry.isVisible) return false;

      // Must have unload callback
      if (entry.unloadCallback == null) return false;

      return true;
    }).toList();

    // Sort candidates: priority (asc), visibility (off-screen first), access time (oldest first)
    candidates.sort((a, b) {
      // Sort by priority (low first)
      final priorityCompare = a.priority.index.compareTo(b.priority.index);
      if (priorityCompare != 0) return priorityCompare;

      // Then by visibility (off-screen first)
      if (_instance!._config.prioritizeByVisibility) {
        final visibilityCompare = a.isVisible.compareTo(b.isVisible);
        if (visibilityCompare != 0) return visibilityCompare;
      }

      // Then by access time (oldest first)
      return a.lastAccessTime.compareTo(b.lastAccessTime);
    });

    if (kDebugMode && _instance!._config.enableDebugLogging) {
      debugPrint('  Found ${candidates.length} candidates for unloading');
    }

    // Unload candidates until target is reached or duration exceeded
    for (final candidate in candidates) {
      // Check time limit
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed >= effectiveMaxDuration) {
        if (kDebugMode && _instance!._config.enableDebugLogging) {
          debugPrint('⏱️ Max duration reached, stopping unload');
        }
        break;
      }

      // Check if target reached
      if (memoryFreed >= targetFreeBytes) {
        if (kDebugMode && _instance!._config.enableDebugLogging) {
          debugPrint('✅ Target memory freed, stopping unload');
        }
        break;
      }

      // Unload the entry
      try {
        if (kDebugMode && _instance!._config.enableDebugLogging) {
          debugPrint('  Unloading: ${candidate.dataType}:${candidate.id}');
        }

        await candidate.unloadCallback!();

        memoryFreed += candidate.estimatedSizeBytes ?? (1024 * 1024); // 1 MB default
        entriesUnloaded++;

        // Remove from tracking
        _instance!._entries.remove(candidate.id);

        if (kDebugMode && _instance!._config.enableDebugLogging) {
          debugPrint('    ✓ Unloaded ${candidate.dataType}:${candidate.id}');
        }
      } catch (e) {
        failedUnloads++;
        errors.add('Failed to unload ${candidate.dataType}:${candidate.id}: $e');

        if (kDebugMode && _instance!._config.enableDebugLogging) {
          debugPrint('    ✗ Failed: $e');
        }
      }
    }

    final duration = DateTime.now().difference(startTime);
    final result = UnloadResult(
      entriesUnloaded: entriesUnloaded,
      memoryFreedBytes: memoryFreed,
      failedUnloads: failedUnloads,
      errors: errors,
      duration: duration,
    );

    // Update statistics
    _instance!._totalUnloads++;
    _instance!._totalEntriesUnloaded += entriesUnloaded;
    _instance!._totalMemoryFreedBytes += memoryFreed;
    _instance!._totalFailedUnloads += failedUnloads;
    _instance!._lastUnloadTime = DateTime.now();

    // Add to history (keep last 50)
    _instance!._unloadHistory.add(result);
    if (_instance!._unloadHistory.length > 50) {
      _instance!._unloadHistory.removeAt(0);
    }

    if (kDebugMode && _instance!._config.enableDebugLogging) {
      debugPrint('🧹 Unload complete');
      debugPrint('  Entries unloaded: $entriesUnloaded');
      debugPrint('  Memory freed: ${result.memoryFreedMB.toStringAsFixed(2)} MB');
      debugPrint('  Failed: $failedUnloads');
      debugPrint('  Duration: ${duration.inMilliseconds}ms');
    }

    return result;
  }

  /// Get unload statistics
  static UnloadStatistics getStatistics() {
    if (_instance == null) {
      throw StateError('DataUnloadStrategy not initialized');
    }

    final history = _instance!._unloadHistory;
    final avgDuration = history.isEmpty
        ? Duration.zero
        : Duration(
            microseconds: history
                    .map((r) => r.duration.inMicroseconds)
                    .reduce((a, b) => a + b) ~/
                history.length,
          );

    return UnloadStatistics(
      totalUnloads: _instance!._totalUnloads,
      totalEntriesUnloaded: _instance!._totalEntriesUnloaded,
      totalMemoryFreedBytes: _instance!._totalMemoryFreedBytes,
      totalFailedUnloads: _instance!_totalFailedUnloads,
      averageDuration: avgDuration,
      lastUnloadTime: _instance!._lastUnloadTime,
    );
  }

  /// Get unload history
  static List<UnloadResult> getUnloadHistory() {
    if (_instance == null) {
      throw StateError('DataUnloadStrategy not initialized');
    }
    return List.unmodifiable(_instance!._unloadHistory);
  }

  /// Clear all tracked entries (without unloading them)
  static void clearEntries() {
    if (_instance == null) {
      throw StateError('DataUnloadStrategy not initialized');
    }
    _instance!._entries.clear();

    if (kDebugMode && _instance!._config.enableDebugLogging) {
      debugPrint('📦 Cleared all tracked entries');
    }
  }

  /// Update configuration
  static void updateConfig(DataUnloadConfig config) {
    if (_instance == null) {
      throw StateError('DataUnloadStrategy not initialized');
    }
    _instance!._config = config;

    if (kDebugMode && config.enableDebugLogging) {
      debugPrint('⚙️ DataUnloadStrategy config updated');
    }
  }

  /// Get entry by ID
  static DataEntry? getEntry(String entryId) {
    if (_instance == null) {
      throw StateError('DataUnloadStrategy not initialized');
    }
    return _instance!._entries[entryId];
  }

  /// Get entries by data type
  static List<DataEntry> getEntriesByType(String dataType) {
    if (_instance == null) {
      throw StateError('DataUnloadStrategy not initialized');
    }
    return _instance!._entries.values
        .where((e) => e.dataType == dataType)
        .toList();
  }

  /// Get visible entries
  static List<DataEntry> getVisibleEntries() {
    if (_instance == null) {
      throw StateError('DataUnloadStrategy not initialized');
    }
    return _instance!._entries.values.where((e) => e.isVisible).toList();
  }

  /// Get off-screen entries
  static List<DataEntry> getOffScreenEntries() {
    if (_instance == null) {
      throw StateError('DataUnloadStrategy not initialized');
    }
    return _instance!._entries.values.where((e) => !e.isVisible).toList();
  }

  /// Dispose and cleanup
  static Future<void> dispose() async {
    if (_instance == null) return;

    await _instance!._memorySubscription?.cancel();
    _instance!._entries.clear();
    _instance!._unloadHistory.clear();

    _instance = null;

    if (kDebugMode) {
      debugPrint('DataUnloadStrategy disposed');
    }
  }
}
