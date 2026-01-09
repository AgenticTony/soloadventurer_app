import 'dart:typed_data';
import '../entities/journal_entry.dart';
import '../entities/trip.dart';

/// Configuration for PDF export
class PdfExportConfig {
  /// Page margin (in points)
  final double pageMargin;

  /// Content margin (in points)
  final double contentMargin;

  /// Font size for title
  final double titleFontSize;

  /// Font size for headings
  final double headingFontSize;

  /// Font size for body text
  final double bodyFontSize;

  /// Font size for captions
  final double captionFontSize;

  /// Whether to include entry dates
  final bool includeDates;

  /// Whether to include locations
  final bool includeLocations;

  /// Whether to include mood indicators
  final bool includeMoods;

  /// Whether to include media (photos/videos)
  final bool includeMedia;

  /// Maximum width for images (in points)
  final double maxImageWidth;

  /// Maximum height for images (in points)
  final double maxImageHeight;

  /// Image quality (0.0 to 1.0)
  final double imageQuality;

  /// Color scheme for PDF
  final PdfColorScheme colorScheme;

  /// Default configuration
  static const defaultConfig = PdfExportConfig(
    pageMargin: 48.0,
    contentMargin: 24.0,
    titleFontSize: 28.0,
    headingFontSize: 20.0,
    bodyFontSize: 12.0,
    captionFontSize: 10.0,
    includeDates: true,
    includeLocations: true,
    includeMoods: true,
    includeMedia: true,
    maxImageWidth: 400.0,
    maxImageHeight: 300.0,
    imageQuality: 0.85,
    colorScheme: PdfColorScheme.light,
  );

  /// Configuration for high-quality export (larger images, more detail)
  static const highQualityConfig = PdfExportConfig(
    pageMargin: 48.0,
    contentMargin: 24.0,
    titleFontSize: 28.0,
    headingFontSize: 20.0,
    bodyFontSize: 12.0,
    captionFontSize: 10.0,
    includeDates: true,
    includeLocations: true,
    includeMoods: true,
    includeMedia: true,
    maxImageWidth: 500.0,
    maxImageHeight: 400.0,
    imageQuality: 0.95,
    colorScheme: PdfColorScheme.light,
  );

  /// Configuration for compact export (smaller file size)
  static const compactConfig = PdfExportConfig(
    pageMargin: 36.0,
    contentMargin: 16.0,
    titleFontSize: 24.0,
    headingFontSize: 18.0,
    bodyFontSize: 11.0,
    captionFontSize: 9.0,
    includeDates: true,
    includeLocations: true,
    includeMoods: false,
    includeMedia: true,
    maxImageWidth: 300.0,
    maxImageHeight: 200.0,
    imageQuality: 0.7,
    colorScheme: PdfColorScheme.light,
  );

  const PdfExportConfig({
    this.pageMargin = 48.0,
    this.contentMargin = 24.0,
    this.titleFontSize = 28.0,
    this.headingFontSize = 20.0,
    this.bodyFontSize = 12.0,
    this.captionFontSize = 10.0,
    this.includeDates = true,
    this.includeLocations = true,
    this.includeMoods = true,
    this.includeMedia = true,
    this.maxImageWidth = 400.0,
    this.maxImageHeight = 300.0,
    this.imageQuality = 0.85,
    this.colorScheme = PdfColorScheme.light,
  });
}

/// Color schemes for PDF export
enum PdfColorScheme {
  /// Light mode (white background, dark text)
  light,

  /// Dark mode (dark background, light text)
  dark,

  /// Sepia tone (warm, vintage look)
  sepia,
}

/// Result of a PDF export operation
class PdfExportResult {
  /// Whether the export was successful
  final bool success;

  /// Exported PDF data
  final Uint8List? pdfData;

  /// Number of pages in the PDF
  final int pageCount;

  /// Number of entries included
  final int entryCount;

  /// Number of media items included
  final int mediaCount;

  /// Error message if export failed
  final String? error;

  /// File path if saved to disk
  final String? filePath;

  /// Size of the PDF file in bytes
  final int? fileSize;

  const PdfExportResult({
    required this.success,
    this.pdfData,
    this.pageCount = 0,
    this.entryCount = 0,
    this.mediaCount = 0,
    this.error,
    this.filePath,
    this.fileSize,
  });

  /// Creates a successful export result
  factory PdfExportResult.success({
    required Uint8List pdfData,
    required int pageCount,
    required int entryCount,
    required int mediaCount,
    String? filePath,
  }) {
    return PdfExportResult(
      success: true,
      pdfData: pdfData,
      pageCount: pageCount,
      entryCount: entryCount,
      mediaCount: mediaCount,
      filePath: filePath,
      fileSize: pdfData.length,
    );
  }

  /// Creates a failed export result
  factory PdfExportResult.failure({
    required String error,
  }) {
    return PdfExportResult(
      success: false,
      error: error,
    );
  }

  /// File size in human-readable format
  String get fileSizeReadable {
    if (fileSize == null) return 'Unknown';
    final bytes = fileSize!;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Progress of PDF export operation
class PdfExportProgress {
  /// Current stage of export
  final PdfExportStage stage;

  /// Progress value (0.0 to 1.0)
  final double progress;

  /// Current entry being processed (1-based index)
  final int currentEntry;

  /// Total number of entries to process
  final int totalEntries;

  /// Current media item being processed (1-based index)
  final int currentMedia;

  /// Total number of media items to process
  final int totalMedia;

  const PdfExportProgress({
    required this.stage,
    required this.progress,
    this.currentEntry = 0,
    this.totalEntries = 0,
    this.currentMedia = 0,
    this.totalMedia = 0,
  });

  @override
  String toString() {
    return 'PdfExportProgress(stage: $stage, progress: ${(progress * 100).toStringAsFixed(1)}%, '
        'entry: $currentEntry/$totalEntries, media: $currentMedia/$totalMedia)';
  }
}

/// Stages of PDF export process
enum PdfExportStage {
  /// Initializing export
  initializing,

  /// Loading trip data
  loadingData,

  /// Loading media files
  loadingMedia,

  /// Generating PDF pages
  generatingPages,

  /// Finalizing PDF document
  finalizing,

  /// Saving PDF to disk
  saving,

  /// Export completed
  completed,

  /// Export failed
  failed,
}

/// Callback for export progress updates
typedef PdfExportProgressCallback = void Function(PdfExportProgress progress);

/// Service responsible for exporting trips to PDF format
///
/// This service handles:
/// - Generating PDF documents from trip data
/// - Including journal entries with formatted content
/// - Embedding media (photos) in the PDF
/// - Customizable layouts and styling
/// - Progress tracking during export
/// - Saving PDFs to device storage
abstract class PdfExportService {
  /// Export a trip to PDF
  ///
  /// [trip] - The trip to export
  /// [entries] - List of journal entries to include (null = all entries)
  /// [config] - Export configuration options
  /// [onProgress] - Optional callback for progress updates
  /// [outputPath] - Optional file path to save the PDF (null = no save)
  ///
  /// Returns the export result with PDF data
  Future<PdfExportResult> exportTripToPdf({
    required Trip trip,
    List<JournalEntry>? entries,
    PdfExportConfig? config,
    PdfExportProgressCallback? onProgress,
    String? outputPath,
  });

  /// Export a single journal entry to PDF
  ///
  /// [entry] - The journal entry to export
  /// [config] - Export configuration options
  /// [onProgress] - Optional callback for progress updates
  /// [outputPath] - Optional file path to save the PDF (null = no save)
  ///
  /// Returns the export result with PDF data
  Future<PdfExportResult> exportEntryToPdf({
    required JournalEntry entry,
    PdfExportConfig? config,
    PdfExportProgressCallback? onProgress,
    String? outputPath,
  });

  /// Export multiple entries to PDF
  ///
  /// [entries] - List of journal entries to export
  /// [config] - Export configuration options
  /// [onProgress] - Optional callback for progress updates
  /// [outputPath] - Optional file path to save the PDF (null = no save)
  ///
  /// Returns the export result with PDF data
  Future<PdfExportResult> exportEntriesToPdf({
    required List<JournalEntry> entries,
    PdfExportConfig? config,
    PdfExportProgressCallback? onProgress,
    String? outputPath,
  });

  /// Generate a preview of the PDF (first few pages)
  ///
  /// [trip] - The trip to preview
  /// [entries] - List of journal entries to include
  /// [config] - Export configuration options
  /// [maxPages] - Maximum number of pages to generate
  ///
  /// Returns export result with preview PDF data
  Future<PdfExportResult> generatePreview({
    required Trip trip,
    List<JournalEntry>? entries,
    PdfExportConfig? config,
    int maxPages = 3,
  });

  /// Get an estimate of the PDF file size
  ///
  /// [entryCount] - Number of entries to include
  /// [mediaCount] - Number of media items to include
  /// [config] - Export configuration options
  ///
  /// Returns estimated file size in bytes
  int estimateFileSize({
    required int entryCount,
    required int mediaCount,
    PdfExportConfig? config,
  });

  /// Get export statistics for a trip
  ///
  /// [trip] - The trip to analyze
  /// [entries] - List of entries to include (null = all entries)
  ///
  /// Returns a map with statistics about the export
  Future<Map<String, dynamic>> getExportStats({
    required Trip trip,
    List<JournalEntry>? entries,
  });

  /// Validate that media files are available for export
  ///
  /// [entries] - List of entries to validate
  ///
  /// Returns list of missing media file paths (empty if all available)
  Future<List<String>> validateMediaAvailability(List<JournalEntry> entries);

  /// Initialize the service
  Future<void> initialize();

  /// Dispose the service and clean up resources
  Future<void> dispose();
}
