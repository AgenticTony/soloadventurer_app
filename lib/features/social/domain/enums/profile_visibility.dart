/// Profile visibility levels controlling who can see a user's profile
enum ProfileVisibility {
  /// Profile is hidden from everyone except approved followers
  hidden,

  /// Profile visible to verified community members
  community,

  /// Profile is publicly discoverable
  public;

  /// Parse a [ProfileVisibility] from a string value
  static ProfileVisibility fromString(String value) {
    switch (value.toLowerCase()) {
      case 'hidden':
        return ProfileVisibility.hidden;
      case 'community':
        return ProfileVisibility.community;
      case 'public':
        return ProfileVisibility.public;
      default:
        throw ArgumentError('Unknown ProfileVisibility: $value');
    }
  }
}

/// Extension for serialization
extension ProfileVisibilityExtension on ProfileVisibility {
  /// String representation for API serialization
  String get value {
    switch (this) {
      case ProfileVisibility.hidden:
        return 'hidden';
      case ProfileVisibility.community:
        return 'community';
      case ProfileVisibility.public:
        return 'public';
    }
  }
}
