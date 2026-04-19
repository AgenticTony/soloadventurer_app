import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/travel/domain/models/photo.dart';
import 'package:soloadventurer/features/travel/presentation/screens/photo_gallery_screen.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  group('PhotoGalleryScreen', () {
    Future<void> pumpPhotoGallery(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PhotoGalleryScreen(),
        ),
      );
      // Flush the Future.delayed(500ms) from _fetchPhotos
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('renders app bar with title', (tester) async {
      await pumpPhotoGallery(tester);

      expect(find.text('Photo Gallery'), findsOneWidget);
    });

    testWidgets('renders action buttons', (tester) async {
      await pumpPhotoGallery(tester);

      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byType(PopupMenuButton<PhotoSortOption>), findsOneWidget);
    });

    testWidgets('renders floating action button with camera icon',
        (tester) async {
      await pumpPhotoGallery(tester);

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
    });

    testWidgets('displays sort menu items', (tester) async {
      await pumpPhotoGallery(tester);

      // Tap on menu button
      await tester.tap(find.byType(PopupMenuButton<PhotoSortOption>));
      await tester.pump(const Duration(seconds: 1));

      // Verify menu items
      expect(find.text('Newest first'), findsOneWidget);
      expect(find.text('Oldest first'), findsOneWidget);
      expect(find.text('By location'), findsOneWidget);
    });

    testWidgets('renders PhotoGalleryScreen widget', (tester) async {
      await pumpPhotoGallery(tester);

      expect(find.byType(PhotoGalleryScreen), findsOneWidget);
    });

    testWidgets('tapping grid view button does not crash', (tester) async {
      await pumpPhotoGallery(tester);

      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pump();

      expect(find.byType(PhotoGalleryScreen), findsOneWidget);
    });

    testWidgets('tapping filter button does not crash', (tester) async {
      await pumpPhotoGallery(tester);

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pump();

      expect(find.byType(PhotoGalleryScreen), findsOneWidget);
    });

    testWidgets('tapping FAB does not crash', (tester) async {
      await pumpPhotoGallery(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.byType(PhotoGalleryScreen), findsOneWidget);
    });
  });

  group('PhotoSortOption', () {
    test('has all expected values', () {
      expect(PhotoSortOption.values, contains(PhotoSortOption.newest));
      expect(PhotoSortOption.values, contains(PhotoSortOption.oldest));
      expect(PhotoSortOption.values, contains(PhotoSortOption.location));
    });

    test('has exactly 3 values', () {
      expect(PhotoSortOption.values.length, 3);
    });
  });

  group('Photo model', () {
    test('creates photo with required fields', () {
      final photo = Photo(
        id: 'photo_1',
        imageUrl: 'https://example.com/photo1.jpg',
        tripId: 'trip_1',
        takenAt: DateTime(2026, 1, 4),
        width: 800,
        height: 600,
        sizeInBytes: 102400,
        createdAt: DateTime(2026, 1, 4),
      );

      expect(photo.id, 'photo_1');
      expect(photo.imageUrl, 'https://example.com/photo1.jpg');
      expect(photo.tripId, 'trip_1');
      expect(photo.width, 800);
      expect(photo.height, 600);
    });

    test('creates photo with optional caption', () {
      final photo = Photo(
        id: 'photo_1',
        imageUrl: 'https://example.com/photo1.jpg',
        caption: 'Beautiful sunset',
        tripId: 'trip_1',
        takenAt: DateTime(2026, 1, 4),
        width: 800,
        height: 600,
        sizeInBytes: 102400,
        createdAt: DateTime(2026, 1, 4),
      );

      expect(photo.caption, 'Beautiful sunset');
    });

    test('creates photo with optional location', () {
      final photo = Photo(
        id: 'photo_1',
        imageUrl: 'https://example.com/photo1.jpg',
        location: 'Paris, France',
        tripId: 'trip_1',
        takenAt: DateTime(2026, 1, 4),
        width: 800,
        height: 600,
        sizeInBytes: 102400,
        createdAt: DateTime(2026, 1, 4),
      );

      expect(photo.location, 'Paris, France');
    });

    test('creates photo with optional thumbnail URL', () {
      final photo = Photo(
        id: 'photo_1',
        imageUrl: 'https://example.com/photo1.jpg',
        thumbnailUrl: 'https://example.com/thumb1.jpg',
        tripId: 'trip_1',
        takenAt: DateTime(2026, 1, 4),
        width: 800,
        height: 600,
        sizeInBytes: 102400,
        createdAt: DateTime(2026, 1, 4),
      );

      expect(photo.thumbnailUrl, 'https://example.com/thumb1.jpg');
    });
  });
}
