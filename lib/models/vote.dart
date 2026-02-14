/// Data model representing a vote on a post in the backend. A vote simply
/// records that a user has upvoted a post. Downvotes can be represented
/// by removing a vote record.
class Vote {
  final String id;
  final String postId;
  final String userId;

  Vote({
    required this.id,
    required this.postId,
    required this.userId,
  });

  factory Vote.fromMap(Map<String, dynamic> data) {
    return Vote(
      id: data['id'] as String,
      postId: data['post_id'] as String,
      userId: data['user_id'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'post_id': postId,
        'user_id': userId,
      };
}