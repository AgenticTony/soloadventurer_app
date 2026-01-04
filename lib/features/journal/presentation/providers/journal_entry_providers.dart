import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/repositories/journal_repository.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart';

/// State for journal entry creation
class JournalEntryCreationState {
  /// Title of the entry
  final String title;

  /// Content of the entry (Delta JSON format)
  final String content;

  /// Date of the entry
  final DateTime entryDate;

  /// Trip ID if entry belongs to a trip
  final String? tripId;

  /// Mood of the entry
  final String? mood;

  /// Location name
  final String? locationName;

  /// Latitude coordinate
  final double? latitude;

  /// Longitude coordinate
  final double? longitude;

  /// Whether the entry is marked as favorite
  final bool isFavorite;

  /// Whether a save operation is in progress
  final bool isSaving;

  /// Error message if any
  final String? error;

  /// Whether the form is valid
  bool get isValid => title.trim().isNotEmpty && content.trim().isNotEmpty;

  const JournalEntryCreationState({
    this.title = '',
    this.content = '',
    DateTime? entryDate,
    this.tripId,
    this.mood,
    this.locationName,
    this.latitude,
    this.longitude,
    this.isFavorite = false,
    this.isSaving = false,
    this.error,
  }) : entryDate = entryDate ?? DateTime.now();

  JournalEntryCreationState copyWith({
    String? title,
    String? content,
    DateTime? entryDate,
    String? tripId,
    String? mood,
    String? locationName,
    double? latitude,
    double? longitude,
    bool? isFavorite,
    bool? isSaving,
    String? error,
  }) {
    return JournalEntryCreationState(
      title: title ?? this.title,
      content: content ?? this.content,
      entryDate: entryDate ?? this.entryDate,
      tripId: mood != null ? tripId : this.tripId,
      mood: mood,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

/// Notifier for managing journal entry creation state
class JournalEntryCreationNotifier
    extends StateNotifier<JournalEntryCreationState> {
  final Ref _ref;
  final JournalRepository _repository;
  static final _uuid = const Uuid();

  JournalEntryCreationNotifier(this._ref, this._repository)
      : super(const JournalEntryCreationState());

  /// Update the title
  void updateTitle(String title) {
    state = state.copyWith(title: title, error: null);
  }

  /// Update the content
  void updateContent(String content) {
    state = state.copyWith(content: content, error: null);
  }

  /// Update the entry date
  void updateEntryDate(DateTime date) {
    state = state.copyWith(entryDate: date, error: null);
  }

  /// Update the trip ID
  void updateTripId(String? tripId) {
    state = state.copyWith(tripId: tripId, error: null);
  }

  /// Update the mood
  void updateMood(String? mood) {
    state = state.copyWith(mood: mood, error: null);
  }

  /// Update the location
  void updateLocation({
    String? locationName,
    double? latitude,
    double? longitude,
  }) {
    state = state.copyWith(
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      error: null,
    );
  }

  /// Toggle favorite status
  void toggleFavorite() {
    state = state.copyWith(isFavorite: !state.isFavorite, error: null);
  }

  /// Clear all fields
  void clear() {
    state = const JournalEntryCreationState();
  }

  /// Clear error
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// Create a journal entry entity from the current state
  JournalEntry createEntry() {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      throw StateError('User must be authenticated to create entries');
    }

    final now = DateTime.now();

    return JournalEntry(
      id: _uuid.v4(),
      userId: user.id,
      tripId: state.tripId,
      title: state.title.trim(),
      content: state.content,
      mood: state.mood,
      locationName: state.locationName,
      latitude: state.latitude,
      longitude: state.longitude,
      entryDate: state.entryDate,
      isFavorite: state.isFavorite,
      syncStatus: SyncStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Save the journal entry
  Future<bool> saveEntry() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Please enter a title and content');
      return false;
    }

    state = state.copyWith(isSaving: true, error: null);

    try {
      // Create the entry
      final entry = createEntry();

      // Save via repository
      await _repository.createEntry(entry);

      // Success
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to save entry: ${e.toString()}',
      );
      return false;
    }
  }

  /// Load an existing entry for editing
  void loadEntry(JournalEntry entry) {
    state = JournalEntryCreationState(
      title: entry.title,
      content: entry.content,
      entryDate: entry.entryDate,
      tripId: entry.tripId,
      mood: entry.mood,
      locationName: entry.locationName,
      latitude: entry.latitude,
      longitude: entry.longitude,
      isFavorite: entry.isFavorite,
    );
  }
}

/// Provider for journal entry creation
final journalEntryCreationProvider =
    StateNotifierProvider<JournalEntryCreationNotifier, JournalEntryCreationState>(
  (ref) {
    final repository = ref.watch(journalRepositoryProvider);
    return JournalEntryCreationNotifier(ref, repository);
  },
);

/// Provider for Journal Repository
/// This should be overridden in the DI layer to provide the actual implementation
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  throw UnimplementedError(
    'JournalRepository must be overridden in the DI layer',
  );
});

/// Provider for form validation state
final journalEntryFormValidatorProvider = Provider<bool>((ref) {
  return ref.watch(journalEntryCreationProvider).isValid;
});

/// Provider for save button state
final journalEntrySaveButtonProvider = Provider<{
  bool enabled;
  bool isLoading;
}>((ref) {
  final creationState = ref.watch(journalEntryCreationProvider);
  return (
    enabled: creationState.isValid && !creationState.isSaving,
    isLoading: creationState.isSaving,
  );
});
