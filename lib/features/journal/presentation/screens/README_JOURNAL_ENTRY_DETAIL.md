# Journal Entry Detail Screen

Complete implementation of a screen for viewing individual journal entries with all content, media, and metadata.

## Files

- **`journal_entry_detail_screen.dart`** - Main screen widget
- **`journal_entry_detail_provider.dart`** - State management provider
- **`rich_text_viewer.dart`** - Read-only rich text content viewer
- **`journal_entry_detail_screen_example.dart`** - Usage examples and documentation

## Features

### ✅ Implemented
- Display journal entry title, date, and rich text content
- Show location information if available
- Show mood indicator with emoji
- Favorite toggle functionality
- Edit and delete actions
- Sync status indicator for offline support
- Refresh/pull-to-refresh support
- Error handling and loading states
- Entry not found state
- Navigation integration with route arguments

### 🔜 Coming Soon (Future Phases)
- Media gallery viewer (Phase 3 - Media Upload & Management)
- Full edit functionality (Phase 2+)
- Share functionality (Phase 8 - Export & Sharing)
- Trip information with navigation (Phase 5 - Organization & Tagging)

## Architecture

### State Management
Uses `StateNotifierProvider` from Riverpod for state management:

```dart
final journalEntryDetailProvider = StateNotifierProvider.family<
    JournalEntryDetailNotifier, JournalEntryDetailState, String>(
  (ref, entryId) {
    final repository = ref.watch(journalRepositoryProvider);
    return JournalEntryDetailNotifier(repository, entryId);
  },
);
```

### State Class
```dart
class JournalEntryDetailState {
  final JournalEntry? entry;
  final List<MediaItem> mediaItems;
  final bool isLoading;
  final String? error;
  final bool isDeleting;
}
```

### Key Actions
- `refresh()` - Reload entry data
- `deleteEntry()` - Delete the entry
- `toggleFavorite()` - Toggle favorite status
- `clearError()` - Clear error messages

## Usage

### Basic Navigation

```dart
// Navigate to entry detail
Navigator.pushNamed(
  context,
  JournalEntryDetailScreen.routeName,
  arguments: 'entry-id-here',
);
```

### With Result Handling

```dart
final result = await Navigator.pushNamed(
  context,
  JournalEntryDetailScreen.routeName,
  arguments: 'entry-id-here',
);

if (result == true) {
  // Entry was deleted, refresh your list
  _refreshEntries();
}
```

### In Your Route Configuration

```dart
routes: {
  JournalEntryDetailScreen.routeName: (context) {
    final entryId = JournalEntryDetailScreen.extractEntryId(context);
    return JournalEntryDetailScreen(entryId: entryId);
  },
},
```

## UI Components

### 1. App Bar
- Collapsible app bar with entry title
- Favorite toggle button
- Edit button (placeholder for Phase 2+)
- More options menu (Share, Delete)

### 2. Metadata Row
- Entry date and time
- Location name if available
- Icons for visual clarity

### 3. Mood Indicator
- Emoji matched to mood keyword
- Colored pill-style container
- Capitalized mood text

### 4. Rich Text Content
- Read-only viewer using Quill editor
- Supports all formatting from editor:
  - Bold, italic, underline, strikethrough
  - Headings (H1, H2, H3)
  - Lists (ordered and unordered)
  - Block quotes
  - Code blocks
  - Links

### 5. Media Section (Placeholder)
- Shows count of attached media
- Placeholder for Phase 3 implementation
- Grid layout for photos and videos

### 6. Trip Section (Placeholder)
- Shows if entry belongs to a trip
- Trip ID display
- Navigation to trip detail (Phase 5)

### 7. Sync Status Indicator
- Shows for non-synced entries
- Color-coded by status:
  - Orange: Syncing (pending)
  - Red: Conflict
  - Gray: Offline only

### 8. Metadata Footer
- Creation timestamp
- Last updated timestamp (if different)

## Customization

### Styling
The screen uses Material Design 3 theming. All colors and styles are derived from `Theme.of(context)`. To customize:

```dart
// In your theme configuration
ThemeData(
  // App bar colors
  appBarTheme: AppBarTheme(...),

  // Card colors
  cardTheme: CardTheme(...),

  // Color scheme
  colorScheme: ColorScheme(...),
)
```

### Mood Emojis
Default mood-to-emoji mapping in `_getMoodEmoji()`:
- happy/joy → 😊
- adventurous/excited → 🤩
- tired/exhausted → 😴
- sad/down → 😢
- calm/peaceful → 😌
- surprised → 😲
- love/grateful → 🥰

Customize by modifying the `_getMoodEmoji()` method.

## Error Handling

### Loading State
Shows circular progress indicator while fetching data.

### Error State
Displays error message with:
- Error icon
- Error description
- "Try Again" button to refresh

### Not Found State
Friendly message when entry doesn't exist.

### Delete Confirmation
Dialog with:
- Warning message
- Cancel button
- Delete button (red text)

## Testing

### Manual Testing Checklist
- [ ] View entry with all fields populated
- [ ] View entry with minimal data (title + content only)
- [ ] Test favorite toggle
- [ ] Test delete flow
- [ ] Test error state (use invalid entry ID)
- [ ] Test loading state
- [ ] Test refresh functionality
- [ ] Test navigation with route arguments
- [ ] Test return value after delete
- [ ] Verify responsive layout on different screen sizes

### Example Test Data
```dart
final testEntry = JournalEntry(
  id: 'test-id',
  userId: 'user-123',
  title: 'Amazing Day in Paris',
  content: '{"ops":[{"insert":"Had a wonderful time exploring the city!\\n"}]}',
  entryDate: DateTime.now(),
  mood: 'adventurous',
  locationName: 'Paris, France',
  latitude: 48.8566,
  longitude: 2.3522,
  isFavorite: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

## Integration with Repository

The screen integrates with `JournalRepository` from Phase 2.3:

```dart
// Fetch entry
final entry = await repository.getEntry(entryId);

// Fetch media items
final mediaItems = await repository.getMediaForEntry(entryId);

// Update favorite
await repository.updateEntry(entry.copyWith(isFavorite: !entry.isFavorite));

// Delete entry
await repository.deleteEntry(entryId);
```

## Dependencies

- `flutter_riverpod` - State management
- `flutter_quill` - Rich text display
- `intl` - Date formatting

## Future Enhancements

### Phase 2+ - Edit Functionality
- Edit button should navigate to edit screen
- Pass entry data to edit form
- Handle save result

### Phase 3 - Media Gallery
- Implement media grid display
- Add image viewer
- Add video player
- Show upload progress for pending uploads

### Phase 5 - Trip Integration
- Fetch and display trip name
- Navigate to trip detail screen
- Show trip dates and destination

### Phase 8 - Sharing
- Share entry as text
- Share as PDF
- Generate shareable link

### Offline Support (Phase 7)
- Show offline indicator
- Queue delete for sync
- Conflict resolution UI

## Troubleshooting

### Entry Not Loading
- Check that `entryId` is passed correctly
- Verify repository is properly injected
- Check network connectivity
- Look for errors in state

### Rich Text Not Displaying
- Ensure content is in Delta JSON format
- Check that content string is valid JSON
- Verify `flutter_quill` is properly initialized

### Route Not Found
- Verify route name is registered in your router
- Check that `extractEntryId()` is being called
- Ensure arguments are passed as String

## See Also
- [Create Journal Entry Screen](./create_journal_entry_screen.dart)
- [Journal Repository](../../data/repositories/journal_repository_impl.dart)
- [Rich Text Editor](../widgets/rich_text_editor.dart)
- [Journal Entities](../../../domain/entities/)
