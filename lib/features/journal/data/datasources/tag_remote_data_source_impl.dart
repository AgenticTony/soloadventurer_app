import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/error/exceptions.dart';
import 'package:soloadventurer/features/journal/data/datasources/tag_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/tag_model.dart';

/// Supabase implementation of [TagRemoteDataSource]
class TagRemoteDataSourceImpl implements TagRemoteDataSource {
  final SupabaseClient _client;

  TagRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  String get _userId => _client.auth.currentUser?.id ?? '';

  @override
  Future<TagModel> createTag(TagModel tag) async {
    try {
      final response = await _client
          .from('tags')
          .insert({
            'user_id': _userId,
            'name': tag.name,
            'color': tag.color,
            'icon': tag.icon,
          })
          .select()
          .single();

      return TagModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique constraint violation (user_id, name)
        throw ServerException(
          message: 'A tag with this name already exists',
          code: 'duplicate_tag',
        );
      }
      throw ServerException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create tag: ${e.toString()}',
        code: 'create_tag_failed',
      );
    }
  }

  @override
  Future<TagModel> getTag(String tagId) async {
    try {
      final response = await _client
          .from('tags')
          .select()
          .eq('id', tagId)
          .eq('user_id', _userId)
          .single();

      return TagModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw ServerException(
          message: 'Tag not found',
          code: 'tag_not_found',
        );
      }
      throw ServerException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tag: ${e.toString()}',
        code: 'get_tag_failed',
      );
    }
  }

  @override
  Future<List<TagModel>> getTags() async {
    try {
      final response = await _client
          .from('tags')
          .select()
          .eq('user_id', _userId)
          .order('name', ascending: true);

      return (response as List).map((json) => TagModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tags: ${e.toString()}',
        code: 'get_tags_failed',
      );
    }
  }

  @override
  Future<List<TagModel>> getTagsForEntry(String entryId) async {
    try {
      final response = await _client
          .from('tags')
          .select('*, journal_tags!inner(journal_entry_id)')
          .eq('user_id', _userId)
          .eq('journal_tags.journal_entry_id', entryId)
          .order('name', ascending: true);

      // Extract tag data from the nested response
      final tags = <TagModel>[];
      for (final item in response as List) {
        // Remove the journal_tags field before parsing
        final tagData = Map<String, dynamic>.from(item);
        tagData.remove('journal_tags');
        tags.add(TagModel.fromJson(tagData));
      }

      return tags;
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tags for entry: ${e.toString()}',
        code: 'get_entry_tags_failed',
      );
    }
  }

  @override
  Future<TagModel> updateTag(TagModel tag) async {
    try {
      final response = await _client
          .from('tags')
          .update({
            'name': tag.name,
            'color': tag.color,
            'icon': tag.icon,
          })
          .eq('id', tag.id)
          .eq('user_id', _userId)
          .select()
          .single();

      return TagModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw ServerException(
          message: 'A tag with this name already exists',
          code: 'duplicate_tag',
        );
      }
      throw ServerException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update tag: ${e.toString()}',
        code: 'update_tag_failed',
      );
    }
  }

  @override
  Future<void> deleteTag(String tagId) async {
    try {
      await _client
          .from('tags')
          .delete()
          .eq('id', tagId)
          .eq('user_id', _userId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete tag: ${e.toString()}',
        code: 'delete_tag_failed',
      );
    }
  }

  @override
  Future<void> addTagToEntry(String entryId, String tagId) async {
    try {
      await _client.from('journal_tags').insert({
        'journal_entry_id': entryId,
        'tag_id': tagId,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique constraint violation - tag already added
        throw ServerException(
          message: 'Tag is already added to this entry',
          code: 'tag_already_added',
        );
      }
      throw ServerException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to add tag to entry: ${e.toString()}',
        code: 'add_tag_failed',
      );
    }
  }

  @override
  Future<void> removeTagFromEntry(String entryId, String tagId) async {
    try {
      await _client
          .from('journal_tags')
          .delete()
          .eq('journal_entry_id', entryId)
          .eq('tag_id', tagId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to remove tag from entry: ${e.toString()}',
        code: 'remove_tag_failed',
      );
    }
  }

  @override
  Future<void> updateTagsForEntry(String entryId, List<String> tagIds) async {
    try {
      // Delete all existing tags for the entry
      await _client
          .from('journal_tags')
          .delete()
          .eq('journal_entry_id', entryId);

      // Add new tags
      if (tagIds.isNotEmpty) {
        final inserts = tagIds.map((tagId) => {
          'journal_entry_id': entryId,
          'tag_id': tagId,
        }).toList();

        await _client.from('journal_tags').insert(inserts);
      }
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update tags for entry: ${e.toString()}',
        code: 'update_tags_failed',
      );
    }
  }

  @override
  Future<List<TagModel>> getPopularTags({int limit = 20}) async {
    try {
      final response = await _client
          .from('tags')
          .select()
          .eq('user_id', _userId)
          .order('usage_count', ascending: false)
          .limit(limit);

      return (response as List).map((json) => TagModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get popular tags: ${e.toString()}',
        code: 'get_popular_tags_failed',
      );
    }
  }

  @override
  Future<List<TagModel>> searchTags(String query) async {
    try {
      final response = await _client
          .from('tags')
          .select()
          .eq('user_id', _userId)
          .ilike('name', '%$query%')
          .order('usage_count', ascending: false)
          .limit(50);

      return (response as List).map((json) => TagModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to search tags: ${e.toString()}',
        code: 'search_tags_failed',
      );
    }
  }
}
