/// Types of reactions a user can give
enum ReactionType {
  /// Standard like reaction
  like,

  /// Love reaction
  love,

  /// Inspiring reaction
  inspire,

  /// Helpful reaction
  helpful;

  /// Parse from Supabase reaction_type enum value
  static ReactionType fromString(String value) {
    switch (value) {
      case 'like':
        return ReactionType.like;
      case 'love':
        return ReactionType.love;
      case 'inspire':
        return ReactionType.inspire;
      case 'helpful':
        return ReactionType.helpful;
      default:
        throw ArgumentError('Unknown ReactionType: $value');
    }
  }
}

/// Target type for reactions
enum ReactionTargetType {
  /// Reaction on a journal entry
  journal,

  /// Reaction on a comment
  comment;

  /// Parse from database string
  static ReactionTargetType fromString(String value) {
    switch (value) {
      case 'journal':
        return ReactionTargetType.journal;
      case 'comment':
        return ReactionTargetType.comment;
      default:
        throw ArgumentError('Unknown ReactionTargetType: $value');
    }
  }
}
