import 'package:soloadventurer/features/notifications/domain/entities/travel_notification.dart';
import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';

/// Get unread notifications
class GetUnreadNotifications {
  final NotificationRepository _repository;

  GetUnreadNotifications(this._repository);

  Future<List<TravelNotification>> call({
    int limit = 20,
  }) async {
    return await _repository.getUnread(limit: limit);
  }
}
