// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accessTokenHash() => r'5af25b9ef9f4cdcd445f81a4664bd69f3f4f5e46';

/// Provider for the current access token
///
/// Copied from [accessToken].
@ProviderFor(accessToken)
final accessTokenProvider = AutoDisposeProvider<String?>.internal(
  accessToken,
  name: r'accessTokenProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$accessTokenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AccessTokenRef = AutoDisposeProviderRef<String?>;
String _$hasValidTokensHash() => r'193d85e8a40b1e8bbbac8b343595adddad2195de';

/// Provider for token validity
///
/// Copied from [hasValidTokens].
@ProviderFor(hasValidTokens)
final hasValidTokensProvider = AutoDisposeProvider<bool>.internal(
  hasValidTokens,
  name: r'hasValidTokensProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasValidTokensHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasValidTokensRef = AutoDisposeProviderRef<bool>;
String _$tokenManagerHash() => r'37ea8541acd1d783403acc3b37fae69f6025b105';

/// Token provider that manages token lifecycle using Riverpod 3.0 @riverpod pattern
///
/// Copied from [TokenManager].
@ProviderFor(TokenManager)
final tokenManagerProvider = AutoDisposeNotifierProvider<TokenManager,
    AsyncValue<AuthSession?>>.internal(
  TokenManager.new,
  name: r'tokenManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tokenManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TokenManager = AutoDisposeNotifier<AsyncValue<AuthSession?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
