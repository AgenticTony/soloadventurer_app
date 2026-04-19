import 'package:equatable/equatable.dart';

/// Represents a comment on a journal entry
class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.journalId,
    required this.authorId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.parentId,
    this.authorName,
    this.authorAvatarUrl,
    this.deletedAt,
    this.replies = const [],
  });

  /// Unique identifier
  final String id;

  /// The journal entry this comment belongs to
  final String journalId;

  /// The user who wrote the comment
  final String authorId;

  /// Display name of the author (joined from profiles)
  final String? authorName;

  /// Avatar URL of the author (joined from profiles)
  final String? authorAvatarUrl;

  /// Parent comment ID for threaded replies
  final String? parentId;

  /// The comment text content
  final String body;

  /// Soft-delete timestamp
  final DateTime? deletedAt;

  /// When the comment was created
  final DateTime createdAt;

  /// When the comment was last updated
  final DateTime updatedAt;

  /// Nested replies to this comment
  final List<Comment> replies;

  /// Whether this comment has been soft-deleted
  bool get isDeleted => deletedAt != null;

  /// Whether this comment is a reply to another comment
  bool get isReply => parentId != null;

  @override
  List<Object?> get props => [
        id,
        journalId,
        authorId,
        body,
        parentId,
        deletedAt,
        createdAt,
        updatedAt,
        replies,
      ];

  Comment copyWith({
    String? id,
    String? journalId,
    String? authorId,
    String? body,
    String? parentId,
    String? authorName,
    String? authorAvatarUrl,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      journalId: journalId ?? this.journalId,
      authorId: authorId ?? this.authorId,
      body: body ?? this.body,
      parentId: parentId ?? this.parentId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
    );
  }
}
