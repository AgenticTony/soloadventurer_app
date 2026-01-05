import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo.freezed.dart';
part 'photo.g.dart';

/// Model representing a photo in a trip
///
/// This model represents a photo with associated metadata such as
/// location, timestamp, and size information for optimal rendering.
/// Uses Freezed for immutability and efficient copyWith operations.
@freezed
class Photo with _$Photo {
  const factory Photo({
    /// Unique identifier for the photo
    required String id,

    /// URL of the photo image
    required String imageUrl,

    /// Optional thumbnail URL for efficient grid rendering
    String? thumbnailUrl,

    /// Optional caption or description
    String? caption,

    /// Trip ID this photo belongs to
    required String tripId,

    /// Optional location where photo was taken
    String? location,

    /// Optional latitude coordinate
    double? latitude,

    /// Optional longitude coordinate
    double? longitude,

    /// Timestamp when photo was taken
    required DateTime takenAt,

    /// Photo width in pixels
    required int width,

    /// Photo height in pixels
    required int height,

    /// Photo file size in bytes
    required int sizeInBytes,

    /// When the photo was uploaded
    required DateTime createdAt,
  }) = _Photo;

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);

  const Photo._();

  /// Calculates aspect ratio for proper image display
  ///
  /// Returns the width-to-height ratio of the photo. Returns 1.0 (square)
  /// if height is zero or undefined to avoid division by zero.
  double get aspectRatio => height > 0 ? width / height : 1.0;

  /// Returns the appropriate URL to display based on availability
  ///
  /// Prioritizes thumbnail URL for efficient grid rendering, falling back
  /// to full image URL when thumbnail is not available.
  String get displayUrl => thumbnailUrl ?? imageUrl;
}
