import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/repositories/trip_repository.dart';
import '../../domain/services/pdf_export_service.dart';

/// Implementation of PDF export service
class PdfExportServiceImpl implements PdfExportService {
  final JournalRepository _journalRepository;
  final TripRepository _tripRepository;

  PdfExportServiceImpl({
    required JournalRepository journalRepository,
    required TripRepository tripRepository,
  })  : _journalRepository = journalRepository,
        _tripRepository = tripRepository;

  @override
  Future<PdfExportResult> exportTripToPdf({
    required Trip trip,
    List<JournalEntry>? entries,
    PdfExportConfig? config,
    PdfExportProgressCallback? onProgress,
    String? outputPath,
  }) async {
    try {
      onProgress?.call(const PdfExportProgress(
        stage: PdfExportStage.initializing,
        progress: 0.0,
      ));

      // Load entries if not provided
      final entriesToExport =
          entries ?? await _journalRepository.getEntriesByTrip(trip.id);

      onProgress?.call(PdfExportProgress(
        stage: PdfExportStage.loadingData,
        progress: 0.1,
        currentEntry: 0,
        totalEntries: entriesToExport.length,
      ));

      // Validate and load media
      final missingMedia = await validateMediaAvailability(entriesToExport);
      if (missingMedia.isNotEmpty && config?.includeMedia == true) {
        // Continue with export but note missing media
      }

      onProgress?.call(PdfExportProgress(
        stage: PdfExportStage.loadingMedia,
        progress: 0.2,
        currentEntry: 0,
        totalEntries: entriesToExport.length,
      ));

      // Generate PDF
      final pdfData = await _generatePdf(
        trip: trip,
        entries: entriesToExport,
        config: config ?? PdfExportConfig.defaultConfig,
        onProgress: onProgress,
      );

      onProgress?.call(PdfExportProgress(
        stage: PdfExportStage.finalizing,
        progress: 0.95,
        currentEntry: entriesToExport.length,
        totalEntries: entriesToExport.length,
      ));

      // Save to disk if path provided
      String? savedPath;
      if (outputPath != null) {
        savedPath = await _savePdf(pdfData, outputPath);
      }

      // Calculate stats
      final mediaCount = entriesToExport.fold<int>(
        0,
        (sum, entry) => sum + 0, // Media count not available from JournalEntry directly
      );

      onProgress?.call(const PdfExportProgress(
        stage: PdfExportStage.completed,
        progress: 1.0,
      ));

      return PdfExportResult.success(
        pdfData: pdfData,
        pageCount: await _getPageCount(pdfData),
        entryCount: entriesToExport.length,
        mediaCount: mediaCount,
        filePath: savedPath,
      );
    } catch (e) {
      onProgress?.call(const PdfExportProgress(
        stage: PdfExportStage.failed,
        progress: 0.0,
      ));
      return PdfExportResult.failure(error: e.toString());
    }
  }

  @override
  Future<PdfExportResult> exportEntryToPdf({
    required JournalEntry entry,
    PdfExportConfig? config,
    PdfExportProgressCallback? onProgress,
    String? outputPath,
  }) async {
    try {
      onProgress?.call(const PdfExportProgress(
        stage: PdfExportStage.initializing,
        progress: 0.0,
      ));

      final trip = entry.tripId != null
          ? await _tripRepository.getTrip(entry.tripId!)
          : null;

      onProgress?.call(const PdfExportProgress(
        stage: PdfExportStage.loadingData,
        progress: 0.3,
      ));

      final pdfData = await _generatePdf(
        trip: trip ??
            Trip(
              id: 'default',
              userId: entry.userId,
              name: 'Journal Entry',
              startDate: entry.entryDate,
              createdAt: entry.createdAt,
              updatedAt: entry.updatedAt,
            ),
        entries: [entry],
        config: config ?? PdfExportConfig.defaultConfig,
        onProgress: onProgress,
      );

      String? savedPath;
      if (outputPath != null) {
        savedPath = await _savePdf(pdfData, outputPath);
      }

      onProgress?.call(const PdfExportProgress(
        stage: PdfExportStage.completed,
        progress: 1.0,
      ));

      return PdfExportResult.success(
        pdfData: pdfData,
        pageCount: await _getPageCount(pdfData),
        entryCount: 1,
        mediaCount: 0,
        filePath: savedPath,
      );
    } catch (e) {
      onProgress?.call(const PdfExportProgress(
        stage: PdfExportStage.failed,
        progress: 0.0,
      ));
      return PdfExportResult.failure(error: e.toString());
    }
  }

  @override
  Future<PdfExportResult> exportEntriesToPdf({
    required List<JournalEntry> entries,
    PdfExportConfig? config,
    PdfExportProgressCallback? onProgress,
    String? outputPath,
  }) async {
    try {
      onProgress?.call(const PdfExportProgress(
        stage: PdfExportStage.initializing,
        progress: 0.0,
      ));

      // Create a synthetic trip
      final trip = Trip(
        id: 'multiple',
        userId: entries.first.userId,
        name: 'Journal Entries',
        startDate: entries
            .map((e) => e.entryDate)
            .reduce((a, b) => a.isBefore(b) ? a : b),
        endDate: entries
            .map((e) => e.entryDate)
            .reduce((a, b) => a.isAfter(b) ? a : b),
        createdAt: entries
            .map((e) => e.createdAt)
            .reduce((a, b) => a.isBefore(b) ? a : b),
        updatedAt: entries
            .map((e) => e.updatedAt)
            .reduce((a, b) => a.isAfter(b) ? a : b),
      );

      final pdfData = await _generatePdf(
        trip: trip,
        entries: entries,
        config: config ?? PdfExportConfig.defaultConfig,
        onProgress: onProgress,
      );

      String? savedPath;
      if (outputPath != null) {
        savedPath = await _savePdf(pdfData, outputPath);
      }

      onProgress?.call(const PdfExportProgress(
        stage: PdfExportStage.completed,
        progress: 1.0,
      ));

      return PdfExportResult.success(
        pdfData: pdfData,
        pageCount: await _getPageCount(pdfData),
        entryCount: entries.length,
        mediaCount: 0,
        filePath: savedPath,
      );
    } catch (e) {
      onProgress?.call(const PdfExportProgress(
        stage: PdfExportStage.failed,
        progress: 0.0,
      ));
      return PdfExportResult.failure(error: e.toString());
    }
  }

  @override
  Future<PdfExportResult> generatePreview({
    required Trip trip,
    List<JournalEntry>? entries,
    PdfExportConfig? config,
    int maxPages = 3,
  }) async {
    try {
      final entriesToExport = entries ??
          (await _journalRepository.getEntriesByTrip(trip.id))
              .take(maxPages)
              .toList();

      final pdfData = await _generatePdf(
        trip: trip,
        entries: entriesToExport,
        config: config ?? PdfExportConfig.defaultConfig,
        onProgress: null,
      );

      return PdfExportResult.success(
        pdfData: pdfData,
        pageCount: await _getPageCount(pdfData),
        entryCount: entriesToExport.length,
        mediaCount: 0,
      );
    } catch (e) {
      return PdfExportResult.failure(error: e.toString());
    }
  }

  @override
  int estimateFileSize({
    required int entryCount,
    required int mediaCount,
    PdfExportConfig? config,
  }) {
    // Base size per page (~50KB)
    final baseSize = entryCount * 50000;

    // Size per image (assuming average quality)
    final avgImageSize = config?.imageQuality != null
        ? (200000 * config!.imageQuality).toInt()
        : 170000;

    final imageSize = mediaCount * avgImageSize;

    // Metadata overhead
    const metadataSize = 10000;

    return baseSize + imageSize + metadataSize;
  }

  @override
  Future<Map<String, dynamic>> getExportStats({
    required Trip trip,
    List<JournalEntry>? entries,
  }) async {
    final entriesToExport =
        entries ?? await _journalRepository.getEntriesByTrip(trip.id);

    int totalMediaCount = 0;
    int photoCount = 0;
    int videoCount = 0;
    int wordCount = 0;

    for (final entry in entriesToExport) {
      wordCount += entry.content.split(RegExp(r'\s+')).length;
      totalMediaCount += 0; // Media count not available from JournalEntry directly
    }

    return {
      'entryCount': entriesToExport.length,
      'totalMediaCount': totalMediaCount,
      'photoCount': photoCount,
      'videoCount': videoCount,
      'wordCount': wordCount,
      'estimatedFileSize': estimateFileSize(
        entryCount: entriesToExport.length,
        mediaCount: totalMediaCount,
      ),
    };
  }

  @override
  Future<List<String>> validateMediaAvailability(
      List<JournalEntry> entries) async {
    final missingMedia = <String>[];

    // This would check if media files exist
    // For now, return empty list as we'd need to query media repository
    return missingMedia;
  }

  @override
  Future<void> initialize() async {
    // Load fonts if needed
    // For now, we'll use default PDF fonts
  }

  @override
  Future<void> dispose() async {
    // Clean up resources
  }

  // Private helper methods

  Future<Uint8List> _generatePdf({
    required Trip trip,
    required List<JournalEntry> entries,
    required PdfExportConfig config,
    PdfExportProgressCallback? onProgress,
  }) async {
    final pdf = pw.Document();

    final theme = _getTheme(config.colorScheme);

    // Add cover page
    pdf.addPage(
      pw.Page(
        pageTheme: theme,
        build: (pw.Context context) {
          return _buildCoverPage(trip, config, theme);
        },
      ),
    );

    // Add entry pages
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final progress = 0.3 + (0.6 * (i + 1) / entries.length);

      onProgress?.call(PdfExportProgress(
        stage: PdfExportStage.generatingPages,
        progress: progress,
        currentEntry: i + 1,
        totalEntries: entries.length,
      ));

      pdf.addPage(
        pw.Page(
          pageTheme: theme,
          build: (pw.Context context) {
            return _buildEntryPage(entry, config, theme);
          },
        ),
      );
    }

    return await pdf.save();
  }

  pw.Widget _buildCoverPage(
      Trip trip, PdfExportConfig config, pw.PageTheme theme) {
    final dateFormat = DateFormat.yMMMMd('en_US');
    final durationFormat = trip.duration.inDays > 0
        ? '${trip.duration.inDays} days'
        : '${trip.duration.inHours} hours';

    return pw.Container(
      padding: pw.EdgeInsets.all(config.pageMargin),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            trip.name,
            style: pw.TextStyle(
              fontSize: config.titleFontSize,
              fontWeight: pw.FontWeight.bold,
              color: theme.theme?.defaultTextStyle.color ?? PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 16),
          if (trip.description != null) ...[
            pw.Text(
              trip.description!,
              style: pw.TextStyle(
                fontSize: config.bodyFontSize,
                color: theme.theme?.defaultTextStyle.color ?? PdfColors.black,
              ),
            ),
            pw.SizedBox(height: 24),
          ],
          pw.Text(
            'Dates: ${dateFormat.format(trip.startDate)} - '
            '${trip.endDate != null ? dateFormat.format(trip.endDate!) : 'Present'}',
            style: pw.TextStyle(
              fontSize: config.bodyFontSize,
              color: theme.theme?.defaultTextStyle.color ?? PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Duration: $durationFormat',
            style: pw.TextStyle(
              fontSize: config.bodyFontSize,
              color: theme.theme?.defaultTextStyle.color ?? PdfColors.black,
            ),
          ),
          if (trip.destination != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Destination: ${trip.destination}',
              style: pw.TextStyle(
                fontSize: config.bodyFontSize,
                color: theme.theme?.defaultTextStyle.color ?? PdfColors.black,
              ),
            ),
          ],
          pw.SizedBox(height: 32),
          pw.Text(
            'Generated on ${DateFormat.yMMMMd('en_US').add_jm().format(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: config.captionFontSize,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEntryPage(
      JournalEntry entry, PdfExportConfig config, pw.PageTheme theme) {
    final dateFormat = DateFormat.yMMMMd('en_US').add_jm();

    return pw.Container(
      padding: pw.EdgeInsets.all(config.pageMargin),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Title
          pw.Text(
            entry.title,
            style: pw.TextStyle(
              fontSize: config.headingFontSize,
              fontWeight: pw.FontWeight.bold,
              color: theme.theme?.defaultTextStyle.color ?? PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 16),

          // Metadata row
          if (config.includeDates)
            pw.Text(
              dateFormat.format(entry.entryDate),
              style: pw.TextStyle(
                fontSize: config.captionFontSize,
                color: PdfColors.grey700,
              ),
            ),
          pw.SizedBox(height: 8),

          // Location
          if (config.includeLocations && entry.locationName != null)
            pw.Text(
              '📍 ${entry.locationName}',
              style: pw.TextStyle(
                fontSize: config.captionFontSize,
                color: PdfColors.grey700,
              ),
            ),
          pw.SizedBox(height: 8),

          // Mood
          if (config.includeMoods && entry.mood != null)
            pw.Text(
              'Mood: ${entry.mood}',
              style: pw.TextStyle(
                fontSize: config.captionFontSize,
                color: PdfColors.grey700,
              ),
            ),
          pw.SizedBox(height: 24),

          // Content
          pw.Text(
            entry.content,
            style: pw.TextStyle(
              fontSize: config.bodyFontSize,
              color: theme.theme?.defaultTextStyle.color ?? PdfColors.black,
            ),
          ),

          // Media placeholder (actual images would be loaded and embedded)
          if (config.includeMedia) ...[
            pw.SizedBox(height: 24),
            pw.Container(
              height: 100,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Center(
                child: pw.Text(
                  'Media attachments placeholder',
                  style: pw.TextStyle(
                    fontSize: config.captionFontSize,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.PageTheme _getTheme(PdfColorScheme scheme) {
    switch (scheme) {
      case PdfColorScheme.light:
        return pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(48),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
          buildBackground: (pw.Context context) {
            if (context.pageNumber == 1) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Container(color: PdfColors.white),
              );
            }
            return pw.SizedBox.shrink();
          },
        );
      case PdfColorScheme.dark:
        return pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(48),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
          buildBackground: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Container(color: const PdfColor.fromInt(0xFF1E1E1E)),
            );
          },
        );
      case PdfColorScheme.sepia:
        return pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(48),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
          buildBackground: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Container(color: const PdfColor.fromInt(0xFFF4ECD8)),
            );
          },
        );
    }
  }

  Future<String> _savePdf(Uint8List pdfData, String outputPath) async {
    final file = File(outputPath);
    await file.writeAsBytes(pdfData);
    return outputPath;
  }

  Future<int> _getPageCount(Uint8List pdfData) async {
    // Parse PDF to count pages
    try {
      // Simple page count estimation based on PDF structure
      final pdfString = String.fromCharCodes(pdfData);
      final pageMatches = '/Type /Page'.allMatches(pdfString);
      return pageMatches.isNotEmpty ? pageMatches.length : 1;
    } catch (e) {
      return 1; // Default to 1 if parsing fails
    }
  }
}
