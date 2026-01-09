import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';
import 'package:soloadventurer/features/notifications/data/providers/notification_providers.dart'
    show notificationRepositoryOverrideProvider;

part 'notification_preferences_notifier.g.dart';

/// Notifier for managing notification preferences state
@riverpod
class NotificationPreferencesNotifier
    extends _$NotificationPreferencesNotifier {
  @override
  AsyncValue<NotificationPreferences> build() {
    _loadPreferences();
    return const AsyncValue.loading();
  }

  Future<void> _loadPreferences() async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notificationRepositoryOverrideProvider);
      return await repository.getPreferences();
    });
  }

  Future<void> updatePreferences(NotificationPreferences preferences) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notificationRepositoryOverrideProvider);
      await repository.updatePreferences(preferences);
      return await repository.getPreferences();
    });
  }

  Future<void> resetToDefaults() async {
    await updatePreferences(NotificationPreferences.defaultPrefs());
  }
}
