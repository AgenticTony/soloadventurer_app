import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/destination_filter.dart';
import '../../application/providers/filter_provider.dart';

/// A modal bottom sheet for advanced destination filtering options.
///
/// This widget provides comprehensive filter controls including:
/// - Budget level selection
/// - Safety score slider
/// - Activity level selection
/// - Solo suitability score slider
/// - Location/region filters
/// - Tag multi-select
/// - Sort order selection
/// - Hidden gems toggle
///
/// The modal integrates with [FilterProvider] for state management and
/// triggers a search callback when filters are applied.
///
/// Example usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (context) => FilterModal(
///     onApply: () {
///       // Trigger search with updated filters
///       ref.read(destinationSearchProvider.notifier).search(
///         ref.read(filterProvider),
///       );
///     },
///   ),
/// );
/// ```
class FilterModal extends ConsumerStatefulWidget {
  /// Callback when filters are applied
  final VoidCallback? onApply;

  /// Callback when modal is closed without applying
  final VoidCallback? onDismiss;

  /// Available tags for multi-select
  final List<String> availableTags;

  /// Whether to show the sort order selector
  final bool showSortOrder;

  const FilterModal({
    super.key,
    this.onApply,
    this.onDismiss,
    this.availableTags = const [
      'Beach',
      'Mountain',
      'Urban',
      'Cultural',
      'Adventure',
      'Nature',
      'Food',
      'Wellness',
      'Nightlife',
      'Shopping',
      'Historical',
      'Romantic',
    ],
    this.showSortOrder = true,
  });

  @override
  ConsumerState<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends ConsumerState<FilterModal> {
  /// Temporary filter state (applied only on "Apply")
  DestinationFilter? _tempFilter;

  @override
  void initState() {
    super.initState();
    // Initialize temporary filter with current state
    _tempFilter = ref.read(filterProvider);
  }

  /// Apply filters and close modal
  void _applyFilters() {
    if (_tempFilter != null) {
      ref.read(filterProvider.notifier).updateFilter(_tempFilter!);
    }
    widget.onApply?.call();
    Navigator.pop(context);
  }

  /// Reset all filters to default
  void _resetFilters() {
    setState(() {
      _tempFilter = const DestinationFilter();
    });
  }

  /// Calculate the number of active filters
  int _calculateActiveFilterCount(DestinationFilter filter) {
    int count = 0;
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) count++;
    if (filter.budgetLevel != null) count++;
    if (filter.minSafetyScore != null) count++;
    if (filter.minSoloSuitabilityScore != null) count++;
    if (filter.activityLevel != null) count++;
    if (filter.countryCode != null) count++;
    if (filter.region != null) count++;
    if (filter.tags != null && filter.tags!.isNotEmpty) count++;
    return count;
  }

  /// Update budget level filter
  void _updateBudgetLevel(FilterBudgetLevel? level) {
    setState(() {
      _tempFilter = _tempFilter!.copyWith(budgetLevel: level);
    });
  }

  /// Update activity level filter
  void _updateActivityLevel(FilterActivityLevel? level) {
    setState(() {
      _tempFilter = _tempFilter!.copyWith(activityLevel: level);
    });
  }

  /// Update minimum safety score
  void _updateMinSafetyScore(double score) {
    setState(() {
      _tempFilter = _tempFilter!.copyWith(minSafetyScore: score);
    });
  }

  /// Update minimum solo suitability score
  void _updateMinSoloSuitabilityScore(double score) {
    setState(() {
      _tempFilter = _tempFilter!.copyWith(minSoloSuitabilityScore: score);
    });
  }

  /// Update country code
  void _updateCountryCode(String? code) {
    setState(() {
      _tempFilter = _tempFilter!.copyWith(countryCode: code);
    });
  }

  /// Update region
  void _updateRegion(String? region) {
    setState(() {
      _tempFilter = _tempFilter!.copyWith(region: region);
    });
  }

  /// Toggle tag in filters
  void _toggleTag(String tag) {
    final currentTags = _tempFilter!.tags ?? [];
    final updatedTags = List<String>.from(currentTags);

    if (updatedTags.contains(tag)) {
      updatedTags.remove(tag);
    } else {
      updatedTags.add(tag);
    }

    setState(() {
      _tempFilter = _tempFilter!.copyWith(
        tags: updatedTags.isEmpty ? null : updatedTags,
      );
    });
  }

  /// Toggle hidden gems filter
  void _toggleHiddenGems() {
    setState(() {
      _tempFilter = _tempFilter!.copyWith(
        hiddenGemsOnly: !_tempFilter!.hiddenGemsOnly,
      );
    });
  }

  /// Update sort order
  void _updateSortOrder(DestinationSortOrder order) {
    setState(() {
      _tempFilter = _tempFilter!.copyWith(sortBy: order);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentFilter = _tempFilter!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          _buildHandleBar(theme),

          // Header
          _buildHeader(theme, currentFilter),

          // Filter options (scrollable)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Budget level section
                _FilterBudgetLevelSection(
                  selectedLevel: currentFilter.budgetLevel,
                  onLevelChanged: _updateBudgetLevel,
                ),

                const SizedBox(height: 24),

                // Safety score section
                _SafetyScoreSection(
                  minScore: currentFilter.minSafetyScore ?? 1.0,
                  onScoreChanged: _updateMinSafetyScore,
                ),

                const SizedBox(height: 24),

                // Solo suitability score section
                _SoloSuitabilitySection(
                  minScore: currentFilter.minSoloSuitabilityScore ?? 1.0,
                  onScoreChanged: _updateMinSoloSuitabilityScore,
                ),

                const SizedBox(height: 24),

                // Activity level section
                _FilterActivityLevelSection(
                  selectedLevel: currentFilter.activityLevel,
                  onLevelChanged: _updateActivityLevel,
                ),

                const SizedBox(height: 24),

                // Location section
                _LocationSection(
                  countryCode: currentFilter.countryCode,
                  region: currentFilter.region,
                  onCountryCodeChanged: _updateCountryCode,
                  onRegionChanged: _updateRegion,
                ),

                const SizedBox(height: 24),

                // Tags section
                _TagsSection(
                  selectedTags: currentFilter.tags ?? [],
                  availableTags: widget.availableTags,
                  onTagToggled: _toggleTag,
                ),

                const SizedBox(height: 24),

                // Hidden gems toggle
                _HiddenGemsSection(
                  isEnabled: currentFilter.hiddenGemsOnly,
                  onToggled: _toggleHiddenGems,
                ),

                const SizedBox(height: 24),

                // Sort order section
                if (widget.showSortOrder)
                  _SortOrderSection(
                    selectedOrder: currentFilter.sortBy,
                    onOrderChanged: _updateSortOrder,
                  ),

                const SizedBox(height: 100), // Space for bottom buttons
              ],
            ),
          ),

          // Bottom action buttons
          _buildActionButtons(theme, currentFilter),
        ],
      ),
    );
  }

  /// Build the handle bar at the top
  Widget _buildHandleBar(ThemeData theme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha:0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// Build the header with title and active filter count
  Widget _buildHeader(ThemeData theme, DestinationFilter filter) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filters',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (filter.hasActiveFilters)
                Text(
                  '${_calculateActiveFilterCount(filter)} active',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          if (filter.hasActiveFilters)
            TextButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear All'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }

  /// Build the bottom action buttons
  Widget _buildActionButtons(ThemeData theme, DestinationFilter filter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  widget.onDismiss?.call();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Budget level filter section
class _FilterBudgetLevelSection extends StatelessWidget {
  final FilterBudgetLevel? selectedLevel;
  final ValueChanged<FilterBudgetLevel?> onLevelChanged;

  const _FilterBudgetLevelSection({
    required this.selectedLevel,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Level',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FilterBudgetLevel.values.map((level) {
            final isSelected = selectedLevel == level;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getBudgetIcon(level), size: 16),
                  const SizedBox(width: 4),
                  Text(_getBudgetLabel(level)),
                ],
              ),
              selected: isSelected,
              onSelected: (_) {
                onLevelChanged(isSelected ? null : level);
              },
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
      ],
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

/// Safety score slider section
class _SafetyScoreSection extends StatelessWidget {
  final double minScore;
  final ValueChanged<double> onScoreChanged;

  const _SafetyScoreSection({
    required this.minScore,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Minimum safety score filter',
      value: '${minScore.toStringAsFixed(1)} out of 10',
      hint: 'Adjust slider to set minimum safety score for destinations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minimum Safety Score',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${minScore.toStringAsFixed(1)}+',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _getScoreColor(minScore),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: minScore,
            min: 1.0,
            max: 10.0,
            divisions: 18,
            label: minScore.toStringAsFixed(1),
            onChanged: onScoreChanged,
            activeColor: _getScoreColor(minScore),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '10.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return Colors.green.shade700;
    if (score >= 6.0) return Colors.orange.shade700;
    return Colors.red.shade700;
  }
}

/// Solo suitability score slider section
class _SoloSuitabilitySection extends StatelessWidget {
  final double minScore;
  final ValueChanged<double> onScoreChanged;

  const _SoloSuitabilitySection({
    required this.minScore,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Solo suitability score filter',
      value: '${minScore.toStringAsFixed(1)} out of 10',
      hint:
          'Adjust slider to set minimum solo suitability score for destinations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solo Suitability Score',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${minScore.toStringAsFixed(1)}+',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: minScore,
            min: 1.0,
            max: 10.0,
            divisions: 18,
            label: minScore.toStringAsFixed(1),
            onChanged: onScoreChanged,
            activeColor: theme.colorScheme.primary,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '10.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Activity level filter section
class _FilterActivityLevelSection extends StatelessWidget {
  final FilterActivityLevel? selectedLevel;
  final ValueChanged<FilterActivityLevel?> onLevelChanged;

  const _FilterActivityLevelSection({
    required this.selectedLevel,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Level',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FilterActivityLevel.values.map((level) {
            final isSelected = selectedLevel == level;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getActivityIcon(level), size: 16),
                  const SizedBox(width: 4),
                  Text(_getActivityLabel(level)),
                ],
              ),
              selected: isSelected,
              onSelected: (_) {
                onLevelChanged(isSelected ? null : level);
              },
              selectedColor: theme.colorScheme.secondaryContainer,
              checkmarkColor: theme.colorScheme.onSecondaryContainer,
            );
          }).toList(),
        ),
      ],
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

/// Location filter section
class _LocationSection extends StatelessWidget {
  final String? countryCode;
  final String? region;
  final ValueChanged<String?> onCountryCodeChanged;
  final ValueChanged<String?> onRegionChanged;

  const _LocationSection({
    required this.countryCode,
    required this.region,
    required this.onCountryCodeChanged,
    required this.onRegionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: TextEditingController(text: countryCode),
          decoration: const InputDecoration(
            labelText: 'Country Code (e.g., JP, US, TH)',
            prefixIcon: Icon(Icons.public),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          textCapitalization: TextCapitalization.characters,
          onChanged: (value) {
            onCountryCodeChanged(value.isEmpty ? null : value.toUpperCase());
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: TextEditingController(text: region),
          decoration: const InputDecoration(
            labelText: 'Region (e.g., Tokyo, California)',
            prefixIcon: Icon(Icons.location_city),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (value) {
            onRegionChanged(value.isEmpty ? null : value);
          },
        ),
      ],
    );
  }
}

/// Tags multi-select section
class _TagsSection extends StatelessWidget {
  final List<String> selectedTags;
  final List<String> availableTags;
  final ValueChanged<String> onTagToggled;

  const _TagsSection({
    required this.selectedTags,
    required this.availableTags,
    required this.onTagToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (selectedTags.isNotEmpty)
              Text(
                '${selectedTags.length} selected',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) => onTagToggled(tag),
              selectedColor: theme.colorScheme.tertiaryContainer,
              checkmarkColor: theme.colorScheme.onTertiaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Hidden gems toggle section
class _HiddenGemsSection extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onToggled;

  const _HiddenGemsSection({
    required this.isEnabled,
    required this.onToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SwitchListTile(
      title: const Row(
        children: [
          Icon(Icons.diamond, size: 20),
          SizedBox(width: 8),
          Text('Hidden Gems Only'),
        ],
      ),
      subtitle: Text(
        'Show only lesser-known destinations',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      value: isEnabled,
      onChanged: (_) => onToggled(),
      activeThumbColor: Colors.amber.shade700,
    );
  }
}

/// Sort order section
class _SortOrderSection extends StatelessWidget {
  final DestinationSortOrder selectedOrder;
  final ValueChanged<DestinationSortOrder> onOrderChanged;

  const _SortOrderSection({
    required this.selectedOrder,
    required this.onOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<DestinationSortOrder>(
          initialValue: selectedOrder,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            prefixIcon: Icon(Icons.sort),
          ),
          items: DestinationSortOrder.values.map((order) {
            return DropdownMenuItem(
              value: order,
              child: Row(
                children: [
                  Icon(_getSortIcon(order), size: 18),
                  const SizedBox(width: 8),
                  Text(_getSortLabel(order)),
                ],
              ),
            );
          }).toList(),
          onChanged: (order) {
            if (order != null) {
              onOrderChanged(order);
            }
          },
        ),
      ],
    );
  }

  String _getSortLabel(DestinationSortOrder order) {
    switch (order) {
      case DestinationSortOrder.popularity:
        return 'Popularity';
      case DestinationSortOrder.safety:
        return 'Safety Score';
      case DestinationSortOrder.soloSuitability:
        return 'Solo Suitability';
      case DestinationSortOrder.budgetAsc:
        return 'Budget (Low to High)';
      case DestinationSortOrder.budgetDesc:
        return 'Budget (High to Low)';
      case DestinationSortOrder.newest:
        return 'Newest';
      case DestinationSortOrder.relevance:
        return 'Relevance';
    }
  }

  IconData _getSortIcon(DestinationSortOrder order) {
    switch (order) {
      case DestinationSortOrder.popularity:
        return Icons.trending_up;
      case DestinationSortOrder.safety:
        return Icons.security;
      case DestinationSortOrder.soloSuitability:
        return Icons.person;
      case DestinationSortOrder.budgetAsc:
        return Icons.arrow_upward;
      case DestinationSortOrder.budgetDesc:
        return Icons.arrow_downward;
      case DestinationSortOrder.newest:
        return Icons.new_releases;
      case DestinationSortOrder.relevance:
        return Icons.search;
    }
  }
}
