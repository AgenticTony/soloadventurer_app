// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_manager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// DEPRECATED: This presentation layer TokenManager is deprecated.
///
/// Please use the domain layer TokenManager instead:
/// `lib/features/auth/domain/services/token_manager.dart`
///
/// The domain TokenManager uses FeatureAvailability enum and is properly
/// initialized in bootstrap. This presentation layer wrapper is kept for
/// backward compatibility but should not be used for new code.

@ProviderFor(TokenManager)
@Deprecated(
    'Use domain TokenManager from lib/features/auth/domain/services/token_manager.dart instead. This wrapper is deprecated and will be removed in a future version.')
const tokenManagerProvider = TokenManagerProvider._();

/// DEPRECATED: This presentation layer TokenManager is deprecated.
///
/// Please use the domain layer TokenManager instead:
/// `lib/features/auth/domain/services/token_manager.dart`
///
/// The domain TokenManager uses FeatureAvailability enum and is properly
/// initialized in bootstrap. This presentation layer wrapper is kept for
/// backward compatibility but should not be used for new code.
@Deprecated(
    'Use domain TokenManager from lib/features/auth/domain/services/token_manager.dart instead. This wrapper is deprecated and will be removed in a future version.')
final class TokenManagerProvider
    extends $NotifierProvider<TokenManager, AsyncValue<TokenState>> {
  /// DEPRECATED: This presentation layer TokenManager is deprecated.
  ///
  /// Please use the domain layer TokenManager instead:
  /// `lib/features/auth/domain/services/token_manager.dart`
  ///
  /// The domain TokenManager uses FeatureAvailability enum and is properly
  /// initialized in bootstrap. This presentation layer wrapper is kept for
  /// backward compatibility but should not be used for new code.
  const TokenManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tokenManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tokenManagerHash();

  @$internal
  @override
  TokenManager create() => TokenManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<TokenState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<TokenState>>(value),
    );
  }
}

String _$tokenManagerHash() => r'79684f1ac2fb76a5d38156a2728d0267a13f4792';

/// DEPRECATED: This presentation layer TokenManager is deprecated.
///
/// Please use the domain layer TokenManager instead:
/// `lib/features/auth/domain/services/token_manager.dart`
///
/// The domain TokenManager uses FeatureAvailability enum and is properly
/// initialized in bootstrap. This presentation layer wrapper is kept for
/// backward compatibility but should not be used for new code.

@Deprecated(
    'Use domain TokenManager from lib/features/auth/domain/services/token_manager.dart instead. This wrapper is deprecated and will be removed in a future version.')
abstract class _$TokenManager extends $Notifier<AsyncValue<TokenState>> {
  AsyncValue<TokenState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<TokenState>, AsyncValue<TokenState>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<TokenState>, AsyncValue<TokenState>>,
        AsyncValue<TokenState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
