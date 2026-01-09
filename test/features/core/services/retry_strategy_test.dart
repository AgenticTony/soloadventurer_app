import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/core/services/retry_strategy.dart';
import 'dart:math';

void main() {
  group('RetryStrategy', () {
    group('ExponentialBackoffStrategy', () {
      test('should calculate correct exponential delays', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 0.0, // No jitter for predictable testing
          random: FixedRandom(0.5), // Fixed random value
        );

        // Act & Assert
        // Attempt 0: 1s * 2^0 = 1s
        expect(strategy.calculateDelay(0), const Duration(seconds: 1));

        // Attempt 1: 1s * 2^1 = 2s
        expect(strategy.calculateDelay(1), const Duration(seconds: 2));

        // Attempt 2: 1s * 2^2 = 4s
        expect(strategy.calculateDelay(2), const Duration(seconds: 4));

        // Attempt 3: 1s * 2^3 = 8s
        expect(strategy.calculateDelay(3), const Duration(seconds: 8));

        // Attempt 4: 1s * 2^4 = 16s
        expect(strategy.calculateDelay(4), const Duration(seconds: 16));
      });

      test('should cap delay at maxDelay', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 10),
          maxDelay: const Duration(seconds: 30), // Low max for testing
          jitterFactor: 0.0,
          random: FixedRandom(0.5),
        );

        // Act & Assert
        // Attempt 0: 10s
        expect(strategy.calculateDelay(0), const Duration(seconds: 10));

        // Attempt 1: 20s
        expect(strategy.calculateDelay(1), const Duration(seconds: 20));

        // Attempt 2: Would be 40s but capped at 30s
        expect(strategy.calculateDelay(2), const Duration(seconds: 30));

        // Attempt 3: Would be 80s but capped at 30s
        expect(strategy.calculateDelay(3), const Duration(seconds: 30));
      });

      test('should add jitter to delay', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 0.5, // 50% jitter for testing
          random: FixedRandom(0.0), // Returns 0.0, so jitter = -50%
        );

        // Act
        final delay = strategy.calculateDelay(1); // Base: 2s

        // Assert: With 50% jitter and random=0.0, result = 2s * (1 - 0.5) = 1s
        expect(delay.inSeconds, greaterThanOrEqualTo(1));
        expect(delay.inSeconds, lessThanOrEqualTo(3));
      });

      test('should handle zero jitter factor', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 2),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 0.0, // No jitter
          random: FixedRandom(0.5),
        );

        // Act & Assert
        // Without jitter, delays should be exact
        expect(strategy.calculateDelay(0), const Duration(seconds: 2));
        expect(strategy.calculateDelay(1), const Duration(seconds: 4));
        expect(strategy.calculateDelay(2), const Duration(seconds: 8));
      });

      test('should handle negative attempt count gracefully', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          random: FixedRandom(0.5),
        );

        // Act
        final delay = strategy.calculateDelay(-1);

        // Assert: Should treat negative as 0
        expect(delay, const Duration(seconds: 1));
      });

      test('should prevent delay from going negative with jitter', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(milliseconds: 100),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 1.0, // 100% jitter
          random: FixedRandom(0.0), // Returns 0.0, so jitter = -100%
        );

        // Act
        final delay = strategy.calculateDelay(0);

        // Assert: Even with -100% jitter, should not go below 0
        expect(delay.inMilliseconds, greaterThanOrEqualTo(0));
      });

      test('should have correct description', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 2),
          maxDelay: const Duration(minutes: 10),
          jitterFactor: 0.2,
        );

        // Act & Assert
        expect(
          strategy.description,
          'ExponentialBackoff(baseDelay: 2s, maxDelay: 10m, jitter: 20%)',
        );
      });

      test('should validate jitter factor bounds', () {
        // Arrange & Act & Assert
        expect(
          () => ExponentialBackoffStrategy(jitterFactor: -0.1),
          throwsAssertionError,
        );

        expect(
          () => ExponentialBackoffStrategy(jitterFactor: 1.1),
          throwsAssertionError,
        );

        // Valid values should not throw
        expect(() => ExponentialBackoffStrategy(jitterFactor: 0.0),
            returnsNormally);
        expect(() => ExponentialBackoffStrategy(jitterFactor: 0.5),
            returnsNormally);
        expect(() => ExponentialBackoffStrategy(jitterFactor: 1.0),
            returnsNormally);
      });

      test('should distribute delays with randomness', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          jitterFactor: 0.2,
        );

        // Act: Calculate delay 100 times with different random seeds
        final delays = <Duration>[];
        for (int i = 0; i < 100; i++) {
          final testStrategy = ExponentialBackoffStrategy(
            baseDelay: const Duration(seconds: 1),
            jitterFactor: 0.2,
            random: Random(i),
          );
          delays.add(testStrategy.calculateDelay(1));
        }

        // Assert: Should see variation in delays due to jitter
        final uniqueDelays = delays.toSet();
        expect(uniqueDelays.length,
            greaterThan(10), // Should have multiple unique values
            reason: 'Jitter should create variation in delays');
      });

      test('should not exceed maxDelay even with high attempt count', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          maxDelay: const Duration(seconds: 60),
          jitterFactor: 0.0,
          random: FixedRandom(0.5),
        );

        // Act & Assert
        for (int attempt = 0; attempt < 20; attempt++) {
          final delay = strategy.calculateDelay(attempt);
          expect(
            delay.inSeconds,
            lessThanOrEqualTo(60),
            reason: 'Attempt $attempt exceeded maxDelay',
          );
        }
      });
    });

    group('FixedDelayStrategy', () {
      test('should return same delay for all attempts', () {
        // Arrange
        final strategy = FixedDelayStrategy(
          delay: const Duration(seconds: 5),
        );

        // Act & Assert
        expect(strategy.calculateDelay(0), const Duration(seconds: 5));
        expect(strategy.calculateDelay(1), const Duration(seconds: 5));
        expect(strategy.calculateDelay(2), const Duration(seconds: 5));
        expect(strategy.calculateDelay(10), const Duration(seconds: 5));
        expect(strategy.calculateDelay(100), const Duration(seconds: 5));
      });

      test('should handle negative attempt count', () {
        // Arrange
        final strategy = FixedDelayStrategy(
          delay: const Duration(seconds: 3),
        );

        // Act & Assert
        // Should still return fixed delay even with negative count
        expect(strategy.calculateDelay(-1), const Duration(seconds: 3));
        expect(strategy.calculateDelay(-100), const Duration(seconds: 3));
      });

      test('should have correct description', () {
        // Arrange
        final strategy = FixedDelayStrategy(
          delay: const Duration(seconds: 10),
        );

        // Act & Assert
        expect(strategy.description, 'FixedDelay(10s)');
      });

      test('should support custom delay duration', () {
        // Arrange & Act & Assert
        final strategy1 =
            FixedDelayStrategy(delay: const Duration(milliseconds: 500));
        expect(strategy1.calculateDelay(0), const Duration(milliseconds: 500));

        final strategy2 = FixedDelayStrategy(delay: const Duration(minutes: 1));
        expect(strategy2.calculateDelay(0), const Duration(minutes: 1));

        final strategy3 = FixedDelayStrategy(delay: const Duration(hours: 1));
        expect(strategy3.calculateDelay(0), const Duration(hours: 1));
      });
    });

    group('LinearBackoffStrategy', () {
      test('should calculate correct linear delays', () {
        // Arrange
        final strategy = LinearBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          increment: const Duration(seconds: 2),
          maxDelay: const Duration(minutes: 1),
          jitterFactor: 0.0,
          random: FixedRandom(0.5),
        );

        // Act & Assert
        // Attempt 0: 1s + (2s * 0) = 1s
        expect(strategy.calculateDelay(0), const Duration(seconds: 1));

        // Attempt 1: 1s + (2s * 1) = 3s
        expect(strategy.calculateDelay(1), const Duration(seconds: 3));

        // Attempt 2: 1s + (2s * 2) = 5s
        expect(strategy.calculateDelay(2), const Duration(seconds: 5));

        // Attempt 3: 1s + (2s * 3) = 7s
        expect(strategy.calculateDelay(3), const Duration(seconds: 7));
      });

      test('should cap delay at maxDelay', () {
        // Arrange
        final strategy = LinearBackoffStrategy(
          baseDelay: const Duration(seconds: 10),
          increment: const Duration(seconds: 10),
          maxDelay: const Duration(seconds: 25),
          jitterFactor: 0.0,
          random: FixedRandom(0.5),
        );

        // Act & Assert
        // Attempt 0: 10s
        expect(strategy.calculateDelay(0), const Duration(seconds: 10));

        // Attempt 1: 20s
        expect(strategy.calculateDelay(1), const Duration(seconds: 20));

        // Attempt 2: Would be 30s but capped at 25s
        expect(strategy.calculateDelay(2), const Duration(seconds: 25));

        // Attempt 3: Would be 40s but capped at 25s
        expect(strategy.calculateDelay(3), const Duration(seconds: 25));
      });

      test('should add jitter to delay', () {
        // Arrange
        final strategy = LinearBackoffStrategy(
          baseDelay: const Duration(seconds: 5),
          increment: const Duration(seconds: 2),
          maxDelay: const Duration(minutes: 1),
          jitterFactor: 0.4, // 40% jitter
          random: FixedRandom(1.0), // Returns 1.0, so jitter = +40%
        );

        // Act
        final delay = strategy.calculateDelay(1); // Base: 7s

        // Assert: 7s * 1.4 = 9.8s
        expect(delay.inMilliseconds, greaterThan(7000));
        expect(delay.inMilliseconds, lessThan(10000));
      });

      test('should handle zero jitter factor', () {
        // Arrange
        final strategy = LinearBackoffStrategy(
          baseDelay: const Duration(seconds: 2),
          increment: const Duration(seconds: 3),
          jitterFactor: 0.0,
          random: FixedRandom(0.5),
        );

        // Act & Assert
        // Without jitter, delays should be exact
        expect(strategy.calculateDelay(0), const Duration(seconds: 2));
        expect(strategy.calculateDelay(1), const Duration(seconds: 5));
        expect(strategy.calculateDelay(2), const Duration(seconds: 8));
      });

      test('should handle negative attempt count gracefully', () {
        // Arrange
        final strategy = LinearBackoffStrategy(
          baseDelay: const Duration(seconds: 5),
          increment: const Duration(seconds: 2),
          random: FixedRandom(0.5),
        );

        // Act
        final delay = strategy.calculateDelay(-1);

        // Assert: Should treat negative as 0
        expect(delay, const Duration(seconds: 5));
      });

      test('should prevent delay from going negative with jitter', () {
        // Arrange
        final strategy = LinearBackoffStrategy(
          baseDelay: const Duration(milliseconds: 100),
          increment: const Duration(milliseconds: 50),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 1.0, // 100% jitter
          random: FixedRandom(0.0), // Returns 0.0, so jitter = -100%
        );

        // Act
        final delay = strategy.calculateDelay(0);

        // Assert: Even with -100% jitter, should not go below 0
        expect(delay.inMilliseconds, greaterThanOrEqualTo(0));
      });

      test('should have correct description', () {
        // Arrange
        final strategy = LinearBackoffStrategy(
          baseDelay: const Duration(seconds: 2),
          increment: const Duration(seconds: 3),
          maxDelay: const Duration(minutes: 2),
          jitterFactor: 0.15,
        );

        // Act & Assert
        expect(
          strategy.description,
          'LinearBackoff(baseDelay: 2s, increment: 3s, maxDelay: 120s, jitter: 15%)',
        );
      });

      test('should validate jitter factor bounds', () {
        // Arrange & Act & Assert
        expect(
          () => LinearBackoffStrategy(jitterFactor: -0.1),
          throwsAssertionError,
        );

        expect(
          () => LinearBackoffStrategy(jitterFactor: 1.1),
          throwsAssertionError,
        );

        // Valid values should not throw
        expect(() => LinearBackoffStrategy(jitterFactor: 0.0), returnsNormally);
        expect(() => LinearBackoffStrategy(jitterFactor: 0.5), returnsNormally);
        expect(() => LinearBackoffStrategy(jitterFactor: 1.0), returnsNormally);
      });

      test('should not exceed maxDelay even with high attempt count', () {
        // Arrange
        final strategy = LinearBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          increment: const Duration(seconds: 10),
          maxDelay: const Duration(seconds: 30),
          jitterFactor: 0.0,
          random: FixedRandom(0.5),
        );

        // Act & Assert
        for (int attempt = 0; attempt < 10; attempt++) {
          final delay = strategy.calculateDelay(attempt);
          expect(
            delay.inSeconds,
            lessThanOrEqualTo(30),
            reason: 'Attempt $attempt exceeded maxDelay',
          );
        }
      });
    });

    group('Strategy Comparison', () {
      test('exponential should grow faster than linear', () {
        // Arrange
        final exponential = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          jitterFactor: 0.0,
          random: FixedRandom(0.5),
        );
        final linear = LinearBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          increment: const Duration(seconds: 2),
          jitterFactor: 0.0,
          random: FixedRandom(0.5),
        );

        // Act & Assert
        // Early attempts: linear may be faster
        expect(
          exponential.calculateDelay(0).inSeconds,
          lessThanOrEqualTo(linear.calculateDelay(0).inSeconds),
        );

        // Later attempts: exponential should overtake
        expect(
          exponential.calculateDelay(5).inSeconds,
          greaterThan(linear.calculateDelay(5).inSeconds),
        );

        expect(
          exponential.calculateDelay(10).inSeconds,
          greaterThan(linear.calculateDelay(10).inSeconds),
        );
      });

      test('fixed should be consistent', () {
        // Arrange
        final fixed = FixedDelayStrategy(delay: const Duration(seconds: 5));
        final exponential = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          jitterFactor: 0.0,
          random: FixedRandom(0.5),
        );

        // Act & Assert
        // Fixed should always return the same value
        expect(fixed.calculateDelay(0), fixed.calculateDelay(10));

        // Exponential should vary
        expect(
          exponential.calculateDelay(0),
          isNot(equals(exponential.calculateDelay(5))),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle very large attempt counts', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(milliseconds: 1),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 0.0,
          random: FixedRandom(0.5),
        );

        // Act & Assert
        // Even with very large attempt count, should not throw
        expect(() => strategy.calculateDelay(1000), returnsNormally);
        expect(strategy.calculateDelay(1000), const Duration(minutes: 5));
      });

      test('should handle millisecond precision', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(milliseconds: 100),
          jitterFactor: 0.0,
          random: FixedRandom(0.5),
        );

        // Act & Assert
        expect(strategy.calculateDelay(0), const Duration(milliseconds: 100));
        expect(strategy.calculateDelay(1), const Duration(milliseconds: 200));
        expect(strategy.calculateDelay(2), const Duration(milliseconds: 400));
      });

      test('should handle microsecond precision', () {
        // Arrange
        final strategy = FixedDelayStrategy(
          delay: const Duration(microseconds: 1500),
        );

        // Act & Assert
        expect(strategy.calculateDelay(0), const Duration(microseconds: 1500));
      });
    });
  });
}

/// Fixed random generator for testing jitter behavior
class FixedRandom extends Random {
  final double _value;

  FixedRandom(this._value);

  @override
  double nextDouble() => _value;

  @override
  int nextInt(int max) => (_value * max).floor();
}
