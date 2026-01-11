/// Sealed class representing the state of authentication tokens
///
/// Uses Dart 3 sealed class pattern for exhaustive pattern matching.
/// This replaces the Freezed union type pattern.
sealed class TokenState {
  const TokenState();

  /// Creates an empty token state
  const factory TokenState.empty() = EmptyTokenState;

  /// Creates a valid token state
  const factory TokenState.valid({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) = ValidTokenState;

  /// Creates an expired token state
  const factory TokenState.expired({
    required String refreshToken,
  }) = ExpiredTokenState;

  /// Creates a refreshing token state
  const factory TokenState.refreshing({
    required String refreshToken,
  }) = RefreshingTokenState;

  /// Creates an error token state
  const factory TokenState.error({
    required String message,
    required bool requiresReauthentication,
  }) = ErrorTokenState;

  /// Pattern matching - maps the current state to [T]
  T map<T>({
    required T Function(ValidTokenState state) valid,
    required T Function(ExpiredTokenState state) expired,
    required T Function(RefreshingTokenState state) refreshing,
    required T Function(ErrorTokenState state) error,
    required T Function(EmptyTokenState state) empty,
  }) {
    return switch (this) {
      ValidTokenState s => valid(s),
      ExpiredTokenState s => expired(s),
      RefreshingTokenState s => refreshing(s),
      ErrorTokenState s => error(s),
      EmptyTokenState s => empty(s),
    };
  }

  /// Pattern matching - maps the current state to [T], returns null for non-matching states
  T? mapOrNull<T>({
    T Function(ValidTokenState state)? valid,
    T Function(ExpiredTokenState state)? expired,
    T Function(RefreshingTokenState state)? refreshing,
    T Function(ErrorTokenState state)? error,
    T Function(EmptyTokenState state)? empty,
  }) {
    return switch (this) {
      ValidTokenState s when valid != null => valid(s),
      ExpiredTokenState s when expired != null => expired(s),
      RefreshingTokenState s when refreshing != null => refreshing(s),
      ErrorTokenState s when error != null => error(s),
      EmptyTokenState s when empty != null => empty(s),
      _ => null,
    };
  }

  /// Whether the token is currently valid
  bool get isValid => this is ValidTokenState;

  /// Whether the token is expired
  bool get isExpired => this is ExpiredTokenState;

  /// Whether the token is currently being refreshed
  bool get isRefreshing => this is RefreshingTokenState;

  /// Whether the token state is an error
  bool get isError => this is ErrorTokenState;

  /// Whether the token state is empty
  bool get isEmpty => this is EmptyTokenState;
}

/// Valid token state - tokens are present and not expired
final class ValidTokenState extends TokenState {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const ValidTokenState({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidTokenState &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode => Object.hash(accessToken, refreshToken, expiresAt);

  @override
  String toString() =>
      'ValidTokenState(expiresAt: $expiresAt)';
}

/// Expired token state - tokens exist but are past expiration
final class ExpiredTokenState extends TokenState {
  final String refreshToken;

  const ExpiredTokenState({required this.refreshToken});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpiredTokenState && other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => refreshToken.hashCode;

  @override
  String toString() => 'ExpiredTokenState()';
}

/// Refreshing token state - currently attempting to refresh tokens
final class RefreshingTokenState extends TokenState {
  final String refreshToken;

  const RefreshingTokenState({required this.refreshToken});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RefreshingTokenState &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => refreshToken.hashCode;

  @override
  String toString() => 'RefreshingTokenState()';
}

/// Error token state - token refresh failed or other error
final class ErrorTokenState extends TokenState {
  final String message;
  final bool requiresReauthentication;

  const ErrorTokenState({
    required this.message,
    required this.requiresReauthentication,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ErrorTokenState &&
        other.message == message &&
        other.requiresReauthentication == requiresReauthentication;
  }

  @override
  int get hashCode => Object.hash(message, requiresReauthentication);

  @override
  String toString() =>
      'ErrorTokenState(message: $message, requiresReauthentication: $requiresReauthentication)';
}

/// Empty token state - no tokens present
final class EmptyTokenState extends TokenState {
  const EmptyTokenState();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmptyTokenState;
  }

  @override
  int get hashCode => 0;

  @override
  String toString() => 'EmptyTokenState()';
}
