// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_checkin_service_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for BackgroundCheckInServiceImpl

@ProviderFor(backgroundCheckInServiceImpl)
final backgroundCheckInServiceImplProvider =
    BackgroundCheckInServiceImplProvider._();

/// Provider for BackgroundCheckInServiceImpl

final class BackgroundCheckInServiceImplProvider extends $FunctionalProvider<
    BackgroundCheckInService,
    BackgroundCheckInService,
    BackgroundCheckInService> with $Provider<BackgroundCheckInService> {
  /// Provider for BackgroundCheckInServiceImpl
  BackgroundCheckInServiceImplProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backgroundCheckInServiceImplProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backgroundCheckInServiceImplHash();

  @$internal
  @override
  $ProviderElement<BackgroundCheckInService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackgroundCheckInService create(Ref ref) {
    return backgroundCheckInServiceImpl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackgroundCheckInService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackgroundCheckInService>(value),
    );
  }
}

String _$backgroundCheckInServiceImplHash() =>
    r'b0414c4402613432af4af91942513b6e10e35bbd';

/// Provider override for BackgroundCheckInService interface

@ProviderFor(backgroundCheckInServiceOverride)
final backgroundCheckInServiceOverrideProvider =
    BackgroundCheckInServiceOverrideProvider._();

/// Provider override for BackgroundCheckInService interface

final class BackgroundCheckInServiceOverrideProvider
    extends $FunctionalProvider<
        BackgroundCheckInService,
        BackgroundCheckInService,
        BackgroundCheckInService> with $Provider<BackgroundCheckInService> {
  /// Provider override for BackgroundCheckInService interface
  BackgroundCheckInServiceOverrideProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backgroundCheckInServiceOverrideProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backgroundCheckInServiceOverrideHash();

  @$internal
  @override
  $ProviderElement<BackgroundCheckInService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackgroundCheckInService create(Ref ref) {
    return backgroundCheckInServiceOverride(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackgroundCheckInService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackgroundCheckInService>(value),
    );
  }
}

String _$backgroundCheckInServiceOverrideHash() =>
    r'bd0a92262eae07e8830f805d56dc1d97df1083d6';
