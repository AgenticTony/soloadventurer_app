/// Core widgets for SoloAdventurer
///
/// This directory contains reusable widgets used across the application.
/// These widgets are designed to be feature-agnostic and can be used
/// in any part of the app.
///
/// ## Available Widgets
///
/// - [VirtualListView]: A generic virtual scrolling list for efficient
///   rendering of large datasets (500+ items)
/// - [VirtualGridView]: A generic virtual scrolling grid for efficient
///   rendering of large photo galleries (500+ items)
/// - [InfiniteScrollListView]: A generic infinite scroll list with automatic
///   pagination for handling large datasets with efficient memory usage
/// - [InfiniteScrollGridView]: A generic infinite scroll grid with automatic
///   pagination for handling large photo galleries with efficient memory usage
/// - [VirtualListPerformanceTracker]: A performance tracking wrapper that
///   monitors render times, memory usage, and frame rates for virtual lists
/// - [LazyLoadImage]: A visibility-based lazy loading image widget that
///   only loads images when they become visible on screen
/// - [ImagePlaceholder]: A collection of optimized placeholder widgets
///   for image loading states (shimmer, skeleton, color, blurred)
/// - [ImageErrorWidget]: Enhanced error widget with retry functionality,
///   offline detection, and error type classification
/// - [MapMarkerWidget]: Customizable widget for displaying single map markers
///   with type-based styling and tap handling
/// - [MapClusterWidget]: Widget for displaying marker clusters with count
///   and size-based color coding
/// - [OptimizedListItem]: A wrapper widget that adds RepaintBoundary to
///   isolate repaints and improve list performance
/// - [MultiStageImageLoader]: A multi-stage progressive image loader that
///   loads thumbnail → medium → full resolution for optimal performance
///
/// ## Usage
///
/// ```dart
/// import 'package:soloadventurer/core/widgets/widgets.dart';
///
/// // Simple list view
/// VirtualListView<String>(
///   itemCount: items.length,
///   itemBuilder: (context, index) => Text(items[index]),
/// )
///
/// // Infinite scroll with pagination
/// InfiniteScrollListView<Trip>(
///   fetchData: (cursor) async {
///     return await tripRepository.getTripsCursor(
///       userId: 'user123',
///       cursor: cursor,
///       pageSize: 20,
///     );
///   },
///   itemBuilder: (context, trip) => TripCard(trip: trip),
/// )
///
/// // Grid view
/// VirtualGridView<String>(
///   itemCount: photos.length,
///   crossAxisCount: 3,
///   itemBuilder: (context, index) => ImageCard(photo: photos[index]),
/// )
///
/// // Infinite scroll grid with pagination
/// InfiniteScrollGridView<Photo>(
///   crossAxisCount: 3,
///   fetchData: (cursor) async {
///     return await photoRepository.getPhotosCursor(
///       tripId: 'trip123',
///       cursor: cursor,
///       pageSize: 20,
///     );
///   },
///   itemBuilder: (context, photo) => PhotoGridItem(photo: photo),
/// )
///
/// // Optimized lazy loading image with shimmer placeholder
/// LazyLoadImage.optimized(
///   imageUrl: photo.url,
///   thumbnailUrl: photo.thumbnailUrl,
///   size: 100.0,
///   onRetry: () => ref.refresh(photoProvider),
/// )
///
/// // Custom placeholder
/// LazyLoadImage(
///   imageUrl: url,
///   placeholder: (context, url) => ImagePlaceholder.shimmer(),
///   errorWidget: (context, url, error) => ImageErrorWidget.withRetry(
///     error: error,
///     imageUrl: url,
///     onRetry: () => setState(() {}),
///   ),
/// )
///
/// // With performance tracking
/// VirtualListPerformanceTracker(
///   itemName: 'Trip Items',
///   showOverlay: true,
///   onMetricsUpdated: (metrics) {
///     if (kDebugMode) {
///       debugPrint(metrics.toString());
///     }
///   },
///   child: VirtualListView<Trip>(
///     itemCount: trips.length,
///     itemBuilder: (context, index) => TripCard(trip: trips[index]),
///   ),
/// )
///
/// // Multi-stage image loading
/// MultiStageImageLoader.photoGrid(
///   thumbnailUrl: photo.thumbnailUrl,
///   mediumUrl: photo.mediumUrl,
///   fullUrl: photo.fullUrl,
///   size: 150.0,
///   loadFullOnTap: true,
///   onStageChanged: (stage) => debugPrint('Stage: $stage'),
/// )
/// ```

export 'virtual_list_view.dart';
export 'virtual_grid_view.dart';
export 'infinite_scroll_list_view.dart';
export 'virtual_list_performance_tracker.dart';
export 'lazy_load_image.dart';
export 'image_placeholder.dart';
export 'image_error_widget.dart';
export 'map_marker_widgets.dart';
export 'optimized_list_item.dart';
export 'multi_stage_image_loader.dart';
