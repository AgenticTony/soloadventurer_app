import '../entities/journal_entry.dart';
import '../entities/media_item.dart';
import '../entities/trip.dart';

/// Type of content to share
enum ShareableType {
  /// Share a journal entry
  journalEntry,

  /// Share a media item (photo or video)
  mediaItem,

  /// Share an entire trip
  trip,

  /// Share multiple entries
  multipleEntries,
}

/// Platform to share content to
enum SharePlatform {
  /// Native share sheet (user can choose any app)
  generic,

  /// Facebook
  facebook,

  /// Twitter/X
  twitter,

  /// Instagram
  instagram,

  /// WhatsApp
  whatsapp,

  /// Telegram
  telegram,

  /// SMS/Text message
  sms,

  /// Email
  email,

  /// Copy to clipboard
  clipboard,

  /// More options
  more,
}

/// Format for shared content
enum ShareFormat {
  /// Plain text
  text,

  /// Image file
  image,

  /// Video file
  video,

  /// URL/link
  link,

  /// Rich content with images
  rich,
}

/// Result of a share operation
class ShareResult {
  /// Whether the share was successful
  final bool success;

  /// The platform used for sharing
  final SharePlatform platform;

  /// The type of content shared
  final ShareableType contentType;

  /// Number of items shared
  final int itemCount;

  /// Format used for sharing
  final ShareFormat format;

  /// Error message if share failed
  final String? errorMessage;

  /// Timestamp when share was initiated
  final DateTime sharedAt;

  /// Whether content was copied to clipboard
  final bool wasCopiedToClipboard;

  const ShareResult({
    required this.success,
    required this.platform,
    required this.contentType,
    this.itemCount = 1,
    required this.format,
    this.errorMessage,
    required this.sharedAt,
    this.wasCopiedToClipboard = false,
  });

  /// Creates a successful share result
  factory ShareResult.success({
    required SharePlatform platform,
    required ShareableType contentType,
    required ShareFormat format,
    int itemCount = 1,
    bool wasCopiedToClipboard = false,
  }) {
    return ShareResult(
      success: true,
      platform: platform,
      contentType: contentType,
      itemCount: itemCount,
      format: format,
      sharedAt: DateTime.now(),
      wasCopiedToClipboard: wasCopiedToClipboard,
    );
  }

  /// Creates a failed share result
  factory ShareResult.failure({
    required SharePlatform platform,
    required ShareableType contentType,
    required String errorMessage,
  }) {
    return ShareResult(
      success: false,
      platform: platform,
      contentType: contentType,
      format: ShareFormat.text,
      errorMessage: errorMessage,
      sharedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ShareResult('
        'success: $success, '
        'platform: $platform, '
        'type: $contentType, '
        'items: $itemCount, '
        'format: $format'
        ')';
  }
}

/// Configuration for sharing content
class ShareConfig {
  /// Title of the shared content
  final String title;

  /// Main text/message to share
  final String text;

  /// Optional URL to include
  final String? url;

  /// Optional image paths to share
  final List<String>? imagePaths;

  /// Optional video path to share
  final String? videoPath;

  /// Optional hashtags for social media
  final List<String>? hashtags;

  /// Whether to include location
  final bool includeLocation;

  /// Whether to include date
  final bool includeDate;

  /// Whether to include mood
  final bool includeMood;

  /// Custom message template
  final String? messageTemplate;

  const ShareConfig({
    required this.title,
    required this.text,
    this.url,
    this.imagePaths,
    this.videoPath,
    this.hashtags,
    this.includeLocation = true,
    this.includeDate = true,
    this.includeMood = true,
    this.messageTemplate,
  });

  /// Creates a copy with modified fields
  ShareConfig copyWith({
    String? title,
    String? text,
    String? url,
    List<String>? imagePaths,
    String? videoPath,
    List<String>? hashtags,
    bool? includeLocation,
    bool? includeDate,
    bool? includeMood,
    String? messageTemplate,
  }) {
    return ShareConfig(
      title: title ?? this.title,
      text: text ?? this.text,
      url: url ?? this.url,
      imagePaths: imagePaths ?? this.imagePaths,
      videoPath: videoPath ?? this.videoPath,
      hashtags: hashtags ?? this.hashtags,
      includeLocation: includeLocation ?? this.includeLocation,
      includeDate: includeDate ?? this.includeDate,
      includeMood: includeMood ?? this.includeMood,
      messageTemplate: messageTemplate ?? this.messageTemplate,
    );
  }

  /// Formats the text with all included elements
  String getFormattedText({
    String? location,
    DateTime? date,
    String? mood,
  }) {
    final buffer = StringBuffer();

    // Use custom template if provided
    if (messageTemplate != null) {
      var formatted = messageTemplate!;
      formatted = formatted.replaceAll('{title}', title);
      formatted = formatted.replaceAll('{text}', text);
      if (includeLocation && location != null) {
        formatted = formatted.replaceAll('{location}', location);
      }
      if (includeDate && date != null) {
        formatted = formatted.replaceAll('{date}', _formatDate(date));
      }
      if (includeMood && mood != null) {
        formatted = formatted.replaceAll('{mood}', mood);
      }
      buffer.write(formatted);
    } else {
      // Default formatting
      buffer.writeln(title);
      buffer.writeln(text);

      if (includeLocation && location != null) {
        buffer.write('📍 $location');
      }

      if (includeDate && date != null) {
        buffer.write(' 📅 ${_formatDate(date)}');
      }

      if (includeMood && mood != null) {
        buffer.write(' 😊 $mood');
      }
    }

    // Add hashtags
    if (hashtags != null && hashtags!.isNotEmpty) {
      buffer.writeln();
      buffer.write(hashtags!.map((tag) => '#$tag').join(' '));
    }

    // Add URL
    if (url != null) {
      buffer.writeln();
      buffer.write(url);
    }

    return buffer.toString().trim();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Service for sharing journal content to social platforms
abstract class SocialSharingService {
  /// Share a journal entry
  ///
  /// [entry] - The journal entry to share
  /// [platform] - The platform to share to (use generic for native share sheet)
  /// [config] - Optional custom configuration (auto-generated if not provided)
  /// [includeMedia] - Whether to include attached media
  Future<ShareResult> shareEntry(
    JournalEntry entry, {
    SharePlatform platform = SharePlatform.generic,
    ShareConfig? config,
    bool includeMedia = true,
    List<MediaItem>? mediaItems,
  });

  /// Share a media item (photo or video)
  ///
  /// [media] - The media item to share
  /// [platform] - The platform to share to
  /// [config] - Optional custom configuration
  Future<ShareResult> shareMedia(
    MediaItem media, {
    SharePlatform platform = SharePlatform.generic,
    ShareConfig? config,
    JournalEntry? entry,
  });

  /// Share an entire trip
  ///
  /// [trip] - The trip to share
  /// [platform] - The platform to share to
  /// [config] - Optional custom configuration
  /// [entryCount] - Number of entries to include in share
  Future<ShareResult> shareTrip(
    Trip trip, {
    SharePlatform platform = SharePlatform.generic,
    ShareConfig? config,
    int entryCount = 0,
  });

  /// Share multiple entries
  ///
  /// [entries] - The entries to share
  /// [platform] - The platform to share to
  /// [config] - Optional custom configuration
  Future<ShareResult> shareMultipleEntries(
    List<JournalEntry> entries, {
    SharePlatform platform = SharePlatform.generic,
    ShareConfig? config,
  });

  /// Generate a share configuration for a journal entry
  ///
  /// Auto-generates appropriate text, hashtags, and formatting
  ShareConfig generateEntryShareConfig(
    JournalEntry entry, {
    List<String>? customHashtags,
    String? messageTemplate,
    bool includeLocation = true,
    bool includeDate = true,
    bool includeMood = true,
  });

  /// Generate a share configuration for a media item
  ShareConfig generateMediaShareConfig(
    MediaItem media, {
    JournalEntry? entry,
    List<String>? customHashtags,
    String? messageTemplate,
  });

  /// Generate a share configuration for a trip
  ShareConfig generateTripShareConfig(
    Trip trip, {
    int entryCount = 0,
    List<String>? customHashtags,
    String? messageTemplate,
  });

  /// Check if a specific platform is available on the device
  Future<bool> isPlatformAvailable(SharePlatform platform);

  /// Get list of available platforms on the device
  Future<List<SharePlatform>> getAvailablePlatforms();

  /// Copy content to clipboard
  Future<bool> copyToClipboard(String content);

  /// Generate a shareable link for content (future feature)
  /// This would integrate with subtask 8.3 (public trip sharing links)
  Future<String?> generateShareLink({
    ShareableType type,
    String? entryId,
    String? tripId,
    String? mediaId,
  });
}
