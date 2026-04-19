/// Audience levels for content (posts, journal entries)
enum ContentAudience {
  /// Only visible to approved followers
  followers,

  /// Visible to verified community members
  community,

  /// Visible to everyone
  public;

  /// Parse a [ContentAudience] from a string value
  static ContentAudience fromString(String value) {
    switch (value.toLowerCase()) {
      case 'followers':
        return ContentAudience.followers;
      case 'community':
        return ContentAudience.community;
      case 'public':
        return ContentAudience.public;
      default:
        throw ArgumentError('Unknown ContentAudience: $value');
    }
  }
}

/// Extension for serialization
extension ContentAudienceExtension on ContentAudience {
  /// String representation for API serialization
  String get value {
    switch (this) {
      case ContentAudience.followers:
        return 'followers';
      case ContentAudience.community:
        return 'community';
      case ContentAudience.public:
        return 'public';
    }
  }
}
