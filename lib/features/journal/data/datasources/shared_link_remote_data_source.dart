import 'package:soloadventurer/core/errors/app_exception.dart';
import 'package:soloadventurer/features/journal/data/models/shared_link_model.dart';

/// Remote data source interface for shared links
abstract class SharedLinkRemoteDataSource {
  /// Create a new shared link
  ///
  /// Throws [AppException] on failure.
  Future<SharedLinkModel> createSharedLink({
    required String tripId,
    required String userId,
    String? password,
    DateTime? expiresAt,
  });

  /// Get a shared link by ID
  ///
  /// Throws [AppException] if link not found.
  Future<SharedLinkModel> getSharedLink(String linkId);

  /// Get a shared link by slug
  ///
  /// Throws [AppException] if link not found.
  Future<SharedLinkModel> getSharedLinkBySlug(String slug);

  /// Get all shared links for a trip
  ///
  /// Returns empty list if no links found.
  Future<List<SharedLinkModel>> getSharedLinksForTrip(String tripId);

  /// Get all shared links for a user
  ///
  /// Returns empty list if no links found.
  Future<List<SharedLinkModel>> getUserSharedLinks(String userId);

  /// Update a shared link
  ///
  /// Throws [AppException] on failure.
  Future<SharedLinkModel> updateSharedLink({
    required String linkId,
    String? password,
    DateTime? expiresAt,
    bool? isActive,
  });

  /// Deactivate a shared link
  ///
  /// Throws [AppException] on failure.
  Future<void> deactivateSharedLink(String linkId);

  /// Delete a shared link
  ///
  /// Throws [AppException] on failure.
  Future<void> deleteSharedLink(String linkId);

  /// Validate access to a shared link
  ///
  /// Returns a map containing validation results:
  /// - trip_id: UUID
  /// - is_valid: boolean
  /// - requires_password: boolean
  /// - is_expired: boolean
  /// - error_message: string or null
  ///
  /// Throws [AppException] on failure.
  Future<Map<String, dynamic>> validateAccess({
    required String slug,
    String? password,
  });

  /// Record a view for a shared link
  ///
  /// Throws [AppException] on failure.
  Future<void> recordView(String slug);

  /// Check if a slug is available
  ///
  /// Returns true if slug is available, false if already in use.
  Future<bool> isSlugAvailable(String slug);

  /// Generate a unique slug
  ///
  /// Returns a unique slug that is not already in use.
  Future<String> generateUniqueSlug();
}
