import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/widgets/auth_retry_button.dart';

/// Screen displayed when network connectivity issues occur
///
/// This screen provides clear feedback about network errors
/// and offers options to retry or continue in offline mode.
class NetworkErrorScreen extends ConsumerStatefulWidget {
  /// Optional custom message to display
  final String? customMessage;

  /// Callback when user chooses to retry
  final VoidCallback? onRetry;

  /// Callback when user chooses to continue offline
  final VoidCallback? onContinueOffline;

  /// Whether offline mode is available
  final bool offlineModeAvailable;

  /// Creates a new [NetworkErrorScreen]
  const NetworkErrorScreen({
    super.key,
    this.customMessage,
    this.onRetry,
    this.onContinueOffline,
    this.offlineModeAvailable = true,
  });

  /// Route name for navigation
  static const routeName = '/auth/network-error';

  @override
  ConsumerState<NetworkErrorScreen> createState() => _NetworkErrorScreenState();
}

class _NetworkErrorScreenState extends ConsumerState<NetworkErrorScreen> {
  /// Timer to check network connectivity periodically
  Timer? _networkCheckTimer;

  /// Whether network is currently available
  final bool _isNetworkAvailable = false;

  @override
  void initState() {
    super.initState();
    // Start periodic network checks
    _startNetworkCheck();
  }

  @override
  void dispose() {
    _networkCheckTimer?.cancel();
    super.dispose();
  }

  /// Starts periodic network connectivity checks
  void _startNetworkCheck() {
    // Check network every 5 seconds
    _networkCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // In a real implementation, this would use a connectivity service
      // For now, we'll just simulate the check
      _checkNetworkConnectivity();
    });
  }

  /// Checks network connectivity (simulated)
  Future<void> _checkNetworkConnectivity() async {
    // TODO: Implement actual network connectivity check
    // This would typically use a package like connectivity_plus
    // For now, this is a placeholder
  }

  /// Handles retry button press
  void _handleRetry() {
    widget.onRetry?.call();
  }

  /// Handles continue offline button press
  void _handleContinueOffline() {
    widget.onContinueOffline?.call();
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
                  Icons.wifi_off,
                  size: 80,
                  color: theme.colorScheme.error,
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Connection Error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                // Message
                Text(
                  widget.customMessage ??
                      'Unable to connect to the server. Please check your internet connection.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 32),

                // Network status indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isNetworkAvailable
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isNetworkAvailable ? Icons.wifi : Icons.wifi_off,
                        size: 20,
                        color: _isNetworkAvailable
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isNetworkAvailable
                            ? 'Network Connected'
                            : 'No Connection',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _isNetworkAvailable
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Retry button with countdown
                AuthRetryButton(
                  config: const AuthRetryButtonConfig(
                    maxAttempts: 3,
                    showCountdown: true,
                    showAttemptCounter: true,
                    showCancelButton: true,
                  ),
                  onRetry: _handleRetry,
                  buttonText: 'Retry',
                ),

                const SizedBox(height: 16),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Continue offline button
                if (widget.offlineModeAvailable)
                  ElevatedButton.icon(
                    onPressed: _handleContinueOffline,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                    ),
                    icon: const Icon(Icons.offline_pin),
                    label: const Text(
                      'Continue Offline',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                const SizedBox(height: 24),

                // Help text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
                            'Troubleshooting',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Check your Wi-Fi or mobile data connection\n'
                        '• Ensure Airplane Mode is turned off\n'
                        '• Try moving to a location with better signal\n'
                        '• Restart your router if needed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Back button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Go Back',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
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
