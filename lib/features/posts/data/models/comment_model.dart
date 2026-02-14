import '../../domain/entities/comment.dart';

class CommentModel {
  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.createdAt,
    this.userName,
  });

  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime? createdAt;
  final String? userName;

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: (map['id'] ?? '').toString(),
      postId: (map['post_id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      content: (map['content'] ?? map['body'] ?? '').toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      userName: map['user_name']?.toString() ?? map['display_name']?.toString(),
    );
  }

  Map<String, dynamic> toInsertMap() => {
    'post_id': postId,
    'user_id': userId,
    'content': content,
  };

  Comment toEntity() => Comment(
    id: id,
    postId: postId,
    userId: userId,
    content: content,
    createdAt: createdAt,
    userName: userName,
  );
}
