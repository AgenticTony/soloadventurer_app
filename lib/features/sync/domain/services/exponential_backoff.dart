/// Helper class for calculating exponential backoff delays for retry operations
///
/// Implements exponential backoff with jitter to prevent thundering herd problem.
/// Delays follow the pattern: 1s, 2s, 4s, 8s, 16s, 32s, 60s (max)
class ExponentialBackoff {
  /// Base delay in milliseconds (1 second)
  final int baseDelayMs;

  /// Maximum delay in milliseconds (60 seconds)
  final int maxDelayMs;

  /// Whether to add jitter to prevent synchronized retries
  final bool withJitter;

  /// Jitter factor (0.0 to 1.0) - adds randomness to delay
  final double jitterFactor;

  /// Creates a new [ExponentialBackoff] instance
  ///
  /// [baseDelayMs] is the initial delay in milliseconds (default: 1000ms = 1s)
  /// [maxDelayMs] is the maximum delay cap in milliseconds (default: 60000ms = 60s)
  /// [withJitter] whether to add random jitter to prevent thundering herd (default: true)
  /// [jitterFactor] controls how much randomness to add (default: 0.1 = ±10%)
  const ExponentialBackoff({
    this.baseDelayMs = 1000,
    this.maxDelayMs = 60000,
    this.withJitter = true,
    this.jitterFactor = 0.1,
  })  : assert(baseDelayMs > 0, 'baseDelayMs must be positive'),
        assert(maxDelayMs >= baseDelayMs, 'maxDelayMs must be >= baseDelayMs'),
        assert(jitterFactor >= 0 && jitterFactor <= 1,
            'jitterFactor must be between 0 and 1');

  /// Default configuration with standard exponential backoff
  static const standard = ExponentialBackoff();

  /// Aggressive backoff with shorter delays
  static const aggressive = ExponentialBackoff(
    baseDelayMs: 500,
    maxDelayMs: 30000,
  );

  /// Conservative backoff with longer delays
  static const conservative = ExponentialBackoff(
    baseDelayMs: 2000,
    maxDelayMs: 120000,
  );

  /// Calculate the delay in milliseconds for a given retry attempt
  ///
  /// [retryCount] is the number of retry attempts that have been made (0-indexed)
  /// Returns the delay in milliseconds before the next retry should occur
  ///
  /// Examples:
  /// - retryCount=0: 1000ms (1s)
  /// - retryCount=1: 2000ms (2s)
  /// - retryCount=2: 4000ms (4s)
  /// - retryCount=3: 8000ms (8s)
  /// - retryCount=4: 16000ms (16s)
  /// - retryCount=5: 32000ms (32s)
  /// - retryCount=6+: 60000ms (60s, capped)
  int calculateDelay(int retryCount) {
    // Calculate exponential delay: baseDelay * 2^retryCount
    final exponentialDelay = baseDelayMs * (1 << retryCount);

    // Cap at max delay
    final cappedDelay =
        exponentialDelay > maxDelayMs ? maxDelayMs : exponentialDelay;

    // Add jitter if enabled
    if (withJitter && jitterFactor > 0) {
      return _addJitter(cappedDelay);
    }

    return cappedDelay;
  }

  /// Calculate the next retry time for a given retry count
  ///
  /// [retryCount] is the number of retry attempts that have been made
  /// [from] is the base time to calculate from (defaults to now)
  /// Returns the DateTime when the next retry should occur
  DateTime calculateNextRetryTime(int retryCount, {DateTime? from}) {
    final base = from ?? DateTime.now();
    final delayMs = calculateDelay(retryCount);
    return base.add(Duration(milliseconds: delayMs));
  }

  /// Calculate remaining delay until retry is ready
  ///
  /// [retryCount] is the number of retry attempts that have been made
  /// [lastAttemptAt] is when the last retry attempt was made
  /// Returns the remaining Duration, or Duration.zero if ready
  Duration calculateRemainingDelay(int retryCount, DateTime lastAttemptAt) {
    final nextRetryTime =
        calculateNextRetryTime(retryCount, from: lastAttemptAt);
    final now = DateTime.now();
    final diff = nextRetryTime.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Add jitter to a delay value to prevent synchronized retries
  ///
  /// Jitter adds or subtracts a random percentage (controlled by [jitterFactor])
  /// This prevents the thundering herd problem where many clients retry simultaneously
  int _addJitter(int delayMs) {
    if (jitterFactor == 0) return delayMs;

    // Calculate jitter range: ±jitterFactor * delay
    final jitterRange = (delayMs * jitterFactor).toInt();

    // Generate random jitter value in range [-jitterRange, +jitterRange]
    final random =
        DateTime.now().millisecondsSinceEpoch % (2 * jitterRange + 1);
    final jitter = random - jitterRange;

    // Apply jitter and ensure non-negative result
    final result = delayMs + jitter;
    return result < 0 ? 0 : result;
  }

  /// Reset the backoff state
  ///
  /// This is a no-op in this stateless implementation, but provided for API compatibility
  /// with potential future stateful implementations
  void reset() {
    // Stateless implementation - no state to reset
  }

  /// Get a human-readable description of the delay for a given retry count
  String getDelayDescription(int retryCount) {
    final delayMs = calculateDelay(retryCount);
    final delaySeconds = (delayMs / 1000).toStringAsFixed(1);

    if (delayMs < maxDelayMs) {
      return 'Retry $retryCount: wait ${delaySeconds}s '
          '${withJitter ? '(±${(jitterFactor * 100).toInt()}% jitter)' : ''}';
    } else {
      return 'Retry $retryCount: wait ${delaySeconds}s (max delay) '
          '${withJitter ? '(±${(jitterFactor * 100).toInt()}% jitter)' : ''}';
    }
  }

  /// Get all delay values up to max attempts
  /// Useful for testing and logging
  List<int> getDelaysForAttempts(int maxAttempts) {
    return List.generate(
      maxAttempts,
      (index) => calculateDelay(index),
      growable: false,
    );
  }

  @override
  String toString() =>
      'ExponentialBackoff(baseDelayMs: $baseDelayMs, maxDelayMs: $maxDelayMs, '
      'withJitter: $withJitter, jitterFactor: $jitterFactor)';
}
