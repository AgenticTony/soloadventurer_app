// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the notification service implementation
///
/// This provider returns the actual implementation from notification_service_impl.dart.
/// The notificationServiceOverrideProvider handles the proper instantiation and disposal.

@ProviderFor(notificationService)
const notificationServiceProvider = NotificationServiceProvider._();

/// Provider for the notification service implementation
///
/// This provider returns the actual implementation from notification_service_impl.dart.
/// The notificationServiceOverrideProvider handles the proper instantiation and disposal.

final class NotificationServiceProvider extends $FunctionalProvider<
    NotificationService,
    NotificationService,
    NotificationService> with $Provider<NotificationService> {
  /// Provider for the notification service implementation
  ///
  /// This provider returns the actual implementation from notification_service_impl.dart.
  /// The notificationServiceOverrideProvider handles the proper instantiation and disposal.
  const NotificationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'4fcc2de3743ae5366a0f4459f6969dc074d9b226';
