# Social Sharing Service

Comprehensive social sharing functionality for travel journal entries, media items, and trips.

## Features

- **Share Journal Entries** - Share individual journal entries with text, location, date, and mood
- **Share Media** - Share photos and videos directly to social platforms
- **Share Trips** - Share entire trip summaries with entry counts
- **Share Multiple Entries** - Share multiple entries at once
- **Multiple Platforms** - Support for Facebook, Twitter, Instagram, WhatsApp, Telegram, SMS, Email, and clipboard
- **Custom Configuration** - Fully customizable share text, hashtags, and formatting
- **Smart Formatting** - Auto-generates appropriate content for each platform
- **Platform-Aware** - Respects text limits for different platforms

## Installation

The social sharing feature uses the `share_plus` package which is already included in `pubspec.yaml`:

```yaml
dependencies:
  share_plus: ^10.1.2
```

## Quick Start

### Basic Usage

The easiest way to add sharing is using the `SocialShareSheet` widget:

```dart
// Share a journal entry
SocialShareSheet.show(
  context: context,
  contentType: ShareableType.journalEntry,
  entry: journalEntry,
  onShareComplete: () {
    // Optional: Handle completion
  },
);
```

### Using the Share Button Widget

For quick integration, use the `SocialShareButton` widget:

```dart
SocialShareButton(
  contentType: ShareableType.journalEntry,
  entry: journalEntry,
)
```

## Usage Examples

### 1. Share Journal Entry with Media

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/social_share_sheet.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';

class JournalEntryDetailScreen extends ConsumerWidget {
  final JournalEntry entry;

  const JournalEntryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
        actions: [
          // Add share button to app bar
          SocialShareButton(
            contentType: ShareableType.journalEntry,
            entry: entry,
          ),
        ],
      ),
      body: // Entry content...
    );
  }
}
```

### 2. Share Media Item

```dart
// In a media viewer or gallery
SocialShareSheet.show(
  context: context,
  contentType: ShareableType.mediaItem,
  media: mediaItem,
  entry: parentEntry, // Optional: provides context
);
```

### 3. Share Trip

```dart
// In trip detail screen
SocialShareButton(
  contentType: ShareableType.trip,
  trip: trip,
)
```

### 4. Share Multiple Entries

```dart
// Share selected entries
List<JournalEntry> selectedEntries = [...];

SocialShareSheet.show(
  context: context,
  contentType: ShareableType.multipleEntries,
  entries: selectedEntries,
);
```

### 5. Custom Share Configuration

```dart
final notifier = ref.read(socialSharingNotifierProvider.notifier);

// Generate custom config
final customConfig = ShareConfig(
  title: 'My Adventure',
  text: 'Check out what I discovered!',
  hashtags: ['travel', 'adventure', 'wanderlust'],
  includeLocation: true,
  includeDate: true,
  includeMood: false,
);

// Share with custom config
await notifier.shareEntry(
  entry: entry,
  platform: SharePlatform.twitter,
  config: customConfig,
  includeMedia: false,
);
```

### 6. Platform-Specific Sharing

```dart
// Share directly to Twitter
await ref.read(socialSharingNotifierProvider.notifier).shareEntry(
  entry: entry,
  platform: SharePlatform.twitter,
  includeMedia: true,
);

// Share directly to WhatsApp
await ref.read(socialSharingNotifierProvider.notifier).shareEntry(
  entry: entry,
  platform: SharePlatform.whatsapp,
);

// Copy to clipboard
await ref.read(socialSharingNotifierProvider.notifier).shareEntry(
  entry: entry,
  platform: SharePlatform.clipboard,
);
```

### 7. Using the Service Directly

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(socialSharingServiceProvider);

    // Generate share config
    final config = service.generateEntryShareConfig(
      entry,
      customHashtags: ['mytravel', 'adventure'],
      includeLocation: true,
    );

    // Share
    ElevatedButton(
      onPressed: () async {
        final result = await service.shareEntry(
          entry,
          platform: SharePlatform.generic,
          config: config,
        );

        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Shared successfully!')),
          );
        }
      },
      child: Text('Share Entry'),
    );
  }
}
```

## Platform Support

The following platforms are supported:

| Platform | Text Limit | Media Support | Notes |
|----------|-----------|---------------|-------|
| Generic (Share Sheet) | ∞ | ✅ | Native share sheet, shows all available apps |
| Facebook | 63,206 | ✅ | Full text and media support |
| Twitter | 280 | ✅ | Text truncated if needed |
| Instagram | 2,200 | ✅ | Primarily for photos/videos |
| WhatsApp | 65,536 | ✅ | Full support |
| Telegram | 65,536 | ✅ | Full support |
| SMS | 160 | ❌ | Text only, truncated if needed |
| Email | 65,536 | ✅ | Full support |
| Clipboard | ∞ | ❌ | Copies text to clipboard |

## Configuration Options

### ShareConfig

```dart
ShareConfig(
  title: 'Title of shared content',
  text: 'Main text content',
  url: 'https://optional-url.com',
  imagePaths: ['path/to/image1.jpg', 'path/to/image2.jpg'],
  videoPath: 'path/to/video.mp4',
  hashtags: ['travel', 'adventure'],
  includeLocation: true,
  includeDate: true,
  includeMood: true,
  messageTemplate: '{title}\n{text}\n📍 {location}',
)
```

### Message Template Variables

Custom message templates support these variables:

- `{title}` - Entry title
- `{text}` - Entry content/text
- `{location}` - Location name
- `{date}` - Entry date (formatted)
- `{mood}` - Mood emoji/text

Example:

```dart
ShareConfig(
  messageTemplate: '🌍 {title}\n\n{text}\n\n📍 {location} 📅 {date} 😊 {mood}',
  // ...
)
```

## State Management

The sharing feature uses Riverpod for state management:

```dart
// Watch sharing state
final sharingState = ref.watch(socialSharingNotifierProvider);

if (sharingState.isSharing) {
  // Show loading indicator
} else if (sharingState.isSuccess) {
  // Show success message
  print('Shared: ${sharingState.result}');
} else if (sharingState.isFailed) {
  // Show error
  print('Error: ${sharingState.error}');
}
```

## Advanced Usage

### Custom Hashtags

```dart
final config = service.generateEntryShareConfig(
  entry,
  customHashtags: ['#travel', '#adventure', '#soloadventurer'],
);
```

### Platform Availability Check

```dart
final service = ref.read(socialSharingServiceProvider);
final isAvailable = await service.isPlatformAvailable(SharePlatform.whatsapp);

if (isAvailable) {
  // Share to WhatsApp
}
```

### Get Available Platforms

```dart
final platforms = await service.getAvailablePlatforms();
// Returns: [SharePlatform.generic, SharePlatform.facebook, ...]
```

### Handle Share Result

```dart
final result = await service.shareEntry(entry);

if (result.success) {
  print('Shared to ${result.platform}');
  print('Format: ${result.format}');
  print('Items: ${result.itemCount}');
  print('Copied to clipboard: ${result.wasCopiedToClipboard}');
} else {
  print('Failed: ${result.errorMessage}');
}
```

## UI Components

### SocialShareSheet

A bottom sheet modal for selecting sharing platforms:

```dart
SocialShareSheet.show(
  context: context,
  contentType: ShareableType.journalEntry,
  entry: entry,
  onShareComplete: () {
    Navigator.pop(context);
  },
);
```

**Features:**
- Platform grid with icons
- Media inclusion toggle (for entries)
- Success/error feedback
- Loading indicator during share
- Auto-close on success

### SocialShareButton

A simple icon button for quick access:

```dart
SocialShareButton(
  contentType: ShareableType.journalEntry,
  entry: entry,
  onShareComplete: () {
    // Refresh or update UI
  },
)
```

## Best Practices

1. **Provide Context** - Always include entry context when sharing media
   ```dart
   service.shareMedia(media, entry: parentEntry)
   ```

2. **Handle Errors** - Check share results and show feedback
   ```dart
   final result = await service.shareEntry(entry);
   if (!result.success) {
     showError(result.errorMessage);
   }
   ```

3. **Respect Platform Limits** - Text is automatically truncated for platforms like Twitter and SMS

4. **Include Relevant Hashtags** - Use relevant hashtags to increase engagement
   ```dart
   customHashtags: ['travel', countryName, 'adventure']
   ```

5. **Consider Media** - Media files can be large, consider offering option to exclude
   ```dart
   includeMedia: true // Can be toggled in UI
   ```

## Testing

### Manual Testing

1. Test each platform to ensure share works correctly
2. Verify text truncation for platforms with limits
3. Test media sharing (photos and videos)
4. Verify clipboard functionality
5. Test error handling (network issues, file access, etc.)

### Automated Testing

```dart
test('Share journal entry', () async {
  final result = await service.shareEntry(testEntry);

  expect(result.success, true);
  expect(result.contentType, ShareableType.journalEntry);
  expect(result.platform, SharePlatform.generic);
});

test('Generate share config', () {
  final config = service.generateEntryShareConfig(testEntry);

  expect(config.title, testEntry.title);
  expect(config.hashtags, isNotEmpty);
});
```

## Troubleshooting

### Share doesn't work on specific platform

- Check if platform is available on device
- Verify app has necessary permissions
- Ensure files are accessible

### Media not sharing

- Verify media upload status is `completed`
- Check file paths are valid
- Ensure storage permissions are granted

### Text truncated unexpectedly

- Check platform-specific text limits
- Adjust message template to be shorter
- Consider sharing link instead of full content

### Clipboard not working

- Some platforms restrict clipboard access
- Ensure app has necessary permissions
- Consider alternative like sharing to notes app

## Future Enhancements

- **Public Sharing Links** (Subtask 8.3) - Generate shareable URLs
- **Advanced Media Editing** - Crop/filter photos before sharing
- **Story Templates** - Pre-formatted templates for Instagram Stories
- **Share Analytics** - Track shares and engagement
- **Scheduling** - Schedule posts for later
- **Cross-Posting** - Share to multiple platforms at once
- **Custom Platform Integration** - Direct SDK integration for Facebook, Instagram, etc.

## API Reference

### SocialSharingService

```dart
abstract class SocialSharingService {
  Future<ShareResult> shareEntry(
    JournalEntry entry, {
    SharePlatform platform,
    ShareConfig? config,
    bool includeMedia,
    List<MediaItem>? mediaItems,
  });

  Future<ShareResult> shareMedia(
    MediaItem media, {
    SharePlatform platform,
    ShareConfig? config,
    JournalEntry? entry,
  });

  Future<ShareResult> shareTrip(
    Trip trip, {
    SharePlatform platform,
    ShareConfig? config,
    int entryCount,
  });

  Future<ShareResult> shareMultipleEntries(
    List<JournalEntry> entries, {
    SharePlatform platform,
    ShareConfig? config,
  });

  ShareConfig generateEntryShareConfig(JournalEntry entry, {...});
  ShareConfig generateMediaShareConfig(MediaItem media, {...});
  ShareConfig generateTripShareConfig(Trip trip, {...});

  Future<bool> isPlatformAvailable(SharePlatform platform);
  Future<List<SharePlatform>> getAvailablePlatforms();
  Future<bool> copyToClipboard(String content);
}
```

### Enums

#### ShareableType
```dart
enum ShareableType {
  journalEntry,
  mediaItem,
  trip,
  multipleEntries,
}
```

#### SharePlatform
```dart
enum SharePlatform {
  generic,    // Native share sheet
  facebook,
  twitter,
  instagram,
  whatsapp,
  telegram,
  sms,
  email,
  clipboard,
  more,
}
```

#### ShareFormat
```dart
enum ShareFormat {
  text,
  image,
  video,
  link,
  rich,
}
```

## Related Features

- **PDF Export** (Subtask 8.1) - Export trips to PDF
- **Public Sharing Links** (Subtask 8.3) - Generate shareable URLs (coming soon)
- **Backup & Restore** (Subtask 8.4) - Backup all journal data (coming soon)

## Contributing

When contributing to the social sharing feature:

1. Follow existing code patterns and Clean Architecture
2. Add comprehensive documentation for new features
3. Include usage examples in this README
4. Update test cases for new functionality
5. Test on multiple platforms (Android, iOS)

## License

This feature is part of the SoloAdventurer travel journal application.
