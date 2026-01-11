import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';

/// Configuration for the retry button behavior
class AuthRetryButtonConfig {
  /// Maximum number of retry attempts allowed
  final int maxAttempts;

  /// Base delay for exponential backoff in seconds
  final int baseDelaySeconds;

  /// Maximum delay in seconds
  final int maxDelaySeconds;

  /// Whether to show the countdown timer
  final bool showCountdown;

  /// Whether to show attempt counter
  final bool showAttemptCounter;

  /// Whether to show cancel button
  final bool showCancelButton;

  const AuthRetryButtonConfig({
    this.maxAttempts = 3,
    this.baseDelaySeconds = 1,
    this.maxDelaySeconds = 32,
    this.showCountdown = true,
    this.showAttemptCounter = true,
    this.showCancelButton = true,
  });

  /// Creates a config with minimal UI (just the button)
  const AuthRetryButtonConfig.minimal({
    this.maxAttempts = 3,
    this.baseDelaySeconds = 1,
    this.maxDelaySeconds = 32,
    this.showCountdown = false,
    this.showAttemptCounter = false,
    this.showCancelButton = false,
  });

  /// Calculates the delay for a given attempt number using exponential backoff
  Duration calculateDelay(int attemptNumber) {
    final delaySeconds = min(
      (1 << (attemptNumber - 1)).clamp(1, maxDelaySeconds),
      maxDelaySeconds,
    );
    return Duration(seconds: delaySeconds);
  }
}

/// A reusable button widget for authentication retry with exponential backoff visualization
///
/// This widget provides:
/// - Countdown timer showing when next retry is available
/// - Retry attempt counter (e.g., "Attempt 2 of 3")
/// - Cancel option to stop retry attempts
/// - Automatic exponential backoff calculation
///
/// Example usage:
/// ```dart
/// AuthRetryButton(
///   config: AuthRetryButtonConfig(),
///   onRetry: () {
///     // Perform retry logic
///   },
///   onCancel: () {
///     // Handle cancellation
///   },
/// )
/// ```
class AuthRetryButton extends ConsumerStatefulWidget {
  /// Configuration for button behavior
  final AuthRetryButtonConfig config;

  /// Callback when retry is triggered
  final VoidCallback onRetry;

  /// Callback when retry is cancelled
  final VoidCallback? onCancel;

  /// Optional custom label for the retry button
  final String? buttonText;

  /// Optional custom label for the cancel button
  final String? cancelButtonText;

  /// Whether the button should be enabled externally
  final bool externallyEnabled;

  const AuthRetryButton({
    super.key,
    this.config = const AuthRetryButtonConfig(),
    required this.onRetry,
    this.onCancel,
    this.buttonText,
    this.cancelButtonText,
    this.externallyEnabled = true,
  });

  @override
  ConsumerState<AuthRetryButton> createState() => _AuthRetryButtonState();
}

class _AuthRetryButtonState extends ConsumerState<AuthRetryButton> {
  /// Current retry attempt number
  int _currentAttempt = 0;

  /// Timer for countdown
  Timer? _countdownTimer;

  /// Remaining seconds before next retry is allowed
  int _remainingSeconds = 0;

  /// Whether a retry operation is in progress
  bool _isRetrying = false;

  /// Subscription to token refresh service status stream
  StreamSubscription<TokenRefreshResult>? _refreshSubscription;

  @override
  void initState() {
    super.initState();
    // Subscribe to token refresh service if available
    _subscribeToRefreshService();
  }

  @override
  void didUpdateWidget(AuthRetryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset state if externally enabled changes to true
    if (widget.externallyEnabled && !oldWidget.externallyEnabled) {
      _resetState();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _refreshSubscription?.cancel();
    super.dispose();
  }

  /// Subscribes to token refresh service status stream
  void _subscribeToRefreshService() {
    // Note: This would be integrated via provider in real usage
    // For now, this is a placeholder for when TokenRefreshService is available via Riverpod
  }

  /// Resets the retry state
  void _resetState() {
    setState(() {
      _currentAttempt = 0;
      _remainingSeconds = 0;
      _isRetrying = false;
    });
    _countdownTimer?.cancel();
  }

  /// Handles retry button press
  void _handleRetry() {
    if (_isRetrying || _remainingSeconds > 0) {
      return;
    }

    // Increment attempt counter
    setState(() {
      _currentAttempt++;
      _isRetrying = true;
    });

    // Perform retry callback
    widget.onRetry();

    // Simulate retry completion (in real usage, this would be driven by TokenRefreshService)
    // For now, we'll start countdown for next attempt if not max attempts
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });

        // Start countdown if we haven't reached max attempts
        if (_currentAttempt < widget.config.maxAttempts) {
          _startCountdown();
        }
      }
    });
  }

  /// Starts the countdown timer for next retry attempt
  void _startCountdown() {
    final delay = widget.config.calculateDelay(_currentAttempt + 1);
    setState(() {
      _remainingSeconds = delay.inSeconds;
    });

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

  /// Handles cancel button press
  void _handleCancel() {
    _countdownTimer?.cancel();
    _resetState();
    widget.onCancel?.call();
  }

  /// Whether the retry button should be enabled
  bool get _isRetryEnabled {
    return widget.externallyEnabled &&
        !_isRetrying &&
        _remainingSeconds == 0 &&
        _currentAttempt < widget.config.maxAttempts;
  }

  /// Whether max retry attempts have been reached
  bool get _isMaxAttemptsReached {
    return _currentAttempt >= widget.config.maxAttempts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Retry button with attempt counter
        ElevatedButton(
          onPressed: _isRetryEnabled ? _handleRetry : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          child: _isRetrying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : _buildButtonContent(theme),
        ),

        // Retry information and countdown
        if (widget.config.showAttemptCounter ||
            widget.config.showCountdown) ...[
          const SizedBox(height: 12),
          _buildRetryInfo(theme),
        ],

        // Cancel button
        if (widget.config.showCancelButton &&
            !_isMaxAttemptsReached &&
            (_currentAttempt > 0 || _remainingSeconds > 0)) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: _handleCancel,
            child: Text(
              widget.cancelButtonText ?? 'Cancel',
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the button content
  Widget _buildButtonContent(ThemeData theme) {
    final buttonLabel = widget.buttonText ?? 'Retry';

    if (_isMaxAttemptsReached) {
      return Text(
        'Max Attempts Reached',
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha:0.6),
        ),
      );
    }

    return Text(buttonLabel);
  }

  /// Builds retry information section with attempt counter and countdown
  Widget _buildRetryInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha:0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Attempt counter
          if (widget.config.showAttemptCounter && _currentAttempt > 0)
            Text(
              'Attempt $_currentAttempt of ${widget.config.maxAttempts}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),

          // Countdown timer
          if (widget.config.showCountdown &&
              _remainingSeconds > 0 &&
              !_isMaxAttemptsReached) ...[
            if (widget.config.showAttemptCounter) const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Next retry in $_remainingSeconds second${_remainingSeconds == 1 ? "" : "s"}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          // Backoff info
          if (_remainingSeconds == 0 &&
              _currentAttempt > 0 &&
              !_isMaxAttemptsReached) ...[
            if (widget.config.showAttemptCounter) const SizedBox(height: 8),
            Text(
              'Ready to retry',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A simplified version that can be driven by TokenRefreshService status stream
///
/// This version connects directly to TokenRefreshService and automatically
/// updates its state based on the refresh status events.
class AuthRetryButtonAutomatic extends ConsumerStatefulWidget {
  /// TokenRefreshService instance to listen to
  final TokenRefreshService refreshService;

  /// Callback when user manually triggers retry
  final VoidCallback? onManualRetry;

  /// Callback when user cancels retry
  final VoidCallback? onCancel;

  /// Optional custom configuration
  final AuthRetryButtonConfig? config;

  const AuthRetryButtonAutomatic({
    super.key,
    required this.refreshService,
    this.onManualRetry,
    this.onCancel,
    this.config,
  });

  @override
  ConsumerState<AuthRetryButtonAutomatic> createState() =>
      _AuthRetryButtonAutomaticState();
}

class _AuthRetryButtonAutomaticState
    extends ConsumerState<AuthRetryButtonAutomatic> {
  late final AuthRetryButtonConfig _config;
  TokenRefreshResult? _lastResult;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _config = widget.config ?? const AuthRetryButtonConfig();
    _subscribeToRefreshService();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _subscribeToRefreshService() {
    widget.refreshService.statusStream.listen((result) {
      if (!mounted) return;

      setState(() {
        _lastResult = result;

        // Handle retry logic based on status
        if (result.status == TokenRefreshStatus.failure &&
            result.attemptNumber < _config.maxAttempts) {
          // Start countdown for next retry
          _startCountdown(result.attemptNumber + 1);
        }
      });
    });
  }

  void _startCountdown(int attemptNumber) {
    final delay = _config.calculateDelay(attemptNumber);
    setState(() {
      _remainingSeconds = delay.inSeconds;
    });

    _countdownTimer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRefreshing = widget.refreshService.isRefreshing;
    final lastAttempt = _lastResult?.attemptNumber ?? 0;
    final hasFailed = _lastResult?.status == TokenRefreshStatus.failure;
    final maxAttemptsReached = lastAttempt >= _config.maxAttempts;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main action button
        ElevatedButton(
          onPressed:
              (isRefreshing || _remainingSeconds > 0 || maxAttemptsReached)
                  ? null
                  : () {
                      if (hasFailed) {
                        // Trigger retry via refresh service
                        widget.refreshService.refreshToken().catchError((_) {});
                      } else {
                        widget.onManualRetry?.call();
                      }
                    },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: isRefreshing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  maxAttemptsReached
                      ? 'Max Attempts Reached'
                      : _lastResult == null
                          ? 'Retry'
                          : 'Retry Again',
                ),
        ),

        // Status information
        if (_lastResult != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Attempt counter
                if (_config.showAttemptCounter)
                  Text(
                    'Attempt $lastAttempt of ${_config.maxAttempts}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                // Countdown
                if (_remainingSeconds > 0 && !maxAttemptsReached) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Next retry in $_remainingSeconds second${_remainingSeconds == 1 ? "" : "s"}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],

        // Cancel button
        if (widget.onCancel != null &&
            !maxAttemptsReached &&
            (lastAttempt > 0 || _remainingSeconds > 0)) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              widget.refreshService.cancelRefresh();
              widget.onCancel?.call();
            },
            child: const Text('Cancel'),
          ),
        ],
      ],
    );
  }
}
