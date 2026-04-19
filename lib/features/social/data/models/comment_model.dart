import '../../domain/entities/comment.dart';

/// Data model for comments, mapping to/from Supabase JSON
class CommentModel {
  const CommentModel({
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
  });

  final String id;
  final String journalId;
  final String authorId;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentId;
  final String? authorName;
  final String? authorAvatarUrl;
  final DateTime? deletedAt;

  /// Creates a [CommentModel] from a Supabase JSON map
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      journalId: json['journal_id'] as String,
      authorId: json['author_id'] as String,
      body: json['body'] as String? ?? '[deleted]',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      parentId: json['parent_id'] as String?,
      authorName: json['author_name'] as String?,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  /// Converts this model to a domain [Comment] entity
  Comment toEntity() {
    return Comment(
      id: id,
      journalId: journalId,
      authorId: authorId,
      body: deletedAt != null ? '[deleted]' : body,
      createdAt: createdAt,
      updatedAt: updatedAt,
      parentId: parentId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      deletedAt: deletedAt,
    );
  }
}
