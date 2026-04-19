import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/curated_list.dart';
import '../state/curated_lists_state.dart';
import 'destination_repository_provider.dart';

part 'curated_lists_provider.g.dart';

/// Riverpod 3.0 Migration Notes:
/// - Converted from `StateNotifier<AsyncValue<T>>` to `AsyncNotifier<T>`
/// - Dependencies injected via `ref.watch()` in `build()` method
/// - `build()` returns `Future<T>` not `AsyncValue<T>`
/// - State is automatically `AsyncValue<CuratedListsState>` when consumed
/// - Constructor auto-load logic moved to `build()` method
///
/// Provider for curated destination lists state management
///
/// This provider manages the state of curated destination collections including:
/// - All curated lists
/// - Selected/detailed curated list
/// - Loading and error states
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
///
/// Usage:
/// ```dart
/// final curatedListsState = ref.watch(curatedListsProvider);
/// final curatedListsNotifier = ref.watch(curatedListsProvider.notifier);
///
/// // Load all curated lists (automatically called on first watch)
/// // Lists are auto-loaded when the provider is first watched
///
/// // Load a specific curated list
/// await curatedListsNotifier.loadCuratedList(listId);
///
/// // Refresh all curated lists
/// await curatedListsNotifier.refresh();
///
/// // Clear all curated lists
/// curatedListsNotifier.clear();
///
/// // Get curated lists by type
/// final hiddenGems = curatedListsNotifier.hiddenGemsLists;
/// ```
@riverpod
class CuratedLists extends _$CuratedLists {
  /// Initialize the notifier and auto-load curated lists
  ///
  /// Riverpod 3.0: `build()` returns `Future<CuratedListsState>`
  /// `AsyncValue` wrapping is handled automatically by the framework
  @override
  Future<CuratedListsState> build() async {
    // Get dependencies via ref.watch()
    final repository = ref.watch(destinationRepositoryProvider);

    // Auto-load curated lists on build
    final curatedLists = await repository.getCuratedLists();

    return CuratedListsState(
      curatedLists: curatedLists,
    );
  }

  /// Load a specific curated list by ID
  ///
  /// The [listId] parameter is the unique identifier of the curated list to load.
  /// This method fetches the detailed curated list including all destinations.
  ///
  /// Throws an exception if loading fails.
  Future<void> loadCuratedList(String listId) async {
    // Get repository
    final repository = ref.read(destinationRepositoryProvider);

    // Guard against loading if not in success state
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    // Set loading state while keeping current data
    state = const AsyncValue.loading();

    // Load curated list
    state = await AsyncValue.guard(() async {
      final curatedList = await repository.getCuratedListById(listId);

      // Update the list in the curated lists array if it exists
      final updatedLists = currentState.curatedLists.map((list) {
        return list.id == listId ? curatedList : list;
      }).toList();

      // If the list wasn't in the array, add it
      if (!updatedLists.any((list) => list.id == listId)) {
        updatedLists.add(curatedList);
      }

      return currentState.copyWith(
        curatedLists: updatedLists,
        selectedList: curatedList,
      );
    });
  }

  /// Refresh all curated lists
  ///
  /// This method reloads all curated lists from the repository.
  /// Useful for pull-to-refresh functionality or ensuring fresh data.
  ///
  /// Throws an exception if refreshing fails.
  Future<void> refresh() async {
    // Get repository
    final repository = ref.read(destinationRepositoryProvider);

    // Preserve selected list while loading if available
    CuratedList? selectedList;
    if (state.hasValue && state.value!.selectedList != null) {
      selectedList = state.value!.selectedList;
    }

    // Set loading state
    state = const AsyncValue.loading();

    // Load curated lists
    state = await AsyncValue.guard(() async {
      final curatedLists = await repository.getCuratedLists();

      return CuratedListsState(
        curatedLists: curatedLists,
        selectedList: selectedList,
      );
    });
  }

  /// Refresh the selected curated list
  ///
  /// This method reloads the currently selected curated list from the repository.
  /// Returns false if no list is currently selected.
  ///
  /// Throws an exception if refreshing fails.
  Future<bool> refreshSelectedList() async {
    // Get repository
    final repository = ref.read(destinationRepositoryProvider);

    if (!state.hasValue || state.value!.selectedList == null) {
      return false;
    }

    final listId = state.value!.selectedList!.id;

    // Set loading state
    state = await AsyncValue.guard(() async {
      final curatedList = await repository.getCuratedListById(listId);

      // Update the list in the curated lists array
      final currentState = state.value!;
      final updatedLists = currentState.curatedLists.map((list) {
        return list.id == listId ? curatedList : list;
      }).toList();

      return currentState.copyWith(
        curatedLists: updatedLists,
        selectedList: curatedList,
      );
    });

    return true;
  }

  /// Clear the curated lists state
  ///
  /// This method resets the state to initial, clearing all data.
  /// This is useful for cleanup or when the user logs out.
  void clear() {
    state = const AsyncValue.data(CuratedListsState.initial());
  }

  /// Clear the selected curated list
  ///
  /// This method clears the currently selected list while keeping
  /// all curated lists loaded. Useful when navigating away from list detail.
  void clearSelectedList() {
    if (!state.hasValue) {
      return;
    }

    final currentState = state.value!;
    state = AsyncValue.data(currentState.copyWith(
      selectedList: null,
    ));
  }

  /// Get featured curated lists
  ///
  /// Returns a list of curated lists marked as featured.
  /// Returns an empty list if no lists are loaded or if loading failed.
  List<CuratedList> get featuredLists {
    if (!state.hasValue) {
      return const [];
    }

    return state.value!.featuredLists;
  }

  /// Get popular curated lists
  ///
  /// Returns a list of curated lists marked as popular or featured.
  /// Returns an empty list if no lists are loaded or if loading failed.
  List<CuratedList> get popularLists {
    if (!state.hasValue) {
      return const [];
    }

    return state.value!.popularLists;
  }

  /// Get curated lists by type
  ///
  /// The [type] parameter specifies the type of curated lists to filter.
  /// Returns a list of curated lists matching the specified type.
  /// Returns an empty list if no lists are loaded or if loading failed.
  List<CuratedList> getListsByType(CuratedListType type) {
    if (!state.hasValue) {
      return const [];
    }

    return state.value!.getListsByType(type);
  }

  /// Get hidden gems curated lists
  ///
  /// Returns a list of curated lists marked as hidden gems.
  /// Returns an empty list if no lists are loaded or if loading failed.
  List<CuratedList> get hiddenGemsLists {
    if (!state.hasValue) {
      return const [];
    }

    return state.value!.hiddenGemsLists;
  }

  /// Get budget-friendly curated lists
  ///
  /// Returns a list of curated lists marked as budget-friendly.
  /// Returns an empty list if no lists are loaded or if loading failed.
  List<CuratedList> get budgetFriendlyLists {
    if (!state.hasValue) {
      return const [];
    }

    return state.value!.budgetFriendlyLists;
  }

  /// Get popular solo destination curated lists
  ///
  /// Returns a list of curated lists marked as popular solo destinations.
  /// Returns an empty list if no lists are loaded or if loading failed.
  List<CuratedList> get popularSoloLists {
    if (!state.hasValue) {
      return const [];
    }

    return state.value!.popularSoloLists;
  }

  /// Get the total count of curated lists
  ///
  /// Returns the total number of curated lists loaded.
  /// Returns 0 if no lists are loaded.
  int get totalCount {
    if (!state.hasValue) {
      return 0;
    }

    return state.value!.curatedListCount;
  }

  /// Check if there are curated lists loaded
  ///
  /// Returns true if curated lists have been loaded successfully.
  /// Returns false otherwise.
  bool get hasCuratedLists {
    if (!state.hasValue) {
      return false;
    }

    return state.value!.hasCuratedLists;
  }

  /// Check if a curated list is selected
  ///
  /// Returns true if a curated list is currently selected.
  /// Returns false otherwise.
  bool get hasSelectedList {
    if (!state.hasValue) {
      return false;
    }

    return state.value!.hasSelectedList;
  }

  /// Get the selected curated list
  ///
  /// Returns the currently selected curated list, or null if none is selected.
  CuratedList? get selectedList {
    if (!state.hasValue) {
      return null;
    }

    return state.value!.selectedList;
  }
}
