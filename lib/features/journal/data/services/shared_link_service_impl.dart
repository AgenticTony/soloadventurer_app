import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/journal/data/datasources/shared_link_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/datasources/shared_link_remote_data_source_impl.dart';
import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';
import 'package:soloadventurer/features/journal/domain/services/shared_link_service.dart';

/// Implementation of [SharedLinkService]
class SharedLinkServiceImpl implements SharedLinkService {
  final SharedLinkRemoteDataSource _remoteDataSource;

  SharedLinkServiceImpl({
    required SupabaseClient client,
  }) : _remoteDataSource = SharedLinkRemoteDataSourceImpl(client: client);

  @override
  Future<void> initialize() async {
    // No initialization needed for Supabase
    // Client is already initialized
  }

  @override
  Future<void> dispose() async {
    // No cleanup needed
  }

  @override
  Future<SharedLink> createSharedLink(CreateSharedLinkConfig config) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        throw const SharedLinkException(
          'User not authenticated',
          code: 'not_authenticated',
        );
      }

      // Validate expiration date
      if (config.expiresAt != null) {
        if (config.expiresAt!.isBefore(DateTime.now())) {
          throw SharedLinkException.invalidExpiration(
            'Expiration date must be in the future',
          );
        }
      }

      final model = await _remoteDataSource.createSharedLink(
        tripId: config.tripId,
        userId: userId,
        password: config.password,
        expiresAt: config.expiresAt,
      );

      return model.toEntity();
    } on ServerException catch (e) {
      throw SharedLinkException(
        'Failed to create shared link: ${e.message}',
        code: 'creation_failed',
      );
    } on SharedLinkException {
      rethrow;
    } catch (e) {
      throw SharedLinkException(
        'Failed to create shared link: $e',
        code: 'unknown_error',
      );
    }
  }

  @override
  Future<SharedLink?> getSharedLink(String linkId) async {
    try {
      final model = await _remoteDataSource.getSharedLink(linkId);
      return model.toEntity();
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      throw SharedLinkException(
        'Failed to get shared link: ${e.message}',
        code: 'fetch_failed',
      );
    } catch (e) {
      throw SharedLinkException(
        'Failed to get shared link: $e',
        code: 'unknown_error',
      );
    }
  }

  @override
  Future<SharedLink?> getSharedLinkBySlug(String slug) async {
    try {
      final model = await _remoteDataSource.getSharedLinkBySlug(slug);
      return model.toEntity();
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      throw SharedLinkException(
        'Failed to get shared link by slug: ${e.message}',
        code: 'fetch_failed',
      );
    } catch (e) {
      throw SharedLinkException(
        'Failed to get shared link by slug: $e',
        code: 'unknown_error',
      );
    }
  }

  @override
  Future<List<SharedLink>> getSharedLinksForTrip(String tripId) async {
    try {
      final models = await _remoteDataSource.getSharedLinksForTrip(tripId);
      return models.map((model) => model.toEntity()).toList();
    } on ServerException catch (e) {
      throw SharedLinkException(
        'Failed to get shared links for trip: ${e.message}',
        code: 'fetch_failed',
      );
    } catch (e) {
      throw SharedLinkException(
        'Failed to get shared links for trip: $e',
        code: 'unknown_error',
      );
    }
  }

  @override
  Future<List<SharedLink>> getUserSharedLinks() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        throw const SharedLinkException(
          'User not authenticated',
          code: 'not_authenticated',
        );
      }

      final models = await _remoteDataSource.getUserSharedLinks(userId);
      return models.map((model) => model.toEntity()).toList();
    } on ServerException catch (e) {
      throw SharedLinkException(
        'Failed to get user shared links: ${e.message}',
        code: 'fetch_failed',
      );
    } catch (e) {
      throw SharedLinkException(
        'Failed to get user shared links: $e',
        code: 'unknown_error',
      );
    }
  }

  @override
  Future<SharedLinkAccessResult> validateAccess({
    required String slug,
    String? password,
  }) async {
    try {
      final result = await _remoteDataSource.validateAccess(
        slug: slug,
        password: password,
      );

      final isValid = result['is_valid'] as bool? ?? false;
      final tripId = result['trip_id']?.toString() ?? '';
      final requiresPassword = result['requires_password'] as bool? ?? false;
      final isExpired = result['is_expired'] as bool? ?? false;
      final errorMessage = result['error_message'] as String?;

      // Get the link to retrieve linkId
      final link = await getSharedLinkBySlug(slug);

      if (!isValid) {
        if (isExpired) {
          return SharedLinkAccessResult.expired(
            linkId: link?.id ?? '',
            tripId: tripId,
          );
        }

        if (requiresPassword && password == null) {
          return SharedLinkAccessResult.requiresPassword(
            linkId: link?.id ?? '',
            tripId: tripId,
          );
        }

        if (requiresPassword && password != null) {
          return SharedLinkAccessResult.invalidPassword(
            linkId: link?.id ?? '',
            tripId: tripId,
          );
        }

        return SharedLinkAccessResult(
          linkId: link?.id ?? '',
          tripId: tripId,
          isAccessible: false,
          errorMessage: errorMessage ?? 'Access denied',
        );
      }

      // Success
      return SharedLinkAccessResult.success(
        linkId: link?.id ?? '',
        tripId: tripId,
      );
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        return SharedLinkAccessResult.notFound();
      }
      throw SharedLinkException(
        'Failed to validate access: ${e.message}',
        code: 'validation_failed',
      );
    } catch (e) {
      throw SharedLinkException(
        'Failed to validate access: $e',
        code: 'unknown_error',
      );
    }
  }

  @override
  Future<void> recordView(String slug) async {
    try {
      await _remoteDataSource.recordView(slug);
    } on ServerException catch (e) {
      throw SharedLinkException(
        'Failed to record view: ${e.message}',
        code: 'record_failed',
      );
    } catch (e) {
      throw SharedLinkException(
        'Failed to record view: $e',
        code: 'unknown_error',
      );
    }
  }

  @override
  Future<SharedLink> updateSharedLink({
    required String linkId,
    String? password,
    DateTime? expiresAt,
    bool? isActive,
  }) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        throw const SharedLinkException(
          'User not authenticated',
          code: 'not_authenticated',
        );
      }

      // Validate expiration date
      if (expiresAt != null) {
        if (expiresAt.isBefore(DateTime.now())) {
          throw SharedLinkException.invalidExpiration(
            'Expiration date must be in the future',
          );
        }
      }

      // Verify ownership
      final existingLink = await getSharedLink(linkId);
      if (existingLink == null) {
        throw SharedLinkException.notFound(linkId);
      }

      if (existingLink.userId != userId) {
        throw SharedLinkException.notAuthorized();
      }

      final model = await _remoteDataSource.updateSharedLink(
        linkId: linkId,
        password: password,
        expiresAt: expiresAt,
        isActive: isActive,
      );

      return model.toEntity();
    } on ServerException catch (e) {
      throw SharedLinkException(
        'Failed to update shared link: ${e.message}',
        code: 'update_failed',
      );
    } on SharedLinkException {
      rethrow;
    } catch (e) {
      throw SharedLinkException(
        'Failed to update shared link: $e',
        code: 'unknown_error',
      );
    }
  }

  @override
  Future<void> deactivateSharedLink(String linkId) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        throw const SharedLinkException(
          'User not authenticated',
          code: 'not_authenticated',
        );
      }

      // Verify ownership
      final existingLink = await getSharedLink(linkId);
      if (existingLink == null) {
        throw SharedLinkException.notFound(linkId);
      }

      if (existingLink.userId != userId) {
        throw SharedLinkException.notAuthorized();
      }

      await _remoteDataSource.deactivateSharedLink(linkId);
    } on ServerException catch (e) {
      throw SharedLinkException(
        'Failed to deactivate shared link: ${e.message}',
        code: 'deactivate_failed',
      );
    } on SharedLinkException {
      rethrow;
    } catch (e) {
      throw SharedLinkException(
        'Failed to deactivate shared link: $e',
        code: 'unknown_error',
      );
    }
  }

  @override
  Future<void> deleteSharedLink(String linkId) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        throw const SharedLinkException(
          'User not authenticated',
          code: 'not_authenticated',
        );
      }

      // Verify ownership
      final existingLink = await getSharedLink(linkId);
      if (existingLink == null) {
        throw SharedLinkException.notFound(linkId);
      }

      if (existingLink.userId != userId) {
        throw SharedLinkException.notAuthorized();
      }

      await _remoteDataSource.deleteSharedLink(linkId);
    } on ServerException catch (e) {
      throw SharedLinkException(
        'Failed to delete shared link: ${e.message}',
        code: 'delete_failed',
      );
    } on SharedLinkException {
      rethrow;
    } catch (e) {
      throw SharedLinkException(
        'Failed to delete shared link: $e',
        code: 'unknown_error',
      );
    }
  }

  @override
  Future<SharedLinkStatistics> getStatistics(String linkId) async {
    try {
      final link = await getSharedLink(linkId);

      if (link == null) {
        throw SharedLinkException.notFound(linkId);
      }

      return SharedLinkStatistics.fromLink(link);
    } on SharedLinkException {
      rethrow;
    } catch (e) {
      throw SharedLinkException(
        'Failed to get statistics: $e',
        code: 'statistics_failed',
      );
    }
  }

  @override
  Future<bool> isSlugAvailable(String slug) async {
    try {
      return await _remoteDataSource.isSlugAvailable(slug);
    } on ServerException catch (e) {
      throw SharedLinkException(
        'Failed to check slug availability: ${e.message}',
        code: 'check_failed',
      );
    } catch (e) {
      throw SharedLinkException(
        'Failed to check slug availability: $e',
        code: 'unknown_error',
      );
    }
  }

  @override
  Future<String> generateUniqueSlug() async {
    try {
      return await _remoteDataSource.generateUniqueSlug();
    } on ServerException catch (e) {
      throw SharedLinkException(
        'Failed to generate unique slug: ${e.message}',
        code: 'generation_failed',
      );
    } catch (e) {
      throw SharedLinkException(
        'Failed to generate unique slug: $e',
        code: 'unknown_error',
      );
    }
  }
}
