class ModReport {
  const ModReport({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.details,
    this.status,
    this.createdAt,
  });

  final String id;
  final String reporterId;
  final String targetType;
  final String targetId;
  final String reason;
  final String? details;
  final String? status;
  final DateTime? createdAt;
}
