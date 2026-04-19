// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viator_service_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for ViatorServiceImpl.

@ProviderFor(viatorServiceImpl)
const viatorServiceImplProvider = ViatorServiceImplProvider._();

/// Provider for ViatorServiceImpl.

final class ViatorServiceImplProvider
    extends $FunctionalProvider<ViatorService, ViatorService, ViatorService>
    with $Provider<ViatorService> {
  /// Provider for ViatorServiceImpl.
  const ViatorServiceImplProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'viatorServiceImplProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$viatorServiceImplHash();

  @$internal
  @override
  $ProviderElement<ViatorService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ViatorService create(Ref ref) {
    return viatorServiceImpl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ViatorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ViatorService>(value),
    );
  }
}

String _$viatorServiceImplHash() => r'b148e6e207a1af085fc56d16adaf2c9263288385';
