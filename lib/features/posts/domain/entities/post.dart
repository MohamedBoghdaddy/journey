class Post {
  const Post({
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
}
