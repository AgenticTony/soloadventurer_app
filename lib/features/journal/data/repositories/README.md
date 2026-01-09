# Journal Entry CRUD Operations

This document describes the CRUD operations for journal entries implemented with Supabase.

## Architecture

The implementation follows Clean Architecture principles with three layers:

- **Domain Layer**: `JournalRepository` interface (contracts)
- **Data Layer**: `JournalRepositoryImpl` and `JournalRemoteDataSourceImpl` (implementation)
- **Presentation Layer**: Providers that use the repository

## Files

- `lib/features/journal/domain/repositories/journal_repository.dart` - Repository interface
- `lib/features/journal/data/datasources/journal_remote_data_source.dart` - Data source interface
- `lib/features/journal/data/datasources/journal_remote_data_source_impl.dart` - Supabase implementation
- `lib/features/journal/data/repositories/journal_repository_impl.dart` - Repository implementation
- `lib/features/journal/presentation/providers/journal_entry_providers.dart` - State management

## Setup

### 1. Add Supabase Dependency

The `supabase_flutter: ^2.0.0` package has been added to `pubspec.yaml`.

### 2. Initialize Supabase

Initialize Supabase in your app's bootstrap or initialization:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(MyApp());
}
```

### 3. Configure Environment Variables

Add to `.env`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 4. Register Repository in DI

Override the `journalRepositoryProvider` in your DI setup:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source_impl.dart';
import 'package:soloadventurer/features/journal/data/repositories/journal_repository_impl.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';

// In your service locator or provider container
final supabaseClient = Supabase.instance.client;

final journalRemoteDataSource = JournalRemoteDataSourceImpl(
  client: supabaseClient,
);

final journalRepository = JournalRepositoryImpl(
  remoteDataSource: journalRemoteDataSource,
);

// Override the provider
container.read(journalRepositoryProvider.notifier).state = journalRepository;
```

## Usage

### Creating a Journal Entry

```dart
final repository = ref.read(journalRepositoryProvider);

final entry = JournalEntry(
  id: uuid.v4(),
  userId: currentUser.id,
  title: 'My Day in Paris',
  content: 'Today I visited the Eiffel Tower...',
  entryDate: DateTime.now(),
  mood: 'excited',
  locationName: 'Paris, France',
  latitude: 48.8588443,
  longitude: 2.2943506,
  isFavorite: false,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

try {
  final createdEntry = await repository.createEntry(entry);
  print('Entry created with ID: ${createdEntry.id}');
} catch (e) {
  print('Failed to create entry: $e');
}
```

### Getting All Entries

```dart
final repository = ref.read(journalRepositoryProvider);

try {
  final entries = await repository.getEntries();
  for (final entry in entries) {
    print('${entry.title}: ${entry.content}');
  }
} catch (e) {
  print('Failed to get entries: $e');
}
```

### Getting a Single Entry

```dart
final repository = ref.read(journalRepositoryProvider);

try {
  final entry = await repository.getEntry(entryId);
  print('Entry: ${entry.title}');
} catch (e) {
  print('Failed to get entry: $e');
}
```

### Updating an Entry

```dart
final repository = ref.read(journalRepositoryProvider);

try {
  final updatedEntry = await repository.updateEntry(
    entry.copyWith(
      title: 'Updated Title',
      content: 'Updated content',
    ),
  );
  print('Entry updated');
} catch (e) {
  print('Failed to update entry: $e');
}
```

### Deleting an Entry

```dart
final repository = ref.read(journalRepositoryProvider);

try {
  await repository.deleteEntry(entryId);
  print('Entry deleted');
} catch (e) {
  print('Failed to delete entry: $e');
}
```

### Toggle Favorite Status

```dart
final repository = ref.read(journalRepositoryProvider);

try {
  final entry = await repository.toggleFavorite(entryId);
  print('Entry is now favorite: ${entry.isFavorite}');
} catch (e) {
  print('Failed to toggle favorite: $e');
}
```

### Search Entries

```dart
final repository = ref.read(journalRepositoryProvider);

try {
  final results = await repository.searchEntries('Paris');
  print('Found ${results.length} entries');
} catch (e) {
  print('Failed to search: $e');
}
```

### Get Entries by Date Range

```dart
final repository = ref.read(journalRepositoryProvider);

try {
  final startDate = DateTime(2024, 1, 1);
  final endDate = DateTime(2024, 1, 31);
  final entries = await repository.getEntriesByDateRange(startDate, endDate);
  print('Found ${entries.length} entries in January');
} catch (e) {
  print('Failed to get entries: $e');
}
```

### Get Entries with Location

```dart
final repository = ref.read(journalRepositoryProvider);

try {
  final entries = await repository.getEntriesWithLocation();
  print('Found ${entries.length} entries with location data');
} catch (e) {
  print('Failed to get entries: $e');
}
```

## Media Operations

### Add Media to Entry

```dart
final repository = ref.read(journalRepositoryProvider);

final media = MediaItem(
  id: uuid.v4(),
  userId: currentUser.id,
  journalEntryId: entryId,
  mediaType: MediaType.photo,
  storagePath: 'journal-photos/user-id/photo.jpg',
  uploadStatus: UploadStatus.pending,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

try {
  final createdMedia = await repository.addMedia(media);
  print('Media added with ID: ${createdMedia.id}');
} catch (e) {
  print('Failed to add media: $e');
}
```

### Get Media for Entry

```dart
final repository = ref.read(journalRepositoryProvider);

try {
  final mediaItems = await repository.getMediaForEntry(entryId);
  print('Found ${mediaItems.length} media items');
} catch (e) {
  print('Failed to get media: $e');
}
```

### Update Upload Progress

```dart
final repository = ref.read(journalRepositoryProvider);

try {
  final media = await repository.updateMediaUploadProgress(mediaId, 50);
  print('Upload progress: ${media.uploadProgress}%');
} catch (e) {
  print('Failed to update progress: $e');
}
```

### Complete Upload

```dart
final repository = ref.read(journalRepositoryProvider);

try {
  final media = await repository.completeMediaUpload(
    mediaId,
    'journal-photos/user-id/final-photo.jpg',
  );
  print('Upload completed');
} catch (e) {
  print('Failed to complete upload: $e');
}
```

## Error Handling

All repository methods throw `AppException` on failure. Handle errors appropriately:

```dart
import 'package:soloadventurer/core/errors/app_exception.dart';

try {
  final entry = await repository.getEntry(entryId);
} on AppException catch (e) {
  // Handle application-level errors
  showErrorSnackBar(e.message);
} catch (e) {
  // Handle unexpected errors
  showErrorSnackBar('An unexpected error occurred');
}
```

## Database Schema

The CRUD operations work with the following Supabase tables:

### journal_entries

- `id` (UUID, primary key)
- `user_id` (UUID, foreign key to auth.users)
- `trip_id` (UUID, nullable, foreign key to trips)
- `title` (VARCHAR 500)
- `content` (TEXT)
- `mood` (VARCHAR 50, nullable)
- `location_name` (VARCHAR 255, nullable)
- `latitude` (DECIMAL 10,8, nullable)
- `longitude` (DECIMAL 11,8, nullable)
- `location_accuracy` (DECIMAL 10,2, nullable)
- `entry_date` (TIMESTAMPTZ)
- `weather_data` (JSONB, nullable)
- `is_favorite` (BOOLEAN)
- `sync_status` (VARCHAR 20)
- `last_synced_at` (TIMESTAMPTZ, nullable)
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

### media_items

- `id` (UUID, primary key)
- `user_id` (UUID, foreign key to auth.users)
- `journal_entry_id` (UUID, foreign key to journal_entries)
- `media_type` (VARCHAR 20, check: 'photo' or 'video')
- `storage_path` (VARCHAR 2048)
- `original_filename` (VARCHAR 255, nullable)
- `file_size` (BIGINT, nullable)
- `mime_type` (VARCHAR 100, nullable)
- `width` (INTEGER, nullable)
- `height` (INTEGER, nullable)
- `duration` (INTEGER, nullable)
- `thumbnail_path` (VARCHAR 2048, nullable)
- `caption` (TEXT, nullable)
- `upload_status` (VARCHAR 20)
- `upload_progress` (INTEGER, 0-100)
- `exif_data` (JSONB, nullable)
- `is_cover` (BOOLEAN)
- `order_index` (INTEGER)
- `sync_status` (VARCHAR 20)
- `last_synced_at` (TIMESTAMPTZ, nullable)
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

## Row Level Security (RLS)

All database operations are protected by Supabase RLS policies:

- Users can only read their own entries
- Users can only insert entries with their own user_id
- Users can only update their own entries
- Users can only delete their own entries
- Media items inherit permissions from their parent entry

## Testing

To test the CRUD operations without Supabase, create a mock implementation:

```dart
class MockJournalRemoteDataSource implements JournalRemoteDataSource {
  final Map<String, JournalEntryModel> _entries = {};

  @override
  Future<JournalEntryModel> createEntry(JournalEntryModel entry) async {
    _entries[entry.id] = entry;
    return entry;
  }

  @override
  Future<JournalEntryModel> getEntry(String entryId) async {
    final entry = _entries[entryId];
    if (entry == null) {
      throw ServerException(
        message: 'Entry not found',
        statusCode: 404,
      );
    }
    return entry;
  }

  // Implement other methods...
}
```

## Performance Considerations

1. **Pagination**: For large datasets, add pagination to `getEntries()`:

```dart
Future<List<JournalEntryModel>> getEntries({
  int page = 0,
  int pageSize = 20,
}) async {
  final response = await _client
      .from('journal_entries')
      .select()
      .range(page * pageSize, (page + 1) * pageSize - 1)
      .order('entry_date', ascending: false);

  return (response as List)
      .map((json) => JournalEntryModel.fromJson(json))
      .toList();
}
```

2. **Caching**: Consider implementing local caching for offline support (Phase 7)

3. **Indexes**: Database indexes are already created on frequently queried columns:
   - `user_id`, `entry_date`, `is_favorite`, `sync_status`
   - Full-text search on `title` and `content`

## Troubleshooting

### "User not authenticated" error

Ensure the user is logged in before calling repository methods:

```dart
final currentUser = supabase.auth.currentUser;
if (currentUser == null) {
  // Redirect to login
}
```

### "Relation does not exist" error

Run the database migrations to create the required tables:

```bash
supabase migration up
```

### "Permission denied" error

Check that RLS policies are correctly configured in Supabase:

```sql
-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'journal_entries';
```

## Next Steps

- Subtask 2.4: Build journal entry detail view screen
- Phase 3: Implement media upload and compression
- Phase 7: Add offline support with SQLite
