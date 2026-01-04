import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/connectivity_provider.dart';

/// Configuration for how the offline indicator is displayed
class OfflineIndicatorConfig {
  /// Whether to show an icon
  final bool showIcon;

  /// Whether to show text message
  final bool showMessage;

  /// Custom message to display when offline
  final String message;

  /// Display mode for the indicator
  final OfflineIndicatorMode mode;

  /// Background color when offline
  final Color? backgroundColor;

  /// Text/icon color when offline
  final Color? textColor;

  /// Border radius for the indicator
  final double borderRadius;

  /// Icon to display (default: cloud_off)
  final IconData icon;

  /// Whether to animate the indicator appearance
  final bool animate;

  /// Duration of the animation
  final Duration animationDuration;

  /// Whether to show a dismiss button (for banner mode)
  final bool showDismissButton;

  /// Auto-dismiss duration (null = no auto-dismiss)
  final Duration? autoDismissDuration;

  const OfflineIndicatorConfig({
    this.showIcon = true,
    this.showMessage = true,
    this.message = 'You\'re offline',
    this.mode = OfflineIndicatorMode.banner,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 0,
    this.icon = Icons.cloud_off,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showDismissButton = false,
    this.autoDismissDuration,
  });

  /// Configuration for a small badge indicator
  const OfflineIndicatorConfig.badge({
    this.showIcon = true,
    this.showMessage = false,
    this.message = 'Offline',
    this.mode = OfflineIndicatorMode.badge,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 16,
    this.icon = Icons.cloud_off,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showDismissButton = false,
    this.autoDismissDuration,
  });

  /// Configuration for a subtle status bar indicator
  const OfflineIndicatorConfig.statusBar({
    this.showIcon = true,
    this.showMessage = true,
    this.message = 'No connection',
    this.mode = OfflineIndicatorMode.statusBar,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 0,
    this.icon = Icons.cloud_off,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showDismissButton = false,
    this.autoDismissDuration,
  });

  /// Configuration for a snackbar-style notification
  const OfflineIndicatorConfig.snackbar({
    this.showIcon = true,
    this.showMessage = true,
    this.message = 'You\'re offline. Some features may be limited.',
    this.mode = OfflineIndicatorMode.snackbar,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8,
    this.icon = Icons.cloud_off,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showDismissButton = true,
    this.autoDismissDuration = const Duration(seconds: 5),
  });
}

/// Display modes for the offline indicator
enum OfflineIndicatorMode {
  /// Full-width banner at the top of the screen
  banner,

  /// Small badge in the corner
  badge,

  /// Thin status bar at the top
  statusBar,

  /// Snackbar-style floating notification
  snackbar,
}

/// A widget that displays a visual indicator when the device is offline.
///
/// This widget monitors network connectivity and displays a visual indicator
/// when the device loses connection. It supports multiple display modes and
/// can be customized to fit different UI requirements.
///
/// Example usage:
/// ```dart
/// OfflineIndicator(
///   config: OfflineIndicatorConfig(),
/// )
/// ```
///
/// For a small badge:
/// ```dart
/// OfflineIndicator(
///   config: OfflineIndicatorConfig.badge(),
///   position: OfflineIndicatorPosition.topRight,
/// )
/// ```
///
/// For integration with Scaffold:
/// ```dart
/// Scaffold(
///   body: Stack(
///     children: [
///       YourContent(),
///       Positioned(
///         top: 0,
///         left: 0,
///         right: 0,
///         child: OfflineIndicator.banner(),
///       ),
///     ],
///   ),
/// )
/// ```
class OfflineIndicator extends ConsumerStatefulWidget {
  /// Configuration for how to display the indicator
  final OfflineIndicatorConfig config;

  /// Position for badge mode (ignored for other modes)
  final OfflineIndicatorPosition position;

  /// Offset from the edge for badge mode
  final Offset offset;

  /// Callback when indicator is shown
  final VoidCallback? onShow;

  /// Callback when indicator is hidden
  final VoidCallback? onHide;

  const OfflineIndicator({
    super.key,
    this.config = const OfflineIndicatorConfig(),
    this.position = OfflineIndicatorPosition.topRight,
    this.offset = const Offset(16, 16),
    this.onShow,
    this.onHide,
  });

  /// Convenience constructor for banner mode
  const OfflineIndicator.banner({
    super.key,
    String message = 'You\'re offline',
    VoidCallback? onShow,
    VoidCallback? onHide,
  }) : config = OfflineIndicatorConfig(
          message: message,
          mode: OfflineIndicatorMode.banner,
        ),
       position = OfflineIndicatorPosition.topLeft,
       offset = Offset.zero,
       onShow = onShow,
       onHide = onHide;

  /// Convenience constructor for badge mode
  const OfflineIndicator.badge({
    super.key,
    OfflineIndicatorPosition position = OfflineIndicatorPosition.topRight,
    Offset offset = const Offset(16, 16),
    VoidCallback? onShow,
    VoidCallback? onHide,
  }) : config = OfflineIndicatorConfig.badge(),
       position = position,
       offset = offset,
       onShow = onShow,
       onHide = onHide;

  /// Convenience constructor for status bar mode
  const OfflineIndicator.statusBar({
    super.key,
    String message = 'No connection',
    VoidCallback? onShow,
    VoidCallback? onHide,
  }) : config = OfflineIndicatorConfig.statusBar(
          message: message,
        ),
       position = OfflineIndicatorPosition.topLeft,
       offset = Offset.zero,
       onShow = onShow,
       onHide = onHide;

  /// Convenience constructor for snackbar mode
  const OfflineIndicator.snackbar({
    super.key,
    String message = 'You\'re offline. Some features may be limited.',
    Duration? autoDismissDuration,
    VoidCallback? onShow,
    VoidCallback? onHide,
  }) : config = OfflineIndicatorConfig.snackbar(
          message: message,
          autoDismissDuration: autoDismissDuration,
        ),
       position = OfflineIndicatorPosition.topLeft,
       offset = Offset.zero,
       onShow = onShow,
       onHide = onHide;

  @override
  ConsumerState<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends ConsumerState<OfflineIndicator>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  bool _isDismissed = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showIndicator() {
    if (!_isVisible) {
      setState(() => _isVisible = true);
      widget.onShow?.call();
      if (widget.config.animate) {
        _animationController.forward();
      }
    }
  }

  void _hideIndicator() {
    if (_isVisible) {
      if (widget.config.animate) {
        _animationController.reverse().then((_) {
          if (mounted) {
            setState(() => _isVisible = false);
            widget.onHide?.call();
          }
        });
      } else {
        setState(() => _isVisible = false);
        widget.onHide?.call();
      }
    }
  }

  void _dismiss() {
    setState(() => _isDismissed = true);
    _hideIndicator();
  }

  void _resetDismiss() {
    if (_isDismissed) {
      setState(() => _isDismissed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(connectivityNotifierProvider);
    final theme = Theme.of(context);

    // Reset dismissed state when coming back online
    if (isConnected && _isDismissed) {
      _resetDismiss();
    }

    // Handle visibility based on connectivity and dismissed state
    if (!isConnected && !_isDismissed) {
      _showIndicator();
    } else {
      _hideIndicator();
    }

    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    final backgroundColor = widget.config.backgroundColor ??
        (widget.config.mode == OfflineIndicatorMode.snackbar
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.error);

    final textColor = widget.config.textColor ??
        (widget.config.mode == OfflineIndicatorMode.snackbar
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onError);

    Widget indicator = _buildIndicator(backgroundColor, textColor, theme);

    // Apply positioning for badge mode
    if (widget.config.mode == OfflineIndicatorMode.badge) {
      return Positioned(
        top: widget.position == OfflineIndicatorPosition.topLeft ||
                widget.position == OfflineIndicatorPosition.topRight
            ? widget.offset.dy
            : null,
        bottom: widget.position == OfflineIndicatorPosition.bottomLeft ||
                widget.position == OfflineIndicatorPosition.bottomRight
            ? widget.offset.dy
            : null,
        left: widget.position == OfflineIndicatorPosition.topLeft ||
                widget.position == OfflineIndicatorPosition.bottomLeft
            ? widget.offset.dx
            : null,
        right: widget.position == OfflineIndicatorPosition.topRight ||
                widget.position == OfflineIndicatorPosition.bottomRight
            ? widget.offset.dx
            : null,
        child: indicator,
      );
    }

    // Apply animation for banner and status bar modes
    if (widget.config.mode == OfflineIndicatorMode.banner ||
        widget.config.mode == OfflineIndicatorMode.statusBar) {
      if (widget.config.animate) {
        indicator = SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: indicator,
          ),
        );
      }
    }

    return indicator;
  }

  Widget _buildIndicator(Color backgroundColor, Color textColor, ThemeData theme) {
    final icon = Icon(
      widget.config.icon,
      color: textColor,
      size: widget.config.mode == OfflineIndicatorMode.badge ? 16 : 20,
    );

    final message = Text(
      widget.config.message,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontWeight: widget.config.mode == OfflineIndicatorMode.statusBar
            ? FontWeight.normal
            : FontWeight.w500,
      ),
    );

    Widget content;
    switch (widget.config.mode) {
      case OfflineIndicatorMode.banner:
        content = Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(widget.config.borderRadius),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                if (widget.config.showIcon) ...[
                  icon,
                  const SizedBox(width: 12),
                ],
                if (widget.config.showMessage)
                  Expanded(child: message),
                if (widget.config.showDismissButton)
                  IconButton(
                    icon: Icon(Icons.close, color: textColor, size: 20),
                    onPressed: _dismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        );
        break;

      case OfflineIndicatorMode.badge:
        content = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.config.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.config.showIcon) icon,
              if (widget.config.showIcon && widget.config.showMessage)
                const SizedBox(width: 4),
              if (widget.config.showMessage)
                Text(
                  widget.config.message,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        );
        break;

      case OfflineIndicatorMode.statusBar:
        content = Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.config.showIcon) ...[
                  icon,
                  const SizedBox(width: 8),
                ],
                if (widget.config.showMessage) message,
              ],
            ),
          ),
        );
        break;

      case OfflineIndicatorMode.snackbar:
        content = Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.config.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.config.showIcon) ...[
                icon,
                const SizedBox(width: 12),
              ],
              if (widget.config.showMessage) Expanded(child: message),
              if (widget.config.showDismissButton)
                GestureDetector(
                  onTap: _dismiss,
                  child: Icon(Icons.close, color: textColor, size: 20),
                ),
            ],
          ),
        );
        break;
    }

    return content;
  }
}

/// Position options for badge mode
enum OfflineIndicatorPosition {
  /// Top left corner
  topLeft,

  /// Top right corner
  topRight,

  /// Bottom left corner
  bottomLeft,

  /// Bottom right corner
  bottomRight,
}
