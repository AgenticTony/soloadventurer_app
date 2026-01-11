// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suspicious_activity_detector.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Detects and logs suspicious activity patterns related to authentication and API usage

@ProviderFor(SuspiciousActivityDetector)
const suspiciousActivityDetectorProvider =
    SuspiciousActivityDetectorProvider._();

/// Detects and logs suspicious activity patterns related to authentication and API usage
final class SuspiciousActivityDetectorProvider extends $NotifierProvider<
    SuspiciousActivityDetector, SuspiciousActivityDetector> {
  /// Detects and logs suspicious activity patterns related to authentication and API usage
  const SuspiciousActivityDetectorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'suspiciousActivityDetectorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$suspiciousActivityDetectorHash();

  @$internal
  @override
  SuspiciousActivityDetector create() => SuspiciousActivityDetector();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SuspiciousActivityDetector value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SuspiciousActivityDetector>(value),
    );
  }
}

String _$suspiciousActivityDetectorHash() =>
    r'21bc6b55570c17e7cd644a4c6229ad1163adcc93';

/// Detects and logs suspicious activity patterns related to authentication and API usage

abstract class _$SuspiciousActivityDetector
    extends $Notifier<SuspiciousActivityDetector> {
  SuspiciousActivityDetector build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<SuspiciousActivityDetector, SuspiciousActivityDetector>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SuspiciousActivityDetector, SuspiciousActivityDetector>,
        SuspiciousActivityDetector,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
