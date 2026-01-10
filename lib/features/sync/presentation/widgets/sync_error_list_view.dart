import 'package:flutter/material.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';
import 'sync_error_card.dart';

/// List view widget for displaying multiple sync errors
///
/// Features:
/// - Shows all errors in a scrollable list
/// - Empty state when no errors
/// - Filter and sort options
/// - Dismiss all action
/// - Retry all action
class SyncErrorListView extends StatefulWidget {
  /// List of errors to display
  final List<SyncError> errors;

  /// Callback when a specific error is retried
  final Function(SyncError)? onRetryError;

  /// Callback when a specific error is dismissed
  final Function(SyncError)? onDismissError;

  /// Callback when user requests help for an error
  final Function(SyncError)? onHelpError;

  /// Callback when user taps to retry all retryable errors
  final VoidCallback? onRetryAll;

  /// Callback when user taps to dismiss all errors
  final VoidCallback? onDismissAll;

  /// Whether errors can be dismissed
  final bool isDismissible;

  /// Whether to show filter options
  final bool showFilters;

  const SyncErrorListView({
    super.key,
    required this.errors,
    this.onRetryError,
    this.onDismissError,
    this.onHelpError,
    this.onRetryAll,
    this.onDismissAll,
    this.isDismissible = true,
    this.showFilters = true,
  });

  @override
  State<SyncErrorListView> createState() => _SyncErrorListViewState();
}

class _SyncErrorListViewState extends State<SyncErrorListView> {
  SyncErrorSeverity? _selectedSeverity;
  SyncErrorType? _selectedType;
  ErrorSortOption _sortOption = ErrorSortOption.newest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredErrors = _filterAndSortErrors();

    if (filteredErrors.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with stats and actions
        _buildHeader(context, theme, filteredErrors),

        // Filter bar (if enabled)
        if (widget.showFilters) _buildFilterBar(context, theme),

        // Error list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredErrors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              final error = filteredErrors[index];
              return SyncErrorCard(
                error: error,
                onRetry: widget.onRetryError != null
                    ? () => widget.onRetryError!(error)
                    : null,
                onDismiss: widget.isDismissible && widget.onDismissError != null
                    ? () => widget.onDismissError!(error)
                    : null,
                onHelp: widget.onHelpError != null
                    ? () => widget.onHelpError!(error)
                    : null,
                isDismissible: widget.isDismissible,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the empty state widget
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Errors',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'All sync operations are running smoothly',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header with stats and actions
  Widget _buildHeader(
      BuildContext context, ThemeData theme, List<SyncError> displayErrors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and stats
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: _getHighestSeverityColor(theme),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${displayErrors.length} Error${displayErrors.length > 1 ? 's' : ''}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Severity breakdown
          const SizedBox(height: 8),
          _buildSeverityBreakdown(theme),

          // Action buttons
          if (widget.onRetryAll != null || widget.onDismissAll != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Retry all retryable errors
                if (widget.onRetryAll != null &&
                    _hasRetryableErrors(displayErrors))
                  FilledButton.tonalIcon(
                    onPressed: widget.onRetryAll,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry All'),
                  ),

                // Dismiss all errors
                if (widget.onDismissAll != null && widget.isDismissible)
                  OutlinedButton.icon(
                    onPressed: widget.onDismissAll,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Dismiss All'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the severity breakdown bar
  Widget _buildSeverityBreakdown(ThemeData theme) {
    final highCount =
        widget.errors.where((e) => e.severity == SyncErrorSeverity.high).length;
    final mediumCount = widget.errors
        .where((e) => e.severity == SyncErrorSeverity.medium)
        .length;
    final lowCount =
        widget.errors.where((e) => e.severity == SyncErrorSeverity.low).length;

    return Row(
      children: [
        if (highCount > 0)
          _buildSeverityBadge(
              theme, 'High', highCount, theme.colorScheme.error),
        if (mediumCount > 0) ...[
          if (highCount > 0) const SizedBox(width: 8),
          _buildSeverityBadge(theme, 'Med', mediumCount, Colors.deepOrange),
        ],
        if (lowCount > 0) ...[
          if (highCount > 0 || mediumCount > 0) const SizedBox(width: 8),
          _buildSeverityBadge(theme, 'Low', lowCount, Colors.orange),
        ],
      ],
    );
  }

  /// Builds a severity badge
  Widget _buildSeverityBadge(
      ThemeData theme, String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$count $label',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Builds the filter bar
  Widget _buildFilterBar(BuildContext context, ThemeData theme) {
    if (!widget.showFilters) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Severity filter
          DropdownButton<SyncErrorSeverity?>(
            value: _selectedSeverity,
            hint: const Text('All Severities'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Severities'),
              ),
              ...SyncErrorSeverity.values.map(
                (severity) => DropdownMenuItem(
                  value: severity,
                  child: Text(severity.name.capitalize()),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _selectedSeverity = value),
            style: theme.textTheme.bodyMedium,
            isDense: true,
          ),

          // Type filter
          DropdownButton<SyncErrorType?>(
            value: _selectedType,
            hint: const Text('All Types'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Types'),
              ),
              ...SyncErrorType.values.map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeDisplayName(type)),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _selectedType = value),
            style: theme.textTheme.bodyMedium,
            isDense: true,
          ),

          // Sort option
          DropdownButton<ErrorSortOption>(
            value: _sortOption,
            items: ErrorSortOption.values
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(_getSortDisplayName(option)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _sortOption = value);
              }
            },
            style: theme.textTheme.bodyMedium,
            isDense: true,
          ),

          // Clear filters button
          if (_selectedSeverity != null || _selectedType != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedSeverity = null;
                  _selectedType = null;
                });
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  /// Filters and sorts errors based on current settings
  List<SyncError> _filterAndSortErrors() {
    var filtered = widget.errors.toList();

    // Apply filters
    if (_selectedSeverity != null) {
      filtered =
          filtered.where((e) => e.severity == _selectedSeverity).toList();
    }
    if (_selectedType != null) {
      filtered = filtered.where((e) => e.type == _selectedType).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case ErrorSortOption.newest:
        filtered.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
        break;
      case ErrorSortOption.oldest:
        filtered.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
        break;
      case ErrorSortOption.severity:
        filtered.sort((a, b) =>
            _severityOrder(b.severity).compareTo(_severityOrder(a.severity)));
        break;
      case ErrorSortOption.type:
        filtered.sort((a, b) => a.type.name.compareTo(b.type.name));
        break;
    }

    return filtered;
  }

  /// Gets numeric order for severity (higher = more severe)
  int _severityOrder(SyncErrorSeverity severity) {
    switch (severity) {
      case SyncErrorSeverity.high:
        return 3;
      case SyncErrorSeverity.medium:
        return 2;
      case SyncErrorSeverity.low:
        return 1;
    }
  }

  /// Checks if there are any retryable errors
  bool _hasRetryableErrors(List<SyncError> errors) {
    return errors.any((e) => e.isRetryable);
  }

  /// Gets the highest severity color
  Color _getHighestSeverityColor(ThemeData theme) {
    if (widget.errors.any((e) => e.severity == SyncErrorSeverity.high)) {
      return theme.colorScheme.error;
    } else if (widget.errors
        .any((e) => e.severity == SyncErrorSeverity.medium)) {
      return Colors.deepOrange;
    }
    return Colors.orange;
  }

  /// Gets display name for error type
  String _getTypeDisplayName(SyncErrorType type) {
    switch (type) {
      case SyncErrorType.network:
        return 'Network';
      case SyncErrorType.authentication:
        return 'Auth';
      case SyncErrorType.server:
        return 'Server';
      case SyncErrorType.validation:
        return 'Validation';
      case SyncErrorType.conflict:
        return 'Conflict';
      case SyncErrorType.timeout:
        return 'Timeout';
      case SyncErrorType.notFound:
        return 'Not Found';
      case SyncErrorType.rateLimited:
        return 'Rate Limit';
      case SyncErrorType.quotaExceeded:
        return 'Quota';
      case SyncErrorType.unknown:
        return 'Unknown';
    }
  }

  /// Gets display name for sort option
  String _getSortDisplayName(ErrorSortOption option) {
    switch (option) {
      case ErrorSortOption.newest:
        return 'Newest First';
      case ErrorSortOption.oldest:
        return 'Oldest First';
      case ErrorSortOption.severity:
        return 'By Severity';
      case ErrorSortOption.type:
        return 'By Type';
    }
  }
}

/// Sort options for error list
enum ErrorSortOption {
  newest,
  oldest,
  severity,
  type,
}

/// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
