import 'package:flutter/material.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';

/// Callback type for interest selection changes
typedef InterestSelectedCallback = void Function(TravelInterest interest, bool isSelected);

/// Reusable chip widget for selecting travel interests
///
/// Features:
/// - Displays interest with emoji and label
/// - Visual feedback for selected/unselected states
/// - Supports enabled/disabled states
/// - Configurable chip style (outlined or filled)
/// - Animation on selection
///
/// Example usage:
/// ```dart
/// TravelInterestChip(
///   interest: TravelInterest.food,
///   isSelected: _selectedInterests.contains(TravelInterest.food),
///   onToggle: (interest, selected) {
///     setState(() {
///       if (selected) {
///         _selectedInterests.add(interest);
///       } else {
///         _selectedInterests.remove(interest);
///       }
///     });
///   },
/// )
/// ```
class TravelInterestChip extends StatelessWidget {
  /// The travel interest to display
  final TravelInterest interest;

  /// Whether this interest is currently selected
  final bool isSelected;

  /// Callback when the chip is toggled
  final InterestSelectedCallback? onToggle;

  /// Whether the widget is enabled (for loading/disabled states)
  final bool enabled;

  /// Whether to use filled style when selected (vs outlined)
  final bool filledWhenSelected;

  /// Optional custom icon to display instead of emoji
  final IconData? customIcon;

  /// Chip visual density
  final VisualDensity visualDensity;

  const TravelInterestChip({
    super.key,
    required this.interest,
    required this.isSelected,
    this.onToggle,
    this.enabled = true,
    this.filledWhenSelected = true,
    this.customIcon,
    this.visualDensity = VisualDensity.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine colors based on selection state
    final selectedColor = theme.colorScheme.primary;
    final backgroundColor = isSelected && filledWhenSelected
        ? selectedColor.withOpacity(0.15)
        : theme.colorScheme.surface;
    final foregroundColor = isSelected && filledWhenSelected
        ? selectedColor
        : theme.colorScheme.onSurface.withOpacity(0.7);
    final borderColor = isSelected
        ? selectedColor
        : theme.colorScheme.outline.withOpacity(0.5);

    return FilterChip(
      label: _buildLabel(context),
      selected: isSelected,
      onSelected: enabled
          ? (selected) {
              if (onToggle != null) {
                onToggle!(interest, selected);
              }
            }
          : null,
      avatar: customIcon != null
          ? _buildCustomIcon(context)
          : _buildEmojiAvatar(context),
      selectedColor: selectedColor.withOpacity(0.15),
      disabledColor: theme.disabledColor.withOpacity(0.1),
      checkmarkColor: selectedColor,
      backgroundColor: backgroundColor,
      side: BorderSide(color: borderColor),
      elevation: isSelected ? 2 : 0,
      visualDensity: visualDensity,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor),
      ),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: enabled ? foregroundColor : foregroundColor.withOpacity(0.5),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  /// Builds the label widget
  Widget _buildLabel(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (customIcon == null) ...[
          Text(interest.emoji),
          const SizedBox(width: 6),
        ],
        Text(interest.label),
      ],
    );
  }

  /// Builds the emoji avatar (legacy support)
  Widget _buildEmojiAvatar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        interest.emoji,
        style: TextStyle(
          fontSize: 16,
          color: enabled
              ? null
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  /// Builds custom icon avatar
  Widget _buildCustomIcon(BuildContext context) {
    final theme = Theme.of(context);
    return Icon(
      customIcon,
      size: 18,
      color: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurface.withOpacity(0.5),
    );
  }
}

/// Compact version of TravelInterestChip for inline usage
///
/// Uses smaller dimensions and minimal styling for space-constrained UIs
class TravelInterestChipCompact extends StatelessWidget {
  /// The travel interest to display
  final TravelInterest interest;

  /// Whether this interest is currently selected
  final bool isSelected;

  /// Callback when the chip is toggled
  final InterestSelectedCallback? onToggle;

  /// Whether the widget is enabled
  final bool enabled;

  /// Whether to show the emoji
  final bool showEmoji;

  const TravelInterestChipCompact({
    super.key,
    required this.interest,
    required this.isSelected,
    this.onToggle,
    this.enabled = true,
    this.showEmoji = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: enabled
          ? () {
              if (onToggle != null) {
                onToggle!(interest, !isSelected);
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showEmoji) ...[
              Text(
                interest.emoji,
                style: TextStyle(
                  fontSize: 14,
                  color: enabled
                      ? null
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              interest.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: enabled
                    ? null
                    : theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid of interest chips for selection
///
/// Displays all available travel interests in a responsive grid layout
class TravelInterestGrid extends StatelessWidget {
  /// List of all available interests
  final Set<TravelInterest> availableInterests;

  /// Set of currently selected interests
  final Set<TravelInterest> selectedInterests;

  /// Callback when an interest is toggled
  final InterestSelectedCallback? onToggle;

  /// Whether the widget is enabled
  final bool enabled;

  /// Whether to use compact chips
  final bool useCompactChips;

  /// Number of columns in the grid
  final int crossAxisCount;

  /// Spacing between chips
  final double spacing;

  const TravelInterestGrid({
    super.key,
    required this.availableInterests,
    required this.selectedInterests,
    this.onToggle,
    this.enabled = true,
    this.useCompactChips = false,
    this.crossAxisCount = 2,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: useCompactChips ? 4 : 3,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: availableInterests.length,
      itemBuilder: (context, index) {
        final interest = availableInterests.elementAt(index);
        final isSelected = selectedInterests.contains(interest);

        if (useCompactChips) {
          return TravelInterestChipCompact(
            interest: interest,
            isSelected: isSelected,
            onToggle: onToggle,
            enabled: enabled,
          );
        }

        return TravelInterestChip(
          interest: interest,
          isSelected: isSelected,
          onToggle: onToggle,
          enabled: enabled,
        );
      },
    );
  }
}
