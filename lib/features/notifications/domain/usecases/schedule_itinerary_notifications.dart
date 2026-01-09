import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';

/// Schedule all notifications for an itinerary
class ScheduleItineraryNotifications {
  final NotificationRepository _repository;

  ScheduleItineraryNotifications(this._repository);

  Future<void> call(String itineraryId) async {
    await _repository.scheduleItineraryNotifications(itineraryId);
  }
}
