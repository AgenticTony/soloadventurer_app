import 'package:equatable/equatable.dart';

/// Sync status for offline support
enum SyncStatus {
  /// Entity is synced with remote server
  synced,

  /// Entity has pending changes to sync
  pending,

  /// Entity is currently being synced
  syncing,

  /// Entity has a conflict that needs resolution
  conflict,

  /// Entity exists only on local device
  offlineOnly,
}

/// Extension on SyncStatus for database serialization
extension SyncStatusExtension on SyncStatus {
  /// Convert SyncStatus to string for database storage
  String get value {
    switch (this) {
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.syncing:
        return 'syncing';
      case SyncStatus.conflict:
        return 'conflict';
      case SyncStatus.offlineOnly:
        return 'offline_only';
    }
  }

  /// Parse string from database to SyncStatus
  static SyncStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'synced':
        return SyncStatus.synced;
      case 'pending':
        return SyncStatus.pending;
      case 'syncing':
        return SyncStatus.syncing;
      case 'conflict':
        return SyncStatus.conflict;
      case 'offline_only':
      case 'offlineonly':
        return SyncStatus.offlineOnly;
      default:
        return SyncStatus.offlineOnly;
    }
  }
}

/// Represents a shareable link for a trip with optional password protection
class SharedLink extends Equatable {
  /// Unique identifier for the shared link
  final String id;

  /// Trip ID that this link shares
  final String tripId;

  /// User ID who created this link
  final String userId;

  /// Unique slug/identifier for the share link (e.g., "abc123xyz")
  final String slug;

  /// Whether the link has password protection
  final bool hasPassword;

  /// Whether the link is currently active
  final bool isActive;

  /// Optional expiration date (null means no expiration)
  final DateTime? expiresAt;

  /// Number of times the link has been viewed
  final int viewCount;

  /// Timestamp of the last view
  final DateTime? lastViewedAt;

  /// Sync status for offline support
  final SyncStatus syncStatus;

  /// When the link was created
  final DateTime createdAt;

  /// When the link was last updated
  final DateTime updatedAt;

  const SharedLink({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.slug,
    this.hasPassword = false,
    this.isActive = true,
    this.expiresAt,
    this.viewCount = 0,
    this.lastViewedAt,
    this.syncStatus = SyncStatus.synced,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        tripId,
        userId,
        slug,
        hasPassword,
        isActive,
        expiresAt,
        viewCount,
        lastViewedAt,
        syncStatus,
        createdAt,
        updatedAt,
      ];

  /// Creates a copy of this shared link with the given fields replaced
  SharedLink copyWith({
    String? id,
    String? tripId,
    String? userId,
    String? slug,
    bool? hasPassword,
    bool? isActive,
    DateTime? expiresAt,
    int? viewCount,
    DateTime? lastViewedAt,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SharedLink(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      slug: slug ?? this.slug,
      hasPassword: hasPassword ?? this.hasPassword,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Whether the link has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Whether the link is currently accessible
  bool get isAccessible => isActive && !isExpired;

  /// Generate the full shareable URL
  String get shareUrl {
    // In production, this would use your app's domain
    // For now, use a placeholder
    return 'https://soloadventurer.app/share/$slug';
  }

  /// Check if password is required to access
  bool get requiresPassword => hasPassword;
}

/// Result of validating a shared link access
class SharedLinkAccessResult extends Equatable {
  /// The shared link ID
  final String linkId;

  /// The trip ID that the link grants access to
  final String tripId;

  /// Whether access is granted
  final bool isAccessible;

  /// Whether a password is required
  final bool requiresPassword;

  /// Whether the link has expired
  final bool isExpired;

  /// Error message if access is denied
  final String? errorMessage;

  const SharedLinkAccessResult({
    required this.linkId,
    required this.tripId,
    required this.isAccessible,
    this.requiresPassword = false,
    this.isExpired = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        linkId,
        tripId,
        isAccessible,
        requiresPassword,
        isExpired,
        errorMessage,
      ];

  /// Create a successful access result
  factory SharedLinkAccessResult.success({
    required String linkId,
    required String tripId,
  }) {
    return SharedLinkAccessResult(
      linkId: linkId,
      tripId: tripId,
      isAccessible: true,
    );
  }

  /// Create a result requiring password
  factory SharedLinkAccessResult.requiresPassword({
    required String linkId,
    required String tripId,
  }) {
    return SharedLinkAccessResult(
      linkId: linkId,
      tripId: tripId,
      isAccessible: false,
      requiresPassword: true,
      errorMessage: 'Password required',
    );
  }

  /// Create an expired result
  factory SharedLinkAccessResult.expired({
    required String linkId,
    required String tripId,
  }) {
    return SharedLinkAccessResult(
      linkId: linkId,
      tripId: tripId,
      isAccessible: false,
      isExpired: true,
      errorMessage: 'This shared link has expired',
    );
  }

  /// Create a not found result
  factory SharedLinkAccessResult.notFound() {
    return const SharedLinkAccessResult(
      linkId: '',
      tripId: '',
      isAccessible: false,
      errorMessage: 'Shared link not found or has been deactivated',
    );
  }

  /// Create an invalid password result
  factory SharedLinkAccessResult.invalidPassword({
    required String linkId,
    required String tripId,
  }) {
    return SharedLinkAccessResult(
      linkId: linkId,
      tripId: tripId,
      isAccessible: false,
      requiresPassword: true,
      errorMessage: 'Invalid password',
    );
  }
}

/// Configuration for creating a new shared link
class CreateSharedLinkConfig {
  /// Trip ID to share
  final String tripId;

  /// Optional password (null = no password required)
  final String? password;

  /// Optional expiration date (null = no expiration)
  final DateTime? expiresAt;

  const CreateSharedLinkConfig({
    required this.tripId,
    this.password,
    this.expiresAt,
  });

  /// Whether this link has password protection
  bool get hasPassword => password != null && password!.isNotEmpty;

  /// Whether this link has an expiration date
  bool get hasExpiration => expiresAt != null;
}

/// Statistics for a shared link
class SharedLinkStatistics extends Equatable {
  /// Number of times the link has been viewed
  final int totalViews;

  /// Timestamp of the last view
  final DateTime? lastViewedAt;

  /// Number of days since creation
  final int daysSinceCreation;

  /// Average views per day
  final double averageViewsPerDay;

  const SharedLinkStatistics({
    required this.totalViews,
    this.lastViewedAt,
    required this.daysSinceCreation,
    required this.averageViewsPerDay,
  });

  @override
  List<Object?> get props => [
        totalViews,
        lastViewedAt,
        daysSinceCreation,
        averageViewsPerDay,
      ];

  /// Create statistics from a shared link
  factory SharedLinkStatistics.fromLink(SharedLink link) {
    final now = DateTime.now();
    final daysSinceCreation = now.difference(link.createdAt).inDays;

    return SharedLinkStatistics(
      totalViews: link.viewCount,
      lastViewedAt: link.lastViewedAt,
      daysSinceCreation: daysSinceCreation > 0 ? daysSinceCreation : 1,
      averageViewsPerDay: daysSinceCreation > 0
          ? link.viewCount / daysSinceCreation
          : link.viewCount.toDouble(),
    );
  }
}
