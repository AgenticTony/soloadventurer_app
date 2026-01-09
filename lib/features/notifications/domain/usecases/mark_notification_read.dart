import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';

/// Mark a notification as read
class MarkNotificationRead {
  final NotificationRepository _repository;

  MarkNotificationRead(this._repository);

  Future<void> call(String notificationId) async {
    await _repository.markAsRead(notificationId);
  }
}
