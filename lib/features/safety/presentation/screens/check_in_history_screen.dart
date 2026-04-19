import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/check_in.dart';
import '../providers/safety_providers.dart';

/// Screen for displaying check-in history
/// Shows all check-ins with filtering and sorting options
class CheckInHistoryScreen extends ConsumerStatefulWidget {
  const CheckInHistoryScreen({super.key});

  @override
  ConsumerState<CheckInHistoryScreen> createState() =>
      _CheckInHistoryScreenState();
}

class _CheckInHistoryScreenState extends ConsumerState<CheckInHistoryScreen> {
  CheckInStatus? _selectedStatusFilter;
  _SortOption _sortOption = _SortOption.newestFirst;

  @override
  void initState() {
    super.initState();
    // Load all check-ins when screen initializes
    Future.microtask(() {
      ref.read(checkInProvider.notifier).loadCheckIns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkInAsync = ref.watch(checkInProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in History'),
        actions: [
          // Filter button
          PopupMenuButton<CheckInStatus?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by status',
            onSelected: (status) {
              setState(() {
                _selectedStatusFilter = status;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.list),
                    SizedBox(width: 8),
                    Text('All Check-ins'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: CheckInStatus.completed,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Completed'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: CheckInStatus.missed,
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Missed'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: CheckInStatus.cancelled,
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Cancelled'),
                  ],
                ),
              ),
            ],
          ),
          // Sort button
          PopupMenuButton<_SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (option) {
              setState(() {
                _sortOption = option;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _SortOption.newestFirst,
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward),
                    SizedBox(width: 8),
                    Text('Newest First'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: _SortOption.oldestFirst,
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward),
                    SizedBox(width: 8),
                    Text('Oldest First'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: checkInAsync.when(
        data: (checkInState) {
          final allCheckIns = checkInState.checkIns;
          final filteredCheckIns = _applyFiltersAndSort(allCheckIns);
          return _buildBody(context, filteredCheckIns);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorWidget(context, error.toString()),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<CheckIn> checkIns,
  ) {
    if (checkIns.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(checkInProvider.notifier).loadCheckIns();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: checkIns.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final checkIn = checkIns[index];
          return _buildCheckInCard(context, checkIn);
        },
      ),
    );
  }

  Widget _buildCheckInCard(BuildContext context, CheckIn checkIn) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusBorderColor(checkIn.status),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewCheckInDetails(context, checkIn),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon, title, and status
              Row(
                children: [
                  Icon(
                    _getCheckInIcon(checkIn.triggerType),
                    color: _getStatusColor(checkIn.status),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCheckInTitle(checkIn),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(checkIn.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, checkIn.status),
                ],
              ),

              // Status message if present
              if (checkIn.statusMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  checkIn.statusMessage!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],

              // Location if present
              if (checkIn.location != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        checkIn.location!.placeName ??
                            checkIn.location!.address ??
                            '${checkIn.location!.latitude.toStringAsFixed(4)}, ${checkIn.location!.longitude.toStringAsFixed(4)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Additional details row
              const SizedBox(height: 12),
              Row(
                children: [
                  if (checkIn.completedAt != null) ...[
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completed: ${_formatDateTime(checkIn.completedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ] else if (checkIn.status == CheckInStatus.missed &&
                      checkIn.deadline != null) ...[
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Colors.red[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Missed: ${_formatDateTime(checkIn.deadline!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red[600],
                      ),
                    ),
                  ] else if (checkIn.status == CheckInStatus.cancelled) ...[
                    Icon(
                      Icons.cancel_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Cancelled',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),

              // View details button
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _viewCheckInDetails(context, checkIn),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, CheckInStatus status) {
    String label;
    Color color;

    switch (status) {
      case CheckInStatus.scheduled:
        label = 'Scheduled';
        color = Colors.blue;
        break;
      case CheckInStatus.active:
        label = 'Active';
        color = Colors.green;
        break;
      case CheckInStatus.completed:
        label = 'Completed';
        color = Colors.grey;
        break;
      case CheckInStatus.missed:
        label = 'Missed';
        color = Colors.red;
        break;
      case CheckInStatus.cancelled:
        label = 'Cancelled';
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    // Show different messages based on filter
    String title;
    String message;
    IconData icon;

    if (_selectedStatusFilter != null) {
      switch (_selectedStatusFilter!) {
        case CheckInStatus.completed:
          title = 'No Completed Check-ins';
          message = 'You haven\'t completed any check-ins yet';
          icon = Icons.check_circle_outline;
          break;
        case CheckInStatus.missed:
          title = 'No Missed Check-ins';
          message = 'Great! You haven\'t missed any check-ins';
          icon = Icons.verified_outlined;
          break;
        case CheckInStatus.cancelled:
          title = 'No Cancelled Check-ins';
          message = 'You haven\'t cancelled any check-ins';
          icon = Icons.event_available;
          break;
        default:
          title = 'No Check-ins Found';
          message = 'Start by creating a check-in';
          icon = Icons.event_available;
      }
    } else {
      title = 'No Check-in History';
      message = 'Your check-in history will appear here';
      icon = Icons.history;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            if (_selectedStatusFilter != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedStatusFilter = null;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filter'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(checkInProvider.notifier).loadCheckIns();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _viewCheckInDetails(BuildContext context, CheckIn checkIn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CheckInDetailsSheet(checkIn: checkIn),
    );
  }

  List<CheckIn> _applyFiltersAndSort(List<CheckIn> checkIns) {
    var filtered = checkIns;

    // Apply status filter
    if (_selectedStatusFilter != null) {
      filtered = filtered
          .where((checkIn) => checkIn.status == _selectedStatusFilter)
          .toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case _SortOption.newestFirst:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _SortOption.oldestFirst:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    return filtered;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time only
      return 'Today at ${dateTime.toString().split(' ')[1].substring(0, 5)}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday at ${dateTime.toString().split(' ')[1].substring(0, 5)}';
    } else if (difference.inDays < 7) {
      // This week - show day of week
      final weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      return '${weekdays[dateTime.weekday - 1]} at ${dateTime.toString().split(' ')[1].substring(0, 5)}';
    } else {
      // Older - show date
      return '${dateTime.toString().split(' ')[0]} at ${dateTime.toString().split(' ')[1].substring(0, 5)}';
    }
  }

  String _getCheckInTitle(CheckIn checkIn) {
    switch (checkIn.triggerType) {
      case CheckInTriggerType.manual:
        return 'Manual Check-in';
      case CheckInTriggerType.scheduledTime:
        return 'Scheduled Check-in';
      case CheckInTriggerType.locationArrival:
        return 'Arrival Check-in';
      case CheckInTriggerType.locationDeparture:
        return 'Departure Check-in';
    }
  }

  IconData _getCheckInIcon(CheckInTriggerType triggerType) {
    switch (triggerType) {
      case CheckInTriggerType.manual:
        return Icons.check_circle;
      case CheckInTriggerType.scheduledTime:
        return Icons.schedule;
      case CheckInTriggerType.locationArrival:
        return Icons.login;
      case CheckInTriggerType.locationDeparture:
        return Icons.logout;
    }
  }

  Color _getStatusColor(CheckInStatus status) {
    switch (status) {
      case CheckInStatus.scheduled:
        return Colors.blue;
      case CheckInStatus.active:
        return Colors.green;
      case CheckInStatus.completed:
        return Colors.grey;
      case CheckInStatus.missed:
        return Colors.red;
      case CheckInStatus.cancelled:
        return Colors.grey;
    }
  }

  Color _getStatusBorderColor(CheckInStatus status) {
    switch (status) {
      case CheckInStatus.scheduled:
        return Colors.blue.shade300;
      case CheckInStatus.active:
        return Colors.green.shade300;
      case CheckInStatus.completed:
        return Colors.grey.shade300;
      case CheckInStatus.missed:
        return Colors.red.shade300;
      case CheckInStatus.cancelled:
        return Colors.grey.shade300;
    }
  }
}

/// Enum for sort options
enum _SortOption {
  newestFirst,
  oldestFirst,
}

/// Bottom sheet widget for displaying detailed check-in information
class _CheckInDetailsSheet extends StatelessWidget {
  final CheckIn checkIn;

  const _CheckInDetailsSheet({required this.checkIn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar for visual indication
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Icon(
                _getDetailsIcon(checkIn.triggerType),
                color: _getDetailsColor(checkIn.status),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDetailsTitle(checkIn),
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      _getDetailsSubtitle(checkIn),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          // Status
          _DetailRow(
            icon: Icons.info_outline,
            label: 'Status',
            value: _getStatusLabel(checkIn.status),
          ),

          // Created at
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.add_circle_outline,
            label: 'Created',
            value: _formatFullDateTime(checkIn.createdAt),
          ),

          // Scheduled time
          if (checkIn.scheduledTime != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.schedule,
              label: 'Scheduled Time',
              value: _formatFullDateTime(checkIn.scheduledTime!),
            ),
          ],

          // Deadline
          if (checkIn.deadline != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.timer_outlined,
              label: 'Deadline',
              value: _formatFullDateTime(checkIn.deadline!),
            ),
          ],

          // Completed at
          if (checkIn.completedAt != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.check_circle_outline,
              label: 'Completed At',
              value: _formatFullDateTime(checkIn.completedAt!),
            ),
          ],

          // Location
          if (checkIn.location != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.location_on,
              label: 'Location',
              value: checkIn.location!.placeName ??
                  checkIn.location!.address ??
                  '${checkIn.location!.latitude.toStringAsFixed(6)}, ${checkIn.location!.longitude.toStringAsFixed(6)}',
            ),
            if (checkIn.location!.accuracy != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.gps_fixed,
                label: 'Accuracy',
                value: '~${checkIn.location!.accuracy!.toStringAsFixed(0)}m',
              ),
            ],
          ],

          // Status message
          if (checkIn.statusMessage != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.message,
              label: 'Message',
              value: checkIn.statusMessage!,
            ),
          ],

          // Trip ID
          if (checkIn.tripId != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.trip_origin,
              label: 'Trip ID',
              value: checkIn.tripId!,
            ),
          ],

          // Notify contacts
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.people,
            label: 'Notify Contacts',
            value: checkIn.notifyContactIds.isEmpty
                ? 'None'
                : '${checkIn.notifyContactIds.length} contact(s)',
          ),

          // Alert sent
          if (checkIn.alertSent) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.notifications_active,
              label: 'Alert Sent',
              value: checkIn.alertSentAt != null
                  ? _formatFullDateTime(checkIn.alertSentAt!)
                  : 'Yes',
            ),
          ],

          // Updated at
          if (checkIn.updatedAt != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.update,
              label: 'Last Updated',
              value: _formatFullDateTime(checkIn.updatedAt!),
            ),
          ],

          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDetailsIcon(CheckInTriggerType triggerType) {
    switch (triggerType) {
      case CheckInTriggerType.manual:
        return Icons.check_circle;
      case CheckInTriggerType.scheduledTime:
        return Icons.schedule;
      case CheckInTriggerType.locationArrival:
        return Icons.login;
      case CheckInTriggerType.locationDeparture:
        return Icons.logout;
    }
  }

  Color _getDetailsColor(CheckInStatus status) {
    switch (status) {
      case CheckInStatus.scheduled:
        return Colors.blue;
      case CheckInStatus.active:
        return Colors.green;
      case CheckInStatus.completed:
        return Colors.grey;
      case CheckInStatus.missed:
        return Colors.red;
      case CheckInStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getDetailsTitle(CheckIn checkIn) {
    switch (checkIn.triggerType) {
      case CheckInTriggerType.manual:
        return 'Manual Check-in';
      case CheckInTriggerType.scheduledTime:
        return 'Scheduled Check-in';
      case CheckInTriggerType.locationArrival:
        return 'Arrival Check-in';
      case CheckInTriggerType.locationDeparture:
        return 'Departure Check-in';
    }
  }

  String _getDetailsSubtitle(CheckIn checkIn) {
    switch (checkIn.status) {
      case CheckInStatus.completed:
        return 'Completed successfully';
      case CheckInStatus.missed:
        return 'Missed deadline';
      case CheckInStatus.cancelled:
        return 'Cancelled by user';
      case CheckInStatus.scheduled:
        return 'Scheduled for future';
      case CheckInStatus.active:
        return 'Currently active';
    }
  }

  String _getStatusLabel(CheckInStatus status) {
    switch (status) {
      case CheckInStatus.scheduled:
        return 'Scheduled';
      case CheckInStatus.active:
        return 'Active';
      case CheckInStatus.completed:
        return 'Completed';
      case CheckInStatus.missed:
        return 'Missed';
      case CheckInStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatFullDateTime(DateTime dateTime) {
    return '${dateTime.toString().split(' ')[0]} at ${dateTime.toString().split(' ')[1].substring(0, 5)}';
  }
}

/// Helper widget for displaying detail rows
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
