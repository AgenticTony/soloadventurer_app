// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_notifications_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for unread notifications

@ProviderFor(UnreadNotificationsNotifier)
final unreadNotificationsProvider = UnreadNotificationsNotifierProvider._();

/// Notifier for unread notifications
final class UnreadNotificationsNotifierProvider extends $NotifierProvider<
    UnreadNotificationsNotifier, AsyncValue<List<TravelNotification>>> {
  /// Notifier for unread notifications
  UnreadNotificationsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'unreadNotificationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationsNotifierHash();

  @$internal
  @override
  UnreadNotificationsNotifier create() => UnreadNotificationsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<TravelNotification>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<TravelNotification>>>(value),
    );
  }
}

String _$unreadNotificationsNotifierHash() =>
    r'394a868b1baf51cbbb86ffd0485fa3ba246f4ff2';

/// Notifier for unread notifications

abstract class _$UnreadNotificationsNotifier
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
