import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';
import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';

/// Get user notification preferences
class GetNotificationPreferences {
  final NotificationRepository _repository;

  GetNotificationPreferences(this._repository);

  Future<NotificationPreferences> call() async {
    return await _repository.getPreferences();
  }
}
