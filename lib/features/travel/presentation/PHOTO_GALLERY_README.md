# Photo Gallery Screen Documentation

## Overview

The `PhotoGalleryScreen` is a virtualized grid view for displaying large photo galleries (500+ photos) with optimal performance. It uses the `VirtualGridView` widget to efficiently render only visible photos, ensuring smooth scrolling and minimal memory usage.

## Features

### Virtual Scrolling Grid
- **Efficient Rendering**: Only renders visible photos using `GridView.builder`
- **Memory Optimized**: Handles 500+ photos without performance degradation
- **Responsive Layout**: Automatically adjusts column count based on screen size
  - Small phones: 2 columns
  - Large phones: 3 columns
  - Tablets: 4 columns

### Photo Display
- **Image Loading**: Progressive loading with loading indicators
- **Error Handling**: Graceful fallback for failed image loads
- **Thumbnail Support**: Uses thumbnails when available for faster loading
- **Caption Overlay**: Optional captions displayed at bottom of photos
- **Location Indicator**: Shows location icon for geotagged photos

### User Interaction
- **Tap to View**: Tap on any photo to open full-screen viewer
- **View Toggle**: Switch between grid and list views
- **Filter Options**: Filter photos by date, location, etc.
- **Sort Menu**: Sort by newest, oldest, or location
- **Add Photo**: Floating action button to add new photos

### State Management
- **Loading State**: Shows loading indicator while fetching photos
- **Error State**: Displays error message with retry button
- **Empty State**: Helpful message when no photos are available

## Architecture

### Widget Structure

```
PhotoGalleryScreen
├── AppBar (title, actions)
├── VirtualGridView<Photo>
│   ├── _PhotoGridItem
│   │   ├── _PhotoImage
│   │   ├── _PhotoCaption (optional)
│   │   └── _LocationIcon (optional)
└── FloatingActionButton
```

### Data Flow

```
photosProvider (Riverpod)
    ↓
PhotoGalleryScreen (ConsumerWidget)
    ↓
VirtualGridView<Photo>
    ↓
_PhotoGridItem (individual photo cards)
```

### Key Components

1. **Photo Model** (`lib/features/travel/domain/models/photo.dart`)
   - Represents a photo with metadata
   - Contains URL, caption, location, timestamp, dimensions
   - Provides thumbnail fallback logic

2. **VirtualGridView** (`lib/core/widgets/virtual_grid_view.dart`)
   - Generic grid widget with virtual scrolling
   - Supports headers, footers, loading, error, and empty states
   - Configurable column count and spacing

3. **PhotoGalleryScreen** (`lib/features/travel/presentation/screens/photo_gallery_screen.dart`)
   - Main screen displaying the photo gallery
   - Uses Riverpod for state management
   - Handles user interactions

4. **_PhotoGridItem** (private widget)
   - Individual photo grid item
   - Displays photo image, caption, and location
   - Handles tap gestures for navigation

## Usage

### Basic Usage

```dart
import 'package:soloadventurer/features/travel/presentation/screens/screens.dart';

// Navigate to photo gallery
Navigator.pushNamed(context, PhotoGalleryScreen.routeName);
```

### With Custom Provider

```dart
// Override photos provider for testing or specific trip
ProviderScope(
  overrides: [
    photosProvider.overrideWithValue(myPhotos),
  ],
  child: PhotoGalleryScreen(),
)
```

### Filtering Photos

```dart
// Filter photos by trip
final tripPhotos = allPhotos.where((p) => p.tripId == tripId).toList();

// Filter by date range
final recentPhotos = photos.where((p) =>
  p.takenAt.isAfter(startDate) && p.takenAt.isBefore(endDate)
).toList();

// Filter by location
final parisPhotos = photos.where((p) =>
  p.location?.contains('Paris') == true
).toList();
```

## Performance Considerations

### Memory Efficiency
- **Virtual Scrolling**: Only renders visible photos (typically 10-20 items)
- **Image Caching**: Uses Flutter's built-in image caching
- **Thumbnail Loading**: Prefers thumbnails over full-size images
- **Automatic Cleanup**: Unloads off-screen images automatically

### Optimizations
1. **Lazy Loading**: Images load as they come into view
2. **Placeholder Strategy**: Shows loading indicators during fetch
3. **Error Boundaries**: Isolates image load failures
4. **Key Management**: Uses `ValueKey` for efficient widget updates

### Performance Targets
- **Render 500 photos**: < 2 seconds
- **Scroll FPS**: ≥ 55 FPS
- **Memory Usage**: < 150 MB for 500 photos
- **Initial Load**: < 1 second for first batch

## Testing

### Test Coverage

The test suite (`photo_gallery_screen_test.dart`) covers:

- ✅ Empty state rendering
- ✅ Loading state display
- ✅ Error state handling
- ✅ Photo grid layout rendering
- ✅ 500+ photos efficient rendering
- ✅ Photo caption display
- ✅ Photo location indicator
- ✅ Responsive column count calculation
- ✅ Sort menu functionality

### Running Tests

```bash
# Run all photo gallery tests
flutter test test/features/travel/presentation/screens/photo_gallery_screen_test.dart

# Run with coverage
flutter test --coverage test/features/travel/presentation/screens/photo_gallery_screen_test.dart

# Run specific test
flutter test test/features/travel/presentation/screens/photo_gallery_screen_test.dart --name "renders empty state"
```

## Route Configuration

The photo gallery is registered at:
- **Route**: `/trips/photos`
- **Constant**: `TravelRoutes.photos`
- **Screen**: `PhotoGalleryScreen`

## Future Enhancements

### Planned Features
1. **Full-Screen Viewer**: Swipeable photo viewer with zoom
2. **Multi-Select**: Select multiple photos for batch operations
3. **Photo Editing**: Basic editing tools (crop, rotate, filters)
4. **Albums**: Organize photos into albums or collections
5. **Slideshow**: Automatic slideshow mode
6. **Map View**: Show photos on a map
7. **Sharing**: Share photos to social media or messaging
8. **Offline Mode**: Cache photos for offline viewing
9. **Face Recognition**: Auto-tag people in photos
10. **Auto-Enhancement**: AI-powered photo enhancement

### Performance Enhancements
1. **Progressive Loading**: Load low-res first, then high-res
2. **Prefetching**: Preload next batch of photos
3. **Compression**: Compress photos before upload
4. **CDN Integration**: Use CDN for faster image delivery
5. **WebP Support**: Use WebP format for better compression

## Code Examples

### Creating a Photo

```dart
final photo = Photo(
  id: 'photo_123',
  imageUrl: 'https://example.com/photo.jpg',
  thumbnailUrl: 'https://example.com/photo_thumb.jpg',
  caption: 'Beautiful sunset at the beach',
  tripId: 'trip_456',
  location: 'Santa Monica, CA',
  latitude: 34.0195,
  longitude: -118.4912,
  takenAt: DateTime.now(),
  width: 1920,
  sizeInBytes: 512000,
  createdAt: DateTime.now(),
);
```

### Loading Photos from Repository

```dart
final photosProvider = FutureProvider.autoDispose<List<Photo>>((ref) async {
  final repository = ref.watch(photoRepositoryProvider);
  return repository.fetchPhotos(tripId: 'trip_123');
});

// In widget
final photosAsync = ref.watch(photosProvider);

return photosAsync.when(
  data: (photos) => PhotoGridView(photos: photos),
  loading: () => LoadingIndicator(),
  error: (err, stack) => ErrorWidget(err),
);
```

### Customizing Grid Layout

```dart
VirtualGridView<Photo>(
  itemCount: photos.length,
  crossAxisCount: 4,
  childAspectRatio: 1.0,
  crossAxisSpacing: 2.0,
  mainAxisSpacing: 2.0,
  itemBuilder: (context, index) => PhotoCard(photo: photos[index]),
)
```

## Troubleshooting

### Common Issues

1. **Images Not Loading**
   - Check internet connection
   - Verify image URLs are accessible
   - Check CORS policies for remote images
   - Review error logs in dev tools

2. **Poor Performance**
   - Reduce image size before upload
   - Use thumbnails in grid view
   - Implement pagination for large galleries
   - Check memory usage in Flutter DevTools

3. **Memory Leaks**
   - Ensure providers are properly disposed
   - Check for circular references
   - Use `autoDispose` for providers
   - Monitor memory in DevTools

4. **Layout Issues**
   - Verify column count calculation
   - Check MediaQuery for screen size
   - Test on different device sizes
   - Review aspect ratio settings

## Related Files

- `lib/features/travel/domain/models/photo.dart` - Photo model
- `lib/core/widgets/virtual_grid_view.dart` - VirtualGridView widget
- `lib/features/travel/presentation/screens/photo_gallery_screen.dart` - Main screen
- `test/features/travel/presentation/screens/photo_gallery_screen_test.dart` - Tests
- `lib/features/travel/presentation/routes/travel_routes.dart` - Route constants

## Dependencies

- `flutter_riverpod`: State management
- `flutter`: UI framework
- `cached_network_image`: Image caching (phase 3)

## References

- [Flutter GridView Documentation](https://api.flutter.dev/flutter/widgets/GridView-class.html)
- [Riverpod Documentation](https://riverpod.dev/)
- [Performance Best Practices](https://flutter.dev/docs/perf/rendering/best-practices)
- [Image Optimization Guide](https://flutter.dev/docs/development/ui/images)
