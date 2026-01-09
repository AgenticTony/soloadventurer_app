// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SecurityManager

@ProviderFor(securityManager)
final securityManagerProvider = SecurityManagerProvider._();

/// Provider for SecurityManager

final class SecurityManagerProvider extends $FunctionalProvider<SecurityManager,
    SecurityManager, SecurityManager> with $Provider<SecurityManager> {
  /// Provider for SecurityManager
  SecurityManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'securityManagerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$securityManagerHash();

  @$internal
  @override
  $ProviderElement<SecurityManager> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SecurityManager create(Ref ref) {
    return securityManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecurityManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecurityManager>(value),
    );
  }
}

String _$securityManagerHash() => r'5e8ceea34a60e528571e45b353edf772a86a975e';
