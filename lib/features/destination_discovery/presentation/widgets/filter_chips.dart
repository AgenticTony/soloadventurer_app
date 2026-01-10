import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/destination.dart';
import '../../domain/models/destination_filter.dart';
import '../../application/providers/filter_provider.dart';

/// A horizontally scrollable list of filter chips for quick filtering.
///
/// This widget provides quick-access filter chips for common destination filter
/// categories including budget, activity level, and special categories like
/// hidden gems. It displays the current filter state and allows users to
/// toggle filters on/off with visual feedback.
///
/// The widget automatically shows a "Clear All" chip when any filters are active.
///
/// Example usage:
/// ```dart
/// FilterChips(
///   onFilterChanged: () {
///     // Trigger search with updated filters
///     ref.read(destinationSearchProvider.notifier).search(
///       ref.read(filterProvider),
///     );
///   },
/// )
/// ```
class FilterChips extends ConsumerWidget {
  /// Callback when a filter is changed (added or removed)
  final VoidCallback? onFilterChanged;

  /// Whether to show the budget level chips
  final bool showBudgetChips;

  /// Whether to show the activity level chips
  final bool showActivityChips;

  /// Whether to show the hidden gems chip
  final bool showHiddenGemsChip;

  /// Custom tags to show as chips (in addition to built-in filters)
  final List<String>? customTags;

  /// Padding around the chip list
  final EdgeInsets padding;

  /// Spacing between chips
  final double chipSpacing;

  /// Height of the chip row
  final double height;

  const FilterChips({
    super.key,
    this.onFilterChanged,
    this.showBudgetChips = true,
    this.showActivityChips = true,
    this.showHiddenGemsChip = true,
    this.customTags,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.chipSpacing = 8,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filterState = ref.watch(filterProvider);
    final filterNotifier = ref.read(filterProvider.notifier);

    return SizedBox(
      height: height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        children: [
          // Budget level chips
          if (showBudgetChips) ...[
            _BudgetChip(
              budgetLevel: BudgetLevel.budget,
              isSelected: filterState.budgetLevel == BudgetLevel.budget,
              onTap: () {
                _toggleBudget(filterNotifier, BudgetLevel.budget);
                onFilterChanged?.call();
              },
            ),
            SizedBox(width: chipSpacing),
            _BudgetChip(
              budgetLevel: BudgetLevel.moderate,
              isSelected: filterState.budgetLevel == BudgetLevel.moderate,
              onTap: () {
                _toggleBudget(filterNotifier, BudgetLevel.moderate);
                onFilterChanged?.call();
              },
            ),
            SizedBox(width: chipSpacing),
            _BudgetChip(
              budgetLevel: BudgetLevel.expensive,
              isSelected: filterState.budgetLevel == BudgetLevel.expensive,
              onTap: () {
                _toggleBudget(filterNotifier, BudgetLevel.expensive);
                onFilterChanged?.call();
              },
            ),
            SizedBox(width: chipSpacing),
          ],

          // Activity level chips
          if (showActivityChips) ...[
            _ActivityChip(
              activityLevel: ActivityLevel.relaxed,
              isSelected: filterState.activityLevel == ActivityLevel.relaxed,
              onTap: () {
                _toggleActivity(filterNotifier, ActivityLevel.relaxed);
                onFilterChanged?.call();
              },
            ),
            SizedBox(width: chipSpacing),
            _ActivityChip(
              activityLevel: ActivityLevel.moderate,
              isSelected: filterState.activityLevel == ActivityLevel.moderate,
              onTap: () {
                _toggleActivity(filterNotifier, ActivityLevel.moderate);
                onFilterChanged?.call();
              },
            ),
            SizedBox(width: chipSpacing),
            _ActivityChip(
              activityLevel: ActivityLevel.adventurous,
              isSelected:
                  filterState.activityLevel == ActivityLevel.adventurous,
              onTap: () {
                _toggleActivity(filterNotifier, ActivityLevel.adventurous);
                onFilterChanged?.call();
              },
            ),
            SizedBox(width: chipSpacing),
          ],

          // Hidden gems chip
          if (showHiddenGemsChip) ...[
            _HiddenGemChip(
              isSelected: filterState.hiddenGemsOnly,
              onTap: () {
                filterNotifier.toggleHiddenGemsOnly();
                onFilterChanged?.call();
              },
            ),
            SizedBox(width: chipSpacing),
          ],

          // Custom tags
          if (customTags != null) ...[
            ...customTags!.map((tag) {
              final isSelected = filterState.tags?.contains(tag) ?? false;
              return Padding(
                padding: EdgeInsets.only(right: chipSpacing),
                child: _TagChip(
                  tag: tag,
                  isSelected: isSelected,
                  onTap: () {
                    filterNotifier.toggleTag(tag);
                    onFilterChanged?.call();
                  },
                ),
              );
            }),
          ],

          // Clear all chip (only show when filters are active)
          if (filterState.hasActiveFilters) ...[
            _ClearAllChip(
              onTap: () {
                filterNotifier.reset();
                onFilterChanged?.call();
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Toggles budget level filter
  void _toggleBudget(FilterNotifier notifier, FilterBudgetLevel level) {
    // If already selected, deselect it; otherwise, select it
    if (notifier.budgetLevel == level) {
      notifier.updateBudgetLevel(null);
    } else {
      notifier.updateBudgetLevel(level);
    }
  }

  /// Toggles activity level filter
  void _toggleActivity(FilterNotifier notifier, FilterActivityLevel level) {
    // If already selected, deselect it; otherwise, select it
    if (notifier.activityLevel == level) {
      notifier.updateActivityLevel(null);
    } else {
      notifier.updateActivityLevel(level);
    }
  }
}

/// A budget level filter chip
class _BudgetChip extends StatelessWidget {
  final FilterBudgetLevel budgetLevel;
  final bool isSelected;
  final VoidCallback onTap;

  const _BudgetChip({
    required this.budgetLevel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = _getBudgetLabel(budgetLevel);
    final icon = _getBudgetIcon(budgetLevel);

    return Semantics(
      label: '$label budget filter',
      value: isSelected ? 'Selected' : 'Not selected',
      hint:
          'Double tap to ${isSelected ? "remove" : "apply"} $label budget filter',
      button: true,
      selected: isSelected,
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: theme.colorScheme.primaryContainer,
        checkmarkColor: theme.colorScheme.onPrimaryContainer,
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: isSelected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }

  String _getBudgetLabel(FilterBudgetLevel level) {
    switch (level) {
      case FilterBudgetLevel.budget:
        return 'Budget';
      case FilterBudgetLevel.economy:
        return 'Economy';
      case FilterBudgetLevel.midRange:
        return 'Mid-Range';
      case FilterBudgetLevel.premium:
        return 'Premium';
      case FilterBudgetLevel.luxury:
        return 'Luxury';
      case FilterBudgetLevel.ultraLuxury:
        return 'Ultra Luxury';
    }
  }

  IconData _getBudgetIcon(FilterBudgetLevel level) {
    switch (level) {
      case FilterBudgetLevel.budget:
        return Icons.attach_money;
      case FilterBudgetLevel.economy:
        return Icons.account_balance_wallet;
      case FilterBudgetLevel.midRange:
        return Icons.money;
      case FilterBudgetLevel.premium:
        return Icons.stars;
      case FilterBudgetLevel.luxury:
        return Icons.diamond;
      case FilterBudgetLevel.ultraLuxury:
        return Icons.emoji_events;
    }
  }
}

/// An activity level filter chip
class _ActivityChip extends StatelessWidget {
  final FilterActivityLevel activityLevel;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityChip({
    required this.activityLevel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = _getActivityLabel(activityLevel);
    final icon = _getActivityIcon(activityLevel);

    return Semantics(
      label: '$label activity level filter',
      value: isSelected ? 'Selected' : 'Not selected',
      hint:
          'Double tap to ${isSelected ? "remove" : "apply"} $label activity filter',
      button: true,
      selected: isSelected,
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: theme.colorScheme.primaryContainer,
        checkmarkColor: theme.colorScheme.onPrimaryContainer,
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: isSelected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }

  String _getActivityLabel(FilterActivityLevel level) {
    switch (level) {
      case FilterActivityLevel.relaxed:
        return 'Relaxed';
      case FilterActivityLevel.light:
        return 'Light';
      case FilterActivityLevel.moderate:
        return 'Moderate';
      case FilterActivityLevel.active:
        return 'Active';
      case FilterActivityLevel.intense:
        return 'Intense';
      case FilterActivityLevel.extreme:
        return 'Extreme';
    }
  }

  IconData _getActivityIcon(FilterActivityLevel level) {
    switch (level) {
      case FilterActivityLevel.relaxed:
        return Icons.self_improvement;
      case FilterActivityLevel.light:
        return Icons.directions_walk;
      case FilterActivityLevel.moderate:
        return Icons.hiking;
      case FilterActivityLevel.active:
        return Icons.terrain;
      case FilterActivityLevel.intense:
        return Icons.fire_mode;
      case FilterActivityLevel.extreme:
        return Icons.warning;
    }
  }
}

/// A hidden gems filter chip
class _HiddenGemChip extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _HiddenGemChip({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Hidden gems filter',
      value: isSelected ? 'Selected' : 'Not selected',
      hint:
          'Double tap to ${isSelected ? "remove" : "apply"} hidden gems filter',
      button: true,
      selected: isSelected,
      child: FilterChip(
        label: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.diamond, size: 16),
            SizedBox(width: 4),
            Text('Hidden Gems'),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.amber.withOpacity(0.2),
        checkmarkColor: Colors.amber.shade700,
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: isSelected
              ? Colors.amber.shade700
              : theme.colorScheme.onSurfaceVariant,
        ),
        side: BorderSide(
          color: isSelected
              ? Colors.amber.shade700
              : theme.colorScheme.outline.withOpacity(0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }
}

/// A custom tag filter chip
class _TagChip extends StatelessWidget {
  final String tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagChip({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$tag tag filter',
      value: isSelected ? 'Selected' : 'Not selected',
      hint: 'Double tap to ${isSelected ? "remove" : "apply"} $tag tag filter',
      button: true,
      selected: isSelected,
      child: FilterChip(
        label: Text(tag),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: theme.colorScheme.secondaryContainer,
        checkmarkColor: theme.colorScheme.onSecondaryContainer,
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: isSelected
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }
}

/// A clear all filters chip
class _ClearAllChip extends StatelessWidget {
  final VoidCallback onTap;

  const _ClearAllChip({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Clear all filters',
      hint: 'Removes all active filters. Double tap to clear',
      button: true,
      child: FilterChip(
        label: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear_all, size: 16),
            SizedBox(width: 4),
            Text('Clear All'),
          ],
        ),
        selected: false,
        onSelected: (_) => onTap(),
        backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.3),
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onErrorContainer,
        ),
        side: BorderSide(
          color: theme.colorScheme.error.withOpacity(0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }
}
