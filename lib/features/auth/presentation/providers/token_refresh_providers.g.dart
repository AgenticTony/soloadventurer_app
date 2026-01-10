// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_refresh_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the TokenRefreshService from the service locator

@ProviderFor(tokenRefreshService)
final tokenRefreshServiceProvider = TokenRefreshServiceProvider._();

/// Provider for the TokenRefreshService from the service locator

final class TokenRefreshServiceProvider extends $FunctionalProvider<
    TokenRefreshService,
    TokenRefreshService,
    TokenRefreshService> with $Provider<TokenRefreshService> {
  /// Provider for the TokenRefreshService from the service locator
  TokenRefreshServiceProvider._()
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
    r'422d19f1f754a2f72688dc580377ad40036ad923';
