import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/repositories/journal_repository.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';

// ============================================================================
// Organization Mode
// ============================================================================

/// Defines how journal entries are organized in the list
enum JournalListOrganization {
  /// Organize entries by trip
  byTrip,

  /// Organize entries by date
  byDate,
}

// ============================================================================
// Journal List State
// ============================================================================

/// State for journal list operations
class JournalListState {
  /// All journal entries
  final List<JournalEntry> entries;

  /// Whether data is currently loading
  final bool isLoading;

  /// Error message if any
  final String? error;

  /// Current organization mode
  final JournalListOrganization organizationMode;

  /// Entries organized by trip (tripId -> entries)
  final Map<String?, List<JournalEntry>> entriesByTrip;

  /// Entries organized by date (date string -> entries)
  final Map<String, List<JournalEntry>> entriesByDate;

  const JournalListState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
    this.organizationMode = JournalListOrganization.byDate,
    this.entriesByTrip = const {},
    this.entriesByDate = const {},
  });

  JournalListState copyWith({
    List<JournalEntry>? entries,
    bool? isLoading,
    String? error,
    JournalListOrganization? organizationMode,
    Map<String?, List<JournalEntry>>? entriesByTrip,
    Map<String, List<JournalEntry>>? entriesByDate,
  }) {
    return JournalListState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      organizationMode: organizationMode ?? this.organizationMode,
      entriesByTrip: entriesByTrip ?? this.entriesByTrip,
      entriesByDate: entriesByDate ?? this.entriesByDate,
    );
  }

  /// Whether there are any entries to display
  bool get hasEntries => entries.isNotEmpty;

  /// Get the number of groups (trips or dates)
  int get groupCount {
    return organizationMode == JournalListOrganization.byTrip
        ? entriesByTrip.length
        : entriesByDate.length;
  }
}

// ============================================================================
// Journal List Notifier
// ============================================================================

/// Notifier for managing journal list state
class JournalListNotifier extends StateNotifier<JournalListState> {
  final JournalRepository _repository;

  /// Date formatter for grouping entries by date
  final DateFormat _dateFormatter = DateFormat('MMMM yyyy');

  JournalListNotifier(this._repository) : super(const JournalListState()) {
    loadEntries();
  }

  /// Loads all journal entries for the current user
  Future<void> loadEntries() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final entries = await _repository.getEntries();

      // Sort entries by date (newest first)
      entries.sort((a, b) => b.entryDate.compareTo(a.entryDate));

      // Organize entries by trip
      final entriesByTrip = _organizeByTrip(entries);

      // Organize entries by date
      final entriesByDate = _organizeByDate(entries);

      state = state.copyWith(
        entries: entries,
        entriesByTrip: entriesByTrip,
        entriesByDate: entriesByDate,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Organizes entries by trip
  Map<String?, List<JournalEntry>> _organizeByTrip(List<JournalEntry> entries) {
    final Map<String?, List<JournalEntry>> grouped = {};

    for (final entry in entries) {
      final tripId = entry.tripId;

      if (!grouped.containsKey(tripId)) {
        grouped[tripId] = [];
      }

      grouped[tripId]!.add(entry);
    }

    // Sort each trip's entries by date (newest first)
    for (final tripId in grouped.keys) {
      grouped[tripId]!.sort((a, b) => b.entryDate.compareTo(a.entryDate));
    }

    return grouped;
  }

  /// Organizes entries by date
  Map<String, List<JournalEntry>> _organizeByDate(List<JournalEntry> entries) {
    final Map<String, List<JournalEntry>> grouped = {};

    for (final entry in entries) {
      // Group by month and year (e.g., "January 2025")
      final dateKey = _dateFormatter.format(entry.entryDate);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }

      grouped[dateKey]!.add(entry);
    }

    // Sort each date group's entries by date (newest first)
    for (final dateKey in grouped.keys) {
      grouped[dateKey]!.sort((a, b) => b.entryDate.compareTo(a.entryDate));
    }

    return grouped;
  }

  /// Toggle organization mode between byTrip and byDate
  void toggleOrganizationMode() {
    final newMode = state.organizationMode == JournalListOrganization.byTrip
        ? JournalListOrganization.byDate
        : JournalListOrganization.byTrip;

    state = state.copyWith(organizationMode: newMode);
  }

  /// Set organization mode
  void setOrganizationMode(JournalListOrganization mode) {
    state = state.copyWith(organizationMode: mode);
  }

  /// Refreshes the journal list
  Future<void> refresh() async {
    await loadEntries();
  }

  /// Clears any error state
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

// ============================================================================
// Providers
// ============================================================================

/// Provider for journal list state
final journalListProvider =
    StateNotifierProvider<JournalListNotifier, JournalListState>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return JournalListNotifier(repository);
});

/// Provider for entries grouped by trip
final journalEntriesByTripProvider = Provider<Map<String?, List<JournalEntry>>>(
  (ref) {
    final listState = ref.watch(journalListProvider);
    return listState.entriesByTrip;
  },
);

/// Provider for entries grouped by date
final journalEntriesByDateProvider = Provider<Map<String, List<JournalEntry>>>(
  (ref) {
    final listState = ref.watch(journalListProvider);
    return listState.entriesByDate;
  },
);
