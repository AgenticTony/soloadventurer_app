# Travel Feature - Virtual Scrolling Implementation

This directory contains the presentation layer for the travel feature, demonstrating the use of `VirtualListView` and `VirtualGridView` for efficient rendering of large lists and grids.

## Screens

### TripItemsScreen
- **Route:** `/trips/items`
- **Purpose:** Displays a list of trip items with virtual scrolling
- **Features:**
  - Virtual scrolling for handling 500+ trips efficiently
  - Loading, error, and empty states
  - Dividers between items
  - Tap handling for navigation to trip details

### ActivitiesScreen
- **Route:** `/trips/activities`
- **Purpose:** Displays a list of activities with virtual scrolling
- **Features:**
  - Virtual scrolling for handling 500+ activities efficiently
  - Loading, error, and empty states
  - Card-based layout with category icons
  - Cost badges
  - Time and location information
  - Floating action button for adding activities

### ~~PhotoGalleryScreen~~ — REMOVED 2026-07-17 (Story 0.7)
Deleted along with `PhotoRepository` and `SupabasePhotoRepository`.
It was **never wired**: the `/trips/photos` route documented here was never registered,
`photoRepositoryProvider` was never defined, the screen faked its data with
`Future.delayed`, and the repository queried a **`photos` table that does not exist**
(12 call sites). See `docs/reports/phantom-schema-refs-2026-07-16.md`.

**The `Photo` model survives on purpose** — `integration_test/performance/` uses it as
fixture data for the `VirtualGridView` performance suites. It now has no feature behind
it; it should move into those tests' fixtures rather than sit in `travel/domain/models/`.
Tracked as a follow-up, not done here.

**Photos are not gone from the product — this was the wrong vehicle.** FOUNDATIONS §7
("photos as fuel, not feed") says the media pipeline **already exists** and is a
_"re-shape, not a build"_: the real path is **`media_items`** + the journal, which is
live and wired. PRODUCT §5 lists the four surfaces photos belong on — match card,
verified profile, city board, post-meetup memory — and a trip gallery is not one of
them. Any future media grid should ride `media_items`, not a second photos table.

## Architecture

### Virtual Scrolling Benefits

All screens use virtualized widgets from `lib/core/widgets/widgets.dart`:

#### VirtualListView
Used by TripItemsScreen and ActivitiesScreen:

1. **Memory Efficiency**: Only renders visible items, reducing memory footprint
2. **Performance**: Maintains smooth scrolling even with 500+ items
3. **Consistent API**: Same interface across all list views in the app
4. **State Management**: Built-in loading, error, and empty states
5. **Separators**: Efficient separator rendering interleaved with items

#### VirtualGridView
Used by PhotoGalleryScreen:

1. **Grid Layout**: Efficient 2D grid rendering for photo galleries
2. **Memory Efficiency**: Only renders visible grid items
3. **Responsive**: Automatically adjusts column count based on screen size
4. **Optimized**: Square aspect ratio and tight spacing for photos
5. **State Management**: Built-in loading, error, and empty states

### Data Flow

```
Provider (Riverpod) → ConsumerWidget → VirtualListView/GridView → Item Widgets
```

1. Data providers (`tripItemsProvider`, `activitiesProvider`, `photosProvider`) supply the data
2. Screen widgets watch the providers using `ref.watch()`
3. Virtualized widgets efficiently render only visible items
4. Individual item widgets display the content

## Usage Examples

### List View (TripItemsScreen, ActivitiesScreen)

```dart
VirtualListView<Trip>(
  itemCount: trips.length,
  separatorBuilder: (context, index) => const Divider(height: 1),
  itemBuilder: (context, index) => TripListItem(trip: trips[index]),
)
```

### Grid View (PhotoGalleryScreen)

```dart
VirtualGridView<Photo>(
  itemCount: photos.length,
  crossAxisCount: 3,
  childAspectRatio: 1.0,
  itemBuilder: (context, index) => PhotoGridItem(photo: photos[index]),
)
```

### Using Convenience Constructors

```dart
// Photo grid (optimized for galleries)
VirtualGridView.photoGrid<Photo>(
  itemCount: photos.length,
  crossAxisCount: 3,
  itemBuilder: (context, index) => PhotoCard(photo: photos[index]),
)

// Card grid (optimized for cards)
VirtualGridView.cardGrid<Item>(
  itemCount: items.length,
  crossAxisCount: 2,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
)
```

## Performance Considerations

### List Views
1. **Fixed Item Extent**: If items have consistent height, set `itemExtent` for better performance
2. **Avoid Complex Builds**: Keep item builders simple for smooth scrolling
3. **Use const Constructors**: Use `const` wherever possible in item widgets
4. **Efficient Separators**: Use the built-in `separatorBuilder` instead of wrapping items

### Grid Views
1. **Aspect Ratio**: Use consistent aspect ratios for better performance
2. **Image Optimization**: Use thumbnails instead of full-size images in grid
3. **Column Count**: Adjust based on screen size for optimal density
4. **Spacing**: Minimal spacing (2-4px) for tighter grids, more for cards

## Migration

### From ListView.builder to VirtualListView

**Before:**
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(item: items[index]);
  },
)
```

**After:**
```dart
VirtualListView<Item>(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
)
```

### From GridView.builder to VirtualGridView

**Before:**
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
  ),
  itemCount: photos.length,
  itemBuilder: (context, index) {
    return PhotoWidget(photo: photos[index]);
  },
)
```

**After:**
```dart
VirtualGridView<Photo>(
  itemCount: photos.length,
  crossAxisCount: 3,
  itemBuilder: (context, index) => PhotoWidget(photo: photos[index]),
)
```

## Future Enhancements

- [ ] Add pull-to-refresh functionality
- [ ] Implement infinite scroll pagination
- [ ] Add search and filtering
- [ ] Implement swipe-to-actions (edit, delete)
- [ ] Add animations for item insertion/deletion
- [ ] Support for sticky headers with date grouping
- [ ] Implement drag-and-drop reordering
- [ ] Full-screen photo viewer with zoom
- [ ] Multi-select for batch operations
- [ ] Photo editing tools

## Testing

To test these screens with large datasets:

```dart
// For list views
final testTrips = PerformanceTestDataGenerator().generateTrips(500);

// For photo gallery
final testPhotos = PhotoDataGenerator().generatePhotos(500);
// Use test data with provider overrides
```

See:
- `test/utils/performance/performance_test_utils.dart` - Test data generation utilities
- `lib/features/travel/presentation/PHOTO_GALLERY_README.md` - Photo gallery documentation
- `lib/core/widgets/VIRTUAL_GRID_VIEW_README.md` - VirtualGridView documentation

## Related Documentation

- [Photo Gallery Documentation](./PHOTO_GALLERY_README.md) - Detailed guide for PhotoGalleryScreen
- [VirtualGridView Documentation](../../core/widgets/VIRTUAL_GRID_VIEW_README.md) - VirtualGridView widget guide
- [VirtualListView Documentation](../../core/widgets/README.md) - VirtualListView widget guide
