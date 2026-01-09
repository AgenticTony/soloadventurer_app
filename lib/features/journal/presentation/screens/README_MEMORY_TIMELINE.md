# Memory Timeline Screen

A chronological timeline view of all travel experiences, displaying journal entries grouped by time periods (today, yesterday, this week, this month, this year, and older entries by month/year).

## Features

- ✅ **Automatic grouping** by time periods (today, yesterday, this week, etc.)
- ✅ **Visual timeline** with connecting lines between entries
- ✅ **Entry cards** with title, date, mood, location, and content preview
- ✅ **Media thumbnails** showing up to 3 media items per entry
- ✅ **Pull-to-refresh** for updating timeline data
- ✅ **Empty state** with call-to-action
- ✅ **Error handling** with retry functionality
- ✅ **Material Design 3** styling with theme integration
- ✅ **Tap-to-navigate** to entry detail screen
- ✅ **Summary header** showing total entries and time periods

## Architecture

The memory timeline consists of three main components:

1. **MemoryTimelineProvider** (`memory_timeline_provider.dart`)
   - State management for timeline data
   - Fetches all journal entries from repository
   - Groups entries by time periods
   - Loads media for each entry

2. **TimelineItem** (`timeline_item.dart`)
   - Reusable widget for displaying individual entries
   - Shows title, date, mood, location, content preview
   - Displays media thumbnails with video indicators
   - Supports tap callbacks for navigation

3. **MemoryTimelineScreen** (`memory_timeline_screen.dart`)
   - Main screen displaying the full timeline
   - Groups with headers and icons
   - Pull-to-refresh support
   - Empty and error states

## Installation

Add the required dependencies to `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.3.6
  intl: ^0.18.0
```

## Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:soloadventurer/features/journal/presentation/screens/memory_timeline_screen.dart';
import 'package:soloadventurer/features/journal/presentation/providers/memory_timeline_provider.dart';
import 'package:soloadventurer/features/journal/data/repositories/journal_repository_impl.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// In your app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // Inject the journal repository
        journalRepositoryProvider.overrideWithValue(
          JournalRepositoryImpl(
            JournalRemoteDataSourceImpl(Supabase.instance.client),
          ),
        ),
      ],
      child: MaterialApp(
        home: MemoryTimelineScreen(),
      ),
    );
  }
}
```

### Navigation

```dart
// Navigate from any screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MemoryTimelineScreen(),
  ),
);
```

## State Management

The timeline uses Riverpod for state management with the following providers:

### memoryTimelineProvider

Main state notifier that manages timeline data.

```dart
final timelineState = ref.watch(memoryTimelineProvider);

// Access properties
print(timelineState.entryCount);        // Total number of entries
print(timelineState.groupCount);        // Number of time period groups
print(timelineState.hasContent);        // Whether timeline has content
print(timelineState.groups);            // List of timeline groups
print(timelineState.allEntries);        // All entries flattened
print(timelineState.mediaByEntry);      // Map of entry ID to media items
```

### Methods

```dart
// Refresh timeline data
await ref.read(memoryTimelineProvider.notifier).refresh();

// Clear error state
ref.read(memoryTimelineProvider.notifier).clearError();
```

## Timeline Groups

Entries are automatically grouped into time periods:

| Group Type | Description | Example |
|-----------|-------------|---------|
| **Today** | Entries from today | "Today" |
| **Yesterday** | Entries from yesterday | "Yesterday" |
| **This Week** | Entries from this week | "This Week" (1/1 - 1/7) |
| **This Month** | Entries from this month | "This Month" (January) |
| **This Year** | Entries from this year | "This Year" |
| **Month** | Older entries by month | "December 2023" |

### TimelineGroup

```dart
class TimelineGroup {
  final String title;              // Display title
  final String? subtitle;          // Optional subtitle
  final List<JournalEntry> entries; // Entries in this group
  final TimelineGroupType type;    // Group type enum
}
```

## TimelineItem Widget

Reusable widget for displaying individual entries in the timeline.

### Properties

```dart
TimelineItem(
  entry: journalEntry,              // Required: The journal entry
  mediaItems: [media1, media2],     // Media items for this entry
  onTap: () => print('Tapped'),    // Callback when tapped
  showFullContent: false,           // Show full content or preview
  maxMediaThumbnails: 3,            // Max number of media thumbnails
)
```

### Features

- **Header**: Title with favorite icon
- **Metadata**: Date and time display
- **Mood**: Colored mood indicator with emoji
- **Content**: Text preview (3 lines by default)
- **Media**: Up to 3 thumbnails with video indicators
- **Location**: Location name with icon

## Customization

### Modify Grouping Logic

Edit `_groupEntries()` in `memory_timeline_provider.dart`:

```dart
List<TimelineGroup> _groupEntries(List<JournalEntry> entries) {
  // Custom grouping logic here
  // For example: group by trip instead of date
}
```

### Change Timeline Styling

Edit `MemoryTimelineScreen.build()` to customize:

```dart
// Modify colors, spacing, etc.
Card(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  // Custom styling
)
```

### Custom TimelineItem

```dart
TimelineItem(
  entry: entry,
  mediaItems: media,
  showFullContent: true,          // Show full content instead of preview
  maxMediaThumbnails: 5,          // Show up to 5 thumbnails
  onTap: () => customNavigation(), // Custom navigation
)
```

## Error Handling

The timeline includes comprehensive error handling:

```dart
// Loading state
if (timelineState.isLoading) {
  return CircularProgressIndicator();
}

// Error state
if (timelineState.error != null) {
  return ErrorWidget(
    error: timelineState.error!,
    onRetry: () => ref.read(memoryTimelineProvider.notifier).refresh(),
  );
}

// Empty state
if (!timelineState.hasContent) {
  return EmptyStateWidget(
    onAction: () => Navigator.pushNamed(context, '/journal/create'),
  );
}
```

## Performance Considerations

1. **Parallel Loading**: Media items are loaded in parallel for efficiency
2. **Lazy Rendering**: Timeline groups are rendered on-demand
3. **Media Throttling**: Only up to 3 thumbnails shown per entry
4. **Debouncing**: Consider adding search/filter debouncing if implementing filters

## Future Enhancements

Potential improvements to the timeline:

- [ ] **Filter by Trip**: Show entries from specific trip only
- [ ] **Filter by Mood**: Show entries with specific mood
- [ ] **Filter by Tags**: Show entries with specific tags
- [ ] **Favorites Only**: Toggle to show only favorite entries
- [ ] **Search**: Full-text search within timeline
- [ ] **Export**: Export timeline as PDF or share
- [ ] **Animation**: Add entry animations when scrolling
- [ ] **Infinite Scroll**: Load entries in chunks for large datasets
- [ ] **Map View**: Switch to map view showing entry locations
- [ ] **Statistics**: Show travel statistics and insights

## Integration Examples

### With Bottom Navigation

```dart
Scaffold(
  body: PageView(
    children: [
      HomeScreen(),
      MemoryTimelineScreen(), // Timeline tab
      ProfileScreen(),
    ],
  ),
  bottomNavigationBar: BottomNavigationBar(
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Timeline'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
  ),
)
```

### With Floating Action Button

```dart
Scaffold(
  appBar: AppBar(title: Text('My Timeline')),
  body: MemoryTimelineScreen(),
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () {
      Navigator.pushNamed(context, '/journal/create');
    },
    icon: Icon(Icons.add),
    label: Text('New Entry'),
  ),
)
```

### From Dashboard

```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        DashboardCard(
          title: 'My Timeline',
          icon: Icons.timeline,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MemoryTimelineScreen(),
              ),
            );
          },
        ),
        // More cards...
      ],
    );
  }
}
```

## Testing

### Widget Test Example

```dart
testWidgets('MemoryTimelineScreen displays entries', (tester) async {
  // Mock the repository
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        journalRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(home: MemoryTimelineScreen()),
    ),
  );

  // Verify timeline is displayed
  expect(find.text('Memory Timeline'), findsOneWidget);
  expect(find.byType(TimelineItem), findsWidgets);
});
```

## Troubleshooting

### Timeline Not Loading

- Verify `journalRepositoryProvider` is properly injected
- Check Supabase client initialization
- Ensure user is authenticated
- Check network connection

### Media Not Showing

- Verify storage bucket RLS policies
- Check signed URL generation
- Ensure media items are linked to entries
- Verify `getMediaForEntry()` is working

### Grouping Not Working

- Check entry dates are in UTC
- Verify timezone handling in date comparisons
- Ensure entries are sorted by date before grouping

## Related Components

- **JournalEntryDetailScreen**: View full entry details
- **JournalSearchScreen**: Search and filter entries
- **TripOverviewScreen**: View entries by trip
- **MediaGallery**: View media from entries
- **TimelineItem**: Individual timeline entry widget

## API Reference

### MemoryTimelineState

```dart
class MemoryTimelineState {
  final List<TimelineGroup> groups;              // Time period groups
  final List<JournalEntry> allEntries;           // All entries
  final Map<String, List<MediaItem>> mediaByEntry; // Media by entry
  final bool isLoading;                          // Loading state
  final String? error;                           // Error message
  int get entryCount;                            // Total entries
  int get groupCount;                            // Total groups
  bool get hasContent;                           // Has content
}
```

### TimelineGroupType Enum

```dart
enum TimelineGroupType {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  thisYear,
  month,
  year,
}
```

## License

This component is part of the SoloAdventurer application.
