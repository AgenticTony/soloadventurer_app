import '../../domain/entities/reaction.dart';

/// Data model for reactions, mapping to/from Supabase JSON
class ReactionModel {
  const ReactionModel({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.reaction,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String targetId;
  final ReactionTargetType targetType;
  final ReactionType reaction;
  final DateTime createdAt;

  /// Creates a [ReactionModel] from a Supabase JSON map
  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      targetId: json['target_id'] as String,
      targetType: ReactionTargetType.fromString(json['target_type'] as String),
      reaction: ReactionType.fromString(json['reaction'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this model to Supabase-compatible JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'target_id': targetId,
      'target_type': targetType.name,
      'reaction': reaction.name,
    };
  }
}
