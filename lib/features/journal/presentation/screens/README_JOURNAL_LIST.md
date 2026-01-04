# Journal List Screen

A comprehensive screen for displaying all journal entries organized by trip or date, with support for pull-to-refresh, empty states, and seamless navigation to entry details.

## Features

- **Dual Organization Modes**: View entries organized by date or by trip
- **Tab-Based Navigation**: Easy switching between organization modes using Material Design tabs
- **Pull-to-Refresh**: Refresh data with a simple gesture
- **Smart Grouping**: Entries automatically grouped by month/year or trip
- **Rich Entry Cards**: Display title, date, time, mood, location, content preview, and sync status
- **Empty States**: Helpful guidance when no entries exist
- **Error Handling**: User-friendly error messages with retry functionality
- **Material Design 3**: Modern UI with proper theming and styling

## Installation

The Journal List Screen is part of the travel journal feature. Ensure you have the following dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  intl: ^0.19.0
```

## Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:soloadventurer/features/journal/presentation/screens/journal_list_screen.dart';

// Navigate to the journal list screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const JournalListScreen(),
  ),
);
```

### Provider Setup

The screen requires the `journalRepositoryProvider` to be set up. This is typically done in your dependency injection layer:

```dart
// In your DI setup (e.g., main.dart or providers.dart)
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl(
    remoteDataSource: ref.watch(journalRemoteDataSourceProvider),
    localDataSource: ref.watch(journalLocalDataSourceProvider),
  );
});
```

## State Management

### JournalListState

The screen uses `JournalListState` to manage its data:

```dart
class JournalListState {
  final List<JournalEntry> entries;           // All entries
  final bool isLoading;                       // Loading state
  final String? error;                        // Error message
  final JournalListOrganization organizationMode;  // byDate or byTrip
  final Map<String?, List<JournalEntry>> entriesByTrip;  // Grouped by trip
  final Map<String, List<JournalEntry>> entriesByDate;   // Grouped by date
}
```

### Accessing State

```dart
// Watch the journal list state
final listState = ref.watch(journalListProvider);

// Check loading state
if (listState.isLoading) {
  return CircularProgressIndicator();
}

// Check for errors
if (listState.error != null) {
  return Text('Error: ${listState.error}');
}

// Access entries
final entries = listState.entries;

// Access grouped entries
final byDate = listState.entriesByDate;
final byTrip = listState.entriesByTrip;
```

### Controlling the Screen

```dart
// Refresh the list
await ref.read(journalListProvider.notifier).refresh();

// Toggle organization mode
ref.read(journalListProvider.notifier).toggleOrganizationMode();

// Set specific organization mode
ref.read(journalListProvider.notifier).setOrganizationMode(
  JournalListOrganization.byDate,
);

// Clear errors
ref.read(journalListProvider.notifier).clearError();
```

## UI Components

### JournalEntryCard

The screen uses `JournalEntryCard` to display individual entries:

```dart
JournalEntryCard(
  entry: entry,
  onTap: () {
    // Navigate to entry detail
    Navigator.pushNamed(
      context,
      '/journal/entry/${entry.id}',
    );
  },
);
```

Features of the card:
- Title with favorite icon
- Date and time display
- Mood indicator (if present)
- Location display (if present)
- Content preview (3 lines)
- Sync status indicator

### Organization Tabs

The screen uses a `TabBar` to switch between organization modes:

```dart
TabBar(
  controller: _tabController,
  tabs: const [
    Tab(text: 'By Date', icon: Icon(Icons.calendar_today)),
    Tab(text: 'By Trip', icon: Icon(Icons.flight_takeoff)),
  ],
)
```

### Date Groups

Entries grouped by date show:
- Month/year header (e.g., "January 2025")
- Entry count badge
- All entries for that month

### Trip Groups

Entries grouped by trip show:
- Trip name header (or "Uncategorized Entries")
- Entry count badge
- All entries for that trip

## Navigation Patterns

### From Bottom Navigation

```dart
class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    JournalListScreen(),  // Journal list as a tab
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

### From App Drawer

```dart
Drawer(
  child: ListView(
    children: [
      DrawerHeader(
        child: Text('Travel Journal'),
      ),
      ListTile(
        leading: Icon(Icons.book),
        title: Text('My Journal'),
        onTap: () {
          Navigator.pop(context);  // Close drawer
          Navigator.pushNamed(context, '/journal');
        },
      ),
    ],
  ),
)
```

### With Custom Routes

```dart
// In your route configuration
MaterialApp(
  routes: {
    '/': (context) => HomeScreen(),
    '/journal': (context) => JournalListScreen(),
    '/journal/create': (context) => CreateJournalEntryScreen(),
    '/journal/entry/:id': (context) => JournalEntryDetailScreen(),
  },
);
```

## Customization

### Custom Empty State

To customize the empty state message, modify `_buildEmptyState()` in the screen:

```dart
Widget _buildEmptyState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Your custom empty state widget
        Icon(
          Icons.edit_note,
          size: 80,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
        const SizedBox(height: 24),
        const Text('Your custom message'),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/journal/create'),
          child: const Text('Create Entry'),
        ),
      ],
    ),
  );
}
```

### Custom Entry Card

To customize how entries are displayed, you can modify the `JournalEntryCard` widget or create your own:

```dart
Widget _buildCustomEntryCard(JournalEntry entry) {
  return Card(
    child: ListTile(
      leading: CircleAvatar(
        child: Text(entry.title[0]),
      ),
      title: Text(entry.title),
      subtitle: Text(DateFormat('MM/dd/yyyy').format(entry.entryDate)),
      trailing: entry.isFavorite ? Icon(Icons.favorite) : null,
      onTap: () {
        // Handle tap
      },
    ),
  );
}
```

### Custom Group Headers

Modify the `_DateGroup` or `_TripGroup` widgets to customize group headers:

```dart
class _CustomDateGroup extends StatelessWidget {
  final String dateKey;
  final List entries;

  const _CustomDateGroup({required this.dateKey, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Your custom header
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
          ),
          child: Text(dateKey, style: TextStyle(color: Colors.white)),
        ),
        // Entries...
      ],
    );
  }
}
```

## Error Handling

The screen automatically handles errors and displays user-friendly messages. To customize error handling:

```dart
try {
  await ref.read(journalListProvider.notifier).refresh();
} catch (e) {
  // Show custom error dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Unable to Load Entries'),
      content: Text(e.toString()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

## Testing

### Unit Tests

```dart
test('JournalListNotifier loads entries', () async {
  final mockRepository = MockJournalRepository();
  final notifier = JournalListNotifier(mockRepository);

  when(mockRepository.getEntries())
      .thenAnswer((_) async => [testEntry1, testEntry2]);

  await notifier.loadEntries();

  expect(notifier.state.hasEntries, true);
  expect(notifier.state.entries.length, 2);
});
```

### Widget Tests

```dart
testWidgets('JournalListScreen displays tabs', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        journalRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(home: JournalListScreen()),
    ),
  );

  expect(find.text('By Date'), findsOneWidget);
  expect(find.text('By Trip'), findsOneWidget);
});

testWidgets('JournalListScreen shows loading state', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        journalRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(home: JournalListScreen()),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Performance Considerations

1. **Lazy Loading**: The screen uses `ListView.builder` for efficient rendering
2. **State Management**: Riverpod ensures minimal rebuilds when state changes
3. **Grouped Data**: Entries are grouped once on load, not on every render
4. **Content Preview**: Text is truncated to 150 characters for previews

## Best Practices

1. **Always Refresh**: Refresh the list when returning from creating/editing entries
2. **Handle Errors**: Always check for errors before displaying data
3. **Show Loading States**: Provide feedback during data fetches
4. **Use Semantic Names**: Clear variable and method names for maintainability
5. **Test Both Modes**: Verify both "By Date" and "By Trip" organization modes

## Troubleshooting

### Entries Not Loading

- Verify `journalRepositoryProvider` is properly configured
- Check network connectivity
- Ensure user is authenticated
- Check Supabase RLS policies

### Groups Not Showing

- Verify entries have `tripId` or `entryDate` set correctly
- Check date formatting in grouping logic
- Ensure entries are sorted by date

### Navigation Issues

- Verify route names match navigation calls
- Check that `MaterialApp` includes the route configuration
- Ensure context is valid when calling `Navigator.pushNamed`

## Future Enhancements

- [ ] Add filtering options (date range, trip, tags, mood)
- [ ] Implement search functionality
- [ ] Add sorting options (date ascending/descending, title)
- [ ] Support bulk actions (delete multiple, move to trip)
- [ ] Add pagination for large datasets
- [ ] Implement pull-to-refresh with custom animations
- [ ] Add swipe-to-delete functionality
- [ ] Support multi-select for batch operations

## Related Components

- `JournalEntryDetailScreen`: View individual entries
- `CreateJournalEntryScreen`: Create new entries
- `TripListScreen`: Manage trips
- `JournalSearchScreen`: Search entries
- `MemoryTimelineScreen`: Alternative chronological view
- `JournalMapScreen`: Map view of entries

## API Reference

### JournalListNotifier

| Method | Description | Returns |
|--------|-------------|---------|
| `loadEntries()` | Loads all entries for current user | `Future<void>` |
| `refresh()` | Refreshes the entry list | `Future<void>` |
| `toggleOrganizationMode()` | Switches between byTrip/byDate | `void` |
| `setOrganizationMode(mode)` | Sets organization mode | `void` |
| `clearError()` | Clears error state | `void` |

### JournalListOrganization

| Value | Description |
|-------|-------------|
| `byTrip` | Organize entries by trip |
| `byDate` | Organize entries by date |

## Support

For issues, questions, or contributions, please refer to the main project documentation.
