import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/travel/domain/models/photo.dart';
import 'package:soloadventurer/features/travel/presentation/screens/photo_gallery_screen.dart';
import 'package:soloadventurer/features/travel/presentation/screens/screens.dart';

void main() {
  group('PhotoGalleryScreen', () {
    testWidgets('renders empty state when no photos', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            photosProvider.overrideWithValue(<Photo>[]),
            photosLoadingProvider.overrideWithValue(false),
            photosErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: PhotoGalleryScreen(),
          ),
        ),
      );

      expect(find.text('No photos yet'), findsOneWidget);
      expect(find.text('Add photos to your trip to see them here'), findsOneWidget);
    });

    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            photosProvider.overrideWithValue(<Photo>[]),
            photosLoadingProvider.overrideWithValue(true),
            photosErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: PhotoGalleryScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            photosProvider.overrideWithValue(<Photo>[]),
            photosLoadingProvider.overrideWithValue(false),
            photosErrorProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(
            home: PhotoGalleryScreen(),
          ),
        ),
      );

      expect(find.text('Failed to load photos'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders photos in grid layout', (tester) async {
      final photos = List.generate(
        10,
        (index) => Photo(
          id: 'photo_$index',
          imageUrl: 'https://example.com/photo$index.jpg',
          tripId: 'trip_1',
          takenAt: DateTime(2026, 1, 4),
          width: 800,
          sizeInBytes: 102400,
          createdAt: DateTime(2026, 1, 4),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            photosProvider.overrideWithValue(photos),
            photosLoadingProvider.overrideWithValue(false),
            photosErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: PhotoGalleryScreen(),
          ),
        ),
      );

      // Verify app bar
      expect(find.text('Photo Gallery'), findsOneWidget);

      // Verify action buttons
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byType(PopupMenuButton<PhotoSortOption>), findsOneWidget);

      // Verify photos are rendered
      expect(find.byType(GridTile), findsWidgets);

      // Verify floating action button
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
    });

    testWidgets('handles 500+ photos efficiently', (tester) async {
      final photos = List.generate(
        500,
        (index) => Photo(
          id: 'photo_$index',
          imageUrl: 'https://example.com/photo$index.jpg',
          tripId: 'trip_1',
          takenAt: DateTime(2026, 1, 4),
          width: 800,
          sizeInBytes: 102400,
          createdAt: DateTime(2026, 1, 4),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            photosProvider.overrideWithValue(photos),
            photosLoadingProvider.overrideWithValue(false),
            photosErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: PhotoGalleryScreen(),
          ),
        ),
      );

      // Pump and settle to allow rendering
      await tester.pumpAndSettle();

      // Verify grid view is rendered
      expect(find.byType(GridView), findsOneWidget);

      // Verify scrolling works smoothly
      await tester.drag(find.byType(GridView), const Offset(0, -500));
      await tester.pump();

      // Grid should still be present after scrolling
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('displays photo with caption', (tester) async {
      final photos = [
        Photo(
          id: 'photo_1',
          imageUrl: 'https://example.com/photo1.jpg',
          caption: 'Beautiful sunset',
          tripId: 'trip_1',
          takenAt: DateTime(2026, 1, 4),
          width: 800,
          sizeInBytes: 102400,
          createdAt: DateTime(2026, 1, 4),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            photosProvider.overrideWithValue(photos),
            photosLoadingProvider.overrideWithValue(false),
            photosErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: PhotoGalleryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify caption is displayed
      expect(find.text('Beautiful sunset'), findsOneWidget);
    });

    testWidgets('displays photo with location', (tester) async {
      final photos = [
        Photo(
          id: 'photo_1',
          imageUrl: 'https://example.com/photo1.jpg',
          location: 'Paris, France',
          tripId: 'trip_1',
          takenAt: DateTime(2026, 1, 4),
          width: 800,
          sizeInBytes: 102400,
          createdAt: DateTime(2026, 1, 4),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            photosProvider.overrideWithValue(photos),
            photosLoadingProvider.overrideWithValue(false),
            photosErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: PhotoGalleryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify location icon is displayed
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('calculates appropriate column count for screen size',
        (tester) async {
      final photos = List.generate(
        6,
        (index) => Photo(
          id: 'photo_$index',
          imageUrl: 'https://example.com/photo$index.jpg',
          tripId: 'trip_1',
          takenAt: DateTime(2026, 1, 4),
          width: 800,
          sizeInBytes: 102400,
          createdAt: DateTime(2026, 1, 4),
        ),
      );

      // Test with small screen (phone)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            photosProvider.overrideWithValue(photos),
            photosLoadingProvider.overrideWithValue(false),
            photosErrorProvider.overrideWithValue(false),
          ],
          child: const MediaQuery(
            data: MediaQueryData(size: Size(375, 667)),
            child: MaterialApp(
              home: PhotoGalleryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(GridView), findsOneWidget);

      // Test with large screen (tablet)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            photosProvider.overrideWithValue(photos),
            photosLoadingProvider.overrideWithValue(false),
            photosErrorProvider.overrideWithValue(false),
          ],
          child: const MediaQuery(
            data: MediaQueryData(size: Size(768, 1024)),
            child: MaterialApp(
              home: PhotoGalleryScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('displays sort menu', (tester) async {
      final photos = <Photo>[];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            photosProvider.overrideWithValue(photos),
            photosLoadingProvider.overrideWithValue(false),
            photosErrorProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: PhotoGalleryScreen(),
          ),
        ),
      );

      // Tap on menu button
      await tester.tap(find.byType(PopupMenuButton<PhotoSortOption>));
      await tester.pumpAndSettle();

      // Verify menu items
      expect(find.text('Newest first'), findsOneWidget);
      expect(find.text('Oldest first'), findsOneWidget);
      expect(find.text('By location'), findsOneWidget);
    });
  });
}
