import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';

/// Widget for capturing and displaying location in journal entry creation
///
/// Provides:
/// - Visual display of current location (if set)
/// - Capture location button with loading state
/// - Clear location button
/// - Error handling with user-friendly messages
/// - Accuracy indicator
class LocationCaptureWidget extends ConsumerWidget {
  /// Whether to show the widget in compact mode (smaller footprint)
  final bool isCompact;

  /// Custom padding for the widget
  final EdgeInsetsGeometry? padding;

  const LocationCaptureWidget({
    super.key,
    this.isCompact = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creationState = ref.watch(journalEntryCreationProvider);
    final theme = Theme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: creationState.latitude != null
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: creationState.latitude != null
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: creationState.latitude != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                size: isCompact ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Location',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (creationState.latitude != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Added',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Location info or capture button
          if (creationState.latitude != null) ...[
            // Location details
            _LocationDetails(
              latitude: creationState.latitude!,
              longitude: creationState.longitude!,
              accuracy: creationState.locationAccuracy,
              locationName: creationState.locationName,
              isCompact: isCompact,
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: creationState.isCapturingLocation
                        ? null
                        : () {
                            ref
                                .read(journalEntryCreationProvider.notifier)
                                .captureCurrentLocation();
                          },
                    icon: creationState.isCapturingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      creationState.isCapturingLocation
                          ? 'Capturing...'
                          : 'Update Location',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(journalEntryCreationProvider.notifier)
                          .clearLocation();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // No location set - show capture button
            if (creationState.isCapturingLocation) ...[
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Capturing location...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(journalEntryCreationProvider.notifier)
                      .captureCurrentLocation();
                },
                icon: const Icon(Icons.my_location),
                label: const Text('Capture Current Location'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),

              const SizedBox(height: 8),

              // Helper text
              Text(
                'Add your current location to this journal entry',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],

          // Error message
          if (creationState.error != null &&
              creationState.error!.contains('location')) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      creationState.error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      ref
                          .read(journalEntryCreationProvider.notifier)
                          .clearError();
                    },
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget displaying location details
class _LocationDetails extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String? locationName;
  final bool isCompact;

  const _LocationDetails({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.locationName,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coordinates
          Row(
            children: [
              Icon(
                Icons.place,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),

          if (!isCompact) ...[
            const SizedBox(height: 8),

            // Location name if available
            if (locationName != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_city,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      locationName!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Accuracy indicator
            if (accuracy != null) ...[
              Row(
                children: [
                  Icon(
                    _getAccuracyIcon(accuracy!),
                    size: 16,
                    color: _getAccuracyColor(accuracy!, theme),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Accuracy: ${accuracy!.toStringAsFixed(1)}m',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getAccuracyColor(accuracy!, theme),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (accuracy! <= 100)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Good',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green.shade700,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Fair',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  IconData _getAccuracyIcon(double accuracy) {
    if (accuracy <= 10) return Icons.check_circle;
    if (accuracy <= 50) return Icons.check;
    if (accuracy <= 100) return Icons.info;
    return Icons.warning;
  }

  Color _getAccuracyColor(double accuracy, ThemeData theme) {
    if (accuracy <= 10) return Colors.green.shade700;
    if (accuracy <= 50) return Colors.green.shade500;
    if (accuracy <= 100) return Colors.orange.shade700;
    return theme.colorScheme.error;
  }
}

/// Simple inline button for capturing location
///
/// Use this when you want a minimal location capture button
/// that doesn't show location details inline.
class LocationCaptureButton extends ConsumerWidget {
  /// Button label
  final String? label;

  /// Icon to show when location is set
  final IconData? capturedIcon;

  /// Icon to show when location is not set
  final IconData? uncapturedIcon;

  const LocationCaptureButton({
    super.key,
    this.label,
    this.capturedIcon,
    this.uncapturedIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creationState = ref.watch(journalEntryCreationProvider);
    final theme = Theme.of(context);

    final hasLocation = creationState.latitude != null;

    return IconButton(
      icon: creationState.isCapturingLocation
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              hasLocation
                  ? capturedIcon ?? Icons.location_on
                  : uncapturedIcon ?? Icons.location_on_outlined,
              color: hasLocation ? theme.colorScheme.primary : null,
            ),
      onPressed: creationState.isCapturingLocation
          ? null
          : () {
              if (hasLocation) {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Remove Location?'),
                    content: const Text(
                      'Do you want to remove the location from this journal entry?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(journalEntryCreationProvider.notifier)
                              .clearLocation();
                          Navigator.pop(context);
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
              } else {
                // Capture location
                ref
                    .read(journalEntryCreationProvider.notifier)
                    .captureCurrentLocation();
              }
            },
      tooltip:
          hasLocation ? 'Remove location' : label ?? 'Add current location',
    );
  }
}
