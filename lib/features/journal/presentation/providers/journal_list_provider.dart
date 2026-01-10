import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';

part 'journal_list_provider.g.dart';

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
// Journal List Notifier (Riverpod 3.0)
// ============================================================================

/// Notifier for managing journal list state
/// MIGRATION: StateNotifier → Notifier pattern
/// - Constructor logic moved to build() method
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
@riverpod
class JournalList extends _$JournalList {
  /// Date formatter for grouping entries by date
  DateFormat get _dateFormatter => DateFormat('MMMM yyyy');

  @override
  JournalListState build() {
    // Initial load happens automatically when provider is first accessed
    // Note: We don't call loadEntries() here to avoid issues during build
    return const JournalListState();
  }

  /// Loads all journal entries for the current user
  Future<void> loadEntries() async {
    final repository = ref.watch(journalRepositoryProvider);
    state = state.copyWith(isLoading: true, error: null);

    try {
      final entries = await repository.getEntries();

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
// Computed Providers (derived from JournalList)
// ============================================================================

/// Provider for entries grouped by trip
/// Computed from the main journalListProvider state
@riverpod
Map<String?, List<JournalEntry>> journalEntriesByTrip(Ref ref) {
  final listState = ref.watch(journalListProvider);
  return listState.entriesByTrip;
}

/// Provider for entries grouped by date
/// Computed from the main journalListProvider state
@riverpod
Map<String, List<JournalEntry>> journalEntriesByDate(Ref ref) {
  final listState = ref.watch(journalListProvider);
  return listState.entriesByDate;
}
