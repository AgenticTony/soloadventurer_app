import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';

/// Domain service for managing shared links for trips
abstract class SharedLinkService {
  /// Initialize the service
  Future<void> initialize();

  /// Clean up resources
  Future<void> dispose();

  /// Create a new shared link for a trip
  ///
  /// Returns the created [SharedLink] with a unique slug.
  /// If [password] is provided, the link will be password-protected.
  /// If [expiresAt] is provided, the link will expire after that date.
  Future<SharedLink> createSharedLink(CreateSharedLinkConfig config);

  /// Get a shared link by its ID
  Future<SharedLink?> getSharedLink(String linkId);

  /// Get a shared link by its slug
  Future<SharedLink?> getSharedLinkBySlug(String slug);

  /// Get all shared links for a trip
  Future<List<SharedLink>> getSharedLinksForTrip(String tripId);

  /// Get all shared links created by the user
  Future<List<SharedLink>> getUserSharedLinks();

  /// Validate access to a shared link
  ///
  /// Returns [SharedLinkAccessResult] indicating whether access is granted.
  /// If the link requires a password, [password] must be provided.
  Future<SharedLinkAccessResult> validateAccess({
    required String slug,
    String? password,
  });

  /// Record a view for a shared link
  ///
  /// Increments the view count and updates last_viewed_at.
  Future<void> recordView(String slug);

  /// Update a shared link
  ///
  /// Only the link owner can update the link.
  /// [password] can be set to null to remove password protection.
  /// [expiresAt] can be set to null to remove expiration.
  Future<SharedLink> updateSharedLink({
    required String linkId,
    String? password,
    DateTime? expiresAt,
    bool? isActive,
  });

  /// Deactivate a shared link
  ///
  /// The link will no longer be accessible but remains in the database.
  Future<void> deactivateSharedLink(String linkId);

  /// Delete a shared link permanently
  Future<void> deleteSharedLink(String linkId);

  /// Get statistics for a shared link
  Future<SharedLinkStatistics> getStatistics(String linkId);

  /// Check if a slug is available (not already in use)
  Future<bool> isSlugAvailable(String slug);

  /// Generate a new unique slug
  Future<String> generateUniqueSlug();
}

/// Error thrown when shared link operations fail
class SharedLinkException implements Exception {
  /// Error message
  final String message;

  /// Error code
  final String code;

  /// Additional details
  final Map<String, dynamic>? details;

  const SharedLinkException(
    this.message, {
    this.code = 'shared_link_error',
    this.details,
  });

  /// Error for link not found
  factory SharedLinkException.notFound(String slug) {
    return SharedLinkException(
      'Shared link not found: $slug',
      code: 'not_found',
    );
  }

  /// Error for expired link
  factory SharedLinkException.expired(String slug) {
    return SharedLinkException(
      'Shared link has expired: $slug',
      code: 'expired',
    );
  }

  /// Error for invalid password
  factory SharedLinkException.invalidPassword() {
    return SharedLinkException(
      'Invalid password',
      code: 'invalid_password',
    );
  }

  /// Error for link not owned by user
  factory SharedLinkException.notAuthorized() {
    return SharedLinkException(
      'You are not authorized to modify this shared link',
      code: 'not_authorized',
    );
  }

  /// Error for slug already in use
  factory SharedLinkException.slugInUse(String slug) {
    return SharedLinkException(
      'Slug already in use: $slug',
      code: 'slug_in_use',
    );
  }

  /// Error for invalid expiration date
  factory SharedLinkException.invalidExpiration(String reason) {
    return SharedLinkException(
      'Invalid expiration date: $reason',
      code: 'invalid_expiration',
    );
  }

  /// Error for network issues
  factory SharedLinkException.network(String message) {
    return SharedLinkException(
      'Network error: $message',
      code: 'network_error',
    );
  }

  @override
  String toString() {
    return 'SharedLinkException: $message (code: $code)';
  }
}
