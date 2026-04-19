/// Who is allowed to comment on content
enum CommentPermission {
  /// Nobody can comment
  nobody,

  /// Only approved followers can comment
  followers,

  /// All community members can comment
  everyone;

  /// Parse a [CommentPermission] from a string value
  static CommentPermission fromString(String value) {
    switch (value.toLowerCase()) {
      case 'nobody':
        return CommentPermission.nobody;
      case 'followers':
        return CommentPermission.followers;
      case 'everyone':
        return CommentPermission.everyone;
      default:
        throw ArgumentError('Unknown CommentPermission: $value');
    }
  }
}

/// Extension for serialization
extension CommentPermissionExtension on CommentPermission {
  /// String representation for API serialization
  String get value {
    switch (this) {
      case CommentPermission.nobody:
        return 'nobody';
      case CommentPermission.followers:
        return 'followers';
      case CommentPermission.everyone:
        return 'everyone';
    }
  }
}
