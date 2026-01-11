// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_checkin_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the background check-in service implementation

@ProviderFor(backgroundCheckInService)
const backgroundCheckInServiceProvider = BackgroundCheckInServiceProvider._();

/// Provider for the background check-in service implementation

final class BackgroundCheckInServiceProvider extends $FunctionalProvider<
    BackgroundCheckInService,
    BackgroundCheckInService,
    BackgroundCheckInService> with $Provider<BackgroundCheckInService> {
  /// Provider for the background check-in service implementation
  const BackgroundCheckInServiceProvider._()
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
    r'3093a349ebf02f6d029db5fe8fefadfaad8f85e6';
