// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing notification preferences state

@ProviderFor(NotificationPreferencesNotifier)
final notificationPreferencesProvider =
    NotificationPreferencesNotifierProvider._();

/// Notifier for managing notification preferences state
final class NotificationPreferencesNotifierProvider extends $NotifierProvider<
    NotificationPreferencesNotifier, AsyncValue<NotificationPreferences>> {
  /// Notifier for managing notification preferences state
  NotificationPreferencesNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationPreferencesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationPreferencesNotifierHash();

  @$internal
  @override
  NotificationPreferencesNotifier create() => NotificationPreferencesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<NotificationPreferences> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<NotificationPreferences>>(value),
    );
  }
}

String _$notificationPreferencesNotifierHash() =>
    r'12961aeadfd18fd43d62cb4a26a875c77f4c5f67';

/// Notifier for managing notification preferences state

abstract class _$NotificationPreferencesNotifier
    extends $Notifier<AsyncValue<NotificationPreferences>> {
  AsyncValue<NotificationPreferences> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<NotificationPreferences>,
        AsyncValue<NotificationPreferences>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<NotificationPreferences>,
            AsyncValue<NotificationPreferences>>,
        AsyncValue<NotificationPreferences>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
