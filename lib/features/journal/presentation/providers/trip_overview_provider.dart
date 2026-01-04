import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/features/journal/domain/repositories/journal_repository.dart';

// ============================================================================
// Trip Overview State
// ============================================================================

/// State for trip overview (entries and media)
class TripOverviewState {
  final List<JournalEntry> entries;
  final List<MediaItem> mediaItems;
  final bool isLoadingEntries;
  final bool isLoadingMedia;
  final String? error;

  const TripOverviewState({
    this.entries = const [],
    this.mediaItems = const [],
    this.isLoadingEntries = false,
    this.isLoadingMedia = false,
    this.error,
  });

  TripOverviewState copyWith({
    List<JournalEntry>? entries,
    List<MediaItem>? mediaItems,
    bool? isLoadingEntries,
    bool? isLoadingMedia,
    String? error,
  }) {
    return TripOverviewState(
      entries: entries ?? this.entries,
      mediaItems: mediaItems ?? this.mediaItems,
      isLoadingEntries: isLoadingEntries ?? this.isLoadingEntries,
      isLoadingMedia: isLoadingMedia ?? this.isLoadingMedia,
      error: error,
    );
  }

  /// Whether any data is currently loading
  bool get isLoading => isLoadingEntries || isLoadingMedia;

  /// Total count of entries
  int get entryCount => entries.length;

  /// Total count of media items
  int get mediaCount => mediaItems.length;

  /// Whether there's any content to display
  bool get hasContent => entries.isNotEmpty || mediaItems.isNotEmpty;

  /// Entries sorted by date (newest first)
  List<JournalEntry> get sortedEntries => entries.toList()
    ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

  /// Media items sorted by created date (newest first)
  List<MediaItem> get sortedMedia => mediaItems.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

// ============================================================================
// Trip Overview Notifier
// ============================================================================

/// Notifier for managing trip overview state
class TripOverviewNotifier extends StateNotifier<TripOverviewState> {
  final JournalRepository _repository;
  String _currentTripId = '';

  TripOverviewNotifier(this._repository) : super(const TripOverviewState());

  /// Loads all entries and media for a trip
  Future<void> loadTripContent(String tripId) async {
    _currentTripId = tripId;
    state = state.copyWith(
      isLoadingEntries: true,
      isLoadingMedia: true,
      error: null,
    );

    try {
      // Load entries and media in parallel
      final results = await Future.wait([
        _repository.getEntriesByTrip(tripId),
        _repository.getMediaForTrip(tripId),
      ]);

      final entries = results[0] as List<JournalEntry>;
      final mediaItems = results[1] as List<MediaItem>;

      state = state.copyWith(
        entries: entries,
        mediaItems: mediaItems,
        isLoadingEntries: false,
        isLoadingMedia: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingEntries: false,
        isLoadingMedia: false,
        error: e.toString(),
      );
    }
  }

  /// Reloads the current trip content
  Future<void> refresh() async {
    if (_currentTripId.isEmpty) return;
    await loadTripContent(_currentTripId);
  }

  /// Clears any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================================================
// Providers
// ============================================================================

/// Provides the journal repository
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  // This should be overridden in the main app with the actual implementation
  throw UnimplementedError('JournalRepository not implemented');
});

/// Provider for trip overview state (family provider for different trip IDs)
final tripOverviewProvider = StateNotifierProvider.family<TripOverviewNotifier, TripOverviewState, String>((ref, tripId) {
  final repository = ref.watch(journalRepositoryProvider);
  final notifier = TripOverviewNotifier(repository);
  // Load the trip content immediately
  Future.microtask(() => notifier.loadTripContent(tripId));
  return notifier;
});
