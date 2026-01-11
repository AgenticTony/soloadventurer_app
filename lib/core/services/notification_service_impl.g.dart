// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_service_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for NotificationServiceImpl

@ProviderFor(notificationServiceImpl)
const notificationServiceImplProvider = NotificationServiceImplProvider._();

/// Provider for NotificationServiceImpl

final class NotificationServiceImplProvider extends $FunctionalProvider<
    NotificationService,
    NotificationService,
    NotificationService> with $Provider<NotificationService> {
  /// Provider for NotificationServiceImpl
  const NotificationServiceImplProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationServiceImplProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceImplHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationServiceImpl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceImplHash() =>
    r'c1cc12c813dd721f44e1f079ff6e7da58aa5f764';

/// Provider override for NotificationService interface

@ProviderFor(notificationServiceOverride)
const notificationServiceOverrideProvider =
    NotificationServiceOverrideProvider._();

/// Provider override for NotificationService interface

final class NotificationServiceOverrideProvider extends $FunctionalProvider<
    NotificationService,
    NotificationService,
    NotificationService> with $Provider<NotificationService> {
  /// Provider override for NotificationService interface
  const NotificationServiceOverrideProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationServiceOverrideProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceOverrideHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationServiceOverride(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceOverrideHash() =>
    r'30769e08cbcbd2363fc3824ea7e8e25771427b30';
