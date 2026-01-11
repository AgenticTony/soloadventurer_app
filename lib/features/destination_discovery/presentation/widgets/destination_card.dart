import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/destination.dart';
import 'safety_score_badge.dart';
import 'solo_suitability_badge.dart';
import '../utils/image_cache_manager.dart';

/// A reusable card widget for displaying destination preview with key information.
///
/// This card shows the destination's image, name, description, safety score,
/// solo suitability score, budget level, and location. It supports tap gestures
/// for navigation and includes a bookmark/save button.
class DestinationCard extends StatelessWidget {
  /// The destination to display
  final Destination destination;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Callback when the bookmark/save button is tapped
  final VoidCallback? onBookmarkTap;

  /// Whether the destination is currently saved/bookmarked
  final bool isSaved;

  /// Optional widget to display below the card content
  final Widget? trailing;

  /// Card border radius
  final double borderRadius;

  /// Card elevation
  final double elevation;

  const DestinationCard({
    super.key,
    required this.destination,
    this.onTap,
    this.onBookmarkTap,
    this.isSaved = false,
    this.trailing,
    this.borderRadius = 12,
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Semantics(
        label: 'Destination: ${destination.name}, ${destination.countryCode}',
        value: 'Safety score ${destination.safetyScore.toStringAsFixed(1)}, '
            'Solo suitability ${destination.soloSuitabilityScore.toStringAsFixed(1)}, '
            '${_getBudgetInfo(destination.budgetLevel)['label']} budget',
        hint: onTap != null ? 'Double tap to view destination details' : null,
        button: onTap != null,
        child: Card(
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section with bookmark button overlay
                _buildImageSection(context, theme),

                // Content section
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and location row
                      _buildHeaderRow(context, theme),
                      const SizedBox(height: 8),

                      // Badges row
                      _buildBadgesRow(context, theme),
                      const SizedBox(height: 8),

                      // Description
                      _buildDescription(context, theme),
                      const SizedBox(height: 8),

                      // Budget indicator
                      _buildBudgetIndicator(context, theme),

                      // Trailing widget if provided
                      if (trailing != null) ...[
                        const SizedBox(height: 12),
                        trailing!,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the image section with bookmark button overlay
  Widget _buildImageSection(BuildContext context, ThemeData theme) {
    final imageUrl = destination.coverImageUrl ??
        (destination.images.isNotEmpty ? destination.images.first : null);

    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(borderRadius),
            ),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    cacheManager: destinationImageCacheManager,
                    fadeInDuration: const Duration(milliseconds: 200),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.place,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.place,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),

          // Hidden gem badge
          if (destination.isHiddenGem)
            Positioned(
              top: 8,
              left: 8,
              child: _buildHiddenGemBadge(theme),
            ),

          // Bookmark button
          if (onBookmarkTap != null)
            Positioned(
              top: 8,
              right: 8,
              child: _buildBookmarkButton(context, theme),
            ),
        ],
      ),
    );
  }

  /// Builds the header row with name and location
  Widget _buildHeaderRow(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            destination.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.location_on,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          destination.countryCode,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Builds the badges row with safety and solo suitability scores
  Widget _buildBadgesRow(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        _buildSafetyScoreBadge(context, theme),
        const SizedBox(width: 8),
        _buildSoloSuitabilityBadge(context, theme),
      ],
    );
  }

  /// Builds the safety score badge
  Widget _buildSafetyScoreBadge(BuildContext context, ThemeData theme) {
    return SafetyScoreBadge(
      score: destination.safetyScore,
      label: 'Safety',
    );
  }

  /// Builds the solo suitability badge
  Widget _buildSoloSuitabilityBadge(BuildContext context, ThemeData theme) {
    return SoloSuitabilityBadge(
      score: destination.soloSuitabilityScore,
      label: 'Solo',
    );
  }

  /// Builds the description text
  Widget _buildDescription(BuildContext context, ThemeData theme) {
    return Text(
      destination.description,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the budget level indicator
  Widget _buildBudgetIndicator(BuildContext context, ThemeData theme) {
    final budgetInfo = _getBudgetInfo(destination.budgetLevel);

    return Row(
      children: [
        Icon(
          budgetInfo['icon'] as IconData,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          budgetInfo['label'] as String,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (destination.averageDailyCost != null) ...[
          const Spacer(),
          Text(
            '\$${destination.averageDailyCost}/day',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the bookmark button
  Widget _buildBookmarkButton(BuildContext context, ThemeData theme) {
    return Semantics(
      label: isSaved ? 'Remove from saved' : 'Save destination',
      hint: 'Double tap to ${isSaved ? "remove" : "save"} this destination',
      button: true,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        child: InkWell(
          onTap: onBookmarkTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface.withValues(alpha:0.9),
            ),
            child: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              size: 20,
              color: isSaved
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the hidden gem badge
  Widget _buildHiddenGemBadge(ThemeData theme) {
    return Semantics(
      label: 'Hidden gem destination',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha:0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.diamond,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'Hidden Gem',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns budget information based on budget level
  Map<String, dynamic> _getBudgetInfo(BudgetLevel level) {
    switch (level) {
      case BudgetLevel.budget:
        return {
          'icon': Icons.attach_money,
          'label': 'Budget-friendly',
        };
      case BudgetLevel.moderate:
        return {
          'icon': Icons.money,
          'label': 'Moderate',
        };
      case BudgetLevel.expensive:
        return {
          'icon': Icons.trending_up,
          'label': 'Luxury',
        };
    }
  }
}
