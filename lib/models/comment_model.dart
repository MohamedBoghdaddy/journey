/// Represents a comment on a post in Masr Spaces.
/// Unified model (frontend + backend compatible) with small safety enhancements.
class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String content;

  /// Stored/normalized to UTC.
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  /// Create from Supabase row / backend response.
  ///
  /// Supports alternative keys:
  /// - post_id OR postId
  /// - author_id OR authorId
  /// - created_at OR createdAt
  factory CommentModel.fromMap(Map<String, dynamic> data) {
    return CommentModel(
      id: (data['id'] ?? '').toString(),
      postId: (data['post_id'] ?? data['postId'] ?? '').toString(),
      authorId: (data['author_id'] ?? data['authorId'] ?? '').toString(),
      content: (data['content'] ?? '').toString(),
      createdAt: _parseDateTime(data['created_at'] ?? data['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  /// Convert to map for storage/network.
  ///
  /// By default uses snake_case keys to match typical DB columns.
  Map<String, dynamic> toMap({bool snakeCase = true}) {
    if (snakeCase) {
      return {
        'id': id,
        'post_id': postId,
        'author_id': authorId,
        'content': content,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
    }
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'content': content,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? content,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get hasContent => content.trim().isNotEmpty;

  /// Handy for preview lists.
  String get excerpt {
    final t = content.trim();
    if (t.isEmpty) return '';
    return t.length <= 140 ? t : '${t.substring(0, 140)}…';
  }

  // ---- helpers ----
  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v.toUtc();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    final dt = DateTime.tryParse(s);
    return dt?.toUtc();
  }
}
