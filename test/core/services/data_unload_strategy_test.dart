import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/services/data_unload_strategy.dart';
import 'package:soloadventurer/core/services/memory_monitor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DataUnloadStrategy', () {
    late List<DataEntry> testEntries;

    setUp(() async {
      // Initialize MemoryMonitor first (required for DataUnloadStrategy)
      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          warningThresholdBytes: 150 * 1024 * 1024,
          criticalThresholdBytes: 180 * 1024 * 1024,
          enabled: false, // Disable actual monitoring for tests
        ),
        onAlert: (alert) {},
      );

      // Initialize DataUnloadStrategy
      await DataUnloadStrategy.initialize(
        config: const DataUnloadConfig(
          enableDebugLogging: false, // Disable logging for tests
        ),
      );

      // Create test entries
      testEntries = [
        DataEntry(
          id: 'entry_1',
          dataType: 'test',
          priority: DataPriority.critical,
          estimatedSizeBytes: 10 * 1024 * 1024, // 10 MB
          isVisible: true,
          unloadCallback: () async {
            // Simulate unload
          },
        ),
        DataEntry(
          id: 'entry_2',
          dataType: 'test',
          priority: DataPriority.high,
          estimatedSizeBytes: 5 * 1024 * 1024, // 5 MB
          isVisible: true,
          unloadCallback: () async {},
        ),
        DataEntry(
          id: 'entry_3',
          dataType: 'test',
          priority: DataPriority.normal,
          estimatedSizeBytes: 3 * 1024 * 1024, // 3 MB
          isVisible: false,
          unloadCallback: () async {},
        ),
        DataEntry(
          id: 'entry_4',
          dataType: 'test',
          priority: DataPriority.low,
          estimatedSizeBytes: 2 * 1024 * 1024, // 2 MB
          isVisible: false,
          unloadCallback: () async {},
        ),
      ];
    });

    tearDown(() async {
      await DataUnloadStrategy.dispose();
      await MemoryMonitor.dispose();
    });

    group('Initialization', () {
      test('should initialize successfully', () {
        expect(DataUnloadStrategy.isInitialized, isTrue);
      });

      test('should throw when initializing twice', () async {
        await expectLater(
          () => DataUnloadStrategy.initialize(),
          throwsStateError,
        );
      });

      test('should use default config when not provided', () async {
        await DataUnloadStrategy.dispose();
        await DataUnloadStrategy.initialize();

        final config = DataUnloadStrategy.instance.config;
        expect(config.autoUnloadOnWarning, isTrue);
        expect(config.autoUnloadOnCritical, isTrue);
        expect(config.targetFreePercentageWarning, 0.1);
        expect(config.targetFreePercentageCritical, 0.3);
      });

      test('should use custom config when provided', () async {
        await DataUnloadStrategy.dispose();
        await DataUnloadStrategy.initialize(
          config: const DataUnloadConfig(
            autoUnloadOnWarning: false,
            targetFreePercentageWarning: 0.2,
          ),
        );

        final config = DataUnloadStrategy.instance.config;
        expect(config.autoUnloadOnWarning, isFalse);
        expect(config.targetFreePercentageWarning, 0.2);
      });
    });

    group('Entry Registration', () {
      test('should register entry successfully', () {
        DataUnloadStrategy.register(testEntries[0]);

        final entry = DataUnloadStrategy.getEntry('entry_1');
        expect(entry, isNotNull);
        expect(entry!.id, 'entry_1');
        expect(entry.dataType, 'test');
        expect(entry.priority, DataPriority.critical);
      });

      test('should register multiple entries', () {
        for (final entry in testEntries) {
          DataUnloadStrategy.register(entry);
        }

        expect(DataUnloadStrategy.instance.entries.length, 4);
      });

      test('should overwrite existing entry with same ID', () {
        DataUnloadStrategy.register(testEntries[0]);
        DataUnloadStrategy.register(
          testEntries[0].copyWith(priority: DataPriority.low),
        );

        final entry = DataUnloadStrategy.getEntry('entry_1');
        expect(entry!.priority, DataPriority.low);
      });

      test('should unregister entry', () {
        DataUnloadStrategy.register(testEntries[0]);
        DataUnloadStrategy.unregister('entry_1');

        final entry = DataUnloadStrategy.getEntry('entry_1');
        expect(entry, isNull);
      });

      test('should unregister non-existent entry without error', () {
        expect(
          () => DataUnloadStrategy.unregister('non_existent'),
          returnsNormally,
        );
      });

      test('should get all entries', () {
        for (final entry in testEntries) {
          DataUnloadStrategy.register(entry);
        }

        final entries = DataUnloadStrategy.instance.entries;
        expect(entries.length, 4);
        expect(entries.map((e) => e.id).contains('entry_1'), isTrue);
        expect(entries.map((e) => e.id).contains('entry_4'), isTrue);
      });
    });

    group('Visibility Tracking', () {
      test('should mark entry as visible', () {
        DataUnloadStrategy.register(testEntries[0]);
        DataUnloadStrategy.markVisible('entry_1');

        final entry = DataUnloadStrategy.getEntry('entry_1');
        expect(entry!.isVisible, isTrue);
      });

      test('should mark entry as off-screen', () {
        DataUnloadStrategy.register(testEntries[0].copyWith(isVisible: true));
        DataUnloadStrategy.markOffScreen('entry_1');

        final entry = DataUnloadStrategy.getEntry('entry_1');
        expect(entry!.isVisible, isFalse);
      });

      test('should update access time', () {
        DataUnloadStrategy.register(testEntries[0]);
        final originalTime =
            DataUnloadStrategy.getEntry('entry_1')!.lastAccessTime;

        // Wait a bit and update
        await Future.delayed(const Duration(milliseconds: 10));
        DataUnloadStrategy.updateAccessTime('entry_1');

        final newTime = DataUnloadStrategy.getEntry('entry_1')!.lastAccessTime;
        expect(newTime.isAfter(originalTime), isTrue);
      });

      test('should handle visibility for non-existent entry', () {
        expect(
          () => DataUnloadStrategy.markVisible('non_existent'),
          returnsNormally,
        );
        expect(
          () => DataUnloadStrategy.markOffScreen('non_existent'),
          returnsNormally,
        );
      });

      test('should get visible entries', () {
        DataUnloadStrategy.register(testEntries[0]); // visible
        DataUnloadStrategy.register(testEntries[1]); // visible
        DataUnloadStrategy.register(testEntries[2]); // off-screen

        final visible = DataUnloadStrategy.getVisibleEntries();
        expect(visible.length, 2);
        expect(visible.every((e) => e.isVisible), isTrue);
      });

      test('should get off-screen entries', () {
        DataUnloadStrategy.register(testEntries[0]); // visible
        DataUnloadStrategy.register(testEntries[2]); // off-screen
        DataUnloadStrategy.register(testEntries[3]); // off-screen

        final offScreen = DataUnloadStrategy.getOffScreenEntries();
        expect(offScreen.length, 2);
        expect(offScreen.every((e) => !e.isVisible), isTrue);
      });
    });

    group('Entry Queries', () {
      setUp(() {
        for (final entry in testEntries) {
          DataUnloadStrategy.register(entry);
        }
      });

      test('should get entry by ID', () {
        final entry = DataUnloadStrategy.getEntry('entry_1');
        expect(entry, isNotNull);
        expect(entry!.id, 'entry_1');
      });

      test('should return null for non-existent entry', () {
        final entry = DataUnloadStrategy.getEntry('non_existent');
        expect(entry, isNull);
      });

      test('should get entries by data type', () {
        final entries = DataUnloadStrategy.getEntriesByType('test');
        expect(entries.length, 4);
      });

      test('should return empty list for unknown data type', () {
        final entries = DataUnloadStrategy.getEntriesByType('unknown');
        expect(entries, isEmpty);
      });
    });

    group('Unload Operations', () {
      test('should unload off-screen data only', () async {
        DataUnloadStrategy.register(testEntries[0]); // visible, critical
        DataUnloadStrategy.register(testEntries[2]); // off-screen, normal
        DataUnloadStrategy.register(testEntries[3]); // off-screen, low

        final result = await DataUnloadStrategy.unloadOffScreenData(
          targetFreeBytes: 1024 * 1024, // 1 MB
          onlyOffScreen: true,
        );

        expect(result.entriesUnloaded, greaterThan(0));
        expect(
            DataUnloadStrategy.getEntry('entry_1'), isNotNull); // Still visible
        expect(DataUnloadStrategy.getEntry('entry_2'), isNull); // Unloaded
      });

      test('should respect max priority limit', () async {
        DataUnloadStrategy.register(testEntries[2]); // normal
        DataUnloadStrategy.register(testEntries[3]); // low

        final result = await DataUnloadStrategy.unloadOffScreenData(
          targetFreeBytes: 1024 * 1024,
          maxPriority: DataPriority.normal,
        );

        // Should unload low priority but not normal (if onlyOffScreen is false)
        expect(result.entriesUnloaded, greaterThan(0));
      });

      test('should stop when target memory is reached', () async {
        DataUnloadStrategy.register(testEntries[2]); // 3 MB
        DataUnloadStrategy.register(testEntries[3]); // 2 MB

        final result = await DataUnloadStrategy.unloadOffScreenData(
          targetFreeBytes: 3 * 1024 * 1024, // 3 MB
        );

        // Should unload entry_3 (2 MB) and maybe entry_2 (3 MB)
        expect(result.memoryFreedBytes, greaterThanOrEqualTo(2 * 1024 * 1024));
      });

      test('should stop when max duration is reached', () async {
        // Create entries with slow unload callbacks
        final slowEntry = DataEntry(
          id: 'slow',
          dataType: 'test',
          priority: DataPriority.low,
          estimatedSizeBytes: 1024 * 1024,
          unloadCallback: () async {
            await Future.delayed(const Duration(milliseconds: 50));
          },
        );

        DataUnloadStrategy.register(slowEntry);

        final result = await DataUnloadStrategy.unloadOffScreenData(
          targetFreeBytes: 1024 * 1024 * 1024, // 1 GB (won't be reached)
          maxDuration: const Duration(milliseconds: 20), // Stop after 20ms
        );

        // Should stop before completing due to time limit
        expect(result.duration.inMilliseconds, lessThan(50));
      });

      test('should track unload statistics', () async {
        DataUnloadStrategy.register(testEntries[2]);
        DataUnloadStrategy.register(testEntries[3]);

        await DataUnloadStrategy.unloadOffScreenData(
          targetFreeBytes: 1024 * 1024,
        );

        final stats = DataUnloadStrategy.getStatistics();
        expect(stats.totalUnloads, 1);
        expect(stats.totalEntriesUnloaded, greaterThan(0));
        expect(stats.totalMemoryFreedBytes, greaterThan(0));
        expect(stats.lastUnloadTime, isNotNull);
      });

      test('should record unload history', () async {
        DataUnloadStrategy.register(testEntries[2]);
        DataUnloadStrategy.register(testEntries[3]);

        await DataUnloadStrategy.unloadOffScreenData(
          targetFreeBytes: 1024 * 1024,
        );

        final history = DataUnloadStrategy.getUnloadHistory();
        expect(history, isNotEmpty);
        expect(history.first.entriesUnloaded, greaterThan(0));
      });

      test('should keep history size limited', () async {
        // Perform 60 unloads (more than max 50)
        for (int i = 0; i < 60; i++) {
          final entry = DataEntry(
            id: 'entry_$i',
            dataType: 'test',
            priority: DataPriority.low,
            estimatedSizeBytes: 1024,
            unloadCallback: () async {},
          );
          DataUnloadStrategy.register(entry);

          await DataUnloadStrategy.unloadOffScreenData(
            targetFreeBytes: 1024,
          );
        }

        final history = DataUnloadStrategy.getUnloadHistory();
        expect(history.length, lessThanOrEqualTo(50));
      });

      test('should handle unload callback errors gracefully', () async {
        final errorEntry = DataEntry(
          id: 'error',
          dataType: 'test',
          priority: DataPriority.low,
          estimatedSizeBytes: 1024 * 1024,
          unloadCallback: () async {
            throw Exception('Unload failed');
          },
        );

        DataUnloadStrategy.register(errorEntry);
        DataUnloadStrategy.register(testEntries[3]); // This one should succeed

        final result = await DataUnloadStrategy.unloadOffScreenData(
          targetFreeBytes: 1024 * 1024 * 1024,
        );

        expect(result.failedUnloads, 1);
        expect(result.errors, isNotEmpty);
        expect(result.errors.first.contains('Unload failed'), isTrue);
      });

      test('should not unload entries without unload callback', () async {
        final noCallbackEntry = DataEntry(
          id: 'no_callback',
          dataType: 'test',
          priority: DataPriority.low,
          estimatedSizeBytes: 1024 * 1024,
          unloadCallback: null, // No callback
        );

        DataUnloadStrategy.register(noCallbackEntry);

        final result = await DataUnloadStrategy.unloadOffScreenData(
          targetFreeBytes: 1024 * 1024 * 1024,
        );

        expect(result.entriesUnloaded, 0);
        expect(DataUnloadStrategy.getEntry('no_callback'), isNotNull);
      });
    });

    group('Priority Sorting', () {
      test('should unload low priority before normal priority', () async {
        final lowPriority = DataEntry(
          id: 'low',
          dataType: 'test',
          priority: DataPriority.low,
          estimatedSizeBytes: 2 * 1024 * 1024,
          isVisible: false,
          unloadCallback: () async {},
        );

        final normalPriority = DataEntry(
          id: 'normal',
          dataType: 'test',
          priority: DataPriority.normal,
          estimatedSizeBytes: 2 * 1024 * 1024,
          isVisible: false,
          unloadCallback: () async {},
        );

        DataUnloadStrategy.register(lowPriority);
        DataUnloadStrategy.register(normalPriority);

        final result = await DataUnloadStrategy.unloadOffScreenData(
          targetFreeBytes: 2 * 1024 * 1024, // Only 2 MB needed
        );

        expect(DataUnloadStrategy.getEntry('low'), isNull); // Unloaded
        expect(DataUnloadStrategy.getEntry('normal'), isNotNull); // Kept
      });

      test('should unload off-screen before visible', () async {
        final offScreen = DataEntry(
          id: 'off_screen',
          dataType: 'test',
          priority: DataPriority.normal,
          estimatedSizeBytes: 2 * 1024 * 1024,
          isVisible: false,
          unloadCallback: () async {},
        );

        final visible = DataEntry(
          id: 'visible',
          dataType: 'test',
          priority: DataPriority.normal,
          estimatedSizeBytes: 2 * 1024 * 1024,
          isVisible: true,
          unloadCallback: () async {},
        );

        DataUnloadStrategy.register(offScreen);
        DataUnloadStrategy.register(visible);

        final result = await DataUnloadStrategy.unloadOffScreenData(
          targetFreeBytes: 2 * 1024 * 1024,
        );

        expect(DataUnloadStrategy.getEntry('off_screen'), isNull); // Unloaded
        expect(DataUnloadStrategy.getEntry('visible'), isNotNull); // Kept
      });
    });

    group('Configuration Updates', () {
      test('should update configuration', () {
        const newConfig = DataUnloadConfig(
          autoUnloadOnWarning: false,
          targetFreePercentageWarning: 0.5,
        );

        DataUnloadStrategy.updateConfig(newConfig);

        final config = DataUnloadStrategy.instance.config;
        expect(config.autoUnloadOnWarning, isFalse);
        expect(config.targetFreePercentageWarning, 0.5);
      });

      test('should use updated config for subsequent operations', () async {
        // First unload with original config
        DataUnloadStrategy.register(testEntries[3]);
        await DataUnloadStrategy.unloadOffScreenData(
          targetFreeBytes: 1024 * 1024,
        );

        // Update config
        DataUnloadStrategy.updateConfig(
          const DataUnloadConfig(
            maxUnloadDuration: Duration(milliseconds: 10),
          ),
        );

        // Next unload should use new config
        DataUnloadStrategy.register(testEntries[2]);
        final result = await DataUnloadStrategy.unloadOffScreenData(
          targetFreeBytes: 1024 * 1024 * 1024,
        );

        expect(result.duration.inMilliseconds, lessThan(20));
      });
    });

    group('Clear Operations', () {
      test('should clear all entries', () {
        for (final entry in testEntries) {
          DataUnloadStrategy.register(entry);
        }

        expect(DataUnloadStrategy.instance.entries.length, 4);

        DataUnloadStrategy.clearEntries();

        expect(DataUnloadStrategy.instance.entries, isEmpty);
      });

      test('should clear entries without unloading', () async {
        bool unloadCalled = false;

        final entry = DataEntry(
          id: 'test',
          dataType: 'test',
          priority: DataPriority.normal,
          unloadCallback: () async {
            unloadCalled = true;
          },
        );

        DataUnloadStrategy.register(entry);
        DataUnloadStrategy.clearEntries();

        expect(unloadCalled, isFalse);
      });
    });

    group('Disposal', () {
      test('should dispose successfully', () async {
        expect(DataUnloadStrategy.isInitialized, isTrue);

        await DataUnloadStrategy.dispose();

        expect(DataUnloadStrategy.isInitialized, isFalse);
      });

      test('should dispose without error when called multiple times', () async {
        await DataUnloadStrategy.dispose();
        await DataUnloadStrategy.dispose(); // Should not throw
      });

      test('should clear resources on disposal', () async {
        DataUnloadStrategy.register(testEntries[0]);
        await DataUnloadStrategy.dispose();

        // After disposal, should be able to reinitialize
        await DataUnloadStrategy.initialize();
        expect(DataUnloadStrategy.instance.entries, isEmpty);
      });
    });

    group('DataEntry Model', () {
      test('should create entry with all fields', () {
        final entry = DataEntry(
          id: 'test',
          dataType: 'trip',
          priority: DataPriority.high,
          estimatedSizeBytes: 1024 * 1024,
          isVisible: true,
          lastAccessTime: DateTime(2024, 1, 1),
          metadata: {'key': 'value'},
        );

        expect(entry.id, 'test');
        expect(entry.dataType, 'trip');
        expect(entry.priority, DataPriority.high);
        expect(entry.estimatedSizeBytes, 1024 * 1024);
        expect(entry.isVisible, isTrue);
        expect(entry.lastAccessTime, DateTime(2024, 1, 1));
        expect(entry.metadata, {'key': 'value'});
      });

      test('should calculate size in MB correctly', () {
        final entry = DataEntry(
          id: 'test',
          dataType: 'test',
          priority: DataPriority.normal,
          estimatedSizeBytes: 5 * 1024 * 1024, // 5 MB
        );

        expect(entry.estimatedSizeMB, 5.0);
      });

      test('should copy with modified values', () {
        final entry = DataEntry(
          id: 'test',
          dataType: 'test',
          priority: DataPriority.normal,
        );

        final copied = entry.copyWith(
          priority: DataPriority.high,
          isVisible: true,
        );

        expect(copied.id, 'test');
        expect(copied.priority, DataPriority.high);
        expect(copied.isVisible, isTrue);
      });

      test('should convert to JSON', () {
        final entry = DataEntry(
          id: 'test',
          dataType: 'test',
          priority: DataPriority.normal,
          estimatedSizeBytes: 1024 * 1024,
        );

        final json = entry.toJson();

        expect(json['id'], 'test');
        expect(json['dataType'], 'test');
        expect(json['priority'], 'normal');
        expect(json['estimatedSizeBytes'], 1024 * 1024);
      });
    });

    group('UnloadResult Model', () {
      test('should calculate memory freed in MB', () {
        const result = UnloadResult(
          entriesUnloaded: 10,
          memoryFreedBytes: 20 * 1024 * 1024, // 20 MB
          duration: Duration(milliseconds: 100),
        );

        expect(result.memoryFreedMB, 20.0);
      });

      test('should calculate success rate', () {
        const result = UnloadResult(
          entriesUnloaded: 8,
          memoryFreedBytes: 10 * 1024 * 1024,
          failedUnloads: 2,
          duration: Duration(milliseconds: 100),
        );

        expect(result.successRate, 0.8); // 8/10
      });

      test('should handle zero total entries', () {
        const result = UnloadResult(
          entriesUnloaded: 0,
          memoryFreedBytes: 0,
          failedUnloads: 0,
          duration: Duration(milliseconds: 100),
        );

        expect(result.successRate, 1.0);
      });
    });

    group('UnloadStatistics Model', () {
      test('should calculate total memory freed in MB', () {
        const stats = UnloadStatistics(
          totalUnloads: 5,
          totalEntriesUnloaded: 50,
          totalMemoryFreedBytes: 100 * 1024 * 1024, // 100 MB
          averageDuration: Duration(milliseconds: 50),
        );

        expect(stats.totalMemoryFreedMB, 100.0);
      });

      test('should calculate average memory freed', () {
        const stats = UnloadStatistics(
          totalUnloads: 5,
          totalEntriesUnloaded: 50,
          totalMemoryFreedBytes: 100 * 1024 * 1024, // 100 MB
          averageDuration: Duration(milliseconds: 50),
        );

        expect(stats.averageMemoryFreedMB, 20.0); // 100 MB / 5 unloads
      });

      test('should handle zero unloads', () {
        const stats = UnloadStatistics(
          totalUnloads: 0,
          totalEntriesUnloaded: 0,
          totalMemoryFreedBytes: 0,
          averageDuration: Duration(milliseconds: 0),
        );

        expect(stats.averageMemoryFreedMB, 0.0);
      });
    });
  });
}
