// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_service_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(connectivityServiceImpl)
final connectivityServiceImplProvider = ConnectivityServiceImplProvider._();

final class ConnectivityServiceImplProvider extends $FunctionalProvider<
    ConnectivityService,
    ConnectivityService,
    ConnectivityService> with $Provider<ConnectivityService> {
  ConnectivityServiceImplProvider._()
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
    r'0c2a75789ba70b0a87bc1d133bc2bb1b2d0de9bf';
