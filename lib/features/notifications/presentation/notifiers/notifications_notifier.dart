import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/notifications/domain/entities/travel_notification.dart';
import 'package:soloadventurer/features/notifications/data/providers/notification_providers.dart'
    show notificationRepositoryOverrideProvider;

part 'notifications_notifier.g.dart';

/// Notifier for managing notifications state
@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  AsyncValue<List<TravelNotification>> build() {
    _loadNotifications();
    return const AsyncValue.loading();
  }

  Future<void> _loadNotifications() async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notificationRepositoryOverrideProvider);
      return await repository.getHistory(limit: 50);
    });
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }

  Future<void> markAsRead(String notificationId) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notificationRepositoryOverrideProvider);
      await repository.markAsRead(notificationId);
      return await repository.getHistory(limit: 50);
    });
  }

  Future<void> dismiss(String notificationId) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notificationRepositoryOverrideProvider);
      await repository.dismiss(notificationId);
      return await repository.getHistory(limit: 50);
    });
  }

  Future<void> dismissAll() async {
    final notifications = state.value ?? [];
    for (final notification in notifications) {
      await dismiss(notification.id);
    }
  }

  Future<void> clearHistory() async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notificationRepositoryOverrideProvider);
      await repository.clearHistory();
      return await repository.getHistory(limit: 50);
    });
  }
}
