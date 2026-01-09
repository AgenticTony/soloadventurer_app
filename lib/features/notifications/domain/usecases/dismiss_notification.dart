import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';

/// Dismiss a notification
class DismissNotification {
  final NotificationRepository _repository;

  DismissNotification(this._repository);

  Future<void> call(String notificationId) async {
    await _repository.dismiss(notificationId);
  }
}
