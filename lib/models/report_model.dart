/// Represents a content report (post/comment) in Masr Spaces.
/// Unified model (frontend + backend compatible) with small safety enhancements.
class ReportModel {
  final String id;
  final String reporterId;

  /// Usually: 'post' or 'comment'
  final String targetType;

  final String targetId;
  final String reason;

  /// e.g. 'pending', 'resolved', 'dismissed'
  final String status;

  /// Stored/normalized to UTC.
  final DateTime createdAt;

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.status = 'pending',
    required this.createdAt,
  });

  /// Create from Supabase row / backend response.
  ///
  /// Supports alternative keys:
  /// - reporter_id OR reporterId
  /// - target_type OR targetType
  /// - target_id OR targetId
  /// - created_at OR createdAt
  factory ReportModel.fromMap(Map<String, dynamic> data) {
    final rawType =
        (data['target_type'] ?? data['targetType'] ?? '').toString();
    final rawStatus = (data['status'] ?? 'pending').toString();

    return ReportModel(
      id: (data['id'] ?? '').toString(),
      reporterId: (data['reporter_id'] ?? data['reporterId'] ?? '').toString(),
      targetType: _normalizeTargetType(rawType),
      targetId: (data['target_id'] ?? data['targetId'] ?? '').toString(),
      reason: (data['reason'] ?? '').toString(),
      status: _normalizeStatus(rawStatus),
      createdAt: _parseDateTime(data['created_at'] ?? data['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  /// Convert to map for storage/network.
  ///
  /// By default uses snake_case keys to match typical DB columns.
  Map<String, dynamic> toMap({bool snakeCase = true}) {
    final map = <String, dynamic>{
      'id': id,
      'reason': reason,
      'status': status,
      'created_at': createdAt.toUtc().toIso8601String(),
    };

    if (snakeCase) {
      map.addAll({
        'reporter_id': reporterId,
        'target_type': targetType,
        'target_id': targetId,
      });
    } else {
      map.addAll({
        'reporterId': reporterId,
        'targetType': targetType,
        'targetId': targetId,
      });
    }

    return map;
  }

  ReportModel copyWith({
    String? id,
    String? reporterId,
    String? targetType,
    String? targetId,
    String? reason,
    String? status,
    DateTime? createdAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      targetType: targetType != null
          ? _normalizeTargetType(targetType)
          : this.targetType,
      targetId: targetId ?? this.targetId,
      reason: reason ?? this.reason,
      status: status != null ? _normalizeStatus(status) : this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isResolved => status == 'resolved';

  // ---- helpers ----

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v.toUtc();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    final dt = DateTime.tryParse(s);
    return dt?.toUtc();
  }

  static String _normalizeTargetType(String v) {
    final t = v.trim().toLowerCase();
    if (t == 'posts') return 'post';
    if (t == 'comments') return 'comment';
    if (t == 'post' || t == 'comment') return t;
    // fallback (keeps forward-compat if you add new targets later)
    return t.isEmpty ? 'post' : t;
  }

  static String _normalizeStatus(String v) {
    final s = v.trim().toLowerCase();
    if (s.isEmpty) return 'pending';
    // common aliases
    if (s == 'open') return 'pending';
    if (s == 'closed' || s == 'done') return 'resolved';
    return s;
  }
}
