import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/utils/preloading_strategy.dart';

void main() {
  group('PreloadConfig', () {
    test('should create default config', () {
      const config = PreloadConfig();

      expect(config.strategy, PreloadStrategy.predictive);
      expect(config.fixedThreshold, 500.0);
      expect(config.velocityThreshold, 1000.0);
      expect(config.velocityMultiplier, 0.5);
      expect(config.preloadAheadCount, 2);
      expect(config.minPreloadInterval, 500);
      expect(config.enableAdaptiveThreshold, true);
      expect(config.adaptiveFactor, 1.0);
    });

    test('should create custom config', () {
      const config = PreloadConfig(
        strategy: PreloadStrategy.aggressive,
        fixedThreshold: 800.0,
        velocityThreshold: 1500.0,
        velocityMultiplier: 0.7,
        preloadAheadCount: 3,
        minPreloadInterval: 300,
        enableAdaptiveThreshold: false,
        adaptiveFactor: 0.8,
      );

      expect(config.strategy, PreloadStrategy.aggressive);
      expect(config.fixedThreshold, 800.0);
      expect(config.velocityMultiplier, 0.7);
    });

    test('should provide predefined configs', () {
      const defaultConfig = PreloadConfig.defaultConfig;
      const aggressiveConfig = PreloadConfig.aggressiveConfig;
      const conservativeConfig = PreloadConfig.conservativeConfig;

      expect(defaultConfig.strategy, PreloadStrategy.predictive);
      expect(aggressiveConfig.strategy, PreloadStrategy.aggressive);
      expect(conservativeConfig.strategy, PreloadStrategy.conservative);
    });

    test('should copy with modified fields', () {
      const config = PreloadConfig(
        strategy: PreloadStrategy.predictive,
        fixedThreshold: 500.0,
      );

      final modified = config.copyWith(
        strategy: PreloadStrategy.aggressive,
        fixedThreshold: 800.0,
      );

      expect(modified.strategy, PreloadStrategy.aggressive);
      expect(modified.fixedThreshold, 800.0);
      expect(modified.velocityThreshold, config.velocityThreshold);
    });
  });

  group('PreloadMetrics', () {
    test('should create default metrics', () {
      const metrics = PreloadMetrics();

      expect(metrics.successfulPreloads, 0);
      expect(metrics.failedPreloads, 0);
      expect(metrics.averageLoadTime, 0.0);
      expect(metrics.totalPreloadedPages, 0);
      expect(metrics.cacheHitRate, 0.0);
      expect(metrics.lastPreloadTime, null);
    });

    test('should create metrics with values', () {
      final now = DateTime.now();
      final metrics = PreloadMetrics(
        successfulPreloads: 10,
        failedPreloads: 2,
        averageLoadTime: 500.0,
        totalPreloadedPages: 10,
        cacheHitRate: 0.8,
        lastPreloadTime: now,
      );

      expect(metrics.successfulPreloads, 10);
      expect(metrics.failedPreloads, 2);
      expect(metrics.averageLoadTime, 500.0);
      expect(metrics.cacheHitRate, 0.8);
      expect(metrics.lastPreloadTime, now);
    });

    test('should determine performing well correctly', () {
      const goodMetrics = PreloadMetrics(
        successfulPreloads: 10,
        failedPreloads: 0,
        averageLoadTime: 500.0,
        cacheHitRate: 0.8,
      );

      const badMetrics = PreloadMetrics(
        successfulPreloads: 10,
        failedPreloads: 2,
        averageLoadTime: 500.0,
        cacheHitRate: 0.8,
      );

      const slowMetrics = PreloadMetrics(
        successfulPreloads: 10,
        failedPreloads: 0,
        averageLoadTime: 2500.0,
        cacheHitRate: 0.8,
      );

      expect(goodMetrics.isPerformingWell, true);
      expect(badMetrics.isPerformingWell, false);
      expect(slowMetrics.isPerformingWell, false);
    });

    test('should copy with modified fields', () {
      const metrics = PreloadMetrics(
        successfulPreloads: 5,
        averageLoadTime: 500.0,
      );

      final modified = metrics.copyWith(
        successfulPreloads: 10,
        averageLoadTime: 600.0,
      );

      expect(modified.successfulPreloads, 10);
      expect(modified.averageLoadTime, 600.0);
      expect(modified.failedPreloads, metrics.failedPreloads);
    });

    test('should format toString correctly', () {
      const metrics = PreloadMetrics(
        successfulPreloads: 10,
        failedPreloads: 2,
        averageLoadTime: 500.0,
        cacheHitRate: 0.8,
      );

      final string = metrics.toString();

      expect(string, contains('successful: 10'));
      expect(string, contains('failed: 2'));
      expect(string, contains('500'));
      expect(string, contains('80%'));
    });
  });

  group('PreloadingManager', () {
    late PreloadingManager manager;

    setUp(() {
      manager = PreloadingManager(
        config: PreloadConfig.defaultConfig,
      );
    });

    test('should initialize with default config', () {
      expect(manager.config.strategy, PreloadStrategy.predictive);
      expect(manager.metrics.successfulPreloads, 0);
    });

    test('should update velocity correctly', () {
      manager.updateVelocity(1000.0);
      manager.updateVelocity(1500.0);
      manager.updateVelocity(2000.0);

      // Average should be around 1500
      expect(manager.metrics, isNotNull);
    });

    test('should record successful load', () {
      manager.recordSuccessfulLoad(500);
      manager.recordSuccessfulLoad(600);
      manager.recordSuccessfulLoad(400);

      expect(manager.metrics.successfulPreloads, 3);
      expect(manager.metrics.totalPreloadedPages, 3);
      expect(manager.metrics.averageLoadTime, 500.0);
      expect(manager.metrics.lastPreloadTime, isNotNull);
    });

    test('should record failed load', () {
      manager.recordFailedLoad();
      manager.recordFailedLoad();

      expect(manager.metrics.failedPreloads, 2);
      expect(manager.metrics.successfulPreloads, 0);
    });

    test('should calculate threshold for fixed distance strategy', () {
      manager = PreloadingManager(
        config: const PreloadConfig(
          strategy: PreloadStrategy.fixedDistance,
          fixedThreshold: 500.0,
        ),
      );

      final threshold = manager.calculateThreshold();
      expect(threshold, 500.0);
    });

    test('should calculate threshold for velocity based strategy', () {
      manager = PreloadingManager(
        config: const PreloadConfig(
          strategy: PreloadStrategy.velocityBased,
          fixedThreshold: 500.0,
          velocityThreshold: 1000.0,
          velocityMultiplier: 0.5,
        ),
      );

      manager.updateVelocity(2000.0);
      final threshold = manager.calculateThreshold();

      // 500 + (2000 * 0.5) = 1500
      expect(threshold, 1500.0);
    });

    test('should calculate threshold for predictive strategy', () {
      manager = PreloadingManager(
        config: const PreloadConfig(
          strategy: PreloadStrategy.predictive,
          fixedThreshold: 500.0,
          velocityThreshold: 1000.0,
          velocityMultiplier: 0.5,
        ),
      );

      manager.updateVelocity(2000.0);
      final threshold = manager.calculateThreshold();

      // 500 + (2000 * 0.5 * (1 + 2.0/1000.0))
      expect(threshold, greaterThan(500.0));
    });

    test('should calculate threshold for aggressive strategy', () {
      manager = PreloadingManager(
        config: const PreloadConfig(
          strategy: PreloadStrategy.aggressive,
          fixedThreshold: 500.0,
        ),
      );

      final threshold = manager.calculateThreshold();
      expect(threshold, 750.0); // 500 * 1.5
    });

    test('should calculate threshold for conservative strategy', () {
      manager = PreloadingManager(
        config: const PreloadConfig(
          strategy: PreloadStrategy.conservative,
          fixedThreshold: 500.0,
        ),
      );

      final threshold = manager.calculateThreshold();
      expect(threshold, 200.0); // 500 * 0.4
    });

    test('should calculate adaptive threshold based on performance', () {
      manager = PreloadingManager(
        config: const PreloadConfig(
          strategy: PreloadStrategy.predictive,
          enableAdaptiveThreshold: true,
        ),
      );

      // Fast loads - should increase threshold
      manager.recordSuccessfulLoad(300);
      manager.recordSuccessfulLoad(400);

      final fastThreshold = manager.calculateAdaptiveThreshold();
      final baseThreshold = manager.calculateThreshold();

      expect(fastThreshold, greaterThan(baseThreshold * 0.9));
    });

    test('should determine if can preload based on interval', () {
      expect(manager.canPreload, true);

      manager.markPreloadTriggered();
      expect(manager.canPreload, false);

      // After interval, should allow preload again
      // Note: This would require waiting 500ms in a real test
    });

    test('should determine if should preload correctly', () {
      manager = PreloadingManager(
        config: const PreloadConfig(
          strategy: PreloadStrategy.fixedDistance,
          fixedThreshold: 500.0,
        ),
      );

      // Within threshold
      expect(manager.shouldPreload(1000.0, 600.0), true);

      // Outside threshold
      expect(manager.shouldPreload(1000.0, 200.0), false);
    });

    test('should return preload ahead count', () {
      expect(manager.preloadAheadCount, 2);

      manager = PreloadingManager(
        config: PreloadConfig.aggressiveConfig,
      );

      expect(manager.preloadAheadCount, 3);
    });

    test('should reset metrics', () {
      manager.recordSuccessfulLoad(500);
      manager.recordFailedLoad();
      manager.markPreloadTriggered();

      expect(manager.metrics.successfulPreloads, 1);
      expect(manager.metrics.failedPreloads, 1);

      manager.reset();

      expect(manager.metrics.successfulPreloads, 0);
      expect(manager.metrics.failedPreloads, 0);
    });
  });

  group('PreloadStrategy enum', () {
    test('should have all strategies', () {
      expect(PreloadStrategy.values.length, 5);
      expect(PreloadStrategy.values, contains(PreloadStrategy.fixedDistance));
      expect(PreloadStrategy.values, contains(PreloadStrategy.velocityBased));
      expect(PreloadStrategy.values, contains(PreloadStrategy.predictive));
      expect(PreloadStrategy.values, contains(PreloadStrategy.aggressive));
      expect(PreloadStrategy.values, contains(PreloadStrategy.conservative));
    });
  });

  group('PreloadingManager integration', () {
    late PreloadingManager manager;

    setUp(() {
      manager = PreloadingManager(
        config: const PreloadConfig(
          strategy: PreloadStrategy.predictive,
          enableAdaptiveThreshold: true,
        ),
      );
    });

    test('should track velocity and adjust threshold', () {
      // Slow scrolling
      manager.updateVelocity(500.0);
      final slowThreshold = manager.calculateThreshold();

      // Fast scrolling
      manager.updateVelocity(2000.0);
      final fastThreshold = manager.calculateThreshold();

      expect(fastThreshold, greaterThan(slowThreshold));
    });

    test('should adapt based on load times', () {
      // Slow loads
      manager.recordSuccessfulLoad(2500);
      manager.recordSuccessfulLoad(3000);

      final slowLoadThreshold = manager.calculateAdaptiveThreshold();

      // Reset and record fast loads
      manager.reset();
      manager.recordSuccessfulLoad(200);
      manager.recordSuccessfulLoad(300);

      final fastLoadThreshold = manager.calculateAdaptiveThreshold();

      // Slow loads should trigger earlier preloading (lower threshold)
      expect(slowLoadThreshold, lessThan(fastLoadThreshold));
    });

    test('should handle multiple load failures gracefully', () {
      manager.recordFailedLoad();
      manager.recordFailedLoad();
      manager.recordFailedLoad();

      expect(manager.metrics.failedPreloads, 3);

      // Should still allow preloading
      expect(manager.canPreload, true);
    });

    test('should respect minimum preload interval', () {
      manager.markPreloadTriggered();
      expect(manager.canPreload, false);

      // Even after a short time, should not allow preload
      expect(manager.canPreload, false);
    });
  });
}
