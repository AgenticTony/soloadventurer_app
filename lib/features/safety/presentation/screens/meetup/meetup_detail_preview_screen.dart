import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Screen showing meetup details as seen by a trusted contact.
///
/// Displays the shared meetup information: who, where, when,
/// and the sharer's notes. Shows a "plans changed" badge if updated.
class MeetupDetailPreviewScreen extends StatelessWidget {
  /// Route name for navigation
  static const routeName = '/safety/meetup/detail';

  /// Creates a new [MeetupDetailPreviewScreen]
  const MeetupDetailPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>? ??
        <String, dynamic>{};

    final meetingWith = extra['meetingWith'] as String? ?? 'Unknown';
    final locationName = extra['locationName'] as String? ?? 'Unknown location';
    final locationAddress = extra['locationAddress'] as String?;
    final meetupTimeStr = extra['meetupTime'] as String?;
    final notes = extra['notes'] as String?;
    final sharedByName = extra['sharedByName'] as String? ?? 'Someone';
    final plansChanged = extra['plansChanged'] as bool? ?? false;

    final meetupTime = meetupTimeStr != null
        ? DateTime.tryParse(meetupTimeStr) ?? DateTime.now()
        : DateTime.now();

    final isPast = DateTime.now().isAfter(meetupTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetup Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Shared by header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    child: Text(sharedByName[0].toUpperCase()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$sharedByName shared a meetup with you',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (plansChanged)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'PLANS CHANGED',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Meeting details card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meeting Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Who
                    _detailRow(
                      theme,
                      icon: Icons.person,
                      label: 'Meeting With',
                      value: meetingWith,
                    ),
                    const SizedBox(height: 16),

                    // Where
                    _detailRow(
                      theme,
                      icon: Icons.location_on,
                      label: 'Location',
                      value: locationAddress != null
                          ? '$locationName\n$locationAddress'
                          : locationName,
                    ),
                    const SizedBox(height: 16),

                    // When
                    _detailRow(
                      theme,
                      icon: Icons.schedule,
                      label: 'Time',
                      value: _formatDateTime(meetupTime),
                      trailing: isPast
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'PAST',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : null,
                    ),

                    // Notes
                    if (notes != null && notes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _detailRow(
                        theme,
                        icon: Icons.notes,
                        label: 'Notes',
                        value: notes,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Safety reminder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 20, color: Colors.orange.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'If you don\'t hear from $sharedByName after the meetup time, '
                      'consider reaching out to check in.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade900,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year} at $hour:$minute';
  }
}
