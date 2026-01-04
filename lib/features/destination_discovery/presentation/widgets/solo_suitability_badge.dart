import 'package:flutter/material.dart';

/// A reusable badge widget for displaying solo suitability scores with visual indicators.
///
/// This widget displays a solo suitability score (typically 1-10) with color coding,
/// an appropriate icon, and optional label. The badge automatically adjusts
/// its appearance based on the score value:
/// - Blue with person icon for high suitability (≥8)
/// - Light blue with hiking icon for medium suitability (≥6)
/// - Grey with travel_explore icon for low suitability (<6)
///
/// Example usage:
/// ```dart
/// SoloSuitabilityBadge(
///   score: 9.0,
///   label: 'Solo',
/// )
///
/// SoloSuitabilityBadge(score: 7.5)
///
/// SoloSuitabilityBadge(
///   score: 6.0,
///   label: 'Solo Friendly',
///   showLabel: true,
/// )
/// ```
class SoloSuitabilityBadge extends StatelessWidget {
  /// The solo suitability score to display (typically 1-10)
  final double score;

  /// Optional label text to display next to the score
  final String? label;

  /// Whether to show the label text
  final bool showLabel;

  /// Badge padding
  final EdgeInsets padding;

  /// Border radius of the badge
  final double borderRadius;

  /// Icon size
  final double iconSize;

  const SoloSuitabilityBadge({
    super.key,
    required this.score,
    this.label,
    this.showLabel = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 12,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getSuitabilityColor(score, theme);
    final icon = _getSuitabilityIcon(score);
    final displayLabel = label ?? 'Solo';
    final suitabilityLevel = _getSuitabilityLevelLabel(score);

    return Semantics(
      label: '$displayLabel suitability score: ${score.toStringAsFixed(1)} out of 10, $suitabilityLevel',
      value: score.toStringAsFixed(1),
      hint: 'Solo travel suitability rating from 1 to 10',
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              score.toStringAsFixed(1),
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showLabel) ...[
              const SizedBox(width: 2),
              Text(
                displayLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Returns the accessibility label for the suitability level
  String _getSuitabilityLevelLabel(double score) {
    if (score >= 8) {
      return 'excellent for solo travelers';
    } else if (score >= 6) {
      return 'good for solo travelers';
    } else {
      return 'challenging for solo travelers';
    }
  }

  /// Returns the color for the solo suitability score.
  ///
  /// - Blue (≥8): Excellent solo suitability
  /// - Light Blue (≥6): Good solo suitability
  /// - Grey (<6): Challenging solo suitability
  Color _getSuitabilityColor(double score, ThemeData theme) {
    if (score >= 8) {
      return Colors.blue.shade700;
    } else if (score >= 6) {
      return Colors.lightBlue;
    } else {
      return Colors.grey.shade600;
    }
  }

  /// Returns the icon for the solo suitability score.
  ///
  /// - person: Excellent suitability (≥8)
  /// - hiking: Good suitability (≥6)
  /// - travel_explore: Challenging suitability (<6)
  IconData _getSuitabilityIcon(double score) {
    if (score >= 8) {
      return Icons.person;
    } else if (score >= 6) {
      return Icons.hiking;
    } else {
      return Icons.travel_explore;
    }
  }
}
