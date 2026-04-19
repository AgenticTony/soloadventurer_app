import 'dart:async';
import 'package:clock/clock.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';

/// Result of a token expiration check
class TokenExpirationResult {
  /// Whether the token is expired
  final bool isExpired;

  /// Whether the token should be refreshed now
  final bool shouldRefresh;

  /// Time until token expiration (null if already expired or no expiration)
  final Duration? timeUntilExpiration;

  /// Time until refresh should be triggered (null if already expired or no expiration)
  final Duration? timeUntilRefresh;

  /// The expiration time (null if not available)
  final DateTime? expirationTime;

  const TokenExpirationResult({
    required this.isExpired,
    required this.shouldRefresh,
    this.timeUntilExpiration,
    this.timeUntilRefresh,
    this.expirationTime,
  });

  /// Creates a result for an expired token
  factory TokenExpirationResult.expired({
    required DateTime expirationTime,
  }) {
    final now = clock.now();
    return TokenExpirationResult(
      isExpired: true,
      shouldRefresh: true,
      timeUntilExpiration: now.difference(expirationTime),
      timeUntilRefresh: Duration.zero,
      expirationTime: expirationTime,
    );
  }

  /// Creates a result for a token that should be refreshed
  factory TokenExpirationResult.shouldRefreshNow({
    required DateTime expirationTime,
    required Duration timeUntilExpiration,
    required Duration timeUntilRefresh,
  }) {
    return TokenExpirationResult(
      isExpired: false,
      shouldRefresh: true,
      timeUntilExpiration: timeUntilExpiration,
      timeUntilRefresh: timeUntilRefresh,
      expirationTime: expirationTime,
    );
  }

  /// Creates a result for a valid token
  factory TokenExpirationResult.valid({
    required DateTime expirationTime,
    required Duration timeUntilExpiration,
    required Duration timeUntilRefresh,
  }) {
    return TokenExpirationResult(
      isExpired: false,
      shouldRefresh: false,
      timeUntilExpiration: timeUntilExpiration,
      timeUntilRefresh: timeUntilRefresh,
      expirationTime: expirationTime,
    );
  }

  /// Creates a result for a token with no expiration information
  factory TokenExpirationResult.noExpiration() {
    return const TokenExpirationResult(
      isExpired: false,
      shouldRefresh: false,
      timeUntilExpiration: null,
      timeUntilRefresh: null,
      expirationTime: null,
    );
  }

  @override
  String toString() {
    return 'TokenExpirationResult{isExpired: $isExpired, shouldRefresh: $shouldRefresh, '
        'timeUntilExpiration: $timeUntilExpiration, timeUntilRefresh: $timeUntilRefresh}';
  }
}

/// Service for tracking token expiration time and triggering proactive refresh
///
/// This service monitors authentication token expiration and:
/// - Calculates time until token expiration
/// - Triggers refresh at 75% of token lifetime
/// - Handles edge cases (missing expiration, already expired)
/// - Integrates with TokenRefreshService for automatic refresh
class TokenExpirationTracker {
  /// Service for performing token refresh operations
  final TokenRefreshService _refreshService;

  /// Refresh threshold as a percentage of token lifetime (default: 75%)
  final double refreshThreshold;

  /// Timer for scheduled refresh operations
  Timer? _refreshTimer;

  /// Current auth session being tracked
  AuthSession? _currentSession;

  /// Whether the tracker is actively monitoring
  bool _isMonitoring = false;

  /// Creates a new [TokenExpirationTracker]
  ///
  /// [refreshThreshold] is the percentage of token lifetime after which
  /// refresh should be triggered (0.0 to 1.0, default 0.75 for 75%)
  TokenExpirationTracker({
    required TokenRefreshService refreshService,
    this.refreshThreshold = 0.75,
  })  : _refreshService = refreshService,
        assert(refreshThreshold > 0.0 && refreshThreshold < 1.0,
            'refreshThreshold must be between 0.0 and 1.0');

  /// Whether the tracker is actively monitoring a session
  bool get isMonitoring => _isMonitoring;

  /// Starts tracking the token expiration for the given session
  ///
  /// This will schedule a refresh at 75% of the token lifetime.
  /// If a refresh is already scheduled, it will be cancelled and rescheduled.
  void startTracking(AuthSession session) {

    _currentSession = session;
    _isMonitoring = true;

    // Cancel any existing timer
    _refreshTimer?.cancel();

    // Calculate when to refresh
    final result = checkExpiration(session);

    if (result.shouldRefresh) {
      // Token is already expired or should be refreshed now
      _scheduleRefresh(Duration.zero);
    } else if (result.timeUntilRefresh != null) {
      // Schedule refresh for the future
      _scheduleRefresh(result.timeUntilRefresh!);
    } else {
    }
  }

  /// Stops tracking token expiration
  ///
  /// This will cancel any pending refresh operations.
  void stopTracking() {

    _isMonitoring = false;
    _currentSession = null;
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Checks the expiration status of a token
  ///
  /// Returns a [TokenExpirationResult] with information about the token's
  /// expiration status and whether it should be refreshed.
  TokenExpirationResult checkExpiration(AuthSession session) {
    final expirationTime = session.expiresAt;
    final now = clock.now();

    // Edge case: missing expiration time
    if (expirationTime == DateTime(0)) {
      return TokenExpirationResult.noExpiration();
    }

    // Calculate time until expiration
    final timeUntilExpiration = expirationTime.difference(now);

    // Check if token is already expired
    if (timeUntilExpiration.isNegative) {
      return TokenExpirationResult.expired(expirationTime: expirationTime);
    }

    // Calculate token lifetime for refresh threshold
    // Assuming token was issued 1 hour before expiration (Cognito default)
    // This is a reasonable default for most JWT tokens
    const assumedTokenLifetime = Duration(hours: 1);

    // Calculate time until refresh (at 75% of lifetime)
    final refreshBeforeExpiration = Duration(
      microseconds:
          (assumedTokenLifetime.inMicroseconds * refreshThreshold).round(),
    );

    final timeUntilRefresh = timeUntilExpiration - refreshBeforeExpiration;

    // Check if we should refresh now
    if (timeUntilRefresh.isNegative) {

      return TokenExpirationResult.shouldRefreshNow(
        expirationTime: expirationTime,
        timeUntilExpiration: timeUntilExpiration,
        timeUntilRefresh: Duration.zero,
      );
    }

    // Token is still valid

    return TokenExpirationResult.valid(
      expirationTime: expirationTime,
      timeUntilExpiration: timeUntilExpiration,
      timeUntilRefresh: timeUntilRefresh,
    );
  }

  /// Calculates the time until a token expires
  ///
  /// Returns null if the token has no expiration information.
  /// Returns a negative Duration if the token is already expired.
  Duration? getTimeUntilExpiration(AuthSession session) {
    final expirationTime = session.expiresAt;

    if (expirationTime == DateTime(0)) {
      return null;
    }

    return expirationTime.difference(clock.now());
  }

  /// Checks if a token is expired
  bool isTokenExpired(AuthSession session) {
    final timeUntilExpiration = getTimeUntilExpiration(session);

    if (timeUntilExpiration == null) {
      // No expiration information, assume not expired
      return false;
    }

    return timeUntilExpiration.isNegative;
  }

  /// Checks if a token should be refreshed based on the refresh threshold
  bool shouldRefreshToken(AuthSession session) {
    final result = checkExpiration(session);
    return result.shouldRefresh;
  }

  /// Schedules a refresh operation
  void _scheduleRefresh(Duration delay) {
    // Cancel any existing timer
    _refreshTimer?.cancel();

    if (delay == Duration.zero) {
      // Refresh immediately
      _performRefresh();
    } else {
      // Schedule refresh for the future
      _refreshTimer = Timer(delay, _performRefresh);
    }
  }

  /// Performs the token refresh operation
  Future<void> _performRefresh() async {
    if (!_isMonitoring || _currentSession == null) {
      return;
    }

    // Check if we're still within the refresh window
    final result = checkExpiration(_currentSession!);
    if (!result.shouldRefresh) {
      // Reschedule based on new timing
      if (result.timeUntilRefresh != null) {
        _scheduleRefresh(result.timeUntilRefresh!);
      }
      return;
    }

    try {
      // Use the TokenRefreshService to perform the refresh
      final newSession = await _refreshService.refreshToken();

      // Update the current session and reschedule
      _currentSession = newSession;
      startTracking(newSession);
    } on AuthException catch (_) {

      // Retry with exponential backoff
      final retryDelay = _calculateRetryDelay();
      _scheduleRefresh(retryDelay);
    } catch (e) {

      // Retry with exponential backoff
      final retryDelay = _calculateRetryDelay();
      _scheduleRefresh(retryDelay);
    }
  }

  /// Calculates retry delay with exponential backoff
  Duration _calculateRetryDelay() {
    // Simple exponential backoff: 30s, 60s, 120s, 300s (5 min max)
    const baseDelay = Duration(seconds: 30);

    // For now, use a fixed delay. In a more sophisticated implementation,
    // we could track the number of consecutive failures and increase delay.
    return baseDelay;
  }

  /// Updates the tracked session
  ///
  /// Use this when the session is updated externally (e.g., after a manual refresh).
  /// This will reschedule the refresh timer based on the new expiration time.
  void updateSession(AuthSession session) {
    if (_isMonitoring) {
      startTracking(session);
    }
  }

  /// Disposes of the tracker and cancels any pending operations
  void dispose() {
    stopTracking();
  }

  /// Resets the tracker state (useful for testing)
  void reset() {
    stopTracking();
  }
}
