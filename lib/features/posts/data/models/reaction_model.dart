import '../../domain/entities/reaction.dart';

class ReactionModel {
  const ReactionModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.type = ReactionType.like,
    this.createdAt,
  });

  final String id;
  final String postId;
  final String userId;
  final ReactionType type;
  final DateTime? createdAt;

  factory ReactionModel.fromMap(Map<String, dynamic> map) {
    return ReactionModel(
      id: (map['id'] ?? '').toString(),
      postId: (map['post_id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      type: ReactionType.like,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }
}
