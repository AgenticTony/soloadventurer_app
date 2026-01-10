import 'dart:io';
import 'dart:typed_data';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import '../core/errors/exceptions.dart';

/// Result of EXIF data extraction from an image
class ExifData {
  /// GPS latitude coordinate (null if not available)
  final double? latitude;

  /// GPS longitude coordinate (null if not available)
  final double? longitude;

  /// Altitude in meters (null if not available)
  final double? altitude;

  /// Date and time when photo was taken (null if not available)
  final DateTime? dateTime;

  /// Date and time when photo was digitized (null if not available)
  final DateTime? dateTimeDigitized;

  /// Date and time when photo was modified (null if not available)
  final DateTime? dateTimeOriginal;

  /// Camera make (null if not available)
  final String? make;

  /// Camera model (null if not available)
  final String? model;

  /// Image orientation (1-8, null if not available)
  final int? orientation;

  /// Flash mode (null if not available)
  final String? flash;

  /// Focal length in mm (null if not available)
  final double? focalLength;

  /// ISO speed rating (null if not available)
  final int? isoSpeed;

  /// Exposure time in seconds (null if not available)
  final double? exposureTime;

  /// F-number (aperture) (null if not available)
  final double? fNumber;

  /// Image width in pixels (null if not available)
  final int? imageWidth;

  /// Image height in pixels (null if not available)
  final int? imageHeight;

  /// Whether GPS location data is available
  bool get hasLocation => latitude != null && longitude != null;

  /// Whether date/time data is available
  bool get hasDateTime =>
      dateTime != null || dateTimeDigitized != null || dateTimeOriginal != null;

  /// Best available date/time (prioritizes dateTimeOriginal, then dateTimeDigitized, then dateTime)
  DateTime? get bestDateTime =>
      dateTimeOriginal ?? dateTimeDigitized ?? dateTime;

  const ExifData({
    this.latitude,
    this.longitude,
    this.altitude,
    this.dateTime,
    this.dateTimeDigitized,
    this.dateTimeOriginal,
    this.make,
    this.model,
    this.orientation,
    this.flash,
    this.focalLength,
    this.isoSpeed,
    this.exposureTime,
    this.fNumber,
    this.imageWidth,
    this.imageHeight,
  });

  /// Creates a copy with updated fields
  ExifData copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    DateTime? dateTime,
    DateTime? dateTimeDigitized,
    DateTime? dateTimeOriginal,
    String? make,
    String? model,
    int? orientation,
    String? flash,
    double? focalLength,
    int? isoSpeed,
    double? exposureTime,
    double? fNumber,
    int? imageWidth,
    int? imageHeight,
  }) {
    return ExifData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      dateTime: dateTime ?? this.dateTime,
      dateTimeDigitized: dateTimeDigitized ?? this.dateTimeDigitized,
      dateTimeOriginal: dateTimeOriginal ?? this.dateTimeOriginal,
      make: make ?? this.make,
      model: model ?? this.model,
      orientation: orientation ?? this.orientation,
      flash: flash ?? this.flash,
      focalLength: focalLength ?? this.focalLength,
      isoSpeed: isoSpeed ?? this.isoSpeed,
      exposureTime: exposureTime ?? this.exposureTime,
      fNumber: fNumber ?? this.fNumber,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'dateTime': dateTime?.toIso8601String(),
      'dateTimeDigitized': dateTimeDigitized?.toIso8601String(),
      'dateTimeOriginal': dateTimeOriginal?.toIso8601String(),
      'make': make,
      'model': model,
      'orientation': orientation,
      'flash': flash,
      'focalLength': focalLength,
      'isoSpeed': isoSpeed,
      'exposureTime': exposureTime,
      'fNumber': fNumber,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
    };
  }

  /// Create from JSON
  factory ExifData.fromJson(Map<String, dynamic> json) {
    return ExifData(
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      altitude: json['altitude'] as double?,
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'] as String)
          : null,
      dateTimeDigitized: json['dateTimeDigitized'] != null
          ? DateTime.parse(json['dateTimeDigitized'] as String)
          : null,
      dateTimeOriginal: json['dateTimeOriginal'] != null
          ? DateTime.parse(json['dateTimeOriginal'] as String)
          : null,
      make: json['make'] as String?,
      model: json['model'] as String?,
      orientation: json['orientation'] as int?,
      flash: json['flash'] as String?,
      focalLength: json['focalLength'] as double?,
      isoSpeed: json['isoSpeed'] as int?,
      exposureTime: json['exposureTime'] as double?,
      fNumber: json['fNumber'] as double?,
      imageWidth: json['imageWidth'] as int?,
      imageHeight: json['imageHeight'] as int?,
    );
  }

  @override
  String toString() =>
      'ExifData(location: ${hasLocation ? "($latitude, $longitude)" : "N/A"}, '
      'dateTime: ${bestDateTime ?? "N/A"}, '
      'camera: ${make ?? "N/A"} ${model ?? "N/A"})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExifData &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          altitude == other.altitude &&
          dateTime == other.dateTime &&
          dateTimeDigitized == other.dateTimeDigitized &&
          dateTimeOriginal == other.dateTimeOriginal;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      dateTime.hashCode ^
      dateTimeOriginal.hashCode;
}

/// Configuration for EXIF data extraction
class ExifExtractionConfig {
  /// Whether to extract GPS location data
  final bool extractLocation;

  /// Whether to extract date/time data
  final bool extractDateTime;

  /// Whether to extract camera metadata (make, model, etc.)
  final bool extractCameraInfo;

  /// Whether to extract image dimensions
  final bool extractDimensions;

  /// Whether to throw exceptions or return null on errors
  final bool throwOnError;

  const ExifExtractionConfig({
    this.extractLocation = true,
    this.extractDateTime = true,
    this.extractCameraInfo = true,
    this.extractDimensions = true,
    this.throwOnError = false,
  });

  /// Predefined configuration for travel journal (location and date focused)
  static const forTravelJournal = ExifExtractionConfig(
    extractLocation: true,
    extractDateTime: true,
    extractCameraInfo: false,
    extractDimensions: false,
    throwOnError: false,
  );

  /// Predefined configuration for full metadata extraction
  static const fullMetadata = ExifExtractionConfig(
    extractLocation: true,
    extractDateTime: true,
    extractCameraInfo: true,
    extractDimensions: true,
    throwOnError: false,
  );
}

/// Utility for extracting EXIF metadata from images
class ExifUtils {
  /// Private constructor to prevent instantiation
  ExifUtils._();

  /// Extract EXIF data from an image file
  ///
  /// [file] - The image file to extract EXIF data from
  /// [config] - Optional configuration for extraction
  ///
  /// Returns [ExifData] containing extracted metadata
  /// Throws [ExifException] if extraction fails and [throwOnError] is true
  ///
  /// Example:
  /// ```dart
  /// final file = File('/path/to/image.jpg');
  /// final exifData = await ExifUtils.extractExif(file);
  /// if (exifData.hasLocation) {
  ///   print('Photo taken at: ${exifData.latitude}, ${exifData.longitude}');
  /// }
  /// ```
  static Future<ExifData> extractExif(
    File file, {
    ExifExtractionConfig config = const ExifExtractionConfig(),
  }) async {
    try {
      // Read file bytes
      final bytes = await file.readAsBytes();

      // Extract EXIF data
      final tags = await readExifFromBytes(bytes);

      // Parse EXIF data
      return _parseExifTags(tags, config);
    } catch (e) {
      if (config.throwOnError) {
        throw ExifException(
          'Failed to extract EXIF data: ${e.toString()}',
        );
      }
      // Return empty ExifData on error if not throwing
      return const ExifData();
    }
  }

  /// Extract EXIF data from image bytes
  ///
  /// [bytes] - The image bytes to extract EXIF data from
  /// [config] - Optional configuration for extraction
  ///
  /// Returns [ExifData] containing extracted metadata
  /// Throws [ExifException] if extraction fails and [throwOnError] is true
  ///
  /// Example:
  /// ```dart
  /// final bytes = await pickedFile.readAsBytes();
  /// final exifData = await ExifUtils.extractExifFromBytes(bytes);
  /// ```
  static Future<ExifData> extractExifFromBytes(
    Uint8List bytes, {
    ExifExtractionConfig config = const ExifExtractionConfig(),
  }) async {
    try {
      final tags = await readExifFromBytes(bytes);
      return _parseExifTags(tags, config);
    } catch (e) {
      if (config.throwOnError) {
        throw ExifException(
          'Failed to extract EXIF data from bytes: ${e.toString()}',
        );
      }
      return const ExifData();
    }
  }

  /// Extract only location data from an image file
  ///
  /// [file] - The image file to extract location from
  ///
  /// Returns [ExifData] with only location fields populated
  ///
  /// Example:
  /// ```dart
  /// final exifData = await ExifUtils.extractLocation(File('photo.jpg'));
  /// if (exifData.hasLocation) {
  ///   print('Location: ${exifData.latitude}, ${exifData.longitude}');
  /// }
  /// ```
  static Future<ExifData> extractLocation(File file) async {
    return extractExif(
      file,
      config: const ExifExtractionConfig(
        extractLocation: true,
        extractDateTime: false,
        extractCameraInfo: false,
        extractDimensions: false,
      ),
    );
  }

  /// Extract only date/time data from an image file
  ///
  /// [file] - The image file to extract date/time from
  ///
  /// Returns [ExifData] with only date/time fields populated
  ///
  /// Example:
  /// ```dart
  /// final exifData = await ExifUtils.extractDateTime(File('photo.jpg'));
  /// print('Photo taken: ${exifData.bestDateTime}');
  /// ```
  static Future<ExifData> extractDateTime(File file) async {
    return extractExif(
      file,
      config: const ExifExtractionConfig(
        extractLocation: false,
        extractDateTime: true,
        extractCameraInfo: false,
        extractDimensions: false,
      ),
    );
  }

  /// Parse EXIF tags into [ExifData] object
  static ExifData _parseExifTags(
    Map<String, IfdTag> tags,
    ExifExtractionConfig config,
  ) {
    double? latitude;
    double? longitude;
    double? altitude;
    DateTime? dateTime;
    DateTime? dateTimeDigitized;
    DateTime? dateTimeOriginal;
    String? make;
    String? model;
    int? orientation;
    String? flash;
    double? focalLength;
    int? isoSpeed;
    double? exposureTime;
    double? fNumber;
    int? imageWidth;
    int? imageHeight;

    // Extract GPS location
    if (config.extractLocation) {
      if (tags.containsKey('GPSLatitude') && tags.containsKey('GPSLongitude')) {
        latitude = _convertToDegree(tags['GPSLatitude']);
        longitude = _convertToDegree(tags['GPSLongitude']);

        // Check for latitude and longitude ref (N/S, E/W)
        final latRef = tags['GPSLatitudeRef'];
        final lngRef = tags['GPSLongitudeRef'];

        if (latRef != null && latRef.printable == 'S') {
          latitude = -latitude;
        }
        if (lngRef != null && lngRef.printable == 'W') {
          longitude = -longitude;
        }
      }

      // Extract altitude
      if (tags.containsKey('GPSAltitude')) {
        final altTag = tags['GPSAltitude'];
        if (altTag != null) {
          altitude = _convertRationalToDouble(altTag.values);
        }
      }
    }

    // Extract date/time
    if (config.extractDateTime) {
      dateTime = _parseDateTime(tags['DateTime']);
      dateTimeOriginal = _parseDateTime(tags['DateTimeOriginal']);
      dateTimeDigitized = _parseDateTime(tags['DateTimeDigitized']);
    }

    // Extract camera info
    if (config.extractCameraInfo) {
      make = tags['Make']?.printable.toString();
      model = tags['Model']?.printable.toString();
      orientation = tags['Orientation']?.values.first as int?;
      flash = tags['Flash']?.printable.toString();
      focalLength = _convertRationalToDouble(tags['FocalLength']?.values);
      isoSpeed = tags['ISOSpeedRatings']?.values.first as int?;
      exposureTime = _convertRationalToDouble(tags['ExposureTime']?.values);
      fNumber = _convertRationalToDouble(tags['FNumber']?.values);
    }

    // Extract dimensions
    if (config.extractDimensions) {
      imageWidth = tags['PixelXDimension']?.values.first as int? ??
          tags['ExifImageWidth']?.values.first as int?;
      imageHeight = tags['PixelYDimension']?.values.first as int? ??
          tags['ExifImageHeight']?.values.first as int?;
    }

    return ExifData(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      dateTime: dateTime,
      dateTimeDigitized: dateTimeDigitized,
      dateTimeOriginal: dateTimeOriginal,
      make: make,
      model: model,
      orientation: orientation,
      flash: flash,
      focalLength: focalLength,
      isoSpeed: isoSpeed,
      exposureTime: exposureTime,
      fNumber: fNumber,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
  }

  /// Convert GPS coordinate from EXIF format to decimal degrees
  static double? _convertToDegree(IfdTag? tag) {
    if (tag == null) return null;

    final values = tag.values;
    if (values.isEmpty) return null;

    try {
      // GPS coordinates are stored as [degrees, minutes, seconds]
      final degrees = _convertRationalToDouble([values[0]]) ?? 0.0;
      final minutes = _convertRationalToDouble([values[1]]) ?? 0.0;
      final seconds = _convertRationalToDouble([values[2]]) ?? 0.0;

      return degrees + (minutes / 60) + (seconds / 3600);
    } catch (e) {
      return null;
    }
  }

  /// Convert rational number to double
  static double? _convertRationalToDouble(dynamic value) {
    if (value == null) return null;

    try {
      if (value is List && value.isNotEmpty) {
        final first = value[0];
        if (first is double) {
          return first;
        }
        if (first is int) {
          // Check if it's a rational [numerator, denominator]
          if (value.length >= 2) {
            final numerator = first.toDouble();
            final denominator = (value[1] as num).toDouble();
            if (denominator != 0) {
              return numerator / denominator;
            }
          }
          return first.toDouble();
        }
      }
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
    } catch (e) {
      return null;
    }

    return null;
  }

  /// Parse date/time string from EXIF tag
  static DateTime? _parseDateTime(IfdTag? tag) {
    if (tag == null) return null;

    final dateString = tag.printable;

    try {
      // EXIF date format is typically "YYYY:MM:DD HH:MM:SS"
      final parts = dateString.split(' ');
      if (parts.length != 2) return null;

      final dateParts = parts[0].split(':');
      final timeParts = parts[1].split(':');

      if (dateParts.length != 3 || timeParts.length != 3) return null;

      return DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if a file is likely to contain EXIF data
  ///
  /// [file] - The file to check
  ///
  /// Returns true if the file is a JPEG or TIFF image (which typically contain EXIF)
  ///
  /// Example:
  /// ```dart
  /// if (await ExifUtils.hasExifData(file)) {
  ///   final exif = await ExifUtils.extractExif(file);
  /// }
  /// ```
  static Future<bool> hasExifData(File file) async {
    try {
      final extension = file.path.toLowerCase();
      return extension.endsWith('.jpg') ||
          extension.endsWith('.jpeg') ||
          extension.endsWith('.tif') ||
          extension.endsWith('.tiff');
    } catch (e) {
      return false;
    }
  }

  /// Get image dimensions from file (fallback when EXIF doesn't have dimensions)
  ///
  /// [file] - The image file
  ///
  /// Returns a map with 'width' and 'height' keys, or null if unavailable
  ///
  /// Example:
  /// ```dart
  /// final dimensions = await ExifUtils.getImageDimensions(file);
  /// print('Image size: ${dimensions['width']}x${dimensions['height']}');
  /// ```
  static Future<Map<String, int>?> getImageDimensions(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      return null;
    }
  }
}
