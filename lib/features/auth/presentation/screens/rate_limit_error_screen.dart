import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/auth_error_handler.dart';

/// Screen displayed when rate limit is exceeded
///
/// This screen provides clear feedback about rate limiting
/// and displays a countdown timer until the user can retry.
class RateLimitErrorScreen extends ConsumerStatefulWidget {
  /// Error information from AuthErrorHandler
  final AuthErrorInfo errorInfo;

  /// Optional custom message to display
  final String? customMessage;

  /// Callback when user should be allowed to retry
  final VoidCallback? onRetryAllowed;

  /// Creates a new [RateLimitErrorScreen]
  const RateLimitErrorScreen({
    super.key,
    required this.errorInfo,
    this.customMessage,
    this.onRetryAllowed,
  });

  /// Route name for navigation
  static const routeName = '/auth/rate-limit-error';

  @override
  ConsumerState<RateLimitErrorScreen> createState() => _RateLimitErrorScreenState();
}

class _RateLimitErrorScreenState extends ConsumerState<RateLimitErrorScreen> {
  /// Timer for countdown
  Timer? _countdownTimer;

  /// Remaining seconds until retry is allowed
  int _remainingSeconds = 0;

  /// Whether the user can retry now
  bool get _canRetry => _remainingSeconds <= 0;

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Initializes the countdown timer based on the error info
  void _initializeCountdown() {
    final waitDuration = widget.errorInfo.recovery.retryDelay;
    if (waitDuration != null) {
      setState(() {
        _remainingSeconds = waitDuration.inSeconds;
      });
      _startCountdown();
    }
  }

  /// Starts the countdown timer
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  /// Formats the remaining time for display
  String _formatRemainingTime() {
    if (_remainingSeconds <= 0) {
      return 'You can retry now';
    }

    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;

    if (hours > 0) {
      return '$hours hour${hours > 1 ? "s" : ""} $minutes minute${minutes > 1 ? "s" : ""}';
    } else if (minutes > 0) {
      return '$minutes minute${minutes > 1 ? "s" : ""} $seconds second${seconds > 1 ? "s" : ""}';
    } else {
      return '$seconds second${seconds > 1 ? "s" : ""}';
    }
  }

  /// Handles retry button press
  void _handleRetry() {
    if (_canRetry) {
      Navigator.of(context).pop();
      widget.onRetryAllowed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error icon
                Icon(
                  Icons.speed,
                  size: 80,
                  color: theme.colorScheme.error,
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Too Many Attempts',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                // Message
                Text(
                  widget.customMessage ?? widget.errorInfo.userMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 32),

                // Countdown timer display
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primaryContainer.withOpacity(0.3),
                        theme.colorScheme.primaryContainer.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _canRetry ? Icons.check_circle : Icons.schedule,
                        size: 48,
                        color: _canRetry
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _canRetry ? 'Ready to Retry' : 'Please Wait',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatRemainingTime(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _canRetry
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Retry button (enabled when countdown finishes)
                ElevatedButton(
                  onPressed: _canRetry ? _handleRetry : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Text(
                    _canRetry ? 'Retry Now' : 'Please Wait',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Cancel button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Information section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'About Rate Limiting',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'To protect our service and prevent abuse, we limit the number of attempts '
                        'you can make in a short period of time.\n\n'
                        'This helps ensure fair usage and maintains service quality for all users.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tips section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tips',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Double-check your credentials before each attempt\n'
                        '• Wait for the countdown to finish before retrying\n'
                        '• If you keep having issues, consider resetting your password\n'
                        '• Contact support if you believe this is an error',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
