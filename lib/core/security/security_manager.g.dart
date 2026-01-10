// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages security-related features like rate limiting and device tracking

@ProviderFor(SecurityManager)
final securityManagerProvider = SecurityManagerProvider._();

/// Manages security-related features like rate limiting and device tracking
final class SecurityManagerProvider
    extends $NotifierProvider<SecurityManager, SecurityManager> {
  /// Manages security-related features like rate limiting and device tracking
  SecurityManagerProvider._()
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

String _$securityManagerHash() => r'd696a60ffb495a551429352522a5ce858c9af2f1';

/// Manages security-related features like rate limiting and device tracking

abstract class _$SecurityManager extends $Notifier<SecurityManager> {
  SecurityManager build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SecurityManager, SecurityManager>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SecurityManager, SecurityManager>,
        SecurityManager,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
