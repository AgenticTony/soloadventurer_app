import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/notifications/domain/entities/notification_preferences.dart';
import '../providers/notification_providers.dart';

part 'notification_preferences_notifier.g.dart';

/// Notifier for managing notification preferences state
@riverpod
class NotificationPreferencesNotifier extends _$NotificationPreferencesNotifier {
  @override
  AsyncValue<NotificationPreferences> build() {
    _loadPreferences();
    return const AsyncValue.loading();
  }

  Future<void> _loadPreferences() async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notificationRepositoryProvider);
      return await repository.getPreferences();
    });
  }

  Future<void> updatePreferences(NotificationPreferences preferences) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.updatePreferences(preferences);
      return await repository.getPreferences();
    });
  }

  Future<void> resetToDefaults() async {
    await updatePreferences(NotificationPreferences.defaultPrefs());
  }
}
