import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/trip.dart';
import '../../domain/services/social_sharing_service.dart';

// Import for UploadStatus enum

/// Implementation of social sharing service
class SocialSharingServiceImpl implements SocialSharingService {
  /// Default hashtags for travel journal posts
  static const List<String> defaultHashtags = [
    'travel',
    'adventure',
    'wanderlust',
    'traveljournal',
    'soloadventurer',
  ];

  /// Maximum text length for different platforms
  static const Map<SharePlatform, int> maxTextLengths = {
    SharePlatform.twitter: 280,
    SharePlatform.facebook: 63206,
    SharePlatform.instagram: 2200,
    SharePlatform.whatsapp: 65536,
    SharePlatform.telegram: 65536,
    SharePlatform.sms: 160,
    SharePlatform.email: 65536,
    SharePlatform.generic: 65536,
  };

  @override
  Future<JournalShareResult> shareEntry(
    JournalEntry entry, {
    SharePlatform platform = SharePlatform.generic,
    ShareConfig? config,
    bool includeMedia = true,
    List<MediaItem>? mediaItems,
  }) async {
    try {
      // Generate config if not provided
      final shareConfig = config ??
          generateEntryShareConfig(
            entry,
            includeLocation: true,
            includeDate: true,
            includeMood: true,
          );

      // Format the text
      final text = shareConfig.getFormattedText(
        location: entry.locationName,
        date: entry.entryDate,
        mood: entry.mood,
      );

      // Truncate text if needed for platform
      final truncatedText = _truncateTextForPlatform(text, platform);

      // Perform share based on platform
      if (platform == SharePlatform.clipboard) {
        await copyToClipboard(truncatedText);
        return JournalShareResult.success(
          platform: platform,
          contentType: ShareableType.journalEntry,
          format: ShareFormat.text,
          wasCopiedToClipboard: true,
        );
      }

      // Collect files to share
      final files = <XFile>[];
      if (includeMedia && mediaItems != null && mediaItems.isNotEmpty) {
        for (final media in mediaItems) {
          if (media.uploadStatus == UploadStatus.completed) {
            try {
              final file = await _getXFileFromMedia(media);
              if (file != null) {
                files.add(file);
              }
            } catch (e) {
              // Continue even if one media fails to load
              continue;
            }
          }
        }
      }

      // Share content
      await Share.shareXFiles(
        files,
        text: truncatedText,
        subject: shareConfig.title,
      );

      return JournalShareResult.success(
        platform: platform,
        contentType: ShareableType.journalEntry,
        format: files.isEmpty ? ShareFormat.text : ShareFormat.rich,
        itemCount: 1,
      );
    } catch (e) {
      return JournalShareResult.failure(
        platform: platform,
        contentType: ShareableType.journalEntry,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<JournalShareResult> shareMedia(
    MediaItem media, {
    SharePlatform platform = SharePlatform.generic,
    ShareConfig? config,
    JournalEntry? entry,
  }) async {
    try {
      // Generate config if not provided
      final shareConfig = config ??
          generateMediaShareConfig(
            media,
            entry: entry,
          );

      // Get the media file
      final xFile = await _getXFileFromMedia(media);
      if (xFile == null) {
        return JournalShareResult.failure(
          platform: platform,
          contentType: ShareableType.mediaItem,
          errorMessage: 'Media file not available',
        );
      }

      // Prepare text
      String text = shareConfig.text;
      if (entry != null) {
        text = shareConfig.getFormattedText(
          location: entry.locationName,
          date: entry.entryDate,
          mood: entry.mood,
        );
      }

      final truncatedText = _truncateTextForPlatform(text, platform);

      // Share based on platform
      if (platform == SharePlatform.clipboard) {
        await copyToClipboard(truncatedText);
        return JournalShareResult.success(
          platform: platform,
          contentType: ShareableType.mediaItem,
          format: ShareFormat.text,
          wasCopiedToClipboard: true,
        );
      }

      // Share the file
      await Share.shareXFiles(
        [xFile],
        text: truncatedText,
        subject: shareConfig.title,
      );

      return JournalShareResult.success(
        platform: platform,
        contentType: ShareableType.mediaItem,
        format: media.isVideo ? ShareFormat.video : ShareFormat.image,
      );
    } catch (e) {
      return JournalShareResult.failure(
        platform: platform,
        contentType: ShareableType.mediaItem,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<JournalShareResult> shareTrip(
    Trip trip, {
    SharePlatform platform = SharePlatform.generic,
    ShareConfig? config,
    int entryCount = 0,
  }) async {
    try {
      // Generate config if not provided
      final shareConfig = config ??
          generateTripShareConfig(
            trip,
            entryCount: entryCount,
          );

      // Format the text
      final text = shareConfig.getFormattedText(
        location: trip.destination,
        date: trip.startDate,
      );

      final truncatedText = _truncateTextForPlatform(text, platform);

      // Share based on platform
      if (platform == SharePlatform.clipboard) {
        await copyToClipboard(truncatedText);
        return JournalShareResult.success(
          platform: platform,
          contentType: ShareableType.trip,
          format: ShareFormat.text,
          wasCopiedToClipboard: true,
        );
      }

      // Share text only (trips are shared as text with link in future)
      await Share.share(
        truncatedText,
        subject: shareConfig.title,
      );

      return JournalShareResult.success(
        platform: platform,
        contentType: ShareableType.trip,
        format: ShareFormat.text,
        itemCount: entryCount,
      );
    } catch (e) {
      return JournalShareResult.failure(
        platform: platform,
        contentType: ShareableType.trip,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<JournalShareResult> shareMultipleEntries(
    List<JournalEntry> entries, {
    SharePlatform platform = SharePlatform.generic,
    ShareConfig? config,
  }) async {
    try {
      if (entries.isEmpty) {
        return JournalShareResult.failure(
          platform: platform,
          contentType: ShareableType.multipleEntries,
          errorMessage: 'No entries to share',
        );
      }

      // Use first entry for config
      final firstEntry = entries.first;
      final shareConfig = config ??
          generateEntryShareConfig(
            firstEntry,
            customHashtags: ['traveljournal', 'memories'],
          );

      // Create summary text
      final buffer = StringBuffer();
      buffer.writeln(shareConfig.title);
      buffer.writeln('📝 ${entries.length} journal entries');
      buffer
          .writeln('📅 ${DateFormat('MMM yyyy').format(firstEntry.entryDate)}');
      if (shareConfig.url != null) {
        buffer.write(shareConfig.url);
      }

      final text = buffer.toString().trim();
      final truncatedText = _truncateTextForPlatform(text, platform);

      // Share based on platform
      if (platform == SharePlatform.clipboard) {
        await copyToClipboard(truncatedText);
        return JournalShareResult.success(
          platform: platform,
          contentType: ShareableType.multipleEntries,
          format: ShareFormat.text,
          itemCount: entries.length,
          wasCopiedToClipboard: true,
        );
      }

      await Share.share(
        truncatedText,
        subject: shareConfig.title,
      );

      return JournalShareResult.success(
        platform: platform,
        contentType: ShareableType.multipleEntries,
        format: ShareFormat.text,
        itemCount: entries.length,
      );
    } catch (e) {
      return JournalShareResult.failure(
        platform: platform,
        contentType: ShareableType.multipleEntries,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  ShareConfig generateEntryShareConfig(
    JournalEntry entry, {
    List<String>? customHashtags,
    String? messageTemplate,
    bool includeLocation = true,
    bool includeDate = true,
    bool includeMood = true,
  }) {
    final hashtags = customHashtags ?? defaultHashtags;

    // Create title
    final title = entry.title.isNotEmpty ? entry.title : 'Journal Entry';

    // Create text preview (first 200 chars)
    final textPreview = entry.content.length > 200
        ? '${entry.content.substring(0, 200)}...'
        : entry.content;

    return ShareConfig(
      title: title,
      text: textPreview,
      hashtags: hashtags,
      includeLocation: includeLocation,
      includeDate: includeDate,
      includeMood: includeMood,
      messageTemplate: messageTemplate,
    );
  }

  @override
  ShareConfig generateMediaShareConfig(
    MediaItem media, {
    JournalEntry? entry,
    List<String>? customHashtags,
    String? messageTemplate,
  }) {
    final hashtags = customHashtags ?? [...defaultHashtags, 'travelphoto'];

    String title = 'Travel ${media.isVideo ? "Video" : "Photo"}';
    String text = '';

    if (entry != null) {
      title = entry.title;
      text = media.caption ?? entry.content;
    } else if (media.caption != null) {
      text = media.caption!;
    }

    // Truncate text
    if (text.length > 200) {
      text = '${text.substring(0, 200)}...';
    }

    return ShareConfig(
      title: title,
      text: text,
      hashtags: hashtags,
      messageTemplate: messageTemplate,
      includeLocation: entry?.locationName != null,
      includeDate: entry != null,
      includeMood: entry?.mood != null,
    );
  }

  @override
  ShareConfig generateTripShareConfig(
    Trip trip, {
    int entryCount = 0,
    List<String>? customHashtags,
    String? messageTemplate,
  }) {
    final hashtags = customHashtags ??
        [...defaultHashtags, trip.name.toLowerCase().replaceAll(' ', '')];

    final text = entryCount > 0
        ? '📝 $entryCount journal entries from ${trip.name}'
        : 'Check out my trip to ${trip.destination}!';

    return ShareConfig(
      title: 'Trip: ${trip.name}',
      text: text,
      hashtags: hashtags,
      messageTemplate: messageTemplate,
    );
  }

  @override
  Future<bool> isPlatformAvailable(SharePlatform platform) async {
    // For most platforms, we use the generic share sheet which is always available
    if (platform == SharePlatform.generic) {
      return true;
    }

    // TODO: Implement platform-specific availability checks
    // This would require platform-specific plugins like url_launcher
    return true;
  }

  @override
  Future<List<SharePlatform>> getAvailablePlatforms() async {
    // Return all platforms (generic share sheet supports all)
    return SharePlatform.values;
  }

  @override
  Future<bool> copyToClipboard(String content) async {
    try {
      await Clipboard.setData(ClipboardData(text: content));
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> generateShareLink({
    required ShareableType type,
    String? entryId,
    String? tripId,
    String? mediaId,
  }) async {
    // TODO: Implement in subtask 8.3 (public trip sharing links)
    // This will integrate with backend API to generate shareable URLs
    return null;
  }

  /// Get XFile from media item
  Future<XFile?> _getXFileFromMedia(MediaItem media) async {
    try {
      // For remote files, we'd need to download them first
      // For now, this is a placeholder for future implementation
      if (media.storagePath.startsWith('http')) {
        // Download to temp file
        // TODO: Implement download logic
        return null;
      } else {
        // Local file
        return XFile(media.storagePath);
      }
    } catch (e) {
      return null;
    }
  }

  /// Truncate text to fit platform limits
  String _truncateTextForPlatform(String text, SharePlatform platform) {
    final maxLength =
        maxTextLengths[platform] ?? maxTextLengths[SharePlatform.generic]!;

    if (text.length <= maxLength) {
      return text;
    }

    return '${text.substring(0, maxLength - 3)}...';
  }
}
