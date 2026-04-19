// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the PushNotificationService singleton

@ProviderFor(pushNotificationService)
const pushNotificationServiceProvider = PushNotificationServiceProvider._();

/// Provider for the PushNotificationService singleton

final class PushNotificationServiceProvider extends $FunctionalProvider<
    PushNotificationService,
    PushNotificationService,
    PushNotificationService> with $Provider<PushNotificationService> {
  /// Provider for the PushNotificationService singleton
  const PushNotificationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pushNotificationServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pushNotificationServiceHash();

  @$internal
  @override
  $ProviderElement<PushNotificationService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PushNotificationService create(Ref ref) {
    return pushNotificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushNotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushNotificationService>(value),
    );
  }
}

String _$pushNotificationServiceHash() =>
    r'4730a581cc937f488ee2a274c8d66de537d18103';
