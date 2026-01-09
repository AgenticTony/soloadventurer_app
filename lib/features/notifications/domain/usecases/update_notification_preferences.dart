import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';
import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';

/// Update user notification preferences
class UpdateNotificationPreferences {
  final NotificationRepository _repository;

  UpdateNotificationPreferences(this._repository);

  Future<void> call(NotificationPreferences preferences) async {
    // Add timestamp before saving
    final updated = preferences.withTimestamp();
    await _repository.updatePreferences(updated);
  }
}
