import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/safety_providers.dart';
import '../../domain/entities/safety_status.dart';
import 'trusted_contacts_screen.dart';
import 'check_in_home_screen.dart';
import 'emergency_sos_screen.dart';
import 'location_sharing_screen.dart';
import 'status_update_screen.dart';
import 'manual_check_in_screen.dart';

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
      ref.read(trustedContactsNotifierProvider.notifier).loadContacts();
      ref.read(checkInNotifierProvider.notifier).loadUpcomingCheckIns();
      ref.read(locationSharingNotifierProvider.notifier).loadActiveShares();
      ref.read(safetyNotifierProvider.notifier).getSafetyStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trustedContactsState = ref.watch(trustedContactsNotifierProvider);
    final checkInState = ref.watch(checkInNotifierProvider);
    final locationSharingState = ref.watch(locationSharingNotifierProvider);
    final safetyState = ref.watch(safetyNotifierProvider);

    final contactsCount = trustedContactsState.contacts.length;
    final upcomingCheckInsCount = checkInState.upcomingCheckIns.length;
    final activeLocationSharesCount = locationSharingState.activeShares.length;
    final currentStatus = safetyState.currentStatus;
    final hasActiveEmergency = safetyState.hasActiveEmergency;

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
                        _getStatusIcon(currentStatus.statusType),
                        size: 16,
                      ),
                      label: Text(
                        _getStatusLabel(currentStatus.statusType),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: _getStatusColor(
                                  context, currentStatus.statusType)
                              .withOpacity(0.2) ??
                          Colors.grey.withOpacity(0.2),
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
            color: upcomingCheckInsCount > 0
                ? Colors.orange
                : Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.location_on,
            label: 'Sharing',
            value: activeLocationSharesCount.toString(),
            color: activeLocationSharesCount > 0
                ? Colors.green
                : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStatusCard(
    BuildContext context,
    SafetyStatus currentStatus,
  ) {
    final statusColor = _getStatusColor(context, currentStatus.statusType);
    final statusIcon = _getStatusIcon(currentStatus.statusType);
    final statusLabel = _getStatusLabel(currentStatus.statusType);

    return Card(
      elevation: 2,
      color: statusColor?.withOpacity(0.1),
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
              'Updated ${_formatTimeAgo(currentStatus.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
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
          onTap: () => _navigateToEmergencySOS(context),
        ),
      ],
    );
  }

  // Navigation methods

  void _navigateToTrustedContacts(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TrustedContactsScreen(),
      ),
    );
  }

  void _navigateToCheckIns(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CheckInHomeScreen(),
      ),
    );
  }

  void _navigateToLocationSharing(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LocationSharingScreen(),
      ),
    );
  }

  void _navigateToEmergencySOS(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EmergencySOSScreen(),
      ),
    );
  }

  void _navigateToUpdateStatus(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StatusUpdateScreen(),
      ),
    );
  }

  void _navigateToManualCheckIn(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ManualCheckInScreen(),
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
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
        side: isEmergency
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
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
                  color: color.withOpacity(0.1),
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
