import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/check_in.dart';
import '../providers/safety_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'manual_check_in_screen.dart';
import 'schedule_check_in_screen.dart';
import 'check_in_history_screen.dart';

/// Main check-in screen showing active and upcoming check-ins
/// Provides quick actions to create manual check-ins, schedule check-ins, and view history
class CheckInHomeScreen extends ConsumerStatefulWidget {
  const CheckInHomeScreen({super.key});

  @override
  ConsumerState<CheckInHomeScreen> createState() => _CheckInHomeScreenState();
}

class _CheckInHomeScreenState extends ConsumerState<CheckInHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load upcoming check-ins when screen initializes
    Future.microtask(() {
      ref.read(checkInNotifierProvider.notifier).loadUpcomingCheckIns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkInState = ref.watch(checkInNotifierProvider);
    final upcomingCheckIns = checkInState.upcomingCheckIns;
    final nextCheckIn = checkInState.nextCheckIn;
    final isLoading = checkInState.isLoading;
    final isProcessing = checkInState.isProcessing;
    final error = checkInState.error;
    final dueSoonCount = checkInState.dueSoonCount;
    final missedCount = checkInState.missedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-ins'),
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _navigateToHistory(context),
            tooltip: 'Check-in History',
          ),
          // Info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'About Check-ins',
          ),
        ],
      ),
      body: _buildBody(
        context,
        upcomingCheckIns,
        nextCheckIn,
        isLoading,
        isProcessing,
        error,
        dueSoonCount,
        missedCount,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isProcessing ? null : () => _showCheckInOptions(context),
        icon: const Icon(Icons.add),
        label: const Text('New Check-in'),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<CheckIn> upcomingCheckIns,
    CheckIn? nextCheckIn,
    bool isLoading,
    bool isProcessing,
    String? error,
    int dueSoonCount,
    int missedCount,
  ) {
    if (isLoading && upcomingCheckIns.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return _buildErrorWidget(context, error);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status cards section
          _buildStatusCards(context, dueSoonCount, missedCount, nextCheckIn),

          const SizedBox(height: 24),

          // Next check-in section (if exists)
          if (nextCheckIn != null) ...[
            _buildNextCheckInSection(context, nextCheckIn),
            const SizedBox(height: 24),
          ],

          // Upcoming check-ins header
          Text(
            'Upcoming Check-ins',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          // Check-ins list
          if (upcomingCheckIns.isEmpty) {
            _buildEmptyCheckInsState(context);
          } else {
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingCheckIns.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final checkIn = upcomingCheckIns[index];
                return _buildCheckInCard(context, checkIn);
              },
            ),
          },
        ],
      ),
    );
  }

  Widget _buildStatusCards(
    BuildContext context,
    int dueSoonCount,
    int missedCount,
    CheckIn? nextCheckIn,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            icon: Icons.access_time,
            title: 'Due Soon',
            value: dueSoonCount.toString(),
            color: dueSoonCount > 0 ? Colors.orange : Colors.grey,
            onTap: () {
              // Scroll to first due soon check-in
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatusCard(
            icon: Icons.event_available,
            title: 'Missed',
            value: missedCount.toString(),
            color: missedCount > 0 ? Colors.red : Colors.grey,
            onTap: () => _navigateToHistory(context),
          ),
        ),
      ],
    );
  }

  Widget _buildNextCheckInSection(BuildContext context, CheckIn nextCheckIn) {
    final theme = Theme.of(context);
    final isDueSoon = _isDueSoon(nextCheckIn);
    final isOverdue = _isOverdue(nextCheckIn);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverdue
              ? [Colors.red.shade400, Colors.red.shade600]
              : isDueSoon
                  ? [Colors.orange.shade400, Colors.orange.shade600]
                  : [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOverdue ? Icons.warning : Icons.access_time,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                isOverdue ? 'Overdue Check-in' : 'Next Check-in',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatCheckInTime(nextCheckIn),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (nextCheckIn.statusMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              nextCheckIn.statusMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _completeCheckIn(context, nextCheckIn),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: isOverdue ? Colors.red : theme.colorScheme.primary,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Complete Check-in'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard(BuildContext context, CheckIn checkIn) {
    final theme = Theme.of(context);
    final isDueSoon = _isDueSoon(checkIn);
    final isOverdue = _isOverdue(checkIn);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverdue
            ? BorderSide(color: Colors.red.shade300, width: 2)
            : isDueSoon
                ? BorderSide(color: Colors.orange.shade300, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewCheckInDetails(context, checkIn),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCheckInIcon(checkIn.triggerType),
                    color: _getStatusColor(checkIn),
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
                          _formatCheckInTime(checkIn),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, checkIn),
                ],
              ),
              if (checkIn.statusMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  checkIn.statusMessage!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _viewCheckInDetails(context, checkIn),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View'),
                  ),
                  if (checkIn.status == CheckInStatus.scheduled ||
                      checkIn.status == CheckInStatus.active) ...[
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => _completeCheckIn(context, checkIn),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Complete'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, CheckIn checkIn) {
    String label;
    Color color;

    switch (checkIn.status) {
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
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }

  Widget _buildEmptyCheckInsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Upcoming Check-ins',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a manual check-in or schedule one for the future',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCheckInOptions(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Check-in'),
          ),
        ],
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
              'Error Loading Check-ins',
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
                ref
                    .read(checkInNotifierProvider.notifier)
                    .loadUpcomingCheckIns();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckInOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Manual Check-in'),
              subtitle: const Text('Check in now with your current location'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToManualCheckIn(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Schedule Check-in'),
              subtitle: const Text('Schedule a check-in for the future'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToScheduleCheckIn(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _completeCheckIn(BuildContext context, CheckIn checkIn) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManualCheckInScreen(
          existingCheckIn: checkIn,
        ),
      ),
    );
  }

  void _viewCheckInDetails(BuildContext context, CheckIn checkIn) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _CheckInDetailsSheet(checkIn: checkIn),
    );
  }

  void _navigateToManualCheckIn(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ManualCheckInScreen(),
      ),
    );
  }

  void _navigateToScheduleCheckIn(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ScheduleCheckInScreen(),
      ),
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CheckInHistoryScreen(),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Check-ins'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Check-ins help you stay safe by letting your trusted contacts know you\'re okay.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Types of Check-ins:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '• Manual: Check in now with your current location',
                style: TextStyle(fontSize: 13),
              ),
              Text(
                '• Scheduled: Set a specific time to check in',
                style: TextStyle(fontSize: 13),
              ),
              Text(
                '• Location-based: Check in when arriving at or leaving a location',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                'If you miss a scheduled check-in, your trusted contacts will be notified with your last known location.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  bool _isDueSoon(CheckIn checkIn) {
    final deadline = checkIn.deadline ?? checkIn.scheduledTime;
    if (deadline == null) return false;
    return deadline.isBefore(DateTime.now().add(const Duration(hours: 1)));
  }

  bool _isOverdue(CheckIn checkIn) {
    final deadline = checkIn.deadline ?? checkIn.scheduledTime;
    if (deadline == null) return false;
    return deadline.isBefore(DateTime.now());
  }

  String _formatCheckInTime(CheckIn checkIn) {
    final scheduledTime = checkIn.scheduledTime;
    final deadline = checkIn.deadline;

    if (scheduledTime == null) return 'No time set';

    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    if (difference.inMinutes < 1) {
      return 'Due now';
    } else if (difference.inMinutes < 60) {
      return 'Due in ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'Due in ${difference.inHours} hours';
    } else {
      return 'Due on ${scheduledTime.toString().split(' ')[0]} at ${scheduledTime.toString().split(' ')[1].substring(0, 5)}';
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

  Color _getStatusColor(CheckIn checkIn) {
    if (_isOverdue(checkIn)) return Colors.red;
    if (_isDueSoon(checkIn)) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }
}

/// Widget for status cards
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet widget for displaying check-in details
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
          Row(
            children: [
              Icon(
                _getDetailsIcon(checkIn.triggerType),
                color: _getDetailsColor(checkIn),
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
          _DetailRow(
            icon: Icons.access_time,
            label: 'Status',
            value: _getStatusLabel(checkIn.status),
          ),
          if (checkIn.scheduledTime != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.schedule,
              label: 'Scheduled Time',
              value: _formatDateTime(checkIn.scheduledTime!),
            ),
          ],
          if (checkIn.deadline != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.timer,
              label: 'Deadline',
              value: _formatDateTime(checkIn.deadline!),
            ),
          ],
          if (checkIn.completedAt != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.check_circle,
              label: 'Completed At',
              value: _formatDateTime(checkIn.completedAt!),
            ),
          ],
          if (checkIn.location != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.location_on,
              label: 'Location',
              value: checkIn.location!.placeName ??
                  checkIn.location!.address ??
                  '${checkIn.location!.latitude.toStringAsFixed(4)}, ${checkIn.location!.longitude.toStringAsFixed(4)}',
            ),
          ],
          if (checkIn.statusMessage != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.message,
              label: 'Message',
              value: checkIn.statusMessage!,
            ),
          ],
          if (checkIn.tripId != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.trip_origin,
              label: 'Trip ID',
              value: checkIn.tripId!,
            ),
          ],
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.people,
            label: 'Notify Contacts',
            value: checkIn.notifyContactIds.isEmpty
                ? 'None'
                : '${checkIn.notifyContactIds.length} contact(s)',
          ),
          const SizedBox(height: 8),
          Text(
            'Created on ${_formatDateTime(checkIn.createdAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
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

  Color _getDetailsColor(CheckIn checkIn) {
    switch (checkIn.status) {
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
    if (checkIn.status == CheckInStatus.completed) {
      return 'Completed at ${_formatDateTime(checkIn.completedAt ?? checkIn.updatedAt ?? DateTime.now())}';
    } else if (checkIn.status == CheckInStatus.missed) {
      return 'Missed deadline at ${_formatDateTime(checkIn.deadline ?? DateTime.now())}';
    } else if (checkIn.status == CheckInStatus.cancelled) {
      return 'Cancelled at ${_formatDateTime(checkIn.updatedAt ?? DateTime.now())}';
    } else {
      return 'Scheduled for ${_formatDateTime(checkIn.scheduledTime ?? checkIn.deadline ?? DateTime.now())}';
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

  String _formatDateTime(DateTime dateTime) {
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
