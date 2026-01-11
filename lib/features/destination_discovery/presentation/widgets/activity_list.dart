import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/destination.dart';

/// A widget for displaying popular activities for a destination.
///
/// This widget presents a list or grid of activities, showing each activity's
/// name, description, icon/image, category, and solo suitability indicator.
/// It supports both horizontal and vertical layouts, with customizable styling
/// and tap handlers for activity details.
///
/// Each activity shows:
/// - Activity icon or image
/// - Activity name and brief description
/// - Category badge with contextual icon
/// - Solo-friendly indicator
/// - Optional cost level
///
/// Example usage:
/// ```dart
/// ActivityList(
///   activities: destination.popularActivities,
///   layout: ActivityListLayout.list,
///   onActivityTap: (activity) {
///     // Navigate to activity details
///   },
/// )
///
/// ActivityList(
///   activities: destination.popularActivities,
///   layout: ActivityListLayout.grid,
///   gridCrossAxisCount: 2,
/// )
/// ```
class ActivityList extends StatelessWidget {
  /// List of activities to display
  final List<Activity> activities;

  /// Layout type for the activity list
  final ActivityListLayout layout;

  /// Callback when an activity is tapped
  final ValueChanged<Activity>? onActivityTap;

  /// Optional header title
  final String? title;

  /// Number of columns in grid layout (default: 2)
  final int gridCrossAxisCount;

  /// Aspect ratio for grid items (default: 1.3)
  final double gridAspectRatio;

  /// Height of list items in horizontal layout (default: 120)
  final double horizontalItemHeight;

  /// Whether to show activity descriptions (default: true)
  final bool showDescription;

  /// Whether to show category badges (default: true)
  final bool showCategory;

  /// Whether to show cost level (default: true)
  final bool showCostLevel;

  /// Padding around the widget
  final EdgeInsets padding;

  /// Spacing between items
  final double itemSpacing;

  const ActivityList({
    super.key,
    required this.activities,
    this.layout = ActivityListLayout.list,
    this.onActivityTap,
    this.title,
    this.gridCrossAxisCount = 2,
    this.gridAspectRatio = 1.3,
    this.horizontalItemHeight = 120,
    this.showDescription = true,
    this.showCategory = true,
    this.showCostLevel = true,
    this.padding = const EdgeInsets.all(16),
    this.itemSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (activities.isEmpty) {
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

          // Activities based on layout
          _buildActivitiesList(context, theme),
        ],
      ),
    );
  }

  /// Builds the activities list based on the selected layout
  Widget _buildActivitiesList(BuildContext context, ThemeData theme) {
    switch (layout) {
      case ActivityListLayout.grid:
        return _buildGridLayout(context, theme);
      case ActivityListLayout.horizontal:
        return _buildHorizontalLayout(context, theme);
      case ActivityListLayout.list:
      default:
        return _buildVerticalLayout(context, theme);
    }
  }

  /// Builds a vertical list layout
  Widget _buildVerticalLayout(BuildContext context, ThemeData theme) {
    return Column(
      children: activities.asMap().entries.map((entry) {
        final index = entry.key;
        final activity = entry.value;
        return Padding(
          padding: EdgeInsets.only(
              bottom: index < activities.length - 1 ? itemSpacing : 0),
          child: _ActivityCard(
            activity: activity,
            onTap: onActivityTap,
            showDescription: showDescription,
            showCategory: showCategory,
            showCostLevel: showCostLevel,
          ),
        );
      }).toList(),
    );
  }

  /// Builds a grid layout
  Widget _buildGridLayout(BuildContext context, ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCrossAxisCount,
        childAspectRatio: gridAspectRatio,
        crossAxisSpacing: itemSpacing,
        mainAxisSpacing: itemSpacing,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return _ActivityCard(
          activity: activities[index],
          onTap: onActivityTap,
          showDescription: showDescription,
          showCategory: showCategory,
          showCostLevel: showCostLevel,
          isGrid: true,
        );
      },
    );
  }

  /// Builds a horizontal scrollable list
  Widget _buildHorizontalLayout(BuildContext context, ThemeData theme) {
    return SizedBox(
      height: horizontalItemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: activities.length,
        separatorBuilder: (context, index) => SizedBox(width: itemSpacing),
        itemBuilder: (context, index) {
          return SizedBox(
            width: horizontalItemHeight * 1.5,
            child: _ActivityCard(
              activity: activities[index],
              onTap: onActivityTap,
              showDescription: false, // Hide description in horizontal layout
              showCategory: showCategory,
              showCostLevel: false, // Hide cost in horizontal layout
              isHorizontal: true,
            ),
          );
        },
      ),
    );
  }

  /// Builds the empty state when no activities are available
  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hiking,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No activities available',
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

/// Layout options for ActivityList
enum ActivityListLayout {
  /// Vertical list of activity cards
  list,

  /// Grid layout with multiple columns
  grid,

  /// Horizontal scrollable list
  horizontal,
}

/// A card widget for displaying a single activity.
///
/// This is a private widget used internally by [ActivityList].
class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final ValueChanged<Activity>? onTap;
  final bool showDescription;
  final bool showCategory;
  final bool showCostLevel;
  final bool isGrid;
  final bool isHorizontal;

  const _ActivityCard({
    required this.activity,
    this.onTap,
    this.showDescription = true,
    this.showCategory = true,
    this.showCostLevel = true,
    this.isGrid = false,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label:
          'Activity: ${activity.name}${", ${activity.category}"}${activity.soloFriendly ? ", Solo-friendly" : ""}',
      hint: onTap != null ? 'Double tap to view activity details' : null,
      button: onTap != null,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap != null ? () => onTap!(activity) : null,
          borderRadius: BorderRadius.circular(12),
          child: isGrid || isHorizontal
              ? _buildCompactLayout(context, theme)
              : _buildDetailedLayout(context, theme),
        ),
      ),
    );
  }

  /// Builds detailed layout (vertical list view)
  Widget _buildDetailedLayout(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Activity icon/image
          _buildActivityIcon(context, theme, size: 56),
          const SizedBox(width: 12),

          // Activity info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and badges row
                _buildHeaderRow(context, theme),
                const SizedBox(height: 8),

                // Description
                if (showDescription && activity.description != null)
                  _buildDescription(context, theme),
                const SizedBox(height: 8),

                // Category and cost
                if (showCategory || showCostLevel)
                  _buildMetadataRow(context, theme),
              ],
            ),
          ),

          // Solo-friendly badge
          _buildSoloFriendlyBadge(context, theme),
        ],
      ),
    );
  }

  /// Builds compact layout (grid or horizontal view)
  Widget _buildCompactLayout(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Activity icon/image
        Expanded(
          child: _buildActivityIcon(context, theme),
        ),

        // Activity info
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                activity.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Category badge
              if (showCategory) _buildCategoryBadge(theme),
              const SizedBox(height: 4),

              // Solo-friendly indicator
              _buildSoloFriendlyIndicator(context, theme),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the activity icon or image
  Widget _buildActivityIcon(
    BuildContext context,
    ThemeData theme, {
    double? size,
  }) {
    final iconSize = size ?? double.infinity;

    if (activity.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: iconSize,
          height: size ?? iconSize,
          child: CachedNetworkImage(
            imageUrl: activity.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: iconSize,
              height: size ?? iconSize,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: iconSize,
              height: size ?? iconSize,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                _getCategoryIcon(activity.category),
                size: size != null ? size * 0.5 : 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    // Fallback to category icon
    return Container(
      width: iconSize,
      height: size ?? iconSize,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(activity.category),
          size: size != null ? size * 0.5 : 32,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  /// Builds the header row with name and solo-friendly badge
  Widget _buildHeaderRow(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            activity.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showCostLevel && activity.costLevel != null) ...[
          const SizedBox(width: 8),
          _buildCostBadge(theme),
        ],
      ],
    );
  }

  /// Builds the activity description
  Widget _buildDescription(BuildContext context, ThemeData theme) {
    return Text(
      activity.description ?? '',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the metadata row with category
  Widget _buildMetadataRow(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        if (showCategory) _buildCategoryBadge(theme),
      ],
    );
  }

  /// Builds the category badge
  Widget _buildCategoryBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(activity.category),
            size: 14,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            activity.category,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the cost level badge
  Widget _buildCostBadge(ThemeData theme) {
    final costInfo = _getCostInfo(activity.costLevel!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            costInfo['icon'] as IconData,
            size: 14,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            costInfo['label'] as String,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the solo-friendly badge (for detailed layout)
  Widget _buildSoloFriendlyBadge(BuildContext context, ThemeData theme) {
    if (!activity.soloFriendly) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: 'Solo-friendly activity',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.lightBlue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.lightBlue,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person,
              size: 14,
              color: Colors.lightBlue,
            ),
            const SizedBox(width: 4),
            Text(
              'Solo',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the solo-friendly indicator (for compact layout)
  Widget _buildSoloFriendlyIndicator(BuildContext context, ThemeData theme) {
    if (!activity.soloFriendly) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const Icon(
          Icons.person,
          size: 12,
          color: Colors.lightBlue,
        ),
        const SizedBox(width: 4),
        Text(
          'Solo-friendly',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Returns the icon for the activity category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      // Outdoor activities
      case 'outdoor':
      case 'adventure':
      case 'hiking':
      case 'nature':
        return Icons.hiking;

      // Cultural activities
      case 'cultural':
      case 'museum':
      case 'history':
      case 'art':
        return Icons.museum;

      // Food and dining
      case 'food':
      case 'dining':
      case 'restaurant':
      case 'culinary':
        return Icons.restaurant;

      // Nightlife
      case 'nightlife':
      case 'bar':
      case 'club':
        return Icons.local_bar;

      // Transportation
      case 'transport':
      case 'transportation':
      case 'transit':
        return Icons.directions_transit;

      // Wellness and spa
      case 'wellness':
      case 'spa':
      case 'relaxation':
        return Icons.spa;

      // Shopping
      case 'shopping':
      case 'market':
        return Icons.shopping_bag;

      // Entertainment
      case 'entertainment':
      case 'show':
      case 'performance':
        return Icons.theater_comedy;

      // Sports
      case 'sports':
      case 'fitness':
        return Icons.sports_basketball;

      // Beach and water
      case 'beach':
      case 'water':
      case 'swimming':
        return Icons.beach_access;

      // Sightseeing
      case 'sightseeing':
      case 'tour':
      case 'landmarks':
        return Icons.tour;

      // Photography
      case 'photography':
        return Icons.camera_alt;

      // Music
      case 'music':
      case 'concert':
        return Icons.music_note;

      // Default icon
      default:
        return Icons.attractions;
    }
  }

  /// Returns cost information based on cost level
  Map<String, dynamic> _getCostInfo(String costLevel) {
    switch (costLevel.toLowerCase()) {
      case 'free':
        return {
          'icon': Icons.money_off,
          'label': 'Free',
        };
      case 'low':
      case 'budget':
        return {
          'icon': Icons.attach_money,
          'label': 'Low',
        };
      case 'medium':
      case 'moderate':
        return {
          'icon': Icons.money,
          'label': 'Medium',
        };
      case 'high':
      case 'expensive':
        return {
          'icon': Icons.trending_up,
          'label': 'High',
        };
      default:
        return {
          'icon': Icons.paid,
          'label': costLevel,
        };
    }
  }
}
