import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/notifications/domain/entities/travel_notification.dart';
import 'package:soloadventurer/features/notifications/presentation/providers/notification_providers.dart';

/// Screen for displaying notification history
class NotificationHistoryScreen extends ConsumerWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearDialog(context, ref),
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(notificationsNotifierProvider.notifier).refresh(),
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildNotificationList(context, ref, notifications);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(notificationsNotifierProvider.notifier)
                      .refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifications will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    WidgetRef ref,
    List<TravelNotification> notifications,
  ) {
    // Group notifications by date
    final grouped = _groupNotificationsByDate(notifications);

    return ListView.builder(
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final date = grouped.keys.elementAt(index);
        final items = grouped[date]!;

        return _buildDateSection(context, ref, date, items);
      },
    );
  }

  Map<String, List<TravelNotification>> _groupNotificationsByDate(
    List<TravelNotification> notifications,
  ) {
    final Map<String, List<TravelNotification>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final notification in notifications) {
      final notificationDate = DateTime(
        notification.scheduledAt.year,
        notification.scheduledAt.month,
        notification.scheduledAt.day,
      );

      String dateKey;
      if (notificationDate == today) {
        dateKey = 'Today';
      } else if (notificationDate == yesterday) {
        dateKey = 'Yesterday';
      } else {
        dateKey = DateFormat('MMM d, yyyy').format(notification.scheduledAt);
      }

      grouped.putIfAbsent(dateKey, () => []).add(notification);
    }

    // Sort items within each date by time (newest first)
    for (final items in grouped.values) {
      items.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    }

    return grouped;
  }

  Widget _buildDateSection(
    BuildContext context,
    WidgetRef ref,
    String date,
    List<TravelNotification> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            date,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...items.map((notification) =>
            _buildNotificationTile(context, ref, notification)),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    WidgetRef ref,
    TravelNotification notification,
  ) {
    final isRead = notification.isRead;
    final isDismissed = notification.isDismissed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              _getCategoryColor(notification.category).withValues(alpha: 0.2),
          child: Text(
            notification.icon,
            style: TextStyle(
              fontSize: 20,
              color: _getCategoryColor(notification.category),
            ),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            decoration: isDismissed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.scheduledAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        trailing: _buildTrailing(context, ref, notification),
        onTap: () => _showNotificationDetails(context, notification),
      ),
    );
  }

  Widget? _buildTrailing(
    BuildContext context,
    WidgetRef ref,
    TravelNotification notification,
  ) {
    if (notification.isDismissed) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }

    if (!notification.isRead) {
      return IconButton(
        icon: const Icon(Icons.check_circle_outline),
        onPressed: () async {
          await ref
              .read(notificationsNotifierProvider.notifier)
              .markAsRead(notification.id);
        },
        tooltip: 'Mark as read',
      );
    }

    return IconButton(
      icon: const Icon(Icons.delete_outline),
      onPressed: () async {
        await ref
            .read(notificationsNotifierProvider.notifier)
            .dismiss(notification.id);
      },
      tooltip: 'Dismiss',
    );
  }

  void _showNotificationDetails(
    BuildContext context,
    TravelNotification notification,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          _NotificationDetailsDialog(notification: notification),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all notification history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(notificationsNotifierProvider.notifier)
                  .clearHistory();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  Color _getCategoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.flight:
        return Colors.blue;
      case NotificationCategory.accommodation:
        return Colors.purple;
      case NotificationCategory.activity:
        return Colors.orange;
      case NotificationCategory.weather:
        return Colors.cyan;
      case NotificationCategory.safety:
        return Colors.red;
      case NotificationCategory.recommendation:
        return Colors.green;
      case NotificationCategory.trip:
        return Colors.indigo;
    }
  }
}

class _NotificationDetailsDialog extends StatelessWidget {
  final TravelNotification notification;

  const _NotificationDetailsDialog({required this.notification});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(notification.icon),
          const SizedBox(width: 8),
          Expanded(child: Text(notification.title)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(notification.body),
            const SizedBox(height: 16),
            _buildDetailRow('Category', notification.category.name),
            _buildDetailRow('Priority', notification.priority.name),
            _buildDetailRow(
                'Scheduled',
                DateFormat('MMM d, yyyy HH:mm')
                    .format(notification.scheduledAt)),
            if (notification.deliveredAt != null)
              _buildDetailRow(
                  'Delivered',
                  DateFormat('MMM d, yyyy HH:mm')
                      .format(notification.deliveredAt!)),
            if (notification.readAt != null)
              _buildDetailRow('Read',
                  DateFormat('MMM d, yyyy HH:mm').format(notification.readAt!)),
            if (notification.data != null && notification.data!.isNotEmpty)
              _buildDataRow('Data', notification.data!),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...data.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 2),
              child: Text('${entry.key}: ${entry.value}'),
            );
          }),
        ],
      ),
    );
  }
}
