class Report {
  const Report({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.details,
    this.createdAt,
  });

  final String id;
  final String reporterId;
  final String targetType; // 'user', 'post', 'space', 'product'
  final String targetId;
  final String reason;
  final String? details;
  final DateTime? createdAt;
}
