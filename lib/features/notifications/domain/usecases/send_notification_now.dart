import 'package:soloadventurer/features/notifications/domain/entities/travel_notification.dart';
import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';

/// Send a notification immediately
class SendNotificationNow {
  final NotificationRepository _repository;

  SendNotificationNow(this._repository);

  Future<void> call(TravelNotification notification) async {
    await _repository.sendNow(notification);
  }
}
