import 'package:flutter/material.dart';

/// A reusable badge widget for displaying safety scores with visual indicators.
///
/// This widget displays a safety score (typically 1-10) with color coding,
/// an appropriate icon, and optional label. The badge automatically adjusts
/// its appearance based on the score value:
/// - Green with security icon for high safety (≥8)
/// - Orange/yellow with warning icon for medium safety (≥6)
/// - Red with dangerous icon for low safety (<6)
///
/// Example usage:
/// ```dart
/// SafetyScoreBadge(
///   score: 8.5,
///   label: 'Safety',
/// )
///
/// SafetyScoreBadge(score: 7.2)
///
/// SafetyScoreBadge(
///   score: 5.0,
///   label: 'Safety Rating',
///   showLabel: true,
/// )
/// ```
class SafetyScoreBadge extends StatelessWidget {
  /// The safety score to display (typically 1-10)
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

  const SafetyScoreBadge({
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
    final color = _getSafetyScoreColor(score, theme);
    final icon = _getSafetyScoreIcon(score);
    final displayLabel = label ?? 'Safety';
    final safetyLevel = _getSafetyLevelLabel(score);

    return Semantics(
      label:
          '$displayLabel score: ${score.toStringAsFixed(1)} out of 10, $safetyLevel',
      value: score.toStringAsFixed(1),
      hint: 'Safety rating from 1 to 10',
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
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

  /// Returns the accessibility label for the safety level
  String _getSafetyLevelLabel(double score) {
    if (score >= 8) {
      return 'high safety';
    } else if (score >= 6) {
      return 'medium safety';
    } else {
      return 'low safety';
    }
  }

  /// Returns the color for the safety score.
  ///
  /// - Green (≥8): High safety
  /// - Orange (≥6): Medium safety
  /// - Red (<6): Low safety
  Color _getSafetyScoreColor(double score, ThemeData theme) {
    if (score >= 8) {
      return Colors.green;
    } else if (score >= 6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Returns the icon for the safety score.
  ///
  /// - security: High safety (≥8)
  /// - warning_amber: Medium safety (≥6)
  /// - dangerous: Low safety (<6)
  IconData _getSafetyScoreIcon(double score) {
    if (score >= 8) {
      return Icons.security;
    } else if (score >= 6) {
      return Icons.warning_amber;
    } else {
      return Icons.dangerous;
    }
  }
}
