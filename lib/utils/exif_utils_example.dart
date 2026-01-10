import 'dart:io';
import 'package:flutter/material.dart';
import 'exif_utils.dart';

/// Example demonstrating basic EXIF data extraction
void basicExifExtractionExample() async {
  // Load an image file
  final file = File('/path/to/your/photo.jpg');

  try {
    // Extract all EXIF data
    final exifData = await ExifUtils.extractExif(file);

    // Check if location data is available
    if (exifData.hasLocation) {
      print('Photo location: ${exifData.latitude}, ${exifData.longitude}');
      if (exifData.altitude != null) {
        print('Altitude: ${exifData.altitude} meters');
      }
    } else {
      print('No GPS location data found in photo');
    }

    // Check if date/time is available
    if (exifData.hasDateTime) {
      print('Photo taken: ${exifData.bestDateTime}');
    }

    // Display camera information
    if (exifData.make != null || exifData.model != null) {
      print('Camera: ${exifData.make} ${exifData.model}');
    }
  } catch (e) {
    print('Error extracting EXIF: $e');
  }
}

/// Example demonstrating travel journal integration
Future<void> travelJournalExample() async {
  final photoFile = File('/path/to/travel/photo.jpg');

  // Extract location and date for journal entry
  final exifData = await ExifUtils.extractExif(
    photoFile,
    config: ExifExtractionConfig.forTravelJournal,
  );

  // Use extracted data for journal entry
  final journalData = {
    'title': 'Beautiful Sunset',
    'content': 'Amazing view from the beach...',
    'date': exifData.bestDateTime ?? DateTime.now(),
    'location': exifData.hasLocation
        ? {
            'latitude': exifData.latitude,
            'longitude': exifData.longitude,
          }
        : null,
  };

  print('Journal entry created:');
  print('  Date: ${journalData['date']}');
  if (journalData['location'] != null) {
    final loc = journalData['location'] as Map<String, double?>;
    print('  Location: ${loc['latitude']}, ${loc['longitude']}');
  }
}

/// Example demonstrating selective extraction
Future<void> selectiveExtractionExample() async {
  final file = File('/path/to/photo.jpg');

  // Extract only location data (faster)
  final locationData = await ExifUtils.extractLocation(file);
  if (locationData.hasLocation) {
    print('GPS: ${locationData.latitude}, ${locationData.longitude}');
  }

  // Extract only date/time data
  final dateTimeData = await ExifUtils.extractDateTime(file);
  if (dateTimeData.bestDateTime != null) {
    print('Taken: ${dateTimeData.bestDateTime}');
  }
}

/// Example demonstrating custom configuration
Future<void> customConfigurationExample() async {
  final file = File('/path/to/photo.jpg');

  // Custom config: extract everything but throw on error
  const config = ExifExtractionConfig(
    extractLocation: true,
    extractDateTime: true,
    extractCameraInfo: true,
    extractDimensions: true,
    throwOnError: true,
  );

  try {
    final exifData = await ExifUtils.extractExif(file, config: config);

    // Access all available metadata
    print('Dimensions: ${exifData.imageWidth}x${exifData.imageHeight}');
    print('ISO: ${exifData.isoSpeed}');
    print('Focal Length: ${exifData.focalLength}mm');
    print('Aperture: f/${exifData.fNumber}');
    print('Exposure: ${exifData.exposureTime}s');
    print('Flash: ${exifData.flash}');
  } catch (e) {
    print('Failed to extract EXIF: $e');
  }
}

/// Example demonstrating error handling
Future<void> errorHandlingExample() async {
  final file = File('/path/to/invalid.jpg');

  // Approach 1: Don't throw, return empty data
  final exifData = await ExifUtils.extractExif(file);
  if (!exifData.hasLocation && !exifData.hasDateTime) {
    print('No EXIF data found (file might not have metadata)');
  }

  // Approach 2: Throw exception for explicit error handling
  try {
    final exifData = await ExifUtils.extractExif(
      file,
      config: const ExifExtractionConfig(throwOnError: true),
    );
    print('EXIF extracted successfully');
  } on ExifException catch (e) {
    print('EXIF extraction failed: ${e.message}');
    // Handle error appropriately
  }
}

/// Example demonstrating byte-based extraction
Future<void> byteBasedExtractionExample() async {
  // Example: extracting EXIF from image picker result
  final file = File('/path/to/picked/image.jpg');
  final bytes = await file.readAsBytes();

  // Extract EXIF directly from bytes (no file needed)
  final exifData = await ExifUtils.extractExifFromBytes(
    bytes,
    config: ExifExtractionConfig.forTravelJournal,
  );

  print('Extracted from bytes:');
  print('  Location: ${exifData.hasLocation ? "Yes" : "No"}');
  print('  DateTime: ${exifData.bestDateTime ?? "None"}');
}

/// Example demonstrating batch processing
Future<void> batchProcessingExample() async {
  final photoFiles = [
    File('/path/to/photo1.jpg'),
    File('/path/to/photo2.jpg'),
    File('/path/to/photo3.jpg'),
  ];

  final photosWithLocation = <Map<String, dynamic>>[];

  for (final file in photoFiles) {
    final exifData = await ExifUtils.extractExif(
      file,
      config: ExifExtractionConfig.forTravelJournal,
    );

    if (exifData.hasLocation) {
      photosWithLocation.add({
        'file': file.path,
        'latitude': exifData.latitude,
        'longitude': exifData.longitude,
        'date': exifData.bestDateTime,
      });
    }
  }

  print('Found ${photosWithLocation.length} photos with GPS data');
  for (final photo in photosWithLocation) {
    print('  ${photo['file']}: ${photo['latitude']}, ${photo['longitude']}');
  }
}

/// Example demonstrating image dimensions fallback
Future<void> imageDimensionsExample() async {
  final file = File('/path/to/photo.jpg');

  // Try to get dimensions from EXIF first
  final exifData = await ExifUtils.extractExif(file);

  if (exifData.imageWidth != null && exifData.imageHeight != null) {
    print(
        'Dimensions from EXIF: ${exifData.imageWidth}x${exifData.imageHeight}');
  } else {
    // Fallback to reading the actual image
    print('EXIF dimensions not available, reading image...');
    final dimensions = await ExifUtils.getImageDimensions(file);
    if (dimensions != null) {
      print(
          'Actual dimensions: ${dimensions['width']}x${dimensions['height']}');
    }
  }
}

/// Example demonstrating JSON serialization
Future<void> jsonSerializationExample() async {
  final file = File('/path/to/photo.jpg');
  final exifData = await ExifUtils.extractExif(file);

  // Convert to JSON for storage or transmission
  final json = exifData.toJson();
  print('JSON: $json');

  // Reconstruct from JSON
  final restored = ExifData.fromJson(json);
  print('Restored location: ${restored.latitude}, ${restored.longitude}');
  print('Restored date: ${restored.bestDateTime}');
}

/// Example Flutter widget demonstrating UI integration
class ExifWidgetExample extends StatefulWidget {
  const ExifWidgetExample({super.key});

  @override
  State<ExifWidgetExample> createState() => _ExifWidgetExampleState();
}

class _ExifWidgetExampleState extends State<ExifWidgetExample> {
  File? _selectedImage;
  ExifData? _exifData;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImageAndExtractExif() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate picking an image
      // In real app, use ImagePicker
      final file = File('/path/to/picked/image.jpg');

      // Extract EXIF data
      final exifData = await ExifUtils.extractExif(
        file,
        config: ExifExtractionConfig.forTravelJournal,
      );

      setState(() {
        _selectedImage = file;
        _exifData = exifData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load image: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EXIF Extraction Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _pickImageAndExtractExif,
              child: const Text('Pick Image & Extract EXIF'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red))
            else if (_exifData != null) ...[
              _buildInfoRow(
                  'Location',
                  _exifData!.hasLocation
                      ? '${_exifData!.latitude!.toStringAsFixed(6)}, ${_exifData!.longitude!.toStringAsFixed(6)}'
                      : 'Not available'),
              _buildInfoRow('Date',
                  _exifData!.bestDateTime?.toString() ?? 'Not available'),
              _buildInfoRow(
                  'Camera',
                  '${_exifData!.make ?? 'Unknown'} ${_exifData!.model ?? ''}'
                      .trim()),
              if (_exifData!.imageWidth != null &&
                  _exifData!.imageHeight != null)
                _buildInfoRow('Dimensions',
                    '${_exifData!.imageWidth}x${_exifData!.imageHeight}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// Main entry point for examples
void main() {
  print('=== EXIF Utils Examples ===\n');

  print('1. Basic EXIF Extraction:');
  basicExifExtractionExample();

  print('\n2. Travel Journal Integration:');
  travelJournalExample();

  print('\n3. Selective Extraction:');
  selectiveExtractionExample();

  print('\n4. Custom Configuration:');
  customConfigurationExample();

  print('\n5. Error Handling:');
  errorHandlingExample();

  print('\n6. Byte-based Extraction:');
  byteBasedExtractionExample();

  print('\n7. Batch Processing:');
  batchProcessingExample();

  print('\n8. Image Dimensions:');
  imageDimensionsExample();

  print('\n9. JSON Serialization:');
  jsonSerializationExample();

  print('\n=== End Examples ===');
}
