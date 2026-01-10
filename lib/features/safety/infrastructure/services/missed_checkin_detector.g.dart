// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'missed_checkin_detector.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the missed check-in detector implementation

@ProviderFor(missedCheckInDetector)
final missedCheckInDetectorProvider = MissedCheckInDetectorProvider._();

/// Provider for the missed check-in detector implementation

final class MissedCheckInDetectorProvider extends $FunctionalProvider<
    MissedCheckInDetector,
    MissedCheckInDetector,
    MissedCheckInDetector> with $Provider<MissedCheckInDetector> {
  /// Provider for the missed check-in detector implementation
  MissedCheckInDetectorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'missedCheckInDetectorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$missedCheckInDetectorHash();

  @$internal
  @override
  $ProviderElement<MissedCheckInDetector> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MissedCheckInDetector create(Ref ref) {
    return missedCheckInDetector(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MissedCheckInDetector value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MissedCheckInDetector>(value),
    );
  }
}

String _$missedCheckInDetectorHash() =>
    r'83f81250920b487c80f870bbd05bb2765dee97fc';
