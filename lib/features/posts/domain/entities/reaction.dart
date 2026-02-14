enum ReactionType { like }

class Reaction {
  const Reaction({
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
}
