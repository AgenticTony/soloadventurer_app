// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_audit_logger.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides comprehensive audit logging for token operations
///
/// NOTE: This service has been stubbed out after removing AWS CloudWatch dependencies.
/// The actual monitoring should be handled by a different monitoring service.

@ProviderFor(tokenAuditLogger)
const tokenAuditLoggerProvider = TokenAuditLoggerProvider._();

/// Provides comprehensive audit logging for token operations
///
/// NOTE: This service has been stubbed out after removing AWS CloudWatch dependencies.
/// The actual monitoring should be handled by a different monitoring service.

final class TokenAuditLoggerProvider
    extends $FunctionalProvider<LoggingService, LoggingService, LoggingService>
    with $Provider<LoggingService> {
  /// Provides comprehensive audit logging for token operations
  ///
  /// NOTE: This service has been stubbed out after removing AWS CloudWatch dependencies.
  /// The actual monitoring should be handled by a different monitoring service.
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

String _$tokenAuditLoggerHash() => r'4aebea3ead2a470055c5d5dd49f37084c4ceab13';
