# PDF Export Service

Comprehensive PDF export functionality for travel journal trips and entries, featuring customizable layouts, media embedding, progress tracking, and multiple export quality options.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Architecture](#architecture)
- [Usage Examples](#usage-examples)
- [API Reference](#api-reference)
- [Configuration Options](#configuration-options)
- [Error Handling](#error-handling)
- [Performance Considerations](#performance-considerations)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## Overview

The PDF Export Service provides a complete solution for exporting travel journal trips and entries to beautifully formatted PDF documents. It supports:

- Full trip export with all entries and media
- Single entry export
- Multiple entries export
- Customizable layouts and styling
- Multiple quality presets (standard, high quality, compact)
- Progress tracking with detailed stages
- File size estimation
- Export statistics
- Multiple color schemes (light, dark, sepia)

## Features

### Core Features

✅ **Complete Trip Export**: Export entire trips with all journal entries, media, and metadata
✅ **Flexible Entry Selection**: Export all entries, specific entries, or single entries
✅ **Media Embedding**: Include photos and videos in the PDF
✅ **Customizable Layouts**: Control margins, fonts, colors, and styling
✅ **Progress Tracking**: Real-time progress updates with detailed stage information
✅ **Quality Presets**: Choose between standard, high quality, or compact exports
✅ **Color Schemes**: Light mode, dark mode, and sepia tone options
✅ **File Size Estimation**: Get accurate estimates before exporting
✅ **Export Statistics**: View detailed stats about entries, media, and content
✅ **Error Handling**: Comprehensive error handling with detailed messages

### Advanced Features

✅ **Incremental Generation**: Generate PDFs page-by-page for large trips
✅ **Preview Generation**: Generate previews with limited pages
✅ **Media Validation**: Check if media files are available before export
✅ **Metadata Inclusion**: Include dates, locations, moods, and other metadata
✅ **Smart Formatting**: Automatic date formatting, location display, and content rendering
✅ **Responsive Layouts**: PDFs adapt to different content lengths and media sizes
✅ **Background Export**: Export operations run asynchronously without blocking UI

## Installation

### 1. Add Dependencies

The required dependencies are already included in `pubspec.yaml`:

```yaml
dependencies:
  pdf: ^3.10.7
  printing: ^5.11.1
  path_provider: ^2.1.1
  intl: ^0.19.0
```

### 2. Import the Service

```dart
import 'package:soloadventurer/features/journal/domain/services/pdf_export_service.dart';
import 'package:soloadventurer/features/journal/data/services/pdf_export_service_impl.dart';
import 'package:soloadventurer/features/journal/presentation/providers/pdf_export_providers.dart';
```

### 3. Initialize the Service

The service is automatically initialized through the Riverpod provider:

```dart
final pdfExportService = ref.read(pdfExportServiceProvider);
```

## Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (PDF Export Widget, Providers)         │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          Domain Layer                   │
│  (PdfExportService Interface)           │
│  - PdfExportConfig                      │
│  - PdfExportResult                      │
│  - PdfExportProgress                    │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           Data Layer                    │
│  (PdfExportServiceImpl)                 │
│  - PDF Generation Logic                 │
│  - Media Processing                     │
│  - File I/O Operations                  │
└─────────────────────────────────────────┘
```

### Key Components

1. **PdfExportService** (Domain Interface): Defines the contract for PDF export operations
2. **PdfExportServiceImpl** (Implementation): Concrete implementation with PDF generation logic
3. **PdfExportNotifier** (State Management): Riverpod notifier for managing export state
4. **PdfExportWidget** (UI): User interface for triggering and monitoring exports

## Usage Examples

### Example 1: Export a Complete Trip

```dart
// In a widget or use case
final exportNotifier = ref.read(pdfExportNotifierProvider.notifier);

// Start export with default settings
await exportNotifier.exportTrip(
  tripId: 'trip-123',
);

// Or with custom settings
await exportNotifier.exportTrip(
  tripId: 'trip-123',
  config: PdfExportConfig.highQualityConfig,
  outputPath: '/path/to/save/trip-export.pdf',
);

// Listen to progress
ref.listen<PdfExportState>(
  pdfExportNotifierProvider,
  (previous, next) {
    print('Progress: ${(next.progress * 100).toStringAsFixed(0)}%');
    print('Stage: ${next.stage}');
    if (next.isSuccess) {
      print('Export successful! File size: ${next.result?.fileSizeReadable}');
    } else if (next.isFailed) {
      print('Export failed: ${next.error}');
    }
  },
);
```

### Example 2: Export a Single Entry

```dart
final exportNotifier = ref.read(pdfExportNotifierProvider.notifier);

await exportNotifier.exportEntry(
  entryId: 'entry-456',
  config: PdfExportConfig.defaultConfig,
);
```

### Example 3: Export Multiple Entries

```dart
final exportNotifier = ref.read(pdfExportNotifierProvider.notifier);

await exportNotifier.exportEntries(
  entryIds: ['entry-1', 'entry-2', 'entry-3'],
  config: PdfExportConfig.compactConfig, // Smaller file size
);
```

### Example 4: Using the PDF Export Widget

```dart
class TripDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfExportWidget(
                    tripId: 'trip-123',
                    tripName: 'Summer Vacation 2024',
                    onExportComplete: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PDF exported successfully!')),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: /* trip content */,
    );
  }
}
```

### Example 5: Custom Export Configuration

```dart
final customConfig = PdfExportConfig(
  pageMargin: 36.0,
  contentMargin: 20.0,
  titleFontSize: 32.0,
  headingFontSize: 24.0,
  bodyFontSize: 14.0,
  captionFontSize: 11.0,
  includeDates: true,
  includeLocations: true,
  includeMoods: false, // Exclude moods
  includeMedia: true,
  maxImageWidth: 500.0,
  maxImageHeight: 400.0,
  imageQuality: 0.9,
  colorScheme: PdfColorScheme.sepia, // Vintage look
);

await exportNotifier.exportTrip(
  tripId: 'trip-123',
  config: customConfig,
);
```

### Example 6: Get Export Statistics

```dart
final stats = await ref.read(pdfExportStatsProvider('trip-123').future);

print('Entries: ${stats['entryCount']}');
print('Media: ${stats['totalMediaCount']}');
print('Words: ${stats['wordCount']}');
print('Est. Size: ${stats['estimatedFileSize']}');
```

### Example 7: Estimate File Size Before Export

```dart
final estimatedSize = await ref.read(estimatedPdfSizeProvider('trip-123').future);

print('Estimated file size: ${(estimatedSize / 1024 / 1024).toStringAsFixed(2)} MB');
```

### Example 8: Generate Preview

```dart
final service = ref.read(pdfExportServiceProvider);

final previewResult = await service.generatePreview(
  trip: trip,
  entries: entries,
  maxPages: 3, // Only first 3 pages
);

// Use preview for showing user what the PDF will look like
```

### Example 9: Direct Service Usage (Without Provider)

```dart
final journalRepository = ref.read(journalRepositoryProvider);
final tripRepository = ref.read(tripRepositoryProvider);

final service = PdfExportServiceImpl(
  journalRepository: journalRepository,
  tripRepository: tripRepository,
);

// Perform export with progress callback
final result = await service.exportTripToPdf(
  trip: trip,
  entries: entries,
  config: PdfExportConfig.defaultConfig,
  onProgress: (progress) {
    print('Progress: ${progress.stage} - ${(progress.progress * 100).toStringAsFixed(0)}%');
  },
);

if (result.success) {
  print('PDF generated successfully!');
  print('Pages: ${result.pageCount}');
  print('File size: ${result.fileSizeReadable}');
} else {
  print('Export failed: ${result.error}');
}
```

### Example 10: Validate Media Availability

```dart
final service = ref.read(pdfExportServiceProvider);

// Check if all media files are available
final missingMedia = await service.validateMediaAvailability(entries);

if (missingMedia.isNotEmpty) {
  print('Warning: ${missingMedia.length} media files are missing');
  // Show warning to user
  for (final path in missingMedia) {
    print('Missing: $path');
  }
}
```

## API Reference

### PdfExportService Interface

#### Methods

##### `exportTripToPdf()`

Export a complete trip to PDF.

```dart
Future<PdfExportResult> exportTripToPdf({
  required Trip trip,
  List<JournalEntry>? entries,
  PdfExportConfig? config,
  PdfExportProgressCallback? onProgress,
  String? outputPath,
})
```

**Parameters:**
- `trip` (required): The trip to export
- `entries`: Optional list of entries to include (null = all entries)
- `config`: Export configuration options
- `onProgress`: Optional callback for progress updates
- `outputPath`: Optional file path to save PDF

**Returns:** `Future<PdfExportResult>`

##### `exportEntryToPdf()`

Export a single journal entry to PDF.

```dart
Future<PdfExportResult> exportEntryToPdf({
  required JournalEntry entry,
  PdfExportConfig? config,
  PdfExportProgressCallback? onProgress,
  String? outputPath,
})
```

##### `exportEntriesToPdf()`

Export multiple entries to PDF.

```dart
Future<PdfExportResult> exportEntriesToPdf({
  required List<JournalEntry> entries,
  PdfExportConfig? config,
  PdfExportProgressCallback? onProgress,
  String? outputPath,
})
```

##### `generatePreview()`

Generate a preview with limited pages.

```dart
Future<PdfExportResult> generatePreview({
  required Trip trip,
  List<JournalEntry>? entries,
  PdfExportConfig? config,
  int maxPages = 3,
})
```

##### `estimateFileSize()`

Get estimated file size before export.

```dart
int estimateFileSize({
  required int entryCount,
  required int mediaCount,
  PdfExportConfig? config,
})
```

**Returns:** Estimated size in bytes

##### `getExportStats()`

Get export statistics for a trip.

```dart
Future<Map<String, dynamic>> getExportStats({
  required Trip trip,
  List<JournalEntry>? entries,
})
```

**Returns:** Map with keys:
- `entryCount`: Number of entries
- `totalMediaCount`: Total media items
- `photoCount`: Number of photos
- `videoCount`: Number of videos
- `wordCount`: Total word count
- `estimatedFileSize`: Estimated size in bytes

##### `validateMediaAvailability()`

Check if media files are available.

```dart
Future<List<String>> validateMediaAvailability(List<JournalEntry> entries)
```

**Returns:** List of missing media file paths (empty if all available)

### PdfExportConfig

Configuration options for PDF export.

```dart
class PdfExportConfig {
  final double pageMargin;          // Page margin in points
  final double contentMargin;        // Content margin in points
  final double titleFontSize;        // Title font size
  final double headingFontSize;      // Heading font size
  final double bodyFontSize;         // Body font size
  final double captionFontSize;      // Caption font size
  final bool includeDates;           // Include entry dates
  final bool includeLocations;       // Include location info
  final bool includeMoods;           // Include mood indicators
  final bool includeMedia;           // Include media items
  final double maxImageWidth;        // Max image width in points
  final double maxImageHeight;       // Max image height in points
  final double imageQuality;         // Image quality (0.0 to 1.0)
  final PdfColorScheme colorScheme;  // Color scheme
}
```

#### Presets

- `PdfExportConfig.defaultConfig`: Standard quality, balanced settings
- `PdfExportConfig.highQualityConfig`: Best quality, larger file size
- `PdfExportConfig.compactConfig`: Smaller file size, lower quality

### PdfExportResult

Result of a PDF export operation.

```dart
class PdfExportResult {
  final bool success;           // Whether export succeeded
  final Uint8List? pdfData;     // PDF data
  final int pageCount;          // Number of pages
  final int entryCount;         // Number of entries
  final int mediaCount;         // Number of media items
  final String? error;          // Error message if failed
  final String? filePath;       // File path if saved
  final int? fileSize;          // File size in bytes
  final String get fileSizeReadable; // Human-readable size
}
```

### PdfExportProgress

Progress information during export.

```dart
class PdfExportProgress {
  final PdfExportStage stage;       // Current stage
  final double progress;            // Progress (0.0 to 1.0)
  final int currentEntry;           // Current entry index
  final int totalEntries;           // Total entries
  final int currentMedia;           // Current media index
  final int totalMedia;             // Total media items
}
```

#### Export Stages

- `initializing`: Setting up export
- `loadingData`: Loading trip and entry data
- `loadingMedia`: Loading media files
- `generatingPages`: Creating PDF pages
- `finalizing`: Finalizing document
- `saving`: Saving to disk
- `completed`: Export finished
- `failed`: Export failed

## Configuration Options

### Quality Presets Comparison

| Setting | Standard | High Quality | Compact |
|---------|----------|--------------|---------|
| Page Margin | 48pt | 48pt | 36pt |
| Title Font | 28pt | 28pt | 24pt |
| Body Font | 12pt | 12pt | 11pt |
| Max Image Width | 400pt | 500pt | 300pt |
| Max Image Height | 300pt | 400pt | 200pt |
| Image Quality | 85% | 95% | 70% |
| Include Moods | Yes | Yes | No |
| Est. Size (per entry) | ~70KB | ~120KB | ~40KB |

### Color Schemes

#### Light Mode (Default)
- White background
- Black text
- Best for printing
- Most readable

#### Dark Mode
- Dark gray background (#1E1E1E)
- Light text
- Good for screen viewing
- Saves ink

#### Sepia Mode
- Warm beige background (#F4ECD8)
- Brown-tinted text
- Vintage, book-like appearance
- Easy on the eyes

## Error Handling

### Common Errors and Solutions

#### `PdfExportException`

Thrown when PDF generation fails.

```dart
try {
  await exportNotifier.exportTrip(tripId: 'trip-123');
} catch (e) {
  if (e is PdfExportException) {
    print('PDF export failed: ${e.message}');
    // Show error to user
  }
}
```

#### Missing Media Files

```dart
final missingMedia = await service.validateMediaAvailability(entries);
if (missingMedia.isNotEmpty) {
  // Warn user that some media will be missing
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Missing Media'),
      content: Text('${missingMedia.length} media files could not be found. Continue anyway?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Proceed with export
          },
          child: const Text('Continue'),
        ),
      ],
    ),
  );
}
```

#### Out of Memory Errors

For very large trips, consider:
- Exporting in batches
- Using the `compact` quality preset
- Excluding some media items
- Generating a preview first

## Performance Considerations

### Optimization Tips

1. **Use Compact Quality for Large Trips**
   ```dart
   config: PdfExportConfig.compactConfig
   ```

2. **Exclude Unnecessary Content**
   ```dart
   config: PdfExportConfig(
     includeMoods: false,
     includeMedia: false, // Text only
   )
   ```

3. **Generate Preview First**
   ```dart
   final preview = await service.generatePreview(
     trip: trip,
     maxPages: 3,
   );
   ```

4. **Monitor Progress**
   Always use progress callbacks for long exports:
   ```dart
   onProgress: (progress) {
     print('${(progress.progress * 100).toStringAsFixed(0)}%');
   }
   ```

### File Size Guidelines

- Small trip (1-5 entries, few photos): ~500KB - 2MB
- Medium trip (6-20 entries, moderate photos): ~2MB - 10MB
- Large trip (21+ entries, many photos): ~10MB - 50MB+
- Use `compact` preset to reduce sizes by ~40%
- Use `highQuality` preset to increase sizes by ~70%

## Testing

### Unit Tests

```dart
test('estimates file size correctly', () {
  final service = PdfExportServiceImpl(
    journalRepository: mockJournalRepo,
    tripRepository: mockTripRepo,
  );

  final estimatedSize = service.estimateFileSize(
    entryCount: 10,
    mediaCount: 5,
    config: PdfExportConfig.defaultConfig,
  );

  expect(estimatedSize, greaterThan(0));
  expect(estimatedSize, lessThan(10 * 1024 * 1024)); // Less than 10MB
});
```

### Widget Tests

```dart
testWidgets('shows export progress', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: PdfExportWidget(
          tripId: 'test-trip',
          tripName: 'Test Trip',
        ),
      ),
    ),
  );

  expect(find.text('Export PDF'), findsOneWidget);

  // Tap export button
  await tester.tap(find.text('Export PDF'));
  await tester.pump();

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### Integration Tests

```dart
testWidgets('exports trip successfully', (tester) async {
  // Setup test data
  final testTrip = Trip(/* ... */);
  final testEntries = [/* ... */];

  // Perform export
  final result = await service.exportTripToPdf(
    trip: testTrip,
    entries: testEntries,
  );

  expect(result.success, true);
  expect(result.pdfData, isNotNull);
  expect(result.pageCount, greaterThan(0));
});
```

## Troubleshooting

### Issue: PDF generation is slow

**Solution:**
- Use `PdfExportConfig.compactConfig`
- Reduce `maxImageWidth` and `maxImageHeight`
- Lower `imageQuality`
- Exclude non-essential media

### Issue: PDF file is too large

**Solution:**
```dart
config: PdfExportConfig(
  imageQuality: 0.7, // Lower quality
  maxImageWidth: 300.0,
  maxImageHeight: 200.0,
)
```

### Issue: Images are not appearing in PDF

**Solution:**
- Check if media files are available: `validateMediaAvailability()`
- Verify network connectivity for remote images
- Check file permissions
- Review error messages in `PdfExportResult.error`

### Issue: Text is cut off

**Solution:**
```dart
config: PdfExportConfig(
  pageMargin: 60.0, // Increase margins
  bodyFontSize: 11.0, // Smaller font
)
```

### Issue: Export fails with memory error

**Solution:**
- Export fewer entries at a time
- Use compact quality
- Close other apps to free memory
- Consider implementing pagination

## Related Components

- **Media Upload Service**: For managing media uploads before export
- **Trip Repository**: For loading trip data
- **Journal Repository**: For loading entry data
- **Offline Storage**: For accessing cached media

## Future Enhancements

- [ ] Add custom fonts support
- [ ] Include video thumbnails with play icons
- [ ] Add table of contents
- [ ] Support for bookmarks/links
- [ ] Embed trip map visualization
- [ ] Add watermarking option
- [ ] Support for password-protected PDFs
- [ ] Batch export multiple trips
- [ ] Email PDF directly from app
- [ ] Cloud storage integration (Drive, Dropbox)
