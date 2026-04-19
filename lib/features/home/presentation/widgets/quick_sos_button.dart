import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/safety/presentation/widgets/sos_button_widget.dart';
import '../../../../features/safety/presentation/providers/safety_providers.dart';
import '../../../../features/auth/presentation/providers/auth_navigation_provider.dart';

/// Quick access SOS button for the home screen
///
/// Features:
/// - Small, unobtrusive button that can be quickly accessed in emergencies
/// - Shows pulsing animation when no active emergency
/// - Shows "ACTIVE" state when emergency is in progress
/// - Navigates to Emergency SOS screen when pressed
/// - Disabled state when emergency is active or loading
/// - Full accessibility support for screen readers
///
/// Example usage:
/// ```dart
/// QuickSOSButton()
/// ```
class QuickSOSButton extends ConsumerWidget {
  /// Size of the button (defaults to small for compact home screen display)
  final SOSButtonSize size;

  /// Optional custom label (defaults to "SOS")
  final String? label;

  /// Whether to show the button in a card (defaults to false)
  final bool showInCard;

  const QuickSOSButton({
    super.key,
    this.size = SOSButtonSize.small,
    this.label,
    this.showInCard = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safetyAsync = ref.watch(safetyProvider);
    final hasActiveEmergency = safetyAsync.value?.hasActiveEmergency ?? false;
    final isProcessing = safetyAsync.isLoading;

    final button = SOSButtonWidget(
      size: size,
      isLoading: isProcessing,
      hasActiveEmergency: hasActiveEmergency,
      label: label,
      activeLabel: 'ACTIVE',
      showPulse: !hasActiveEmergency,
      semanticLabel: hasActiveEmergency
          ? 'Active emergency alert - Tap to view details'
          : 'Emergency SOS button - Tap to trigger emergency alert',
      onPressed: () => _handleSOSPressed(context, ref),
    );

    if (showInCard) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              button,
              const SizedBox(height: 8),
              Text(
                hasActiveEmergency ? 'Emergency Active' : 'Quick SOS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: hasActiveEmergency
                          ? Colors.orange.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return button;
  }

  /// Handles SOS button press - navigates to emergency SOS screen
  void _handleSOSPressed(BuildContext context, WidgetRef ref) {
    ref.read(authNavigationProvider.notifier).navigateToEmergencySOS();
  }
}
