// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing notifications state

@ProviderFor(NotificationsNotifier)
final notificationsProvider = NotificationsNotifierProvider._();

/// Notifier for managing notifications state
final class NotificationsNotifierProvider extends $NotifierProvider<
    NotificationsNotifier, AsyncValue<List<TravelNotification>>> {
  /// Notifier for managing notifications state
  NotificationsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationsNotifierHash();

  @$internal
  @override
  NotificationsNotifier create() => NotificationsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<TravelNotification>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<TravelNotification>>>(value),
    );
  }
}

String _$notificationsNotifierHash() =>
    r'fd32a638c62137d315601c0d215c0692d8795a18';

/// Notifier for managing notifications state

abstract class _$NotificationsNotifier
    extends $Notifier<AsyncValue<List<TravelNotification>>> {
  AsyncValue<List<TravelNotification>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<TravelNotification>>,
        AsyncValue<List<TravelNotification>>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<TravelNotification>>,
            AsyncValue<List<TravelNotification>>>,
        AsyncValue<List<TravelNotification>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
