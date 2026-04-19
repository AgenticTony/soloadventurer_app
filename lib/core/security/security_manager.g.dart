// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages security-related features like rate limiting and device tracking

@ProviderFor(SecurityManager)
const securityManagerProvider = SecurityManagerProvider._();

/// Manages security-related features like rate limiting and device tracking
final class SecurityManagerProvider
    extends $NotifierProvider<SecurityManager, SecurityManager> {
  /// Manages security-related features like rate limiting and device tracking
  const SecurityManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'securityManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$securityManagerHash();

  @$internal
  @override
  SecurityManager create() => SecurityManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecurityManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecurityManager>(value),
    );
  }
}

String _$securityManagerHash() => r'1470c60e9b0cce74b96ffd47b3954b113cd1d79c';

/// Manages security-related features like rate limiting and device tracking

abstract class _$SecurityManager extends $Notifier<SecurityManager> {
  SecurityManager build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SecurityManager, SecurityManager>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SecurityManager, SecurityManager>,
        SecurityManager,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
