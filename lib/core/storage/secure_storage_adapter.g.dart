// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_storage_adapter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SecurityManagerAdapter
///
/// This provider creates the adapter and initializes it with the
/// actual SecurityManager from Riverpod.

@ProviderFor(securityManagerAdapter)
const securityManagerAdapterProvider = SecurityManagerAdapterProvider._();

/// Provider for SecurityManagerAdapter
///
/// This provider creates the adapter and initializes it with the
/// actual SecurityManager from Riverpod.

final class SecurityManagerAdapterProvider extends $FunctionalProvider<
    SecurityManagerAdapter,
    SecurityManagerAdapter,
    SecurityManagerAdapter> with $Provider<SecurityManagerAdapter> {
  /// Provider for SecurityManagerAdapter
  ///
  /// This provider creates the adapter and initializes it with the
  /// actual SecurityManager from Riverpod.
  const SecurityManagerAdapterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'securityManagerAdapterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$securityManagerAdapterHash();

  @$internal
  @override
  $ProviderElement<SecurityManagerAdapter> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SecurityManagerAdapter create(Ref ref) {
    return securityManagerAdapter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecurityManagerAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecurityManagerAdapter>(value),
    );
  }
}

String _$securityManagerAdapterHash() =>
    r'd352bc5f0d7e6e4e58cdf41db19cd65c88146451';
