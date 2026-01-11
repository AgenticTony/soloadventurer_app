// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_audit_logger.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides comprehensive audit logging for token operations

@ProviderFor(tokenAuditLogger)
const tokenAuditLoggerProvider = TokenAuditLoggerProvider._();

/// Provides comprehensive audit logging for token operations

final class TokenAuditLoggerProvider
    extends $FunctionalProvider<LoggingService, LoggingService, LoggingService>
    with $Provider<LoggingService> {
  /// Provides comprehensive audit logging for token operations
  const TokenAuditLoggerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tokenAuditLoggerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tokenAuditLoggerHash();

  @$internal
  @override
  $ProviderElement<LoggingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoggingService create(Ref ref) {
    return tokenAuditLogger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoggingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoggingService>(value),
    );
  }
}

String _$tokenAuditLoggerHash() => r'7c53bf38a0d3637c40426d3978f7ed11bdb8e9b9';
