import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/pdf_export_service.dart';
import '../providers/pdf_export_providers.dart';

/// Widget for exporting a trip to PDF
class PdfExportWidget extends ConsumerStatefulWidget {
  final String tripId;
  final String tripName;
  final VoidCallback? onExportComplete;

  const PdfExportWidget({
    super.key,
    required this.tripId,
    required this.tripName,
    this.onExportComplete,
  });

  @override
  ConsumerState<PdfExportWidget> createState() => _PdfExportWidgetState();
}

class _PdfExportWidgetState extends ConsumerState<PdfExportWidget> {
  PdfExportConfig? _selectedConfig;

  @override
  Widget build(BuildContext context) {
    final exportState = ref.watch(pdfExportNotifierProvider);
    final exportStats = ref.watch(pdfExportStatsProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export to PDF'),
        actions: [
          if (exportState.isSuccess)
            TextButton.icon(
              onPressed: () => _sharePdf(context, exportState.result!),
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trip info card
          _buildTripInfoCard(context),
          const SizedBox(height: 24),

          // Export stats
          exportStats.when(
            data: (stats) => _ExportStatsCard(stats: stats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => _buildErrorCard(err.toString()),
          ),
          const SizedBox(height: 24),

          // Configuration options
          _ConfigSection(
            selectedConfig: _selectedConfig,
            onConfigChanged: (config) {
              setState(() {
                _selectedConfig = config;
              });
            },
          ),
          const SizedBox(height: 24),

          // Export button
          if (!exportState.isExporting)
            _buildExportButton(context, exportState)
          else
            _buildProgressCard(exportState),

          // Result section
          if (exportState.isSuccess) _buildSuccessCard(exportState),

          // Error section
          if (exportState.isFailed) _buildFailureCard(exportState),
        ],
      ),
    );
  }

  Widget _buildTripInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip: ${widget.tripName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This will export all journal entries and media from this trip to a PDF document.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text('Error: $error')),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(BuildContext context, PdfExportState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: state.isIdle || state.isFailed ? _startExport : null,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Export PDF'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildProgressCard(PdfExportState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStageLabel(state.stage),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(state.progress * 100).toStringAsFixed(0)}% complete',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (state.totalEntries > 0) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: state.progress,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 8),
              Text(
                'Entry ${state.currentEntry} of ${state.totalEntries}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard(PdfExportState state) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                Text(
                  'Export Successful!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.green[900],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow('Pages', '${state.result?.pageCount ?? 0}'),
            _buildStatRow('Entries', '${state.result?.entryCount ?? 0}'),
            _buildStatRow('Media items', '${state.result?.mediaCount ?? 0}'),
            _buildStatRow('File size', state.result?.fileSizeReadable ?? 'Unknown'),
            if (state.exportDuration != null)
              _buildStatRow('Duration', _formatDuration(state.exportDuration!)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sharePdf(context, state.result!),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ref.read(pdfExportNotifierProvider.notifier).reset(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailureCard(PdfExportState state) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Export Failed',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.red[900],
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              state.error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red[700],
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(pdfExportNotifierProvider.notifier).clearError();
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _startExport() async {
    final outputPath = await ref.read(defaultPdfPathProvider(widget.tripName).future);
    await ref.read(pdfExportNotifierProvider.notifier).exportTrip(
          tripId: widget.tripId,
          config: _selectedConfig,
          outputPath: outputPath,
        );

    if (mounted && widget.onExportComplete != null) {
      widget.onExportComplete!();
    }
  }

  void _sharePdf(BuildContext context, PdfExportResult result) {
    // Show sharing options
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  String _getStageLabel(PdfExportStage? stage) {
    switch (stage) {
      case PdfExportStage.initializing:
        return 'Initializing...';
      case PdfExportStage.loadingData:
        return 'Loading entries...';
      case PdfExportStage.loadingMedia:
        return 'Loading media...';
      case PdfExportStage.generatingPages:
        return 'Generating PDF pages...';
      case PdfExportStage.finalizing:
        return 'Finalizing...';
      case PdfExportStage.saving:
        return 'Saving PDF...';
      case PdfExportStage.completed:
        return 'Completed!';
      case PdfExportStage.failed:
        return 'Failed';
      case null:
        return 'Preparing...';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else {
      return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }
}

class _ExportStatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _ExportStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Contents',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildStatRow(context, 'Journal Entries', '${stats['entryCount'] ?? 0}'),
            _buildStatRow(context, 'Media Items', '${stats['totalMediaCount'] ?? 0}'),
            _buildStatRow(context, 'Total Words', '${stats['wordCount'] ?? 0}'),
            _buildStatRow(
              context,
              'Est. File Size',
              _formatFileSize(stats['estimatedFileSize'] ?? 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _ConfigSection extends StatelessWidget {
  final PdfExportConfig? selectedConfig;
  final ValueChanged<PdfExportConfig> onConfigChanged;

  const _ConfigSection({
    required this.selectedConfig,
    required this.onConfigChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Quality',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            RadioListTile<PdfExportConfig>(
              title: const Text('Standard'),
              subtitle: const Text('Balanced quality and file size'),
              value: PdfExportConfig.defaultConfig,
              groupValue: selectedConfig,
              onChanged: (config) => onConfigChanged(config!),
            ),
            RadioListTile<PdfExportConfig>(
              title: const Text('High Quality'),
              subtitle: const Text('Best quality, larger file size'),
              value: PdfExportConfig.highQualityConfig,
              groupValue: selectedConfig,
              onChanged: (config) => onConfigChanged(config!),
            ),
            RadioListTile<PdfExportConfig>(
              title: const Text('Compact'),
              subtitle: const Text('Smaller file size, good for sharing'),
              value: PdfExportConfig.compactConfig,
              groupValue: selectedConfig,
              onChanged: (config) => onConfigChanged(config!),
            ),
          ],
        ),
      ),
    );
  }
}
