/// Core utilities for SoloAdventurer
///
/// This directory contains reusable utilities used across the application.
/// These utilities are designed to be feature-agnostic and can be used
/// in any part of the app.
///
/// ## Available Utilities
///
/// - [ScrollPerformanceTracker]: Tracks scroll performance metrics (velocity, FPS)
/// - [Debouncer]: Debounces operations to reduce redundant calls
/// - [QueryBatcher]: Batches multiple queries together for efficiency
/// - [PreloadingManager]: Manages intelligent preloading strategies
///
/// ## Usage
///
/// ```dart
/// import 'package:soloadventurer/core/utils/utils.dart';
///
/// // Debounce search queries
/// final debouncer = Debouncer<PaginatedData<Trip>>(
///   duration: const Duration(milliseconds: 500),
/// );
///
/// debouncer.debounce(
///   input: searchQuery,
///   action: () => repository.search(query),
///   onComplete: (result) {
///     if (result.executed) showResults(result.value);
///   },
/// );
///
/// // Batch multiple queries
/// final batcher = QueryBatcher(
///   config: BatchConfig.aggressive,
/// );
///
/// final trips = batcher.add(
///   key: 'trips',
///   query: () => repository.getTrips(),
/// );
///
/// final activities = batcher.add(
///   key: 'activities',
///   query: () => repository.getActivities(),
/// );
///
/// final results = await batcher.execute();
///
/// // Intelligent preloading
/// InfiniteScrollListView<Trip>.withIntelligentPreloading(
///   fetchData: (cursor) => repository.getTripsCursor(cursor: cursor),
///   itemBuilder: (context, trip) => TripCard(trip: trip),
///   preloadConfig: PreloadConfig.defaultConfig,
/// )
/// ```
library;

export 'scroll_performance_tracker.dart';
export 'debounce.dart';
export 'query_batcher.dart';
export 'preloading_strategy.dart';
