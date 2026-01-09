import 'package:flutter/material.dart';

/// Callback type for SOS button press
typedef SOSButtonCallback = void Function();

/// Prominent, accessible SOS button widget for emergency situations
///
/// Features:
/// - Pulsing animation to draw attention
/// - Configurable size for different use cases (large for dedicated screen, small for quick access)
/// - Loading and disabled states
/// - Accessibility support with semantic labels
/// - Visual feedback with gradient and shadow effects
/// - Customizable colors and labels
///
/// Use cases:
/// - Main SOS button on EmergencySOSScreen (large)
/// - Quick access SOS button on home screen (small/medium)
/// - Floating SOS button for emergency access (medium)
///
/// Example usage:
/// ```dart
/// SOSButtonWidget(
///   size: SOSButtonSize.large,
///   onPressed: () => _triggerSOS(),
///   isLoading: _isProcessing,
///   hasActiveEmergency: _hasActiveEmergency,
/// )
/// ```
class SOSButtonWidget extends StatefulWidget {
  /// Callback when the button is pressed
  final SOSButtonCallback? onPressed;

  /// Whether the button is in a loading state
  final bool isLoading;

  /// Whether there is an active emergency (button shows "ACTIVE" state)
  final bool hasActiveEmergency;

  /// Size of the button
  final SOSButtonSize size;

  /// Custom label for normal state (defaults to "SOS")
  final String? label;

  /// Custom label for active emergency state (defaults to "ACTIVE")
  final String? activeLabel;

  /// Custom subtitle text (shown below main label in large size)
  final String? subtitle;

  /// Primary color for the button (defaults to red)
  final Color? color;

  /// Whether to show the pulsing animation
  final bool showPulse;

  /// Accessibility label for screen readers
  final String? semanticLabel;

  const SOSButtonWidget({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.hasActiveEmergency = false,
    this.size = SOSButtonSize.large,
    this.label,
    this.activeLabel,
    this.subtitle,
    this.color,
    this.showPulse = true,
    this.semanticLabel,
  });

  @override
  State<SOSButtonWidget> createState() => _SOSButtonWidgetState();
}

class _SOSButtonWidgetState extends State<SOSButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.showPulse && !widget.hasActiveEmergency && !widget.isLoading) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SOSButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldPulse = widget.showPulse &&
        !widget.hasActiveEmergency &&
        !widget.isLoading &&
        widget.onPressed != null;

    if (shouldPulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!shouldPulse && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null &&
        !widget.isLoading &&
        !widget.hasActiveEmergency;

    final buttonColor = widget.color ?? Colors.red;
    final activeColor = widget.color?.withOpacity(0.8) ?? Colors.orange;

    final dimensions = widget.size.dimensions;

    return Semantics(
      label: widget.semanticLabel ??
          (widget.hasActiveEmergency ? 'Active emergency alert' : 'Emergency SOS button'),
      button: true,
      enabled: isEnabled,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scaleValue = widget.hasActiveEmergency || widget.isLoading
              ? 1.0
              : _pulseAnimation.value;

          return Transform.scale(
            scale: scaleValue,
            child: GestureDetector(
              onTap: isEnabled ? widget.onPressed : null,
              child: Container(
                width: dimensions.width,
                height: dimensions.height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: widget.hasActiveEmergency
                        ? [
                            activeColor.withOpacity(0.3),
                            activeColor,
                          ]
                        : [
                            buttonColor.withOpacity(0.3),
                            buttonColor,
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.hasActiveEmergency
                          ? activeColor.withOpacity(0.5)
                          : buttonColor.withOpacity(0.5),
                      blurRadius: widget.hasActiveEmergency
                          ? dimensions.blurRadius * 0.7
                          : dimensions.blurRadius,
                      spreadRadius: widget.hasActiveEmergency
                          ? dimensions.spreadRadius * 0.5
                          : dimensions.spreadRadius,
                    ),
                    if (!widget.hasActiveEmergency &&
                        !widget.isLoading &&
                        widget.showPulse)
                      BoxShadow(
                        color: buttonColor.withOpacity(0.3),
                        blurRadius: dimensions.blurRadius * 2 * _pulseAnimation.value,
                        spreadRadius: dimensions.spreadRadius * 2 * _pulseAnimation.value,
                      ),
                  ],
                ),
                child: _buildContent(theme, buttonColor, activeColor, dimensions),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    Color buttonColor,
    Color activeColor,
    SOSButtonDimensions dimensions,
  ) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: dimensions.loadingIndicatorSize,
          height: dimensions.loadingIndicatorSize,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 4,
          ),
        ),
      );
    }

    final mainLabel = widget.hasActiveEmergency
        ? (widget.activeLabel ?? 'ACTIVE')
        : (widget.label ?? 'SOS');

    const textColor = Colors.white;

    if (widget.size == SOSButtonSize.small) {
      // Small size: just show icon or text
      return Center(
        child: Text(
          mainLabel,
          style: theme.textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: dimensions.fontSize,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Medium and Large sizes: show main label and optional subtitle
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          mainLabel,
          style: theme.textTheme.displayMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: dimensions.fontSize,
          ),
          textAlign: TextAlign.center,
        ),
        if (!widget.hasActiveEmergency &&
            widget.subtitle != null &&
            widget.size == SOSButtonSize.large) ...[
          SizedBox(height: dimensions.subtitleSpacing),
          Text(
            widget.subtitle!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              fontSize: dimensions.subtitleFontSize,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Size options for the SOS button
enum SOSButtonSize {
  /// Small size (56x56) - for quick access buttons, FABs
  small,

  /// Medium size (100x100) - for inline buttons, cards
  medium,

  /// Large size (180x180) - for dedicated emergency screens
  large,
}

/// Extension to get dimensions for each button size
extension SOSButtonSizeExtension on SOSButtonSize {
  SOSButtonDimensions get dimensions {
    switch (this) {
      case SOSButtonSize.small:
        return const SOSButtonDimensions(
          width: 56,
          height: 56,
          fontSize: 18,
          subtitleFontSize: 0,
          subtitleSpacing: 0,
          blurRadius: 10,
          spreadRadius: 2,
          loadingIndicatorSize: 20,
        );
      case SOSButtonSize.medium:
        return const SOSButtonDimensions(
          width: 100,
          height: 100,
          fontSize: 28,
          subtitleFontSize: 12,
          subtitleSpacing: 4,
          blurRadius: 20,
          spreadRadius: 5,
          loadingIndicatorSize: 30,
        );
      case SOSButtonSize.large:
        return const SOSButtonDimensions(
          width: 180,
          height: 180,
          fontSize: 48,
          subtitleFontSize: 16,
          subtitleSpacing: 4,
          blurRadius: 30,
          spreadRadius: 10,
          loadingIndicatorSize: 40,
        );
    }
  }
}

/// Dimensions for the SOS button
@immutable
class SOSButtonDimensions {
  final double width;
  final double height;
  final double fontSize;
  final double subtitleFontSize;
  final double subtitleSpacing;
  final double blurRadius;
  final double spreadRadius;
  final double loadingIndicatorSize;

  const SOSButtonDimensions({
    required this.width,
    required this.height,
    required this.fontSize,
    required this.subtitleFontSize,
    required this.subtitleSpacing,
    required this.blurRadius,
    required this.spreadRadius,
    required this.loadingIndicatorSize,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SOSButtonDimensions &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          fontSize == other.fontSize &&
          subtitleFontSize == other.subtitleFontSize &&
          subtitleSpacing == other.subtitleSpacing &&
          blurRadius == other.blurRadius &&
          spreadRadius == other.spreadRadius &&
          loadingIndicatorSize == other.loadingIndicatorSize;

  @override
  int get hashCode =>
      width.hashCode ^
      height.hashCode ^
      fontSize.hashCode ^
      subtitleFontSize.hashCode ^
      subtitleSpacing.hashCode ^
      blurRadius.hashCode ^
      spreadRadius.hashCode ^
      loadingIndicatorSize.hashCode;
}
