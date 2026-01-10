// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_export_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the PDF export service

@ProviderFor(pdfExportService)
final pdfExportServiceProvider = PdfExportServiceProvider._();

/// Provider for the PDF export service

final class PdfExportServiceProvider extends $FunctionalProvider<
    PdfExportService,
    PdfExportService,
    PdfExportService> with $Provider<PdfExportService> {
  /// Provider for the PDF export service
  PdfExportServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pdfExportServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pdfExportServiceHash();

  @$internal
  @override
  $ProviderElement<PdfExportService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PdfExportService create(Ref ref) {
    return pdfExportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PdfExportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PdfExportService>(value),
    );
  }
}

String _$pdfExportServiceHash() => r'4dd842389229e81a6d2df1107868ac430f442c73';

/// Notifier for PDF export state management

@ProviderFor(PdfExportNotifier)
final pdfExportProvider = PdfExportNotifierProvider._();

/// Notifier for PDF export state management
final class PdfExportNotifierProvider
    extends $NotifierProvider<PdfExportNotifier, PdfExportState> {
  /// Notifier for PDF export state management
  PdfExportNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pdfExportProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pdfExportNotifierHash();

  @$internal
  @override
  PdfExportNotifier create() => PdfExportNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PdfExportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PdfExportState>(value),
    );
  }
}

String _$pdfExportNotifierHash() => r'6ce7dbfaa9baa2518bdd1e888f3f882053f82248';

/// Notifier for PDF export state management

abstract class _$PdfExportNotifier extends $Notifier<PdfExportState> {
  PdfExportState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PdfExportState, PdfExportState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PdfExportState, PdfExportState>,
        PdfExportState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provider for PDF export statistics

@ProviderFor(pdfExportStats)
final pdfExportStatsProvider = PdfExportStatsFamily._();

/// Provider for PDF export statistics

final class PdfExportStatsProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// Provider for PDF export statistics
  PdfExportStatsProvider._(
      {required PdfExportStatsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'pdfExportStatsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pdfExportStatsHash();

  @override
  String toString() {
    return r'pdfExportStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return pdfExportStats(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PdfExportStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pdfExportStatsHash() => r'fc7c0884a233e32cef19f87cabfa070d09914d5d';

/// Provider for PDF export statistics

final class PdfExportStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>>, String> {
  PdfExportStatsFamily._()
      : super(
          retry: null,
          name: r'pdfExportStatsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for PDF export statistics

  PdfExportStatsProvider call(
    String tripId,
  ) =>
      PdfExportStatsProvider._(argument: tripId, from: this);

  @override
  String toString() => r'pdfExportStatsProvider';
}

/// Provider for estimated file size

@ProviderFor(estimatedPdfSize)
final estimatedPdfSizeProvider = EstimatedPdfSizeFamily._();

/// Provider for estimated file size

final class EstimatedPdfSizeProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for estimated file size
  EstimatedPdfSizeProvider._(
      {required EstimatedPdfSizeFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'estimatedPdfSizeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$estimatedPdfSizeHash();

  @override
  String toString() {
    return r'estimatedPdfSizeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return estimatedPdfSize(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EstimatedPdfSizeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$estimatedPdfSizeHash() => r'1f533715b3705e0ca1f76934d2fc4961f22c3d70';

/// Provider for estimated file size

final class EstimatedPdfSizeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  EstimatedPdfSizeFamily._()
      : super(
          retry: null,
          name: r'estimatedPdfSizeProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for estimated file size

  EstimatedPdfSizeProvider call(
    String tripId,
  ) =>
      EstimatedPdfSizeProvider._(argument: tripId, from: this);

  @override
  String toString() => r'estimatedPdfSizeProvider';
}

/// Provider for default output path

@ProviderFor(defaultPdfPath)
final defaultPdfPathProvider = DefaultPdfPathFamily._();

/// Provider for default output path

final class DefaultPdfPathProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Provider for default output path
  DefaultPdfPathProvider._(
      {required DefaultPdfPathFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'defaultPdfPathProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$defaultPdfPathHash();

  @override
  String toString() {
    return r'defaultPdfPathProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return defaultPdfPath(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DefaultPdfPathProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$defaultPdfPathHash() => r'a881497f671c4a9536dae68d28d618321d1e9af0';

/// Provider for default output path

final class DefaultPdfPathFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  DefaultPdfPathFamily._()
      : super(
          retry: null,
          name: r'defaultPdfPathProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for default output path

  DefaultPdfPathProvider call(
    String tripName,
  ) =>
      DefaultPdfPathProvider._(argument: tripName, from: this);

  @override
  String toString() => r'defaultPdfPathProvider';
}
