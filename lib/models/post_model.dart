/// Represents a forum post.
class PostModel {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> data) {
    return PostModel(
      id: data['id'] as String,
      authorId: data['author_id'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'author_id': authorId,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };
}