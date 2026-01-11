// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'missed_checkin_detector_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for MissedCheckInDetectorImpl

@ProviderFor(missedCheckInDetectorImpl)
const missedCheckInDetectorImplProvider = MissedCheckInDetectorImplProvider._();

/// Provider for MissedCheckInDetectorImpl

final class MissedCheckInDetectorImplProvider extends $FunctionalProvider<
    MissedCheckInDetector,
    MissedCheckInDetector,
    MissedCheckInDetector> with $Provider<MissedCheckInDetector> {
  /// Provider for MissedCheckInDetectorImpl
  const MissedCheckInDetectorImplProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'missedCheckInDetectorImplProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$missedCheckInDetectorImplHash();

  @$internal
  @override
  $ProviderElement<MissedCheckInDetector> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MissedCheckInDetector create(Ref ref) {
    return missedCheckInDetectorImpl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MissedCheckInDetector value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MissedCheckInDetector>(value),
    );
  }
}

String _$missedCheckInDetectorImplHash() =>
    r'308187d203317709ecb46799c0a15ecc2c8a3df8';

/// Provider override for MissedCheckInDetector interface

@ProviderFor(missedCheckInDetectorOverride)
const missedCheckInDetectorOverrideProvider =
    MissedCheckInDetectorOverrideProvider._();

/// Provider override for MissedCheckInDetector interface

final class MissedCheckInDetectorOverrideProvider extends $FunctionalProvider<
    MissedCheckInDetector,
    MissedCheckInDetector,
    MissedCheckInDetector> with $Provider<MissedCheckInDetector> {
  /// Provider override for MissedCheckInDetector interface
  const MissedCheckInDetectorOverrideProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'missedCheckInDetectorOverrideProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$missedCheckInDetectorOverrideHash();

  @$internal
  @override
  $ProviderElement<MissedCheckInDetector> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MissedCheckInDetector create(Ref ref) {
    return missedCheckInDetectorOverride(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MissedCheckInDetector value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MissedCheckInDetector>(value),
    );
  }
}

String _$missedCheckInDetectorOverrideHash() =>
    r'7c26af930b4e6743c22675fbe27d21e0ba05a261';
