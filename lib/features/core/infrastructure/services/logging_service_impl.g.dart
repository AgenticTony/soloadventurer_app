// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logging_service_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Implementation of [LoggingService] that follows AWS best practices for logging

@ProviderFor(LoggingServiceImpl)
const loggingServiceImplProvider = LoggingServiceImplProvider._();

/// Implementation of [LoggingService] that follows AWS best practices for logging
final class LoggingServiceImplProvider
    extends $NotifierProvider<LoggingServiceImpl, LoggingService> {
  /// Implementation of [LoggingService] that follows AWS best practices for logging
  const LoggingServiceImplProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'loggingServiceImplProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$loggingServiceImplHash();

  @$internal
  @override
  LoggingServiceImpl create() => LoggingServiceImpl();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoggingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoggingService>(value),
    );
  }
}

String _$loggingServiceImplHash() =>
    r'57985073370ef4a49d854b2b7e3386089e5a725c';

/// Implementation of [LoggingService] that follows AWS best practices for logging

abstract class _$LoggingServiceImpl extends $Notifier<LoggingService> {
  LoggingService build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LoggingService, LoggingService>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<LoggingService, LoggingService>,
        LoggingService,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
