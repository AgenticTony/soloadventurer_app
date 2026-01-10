import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';

part 'journal_entry_detail_provider.g.dart';

/// State for journal entry detail view
class JournalEntryDetailState {
  /// The journal entry being viewed
  final JournalEntry? entry;

  /// Media items attached to this entry
  final List<MediaItem> mediaItems;

  /// Whether data is currently loading
  final bool isLoading;

  /// Error message if any
  final String? error;

  /// Whether the entry is being deleted
  final bool isDeleting;

  /// Whether there's any content to display
  bool get hasEntry => entry != null;

  /// Whether there are media items
  bool get hasMedia => mediaItems.isNotEmpty;

  const JournalEntryDetailState({
    this.entry,
    this.mediaItems = const [],
    this.isLoading = false,
    this.error,
    this.isDeleting = false,
  });

  JournalEntryDetailState copyWith({
    JournalEntry? entry,
    List<MediaItem>? mediaItems,
    bool? isLoading,
    String? error,
    bool? isDeleting,
  }) {
    return JournalEntryDetailState(
      entry: entry ?? this.entry,
      mediaItems: mediaItems ?? this.mediaItems,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

// ============================================================================
// Journal Entry Detail Notifier (Riverpod 3.0 Family Provider)
// ============================================================================

/// Notifier for managing journal entry detail state
/// MIGRATION: StateNotifier → Notifier pattern with family parameter
/// - entryId is passed as a parameter to the build() method (family provider)
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
/// Usage: ref.watch(journalEntryDetailProvider(entryId))
@riverpod
class JournalEntryDetail extends _$JournalEntryDetail {
  @override
  JournalEntryDetailState build(String entryId) {
    // Initial load happens automatically when provider is first accessed
    // Note: We don't call _loadEntry() here to avoid issues during build
    return const JournalEntryDetailState();
  }

  /// Load the journal entry and its media
  Future<void> _loadEntry() async {
    final repository = ref.watch(journalRepositoryProvider);
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch the entry
      final entry = await repository.getEntry(entryId);

      // Fetch media items for this entry
      final mediaItems = await repository.getMediaForEntry(entryId);

      state = state.copyWith(
        entry: entry,
        mediaItems: mediaItems,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load entry: ${e.toString()}',
      );
    }
  }

  /// Refresh the entry data
  Future<void> refresh() async {
    await _loadEntry();
  }

  /// Delete the current entry
  Future<bool> deleteEntry() async {
    if (state.entry == null) {
      return false;
    }

    final repository = ref.watch(journalRepositoryProvider);
    state = state.copyWith(isDeleting: true, error: null);

    try {
      await repository.deleteEntry(entryId);
      state = state.copyWith(isDeleting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Failed to delete entry: ${e.toString()}',
      );
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite() async {
    if (state.entry == null) {
      return false;
    }

    final repository = ref.watch(journalRepositoryProvider);

    try {
      final updatedEntry = state.entry!.copyWith(
        isFavorite: !state.entry!.isFavorite,
      );

      await repository.updateEntry(updatedEntry);

      // Update local state
      state = state.copyWith(entry: updatedEntry);

      return true;
    } catch (e) {
      state =
          state.copyWith(error: 'Failed to update favorite: ${e.toString()}');
      return false;
    }
  }

  /// Clear any error message
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}
