# Journal Search Functionality

Comprehensive search and filter system for journal entries with support for text search, location, date range, mood, favorites, and tags.

## Features

### Search Capabilities
- ✅ **Full-text search** across entry titles and content
- ✅ **Location filtering** by location name
- ✅ **Date range filtering** with start and end dates
- ✅ **Mood filtering** with emoji support
- ✅ **Favorites filter** to show only favorite entries
- ✅ **Multiple filter combinations** for refined searches
- ✅ **Real-time search** with debouncing
- ✅ **Filter chips** showing active filters
- ✅ **Pull-to-refresh** for updating results
- ✅ **Empty states** with helpful messages
- ✅ **Error handling** with retry functionality

## Architecture

### Components

#### 1. **JournalSearchProvider** (`journal_search_provider.dart`)

State management for search functionality using Riverpod.

**Key Classes:**
- `JournalSearchFilters` - Encapsulates all search filters
- `JournalSearchState` - Manages search results and UI state
- `JournalSearchNotifier` - Business logic for search operations

**Features:**
- Debounced text search (500ms delay)
- Client-side filtering for location, date, mood, favorites
- Tag filtering via repository calls
- Error handling and loading states
- Filter management (add, remove, clear)

#### 2. **JournalSearchScreen** (`journal_search_screen.dart`)

Main search screen with search bar and results.

**UI Components:**
- Search bar with auto-search
- Filter button with active filter badge
- Clear filters button
- Active filter chips (horizontal scrollable)
- Search results list with cards
- Empty and error states
- Pull-to-refresh support

**Features:**
- Real-time search as user types
- Tap result card to view entry details
- Visual feedback for all actions
- Responsive layout

#### 3. **JournalSearchFilterSheet** (`journal_search_filter_sheet.dart`)

Modal bottom sheet for configuring filters.

**Filter Sections:**
- Date range picker (from/to dates)
- Location name text input
- Mood selection with filter chips
- Favorites toggle switch
- Clear all filters option

**Features:**
- Scrollable content for small screens
- Apply button to trigger search
- Visual filter chips for mood selection
- Date picker integration
- Clear individual filters

## Installation & Setup

### 1. Provider Configuration

Ensure the `journalRepositoryProvider` is properly configured in your app's dependency injection:

```dart
// In your providers.dart or main.dart
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final dataSource = JournalRemoteDataSourceImpl(client: supabaseClient);
  return JournalRepositoryImpl(dataSource: dataSource);
});
```

### 2. Navigation

Add the search screen to your navigation:

```dart
// Example navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const JournalSearchScreen(),
  ),
);
```

Or add to your app's routing configuration.

### 3. Dependencies

The search functionality requires these packages (already in pubspec.yaml):
- `flutter_riverpod: ^2.3.6` - State management
- `equatable: ^2.0.5` - Value equality

## Usage Examples

### Basic Search

```dart
// Navigate to search screen
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JournalSearchScreen(),
      ),
    );
  },
  child: const Icon(Icons.search),
)
```

### Programmatic Search

```dart
// Set search query and trigger search
ref.read(journalSearchProvider.notifier).updateQuery('beach vacation');
ref.read(journalSearchProvider.notifier).search();

// Watch results
final searchState = ref.watch(journalSearchProvider);
if (searchState.hasResults) {
  print('Found ${searchState.resultCount} entries');
}
```

### Applying Filters Programmatically

```dart
// Date range filter
final startDate = DateTime(2024, 1, 1);
final endDate = DateTime(2024, 12, 31);
ref.read(journalSearchProvider.notifier).updateDateRangeFilter(startDate, endDate);

// Location filter
ref.read(journalSearchProvider.notifier).updateLocationFilter('Paris');

// Mood filter
ref.read(journalSearchProvider.notifier).updateMoodFilter('happy');

// Favorites filter
ref.read(journalSearchProvider.notifier).updateFavoriteFilter(true);

// Trigger search with filters
ref.read(journalSearchProvider.notifier).search();
```

### Clearing Filters

```dart
// Clear all filters except query
ref.read(journalSearchProvider.notifier).clearFilters();

// Clear everything including query
ref.read(journalSearchProvider.notifier).clearAll();
```

## State Management

### Watching Search State

```dart
Consumer(
  builder: (context, ref, child) {
    final searchState = ref.watch(journalSearchProvider);

    if (searchState.isSearching) {
      return const CircularProgressIndicator();
    }

    if (searchState.error != null) {
      return Text('Error: ${searchState.error}');
    }

    if (!searchState.hasResults) {
      return const Text('No results found');
    }

    return ListView.builder(
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final entry = searchState.results[index];
        return EntryCard(entry: entry);
      },
    );
  },
)
```

### Watching Filters

```dart
// Watch active filter count
final filterCount = ref.watch(
  journalSearchProvider.select((state) => state.filters.activeFilterCount),
);

// Watch specific filter
final locationFilter = ref.watch(
  journalSearchProvider.select((state) => state.filters.locationName),
);
```

## Customization

### Custom Filter Logic

To add custom filtering logic, extend `JournalSearchNotifier`:

```dart
class CustomSearchNotifier extends JournalSearchNotifier {
  CustomSearchNotifier(super.repository);

  @override
  List<JournalEntry> _applyFilters(
    List<JournalEntry> entries,
    JournalSearchFilters filters,
  ) {
    var filtered = super._applyFilters(entries, filters);

    // Add custom filter logic
    if (filters.customField != null) {
      filtered = filtered.where((entry) {
        return entry.customField == filters.customField;
      }).toList();
    }

    return filtered;
  }
}
```

### Custom Result Cards

Modify `_SearchResultCard` in `journal_search_screen.dart`:

```dart
class CustomResultCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const CustomResultCard({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Custom card UI
      child: ListTile(
        leading: CircleAvatar(
          child: Text(entry.title[0]),
        ),
        title: Text(entry.title),
        subtitle: Text(entry.content),
        trailing: entry.isFavorite
            ? const Icon(Icons.star)
            : null,
        onTap: onTap,
      ),
    );
  }
}
```

### Custom Filter Sheet

Extend `JournalSearchFilterSheet` to add custom filters:

```dart
class CustomFilterSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      child: Column(
        children: [
          // Add custom filter widgets
          CustomFilterWidget(
            onFilterChanged: (value) {
              // Update filters
            },
          ),
        ],
      ),
    );
  }
}
```

## Performance Considerations

### Search Optimization

1. **Debouncing**: Text search is debounced by 500ms to reduce API calls
2. **Client-side filtering**: Location, date, mood, and favorites are filtered client-side
3. **Tag filtering**: Tags require repository calls - consider caching or optimizing for large datasets

### Future Optimizations

For production with large datasets, consider:
- Server-side filtering via Supabase queries
- Full-text search with PostgreSQL tsvector
- Pagination for results (limit/offset)
- Result caching
- Search analytics

## Error Handling

The search system handles errors gracefully:

1. **Network errors**: Display error message with retry button
2. **No results**: Show helpful empty state
3. **Loading states**: Show progress indicator during search
4. **Clear error**: User can dismiss error and try again

## Testing

### Unit Tests

```dart
test('search with text query', () async {
  final notifier = JournalSearchNotifier(mockRepository);
  await notifier.search();
  expect(state.results.isNotEmpty, true);
});

test('apply date range filter', () async {
  final notifier = JournalSearchNotifier(mockRepository);
  notifier.updateDateRangeFilter(
    DateTime(2024, 1, 1),
    DateTime(2024, 12, 31),
  );
  await notifier.search();
  expect(state.results.every((e) =>
    e.entryDate.isAfter(DateTime(2024, 1, 1)) &&
    e.entryDate.isBefore(DateTime(2024, 12, 31))
  ), true);
});
```

### Widget Tests

```dart
testWidgets('search bar updates query', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: JournalSearchScreen()),
    ),
  );

  await tester.enterText(find.byType(TextField), 'beach');
  await tester.pump();

  expect(find.text('beach'), findsOneWidget);
});
```

## Troubleshooting

### No Search Results

**Issue**: Search returns no results even with matching entries.

**Solutions:**
1. Check that entries belong to the authenticated user
2. Verify text search is working in Supabase
3. Check filter criteria - filters may be too restrictive
4. Try clearing all filters and searching again

### Filters Not Applying

**Issue**: Applied filters don't affect results.

**Solutions:**
1. Ensure you called `.search()` after updating filters
2. Check that filter values are not null
3. Verify filter logic in `_applyFilters` method

### Slow Search Performance

**Issue**: Search takes too long with many entries.

**Solutions:**
1. Implement server-side filtering
2. Add pagination to limit results
3. Add database indexes for filtered columns
4. Cache frequently accessed data

### Tag Filtering Issues

**Issue**: Tag filter doesn't work or is slow.

**Solutions:**
1. Ensure tag IDs are correct
2. Consider server-side tag filtering
3. Optimize repository calls for tags
4. Cache tag data locally

## Future Enhancements

### Planned Features
- [ ] Server-side filtering via Supabase queries
- [ ] Advanced text search with relevance ranking
- [ ] Saved searches/bookmarks
- [ ] Search suggestions autocomplete
- [ ] Voice search input
- [ ] Search history
- [ ] Export search results
- [ ] Filter by trip (requires trip integration)
- [ ] Filter by media type (photo/video)
- [ ] Filter combinations (AND/OR logic)

### Performance Improvements
- [ ] Pagination for large result sets
- [ ] Result caching
- [ ] Debounce filter updates
- [ ] Lazy loading for results
- [ ] Database query optimization

### UX Improvements
- [ ] Search animations
- [ ] Filter presets (quick filters)
- [ ] Search result highlighting
- [ ] Advanced search builder
- [ ] Filter sharing (deep linking)

## Related Components

- **JournalEntryDetailScreen**: View individual search results
- **TagPicker**: Tag selection for filtering
- **LocationPickerWidget**: Location selection for filtering
- **MoodPicker**: Mood selection for filtering
- **TripOverviewScreen**: Trip-based filtering (future)

## Contributing

When modifying the search functionality:

1. Maintain consistent error handling
2. Preserve debouncing for text search
3. Keep filter logic organized
4. Update documentation
5. Test with various filter combinations
6. Consider performance implications

## License

This component is part of the SoloAdventurer travel journal feature.
