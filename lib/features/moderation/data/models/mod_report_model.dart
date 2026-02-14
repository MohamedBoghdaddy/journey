import '../../domain/entities/mod_report.dart';

class ModReportModel {
  const ModReportModel({
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

  factory ModReportModel.fromMap(Map<String, dynamic> map) {
    return ModReportModel(
      id: (map['id'] ?? '').toString(),
      reporterId: (map['reporter_id'] ?? '').toString(),
      targetType: (map['target_type'] ?? '').toString(),
      targetId: (map['target_id'] ?? '').toString(),
      reason: (map['reason'] ?? '').toString(),
      details: map['details']?.toString(),
      status: map['status']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  ModReport toEntity() => ModReport(
    id: id,
    reporterId: reporterId,
    targetType: targetType,
    targetId: targetId,
    reason: reason,
    details: details,
    status: status,
    createdAt: createdAt,
  );
}
