import 'package:flutter/material.dart';
import '../../domain/models/destination.dart';

/// A widget for displaying detailed safety insights for a destination.
///
/// This widget presents a list of safety insights organized by category,
/// with each insight showing its severity level, description, and safety tips.
/// Insights are displayed in expandable cards that can be collapsed/expanded
/// for better information density.
///
/// Each insight includes:
/// - Category name with contextual icon
/// - Severity indicator (low/medium/high) with color coding
/// - Detailed description
/// - List of actionable safety tips
///
/// Example usage:
/// ```dart
/// SafetyInsights(
///   insights: destination.safetyInsights,
/// )
///
/// SafetyInsights(
///   insights: destination.safetyInsights,
///   initiallyExpanded: 2, // First 2 insights expanded by default
/// )
/// ```
class SafetyInsights extends StatelessWidget {
  /// List of safety insights to display
  final List<SafetyInsight> insights;

  /// Number of insights to have expanded initially (default: 0)
  final int initiallyExpanded;

  /// Optional header title
  final String? title;

  /// Whether to show icons for each insight (default: true)
  final bool showIcons;

  /// Padding around the widget
  final EdgeInsets padding;

  const SafetyInsights({
    super.key,
    required this.insights,
    this.initiallyExpanded = 0,
    this.title,
    this.showIcons = true,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (insights.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional title
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Insights list
          ...insights.asMap().entries.map((entry) {
            final index = entry.key;
            final insight = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SafetyInsightCard(
                insight: insight,
                initiallyExpanded: index < initiallyExpanded,
                showIcon: showIcons,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Builds the empty state when no insights are available
  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No safety information available',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card widget for displaying a single safety insight.
///
/// This is a private widget used internally by [SafetyInsights].
class _SafetyInsightCard extends StatefulWidget {
  final SafetyInsight insight;
  final bool initiallyExpanded;
  final bool showIcon;

  const _SafetyInsightCard({
    required this.insight,
    required this.initiallyExpanded,
    required this.showIcon,
  });

  @override
  State<_SafetyInsightCard> createState() => _SafetyInsightCardState();
}

class _SafetyInsightCardState extends State<_SafetyInsightCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = _getSeverityColor(widget.insight.severity, theme);
    final severityIcon = _getSeverityIcon(widget.insight.severity);
    final categoryIcon = _getCategoryIcon(widget.insight.category);

    return Semantics(
      label:
          '${widget.insight.category} safety information, ${widget.insight.severity} severity',
      value: _isExpanded ? 'Expanded' : 'Collapsed',
      hint:
          'Double tap to ${_isExpanded ? "collapse" : "expand"} safety details',
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: severityColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header section (always visible)
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Category icon
                    if (widget.showIcon) ...[
                      Icon(
                        categoryIcon,
                        color: severityColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Category and severity
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.insight.category,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                severityIcon,
                                size: 14,
                                color: severityColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.insight.severity.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: severityColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Expand/collapse icon
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _isExpanded ? 0.5 : 0,
                      child: Icon(
                        Icons.expand_more,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content (description and tips)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? _buildExpandedContent(context, theme, severityColor)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the expanded content section with description and tips
  Widget _buildExpandedContent(
    BuildContext context,
    ThemeData theme,
    Color severityColor,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            widget.insight.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Tips section
          if (widget.insight.tips.isNotEmpty) ...[
            Text(
              'Safety Tips:',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: severityColor,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.insight.tips.asMap().entries.map((entry) {
              final index = entry.key;
              final tip = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: severityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  /// Returns the color for the severity level.
  Color _getSeverityColor(String severity, ThemeData theme) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  /// Returns the icon for the severity level.
  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Icons.check_circle;
      case 'medium':
        return Icons.warning_amber;
      case 'high':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  /// Returns the icon for the insight category.
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      // Theft and crime
      case 'theft':
      case 'pickpocketing':
      case 'crime':
        return Icons.shopping_bag;

      // Transportation
      case 'transportation':
      case 'transport':
      case 'public transit':
      case 'taxi':
        return Icons.directions_transit;

      // Nightlife and social
      case 'nightlife':
      case 'bars':
      case 'clubs':
      case 'social':
        return Icons.local_bar;

      // Scams
      case 'scams':
      case 'fraud':
        return Icons.money_off;

      // Natural hazards
      case 'natural':
      case 'weather':
      case 'natural hazards':
        return Icons.cloud;

      // Health and medical
      case 'health':
      case 'medical':
        return Icons.local_hospital;

      // Women's safety
      case 'women':
      case 'female':
        return Icons.woman;

      // LGBTQ+ safety
      case 'lgbtq':
      case 'lgbtq+':
        return Icons.diversity_3;

      // Political and civil unrest
      case 'political':
      case 'civil unrest':
      case 'protests':
        return Icons.gavel;

      // Terrorism
      case 'terrorism':
        return Icons.warning;

      // Water and food safety
      case 'water':
      case 'food':
        return Icons.restaurant;

      // General safety
      case 'general':
      case 'overall':
      default:
        return Icons.security;
    }
  }
}
