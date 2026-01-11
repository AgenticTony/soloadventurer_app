// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_refresh_notification_handler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for handling token refresh notifications
///
/// This notifier listens to the TokenRefreshService status stream
/// and converts refresh events into user-facing notifications.
/// Successful refreshes are silent, while failures show user-friendly
/// error messages with options to retry or re-authenticate.

@ProviderFor(TokenRefreshNotificationHandler)
const tokenRefreshNotificationHandlerProvider =
    TokenRefreshNotificationHandlerProvider._();

/// Notifier for handling token refresh notifications
///
/// This notifier listens to the TokenRefreshService status stream
/// and converts refresh events into user-facing notifications.
/// Successful refreshes are silent, while failures show user-friendly
/// error messages with options to retry or re-authenticate.
final class TokenRefreshNotificationHandlerProvider extends $NotifierProvider<
    TokenRefreshNotificationHandler, TokenRefreshNotificationState> {
  /// Notifier for handling token refresh notifications
  ///
  /// This notifier listens to the TokenRefreshService status stream
  /// and converts refresh events into user-facing notifications.
  /// Successful refreshes are silent, while failures show user-friendly
  /// error messages with options to retry or re-authenticate.
  const TokenRefreshNotificationHandlerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tokenRefreshNotificationHandlerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tokenRefreshNotificationHandlerHash();

  @$internal
  @override
  TokenRefreshNotificationHandler create() => TokenRefreshNotificationHandler();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenRefreshNotificationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<TokenRefreshNotificationState>(value),
    );
  }
}

String _$tokenRefreshNotificationHandlerHash() =>
    r'f5801e298857a861547c6556fb7d9e9169f5d72e';

/// Notifier for handling token refresh notifications
///
/// This notifier listens to the TokenRefreshService status stream
/// and converts refresh events into user-facing notifications.
/// Successful refreshes are silent, while failures show user-friendly
/// error messages with options to retry or re-authenticate.

abstract class _$TokenRefreshNotificationHandler
    extends $Notifier<TokenRefreshNotificationState> {
  TokenRefreshNotificationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<TokenRefreshNotificationState, TokenRefreshNotificationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TokenRefreshNotificationState,
            TokenRefreshNotificationState>,
        TokenRefreshNotificationState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
