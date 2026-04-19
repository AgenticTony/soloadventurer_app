import 'dart:math';

/// Base class for retry strategies that calculate delay between retry attempts
abstract class RetryStrategy {
  /// Calculate the delay duration before the next retry attempt
  ///
  /// [attemptCount] The number of attempts already made (0-indexed)
  /// Returns the duration to wait before the next attempt
  Duration calculateDelay(int attemptCount);

  /// Get a description of this retry strategy for debugging/logging
  String get description;
}

/// Exponential backoff strategy with jitter to prevent thundering herd
///
/// This strategy exponentially increases the delay between retries based on
/// the attempt count, with added randomness (jitter) to prevent multiple
/// operations from retrying at the exact same time.
///
/// Formula: min(baseDelay * 2^attemptCount + jitter, maxDelay)
class ExponentialBackoffStrategy extends RetryStrategy {
  /// The base delay before the first retry
  final Duration baseDelay;

  /// The maximum delay cap to prevent excessively long waits
  final Duration maxDelay;

  /// Jitter factor as a percentage (0.0 to 1.0)
  /// Default 0.1 means up to 10% random variation
  final double jitterFactor;

  /// Random number generator for jitter calculation
  final Random _random;

  /// Creates an exponential backoff strategy
  ///
  /// [baseDelay] The starting delay (default: 1 second)
  /// [maxDelay] The maximum allowed delay (default: 5 minutes)
  /// [jitterFactor] Random variation as percentage 0.0-1.0 (default: 0.1)
  /// [random] Optional custom random generator (for testing)
  ExponentialBackoffStrategy({
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(minutes: 5),
    this.jitterFactor = 0.1,
    Random? random,
  })  : _random = random ?? Random(),
        assert(jitterFactor >= 0.0 && jitterFactor <= 1.0,
            'jitterFactor must be between 0.0 and 1.0');

  @override
  Duration calculateDelay(int attemptCount) {
    if (attemptCount < 0) {
      attemptCount = 0;
    }

    // Cap attemptCount to avoid overflow in pow(2, n)
    final effectiveAttempt = attemptCount.clamp(0, 62);

    // Calculate exponential backoff: baseDelay * 2^attemptCount
    final exponentialDelay = baseDelay.inMilliseconds * pow(2, effectiveAttempt);

    // Calculate jitter: random value between -jitterFactor and +jitterFactor
    final jitterRange = exponentialDelay * jitterFactor;
    final jitter = (_random.nextDouble() * 2 - 1) * jitterRange;

    // Apply jitter and ensure we don't go below zero
    final delayWithJitter = max(0, (exponentialDelay + jitter).round());

    // Cap at maxDelay to prevent excessively long waits
    final cappedDelay = min(delayWithJitter, maxDelay.inMilliseconds);

    final result = Duration(milliseconds: cappedDelay);

    return result;
  }

  @override
  String get description =>
      'ExponentialBackoff(baseDelay: ${baseDelay.inSeconds}s, '
      'maxDelay: ${maxDelay.inMinutes}m, jitter: ${(jitterFactor * 100).toInt()}%)';
}

/// Fixed delay strategy for consistent retry intervals
///
/// This strategy always returns the same delay regardless of attempt count.
/// Useful for operations that should retry at regular intervals or for
/// specific scenarios where exponential backoff is not appropriate.
class FixedDelayStrategy extends RetryStrategy {
  /// The fixed delay between retry attempts
  final Duration delay;

  /// Creates a fixed delay strategy
  ///
  /// [delay] The constant delay between retries (default: 5 seconds)
  FixedDelayStrategy({
    this.delay = const Duration(seconds: 5),
  });

  @override
  Duration calculateDelay(int attemptCount) {
    if (attemptCount < 0) {
    }

    return delay;
  }

  @override
  String get description => 'FixedDelay(${delay.inSeconds}s)';
}

/// Linear backoff strategy with optional jitter
///
/// This strategy increases delay linearly with each attempt.
/// Less aggressive than exponential backoff but still provides
/// increasing delays.
///
/// Formula: min(baseDelay + (increment * attemptCount) + jitter, maxDelay)
class LinearBackoffStrategy extends RetryStrategy {
  /// The base delay before the first retry
  final Duration baseDelay;

  /// The amount to increase delay for each attempt
  final Duration increment;

  /// The maximum delay cap
  final Duration maxDelay;

  /// Jitter factor as a percentage (0.0 to 1.0)
  final double jitterFactor;

  /// Random number generator for jitter calculation
  final Random _random;

  /// Creates a linear backoff strategy
  ///
  /// [baseDelay] The starting delay (default: 1 second)
  /// [increment] Delay increase per attempt (default: 2 seconds)
  /// [maxDelay] The maximum allowed delay (default: 1 minute)
  /// [jitterFactor] Random variation as percentage 0.0-1.0 (default: 0.1)
  /// [random] Optional custom random generator (for testing)
  LinearBackoffStrategy({
    this.baseDelay = const Duration(seconds: 1),
    this.increment = const Duration(seconds: 2),
    this.maxDelay = const Duration(minutes: 1),
    this.jitterFactor = 0.1,
    Random? random,
  })  : _random = random ?? Random(),
        assert(jitterFactor >= 0.0 && jitterFactor <= 1.0,
            'jitterFactor must be between 0.0 and 1.0');

  @override
  Duration calculateDelay(int attemptCount) {
    if (attemptCount < 0) {
      attemptCount = 0;
    }

    // Calculate linear backoff: baseDelay + (increment * attemptCount)
    final linearDelay =
        baseDelay.inMilliseconds + (increment.inMilliseconds * attemptCount);

    // Calculate and apply jitter
    final jitterRange = linearDelay * jitterFactor;
    final jitter = (_random.nextDouble() * 2 - 1) * jitterRange;

    final delayWithJitter = max(0, (linearDelay + jitter).round());

    // Cap at maxDelay
    final cappedDelay = min(delayWithJitter, maxDelay.inMilliseconds);

    final result = Duration(milliseconds: cappedDelay);

    return result;
  }

  @override
  String get description => 'LinearBackoff(baseDelay: ${baseDelay.inSeconds}s, '
      'increment: ${increment.inSeconds}s, maxDelay: ${maxDelay.inSeconds}s, '
      'jitter: ${(jitterFactor * 100).toInt()}%)';
}
