# Offline Storage with SQLite

This module provides comprehensive offline storage capabilities for the Travel Journal feature using SQLite. It enables users to create, read, update, and delete journal entries, media items, trips, and tags while offline, with automatic sync capabilities when connectivity is restored.

## Features

- **Complete CRUD Operations**: Full support for creating, reading, updating, and deleting journal entries, media, trips, and tags
- **Sync Status Tracking**: Each entity tracks its sync status (synced, pending, conflict, offline_only)
- **Offline-First Architecture**: All data is stored locally first, then synced to the remote server
- **Performance Optimized**: Database indexes on frequently queried columns
- **Type-Safe**: Full TypeScript-like type safety with Dart's strong typing
- **Error Handling**: Comprehensive error handling with custom exceptions
- **Data Integrity**: Foreign key constraints and cascade deletes

## Architecture

### Database Schema

The offline database consists of the following tables:

#### journal_entries
Stores journal entries with all metadata:
- `id` (TEXT PRIMARY KEY)
- `user_id` (TEXT NOT NULL)
- `trip_id` (TEXT)
- `title` (TEXT NOT NULL)
- `content` (TEXT NOT NULL)
- `mood` (TEXT)
- `location_name` (TEXT)
- `latitude` (REAL)
- `longitude` (REAL)
- `location_accuracy` (REAL)
- `entry_date` (TEXT NOT NULL)
- `weather_data` (TEXT - JSON)
- `is_favorite` (INTEGER)
- `sync_status` (TEXT NOT NULL DEFAULT 'synced')
- `last_synced_at` (TEXT)
- `created_at` (TEXT NOT NULL)
- `updated_at` (TEXT NOT NULL)

#### media_items
Stores photos and videos attached to journal entries:
- `id` (TEXT PRIMARY KEY)
- `user_id` (TEXT NOT NULL)
- `journal_entry_id` (TEXT NOT NULL) - FOREIGN KEY
- `media_type` (TEXT NOT NULL)
- `storage_path` (TEXT NOT NULL)
- `original_filename` (TEXT)
- `file_size` (INTEGER)
- `mime_type` (TEXT)
- `width` (INTEGER)
- `height` (INTEGER)
- `duration` (INTEGER)
- `thumbnail_path` (TEXT)
- `caption` (TEXT)
- `upload_status` (TEXT NOT NULL DEFAULT 'pending')
- `upload_progress` (INTEGER NOT NULL DEFAULT 0)
- `exif_data` (TEXT - JSON)
- `is_cover` (INTEGER)
- `order_index` (INTEGER NOT NULL DEFAULT 0)
- `sync_status` (TEXT NOT NULL DEFAULT 'synced')
- `last_synced_at` (TEXT)
- `created_at` (TEXT NOT NULL)
- `updated_at` (TEXT NOT NULL)

#### trips
Stores trip information:
- `id` (TEXT PRIMARY KEY)
- `user_id` (TEXT NOT NULL)
- `name` (TEXT NOT NULL)
- `description` (TEXT)
- `cover_image_url` (TEXT)
- `start_date` (TEXT NOT NULL)
- `end_date` (TEXT)
- `destination` (TEXT)
- `is_public` (INTEGER NOT NULL DEFAULT 0)
- `sync_status` (TEXT NOT NULL DEFAULT 'synced')
- `last_synced_at` (TEXT)
- `created_at` (TEXT NOT NULL)
- `updated_at` (TEXT NOT NULL)

#### tags
Stores custom tags for categorizing entries:
- `id` (TEXT PRIMARY KEY)
- `user_id` (TEXT NOT NULL)
- `name` (TEXT NOT NULL)
- `color` (TEXT)
- `icon` (TEXT)
- `usage_count` (INTEGER NOT NULL DEFAULT 0)
- `created_at` (TEXT NOT NULL)

#### entry_tags (Junction Table)
Many-to-many relationship between entries and tags:
- `id` (TEXT PRIMARY KEY)
- `journal_entry_id` (TEXT NOT NULL) - FOREIGN KEY
- `tag_id` (TEXT NOT NULL) - FOREIGN KEY
- `created_at` (TEXT NOT NULL)
- UNIQUE(journal_entry_id, tag_id)

### Data Sources

#### JournalLocalDataSource
Provides offline storage operations for journal entries and media items:
- `createEntry()` - Create a new journal entry
- `updateEntry()` - Update an existing entry
- `getEntry()` - Retrieve a single entry by ID
- `getEntries()` - Retrieve all entries
- `getEntriesByTrip()` - Get entries for a specific trip
- `getEntriesByDateRange()` - Get entries within a date range
- `searchEntries()` - Search entries by text
- `getFavoriteEntries()` - Get all favorite entries
- `getEntriesWithLocation()` - Get entries that have location data
- `getEntriesNearLocation()` - Get entries near a specific location
- `deleteEntry()` - Delete an entry
- `toggleFavorite()` - Toggle favorite status
- `getEntriesBySyncStatus()` - Get entries with specific sync status
- `updateSyncStatus()` - Update sync status of an entry

Media operations:
- `addMedia()` - Add a media item
- `updateMedia()` - Update a media item
- `getMediaForEntry()` - Get all media for an entry
- `deleteMedia()` - Delete a media item
- `updateMediaUploadProgress()` - Update upload progress
- `completeMediaUpload()` - Mark upload as complete
- `failMediaUpload()` - Mark upload as failed
- `getMediaBySyncStatus()` - Get media by sync status
- `updateMediaSyncStatus()` - Update sync status

Tag operations:
- `getTagsForEntry()` - Get tags for an entry
- `addTagToEntry()` - Add a tag to an entry
- `removeTagFromEntry()` - Remove a tag from an entry
- `updateTagsForEntry()` - Update all tags for an entry

#### TripLocalDataSource
Provides offline storage operations for trips:
- `createTrip()` - Create a new trip
- `updateTrip()` - Update an existing trip
- `getTrip()` - Retrieve a single trip by ID
- `getTrips()` - Retrieve all trips
- `getTripsBySyncStatus()` - Get trips with specific sync status
- `updateSyncStatus()` - Update sync status of a trip
- `deleteTrip()` - Delete a trip
- `clearAll()` - Clear all trip data

#### TagLocalDataSource
Provides offline storage operations for tags:
- `createTag()` - Create a new tag
- `updateTag()` - Update an existing tag
- `getTag()` - Retrieve a single tag by ID
- `getTags()` - Retrieve all tags
- `getTagsBySyncStatus()` - Get tags with specific sync status
- `updateSyncStatus()` - Update sync status of a tag
- `deleteTag()` - Delete a tag
- `incrementUsageCount()` - Increment tag usage count
- `decrementUsageCount()` - Decrement tag usage count
- `clearAll()` - Clear all tag data

## Installation

The required dependencies are already added to `pubspec.yaml`:

```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.3
```

## Usage

### Initializing the Database

The database is automatically initialized on first use. The `DatabaseHelper` singleton manages the database connection:

```dart
import 'package:soloadventurer/features/journal/data/datasources/database_helper.dart';

// Get database instance (auto-initializes if needed)
final dbHelper = DatabaseHelper();
final db = await dbHelper.database;
```

### Creating Data Sources

```dart
import 'package:soloadventurer/features/journal/data/datasources/journal_local_data_source_impl.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_local_data_source_impl.dart';
import 'package:soloadventurer/features/journal/data/datasources/tag_local_data_source_impl.dart';

final journalLocalDataSource = JournalLocalDataSourceImpl(
  databaseHelper: DatabaseHelper(),
);

final tripLocalDataSource = TripLocalDataSourceImpl(
  databaseHelper: DatabaseHelper(),
);

final tagLocalDataSource = TagLocalDataSourceImpl(
  databaseHelper: DatabaseHelper(),
);
```

### Creating a Journal Entry

```dart
final entry = JournalEntryModel(
  id: 'entry-123',
  userId: 'user-456',
  title: 'My Adventure in Paris',
  content: 'Today I visited the Eiffel Tower...',
  entryDate: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncStatus: SyncStatus.pending, // Mark as pending for sync
);

final createdEntry = await journalLocalDataSource.createEntry(entry);
```

### Retrieving Journal Entries

```dart
// Get all entries
final entries = await journalLocalDataSource.getEntries();

// Get entries for a trip
final tripEntries = await journalLocalDataSource.getEntriesByTrip('trip-123');

// Get entries by date range
final dateRangeEntries = await journalLocalDataSource.getEntriesByDateRange(
  DateTime(2024, 1, 1),
  DateTime(2024, 1, 31),
);

// Get favorite entries
final favorites = await journalLocalDataSource.getFavoriteEntries();

// Search entries
final searchResults = await journalLocalDataSource.searchEntries('Paris');
```

### Updating Sync Status

```dart
// Mark entry as synced
await journalLocalDataSource.updateSyncStatus('entry-123', 'synced');

// Get all pending entries (for sync)
final pendingEntries = await journalLocalDataSource.getEntriesBySyncStatus('pending');
```

### Working with Media

```dart
final media = MediaItemModel(
  id: 'media-123',
  userId: 'user-456',
  journalEntryId: 'entry-123',
  mediaType: MediaType.photo,
  storagePath: '/local/path/to/photo.jpg',
  uploadStatus: UploadStatus.pending,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Add media to entry
await journalLocalDataSource.addMedia(media);

// Update upload progress
await journalLocalDataSource.updateMediaUploadProgress('media-123', 50);

// Complete upload
await journalLocalDataSource.completeMediaUpload('media-123', '/remote/path/photo.jpg');
```

### Working with Trips

```dart
final trip = TripModel(
  id: 'trip-123',
  userId: 'user-456',
  name: 'European Adventure',
  startDate: DateTime(2024, 6, 1),
  endDate: DateTime(2024, 6, 15),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

await tripLocalDataSource.createTrip(trip);
```

### Working with Tags

```dart
final tag = TagModel(
  id: 'tag-123',
  userId: 'user-456',
  name: 'Adventure',
  color: '#FF5722',
  icon: '🏔️',
  createdAt: DateTime.now(),
);

await tagLocalDataSource.createTag(tag);

// Add tag to entry
await journalLocalDataSource.addTagToEntry('entry-123', 'tag-123');

// Increment usage count
await tagLocalDataSource.incrementUsageCount('tag-123');
```

## Sync Status Management

Each entity has a `syncStatus` field with the following values:

- **synced**: The entity is up-to-date with the server
- **pending**: The entity has local changes that need to be synced
- **conflict**: There's a conflict between local and remote versions
- **offlineOnly**: The entity only exists locally (never synced)

### Sync Workflow

1. **Create/Update Offline**: When creating or updating an entity while offline, set `syncStatus` to `pending`
2. **Sync Process**: Periodically check for entities with `pending` status
3. **Upload to Server**: Send pending changes to the remote server
4. **Update Status**: Mark as `synced` after successful upload
5. **Handle Conflicts**: If server version changed, mark as `conflict` and resolve

## Error Handling

All data source methods throw `DatabaseException` on failure:

```dart
try {
  final entry = await journalLocalDataSource.getEntry('entry-123');
} on DatabaseException catch (e) {
  // Handle database error
  print('Database error: ${e.message}');
} on NotFoundException catch (e) {
  // Handle not found error
  print('Entry not found: ${e.message}');
}
```

## Performance Considerations

### Database Indexes

Indexes are created on frequently queried columns:
- `journal_entries(user_id, trip_id, entry_date, sync_status)`
- `media_items(journal_entry_id, user_id)`
- `trips(user_id)`
- `tags(user_id)`
- `entry_tags(journal_entry_id, tag_id)`

### Best Practices

1. **Use Transactions**: For multiple operations, use transactions
2. **Batch Operations**: Use batch inserts/updates for better performance
3. **Close Connections**: Close the database when not in use
4. **Limit Query Results**: Use pagination for large datasets
5. **Query Optimization**: Use specific WHERE clauses to limit results

## Testing

### Mock Database Helper

For testing, create a mock `DatabaseHelper`:

```dart
class MockDatabaseHelper extends DatabaseHelper {
  @override
  Future<Database> get database async {
    // Return in-memory database for testing
    return openDatabase(
      ':memory:',
      version: 1,
      onCreate: (db, version) async {
        // Create test schema
      },
    );
  }
}
```

## Future Enhancements

- [ ] Add database migrations support
- [ ] Implement full-text search
- [ ] Add data compression for large content
- [ ] Implement data encryption
- [ ] Add backup/restore functionality
- [ ] Support for complex queries with JOINs
- [ ] Add query result caching
- [ ] Implement database analytics

## Troubleshooting

### Common Issues

**Issue**: Database is locked
- **Solution**: Ensure only one database instance is active
- **Code**: `await DatabaseHelper().database;`

**Issue**: Query is slow
- **Solution**: Add indexes on queried columns
- **Code**: See `DatabaseHelper._createIndexes()`

**Issue**: Foreign key constraint failed
- **Solution**: Ensure parent record exists before adding child records
- **Code**: Create trip before creating entries for that trip

**Issue**: Out of memory
- **Solution**: Use pagination or limit query results
- **Code**: `db.query('table', limit: 100);`

## Related Files

- `database_helper.dart` - Database initialization and schema management
- `journal_local_data_source.dart` - Journal local data source interface
- `journal_local_data_source_impl.dart` - Journal local data source implementation
- `trip_local_data_source.dart` - Trip local data source interface
- `trip_local_data_source_impl.dart` - Trip local data source implementation
- `tag_local_data_source.dart` - Tag local data source interface
- `tag_local_data_source_impl.dart` - Tag local data source implementation
- `../../../core/errors/app_exception.dart` - Custom exception classes

## Dependencies

- `sqflite` - SQLite database plugin for Flutter
- `path` - Path manipulation for cross-platform paths
- `soloadventurer/core/errors/app_exception.dart` - Custom exceptions

## License

This module is part of the SoloAdventurer project.
