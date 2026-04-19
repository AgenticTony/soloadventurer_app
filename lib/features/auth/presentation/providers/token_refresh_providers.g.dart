// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_refresh_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the TokenRefreshService
///
/// Delegates to the canonical provider in auth_service_providers.dart.

@ProviderFor(tokenRefreshService)
const tokenRefreshServiceProvider = TokenRefreshServiceProvider._();

/// Provider for the TokenRefreshService
///
/// Delegates to the canonical provider in auth_service_providers.dart.

final class TokenRefreshServiceProvider extends $FunctionalProvider<
    TokenRefreshService,
    TokenRefreshService,
    TokenRefreshService> with $Provider<TokenRefreshService> {
  /// Provider for the TokenRefreshService
  ///
  /// Delegates to the canonical provider in auth_service_providers.dart.
  const TokenRefreshServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tokenRefreshServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tokenRefreshServiceHash();

  @$internal
  @override
  $ProviderElement<TokenRefreshService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenRefreshService create(Ref ref) {
    return tokenRefreshService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenRefreshService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenRefreshService>(value),
    );
  }
}

String _$tokenRefreshServiceHash() =>
    r'39b5ecaf6f9d0462bee00e424c475259cf5c24da';
