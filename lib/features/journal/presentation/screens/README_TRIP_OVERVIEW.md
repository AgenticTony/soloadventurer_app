# Trip Overview Screen

## Overview

The `TripOverviewScreen` displays all journal entries and media items for a specific trip in a unified, scrollable view. It provides a comprehensive overview of trip content with statistics, entry cards, and media gallery.

## Features

- **Trip Statistics**: Display entry count, media count, and trip duration
- **Journal Entries List**: Shows all entries sorted by date (newest first)
  - Entry title, date, time, and location
  - Mood indicator with emoji
  - Content preview
  - Favorite indicator
  - Tap to view full entry details
- **Media Gallery**: Grid view of all photos and videos from the trip
  - 3-column grid layout
  - Thumbnail images with error handling
  - Video indicator icon
  - Upload status overlay (for uploading/failed media)
- **Pull-to-Refresh**: Reload content with swipe gesture
- **Loading States**: Separate loading indicators for entries and media
- **Empty States**: Helpful messages when no entries or media exist
- **Error Handling**: User-friendly error display with retry option
- **Material Design 3**: Full theme integration with consistent styling

## Architecture

### State Management

Uses Riverpod with `TripOverviewProvider` for state management:

```dart
final tripOverviewProvider = StateNotifierProvider.family<TripOverviewNotifier, TripOverviewState, String>((ref, tripId) {
  final repository = ref.watch(journalRepositoryProvider);
  final notifier = TripOverviewNotifier(repository);
  Future.microtask(() => notifier.loadTripContent(tripId));
  return notifier;
});
```

**State Class:**
- `entries`: List of journal entries for the trip
- `mediaItems`: List of media items for the trip
- `isLoadingEntries`: Whether entries are loading
- `isLoadingMedia`: Whether media is loading
- `error`: Error message if loading failed

**Computed Properties:**
- `isLoading`: True if either entries or media are loading
- `entryCount`: Total number of entries
- `mediaCount`: Total number of media items
- `hasContent`: True if there are entries or media
- `sortedEntries`: Entries sorted by date (newest first)
- `sortedMedia`: Media sorted by created date (newest first)

**Methods:**
- `loadTripContent(tripId)`: Loads all entries and media for a trip (parallel loading)
- `refresh()`: Reloads current trip content
- `clearError()`: Clears error state

### Data Sources

The screen fetches data from `JournalRepository`:
- `getEntriesByTrip(tripId)`: Retrieves all journal entries for the trip
- `getMediaForTrip(tripId)`: Retrieves all media items for the trip

## Usage

### Basic Navigation

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TripOverviewScreen(tripId: trip.id),
  ),
);
```

### Provider Setup

Before using the screen, you must override the `journalRepositoryProvider`:

```dart
// In your main app or provider container
journalRepositoryProvider.overrideWithValue(journalRepository);
```

### Customization

#### Modify Entry Card Layout

Edit the `_buildEntryCard` method to customize:
- Card styling and padding
- Information display (title, date, location, mood)
- Content preview length
- Tap behavior

#### Adjust Media Grid

Modify the `buildMediaGrid` method:
- Change `crossAxisCount` for more/fewer columns
- Adjust spacing with `crossAxisSpacing` and `mainAxisSpacing`
- Change aspect ratio with `childAspectRatio`

#### Statistics Section

Customize the `_buildStatistics` method to:
- Add/remove statistics
- Change layout from Row to Column
- Modify icons and labels

## UI Components

### Trip Cover Image

The app bar displays the trip's cover image if available, with a gradient placeholder as fallback:

```dart
background: trip.coverImageUrl != null
    ? Image.network(trip.coverImageUrl!, fit: BoxFit.cover, ...)
    : _buildPlaceholder(context),
```

### Statistics Card

Shows three key metrics in a horizontal row:
- **Entries**: Total journal entries for the trip
- **Media**: Total photos and videos
- **Duration**: Trip duration in days

### Entry Card

Each entry card displays:
- Title (with favorite icon if applicable)
- Date and time (e.g., "Jan 15, 2026 at 2:30 PM")
- Location name (if available)
- Mood emoji and label (if set)
- Content preview (2 lines max)

Cards are tappable and navigate to `JournalEntryDetailScreen`.

### Media Thumbnail

Media items in the grid show:
- Thumbnail image (or placeholder if loading/failed)
- Video icon overlay for video files
- Upload progress/failed status overlay

### Empty States

Two types of empty states:

1. **No Entries**: Shown when trip has no journal entries
   - Icon: `Icons.note_alt_outlined`
   - Message: "No entries yet"
   - Subtext: "Start documenting your trip adventures"

2. **No Media**: Media section is hidden if no media items exist

### Error State

If loading fails, displays:
- Error icon
- Error message
- Retry button (trips are reloaded via tripDetailProvider)

## Error Handling

### Loading Errors

The screen handles errors from both trip details and content loading:

```dart
detailState.error != null
    ? _buildError(context, detailState.error!)
    : // render content
```

### Network Errors

Image loading uses error builders:
```dart
Image.network(
  url,
  errorBuilder: (context, error, stackTrace) {
    return _buildMediaPlaceholder(context, media);
  },
)
```

### Empty Content

Gracefully handles trips with:
- No entries (shows empty state)
- No media (hides media section)
- No content at all (shows both empty states)

## Performance Considerations

### Parallel Loading

Entries and media are loaded in parallel using `Future.wait`:

```dart
final results = await Future.wait([
  _repository.getEntriesByTrip(tripId),
  _repository.getMediaForTrip(tripId),
]);
```

### Lazy Rendering

- Uses `CustomScrollView` for efficient scrolling
- Media grid uses `shrinkWrap: true` to size itself
- No unnecessary rebuilds

### Image Loading

- Network images are loaded asynchronously
- Error handling prevents app crashes on invalid URLs
- Placeholders shown during loading

## Integration with Other Features

### Journal Entry Detail Screen

Tapping an entry card navigates to the full entry view:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => JournalEntryDetailScreen(entryId: entry.id),
  ),
);
```

### Trip Detail Screen

The trip detail screen has two navigation points:
1. "Journal Entries" card → navigates to trip overview
2. "Media Gallery" card → navigates to trip overview

### Tag System

When tag display is implemented (future), entry cards can show associated tags.

## Future Enhancements

### Planned Features

1. **Filtering and Sorting**
   - Filter by mood
   - Filter by date range
   - Sort by popularity/views
   - Filter by tags

2. **Batch Operations**
   - Select multiple entries
   - Delete multiple entries
   - Move entries to another trip
   - Export multiple entries

3. **Media Viewer Integration**
   - Fullscreen media viewing
   - Swipe between photos/videos
   - Zoom and pan support
   - Video playback controls

4. **Enhanced Statistics**
   - Most visited locations
   - Mood distribution chart
   - Word cloud from entry content
   - Timeline view of activity

5. **Search Functionality**
   - Search within trip entries
   - Filter by location
   - Search by date

6. **Offline Support**
   - Cache entries and media
   - Show offline indicator
   - Queue changes for sync

## Testing

### Manual Testing Checklist

- [ ] Load trip with entries and media
- [ ] Load trip with entries but no media
- [ ] Load trip with media but no entries
- [ ] Load trip with no content (empty state)
- [ ] Test pull-to-refresh
- [ ] Tap entry card → navigates to detail screen
- [ ] Test with network errors
- [ ] Test with invalid image URLs
- [ ] Verify statistics are accurate
- [ ] Check media grid layout (different screen sizes)
- [ ] Test video indicator display
- [ ] Verify upload status overlays
- [ ] Test empty state messages
- [ ] Verify error state and retry

### Widget Testing Example

```dart
testWidgets('TripOverviewScreen displays entries', (tester) async {
  // Mock repository with test data
  when(() => mockRepository.getEntriesByTrip('trip1'))
      .thenAnswer((_) async => [testEntry1, testEntry2]);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        journalRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        home: TripOverviewScreen(tripId: 'trip1'),
      ),
    ),
  );

  expect(find.text('Test Entry Title'), findsWidgets);
});
```

## Troubleshooting

### Common Issues

**Problem: Entries not loading**
- Verify `journalRepositoryProvider` is properly overridden
- Check that `getEntriesByTrip` returns data
- Ensure user is authenticated

**Problem: Images not displaying**
- Check Supabase storage permissions
- Verify `storagePath` is correct
- Ensure network access is available

**Problem: Statistics show incorrect counts**
- Verify repository methods return correct counts
- Check for duplicate entries/media
- Ensure proper error handling in repository

**Problem: Navigation not working**
- Verify `JournalEntryDetailScreen` route is configured
- Check that entry IDs are valid
- Ensure MaterialApp has proper routes

### Debug Mode

Add debug prints to understand state changes:

```dart
@override
Widget build(BuildContext context) {
  final overviewState = ref.watch(tripOverviewProvider(widget.tripId));
  print('Entries: ${overviewState.entryCount}, Media: ${overviewState.mediaCount}');
  // ...
}
```

## Related Files

- `lib/features/journal/presentation/providers/trip_overview_provider.dart` - State management
- `lib/features/journal/presentation/providers/trip_providers.dart` - Trip detail provider
- `lib/features/journal/presentation/screens/journal_entry_detail_screen.dart` - Entry detail view
- `lib/features/journal/presentation/screens/trip_detail_screen.dart` - Trip detail view
- `lib/features/journal/domain/repositories/journal_repository.dart` - Data repository interface

## Migration Notes

If migrating from an older version:

1. **Provider Setup**: Ensure `journalRepositoryProvider` is overridden in your app
2. **Navigation**: Update navigation calls to use `TripOverviewScreen`
3. **Trip Detail Screen**: Remove "Coming soon" placeholders and use new navigation

## Contributing

When contributing to this screen:

1. Follow existing code patterns and styling
2. Add comprehensive error handling
3. Update documentation for new features
4. Include examples in README
5. Test with empty states and error cases
6. Ensure Material Design 3 compliance
