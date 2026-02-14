import '../../domain/entities/post.dart';

class PostModel {
  const PostModel({
    required this.id,
    required this.authorId,
    this.spaceId,
    required this.title,
    required this.content,
    this.createdAt,
    this.authorName,
    this.likeCount,
    this.commentCount,
  });

  final String id;
  final String authorId;
  final String? spaceId;
  final String title;
  final String content;
  final DateTime? createdAt;
  final String? authorName;
  final int? likeCount;
  final int? commentCount;

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: (map['id'] ?? '').toString(),
      authorId: (map['author_id'] ?? map['user_id'] ?? '').toString(),
      spaceId: map['space_id']?.toString(),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? map['body'] ?? '').toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      authorName: map['author_name']?.toString() ?? map['display_name']?.toString(),
      likeCount: map['like_count'] is int ? map['like_count'] as int : int.tryParse('${map['like_count']}'),
      commentCount: map['comment_count'] is int ? map['comment_count'] as int : int.tryParse('${map['comment_count']}'),
    );
  }

  Map<String, dynamic> toInsertMap() => {
    'title': title,
    'content': content,
    'space_id': spaceId,
    'author_id': authorId,
  };

  Post toEntity() => Post(
    id: id,
    authorId: authorId,
    spaceId: spaceId,
    title: title,
    content: content,
    createdAt: createdAt,
    authorName: authorName,
    likeCount: likeCount,
    commentCount: commentCount,
  );
}
