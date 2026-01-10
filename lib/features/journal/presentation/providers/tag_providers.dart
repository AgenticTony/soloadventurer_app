import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/features/journal/data/datasources/tag_remote_data_source_impl.dart';
import 'package:soloadventurer/features/journal/data/repositories/tag_repository_impl.dart';
import 'package:soloadventurer/features/journal/domain/entities/tag.dart';
import 'package:soloadventurer/features/journal/domain/repositories/tag_repository.dart';

// Generated file
part 'tag_providers.g.dart';

// ============================================================================
// Dependency Injection Providers
// ============================================================================

/// Provider for Supabase client
@riverpod
SupabaseClient tagSupabaseClient(Ref ref) {
  return Supabase.instance.client;
}

/// Provides the TagRemoteDataSource implementation
@riverpod
TagRemoteDataSourceImpl tagRemoteDataSource(Ref ref) {
  final client = ref.watch(tagSupabaseClientProvider);
  return TagRemoteDataSourceImpl(client: client);
}

/// Provides the TagRepository implementation
@riverpod
TagRepository tagRepository(Ref ref) {
  final remoteDataSource = ref.watch(tagRemoteDataSourceProvider);
  return TagRepositoryImpl(remoteDataSource: remoteDataSource);
}

// ============================================================================
// Tag List State
// ============================================================================

/// State for tag list operations
class TagListState {
  final List<Tag> tags;
  final bool isLoading;
  final String? error;

  const TagListState({
    this.tags = const [],
    this.isLoading = false,
    this.error,
  });

  TagListState copyWith({
    List<Tag>? tags,
    bool? isLoading,
    String? error,
  }) {
    return TagListState(
      tags: tags ?? this.tags,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing tag list state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
@riverpod
class TagList extends _$TagList {
  @override
  TagListState build() {
    // Load tags automatically on build
    loadTags();
    return const TagListState();
  }

  /// Loads all tags for the current user
  Future<void> loadTags() async {
    state = state.copyWith(isLoading: true, error: null);

    final repository = ref.read(tagRepositoryProvider);
    final result = await repository.getTags();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (tags) => state = state.copyWith(
        tags: tags,
        isLoading: false,
      ),
    );
  }

  /// Loads popular tags
  Future<void> loadPopularTags({int limit = 20}) async {
    state = state.copyWith(isLoading: true, error: null);

    final repository = ref.read(tagRepositoryProvider);
    final result = await repository.getPopularTags(limit: limit);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (tags) => state = state.copyWith(
        tags: tags,
        isLoading: false,
      ),
    );
  }

  /// Searches tags by name
  Future<void> searchTags(String query) async {
    if (query.isEmpty) {
      await loadTags();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final repository = ref.read(tagRepositoryProvider);
    final result = await repository.searchTags(query);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (tags) => state = state.copyWith(
        tags: tags,
        isLoading: false,
      ),
    );
  }

  /// Clears any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================================================
// Tag Creation/Edit State
// ============================================================================

/// State for tag creation/editing
class TagFormState {
  final String name;
  final String? color;
  final String? icon;
  final bool isLoading;
  final String? error;
  final Tag? tag;

  const TagFormState({
    this.name = '',
    this.color,
    this.icon,
    this.isLoading = false,
    this.error,
    this.tag,
  });

  /// Whether the form is valid
  bool get isValid => name.trim().length >= 2 && name.trim().length <= 50;

  TagFormState copyWith({
    String? name,
    String? color,
    String? icon,
    bool? isLoading,
    String? error,
    Tag? tag,
  }) {
    return TagFormState(
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tag: tag ?? this.tag,
    );
  }
}

/// Notifier for managing tag creation/editing state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
@riverpod
class TagForm extends _$TagForm {
  @override
  TagFormState build() {
    return const TagFormState();
  }

  /// Updates the tag name
  void updateName(String name) {
    state = state.copyWith(name: name, error: null);
  }

  /// Updates the tag color
  void updateColor(String? color) {
    state = state.copyWith(color: color, error: null);
  }

  /// Updates the tag icon
  void updateIcon(String? icon) {
    state = state.copyWith(icon: icon, error: null);
  }

  /// Loads a tag for editing
  Future<void> loadTag(String tagId) async {
    state = state.copyWith(isLoading: true, error: null);

    final repository = ref.read(tagRepositoryProvider);
    final result = await repository.getTag(tagId);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (tag) => state = state.copyWith(
        tag: tag,
        name: tag.name,
        color: tag.color,
        icon: tag.icon,
        isLoading: false,
      ),
    );
  }

  /// Saves the tag (creates new or updates existing)
  Future<bool> saveTag() async {
    if (!state.isValid) {
      state = state.copyWith(
          error: 'Please enter a valid tag name (2-50 characters)');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    final repository = ref.read(tagRepositoryProvider);
    final tag = Tag(
      id: state.tag?.id ?? '',
      userId: '', // Will be set by server
      name: state.name.trim(),
      color: state.color,
      icon: state.icon,
      usageCount: state.tag?.usageCount ?? 0,
      createdAt: state.tag?.createdAt ?? DateTime.now(),
    );

    final result = state.tag?.id == null || state.tag!.id.isEmpty
        ? await repository.createTag(tag)
        : await repository.updateTag(tag);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (savedTag) {
        state = state.copyWith(
          tag: savedTag,
          isLoading: false,
        );
        return true;
      },
    );
  }

  /// Resets the form to initial state
  void reset() {
    state = const TagFormState();
  }

  /// Clears any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================================================
// Entry Tags State
// ============================================================================

/// State for tags on a journal entry
class EntryTagsState {
  final List<Tag> tags;
  final List<String> selectedTagIds;
  final bool isLoading;
  final String? error;

  const EntryTagsState({
    this.tags = const [],
    this.selectedTagIds = const [],
    this.isLoading = false,
    this.error,
  });

  EntryTagsState copyWith({
    List<Tag>? tags,
    List<String>? selectedTagIds,
    bool? isLoading,
    String? error,
  }) {
    return EntryTagsState(
      tags: tags ?? this.tags,
      selectedTagIds: selectedTagIds ?? this.selectedTagIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Gets the selected tag objects
  List<Tag> get selectedTags =>
      tags.where((tag) => selectedTagIds.contains(tag.id)).toList();
}

/// Notifier for managing entry tags
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
@riverpod
class EntryTags extends _$EntryTags {
  @override
  EntryTagsState build() {
    return const EntryTagsState();
  }

  /// Loads all tags for a journal entry
  Future<void> loadEntryTags(String entryId) async {
    state = state.copyWith(isLoading: true, error: null);

    final repository = ref.read(tagRepositoryProvider);

    // Load all available tags
    final allTagsResult = await repository.getTags();
    if (allTagsResult.isLeft()) {
      final failure = allTagsResult.fold((l) => l, (_) => null)!;
      state = state.copyWith(
        isLoading: false,
        error: failure.message,
      );
      return;
    }

    final allTags = allTagsResult.fold((l) => <Tag>[], (r) => r);

    // Load entry's tags
    final entryTagIdsResult = await repository.getTagsForEntry(entryId);
    entryTagIdsResult.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (entryTags) => state = state.copyWith(
        tags: allTags,
        selectedTagIds: entryTags.map((tag) => tag.id).toList(),
        isLoading: false,
      ),
    );
  }

  /// Loads all available tags (for tag picker)
  Future<void> loadAvailableTags() async {
    state = state.copyWith(isLoading: true, error: null);

    final repository = ref.read(tagRepositoryProvider);
    final result = await repository.getTags();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (tags) => state = state.copyWith(
        tags: tags,
        isLoading: false,
      ),
    );
  }

  /// Toggles a tag selection
  void toggleTag(String tagId) {
    final current = List<String>.from(state.selectedTagIds);
    if (current.contains(tagId)) {
      current.remove(tagId);
    } else {
      current.add(tagId);
    }
    state = state.copyWith(selectedTagIds: current);
  }

  /// Adds a tag
  void addTag(String tagId) {
    if (!state.selectedTagIds.contains(tagId)) {
      final current = List<String>.from(state.selectedTagIds);
      current.add(tagId);
      state = state.copyWith(selectedTagIds: current);
    }
  }

  /// Removes a tag
  void removeTag(String tagId) {
    if (state.selectedTagIds.contains(tagId)) {
      final current = List<String>.from(state.selectedTagIds);
      current.remove(tagId);
      state = state.copyWith(selectedTagIds: current);
    }
  }

  /// Saves the selected tags to an entry
  Future<bool> saveEntryTags(String entryId) async {
    state = state.copyWith(isLoading: true, error: null);

    final repository = ref.read(tagRepositoryProvider);
    final result = await repository.updateTagsForEntry(
      entryId,
      state.selectedTagIds,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  /// Clears any error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Resets to initial state
  void reset() {
    state = const EntryTagsState();
  }
}
