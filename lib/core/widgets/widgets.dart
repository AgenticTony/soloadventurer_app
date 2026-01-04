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
///
/// ## Usage
///
/// ```dart
/// import 'package:soloadventurer/core/widgets/widgets.dart';
///
/// // List view
/// VirtualListView<String>(
///   itemCount: items.length,
///   itemBuilder: (context, index) => Text(items[index]),
/// )
///
/// // Grid view
/// VirtualGridView<String>(
///   itemCount: photos.length,
///   crossAxisCount: 3,
///   itemBuilder: (context, index) => ImageCard(photo: photos[index]),
/// )
/// ```

export 'virtual_list_view.dart';
export 'virtual_grid_view.dart';
