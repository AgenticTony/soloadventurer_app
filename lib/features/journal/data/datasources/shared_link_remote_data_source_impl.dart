import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/journal/data/datasources/shared_link_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/shared_link_model.dart';

/// Implementation of [SharedLinkRemoteDataSource] using Supabase
class SharedLinkRemoteDataSourceImpl implements SharedLinkRemoteDataSource {
  final SupabaseClient _client;

  SharedLinkRemoteDataSourceImpl({required SupabaseClient client})
      : _client = client;

  @override
  Future<SharedLinkModel> createSharedLink({
    required String tripId,
    required String userId,
    String? password,
    DateTime? expiresAt,
  }) async {
    try {
      // Use the database function to create the link
      final response = await _client.rpc('create_shared_link', params: {
        'p_trip_id': tripId,
        'p_user_id': userId,
        'p_password': password,
        'p_expires_at': expiresAt?.toIso8601String(),
      });

      final linkId = response as String;
      return await getSharedLink(linkId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to create shared link: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create shared link: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<SharedLinkModel> getSharedLink(String linkId) async {
    try {
      final response =
          await _client.from('shared_links').select().eq('id', linkId).single();

      return _parseSharedLinkFromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '404' || e.code == 'PGRST116') {
        throw const ServerException(
          message: 'Shared link not found',
          statusCode: 404,
        );
      }
      throw ServerException(
        message: 'Failed to get shared link: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get shared link: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<SharedLinkModel> getSharedLinkBySlug(String slug) async {
    try {
      final response =
          await _client.from('shared_links').select().eq('slug', slug).single();

      return _parseSharedLinkFromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '404' || e.code == 'PGRST116') {
        throw const ServerException(
          message: 'Shared link not found',
          statusCode: 404,
        );
      }
      throw ServerException(
        message: 'Failed to get shared link by slug: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get shared link by slug: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<SharedLinkModel>> getSharedLinksForTrip(String tripId) async {
    try {
      final response = await _client
          .from('shared_links')
          .select()
          .eq('trip_id', tripId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _parseSharedLinkFromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get shared links for trip: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get shared links for trip: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<SharedLinkModel>> getUserSharedLinks(String userId) async {
    try {
      final response = await _client
          .from('shared_links')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _parseSharedLinkFromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get user shared links: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get user shared links: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<SharedLinkModel> updateSharedLink({
    required String linkId,
    String? password,
    DateTime? expiresAt,
    bool? isActive,
  }) async {
    try {
      // Build update data
      final Map<String, dynamic> updateData = {};

      if (isActive != null) {
        updateData['is_active'] = isActive;
      }

      if (expiresAt != null) {
        updateData['expires_at'] = expiresAt.toIso8601String();
      } else if (expiresAt == null && password == null) {
        // If explicitly setting expiresAt to null, remove expiration
        updateData['expires_at'] = null;
      }

      // Note: Password updates should be handled via a separate secure function
      // For now, we'll include password_hash updates if needed
      if (password != null) {
        // Use hash_password function
        final hashResult = await _client.rpc('hash_password', params: {
          'password': password,
        });
        updateData['password_hash'] = hashResult as String;
      } else if (password == null && password != null) {
        // Explicitly removing password
        updateData['password_hash'] = null;
      }

      final response = await _client
          .from('shared_links')
          .update(updateData)
          .eq('id', linkId)
          .select()
          .single();

      return _parseSharedLinkFromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to update shared link: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update shared link: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deactivateSharedLink(String linkId) async {
    try {
      await _client
          .from('shared_links')
          .update({'is_active': false}).eq('id', linkId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to deactivate shared link: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to deactivate shared link: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteSharedLink(String linkId) async {
    try {
      await _client.from('shared_links').delete().eq('id', linkId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to delete shared link: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete shared link: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> validateAccess({
    required String slug,
    String? password,
  }) async {
    try {
      final response =
          await _client.rpc('validate_shared_link_access', params: {
        'link_slug': slug,
        'password': password,
      });

      // Parse the table result
      if (response is List && response.isNotEmpty) {
        final row = response[0] as Map<String, dynamic>;
        return {
          'trip_id': row['trip_id']?.toString(),
          'is_valid': row['is_valid'] as bool? ?? false,
          'requires_password': row['requires_password'] as bool? ?? false,
          'is_expired': row['is_expired'] as bool? ?? false,
          'error_message': row['error_message'] as String?,
        };
      }

      throw const ServerException(
        message: 'Invalid response from validation function',
        statusCode: 500,
      );
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to validate shared link access: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to validate shared link access: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> recordView(String slug) async {
    try {
      await _client.rpc('increment_link_view_count', params: {
        'link_slug': slug,
      });
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to record view: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to record view: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<bool> isSlugAvailable(String slug) async {
    try {
      final response = await _client
          .from('shared_links')
          .select('id')
          .eq('slug', slug)
          .maybeSingle();

      return response == null;
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to check slug availability: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to check slug availability: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<String> generateUniqueSlug() async {
    try {
      final response = await _client.rpc('generate_unique_slug');
      return response as String;
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to generate unique slug: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to generate unique slug: $e',
        statusCode: 500,
      );
    }
  }

  /// Parse shared link from JSON response
  SharedLinkModel _parseSharedLinkFromJson(Map<String, dynamic> json) {
    return SharedLinkModel(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      userId: json['user_id'] as String,
      slug: json['slug'] as String,
      hasPassword: json['password_hash'] != null,
      isActive: json['is_active'] as bool? ?? true,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      viewCount: json['view_count'] as int? ?? 0,
      lastViewedAt: json['last_viewed_at'] != null
          ? DateTime.parse(json['last_viewed_at'] as String)
          : null,
      syncStatus: json['sync_status'] as String? ?? 'synced',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
