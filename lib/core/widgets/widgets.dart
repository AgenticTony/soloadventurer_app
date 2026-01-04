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
///
/// ## Usage
///
/// ```dart
/// import 'package:soloadventurer/core/widgets/widgets.dart';
///
/// VirtualListView<String>(
///   itemCount: items.length,
///   itemBuilder: (context, index) => Text(items[index]),
/// )
/// ```

export 'virtual_list_view.dart';
