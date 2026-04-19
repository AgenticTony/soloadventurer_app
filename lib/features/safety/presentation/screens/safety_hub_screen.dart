import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloadventurer/features/safety/presentation/routes/safety_routes.dart';
import '../providers/safety_providers.dart';
import '../../domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/meetup_checkin.dart';
import 'package:soloadventurer/features/safety/presentation/providers/meetup_checkin_providers.dart';
import 'package:soloadventurer/features/safety/presentation/widgets/create_checkin_sheet.dart';
import 'package:soloadventurer/features/safety/presentation/widgets/liability_disclaimer_modal.dart';

/// Main safety hub screen serving as the entry point for all safety features
///
/// Displays overview of safety status, quick stats, and navigation to all safety features:
/// - Trusted Contacts management
/// - Check-ins (manual and scheduled)
/// - Emergency SOS
/// - Location Sharing
/// - Status Updates
class SafetyHubScreen extends ConsumerStatefulWidget {
  const SafetyHubScreen({super.key});

  @override
  ConsumerState<SafetyHubScreen> createState() => _SafetyHubScreenState();
}

class _SafetyHubScreenState extends ConsumerState<SafetyHubScreen> {
  @override
  void initState() {
    super.initState();
    // Load all safety data when screen initializes
    Future.microtask(() {
      ref.read(trustedContactsProvider.notifier).loadContacts();
      ref.read(checkInProvider.notifier).loadUpcomingCheckIns();
      ref.read(locationSharingProvider.notifier).loadActiveShares();
      ref.read(safetyProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trustedContactsState = ref.watch(trustedContactsProvider).value;
    final checkInState = ref.watch(checkInProvider).value;
    final locationSharingState = ref.watch(locationSharingProvider).value;
    final safetyState = ref.watch(safetyProvider).value;

    final contactsCount = trustedContactsState?.contacts.length ?? 0;
    final upcomingCheckInsCount = checkInState?.upcomingCheckIns.length ?? 0;
    final activeLocationSharesCount = locationSharingState?.activeShares.length ?? 0;
    final currentStatus = safetyState?.currentStatus;
    final hasActiveEmergency = safetyState?.hasActiveEmergency ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with safety status indicator
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Safety Hub'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: hasActiveEmergency
                        ? [Colors.red.shade400, Colors.red.shade600]
                        : [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                  ),
                ),
              ),
            ),
            actions: [
              // Status indicator
              if (currentStatus != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Chip(
                      avatar: Icon(
                        _getStatusIcon(currentStatus.status),
                        size: 16,
                      ),
                      label: Text(
                        _getStatusLabel(currentStatus.status),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor:
                          _getStatusColor(context, currentStatus.status)
                                  ?.withValues(alpha: 0.2) ??
                              Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                ),
            ],
          ),

          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats section
                  _buildQuickStats(
                    context,
                    contactsCount,
                    upcomingCheckInsCount,
                    activeLocationSharesCount,
                    hasActiveEmergency,
                  ),

                  const SizedBox(height: 24),

                  // Current safety status card
                  if (currentStatus != null)
                    _buildCurrentStatusCard(context, currentStatus),

                  if (currentStatus != null) const SizedBox(height: 16),

                  // Meetup Check-ins section
                  _buildMeetupCheckins(context, hasActiveEmergency),
                    const SizedBox(height: 24),

                  // Quick actions section
                  _buildQuickActions(context),

                  const SizedBox(height: 24),

                  // Safety features section
                  Text(
                    'Safety Features',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Feature cards
                  _buildFeatureCards(context, hasActiveEmergency),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    int contactsCount,
    int upcomingCheckInsCount,
    int activeLocationSharesCount,
    bool hasActiveEmergency,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.people,
            label: 'Contacts',
            value: contactsCount.toString(),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.event_available,
            label: 'Check-ins',
            value: upcomingCheckInsCount.toString(),
            color: upcomingCheckInsCount > 0 ? Colors.orange : Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.location_on,
            label: 'Sharing',
            value: activeLocationSharesCount.toString(),
            color: activeLocationSharesCount > 0 ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStatusCard(
    BuildContext context,
    SafetyStatus currentStatus,
  ) {
    final statusColor = _getStatusColor(context, currentStatus.status);
    final statusIcon = _getStatusIcon(currentStatus.status);
    final statusLabel = _getStatusLabel(currentStatus.status);

    return Card(
      elevation: 2,
      color: statusColor?.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              statusLabel,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (currentStatus.message != null) ...[
              const SizedBox(height: 8),
              Text(
                currentStatus.message!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (currentStatus.location != null) ...[
              const SizedBox(height: 8),
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
                      currentStatus.location!.placeName ??
                          currentStatus.location!.address ??
                          '${currentStatus.location!.latitude.toStringAsFixed(4)}, ${currentStatus.location!.longitude.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Updated ${_formatTimeAgo(currentStatus.timestamp)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Meetup Check-ins
  // ============================================================

  Widget _buildMeetupCheckins(BuildContext context, bool hasActiveEmergency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.event_available,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Meetup Check-ins',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, child) {
            final activeCheckins = ref.watch(activeCheckinsProvider);            return activeCheckins.when(
              data: (checkins) {
                if (checkins.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No active check-ins',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }
                return Column(
                  children: checkins
                      .map((c) => _meetupCheckinTile(checkin: c))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showCreateCheckinSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Check-in'),
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _meetupCheckinTile({required MeetupCheckin checkin}) {
    final statusColor = _checkinStatusColor(checkin.status);
    final statusIcon = _checkinStatusIcon(checkin.status);
    final statusLabel = _checkinStatusLabel(checkin.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                checkin.locationName ?? 'No location',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                _formatMeetupTime(checkin.meetupTime),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(
              fontSize: 11,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
    const SizedBox(height: 8),
    Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (checkin.status == MeetupCheckinStatus.active ||
            checkin.status == MeetupCheckinStatus.alerted)
          TextButton(
            onPressed: () => ref
                .read(activeCheckinsProvider.notifier)
                .checkInSafe(checkin.id),
            child: Text(
              "I'm Safe",
              style: TextStyle(color: Colors.green),
            ),
          ),
        TextButton(
          onPressed: () => ref
            .read(activeCheckinsProvider.notifier)
            .triggerSOS(checkin.id),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('SOS'),
        ),
        if (checkin.status == MeetupCheckinStatus.scheduled ||
            checkin.status == MeetupCheckinStatus.active)
          TextButton(
            onPressed: () => ref
              .read(activeCheckinsProvider.notifier)
              .cancelCheckin(checkin.id),
            child: const Text('Cancel'),
          ),
      ],
    ),
  ],
),
),
);
  }

  void _showCreateCheckinSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const CreateCheckinSheet();
      },
    );
  }

  String _formatMeetupTime(DateTime time) {
    final now = DateTime.now();
    final diff = time.difference(now);
    if (diff.inMinutes < 60) {
      return 'in ${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return 'in ${diff.inHours}h';
    } else {
      return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2)}';
    }
  }

  Color _checkinStatusColor(MeetupCheckinStatus status) {
    switch (status) {
      case MeetupCheckinStatus.scheduled:
        return Colors.blue;
      case MeetupCheckinStatus.active:
        return Colors.orange;
      case MeetupCheckinStatus.checkedIn:
        return Colors.green;
      case MeetupCheckinStatus.alerted:
        return Colors.amber;
      case MeetupCheckinStatus.sos:
        return Colors.red;
      case MeetupCheckinStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _checkinStatusIcon(MeetupCheckinStatus status) {
    switch (status) {
      case MeetupCheckinStatus.scheduled:
        return Icons.schedule;
      case MeetupCheckinStatus.active:
        return Icons.timer;
      case MeetupCheckinStatus.checkedIn:
        return Icons.check_circle;
      case MeetupCheckinStatus.alerted:
        return Icons.warning;
      case MeetupCheckinStatus.sos:
        return Icons.emergency;
      case MeetupCheckinStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _checkinStatusLabel(MeetupCheckinStatus status) {
    switch (status) {
      case MeetupCheckinStatus.scheduled:
        return 'Scheduled';
      case MeetupCheckinStatus.active:
        return 'Active';
      case MeetupCheckinStatus.checkedIn:
        return 'Checked In';
      case MeetupCheckinStatus.alerted:
        return 'Alerted';
      case MeetupCheckinStatus.sos:
        return 'SOS';
      case MeetupCheckinStatus.cancelled:
        return 'Cancelled';
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.check_circle,
                label: 'Check In',
                color: Colors.green,
                onTap: () => _navigateToManualCheckIn(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.edit_note,
                label: 'Update Status',
                color: Colors.blue,
                onTap: () => _navigateToUpdateStatus(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.emergency,
                label: 'Emergency',
                color: Colors.red,
                onTap: () => _navigateToEmergencySOS(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCards(BuildContext context, bool hasActiveEmergency) {
    return Column(
      children: [
        _FeatureCard(
          icon: Icons.people,
          title: 'Trusted Contacts',
          description: 'Manage your trusted contacts',
          color: Theme.of(context).colorScheme.primary,
          onTap: () => _navigateToTrustedContacts(context),
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.event_available,
          title: 'Check-ins',
          description: 'Manual and scheduled check-ins',
          color: Colors.orange,
          onTap: () => _navigateToCheckIns(context),
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.location_on,
          title: 'Location Sharing',
          description: 'Share your location with contacts',
          color: Colors.green,
          onTap: () => _navigateToLocationSharing(context),
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.emergency,
          title: 'Emergency SOS',
          description: 'Quick emergency alert',
          color: Colors.red,
          isEmergency: true,
          onTap: () => _navigateToEmergencySOSWithDisclaimer(context),
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.share_location,
          title: 'Share My Meetup',
          description: 'Share meetup details with contacts',
          color: Colors.teal,
          onTap: () => _navigateToShareMeetup(context),
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.shield_outlined,
          title: 'Message Safety',
          description: 'AI-powered message screening',
          color: Colors.indigo,
          onTap: () => _navigateToMessageSafety(context),
        ),
      ],
    );
  }

  // Navigation methods

  void _navigateToTrustedContacts(BuildContext context) {
    context.push(SafetyRoutes.trustedContacts);
  }

  void _navigateToCheckIns(BuildContext context) {
    context.push(SafetyRoutes.checkInHome);
  }

  void _navigateToLocationSharing(BuildContext context) {
    context.push(SafetyRoutes.locationSharing);
  }

  void _navigateToEmergencySOS(BuildContext context) {
    context.push(SafetyRoutes.emergencySOS);
  }

  void _navigateToUpdateStatus(BuildContext context) {
    context.push(SafetyRoutes.statusUpdate);
  }

  void _navigateToManualCheckIn(BuildContext context) {
    context.push(SafetyRoutes.manualCheckIn);
  }

  void _navigateToEmergencySOSWithDisclaimer(BuildContext context) async {
    final acknowledged = await LiabilityDisclaimerModal.showIfNeeded(
      context,
      feature: LiabilityFeature.sos,
      onAcknowledged: () {},
    );
    if (acknowledged && context.mounted) {
      context.push(SafetyRoutes.emergencySOS);
    }
  }

  void _navigateToShareMeetup(BuildContext context) {
    context.push('/safety/meetup/share');
  }

  void _navigateToMessageSafety(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI message screening runs automatically in your chats.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Helper methods

  Color? _getStatusColor(BuildContext context, SafetyStatusType statusType) {
    switch (statusType) {
      case SafetyStatusType.safe:
        return Colors.green;
      case SafetyStatusType.needHelp:
        return Colors.orange;
      case SafetyStatusType.emergency:
        return Colors.red;
      case SafetyStatusType.unknown:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(SafetyStatusType statusType) {
    switch (statusType) {
      case SafetyStatusType.safe:
        return Icons.check_circle;
      case SafetyStatusType.needHelp:
        return Icons.help;
      case SafetyStatusType.emergency:
        return Icons.warning;
      case SafetyStatusType.unknown:
        return Icons.help_outline;
    }
  }

  String _getStatusLabel(SafetyStatusType statusType) {
    switch (statusType) {
      case SafetyStatusType.safe:
        return 'Safe';
      case SafetyStatusType.needHelp:
        return 'Need Help';
      case SafetyStatusType.emergency:
        return 'Emergency';
      case SafetyStatusType.unknown:
        return 'Unknown';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Widget for stat cards
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for quick action buttons
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for feature cards
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isEmergency;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isEmergency ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isEmergency ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
