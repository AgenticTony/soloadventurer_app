import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/domain/services/pdf_export_service.dart';
import 'package:soloadventurer/features/journal/presentation/providers/pdf_export_providers.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/pdf_export_widget.dart';

/// Example 1: Basic Trip Export
///
/// Demonstrates the simplest way to export a trip to PDF
class Example1_BasicTripExport extends ConsumerWidget {
  const Example1_BasicTripExport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Export Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PdfExportWidget(
                    tripId: 'trip-123',
                    tripName: 'Summer Vacation 2024',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Tap the PDF icon to export this trip'),
      ),
    );
  }
}

/// Example 2: Export with Custom Configuration
///
/// Demonstrates using custom export settings
class Example2_CustomConfiguration extends ConsumerStatefulWidget {
  const Example2_CustomConfiguration({super.key});

  @override
  ConsumerState<Example2_CustomConfiguration> createState() =>
      _Example2_CustomConfigurationState();
}

class _Example2_CustomConfigurationState
    extends ConsumerState<Example2_CustomConfiguration> {
  PdfExportConfig _selectedConfig = PdfExportConfig.defaultConfig;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Configuration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quality selection
          Card(
            child: Column(
              children: [
                const ListTile(title: Text('Export Quality')),
                RadioListTile<PdfExportConfig>(
                  title: const Text('Standard'),
                  subtitle: const Text('Balanced quality and file size'),
                  value: PdfExportConfig.defaultConfig,
                  groupValue: _selectedConfig,
                  onChanged: (config) =>
                      setState(() => _selectedConfig = config!),
                ),
                RadioListTile<PdfExportConfig>(
                  title: const Text('High Quality'),
                  subtitle: const Text('Best quality, larger file size'),
                  value: PdfExportConfig.highQualityConfig,
                  groupValue: _selectedConfig,
                  onChanged: (config) =>
                      setState(() => _selectedConfig = config!),
                ),
                RadioListTile<PdfExportConfig>(
                  title: const Text('Compact'),
                  subtitle: const Text('Smaller file size for sharing'),
                  value: PdfExportConfig.compactConfig,
                  groupValue: _selectedConfig,
                  onChanged: (config) =>
                      setState(() => _selectedConfig = config!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Custom config builder
          Card(
            child: ListTile(
              title: const Text('Custom Configuration'),
              subtitle: const Text('Build your own export settings'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _showCustomConfigDialog(context),
            ),
          ),

          const SizedBox(height: 24),

          // Export button
          ElevatedButton.icon(
            onPressed: () => _startExport(context, ref),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export with Selected Config'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomConfigDialog(BuildContext context) {
    final customConfig = PdfExportConfig(
      pageMargin: 36.0,
      contentMargin: 20.0,
      titleFontSize: 32.0,
      headingFontSize: 24.0,
      bodyFontSize: 14.0,
      captionFontSize: 11.0,
      includeDates: true,
      includeLocations: true,
      includeMoods: false,
      includeMedia: true,
      maxImageWidth: 450.0,
      maxImageHeight: 350.0,
      imageQuality: 0.85,
      colorScheme: PdfColorScheme.sepia,
    );

    setState(() => _selectedConfig = customConfig);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom sepia configuration selected')),
    );
  }

  Future<void> _startExport(BuildContext context, WidgetRef ref) async {
    final exportNotifier = ref.read(pdfExportNotifierProvider.notifier);

    await exportNotifier.exportTrip(
      tripId: 'trip-123',
      config: _selectedConfig,
    );

    if (!mounted) return;

    final exportState = ref.read(pdfExportNotifierProvider);

    if (exportState.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Export successful! File size: ${exportState.result?.fileSizeReadable}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (exportState.isFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${exportState.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Example 3: Export with Progress Tracking
///
/// Demonstrates detailed progress monitoring
class Example3_ProgressTracking extends ConsumerStatefulWidget {
  const Example3_ProgressTracking({super.key});

  @override
  ConsumerState<Example3_ProgressTracking> createState() =>
      _Example3ProgressTrackingState();
}

class _Example3ProgressTrackingState extends ConsumerState<Example3_ProgressTracking> {
  @override
  Widget build(BuildContext context) {
    final exportState = ref.watch(pdfExportNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (exportState.isIdle)
              ElevatedButton.icon(
                onPressed: () => _startExport(ref),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Export'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            if (exportState.isExporting) _buildProgressCard(exportState),
            if (exportState.isSuccess) _buildSuccessCard(exportState),
            if (exportState.isFailed) _buildErrorCard(exportState),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(PdfExportState state) {
    return Card(
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 24),
            Text(
              _getStageLabel(state.stage),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: state.progress,
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            Text(
              '${(state.progress * 100).toStringAsFixed(1)}% Complete',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (state.totalEntries > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Entry ${state.currentEntry} of ${state.totalEntries}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard(PdfExportState state) {
    return Card(
      margin: const EdgeInsets.all(24),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Export Complete!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow('Pages', '${state.result?.pageCount ?? 0}'),
            _buildStatRow('Entries', '${state.result?.entryCount ?? 0}'),
            _buildStatRow('File Size', state.result?.fileSizeReadable ?? ''),
            if (state.exportDuration != null)
              _buildStatRow('Duration', _formatDuration(state.exportDuration!)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(pdfExportNotifierProvider.notifier).reset(),
              icon: const Icon(Icons.refresh),
              label: const Text('Export Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(PdfExportState state) {
    return Card(
      margin: const EdgeInsets.all(24),
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Export Failed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              state.error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(pdfExportNotifierProvider.notifier).reset(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _startExport(WidgetRef ref) async {
    await ref.read(pdfExportNotifierProvider.notifier).exportTrip(
          tripId: 'trip-123',
          config: PdfExportConfig.defaultConfig,
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

/// Example 4: Export Statistics and Estimation
///
/// Demonstrates getting export stats before exporting
class Example4_ExportStatistics extends ConsumerWidget {
  const Example4_ExportStatistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportStats = ref.watch(pdfExportStatsProvider('trip-123'));
    final estimatedSize = ref.watch(estimatedPdfSizeProvider('trip-123'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          exportStats.when(
            data: (stats) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Contents',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow(context, 'Journal Entries', '${stats['entryCount']}'),
                    _buildStatRow(context, 'Media Items', '${stats['totalMediaCount']}'),
                    _buildStatRow(context, 'Photos', '${stats['photoCount']}'),
                    _buildStatRow(context, 'Videos', '${stats['videoCount']}'),
                    _buildStatRow(context, 'Total Words', '${stats['wordCount']}'),
                  ],
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
          ),
          const SizedBox(height: 16),
          estimatedSize.when(
            data: (size) => Card(
              child: ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Estimated File Size'),
                subtitle: Text(_formatFileSize(size)),
                trailing: _getSizeBadge(size),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PdfExportWidget(
                    tripId: 'trip-123',
                    tripName: 'Sample Trip',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Proceed to Export'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _getSizeBadge(int bytes) {
    final mb = bytes / (1024 * 1024);
    Color color;
    String label;

    if (mb < 5) {
      color = Colors.green;
      label = 'Small';
    } else if (mb < 20) {
      color = Colors.orange;
      label = 'Medium';
    } else {
      color = Colors.red;
      label = 'Large';
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.2),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Example 5: Export Multiple Entries
///
/// Demonstrates exporting specific entries rather than entire trips
class Example5_MultipleEntries extends ConsumerStatefulWidget {
  const Example5_MultipleEntries({super.key});

  @override
  ConsumerState<Example5_MultipleEntries> createState() =>
      _Example5MultipleEntriesState();
}

class _Example5MultipleEntriesState extends ConsumerState<Example5_MultipleEntries> {
  final Set<String> _selectedEntries = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Entries to Export'),
        actions: [
          if (_selectedEntries.isNotEmpty)
            TextButton.icon(
              onPressed: _selectedEntries.isEmpty
                  ? null
                  : () => _exportSelected(context, ref),
              icon: const Icon(Icons.picture_as_pdf),
              label: Text('Export (${_selectedEntries.length})'),
            ),
        ],
      ),
      body: ListView(
        children: [
          _buildEntryTile('Entry 1: Arrival in Paris', 'entry-1'),
          _buildEntryTile('Entry 2: Eiffel Tower Visit', 'entry-2'),
          _buildEntryTile('Entry 3: Louvre Museum', 'entry-3'),
          _buildEntryTile('Entry 4: Seine River Cruise', 'entry-4'),
          _buildEntryTile('Entry 5: Departure', 'entry-5'),
        ],
      ),
    );
  }

  Widget _buildEntryTile(String title, String entryId) {
    final isSelected = _selectedEntries.contains(entryId);

    return CheckboxListTile(
      title: Text(title),
      value: isSelected,
      onChanged: (checked) {
        setState(() {
          if (checked == true) {
            _selectedEntries.add(entryId);
          } else {
            _selectedEntries.remove(entryId);
          }
        });
      },
    );
  }

  Future<void> _exportSelected(BuildContext context, WidgetRef ref) async {
    await ref.read(pdfExportNotifierProvider.notifier).exportEntries(
          entryIds: _selectedEntries.toList(),
          config: PdfExportConfig.defaultConfig,
        );

    if (!mounted) return;

    final exportState = ref.read(pdfExportNotifierProvider);

    if (exportState.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exported ${_selectedEntries.length} entries successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// Example 6: Export Menu Screen
///
/// Main menu showing all export examples
class PdfExportExamplesMenu extends StatelessWidget {
  const PdfExportExamplesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Export Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExampleCard(
            context,
            title: 'Basic Trip Export',
            description: 'Simple export with default settings',
            icon: Icons.flight_takeoff,
            target: const Example1_BasicTripExport(),
          ),
          _buildExampleCard(
            context,
            title: 'Custom Configuration',
            description: 'Choose quality and color scheme',
            icon: Icons.tune,
            target: const Example2_CustomConfiguration(),
          ),
          _buildExampleCard(
            context,
            title: 'Progress Tracking',
            description: 'Monitor export progress in detail',
            icon: Icons.analytics,
            target: const Example3_ProgressTracking(),
          ),
          _buildExampleCard(
            context,
            title: 'Export Statistics',
            description: 'View stats before exporting',
            icon: Icons.bar_chart,
            target: const Example4_ExportStatistics(),
          ),
          _buildExampleCard(
            context,
            title: 'Multiple Entries',
            description: 'Select specific entries to export',
            icon: Icons.checklist,
            target: const Example5_MultipleEntries(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Widget target,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => target),
          );
        },
      ),
    );
  }
}
