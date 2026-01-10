// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_checkin_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the background check-in service implementation

@ProviderFor(backgroundCheckInService)
final backgroundCheckInServiceProvider = BackgroundCheckInServiceProvider._();

/// Provider for the background check-in service implementation

final class BackgroundCheckInServiceProvider extends $FunctionalProvider<
    BackgroundCheckInService,
    BackgroundCheckInService,
    BackgroundCheckInService> with $Provider<BackgroundCheckInService> {
  /// Provider for the background check-in service implementation
  BackgroundCheckInServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backgroundCheckInServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backgroundCheckInServiceHash();

  @$internal
  @override
  $ProviderElement<BackgroundCheckInService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackgroundCheckInService create(Ref ref) {
    return backgroundCheckInService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackgroundCheckInService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackgroundCheckInService>(value),
    );
  }
}

String _$backgroundCheckInServiceHash() =>
    r'7a11a29c3aeb0930c7e25ad9d219649526957fc3';
