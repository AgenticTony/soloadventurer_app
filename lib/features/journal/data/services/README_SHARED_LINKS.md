# Public Trip Sharing Links

Complete system for generating shareable links for trips with optional password protection.

## Overview

This feature allows users to:
- Create shareable links for their trips
- Optionally protect links with passwords
- Set expiration dates for links
- Track link views and statistics
- Share trips with others securely

## Architecture

### Database Layer

**Table: `shared_links`**
- Stores shareable links with metadata
- Password hashing support
- Expiration tracking
- View count tracking

**Database Functions:**
- `generate_unique_slug()` - Generates unique random slugs
- `hash_password(password)` - Hashes passwords (SHA-256, upgrade to bcrypt in production)
- `verify_password(link_id, password)` - Verifies password for a link
- `validate_shared_link_access(link_slug, password)` - Validates access with optional password
- `increment_link_view_count(link_slug)` - Records a view
- `create_shared_link(...)` - Creates a new shared link

### Domain Layer

**Entities:**
- `SharedLink` - Represents a shareable link with all metadata
- `SharedLinkAccessResult` - Result of validating access to a link
- `CreateSharedLinkConfig` - Configuration for creating a new link
- `SharedLinkStatistics` - View statistics for a link

**Service Interface:**
- `SharedLinkService` - Domain service for managing shared links

### Data Layer

**Remote Data Source:**
- `SharedLinkRemoteDataSource` - Interface for Supabase operations
- `SharedLinkRemoteDataSourceImpl` - Implementation using Supabase

**Service Implementation:**
- `SharedLinkServiceImpl` - Business logic implementation

### Presentation Layer

**Providers:**
- `sharedLinkServiceProvider` - Service instance
- `sharedLinkNotifierProvider` - State management for links
- `createSharedLinkNotifierProvider` - Link creation state
- `validateLinkNotifierProvider` - Access validation state
- Multiple computed providers for filtered views

**Widgets:**
- `SharedLinkCreator` - Form for creating new share links
- `SharedLinkManager` - List and manage existing links
- `SharedLinkCard` - Display individual link details
- `PublicTripViewer` - View shared trips (public access)

## Installation

### 1. Run Database Migration

```sql
-- File: supabase/migrations/20250106000000_create_shared_links_table.sql
```

This creates:
- `shared_links` table
- Database functions for slug generation, password hashing, access validation
- Indexes for performance
- RLS policies for security
- Helper views

### 2. Dependencies (Already in project)

```yaml
dependencies:
  flutter_riverpod: ^2.3.6
  supabase_flutter: ^1.10.0
  intl: ^0.18.0
```

## Quick Start

### Basic Usage

#### 1. Create a Shared Link

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/providers/shared_link_providers.dart';
import 'package:soloadventurer/features/journal/presentation/widgets/shared_link_creator.dart';

// Show the shared link creator
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => SharedLinkCreator(
      tripId: 'trip-123',
      tripName: 'Summer Vacation 2024',
    ),
  ),
);
```

#### 2. Create with Password Protection

```dart
final config = CreateSharedLinkConfig(
  tripId: 'trip-123',
  password: 'securePassword123',  // Optional: null for public link
  expiresAt: DateTime(2024, 12, 31),  // Optional: null for no expiration
);

final service = ref.read(sharedLinkServiceProvider);
final link = await service.createSharedLink(config);

print('Share URL: ${link.shareUrl}');
print('Has Password: ${link.hasPassword}');
print('Expires: ${link.expiresAt}');
```

#### 3. Validate Access to Shared Link

```dart
final service = ref.read(sharedLinkServiceProvider);

// Without password (for public links)
final result = await service.validateAccess(slug: 'abc123xyz');

if (result.isAccessible) {
  print('Access granted to trip: ${result.tripId}');
  // Load and display the trip
} else if (result.requiresPassword) {
  print('Password required');
  // Show password prompt
} else if (result.isExpired) {
  print('Link has expired');
  // Show expired message
}
```

#### 4. Validate with Password

```dart
final result = await service.validateAccess(
  slug: 'abc123xyz',
  password: 'securePassword123',
);

if (result.isAccessible) {
  // Record the view
  await service.recordView('abc123xyz');

  // Load trip
  final trip = await tripRepository.getTrip(result.tripId);
}
```

#### 5. Manage Shared Links

```dart
// Get all links for a trip
final links = await service.getSharedLinksForTrip('trip-123');

// Get user's all shared links
final userLinks = await service.getUserSharedLinks();

// Get statistics
final stats = await service.getStatistics('link-456');
print('Total views: ${stats.totalViews}');
print('Avg views/day: ${stats.averageViewsPerDay}');

// Deactivate a link
await service.deactivateSharedLink('link-456');

// Delete a link permanently
await service.deleteSharedLink('link-456');
```

### UI Integration

#### Add Share Button to Trip Detail Screen

```dart
class TripDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summer Vacation'),
        actions: [
          // Share button
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SharedLinkManager(
                    tripId: trip.id,
                    tripName: trip.name,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: /* ... */,
    );
  }
}
```

#### Use Convenience Button Widget

```dart
CreateSharedLinkButton(
  tripId: trip.id,
  tripName: trip.name,
)
```

#### View Public Trip (Shared Link Access)

```dart
// When user opens a shared link URL: https://soloadventurer.app/share/abc123xyz
// Extract slug from URL and navigate to viewer

Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => PublicTripViewer(slug: 'abc123xyz'),
  ),
);
```

## Configuration Options

### Password Protection

```dart
// Public link (no password)
final config1 = CreateSharedLinkConfig(tripId: 'trip-123');

// Protected link (with password)
final config2 = CreateSharedLinkConfig(
  tripId: 'trip-123',
  password: 'mySecretPassword',
);
```

### Expiration

```dart
// No expiration (link never expires)
final config1 = CreateSharedLinkConfig(tripId: 'trip-123');

// Expires in 7 days
final config2 = CreateSharedLinkConfig(
  tripId: 'trip-123',
  expiresAt: DateTime.now().add(Duration(days: 7)),
);

// Expires on specific date
final config3 = CreateSharedLinkConfig(
  tripId: 'trip-123',
  expiresAt: DateTime(2024, 12, 31, 23, 59),
);
```

### Both Password and Expiration

```dart
final config = CreateSharedLinkConfig(
  tripId: 'trip-123',
  password: 'securePassword',
  expiresAt: DateTime.now().add(Duration(days: 30)),
);
```

## State Management

### Watching Link Creation

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createState = ref.watch(createSharedLinkNotifierProvider);

    if (createState.isCreating) {
      return CircularProgressIndicator();
    }

    if (createState.createdLink != null) {
      return Text('Link created: ${createState.createdLink!.shareUrl}');
    }

    if (createState.errorMessage != null) {
      return Text('Error: ${createState.errorMessage}');
    }

    return ElevatedButton(
      onPressed: () => _createLink(ref),
      child: Text('Create Link'),
    );
  }

  void _createLink(WidgetRef ref) {
    final notifier = ref.read(createSharedLinkNotifierProvider.notifier);
    notifier.createLink(CreateSharedLinkConfig(tripId: 'trip-123'));
  }
}
```

### Watching Link List

```dart
class LinkListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sharedLinkNotifierProvider);

    if (state.isLoading) {
      return CircularProgressIndicator();
    }

    if (state.links.isEmpty) {
      return Text('No shared links yet');
    }

    return ListView.builder(
      itemCount: state.links.length,
      itemBuilder: (context, index) {
        final link = state.links[index];
        return Text('${link.slug} - ${link.viewCount} views');
      },
    );
  }
}
```

## Security Considerations

### Password Hashing

The current implementation uses SHA-256 for password hashing. For production:

1. **Upgrade to bcrypt**: Use the `pgcrypto` extension in Supabase

```sql
-- Enable pgcrypto
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Update hash_password function to use bcrypt
CREATE OR REPLACE FUNCTION hash_password(password TEXT)
RETURNS VARCHAR(255) AS $$
BEGIN
  IF password IS NULL OR password = '' THEN
    RETURN NULL;
  END IF;

  -- Use bcrypt for production
  RETURN crypt(password, gen_salt('bf'));
END;
$$ LANGUAGE plpgsql;

-- Update verify_password function
CREATE OR REPLACE FUNCTION verify_password(link_id UUID, password TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  stored_hash VARCHAR(255);
BEGIN
  SELECT password_hash INTO stored_hash
  FROM shared_links
  WHERE id = link_id AND is_active = TRUE;

  IF stored_hash IS NULL THEN
    RETURN TRUE;
  END IF;

  -- Use bcrypt verification
  RETURN stored_hash = crypt(password, stored_hash);
END;
$$ LANGUAGE plpgsql;
```

### Row Level Security (RLS)

The migration includes comprehensive RLS policies:
- Users can only manage their own links
- Public can only validate active links
- All operations are protected

### Rate Limiting

Consider implementing rate limiting for:
- Password validation attempts (prevent brute force)
- Link creation (prevent abuse)

## Best Practices

### 1. Always Validate Access

```dart
// GOOD: Always validate before showing content
final result = await service.validateAccess(slug: slug);
if (result.isAccessible) {
  await service.recordView(slug);
  // Show content
}

// BAD: Don't directly load trips without validation
```

### 2. Handle All Result States

```dart
final result = await service.validateAccess(slug: slug);

switch ((result.isAccessible, result.requiresPassword, result.isExpired)) {
  case (true, _, _):
    // Show content
    break;
  case (_, true, _):
    // Show password prompt
    break;
  case (_, _, true):
    // Show expired message
    break;
  default:
    // Show not found message
}
```

### 3. Use Statistics Wisely

```dart
// Load statistics on demand (not in list views)
// Good for detail views
final stats = await service.getStatistics(linkId);

// Don't load in list items - use link.viewCount directly
Text('${link.viewCount} views')
```

### 4. Provide Clear Feedback

```dart
try {
  final link = await service.createSharedLink(config);
  // Show success dialog with link
  showDialog(context: context, builder: (_) => SuccessDialog(link: link));
} on SharedLinkException catch (e) {
  // Show user-friendly error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(_getUserFriendlyMessage(e))),
  );
}
```

## Testing

### Unit Tests

```dart
test('should create shared link with password', () async {
  final config = CreateSharedLinkConfig(
    tripId: 'trip-123',
    password: 'test123',
  );

  final link = await service.createSharedLink(config);

  expect(link.hasPassword, true);
  expect(link.slug, isNotEmpty);
  expect(link.isActive, true);
});

test('should validate password correctly', () async {
  final result = await service.validateAccess(
    slug: 'abc123',
    password: 'wrongpassword',
  );

  expect(result.isAccessible, false);
  expect(result.requiresPassword, true);
});
```

### Widget Tests

```dart
testWidgets('should show password prompt for protected links', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: PublicTripViewer(slug: 'protected-123'),
      ),
    ),
  );

  expect(find.text('Password Required'), findsOneWidget);
  expect(find.byType(TextField), findsOneWidget);
});
```

## Troubleshooting

### Common Issues

**Issue: Link shows as expired even though expiration date is in future**
- Cause: Timezone mismatch between client and server
- Fix: Always store and compare in UTC

**Issue: Password validation always fails**
- Cause: Password not being hashed correctly
- Fix: Ensure hash_password and verify_password use same algorithm

**Issue: View count not incrementing**
- Cause: recordView not being called after successful validation
- Fix: Always call recordView after successful validateAccess

**Issue: Links not appearing in list**
- Cause: Not invalidating providers after mutations
- Fix: Call ref.invalidate(provider) after create/update/delete

## Performance Considerations

1. **Indexes**: Database has indexes on slug, trip_id, user_id for fast queries
2. **Pagination**: Consider pagination for getUserSharedLinks if user has many links
3. **Statistics Loading**: Statistics are loaded on-demand, not in list views
4. **Caching**: Consider caching validation results for short periods

## Future Enhancements

- [ ] QR code generation for easy sharing
- [ ] Link analytics dashboard (views over time)
- [ ] Email notifications when link is accessed
- [ ] Custom URL slugs (user-defined instead of random)
- [ ] Multiple password support (different passwords for different access levels)
- [ ] Temporary access links (one-time use)
- [ ] Social media metadata for shared links (Open Graph tags)
- [ ] Direct link sharing from app with native share sheet
- [ ] Copy link to clipboard with one tap
- [ ] Link preview in chat apps

## API Reference

### SharedLinkService

```dart
// Create a new shared link
Future<SharedLink> createSharedLink(CreateSharedLinkConfig config)

// Get link by ID
Future<SharedLink?> getSharedLink(String linkId)

// Get link by slug
Future<SharedLink?> getSharedLinkBySlug(String slug)

// Get all links for a trip
Future<List<SharedLink>> getSharedLinksForTrip(String tripId)

// Get user's all links
Future<List<SharedLink>> getUserSharedLinks()

// Validate access
Future<SharedLinkAccessResult> validateAccess({required String slug, String? password})

// Record a view
Future<void> recordView(String slug)

// Update link
Future<SharedLink> updateSharedLink({required String linkId, String? password, DateTime? expiresAt, bool? isActive})

// Deactivate link
Future<void> deactivateSharedLink(String linkId)

// Delete link
Future<void> deleteSharedLink(String linkId)

// Get statistics
Future<SharedLinkStatistics> getStatistics(String linkId)
```

### Entities

```dart
// SharedLink
class SharedLink {
  String id;
  String tripId;
  String userId;
  String slug;
  bool hasPassword;
  bool isActive;
  DateTime? expiresAt;
  int viewCount;
  DateTime? lastViewedAt;
  SyncStatus syncStatus;
  DateTime createdAt;
  DateTime updatedAt;

  String get shareUrl;
  bool get isExpired;
  bool get isAccessible;
}

// SharedLinkAccessResult
class SharedLinkAccessResult {
  String linkId;
  String tripId;
  bool isAccessible;
  bool requiresPassword;
  bool isExpired;
  String? errorMessage;
}

// CreateSharedLinkConfig
class CreateSharedLinkConfig {
  String tripId;
  String? password;
  DateTime? expiresAt;
}

// SharedLinkStatistics
class SharedLinkStatistics {
  int totalViews;
  DateTime? lastViewedAt;
  int daysSinceCreation;
  double averageViewsPerDay;
}
```

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the database migration for any setup issues
3. Verify Supabase RLS policies are applied correctly
4. Check provider injection in your widget tree
