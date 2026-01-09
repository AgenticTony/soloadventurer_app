import 'package:soloadventurer/features/notifications/domain/entities/travel_notification.dart';
import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';

/// Schedule a notification for future delivery
class ScheduleNotification {
  final NotificationRepository _repository;

  ScheduleNotification(this._repository);

  Future<void> call(TravelNotification notification) async {
    await _repository.schedule(notification);
  }
}
