import 'package:flutter/material.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/budget_range.dart';

/// Callback type for budget selection changes
typedef BudgetSelectedCallback = void Function(BudgetRange? budget);

/// Reusable widget for selecting budget range
///
/// Features:
/// - Segmented button style for budget selection
/// - Optional "Skip" option for no budget preference
/// - Visual feedback with icons and descriptions
/// - Supports both required and optional budget selection
/// - Follows Material Design guidelines
///
/// Example usage:
/// ```dart
/// BudgetSelectionWidget(
///   selectedBudget: _selectedBudget,
///   onBudgetChanged: (budget) => setState(() => _selectedBudget = budget),
///   isRequired: false,
/// )
/// ```
class BudgetSelectionWidget extends StatelessWidget {
  /// Currently selected budget (null means no selection/skipped)
  final BudgetRange? selectedBudget;

  /// Callback when budget is changed
  final BudgetSelectedCallback? onBudgetChanged;

  /// Whether budget selection is required (forces a selection)
  final bool isRequired;

  /// Whether to show the "Skip" option
  final bool showSkipOption;

  /// Whether to wrap the widget in a Card
  final bool wrapInCard;

  /// Optional custom title for the selector section
  final String? title;

  /// Optional custom description/instructions
  final String? description;

  /// Visual density for the buttons
  final VisualDensity visualDensity;

  const BudgetSelectionWidget({
    super.key,
    this.selectedBudget,
    this.onBudgetChanged,
    this.isRequired = false,
    this.showSkipOption = true,
    this.wrapInCard = false,
    this.title,
    this.description,
    this.visualDensity = VisualDensity.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional title and description
        if (title != null) ...[
          _buildSectionHeader(context, title!),
          const SizedBox(height: 8),
        ],
        if (description != null) ...[
          Text(
            description!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Budget options
        _buildBudgetOptions(context),
      ],
    );

    if (wrapInCard) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: content,
        ),
      );
    }

    return content;
  }

  /// Builds section header with consistent styling
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  /// Builds the budget selection options
  Widget _buildBudgetOptions(BuildContext context) {
    // Build button segments
    final segments = <ButtonSegment<BudgetRange?>>[
      const ButtonSegment(
        value: BudgetRange.budgetFriendly,
        label: Text('Budget-Friendly'),
        icon: Icon(Icons.savings, size: 18),
      ),
      const ButtonSegment(
        value: BudgetRange.moderate,
        label: Text('Moderate'),
        icon: Icon(Icons.account_balance_wallet, size: 18),
      ),
      const ButtonSegment(
        value: BudgetRange.flexible,
        label: Text('Flexible'),
        icon: Icon(Icons.diamond, size: 18),
      ),
    ];

    // Add skip option if enabled
    if (showSkipOption && !isRequired) {
      segments.add(
        const ButtonSegment(
          value: null,
          label: Text('Skip'),
          icon: Icon(Icons.block, size: 18),
        ),
      );
    }

    return SegmentedButton<BudgetRange?>(
      segments: segments,
      selected: selectedBudget != null
          ? {selectedBudget}
          : (isRequired && BudgetRange.values.isNotEmpty)
              ? {BudgetRange.values.first}
              : <BudgetRange?>{},
      emptySelectionAllowed: !isRequired,
      onSelectionChanged: (Set<BudgetRange?> newSelection) {
        if (newSelection.isNotEmpty && onBudgetChanged != null) {
          onBudgetChanged!(newSelection.first);
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            final budget = selectedBudget;
            if (budget == BudgetRange.budgetFriendly) {
              return Colors.green.withValues(alpha: 0.15);
            } else if (budget == BudgetRange.moderate) {
              return Colors.blue.withValues(alpha: 0.15);
            } else if (budget == BudgetRange.flexible) {
              return Colors.purple.withValues(alpha: 0.15);
            }
          }
          return null;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            final budget = selectedBudget;
            if (budget == BudgetRange.budgetFriendly) {
              return Colors.green.shade700;
            } else if (budget == BudgetRange.moderate) {
              return Colors.blue.shade700;
            } else if (budget == BudgetRange.flexible) {
              return Colors.purple.shade700;
            }
          }
          return null;
        }),
        visualDensity: visualDensity,
      ),
    );
  }
}

/// Card-style budget selection widget with detailed descriptions
///
/// Shows each budget option as a selectable card with full description
class BudgetSelectionCard extends StatelessWidget {
  /// Currently selected budget (null means no selection/skipped)
  final BudgetRange? selectedBudget;

  /// Callback when budget is changed
  final BudgetSelectedCallback? onBudgetChanged;

  /// Whether budget selection is required
  final bool isRequired;

  /// Whether to show the "Skip" option
  final bool showSkipOption;

  const BudgetSelectionCard({
    super.key,
    this.selectedBudget,
    this.onBudgetChanged,
    this.isRequired = false,
    this.showSkipOption = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBudgetOptionCard(
          context: context,
          budget: BudgetRange.budgetFriendly,
          icon: Icons.savings,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildBudgetOptionCard(
          context: context,
          budget: BudgetRange.moderate,
          icon: Icons.account_balance_wallet,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildBudgetOptionCard(
          context: context,
          budget: BudgetRange.flexible,
          icon: Icons.diamond,
          color: Colors.purple,
        ),
        if (showSkipOption && !isRequired) ...[
          const SizedBox(height: 12),
          _buildSkipOption(context),
        ],
      ],
    );
  }

  Widget _buildBudgetOptionCard({
    required BuildContext context,
    required BudgetRange budget,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedBudget == budget;

    return InkWell(
      onTap: onBudgetChanged != null ? () => onBudgetChanged!(budget) : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : color.withValues(alpha: 0.6),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    budget.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected ? color : null,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    budget.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipOption(BuildContext context) {
    final theme = Theme.of(context);
    final isSkipped = selectedBudget == null;

    return InkWell(
      onTap: onBudgetChanged != null ? () => onBudgetChanged!(null) : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSkipped
              ? Colors.grey.withValues(alpha: 0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSkipped
                ? Colors.grey
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSkipped ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.block,
              color:
                  isSkipped ? Colors.grey : Colors.grey.withValues(alpha: 0.6),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skip',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSkipped ? Colors.grey : null,
                      fontWeight:
                          isSkipped ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'I\'ll decide later (no budget preference)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSkipped)
              const Icon(
                Icons.check_circle,
                color: Colors.grey,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact horizontal budget selector for inline usage
///
/// Uses smaller buttons in a horizontal row for space-constrained UIs
class BudgetSelectionCompact extends StatelessWidget {
  /// Currently selected budget (null means no selection/skipped)
  final BudgetRange? selectedBudget;

  /// Callback when budget is changed
  final BudgetSelectedCallback? onBudgetChanged;

  /// Whether budget selection is required
  final bool isRequired;

  /// Whether to show the "Skip" option
  final bool showSkipOption;

  const BudgetSelectionCompact({
    super.key,
    this.selectedBudget,
    this.onBudgetChanged,
    this.isRequired = false,
    this.showSkipOption = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildCompactChip(
          context: context,
          budget: BudgetRange.budgetFriendly,
          icon: Icons.savings,
          color: Colors.green,
        ),
        _buildCompactChip(
          context: context,
          budget: BudgetRange.moderate,
          icon: Icons.account_balance_wallet,
          color: Colors.blue,
        ),
        _buildCompactChip(
          context: context,
          budget: BudgetRange.flexible,
          icon: Icons.diamond,
          color: Colors.purple,
        ),
        if (showSkipOption && !isRequired) _buildSkipChip(context),
      ],
    );
  }

  Widget _buildCompactChip({
    required BuildContext context,
    required BudgetRange budget,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedBudget == budget;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(budget.label),
        ],
      ),
      selected: isSelected,
      onSelected: onBudgetChanged != null
          ? (selected) => onBudgetChanged!(budget)
          : null,
      avatar: null,
      selectedColor: color.withValues(alpha: 0.15),
      checkmarkColor: color,
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: isSelected
            ? color
            : theme.colorScheme.outline.withValues(alpha: 0.5),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildSkipChip(BuildContext context) {
    final theme = Theme.of(context);
    final isSkipped = selectedBudget == null;

    return FilterChip(
      label: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block, size: 16),
          SizedBox(width: 4),
          Text('Skip'),
        ],
      ),
      selected: isSkipped,
      onSelected:
          onBudgetChanged != null ? (selected) => onBudgetChanged!(null) : null,
      avatar: null,
      selectedColor: Colors.grey.withValues(alpha: 0.15),
      checkmarkColor: Colors.grey,
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: isSkipped
            ? Colors.grey
            : theme.colorScheme.outline.withValues(alpha: 0.5),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
