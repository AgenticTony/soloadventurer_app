import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/notifications/domain/entities/travel_notification.dart';
import '../providers/notification_providers.dart';

part 'unread_notifications_notifier.g.dart';

/// Notifier for unread notifications
@riverpod
class UnreadNotificationsNotifier extends _$UnreadNotificationsNotifier {
  @override
  AsyncValue<List<TravelNotification>> build() {
    _loadUnread();
    return const AsyncValue.loading();
  }

  Future<void> _loadUnread() async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notificationRepositoryProvider);
      return await repository.getUnread(limit: 20);
    });
  }

  Future<void> refresh() async {
    await _loadUnread();
  }

  Future<void> markAllAsRead() async {
    state = await AsyncValue.guard(() async {
      final notifications = state.value ?? [];
      final repository = ref.read(notificationRepositoryProvider);
      for (final notification in notifications) {
        await repository.markAsRead(notification.id);
      }
      return await repository.getUnread(limit: 20);
    });
  }
}
