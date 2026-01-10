import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/trip.dart';
import '../../domain/services/pdf_export_service.dart';
import '../../data/services/pdf_export_service_impl.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/repositories/trip_repository.dart';
import 'trip_providers.dart';
import 'journal_entry_providers.dart';

part 'pdf_export_providers.g.dart';

/// Provider for the PDF export service
@Riverpod(keepAlive: true)
PdfExportService pdfExportService(Ref ref) {
  final journalRepository = ref.watch(journalRepositoryProvider);
  final tripRepository = ref.watch(tripRepositoryProvider);

  return PdfExportServiceImpl(
    journalRepository: journalRepository,
    tripRepository: tripRepository,
  );
}

/// State for PDF export operations
class PdfExportState {
  /// Current status of export
  final PdfExportStatus status;

  /// Progress information (0.0 to 1.0)
  final double progress;

  /// Current stage of export
  final PdfExportStage? stage;

  /// Current entry being processed
  final int currentEntry;

  /// Total entries to process
  final int totalEntries;

  /// Export result if available
  final PdfExportResult? result;

  /// Error message if export failed
  final String? error;

  /// Timestamp when export started
  final DateTime? startedAt;

  /// Timestamp when export completed
  final DateTime? completedAt;

  const PdfExportState({
    this.status = PdfExportStatus.idle,
    this.progress = 0.0,
    this.stage,
    this.currentEntry = 0,
    this.totalEntries = 0,
    this.result,
    this.error,
    this.startedAt,
    this.completedAt,
  });

  /// Whether export is currently in progress
  bool get isExporting => status == PdfExportStatus.exporting;

  /// Whether export completed successfully
  bool get isSuccess => status == PdfExportStatus.success;

  /// Whether export failed
  bool get isFailed => status == PdfExportStatus.failed;

  /// Whether export is idle (not started)
  bool get isIdle => status == PdfExportStatus.idle;

  /// Get duration of export
  Duration? get exportDuration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }

  /// Copy with method
  PdfExportState copyWith({
    PdfExportStatus? status,
    double? progress,
    PdfExportStage? stage,
    int? currentEntry,
    int? totalEntries,
    PdfExportResult? result,
    String? error,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return PdfExportState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      stage: stage ?? this.stage,
      currentEntry: currentEntry ?? this.currentEntry,
      totalEntries: totalEntries ?? this.totalEntries,
      result: result ?? this.result,
      error: error ?? this.error,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() {
    return 'PdfExportState(status: $status, progress: ${(progress * 100).toStringAsFixed(1)}%, '
        'stage: $stage, entry: $currentEntry/$totalEntries)';
  }
}

/// Status of PDF export
enum PdfExportStatus {
  /// No export in progress
  idle,

  /// Export is in progress
  exporting,

  /// Export completed successfully
  success,

  /// Export failed
  failed,
}

/// Notifier for PDF export state management
@riverpod
class PdfExportNotifier extends _$PdfExportNotifier {
  @override
  PdfExportState build() {
    return const PdfExportState();
  }

  /// Export a trip to PDF
  Future<void> exportTrip({
    required String tripId,
    PdfExportConfig? config,
    String? outputPath,
  }) async {
    final service = ref.read(pdfExportServiceProvider);

    state = state.copyWith(
      status: PdfExportStatus.exporting,
      progress: 0.0,
      startedAt: DateTime.now(),
      completedAt: null,
      error: null,
      result: null,
    );

    try {
      // Get trip
      final trip = await ref.read(tripRepositoryProvider).getTrip(tripId);

      // Get entries
      final entries =
          await ref.read(journalRepositoryProvider).getEntriesByTrip(tripId);

      // Perform export
      final result = await service.exportTripToPdf(
        trip: trip,
        entries: entries,
        config: config,
        onProgress: (progress) {
          state = state.copyWith(
            progress: progress.progress,
            stage: progress.stage,
            currentEntry: progress.currentEntry,
            totalEntries: progress.totalEntries,
          );
        },
        outputPath: outputPath,
      );

      if (result.success) {
        state = state.copyWith(
          status: PdfExportStatus.success,
          progress: 1.0,
          result: result,
          completedAt: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          status: PdfExportStatus.failed,
          error: result.error,
          completedAt: DateTime.now(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: PdfExportStatus.failed,
        error: e.toString(),
        completedAt: DateTime.now(),
      );
    }
  }

  /// Export a single entry to PDF
  Future<void> exportEntry({
    required String entryId,
    PdfExportConfig? config,
    String? outputPath,
  }) async {
    final service = ref.read(pdfExportServiceProvider);

    state = state.copyWith(
      status: PdfExportStatus.exporting,
      progress: 0.0,
      startedAt: DateTime.now(),
      completedAt: null,
      error: null,
      result: null,
    );

    try {
      final entry =
          await ref.read(journalRepositoryProvider).getEntry(entryId);

      final result = await service.exportEntryToPdf(
        entry: entry,
        config: config,
        onProgress: (progress) {
          state = state.copyWith(
            progress: progress.progress,
            stage: progress.stage,
          );
        },
        outputPath: outputPath,
      );

      if (result.success) {
        state = state.copyWith(
          status: PdfExportStatus.success,
          progress: 1.0,
          result: result,
          completedAt: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          status: PdfExportStatus.failed,
          error: result.error,
          completedAt: DateTime.now(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: PdfExportStatus.failed,
        error: e.toString(),
        completedAt: DateTime.now(),
      );
    }
  }

  /// Export multiple entries to PDF
  Future<void> exportEntries({
    required List<String> entryIds,
    PdfExportConfig? config,
    String? outputPath,
  }) async {
    final service = ref.read(pdfExportServiceProvider);

    state = state.copyWith(
      status: PdfExportStatus.exporting,
      progress: 0.0,
      startedAt: DateTime.now(),
      completedAt: null,
      error: null,
      result: null,
    );

    try {
      final entries = await Future.wait<JournalEntry>(
        entryIds
            .map((id) => ref.read(journalRepositoryProvider).getEntry(id)),
      );

      final result = await service.exportEntriesToPdf(
        entries: entries,
        config: config,
        onProgress: (progress) {
          state = state.copyWith(
            progress: progress.progress,
            stage: progress.stage,
            currentEntry: progress.currentEntry,
            totalEntries: progress.totalEntries,
          );
        },
        outputPath: outputPath,
      );

      if (result.success) {
        state = state.copyWith(
          status: PdfExportStatus.success,
          progress: 1.0,
          result: result,
          completedAt: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          status: PdfExportStatus.failed,
          error: result.error,
          completedAt: DateTime.now(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: PdfExportStatus.failed,
        error: e.toString(),
        completedAt: DateTime.now(),
      );
    }
  }

  /// Reset the state
  void reset() {
    state = const PdfExportState();
  }

  /// Clear the error but keep other state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for PDF export statistics
@riverpod
Future<Map<String, dynamic>> pdfExportStats(
    Ref ref, String tripId) async {
  final service = ref.read(pdfExportServiceProvider);
  final trip = await ref.read(tripRepositoryProvider).getTrip(tripId);
  return service.getExportStats(trip: trip);
}

/// Provider for estimated file size
@riverpod
Future<int> estimatedPdfSize(Ref ref, String tripId) async {
  final stats = await ref.watch(pdfExportStatsProvider(tripId).future);
  return stats['estimatedFileSize'] as int;
}

/// Provider for default output path
@riverpod
Future<String> defaultPdfPath(Ref ref, String tripName) async {
  final directory = await getApplicationDocumentsDirectory();
  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  final safeName = tripName.replaceAll(RegExp(r'[^\w\s-]'), '_').trim();
  return '${directory.path}/$safeName-$timestamp.pdf';
}
