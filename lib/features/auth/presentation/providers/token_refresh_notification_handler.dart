import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';
import 'token_refresh_providers.dart';

part 'token_refresh_notification_handler.g.dart';

/// Notification type for token refresh events
enum TokenRefreshNotificationType {
  /// No notification (silent)
  none,

  /// Info notification
  info,

  /// Warning notification
  warning,

  /// Error notification
  error,
}

/// Notification data for token refresh events
class TokenRefreshNotification {
  /// The type of notification to show
  final TokenRefreshNotificationType type;

  /// The title of the notification
  final String title;

  /// The message to display
  final String message;

  /// Whether to show a retry button
  final bool showRetry;

  /// Whether to show a re-authenticate button
  final bool showReAuth;

  /// The error that caused this notification (if any)
  final String? errorCode;

  const TokenRefreshNotification({
    required this.type,
    required this.title,
    required this.message,
    this.showRetry = false,
    this.showReAuth = false,
    this.errorCode,
  });

  /// Creates a silent notification (no display)
  factory TokenRefreshNotification.silent() {
    return const TokenRefreshNotification(
      type: TokenRefreshNotificationType.none,
      title: '',
      message: '',
    );
  }

  /// Creates an error notification
  factory TokenRefreshNotification.error({
    required String message,
    String? errorCode,
    bool showRetry = true,
    bool showReAuth = true,
  }) {
    return TokenRefreshNotification(
      type: TokenRefreshNotificationType.error,
      title: 'Session Refresh Failed',
      message: message,
      errorCode: errorCode,
      showRetry: showRetry,
      showReAuth: showReAuth,
    );
  }

  /// Creates a warning notification
  factory TokenRefreshNotification.warning({
    required String message,
  }) {
    return TokenRefreshNotification(
      type: TokenRefreshNotificationType.warning,
      title: 'Session Warning',
      message: message,
    );
  }
}

/// State for token refresh notifications
class TokenRefreshNotificationState {
  /// The current notification (if any)
  final TokenRefreshNotification? notification;

  /// Whether a notification is currently being shown
  final bool isShowing;

  const TokenRefreshNotificationState({
    this.notification,
    this.isShowing = false,
  });

  /// Creates a copy with updated fields
  TokenRefreshNotificationState copyWith({
    TokenRefreshNotification? notification,
    bool? isShowing,
  }) {
    return TokenRefreshNotificationState(
      notification: notification ?? this.notification,
      isShowing: isShowing ?? this.isShowing,
    );
  }
}

/// Notifier for handling token refresh notifications
///
/// This notifier listens to the TokenRefreshService status stream
/// and converts refresh events into user-facing notifications.
/// Successful refreshes are silent, while failures show user-friendly
/// error messages with options to retry or re-authenticate.
@riverpod
class TokenRefreshNotificationHandler extends _$TokenRefreshNotificationHandler {
  StreamSubscription<TokenRefreshResult>? _statusSubscription;

  @override
  TokenRefreshNotificationState build() {
    // Listen to token refresh status changes
    final tokenRefreshService = ref.watch(tokenRefreshServiceProvider);

    _statusSubscription = tokenRefreshService.statusStream.listen(
      _handleRefreshStatus,
      onError: (error, stack) {
      },
    );

    ref.onDispose(() {
      _statusSubscription?.cancel();
    });

    return const TokenRefreshNotificationState();
  }

  /// Handles a token refresh status event
  void _handleRefreshStatus(TokenRefreshResult result) {
    final notification = _mapResultToNotification(result);

    if (notification.type != TokenRefreshNotificationType.none) {
      // Show the notification
      state = state.copyWith(
        notification: notification,
        isShowing: true,
      );

      // Auto-clear after a delay (if it's not a critical error)
      if (notification.type != TokenRefreshNotificationType.error) {
        Future.delayed(const Duration(seconds: 5), () {
          // Notifier doesn't have mounted property, rely on ref lifecycle
          clearNotification();
        });
      }
    }
  }

  /// Maps a TokenRefreshResult to an appropriate notification
  TokenRefreshNotification _mapResultToNotification(TokenRefreshResult result) {
    switch (result.status) {
      case TokenRefreshStatus.success:
        // Silent - no notification for successful refresh
        return TokenRefreshNotification.silent();

      case TokenRefreshStatus.inProgress:
        // Silent - in-progress is handled by UI indicators
        return TokenRefreshNotification.silent();

      case TokenRefreshStatus.failure:
        return _createFailureNotification(result);

      case TokenRefreshStatus.cancelled:
        // Silent - cancellation is intentional
        return TokenRefreshNotification.silent();
    }
  }

  /// Creates a user-friendly notification for refresh failure
  TokenRefreshNotification _createFailureNotification(TokenRefreshResult result) {
    final error = result.error;
    final errorCode = error?.code;
    final errorMessage = error?.message ?? 'Unknown error';

    // Determine the user-friendly message based on error code
    String userMessage;
    bool showRetry = true;
    bool showReAuth = false;

    switch (errorCode) {
      case 'NETWORK_ERROR':
      case 'network_connectivity':
      case 'network_timeout':
        userMessage = 'Unable to refresh your session due to network issues. '
            'The app will retry automatically.';
        showRetry = false; // Auto-retry is handled by the service
        showReAuth = false;
        break;

      case 'INVALID_CREDENTIALS':
      case 'USER_NOT_FOUND':
      case 'REFRESH_TOKEN_EXPIRED':
        userMessage = 'Your session has expired. Please sign in again to continue.';
        showRetry = false;
        showReAuth = true;
        break;

      case 'MAX_RETRIES_EXCEEDED':
        userMessage = 'Unable to refresh your session after multiple attempts. '
            'Please check your connection and sign in again.';
        showRetry = false;
        showReAuth = true;
        break;

      default:
        userMessage = errorMessage;
        showRetry = true;
        showReAuth = true;
        break;
    }

    return TokenRefreshNotification.error(
      message: userMessage,
      errorCode: errorCode,
      showRetry: showRetry,
      showReAuth: showReAuth,
    );
  }

  /// Clears the current notification
  void clearNotification() {
    state = state.copyWith(
      notification: null,
      isShowing: false,
    );
  }

  /// Manually trigger a retry (if the notification shows a retry option)
  void retry() {
    // The retry will be handled by the TokenRefreshService
    // Just clear the notification
    clearNotification();
  }

  /// Manually trigger re-authentication (if the notification shows re-auth option)
  void reAuthenticate() {
    // The re-authentication will be handled by the UI layer
    // Just clear the notification
    clearNotification();
  }
}
