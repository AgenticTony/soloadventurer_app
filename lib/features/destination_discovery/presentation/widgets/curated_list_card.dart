import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/curated_list.dart';
import '../utils/image_cache_manager.dart';

/// A reusable card widget for displaying curated destination lists with key information.
///
/// This card shows the curated list's cover image, name, description, type badge,
/// destination count, and a preview of destinations in the list. It supports
/// tap gestures for navigation and follows the design patterns of DestinationCard.
///
/// Example usage:
/// ```dart
/// CuratedListCard(
///   curatedList: myList,
///   onTap: () {
///     // Navigate to curated list detail
///   },
/// )
/// ```
class CuratedListCard extends StatelessWidget {
  /// The curated list to display
  final CuratedList curatedList;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Optional widget to display below the card content
  final Widget? trailing;

  /// Card border radius
  final double borderRadius;

  /// Card elevation
  final double elevation;

  /// Number of preview destinations to show
  final int previewCount;

  const CuratedListCard({
    super.key,
    required this.curatedList,
    this.onTap,
    this.trailing,
    this.borderRadius = 12,
    this.elevation = 2,
    this.previewCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeInfo = _getTypeInfo(curatedList.type);

    return RepaintBoundary(
      child: Semantics(
        label:
            'Curated list: ${curatedList.name}, ${curatedList.destinationCountLabel}, ${typeInfo['label']} collection',
        hint: onTap != null ? 'Double tap to view curated list details' : null,
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
                // Image section with badges overlay
                _buildImageSection(context, theme),

                // Content section
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name row
                      _buildNameRow(context, theme),
                      const SizedBox(height: 8),

                      // Type badge and destination count
                      _buildMetadataRow(context, theme),
                      const SizedBox(height: 8),

                      // Description
                      _buildDescription(context, theme),
                      const SizedBox(height: 12),

                      // Preview destinations
                      if (curatedList.hasDestinations)
                        _buildDestinationsPreview(context, theme),

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

  /// Builds the image section with badges overlay
  Widget _buildImageSection(BuildContext context, ThemeData theme) {
    final imageUrl = curatedList.coverImageUrl ??
        (curatedList.hasGalleryImages ? curatedList.images!.first : null);

    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        children: [
          // Cover image
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
                    cacheManager: curatedListImageCacheManager,
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
                          Icons.travel_explore,
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
                        Icons.travel_explore,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),

          // Featured badge
          if (curatedList.isFeatured)
            Positioned(
              top: 8,
              left: 8,
              child: _buildFeaturedBadge(theme),
            ),

          // Hidden gems badge
          if (curatedList.isHiddenGemsList)
            Positioned(
              top: 8,
              left: curatedList.isFeatured ? null : 8,
              right: curatedList.isFeatured ? null : 8,
              child: _buildHiddenGemBadge(theme),
            ),

          // Type badge (shown in top right if not hidden gems)
          if (!curatedList.isHiddenGemsList)
            Positioned(
              top: 8,
              right: 8,
              child: _buildTypeBadge(theme),
            ),
        ],
      ),
    );
  }

  /// Builds the name row with optional curator info
  Widget _buildNameRow(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            curatedList.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds the metadata row with type and destination count
  Widget _buildMetadataRow(BuildContext context, ThemeData theme) {
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Type badge (small version)
        _buildSmallTypeBadge(theme),
        const SizedBox(width: 8),

        // Destination count
        Icon(
          Icons.place,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          curatedList.destinationCountLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        // View count if popular
        if (curatedList.isPopular) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.visibility,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            _formatViewCount(curatedList.viewCount),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the description text
  Widget _buildDescription(BuildContext context, ThemeData theme) {
    return Text(
      curatedList.description,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the preview of destinations in this list
  Widget _buildDestinationsPreview(BuildContext context, ThemeData theme) {
    final previewDestinations = curatedList.previewDestinations;

    if (previewDestinations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Destinations',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: previewDestinations.take(previewCount).map((destination) {
            return _buildDestinationChip(context, theme, destination);
          }).toList(),
        ),
      ],
    );
  }

  /// Builds a small chip for a preview destination
  Widget _buildDestinationChip(
    BuildContext context,
    ThemeData theme,
    dynamic destination,
  ) {
    final destinationName = destination.name?.toString() ?? 'Unknown';
    final destinationImage = destination.coverImageUrl?.toString() ??
        (destination.images?.isNotEmpty == true
            ? destination.images.first.toString()
            : null);

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Small destination image
          if (destinationImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: destinationImage,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                cacheManager: destinationThumbnailCacheManager,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (context, url) => Container(
                  width: 32,
                  height: 32,
                  color: theme.colorScheme.surfaceContainer,
                  child: Center(
                    child: SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 32,
                  height: 32,
                  color: theme.colorScheme.surfaceContainer,
                  child: Icon(
                    Icons.place,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Icon(
                Icons.place,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

          // Destination name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              destinationName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the featured badge
  Widget _buildFeaturedBadge(ThemeData theme) {
    return Semantics(
      label: 'Featured curated list',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'Featured',
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

  /// Builds the hidden gem badge
  Widget _buildHiddenGemBadge(ThemeData theme) {
    return Semantics(
      label: 'Hidden gems collection',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.9),
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
              'Hidden Gems',
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

  /// Builds the large type badge (for overlay on image)
  Widget _buildTypeBadge(ThemeData theme) {
    final typeInfo = _getTypeInfo(curatedList.type);

    return Semantics(
      label: '${typeInfo['label']} collection type',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: typeInfo['color'] as Color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              typeInfo['icon'] as IconData,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              typeInfo['label'] as String,
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

  /// Builds the small type badge (for metadata row)
  Widget _buildSmallTypeBadge(ThemeData theme) {
    final typeInfo = _getTypeInfo(curatedList.type);

    return Semantics(
      label: '${typeInfo['label']} type',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: (typeInfo['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: typeInfo['color'] as Color,
            width: 1,
          ),
        ),
        child: Text(
          typeInfo['label'] as String,
          style: theme.textTheme.labelSmall?.copyWith(
            color: typeInfo['color'] as Color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Returns type information including icon, label, and color
  Map<String, dynamic> _getTypeInfo(CuratedListType type) {
    switch (type) {
      case CuratedListType.popularSolo:
        return {
          'icon': Icons.trending_up,
          'label': 'Popular',
          'color': Colors.purple,
        };
      case CuratedListType.hiddenGems:
        return {
          'icon': Icons.diamond,
          'label': 'Hidden Gems',
          'color': Colors.amber,
        };
      case CuratedListType.budgetFriendly:
        return {
          'icon': Icons.attach_money,
          'label': 'Budget',
          'color': Colors.green,
        };
      case CuratedListType.adventure:
        return {
          'icon': Icons.hiking,
          'label': 'Adventure',
          'color': Colors.orange,
        };
      case CuratedListType.cultural:
        return {
          'icon': Icons.museum,
          'label': 'Cultural',
          'color': Colors.brown,
        };
      case CuratedListType.beach:
        return {
          'icon': Icons.beach_access,
          'label': 'Beach',
          'color': Colors.lightBlue,
        };
      case CuratedListType.urban:
        return {
          'icon': Icons.location_city,
          'label': 'Urban',
          'color': Colors.blueGrey,
        };
      case CuratedListType.nature:
        return {
          'icon': Icons.park,
          'label': 'Nature',
          'color': Colors.green.shade700,
        };
      case CuratedListType.food:
        return {
          'icon': Icons.restaurant,
          'label': 'Food',
          'color': Colors.red.shade700,
        };
      case CuratedListType.wellness:
        return {
          'icon': Icons.spa,
          'label': 'Wellness',
          'color': Colors.teal,
        };
      case CuratedListType.seasonal:
        return {
          'icon': Icons.calendar_today,
          'label': 'Seasonal',
          'color': Colors.indigo,
        };
      case CuratedListType.custom:
        return {
          'icon': Icons.playlist_add_check,
          'label': 'Custom',
          'color': Colors.cyan,
        };
    }
  }

  /// Formats view count for display
  String _formatViewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k views';
    }
    return '$count views';
  }
}
