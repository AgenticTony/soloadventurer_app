import 'package:soloadventurer/features/notifications/domain/entities/travel_notification.dart';
import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';

/// Get notification history with optional filters
class GetNotificationHistory {
  final NotificationRepository _repository;

  GetNotificationHistory(this._repository);

  Future<List<TravelNotification>> call({
    DateTime? startDate,
    DateTime? endDate,
    NotificationCategory? category,
    int limit = 50,
    int offset = 0,
  }) async {
    return await _repository.getHistory(
      startDate: startDate,
      endDate: endDate,
      category: category,
      limit: limit,
      offset: offset,
    );
  }
}
