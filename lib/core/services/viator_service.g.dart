// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viator_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the ViatorService implementation.

@ProviderFor(viatorService)
const viatorServiceProvider = ViatorServiceProvider._();

/// Provider for the ViatorService implementation.

final class ViatorServiceProvider
    extends $FunctionalProvider<ViatorService, ViatorService, ViatorService>
    with $Provider<ViatorService> {
  /// Provider for the ViatorService implementation.
  const ViatorServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'viatorServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$viatorServiceHash();

  @$internal
  @override
  $ProviderElement<ViatorService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ViatorService create(Ref ref) {
    return viatorService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ViatorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ViatorService>(value),
    );
  }
}

String _$viatorServiceHash() => r'6f3c8c89c1e0ed13d427d7a6183289726ebb2b2b';
