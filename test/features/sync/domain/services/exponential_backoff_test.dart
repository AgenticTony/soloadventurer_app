import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/services/exponential_backoff.dart';

void main() {
  group('ExponentialBackoff', () {
    late ExponentialBackoff backoff;

    setUp(() {
      backoff = ExponentialBackoff.standard;
    });

    group('calculateDelay', () {
      test('should calculate exponential delays correctly', () {
        // Retry 0: 1s (1000ms)
        expect(backoff.calculateDelay(0), 1000);

        // Retry 1: 2s (2000ms)
        expect(backoff.calculateDelay(1), 2000);

        // Retry 2: 4s (4000ms)
        expect(backoff.calculateDelay(2), 4000);

        // Retry 3: 8s (8000ms)
        expect(backoff.calculateDelay(3), 8000);

        // Retry 4: 16s (16000ms)
        expect(backoff.calculateDelay(4), 16000);

        // Retry 5: 32s (32000ms)
        expect(backoff.calculateDelay(5), 32000);

        // Retry 6: 60s (60000ms) - capped at max
        expect(backoff.calculateDelay(6), 60000);

        // Retry 7: should still be capped at 60s
        expect(backoff.calculateDelay(7), 60000);

        // Retry 10: should still be capped at 60s
        expect(backoff.calculateDelay(10), 60000);
      });

      test('should respect custom base delay', () {
        const customBackoff = ExponentialBackoff(baseDelayMs: 500);

        // Retry 0: 500ms
        expect(customBackoff.calculateDelay(0), 500);

        // Retry 1: 1000ms
        expect(customBackoff.calculateDelay(1), 1000);

        // Retry 2: 2000ms
        expect(customBackoff.calculateDelay(2), 2000);
      });

      test('should respect custom max delay', () {
        const customBackoff = ExponentialBackoff(
          baseDelayMs: 1000,
          maxDelayMs: 30000,
        );

        // Retry 0: 1s
        expect(customBackoff.calculateDelay(0), 1000);

        // Retry 1: 2s
        expect(customBackoff.calculateDelay(1), 2000);

        // Retry 2: 4s
        expect(customBackoff.calculateDelay(2), 4000);

        // Retry 3: 8s
        expect(customBackoff.calculateDelay(3), 8000);

        // Retry 4: 16s
        expect(customBackoff.calculateDelay(4), 16000);

        // Retry 5: 30s (capped at max)
        expect(customBackoff.calculateDelay(5), 30000);

        // Retry 6: should still be capped at 30s
        expect(customBackoff.calculateDelay(6), 30000);
      });

      test('should add jitter when enabled', () {
        const backoffWithJitter = ExponentialBackoff(
          withJitter: true,
          jitterFactor: 0.1,
        );

        // With jitter, the delay should be within ±10% of the base delay
        const baseDelay = 1000;
        final delayWithJitter = backoffWithJitter.calculateDelay(0);

        // Allow ±10% variance
        final minExpected = (baseDelay * 0.9).floor();
        final maxExpected = (baseDelay * 1.1).ceil();

        expect(delayWithJitter, greaterThanOrEqualTo(minExpected));
        expect(delayWithJitter, lessThanOrEqualTo(maxExpected));
      });

      test('should not add jitter when disabled', () {
        const backoffNoJitter = ExponentialBackoff(withJitter: false);

        expect(backoffNoJitter.calculateDelay(0), 1000);
        expect(backoffNoJitter.calculateDelay(1), 2000);
        expect(backoffNoJitter.calculateDelay(2), 4000);
      });

      test('should handle zero jitter factor', () {
        const backoff = ExponentialBackoff(
          withJitter: true,
          jitterFactor: 0.0,
        );

        expect(backoff.calculateDelay(0), 1000);
        expect(backoff.calculateDelay(1), 2000);
      });

      test('should get delays for multiple attempts', () {
        final delays = backoff.getDelaysForAttempts(8);

        expect(delays.length, 8);
        expect(delays[0], 1000); // 1s
        expect(delays[1], 2000); // 2s
        expect(delays[2], 4000); // 4s
        expect(delays[3], 8000); // 8s
        expect(delays[4], 16000); // 16s
        expect(delays[5], 32000); // 32s
        expect(delays[6], 60000); // 60s (capped)
        expect(delays[7], 60000); // 60s (capped)
      });
    });

    group('calculateNextRetryTime', () {
      test('should calculate next retry time from base time', () {
        final baseTime = DateTime(2026, 1, 5, 12, 0, 0);

        // Retry 0: 1 second later
        final retry0 = backoff.calculateNextRetryTime(0, from: baseTime);
        expect(retry0, DateTime(2026, 1, 5, 12, 0, 1));

        // Retry 1: 2 seconds later
        final retry1 = backoff.calculateNextRetryTime(1, from: baseTime);
        expect(retry1, DateTime(2026, 1, 5, 12, 0, 2));

        // Retry 2: 4 seconds later
        final retry2 = backoff.calculateNextRetryTime(2, from: baseTime);
        expect(retry2, DateTime(2026, 1, 5, 12, 0, 4));
      });

      test('should use current time if no base time provided', () {
        final before = DateTime.now();
        final retryTime = backoff.calculateNextRetryTime(0);
        final after = DateTime.now();

        // Should be approximately 1 second from now
        final expectedMin = before.add(const Duration(seconds: 1));
        final expectedMax = after.add(const Duration(seconds: 1));

        expect(
            retryTime.isAfter(
                expectedMin.subtract(const Duration(milliseconds: 100))),
            true);
        expect(
            retryTime
                .isBefore(expectedMax.add(const Duration(milliseconds: 100))),
            true);
      });
    });

    group('calculateRemainingDelay', () {
      test('should calculate remaining delay until next retry', () {
        final lastAttempt = DateTime(2026, 1, 5, 12, 0, 0);

        // Immediately after attempt
        final remaining0 = backoff.calculateRemainingDelay(0, lastAttempt);
        expect(remaining0.inSeconds, greaterThanOrEqualTo(1));
        expect(remaining0.inSeconds, lessThanOrEqualTo(2));

        // 0.5 seconds after attempt for retry 0 (1s delay)
        final halfSecondLater = DateTime(2026, 1, 5, 12, 0, 0, 500);
        final remaining1 = backoff.calculateRemainingDelay(0, halfSecondLater);
        expect(remaining1.inMilliseconds, greaterThan(400));
        expect(remaining1.inMilliseconds, lessThan(600));
      });

      test('should return Duration.zero if retry time has passed', () {
        final lastAttempt = DateTime(2026, 1, 5, 12, 0, 0);

        // 2 seconds after attempt for retry 0 (1s delay)
        final twoSecondsLater = DateTime(2026, 1, 5, 12, 0, 2);
        final remaining = backoff.calculateRemainingDelay(0, twoSecondsLater);

        expect(remaining, Duration.zero);
      });
    });

    group('predefined configurations', () {
      test('standard configuration should have standard delays', () {
        const standard = ExponentialBackoff.standard;

        expect(standard.baseDelayMs, 1000);
        expect(standard.maxDelayMs, 60000);
        expect(standard.calculateDelay(0), 1000);
        expect(standard.calculateDelay(6), 60000);
      });

      test('aggressive configuration should have shorter delays', () {
        const aggressive = ExponentialBackoff.aggressive;

        expect(aggressive.baseDelayMs, 500);
        expect(aggressive.maxDelayMs, 30000);
        expect(aggressive.calculateDelay(0), 500);
        expect(aggressive.calculateDelay(6), 30000);
      });

      test('conservative configuration should have longer delays', () {
        const conservative = ExponentialBackoff.conservative;

        expect(conservative.baseDelayMs, 2000);
        expect(conservative.maxDelayMs, 120000);
        expect(conservative.calculateDelay(0), 2000);
        expect(conservative.calculateDelay(6), 120000);
      });
    });

    group('getDelayDescription', () {
      test('should provide human-readable delay descriptions', () {
        final desc0 = backoff.getDelayDescription(0);
        expect(desc0, contains('Retry 0'));
        expect(desc0, contains('1.0s'));

        final desc1 = backoff.getDelayDescription(1);
        expect(desc1, contains('Retry 1'));
        expect(desc1, contains('2.0s'));

        final desc6 = backoff.getDelayDescription(6);
        expect(desc6, contains('Retry 6'));
        expect(desc6, contains('60.0s'));
        expect(desc6, contains('max delay'));
      });

      test('should mention jitter in description when enabled', () {
        const backoffWithJitter =
            ExponentialBackoff(withJitter: true, jitterFactor: 0.1);
        final desc = backoffWithJitter.getDelayDescription(0);

        expect(desc, contains('jitter'));
        expect(desc, contains('±10%'));
      });

      test('should not mention jitter when disabled', () {
        const backoffNoJitter = ExponentialBackoff(withJitter: false);
        final desc = backoffNoJitter.getDelayDescription(0);

        expect(desc, isNot(contains('jitter')));
      });
    });

    group('validation', () {
      test('should throw on negative base delay', () {
        expect(
          () => ExponentialBackoff(baseDelayMs: -1),
          throwsAssertionError,
        );
      });

      test('should throw on zero base delay', () {
        expect(
          () => ExponentialBackoff(baseDelayMs: 0),
          throwsAssertionError,
        );
      });

      test('should throw when max delay is less than base delay', () {
        expect(
          () => ExponentialBackoff(baseDelayMs: 1000, maxDelayMs: 500),
          throwsAssertionError,
        );
      });

      test('should throw on negative jitter factor', () {
        expect(
          () => ExponentialBackoff(jitterFactor: -0.1),
          throwsAssertionError,
        );
      });

      test('should throw on jitter factor greater than 1', () {
        expect(
          () => ExponentialBackoff(jitterFactor: 1.1),
          throwsAssertionError,
        );
      });
    });

    group('toString', () {
      test('should provide useful string representation', () {
        final str = backoff.toString();

        expect(str, contains('ExponentialBackoff'));
        expect(str, contains('baseDelayMs: 1000'));
        expect(str, contains('maxDelayMs: 60000'));
        expect(str, contains('withJitter: true'));
      });
    });

    group('reset', () {
      test('reset should be callable (no-op for stateless implementation)', () {
        // Should not throw
        backoff.reset();

        // Delays should still work the same
        expect(backoff.calculateDelay(0), 1000);
        expect(backoff.calculateDelay(1), 2000);
      });
    });
  });
}
