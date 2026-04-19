// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SyncNotificationService
///
/// This provider creates and manages the SyncNotificationService instance.
/// It auto-disposes when no longer being listened to.

@ProviderFor(syncNotificationService)
const syncNotificationServiceProvider = SyncNotificationServiceProvider._();

/// Provider for SyncNotificationService
///
/// This provider creates and manages the SyncNotificationService instance.
/// It auto-disposes when no longer being listened to.

final class SyncNotificationServiceProvider extends $FunctionalProvider<
    SyncNotificationService,
    SyncNotificationService,
    SyncNotificationService> with $Provider<SyncNotificationService> {
  /// Provider for SyncNotificationService
  ///
  /// This provider creates and manages the SyncNotificationService instance.
  /// It auto-disposes when no longer being listened to.
  const SyncNotificationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncNotificationServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncNotificationServiceHash();

  @$internal
  @override
  $ProviderElement<SyncNotificationService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncNotificationService create(Ref ref) {
    return syncNotificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncNotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncNotificationService>(value),
    );
  }
}

String _$syncNotificationServiceHash() =>
    r'087f6ab0d47b036e311b30387a311a0a78ed3863';
