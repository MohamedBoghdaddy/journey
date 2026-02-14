/// Represents a forum post in Masr Spaces.
/// Unified model (frontend + backend compatible) with small safety enhancements.
class PostModel {
  final String id;
  final String authorId;
  final String spaceId;
  final String title;
  final String content;

  /// Stored as UTC if parse-able; still works with local/UTC strings.
  final DateTime createdAt;

  /// Total number of upvotes (may come from a view/join or computed).
  final int voteCount;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.spaceId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.voteCount = 0,
  });

  /// Create from Supabase row / backend response.
  ///
  /// Supports alternative keys:
  /// - author_id OR authorId
  /// - space_id OR spaceId
  /// - created_at OR createdAt
  /// - vote_count OR voteCount
  factory PostModel.fromMap(Map<String, dynamic> data) {
    return PostModel(
      id: (data['id'] ?? '').toString(),
      authorId: (data['author_id'] ?? data['authorId'] ?? '').toString(),
      spaceId: (data['space_id'] ?? data['spaceId'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      content: (data['content'] ?? '').toString(),
      createdAt: _parseDateTime(data['created_at'] ?? data['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      voteCount: _asInt(data['vote_count'] ?? data['voteCount']) ?? 0,
    );
  }

  /// Convert to map for storage/network.
  ///
  /// By default uses snake_case keys to match typical DB columns.
  Map<String, dynamic> toMap({bool snakeCase = true}) {
    if (snakeCase) {
      return {
        'id': id,
        'author_id': authorId,
        'space_id': spaceId,
        'title': title,
        'content': content,
        'created_at': createdAt.toUtc().toIso8601String(),
        'vote_count': voteCount,
      };
    }
    return {
      'id': id,
      'authorId': authorId,
      'spaceId': spaceId,
      'title': title,
      'content': content,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'voteCount': voteCount,
    };
  }

  PostModel copyWith({
    String? id,
    String? authorId,
    String? spaceId,
    String? title,
    String? content,
    DateTime? createdAt,
    int? voteCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      spaceId: spaceId ?? this.spaceId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      voteCount: voteCount ?? this.voteCount,
    );
  }

  /// Handy for preview lists.
  String get excerpt {
    final t = content.trim();
    if (t.isEmpty) return '';
    return t.length <= 140 ? t : '${t.substring(0, 140)}…';
  }

  bool get hasContent => content.trim().isNotEmpty;

  // ---- helpers ----

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v.toUtc();
    // Supabase sometimes returns ISO string
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    final dt = DateTime.tryParse(s);
    return dt?.toUtc();
  }
}
