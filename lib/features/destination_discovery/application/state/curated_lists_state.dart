import '../../domain/models/curated_list.dart';

/// State class for curated destination lists
class CuratedListsState {
  /// List of all curated lists
  final List<CuratedList> curatedLists;

  /// Currently selected/detailed curated list
  final CuratedList? selectedList;

  /// Whether this is the initial state (no data loaded yet)
  final bool isInitial;

  /// Creates an initial curated lists state
  const CuratedListsState.initial()
      : curatedLists = const [],
        selectedList = null,
        isInitial = true;

  /// Creates a curated lists state with the given fields
  const CuratedListsState({
    required this.curatedLists,
    this.selectedList,
    this.isInitial = false,
  });

  /// Creates a copy of this state with the given fields replaced
  CuratedListsState copyWith({
    List<CuratedList>? curatedLists,
    CuratedList? selectedList,
    bool? isInitial,
  }) {
    return CuratedListsState(
      curatedLists: curatedLists ?? this.curatedLists,
      selectedList: selectedList ?? this.selectedList,
      isInitial: isInitial ?? this.isInitial,
    );
  }

  /// Returns true if no curated lists have been loaded
  bool get isEmpty => curatedLists.isEmpty && !isInitial;

  /// Returns true if curated lists have been loaded
  bool get hasCuratedLists => curatedLists.isNotEmpty;

  /// Returns the number of curated lists
  int get curatedListCount => curatedLists.length;

  /// Returns true if a selected list is available
  bool get hasSelectedList => selectedList != null;

  /// Returns featured curated lists
  List<CuratedList> get featuredLists =>
      curatedLists.where((list) => list.isFeatured).toList();

  /// Returns popular curated lists (featured or high engagement)
  List<CuratedList> get popularLists =>
      curatedLists.where((list) => list.isPopular).toList();

  /// Returns curated lists by type
  List<CuratedList> getListsByType(CuratedListType type) =>
      curatedLists.where((list) => list.type == type).toList();

  /// Returns hidden gems lists
  List<CuratedList> get hiddenGemsLists =>
      getListsByType(CuratedListType.hiddenGems);

  /// Returns budget-friendly lists
  List<CuratedList> get budgetFriendlyLists =>
      getListsByType(CuratedListType.budgetFriendly);

  /// Returns popular solo destination lists
  List<CuratedList> get popularSoloLists =>
      getListsByType(CuratedListType.popularSolo);
}
