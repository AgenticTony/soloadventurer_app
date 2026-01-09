# EXIF Utils

A comprehensive Flutter utility for extracting EXIF metadata from images. Extract GPS location, date/time, camera information, and other metadata from JPEG and TIFF images.

## Features

- ✅ Extract GPS coordinates (latitude, longitude, altitude)
- ✅ Extract date/time information (original, digitized, modified)
- ✅ Extract camera metadata (make, model, ISO, aperture, etc.)
- ✅ Extract image dimensions from EXIF or actual file
- ✅ Configurable extraction options
- ✅ Support for File and Uint8List inputs
- ✅ Predefined configurations for common use cases
- ✅ JSON serialization for data persistence
- ✅ Comprehensive error handling
- ✅ Optimized for travel journal workflows

## Installation

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  exif: ^0.3.0
  image: ^4.1.7
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:your_app/utils/exif_utils.dart';
import 'dart:io';

// Extract EXIF data from an image file
final file = File('/path/to/photo.jpg');
final exifData = await ExifUtils.extractExif(file);

if (exifData.hasLocation) {
  print('Photo taken at: ${exifData.latitude}, ${exifData.longitude}');
}

if (exifData.bestDateTime != null) {
  print('Photo taken on: ${exifData.bestDateTime}');
}
```

## Usage Examples

### 1. Basic EXIF Extraction

Extract all available metadata from an image:

```dart
final file = File('/path/to/photo.jpg');
final exifData = await ExifUtils.extractExif(file);

// Access location data
if (exifData.hasLocation) {
  print('Latitude: ${exifData.latitude}');
  print('Longitude: ${exifData.longitude}');
  print('Altitude: ${exifData.altitude} meters');
}

// Access date/time data
if (exifData.hasDateTime) {
  print('Date taken: ${exifData.bestDateTime}');
  print('Original: ${exifData.dateTimeOriginal}');
  print('Digitized: ${exifData.dateTimeDigitized}');
}

// Access camera information
if (exifData.make != null) {
  print('Camera: ${exifData.make} ${exifData.model}');
  print('ISO: ${exifData.isoSpeed}');
  print('Focal length: ${exifData.focalLength}mm');
  print('Aperture: f/${exifData.fNumber}');
}
```

### 2. Travel Journal Integration

Extract location and date for journal entries:

```dart
final photoFile = File('/path/to/travel/photo.jpg');

// Use predefined config for travel journals
final exifData = await ExifUtils.extractExif(
  photoFile,
  config: ExifExtractionConfig.forTravelJournal,
);

// Create journal entry with extracted data
final journalEntry = {
  'title': 'Beautiful Sunset',
  'content': 'Amazing view from the beach...',
  'date': exifData.bestDateTime ?? DateTime.now(),
  'location': exifData.hasLocation ? {
    'latitude': exifData.latitude,
    'longitude': exifData.longitude,
    'accuracy': null, // GPS from photos typically doesn't have accuracy
  } : null,
};

// Save to database...
```

### 3. Selective Extraction

Extract only specific data types for better performance:

```dart
final file = File('/path/to/photo.jpg');

// Extract only location (faster)
final locationData = await ExifUtils.extractLocation(file);
if (locationData.hasLocation) {
  print('GPS: ${locationData.latitude}, ${locationData.longitude}');
}

// Extract only date/time
final dateTimeData = await ExifUtils.extractDateTime(file);
if (dateTimeData.bestDateTime != null) {
  print('Taken: ${dateTimeData.bestDateTime}');
}
```

### 4. Custom Configuration

Configure what to extract:

```dart
final config = ExifExtractionConfig(
  extractLocation: true,
  extractDateTime: true,
  extractCameraInfo: true,  // Include camera metadata
  extractDimensions: true,   // Include image size
  throwOnError: false,       // Don't throw on errors
);

final exifData = await ExifUtils.extractExif(
  file,
  config: config,
);
```

### 5. Byte-based Extraction

Extract EXIF from image bytes without file I/O:

```dart
// From ImagePicker or network request
final bytes = await pickedFile.readAsBytes();

final exifData = await ExifUtils.extractExifFromBytes(
  bytes,
  config: ExifExtractionConfig.forTravelJournal,
);

print('Location: ${exifData.hasLocation ? "Yes" : "No"}');
print('Date: ${exifData.bestDateTime}');
```

### 6. Batch Processing

Process multiple photos efficiently:

```dart
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
```

### 7. Image Dimensions Fallback

Get dimensions from EXIF or actual image:

```dart
final file = File('/path/to/photo.jpg');
final exifData = await ExifUtils.extractExif(file);

if (exifData.imageWidth != null && exifData.imageHeight != null) {
  print('Dimensions from EXIF: ${exifData.imageWidth}x${exifData.imageHeight}');
} else {
  // Fallback to reading the actual image
  final dimensions = await ExifUtils.getImageDimensions(file);
  if (dimensions != null) {
    print('Actual dimensions: ${dimensions['width']}x${dimensions['height']}');
  }
}
```

### 8. JSON Serialization

Serialize EXIF data for storage or transmission:

```dart
final exifData = await ExifUtils.extractExif(file);

// Convert to JSON
final json = exifData.toJson();
await prefs.setString('exif_data', jsonEncode(json));

// Restore from JSON
final restored = ExifData.fromJson(jsonDecode(prefs.getString('exif_data')!));
print('Restored: ${restored.latitude}, ${restored.longitude}');
```

### 9. Error Handling

Handle errors gracefully:

```dart
// Approach 1: Silent failure (returns empty ExifData)
final exifData = await ExifUtils.extractExif(file);
if (!exifData.hasLocation && !exifData.hasDateTime) {
  print('No EXIF data found');
}

// Approach 2: Explicit error handling
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
```

### 10. Check if File Has EXIF

Verify if a file likely contains EXIF data:

```dart
final file = File('/path/to/photo.jpg');

if (await ExifUtils.hasExifData(file)) {
  final exifData = await ExifUtils.extractExif(file);
  // Process EXIF data
} else {
  print('File format does not support EXIF data');
}
```

## API Reference

### ExifData

Represents extracted EXIF metadata from an image.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `latitude` | `double?` | GPS latitude coordinate |
| `longitude` | `double?` | GPS longitude coordinate |
| `altitude` | `double?` | Altitude in meters |
| `dateTime` | `DateTime?` | Date/time modified |
| `dateTimeDigitized` | `DateTime?` | Date/time digitized |
| `dateTimeOriginal` | `DateTime?` | Date/time original (when photo was taken) |
| `make` | `String?` | Camera manufacturer |
| `model` | `String?` | Camera model |
| `orientation` | `int?` | Image orientation (1-8) |
| `flash` | `String?` | Flash mode |
| `focalLength` | `double?` | Focal length in mm |
| `isoSpeed` | `int?` | ISO speed rating |
| `exposureTime` | `double?` | Exposure time in seconds |
| `fNumber` | `double?` | Aperture f-number |
| `imageWidth` | `int?` | Image width in pixels |
| `imageHeight` | `int?` | Image height in pixels |

#### Computed Properties

- `hasLocation` - Returns `true` if both latitude and longitude are available
- `hasDateTime` - Returns `true` if any date/time field is available
- `bestDateTime` - Returns the best available date (prioritizes original, then digitized, then modified)

#### Methods

- `copyWith(...)` - Create a copy with updated fields
- `toJson()` - Convert to JSON map
- `fromJson(Map<String, dynamic>)` - Create from JSON map

### ExifExtractionConfig

Configuration options for EXIF extraction.

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `extractLocation` | `bool` | `true` | Extract GPS location data |
| `extractDateTime` | `bool` | `true` | Extract date/time data |
| `extractCameraInfo` | `bool` | `true` | Extract camera metadata |
| `extractDimensions` | `bool` | `true` | Extract image dimensions |
| `throwOnError` | `bool` | `false` | Throw exception on error |

#### Predefined Configurations

- `ExifExtractionConfig.forTravelJournal` - Optimized for travel journal entries (location + date only)
- `ExifExtractionConfig.fullMetadata` - Extract all available metadata

### ExifUtils

Static utility class for EXIF extraction.

#### Static Methods

##### `extractExif(File file, {ExifExtractionConfig config})`

Extract EXIF data from an image file.

**Parameters:**
- `file` - The image file to extract EXIF from
- `config` - Optional extraction configuration

**Returns:** `Future<ExifData>`

**Throws:** `ExifException` if extraction fails and `throwOnError` is true

---

##### `extractExifFromBytes(Uint8List bytes, {ExifExtractionConfig config})`

Extract EXIF data from image bytes.

**Parameters:**
- `bytes` - The image bytes to extract EXIF from
- `config` - Optional extraction configuration

**Returns:** `Future<ExifData>`

**Throws:** `ExifException` if extraction fails and `throwOnError` is true

---

##### `extractLocation(File file)`

Extract only location data from an image file.

**Parameters:**
- `file` - The image file to extract location from

**Returns:** `Future<ExifData>` with only location fields populated

---

##### `extractDateTime(File file)`

Extract only date/time data from an image file.

**Parameters:**
- `file` - The image file to extract date/time from

**Returns:** `Future<ExifData>` with only date/time fields populated

---

##### `hasExifData(File file)`

Check if a file is likely to contain EXIF data.

**Parameters:**
- `file` - The file to check

**Returns:** `Future<bool>` - `true` if JPEG or TIFF format

---

##### `getImageDimensions(File file)`

Get image dimensions from actual image data (fallback method).

**Parameters:**
- `file` - The image file

**Returns:** `Future<Map<String, int>?>` - Map with 'width' and 'height', or `null` if unavailable

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Fully Supported | Reads EXIF from JPEG/TIFF files |
| iOS | ✅ Fully Supported | Reads EXIF from JPEG/TIFF files |
| macOS | ✅ Fully Supported | Reads EXIF from JPEG/TIFF files |
| Windows | ✅ Fully Supported | Reads EXIF from JPEG/TIFF files |
| Linux | ✅ Fully Supported | Reads EXIF from JPEG/TIFF files |
| Web | ⚠️ Partial | Limited due to browser file system restrictions |

## Supported Formats

- JPEG (.jpg, .jpeg)
- TIFF (.tif, .tiff)

Other formats (PNG, GIF, WebP, etc.) typically don't contain EXIF data and will return empty `ExifData`.

## Best Practices

### 1. Use Selective Extraction

Extract only the data you need for better performance:

```dart
// ❌ Inefficient if you only need location
final exifData = await ExifUtils.extractExif(file);

// ✅ More efficient
final locationData = await ExifUtils.extractLocation(file);
```

### 2. Handle Missing Data Gracefully

Always check if data is available before using it:

```dart
final exifData = await ExifUtils.extractExif(file);

// ❌ May cause null errors
print('Location: ${exifData.latitude}, ${exifData.longitude}');

// ✅ Safe access
if (exifData.hasLocation) {
  print('Location: ${exifData.latitude}, ${exifData.longitude}');
} else {
  print('No GPS data available');
}
```

### 3. Use Predefined Configurations

Choose the appropriate config for your use case:

```dart
// For travel journals - location + date only
final exifData = await ExifUtils.extractExif(
  file,
  config: ExifExtractionConfig.forTravelJournal,
);

// For camera info - full metadata
final exifData = await ExifUtils.extractExif(
  file,
  config: ExifExtractionConfig.fullMetadata,
);
```

### 4. Batch Processing

When processing multiple images, consider parallel processing:

```dart
final results = await Future.wait(
  photoFiles.map((file) => ExifUtils.extractExif(
    file,
    config: ExifExtractionConfig.forTravelJournal,
  )),
);
```

### 5. Error Handling

Decide on error handling strategy based on use case:

```dart
// For optional metadata - don't throw
final exifData = await ExifUtils.extractExif(file);
if (!exifData.hasLocation) {
  // Use alternative location method
}

// For required metadata - throw and handle
try {
  final exifData = await ExifUtils.extractExif(
    file,
    config: const ExifExtractionConfig(throwOnError: true),
  );
} on ExifException catch (e) {
  // Show error to user
}
```

## Performance Considerations

- **Selective extraction is faster**: Use `extractLocation()` or `extractDateTime()` when you only need specific data
- **Bytes vs File**: `extractExifFromBytes()` avoids file I/O if you already have bytes in memory
- **Batch operations**: Use `Future.wait()` for parallel processing of multiple images
- **Large images**: Image dimension extraction (`getImageDimensions`) decodes the entire image and can be slow for large files

## Troubleshooting

### No EXIF data found

**Problem:** `hasLocation` and `hasDateTime` are both `false`

**Possible causes:**
- Image format doesn't support EXIF (PNG, GIF, WebP)
- EXIF data was stripped by image editing software
- Photo was taken without GPS/location services enabled
- File is corrupted

**Solution:**
```dart
if (await ExifUtils.hasExifData(file)) {
  final exifData = await ExifUtils.extractExif(file);
} else {
  // Use alternative method for location/date
}
```

### Incorrect location

**Problem:** GPS coordinates are wrong

**Possible causes:**
- Camera GPS was not calibrated
- Location services were not accurate when photo was taken
- EXIF data was modified

**Solution:** Always provide a way for users to manually correct location:

```dart
final location = exifData.hasLocation
    ? LatLng(exifData.latitude!, exifData.longitude!)
    : null; // Let user pick location manually
```

### Date/time is null

**Problem:** `bestDateTime` returns `null`

**Possible causes:**
- Camera didn't set date/time in EXIF
- Date/time format is non-standard
- EXIF data is corrupted

**Solution:** Fall back to file modification date:

```dart
final date = exifData.bestDateTime ?? await file.lastModified();
```

## Integration Examples

### With ImagePicker

```dart
import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();
final pickedFile = await picker.pickImage(source: ImageSource.gallery);

if (pickedFile != null) {
  final file = File(pickedFile.path);
  final exifData = await ExifUtils.extractExif(
    file,
    config: ExifExtractionConfig.forTravelJournal,
  );

  // Use exifData for journal entry
}
```

### With MediaPicker (from this project)

```dart
final pickedMedia = await MediaPicker.pickMedia(
  context,
  config: MediaPickerConfig.forTravelJournal,
);

for (final media in pickedMedia) {
  if (media.type == MediaType.photo) {
    final file = File(media.file.path);
    final exifData = await ExifUtils.extractExif(file);

    // Attach EXIF location/date to journal entry
  }
}
```

### With LocationService

```dart
// Try to get location from EXIF first
final exifData = await ExifUtils.extractExif(photoFile);

if (!exifData.hasLocation) {
  // Fall back to current location
  final locationData = await LocationService.getCurrentLocation();
  // Use locationData.latitude, locationData.longitude
}
```

## Related Components

- [LocationService](./location_service.dart) - Get current GPS location
- [GeocodingService](./geocoding_service.dart) - Convert coordinates to place names
- [MediaCompression](./media_compression.dart) - Compress images before upload
- [MediaPicker](../features/journal/presentation/widgets/media_picker.dart) - Pick photos from gallery

## Future Enhancements

- [ ] Extract video metadata (duration, codec, etc.)
- [ ] Extract EXIF from HEIC/HEIF images
- [ ] Extract more camera settings (white balance, exposure mode, etc.)
- [ ] Extract face detection data
- [ ] Extract panorama/stitching info
- [ ] Support for raw image formats (CR2, NEF, ARW, etc.)

## Testing

```dart
// Unit test example
test('extracts GPS coordinates from image with EXIF', () async {
  final file = File('test/fixtures/photo_with_gps.jpg');
  final exifData = await ExifUtils.extractExif(file);

  expect(exifData.hasLocation, isTrue);
  expect(exifData.latitude, isNotNull);
  expect(exifData.longitude, isNotNull);
});

test('returns empty data for image without EXIF', () async {
  final file = File('test/fixtures/photo_no_exif.png');
  final exifData = await ExifUtils.extractExif(file);

  expect(exifData.hasLocation, isFalse);
  expect(exifData.hasDateTime, isFalse);
});
```

## License

This utility is part of the SoloAdventurer project.

## Contributing

When adding new features to EXIF utils:
1. Follow existing code style and patterns
2. Add comprehensive documentation
3. Include example usage
4. Handle errors gracefully
5. Consider performance implications
