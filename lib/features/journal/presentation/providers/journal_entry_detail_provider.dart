import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';
import 'package:soloadventurer/features/journal/domain/repositories/journal_repository.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';

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

/// Notifier for managing journal entry detail state
class JournalEntryDetailNotifier extends StateNotifier<JournalEntryDetailState> {
  final JournalRepository _repository;
  final String entryId;

  JournalEntryDetailNotifier(this._repository, this.entryId)
      : super(const JournalEntryDetailState()) {
    _loadEntry();
  }

  /// Load the journal entry and its media
  Future<void> _loadEntry() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch the entry
      final entry = await _repository.getEntry(entryId);

      if (entry == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Journal entry not found',
        );
        return;
      }

      // Fetch media items for this entry
      final mediaItems = await _repository.getMediaForEntry(entryId);

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

    state = state.copyWith(isDeleting: true, error: null);

    try {
      await _repository.deleteEntry(entryId);
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

    try {
      final updatedEntry = state.entry!.copyWith(
        isFavorite: !state.entry!.isFavorite,
      );

      await _repository.updateEntry(updatedEntry);

      // Update local state
      state = state.copyWith(entry: updatedEntry);

      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update favorite: ${e.toString()}');
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

/// Provider for a journal entry detail view
/// Usage: ref.watch(journalEntryDetailProvider(entryId))
final journalEntryDetailProvider = StateNotifierProvider.family<
    JournalEntryDetailNotifier, JournalEntryDetailState, String>(
  (ref, entryId) {
    final repository = ref.watch(journalRepositoryProvider);
    return JournalEntryDetailNotifier(repository, entryId);
  },
);
