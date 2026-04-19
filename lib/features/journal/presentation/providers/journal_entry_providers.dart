import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart'; // For SyncStatus enum
import 'package:uuid/uuid.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/repositories/journal_repository.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/journal/data/services/location_capture_service.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

// Generated file
part 'journal_entry_providers.g.dart';

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

  /// Location accuracy in meters
  final double? locationAccuracy;

  /// Whether the entry is marked as favorite
  final bool isFavorite;

  /// ID of an existing entry being edited (null for new entries)
  final String? existingEntryId;

  /// Whether a save operation is in progress
  final bool isSaving;

  /// Whether location is being captured
  final bool isCapturingLocation;

  /// Error message if any
  final String? error;

  /// Whether the form is valid
  bool get isValid => title.trim().isNotEmpty && content.trim().isNotEmpty;

  const JournalEntryCreationState({
    this.title = '',
    this.content = '',
    required this.entryDate,
    this.tripId,
    this.mood,
    this.locationName,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    this.isFavorite = false,
    this.existingEntryId,
    this.isSaving = false,
    this.isCapturingLocation = false,
    this.error,
  });

  /// Whether this is an edit of an existing entry
  bool get isEditing => existingEntryId != null;

  JournalEntryCreationState copyWith({
    String? title,
    String? content,
    DateTime? entryDate,
    String? tripId,
    String? mood,
    String? locationName,
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    bool? isFavorite,
    String? existingEntryId,
    bool? isSaving,
    bool? isCapturingLocation,
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
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      isFavorite: isFavorite ?? this.isFavorite,
      existingEntryId: existingEntryId ?? this.existingEntryId,
      isSaving: isSaving ?? this.isSaving,
      isCapturingLocation: isCapturingLocation ?? this.isCapturingLocation,
      error: error,
    );
  }
}

/// Notifier for managing journal entry creation state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
@riverpod
class JournalEntryCreation extends _$JournalEntryCreation {
  final LocationCaptureService _locationService = LocationCaptureService.instance;
  static const _uuid = Uuid();

  @override
  JournalEntryCreationState build() {
    // Dependencies are accessed via ref.watch in build method
    // No constructor parameters needed - they're accessed via ref
    return JournalEntryCreationState(entryDate: DateTime.now());
  }

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
    double? locationAccuracy,
  }) {
    state = state.copyWith(
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      locationAccuracy: locationAccuracy,
      error: null,
    );
  }

  /// Capture current device location
  Future<void> captureCurrentLocation() async {
    state = state.copyWith(isCapturingLocation: true, error: null);

    try {
      // Ensure location service is enabled and permissions granted
      await _locationService.ensureLocationEnabled();

      // Capture location with travel journal config
      final location = await _locationService.getCurrentLocation(
        LocationCaptureConfig.forTravelJournal,
      );

      // Check if accuracy is acceptable
      if (!location.hasAcceptableAccuracy()) {
        state = state.copyWith(
          isCapturingLocation: false,
          error:
              'Location accuracy is poor. Please try again or move to an open area.',
        );
        return;
      }

      // Update state with captured location
      state = state.copyWith(
        latitude: location.latitude,
        longitude: location.longitude,
        locationAccuracy: location.accuracy,
        locationName: location.locationName,
        isCapturingLocation: false,
      );
    } on LocationException catch (e) {
      state = state.copyWith(
        isCapturingLocation: false,
        error: 'Location capture failed: ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(
        isCapturingLocation: false,
        error: 'Failed to capture location: ${e.toString()}',
      );
    }
  }

  /// Clear location data
  void clearLocation() {
    state = state.copyWith(
      locationName: null,
      latitude: null,
      longitude: null,
      locationAccuracy: null,
      error: null,
    );
  }

  /// Toggle favorite status
  void toggleFavorite() {
    state = state.copyWith(isFavorite: !state.isFavorite, error: null);
  }

  /// Clear all fields
  void clear() {
    state = JournalEntryCreationState(entryDate: DateTime.now());
  }

  /// Clear error
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// Create a journal entry entity from the current state
  JournalEntry createEntry() {
    // Access the current user from auth state
    final authState = ref.read(authProvider);
    final User? user;

    if (authState is AsyncData<AuthState>) {
      user = authState.value.user;
    } else {
      throw StateError('User must be authenticated to create entries');
    }

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
      locationAccuracy: state.locationAccuracy,
      entryDate: state.entryDate,
      isFavorite: state.isFavorite,
      syncStatus: SyncStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Save the journal entry (create or update)
  Future<bool> saveEntry() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Please enter a title and content');
      return false;
    }

    state = state.copyWith(isSaving: true, error: null);

    try {
      final repository = ref.read(journalRepositoryProvider);

      if (state.isEditing) {
        // Update existing entry
        final entry = createEntry().copyWith(id: state.existingEntryId!);
        await repository.updateEntry(entry);
      } else {
        // Create new entry
        final entry = createEntry();
        await repository.createEntry(entry);
      }

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
      existingEntryId: entry.id,
      title: entry.title,
      content: entry.content,
      entryDate: entry.entryDate,
      tripId: entry.tripId,
      mood: entry.mood,
      locationName: entry.locationName,
      latitude: entry.latitude,
      longitude: entry.longitude,
      locationAccuracy: entry.locationAccuracy,
      isFavorite: entry.isFavorite,
    );
  }
}

/// Provider for Journal Repository
/// This should be overridden in the DI layer to provide the actual implementation
@riverpod
JournalRepository journalRepository(Ref ref) {
  throw UnimplementedError(
    'JournalRepository must be overridden in the DI layer',
  );
}

/// Class for save button state
class SaveButtonState {
  final bool enabled;
  final bool isLoading;

  const SaveButtonState({
    required this.enabled,
    required this.isLoading,
  });
}

/// Provider for save button state
@riverpod
SaveButtonState journalEntrySaveButton(Ref ref) {
  final creationState = ref.watch(journalEntryCreationProvider);
  return SaveButtonState(
    enabled: creationState.isValid && !creationState.isSaving,
    isLoading: creationState.isSaving,
  );
}
