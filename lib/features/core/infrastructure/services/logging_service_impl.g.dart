// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logging_service_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Implementation of [LoggingService] that follows AWS best practices for logging

@ProviderFor(LoggingServiceImpl)
final loggingServiceImplProvider = LoggingServiceImplProvider._();

/// Implementation of [LoggingService] that follows AWS best practices for logging
final class LoggingServiceImplProvider
    extends $NotifierProvider<LoggingServiceImpl, LoggingService> {
  /// Implementation of [LoggingService] that follows AWS best practices for logging
  LoggingServiceImplProvider._()
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
    r'b6bb408a126572952631917e0978e7de58dd85e2';

/// Implementation of [LoggingService] that follows AWS best practices for logging

abstract class _$LoggingServiceImpl extends $Notifier<LoggingService> {
  LoggingService build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LoggingService, LoggingService>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<LoggingService, LoggingService>,
        LoggingService,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
