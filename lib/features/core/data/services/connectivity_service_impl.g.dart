// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_service_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(connectivityServiceImpl)
const connectivityServiceImplProvider = ConnectivityServiceImplProvider._();

final class ConnectivityServiceImplProvider extends $FunctionalProvider<
    ConnectivityService,
    ConnectivityService,
    ConnectivityService> with $Provider<ConnectivityService> {
  const ConnectivityServiceImplProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectivityServiceImplProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectivityServiceImplHash();

  @$internal
  @override
  $ProviderElement<ConnectivityService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConnectivityService create(Ref ref) {
    return connectivityServiceImpl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityService>(value),
    );
  }
}

String _$connectivityServiceImplHash() =>
    r'1e3bb17f717818c5dc0328c4a71bc3c900782d3b';
