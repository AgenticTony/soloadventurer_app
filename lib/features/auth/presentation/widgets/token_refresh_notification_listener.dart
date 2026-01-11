import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/token_refresh_notification_handler.dart';

/// Widget that listens to token refresh notifications and displays them
///
/// This widget should be placed high in the widget tree (e.g., in MaterialApp's
/// builder or in a root widget) to ensure notifications are shown regardless
/// of the current screen/route.
///
/// Successful refreshes are silent (no notification).
/// Failures show user-friendly error messages with retry/re-auth options.
class TokenRefreshNotificationListener extends ConsumerStatefulWidget {
  /// The child widget beneath this listener
  final Widget child;

  /// Creates a new [TokenRefreshNotificationListener]
  const TokenRefreshNotificationListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<TokenRefreshNotificationListener> createState() =>
      _TokenRefreshNotificationListenerState();
}

class _TokenRefreshNotificationListenerState
    extends ConsumerState<TokenRefreshNotificationListener> {
  @override
  Widget build(BuildContext context) {
    // Listen to notification state changes
    ref.listen<TokenRefreshNotificationState>(
      tokenRefreshNotificationHandlerProvider,
      (previous, next) {
        if (next.isShowing && next.notification != null) {
          _showNotification(context, next.notification!);
        }
      },
    );

    return widget.child;
  }

  /// Shows a notification based on the notification type
  void _showNotification(
    BuildContext context,
    TokenRefreshNotification notification,
  ) {
    switch (notification.type) {
      case TokenRefreshNotificationType.none:
        // Silent - don't show anything
        break;

      case TokenRefreshNotificationType.info:
        _showSnackBar(
          context,
          notification.message,
          backgroundColor: Theme.of(context).colorScheme.primary,
        );
        break;

      case TokenRefreshNotificationType.warning:
        _showSnackBar(
          context,
          notification.message,
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 5),
        );
        break;

      case TokenRefreshNotificationType.error:
        _showErrorDialog(context, notification);
        break;
    }
  }

  /// Shows a SnackBar with the given message
  void _showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    // Remove any existing snack bars
    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Shows an error dialog with retry/re-auth options
  void _showErrorDialog(
    BuildContext context,
    TokenRefreshNotification notification,
  ) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(notification.title),
            ),
          ],
        ),
        content: Text(notification.message),
        actions: _buildDialogActions(
          dialogContext,
          notification,
        ),
      ),
    ).then((_) {
      // Clear the notification state after dialog is closed
      ref
          .read(tokenRefreshNotificationHandlerProvider.notifier)
          .clearNotification();
    });
  }

  /// Builds dialog actions based on notification options
  List<Widget> _buildDialogActions(
    BuildContext dialogContext,
    TokenRefreshNotification notification,
  ) {
    final actions = <Widget>[];

    // Add re-authenticate button if requested
    if (notification.showReAuth) {
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            // Trigger re-authentication flow
            ref
                .read(tokenRefreshNotificationHandlerProvider.notifier)
                .reAuthenticate();
            // Navigate to login screen
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          },
          child: const Text('Sign In'),
        ),
      );
    }

    // Add retry button if requested
    if (notification.showRetry) {
      actions.add(
        ElevatedButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            // Trigger retry
            ref.read(tokenRefreshNotificationHandlerProvider.notifier).retry();
          },
          child: const Text('Retry'),
        ),
      );
    }

    // Add dismiss button as fallback
    if (actions.isEmpty) {
      actions.add(
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('OK'),
        ),
      );
    }

    return actions;
  }
}
