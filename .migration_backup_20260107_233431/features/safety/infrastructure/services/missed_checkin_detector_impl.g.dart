// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'missed_checkin_detector_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for MissedCheckInDetectorImpl

@ProviderFor(missedCheckInDetectorImpl)
final missedCheckInDetectorImplProvider = MissedCheckInDetectorImplProvider._();

/// Provider for MissedCheckInDetectorImpl

final class MissedCheckInDetectorImplProvider extends $FunctionalProvider<
    MissedCheckInDetector,
    MissedCheckInDetector,
    MissedCheckInDetector> with $Provider<MissedCheckInDetector> {
  /// Provider for MissedCheckInDetectorImpl
  MissedCheckInDetectorImplProvider._()
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
    r'da602ed511e2fdd5705607cbc3831bcad0ef28b9';

/// Provider override for MissedCheckInDetector interface

@ProviderFor(missedCheckInDetectorOverride)
final missedCheckInDetectorOverrideProvider =
    MissedCheckInDetectorOverrideProvider._();

/// Provider override for MissedCheckInDetector interface

final class MissedCheckInDetectorOverrideProvider extends $FunctionalProvider<
    MissedCheckInDetector,
    MissedCheckInDetector,
    MissedCheckInDetector> with $Provider<MissedCheckInDetector> {
  /// Provider override for MissedCheckInDetector interface
  MissedCheckInDetectorOverrideProvider._()
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
    r'e1b5f45eb419c17abb73efd84fbd7da1a9b03265';
