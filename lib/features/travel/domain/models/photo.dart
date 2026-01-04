/// Model representing a photo in a trip
///
/// This model represents a photo with associated metadata such as
/// location, timestamp, and size information for optimal rendering.
class Photo {
  /// Unique identifier for the photo
  final String id;

  /// URL of the photo image
  final String imageUrl;

  /// Optional thumbnail URL for efficient grid rendering
  final String? thumbnailUrl;

  /// Optional caption or description
  final String? caption;

  /// Trip ID this photo belongs to
  final String tripId;

  /// Optional location where photo was taken
  final String? location;

  /// Optional latitude coordinate
  final double? latitude;

  /// Optional longitude coordinate
  final double? longitude;

  /// Timestamp when photo was taken
  final DateTime takenAt;

  /// Photo width in pixels
  final int width;

  /// Photo height in pixels
  final int height;

  /// Photo file size in bytes
  final int sizeInBytes;

  /// When the photo was uploaded
  final DateTime createdAt;

  /// Creates a new [Photo] instance
  Photo({
    required this.id,
    required this.imageUrl,
    this.thumbnailUrl,
    this.caption,
    required this.tripId,
    this.location,
    this.latitude,
    this.longitude,
    required this.takenAt,
    required this.width,
    required this.height,
    required this.sizeInBytes,
    required this.createdAt,
  });

  /// Creates a [Photo] from JSON data
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      caption: json['caption'] as String?,
      tripId: json['tripId'] as String,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      takenAt: DateTime.parse(json['takenAt'] as String),
      width: json['width'] as int,
      height: json['height'] as int,
      sizeInBytes: json['sizeInBytes'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts [Photo] to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'tripId': tripId,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'takenAt': takenAt.toIso8601String(),
      'width': width,
      'height': height,
      'sizeInBytes': sizeInBytes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Calculates aspect ratio for proper image display
  double get aspectRatio => height > 0 ? width / height : 1.0;

  /// Returns the appropriate URL to display based on availability
  String get displayUrl => thumbnailUrl ?? imageUrl;

  /// Creates a copy of this [Photo] with modified fields
  Photo copyWith({
    String? id,
    String? imageUrl,
    String? thumbnailUrl,
    String? caption,
    String? tripId,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? takenAt,
    int? width,
    int? height,
    int? sizeInBytes,
    DateTime? createdAt,
  }) {
    return Photo(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      tripId: tripId ?? this.tripId,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      takenAt: takenAt ?? this.takenAt,
      width: width ?? this.width,
      height: height ?? this.height,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
