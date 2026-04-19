import 'package:flutter/widgets.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_expiration_tracker.dart';

/// Status of the token refresh scheduler
enum TokenRefreshSchedulerStatus {
  /// Scheduler is stopped and not monitoring
  stopped,

  /// Scheduler is actively monitoring and scheduling refreshes
  running,

  /// Scheduler is paused (e.g., app is in background)
  paused,
}

/// Scheduler for token refresh operations with app lifecycle awareness
///
/// This service manages token refresh scheduling by:
/// - Scheduling refresh at 75% of token lifetime (via TokenExpirationTracker)
/// - Respecting app lifecycle (pauses when app is backgrounded)
/// - Waking up when app returns to foreground
/// - Handling edge cases (app killed, network loss)
class TokenRefreshScheduler extends WidgetsBindingObserver {
  /// Tracker for monitoring token expiration
  final TokenExpirationTracker _expirationTracker;

  /// Current status of the scheduler
  TokenRefreshSchedulerStatus _status = TokenRefreshSchedulerStatus.stopped;

  /// Current auth session being monitored
  AuthSession? _currentSession;

  /// Binding observer registration flag
  bool _isObserverRegistered = false;

  /// Creates a new [TokenRefreshScheduler]
  TokenRefreshScheduler({
    required TokenExpirationTracker expirationTracker,
  }) : _expirationTracker = expirationTracker;

  /// Current status of the scheduler
  TokenRefreshSchedulerStatus get status => _status;

  /// Whether the scheduler is actively running
  bool get isRunning => _status == TokenRefreshSchedulerStatus.running;

  /// Whether the scheduler is paused
  bool get isPaused => _status == TokenRefreshSchedulerStatus.paused;

  /// Starts monitoring the token expiration for the given session
  ///
  /// This will schedule a refresh at 75% of the token lifetime and
  /// register the app lifecycle observer to pause/resume monitoring.
  void start(AuthSession session) {

    _currentSession = session;

    // Register as observer if not already registered
    if (!_isObserverRegistered) {
      WidgetsBinding.instance.addObserver(this);
      _isObserverRegistered = true;
    }

    // Start tracking with the expiration tracker
    _expirationTracker.startTracking(session);
    _status = TokenRefreshSchedulerStatus.running;

  }

  /// Stops monitoring token expiration
  ///
  /// This will cancel any pending refresh operations and unregister
  /// the app lifecycle observer.
  void stop() {

    _status = TokenRefreshSchedulerStatus.stopped;
    _currentSession = null;

    // Stop tracking with the expiration tracker
    _expirationTracker.stopTracking();

    // Unregister observer
    if (_isObserverRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _isObserverRegistered = false;
    }

  }

  /// Pauses the scheduler (e.g., when app goes to background)
  ///
  /// This keeps the session but stops the refresh timer.
  void pause() {
    if (_status != TokenRefreshSchedulerStatus.running) {
      return;
    }

    _status = TokenRefreshSchedulerStatus.paused;

    // Stop the tracking timer but keep the session
    _expirationTracker.stopTracking();

  }

  /// Resumes the scheduler (e.g., when app returns to foreground)
  ///
  /// This restarts the refresh timer with the retained session.
  void resume() {
    if (_status != TokenRefreshSchedulerStatus.paused) {
      return;
    }

    if (_currentSession == null) {
      return;
    }

    // Restart tracking with the retained session
    _expirationTracker.startTracking(_currentSession!);
    _status = TokenRefreshSchedulerStatus.running;

  }

  /// Handles app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    switch (state) {
      case AppLifecycleState.resumed:
        // App returned to foreground
        _handleAppResumed();
        break;

      case AppLifecycleState.inactive:
        // App is inactive (e.g., during a phone call)
        pause();
        break;

      case AppLifecycleState.paused:
        // App went to background
        pause();
        break;

      case AppLifecycleState.detached:
        // App is being destroyed
        stop();
        break;

      case AppLifecycleState.hidden:
        // App is hidden (same as background on most platforms)
        pause();
        break;
    }
  }

  /// Handles app resume event
  void _handleAppResumed() {
    if (_currentSession == null) {
      return;
    }

    // Check if token needs immediate refresh
    final expirationResult =
        _expirationTracker.checkExpiration(_currentSession!);

    if (expirationResult.isExpired) {
      // Resume will trigger immediate refresh if needed
    } else if (expirationResult.shouldRefresh) {
      // Resume will schedule refresh appropriately
    } else {
      expirationResult.timeUntilRefresh?.inMinutes ?? 0;
    }

    // Resume the scheduler
    resume();
  }

  /// Updates the monitored session
  ///
  /// Use this when the session is updated externally (e.g., after a manual refresh).
  /// This will reschedule the refresh timer based on the new expiration time.
  void updateSession(AuthSession session) {

    _currentSession = session;

    if (_status == TokenRefreshSchedulerStatus.running) {
      // Update the tracker if we're running
      _expirationTracker.updateSession(session);
    } else if (_status == TokenRefreshSchedulerStatus.paused) {
      // Just update the session, don't start tracking while paused
    }
  }

  /// Checks the expiration status of the current session
  ///
  /// Returns null if no session is being monitored.
  TokenExpirationResult? checkExpiration() {
    if (_currentSession == null) {
      return null;
    }

    return _expirationTracker.checkExpiration(_currentSession!);
  }

  /// Disposes of the scheduler and cleans up resources
  void dispose() {
    stop();
  }

  /// Resets the scheduler state (useful for testing)
  void reset() {
    stop();
  }
}
